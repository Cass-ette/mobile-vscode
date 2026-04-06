#!/system/bin/sh
# Mobile VS Code - Environment Configuration
# This script expects environment variables to be injected by the Android app.

# Use system tools
download() {
    /system/bin/curl -L -o "$@"
}

extract_tar() {
    /system/bin/toybox tar -xf "$@"
}

extract_tgz() {
    /system/bin/toybox tar -xzf "$@"
}

# Base directory (injected from Android)
: "${BASE_DIR:=/data/data/com.mobilevscode/files/mobile-dev-env}"

# Subdirectories
export ROOTFS_DIR="${BASE_DIR}/ubuntu-rootfs"
export CODE_SERVER_DIR="${BASE_DIR}/code-server"
export VSCODE_DATA_DIR="${BASE_DIR}/vscode-data"
export WORKSPACE_DIR="${BASE_DIR}/workspace"
export SCRIPTS_DIR="${BASE_DIR}/scripts"
export RUNTIME_BIN_DIR="${BASE_DIR}/runtime/bin"
export CONFIG_DIR="${BASE_DIR}/config"
export LOGS_DIR="${BASE_DIR}/logs"

# Runtime state
export PID_FILE="${BASE_DIR}/run/code-server.pid"
export INSTALL_MARKER="${BASE_DIR}/install.complete"
export CODE_SERVER_LOG="${LOGS_DIR}/code-server.log"
export CODE_SERVER_PORT="8080"

# Versions (can be overridden)
: "${CODE_SERVER_VERSION:=4.91.1}"

# Proxy for downloads
: "${GHPROXY:=https://ghproxy.com/}"

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
