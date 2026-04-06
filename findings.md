# Findings & Decisions

## Requirements
- Remove all Android and shell-script hard dependencies on Termux private paths and runtime.
- Keep the current user-facing flow: install -> foreground service start -> poll `http://localhost:8080` -> WebView load.
- Move runtime ownership to app-private storage rooted at `Context.getFilesDir()`.
- Ship bootstrap assets in APK; keep large Ubuntu rootfs and code-server payloads as first-run downloads.
- Replace `proot-distro` with direct `proot` invocation against an app-owned rootfs.
- Prefer pid/log/marker files over broad `pgrep`/`pkill`.
- Avoid unrelated refactors and UI changes.

## Research Findings
- Remote repository currently exposes only `origin/main`; no `origin/develop` branch exists.
- Project already has a `.worktrees/` directory and it is gitignored.
- User confirmed: repo is `/Users/chenzilve/Projects/mobile vscode`, base branch is `main`, there is no issue/PR, and implementation should start.
- `MainActivity.java` hardcodes `BASE_DIR = "/data/data/com.termux/files/home/mobile-dev-env"`, requests external storage permissions, shells out to `/data/data/com.termux/files/usr/bin/bash`, and leaves `copyScriptsFromAssets()` unimplemented.
- `CodeServerService.java` also shells out to the Termux bash binary and the same Termux base directory.
- Existing shell scripts use a Termux shebang, assume `BASE_DIR` inside Termux home, depend on host commands like `curl`, `tar`, `proot`, `nc`, and use broad `pkill`/`pgrep` matching.
- `start.sh` currently depends on `proot-distro login ubuntu --shared-tmp`; `stop.sh` uses `pkill` first and only loosely manages a pid file.
- `config.sh` is incomplete relative to script usage: it defines no `CONFIG_DIR`, `LOGS_DIR`, `ROOTFS_URL`, or `VSCODE_URL`, though other scripts reference those variables.
- `AndroidManifest.xml` currently includes `READ/WRITE_EXTERNAL_STORAGE` even though the approved plan keeps workspace/data in app-private storage.
- `android/app/build.gradle` is minimal and has no explicit test setup or asset/runtime packaging customization yet.
- No runtime binaries (proot, busybox) or native libraries are present in the repository; APK build depends on downloading these at first run.

## Implementation Summary

### Java Helpers Added
- `RuntimePaths.java`: Centralized app-private path management derived from `Context.getFilesDir()`
- `ProcessRunner.java`: Shell resolution (app-owned preferred, system fallback) and script execution
- `RuntimeInstaller.java`: Asset extraction and bootstrap binary download from manifest URLs

### Scripts Added to assets/scripts/
- `config.sh`: Environment-driven configuration (paths injected from Android)
- `install.sh`: Downloads and extracts rootfs and code-server using busybox applets
- `start.sh`: Direct proot invocation (replaces proot-distro) with bind mounts
- `stop.sh`: PID-file-based shutdown with pkill fallback
- `fix-libs.sh`: Library dependency fix adapted for app-private paths

### Manifest Added
- `assets/runtime/manifest.json`: URLs for busybox (official), proot (Alpine Linux package), rootfs (proot-distro), and code-server (GitHub releases)

### Android Layer Updated
- `MainActivity.java`: Uses RuntimePaths/ProcessRunner/RuntimeInstaller; removed Termux bash path references
- `CodeServerService.java`: Uses RuntimePaths/ProcessRunner; removed Termux bash path references
- `AndroidManifest.xml`: Removed `READ_EXTERNAL_STORAGE` and `WRITE_EXTERNAL_STORAGE` permissions

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| Create worktree branch `feat/app-owned-runtime` | Keeps large refactor isolated from `main` |
| Use project-root planning files inside the worktree | Follows planning-with-files workflow and preserves task context |
| Preserve current activity/service/WebView lifecycle and replace only runtime ownership | Matches approved minimal-refactor plan and minimizes behavioral drift |
| Introduce small Java helper classes for runtime paths, installation, and process launching | Gives focused seams for testing and removes duplicated path/process logic from activity/service |
| Use `/system/bin/sh` as fallback shell | Allows scripts to run before app-owned busybox is downloaded |
| Download bootstrap binaries at first run | Repository lacks prebuilt binaries; APK stays small while remaining self-contained after first launch |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| Global memory file did not exist | Proceeded without prior project memory; no persistent memory assumed |
| Gradle 9.4 incompatible with AGP 8.2 | Created Gradle wrapper configuration for 8.2.1; wrapper download timed out, so system Gradle used for verification |
| No runtime binaries in repository | Implemented manifest-driven download in RuntimeInstaller; added URLs from official sources (busybox.net, Alpine Linux packages, termux/proot-distro releases) |
| APK build issues with Android SDK | Created local.properties pointing to `/Users/chenzilve/Library/Android/sdk`; created gradle.properties with `android.useAndroidX=true` |

## Known Limitations / Not Yet Verified
| Item | Status |
|------|--------|
| Runtime binary download on real device | Not verified; URLs in manifest need network connectivity on first run |
| proot static binary extraction from Alpine .apk | Not verified; may need adaptation if extraction method differs |
| Script execution with `/system/bin/sh` | Verified syntactically, not runtime tested on Android device |
| Full APK install → install → start → WebView flow | Not end-to-end tested on physical device or emulator |
| fix-libs.sh library download | Depends on busybox wget; not verified |

## Resources
- Worktree root: `/Users/chenzilve/Projects/mobile vscode/.worktrees/app-owned-runtime`
- BusyBox official binaries: https://busybox.net/downloads/binaries/
- Alpine Linux packages: https://dl-cdn.alpinelinux.org/alpine/edge/community/aarch64/
- Termux proot-distro releases: https://github.com/termux/proot-distro/releases
- Code-server releases: https://github.com/coder/code-server/releases
