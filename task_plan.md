# Task Plan: Standalone App-Owned Runtime Refactor

## Goal
Refactor the Android app so the APK installs, launches, and persists its own runtime entirely under `com.mobilevscode` app-private storage without any Termux dependency.

## Current Phase
Phase 1

## Phases

### Phase 1: Requirements & Discovery
- [x] Confirm user-approved scope and base branch (`main`)
- [x] Create isolated worktree `feat/app-owned-runtime`
- [x] Audit Android entrypoints, scripts, assets, and packaging
- [x] Record findings in findings.md
- **Status:** complete

### Phase 2: Runtime Path & Asset Design
- [ ] Define app-private directory contract under `Context.getFilesDir()`
- [ ] Define marker/pid/log/config file locations
- [ ] Define Android helper classes and responsibilities
- [ ] Add minimal Java unit-test support and write failing tests first
- **Status:** in_progress

### Phase 3: Implementation
- [ ] Add shared Android runtime helpers
- [ ] Migrate Android activity/service to app-owned runtime
- [ ] Move/adapt bootstrap scripts into assets
- [ ] Update build/manifest packaging as needed
- **Status:** pending

### Phase 4: Testing & Verification
- [ ] Add/adjust focused tests where practical
- [ ] Search for removed Termux/proot-distro references
- [ ] Build debug APK successfully
- [ ] Record verification results in progress.md
- **Status:** pending

### Phase 5: Delivery
- [ ] Summarize modified files and behavior changes
- [ ] Report exactly what was verified vs not yet verified
- **Status:** pending

## Key Questions
1. What existing Android/service/script boundaries can be preserved while replacing the runtime ownership model?
2. What minimum bootstrap payload must be shipped in assets for first-run install to work?
3. Where can focused tests be added before production edits to satisfy TDD for the new helper logic?

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Use a dedicated worktree on a new feature branch | Isolates large multi-file changes from `main` |
| Keep scope limited to plan-specified standalone runtime migration | Matches user request and global minimal-diff instructions |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| `origin/develop` not found during branch safety check | 1 | Confirmed repo only has `origin/main`; user confirmed `main` as base branch |

## Notes
- Re-read this plan before major decisions.
- Prefer the smallest relevant verification before broader checks.
- Keep changes strictly within the approved runtime-independence plan.
