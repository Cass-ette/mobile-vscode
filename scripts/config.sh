#!/data/data/com.termux/files/usr/bin/bash
# Mobile VS Code - Environment Configuration

# Base directory
export BASE_DIR="/data/data/com.termux/files/home/mobile-dev-env"

# Subdirectories
export ROOTFS_DIR="$BASE_DIR/ubuntu-rootfs"
export VSCODE_DIR="$BASE_DIR/vscode-server"
export VSCODE_DATA_DIR="$BASE_DIR/vscode-data"
export WORKSPACE_DIR="$BASE_DIR/workspace"
export SCRIPTS_DIR="$BASE_DIR/scripts"

# Versions
export VSCODE_VERSION="${VSCODE_VERSION:-4.91.1}"

# Proxy for downloads
export GHPROXY="${GHPROXY:-https://ghproxy.com/}"

# Logging functions
log_info() {
    echo "[INFO] $1"
}

log_warn() {
    echo "[WARN] $1"
}

log_error() {
    echo "[ERROR] $1"
}
