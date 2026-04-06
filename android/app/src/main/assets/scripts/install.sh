#!/system/bin/sh
# Mobile VS Code - One-click installer
# Uses system curl and toybox instead of downloading busybox.

set -e

SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/config.sh"

# Download URLs
ROOTFS_URL="https://github.com/termux/proot-distro/releases/download/v4.30.1/ubuntu-questing-aarch64-pd-v4.30.1.tar.xz"

if [ -f "$INSTALL_MARKER" ]; then
    log_info "Environment already installed at $BASE_DIR"
    exit 0
fi

log_info "========================================"
log_info "  Mobile VS Code Installer"
log_info "========================================"
log_info "Install path: $BASE_DIR"
log_info ""

log_info "Creating directory structure..."
mkdir -p "$ROOTFS_DIR" "$CODE_SERVER_DIR" "$VSCODE_DATA_DIR/extensions" "$WORKSPACE_DIR/projects" "$CONFIG_DIR" "$LOGS_DIR"

if [ ! -f "$ROOTFS_DIR/bin/bash" ]; then
    cd "$BASE_DIR"
    if [ -f "ubuntu-rootfs.tar" ]; then
        log_info "Using pre-existing Ubuntu RootFS tarball..."
    elif [ -f "ubuntu-rootfs.tar.xz" ]; then
        log_info "Using pre-existing compressed Ubuntu RootFS tarball..."
    else
        log_info "Downloading Ubuntu RootFS..."
        download ubuntu-rootfs.tar.xz "$ROOTFS_URL" || download ubuntu-rootfs.tar.xz "${GHPROXY}${ROOTFS_URL}"
    fi
    if [ -f "ubuntu-rootfs.tar" ]; then
        log_info "Extracting RootFS (ignoring device node errors)..."
        /system/bin/toybox tar -xf ubuntu-rootfs.tar -C "$ROOTFS_DIR" --strip-components=1 2>/dev/null || true
        rm -f ubuntu-rootfs.tar
    else
        log_info "Extracting RootFS..."
        extract_tar ubuntu-rootfs.tar.xz -C "$ROOTFS_DIR" --strip-components=1 2>/dev/null || true
        rm -f ubuntu-rootfs.tar.xz
    fi
    log_info "Ubuntu RootFS installed"

    # Fix DNS config for proot (systemd-resolved doesn't work in proot)
    log_info "Configuring DNS..."
    echo "nameserver 8.8.8.8" > "$ROOTFS_DIR/etc/resolv.conf"
    echo "nameserver 8.8.4.4" >> "$ROOTFS_DIR/etc/resolv.conf"
fi

if [ -f "$SCRIPT_DIR/fix-libs.sh" ]; then
    log_info "Running library fix script..."
    sh "$SCRIPT_DIR/fix-libs.sh" || log_warn "Library fix had issues"
fi

if [ ! -f "$CODE_SERVER_DIR/bin/code-server" ]; then
    cd "$BASE_DIR"
    VSCODE_TARBALL="code-server-${CODE_SERVER_VERSION}-linux-arm64.tar.gz"
    VSCODE_URL="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-arm64.tar.gz"
    if [ -f "code-server.tar.gz" ]; then
        log_info "Using pre-existing VS Code Server tarball..."
        VSCODE_TARBALL="code-server.tar.gz"
    else
        log_info "Downloading VS Code Server v${CODE_SERVER_VERSION}..."
        download "$VSCODE_TARBALL" "$VSCODE_URL" || download "$VSCODE_TARBALL" "${GHPROXY}${VSCODE_URL}"
    fi
    log_info "Extracting VS Code Server..."
    extract_tgz "$VSCODE_TARBALL" -C "$CODE_SERVER_DIR" --strip-components=1 2>/dev/null || true
    rm -f "$VSCODE_TARBALL"
    log_info "VS Code Server installed"
fi

log_info "Creating VS Code settings..."
mkdir -p "$CONFIG_DIR"
echo '{' > "$CONFIG_DIR/vscode-settings.json"
echo '    "workbench.colorTheme": "Default Dark+",' >> "$CONFIG_DIR/vscode-settings.json"
echo '    "workbench.startupEditor": "welcomePage",' >> "$CONFIG_DIR/vscode-settings.json"
echo '    "editor.fontSize": 14,' >> "$CONFIG_DIR/vscode-settings.json"
echo '    "editor.lineNumbers": "on",' >> "$CONFIG_DIR/vscode-settings.json"
echo '    "editor.wordWrap": "on",' >> "$CONFIG_DIR/vscode-settings.json"
echo '    "terminal.integrated.defaultProfile.linux": "bash",' >> "$CONFIG_DIR/vscode-settings.json"
echo '    "telemetry.enableTelemetry": false,' >> "$CONFIG_DIR/vscode-settings.json"
echo '    "security.workspace.trust.enabled": false' >> "$CONFIG_DIR/vscode-settings.json"
echo '}' >> "$CONFIG_DIR/vscode-settings.json"

mkdir -p "$ROOTFS_DIR/root"
echo 'export HOME=/root' > "$ROOTFS_DIR/root/.bashrc"
echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> "$ROOTFS_DIR/root/.bashrc"
echo 'export TERM=xterm-256color' >> "$ROOTFS_DIR/root/.bashrc"
echo "alias ll='ls -la'" >> "$ROOTFS_DIR/root/.bashrc"
echo 'echo "Welcome to Mobile VS Code!"' >> "$ROOTFS_DIR/root/.bashrc"

touch "$INSTALL_MARKER"
chmod +x "$SCRIPT_DIR/"*.sh 2>/dev/null || true

log_info "========================================"
log_info "Installation Complete!"
log_info "========================================"
log_info "Workspace: $WORKSPACE_DIR"
exit 0
