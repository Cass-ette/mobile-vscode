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
    log_info "Downloading Ubuntu RootFS..."
    cd "$BASE_DIR"
    download ubuntu-rootfs.tar.xz "$ROOTFS_URL" || download ubuntu-rootfs.tar.xz "${GHPROXY}${ROOTFS_URL}"
    log_info "Extracting RootFS..."
    extract_tar ubuntu-rootfs.tar.xz -C "$ROOTFS_DIR" --strip-components=1
    rm -f ubuntu-rootfs.tar.xz
    log_info "Ubuntu RootFS installed"
fi

if [ -f "$SCRIPT_DIR/fix-libs.sh" ]; then
    log_info "Running library fix script..."
    sh "$SCRIPT_DIR/fix-libs.sh" || log_warn "Library fix had issues"
fi

if [ ! -f "$CODE_SERVER_DIR/bin/code-server" ]; then
    log_info "Downloading VS Code Server v${CODE_SERVER_VERSION}..."
    cd "$BASE_DIR"
    VSCODE_TARBALL="code-server-${CODE_SERVER_VERSION}-linux-arm64.tar.gz"
    VSCODE_URL="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-arm64.tar.gz"
    download "$VSCODE_TARBALL" "$VSCODE_URL" || download "$VSCODE_TARBALL" "${GHPROXY}${VSCODE_URL}"
    log_info "Extracting VS Code Server..."
    extract_tgz "$VSCODE_TARBALL" -C "$CODE_SERVER_DIR" --strip-components=1
    rm -f "$VSCODE_TARBALL"
    log_info "VS Code Server installed"
fi

log_info "Creating VS Code settings..."
cat > "$CONFIG_DIR/vscode-settings.json" << 'EOF'
{
    "workbench.colorTheme": "Default Dark+",
    "workbench.startupEditor": "welcomePage",
    "editor.fontSize": 14,
    "editor.lineNumbers": "on",
    "editor.wordWrap": "on",
    "terminal.integrated.defaultProfile.linux": "bash",
    "telemetry.enableTelemetry": false,
    "security.workspace.trust.enabled": false
}
EOF

mkdir -p "$ROOTFS_DIR/root"
cat > "$ROOTFS_DIR/root/.bashrc" << 'EOF'
export HOME=/root
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export TERM=xterm-256color
alias ll='ls -la'
echo "Welcome to Mobile VS Code!"
EOF

touch "$INSTALL_MARKER"
chmod +x "$SCRIPT_DIR/"*.sh 2>/dev/null || true

log_info "========================================"
log_info "Installation Complete!"
log_info "========================================"
log_info "Workspace: $WORKSPACE_DIR"
exit 0
