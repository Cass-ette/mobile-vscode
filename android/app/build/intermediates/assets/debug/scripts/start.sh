#!/system/bin/sh
# Mobile VS Code - Start VS Code Server

SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/config.sh"

cleanup() {
    log_info "Cleaning up..."
    if [ -n "$PROOT_PID" ] && /system/bin/toybox kill -0 "$PROOT_PID" 2>/dev/null; then
        /system/bin/toybox kill "$PROOT_PID" 2>/dev/null || true
    fi
}

trap cleanup EXIT

if [ -f "$PID_FILE" ]; then
    OLD_PID="$(cat "$PID_FILE")"
    if /system/bin/toybox kill -0 "$OLD_PID" 2>/dev/null; then
        log_warn "VS Code Server already running (PID: $OLD_PID)"
        log_info "Visit http://localhost:$CODE_SERVER_PORT"
        exit 0
    fi
    rm -f "$PID_FILE"
fi

if [ ! -f "$INSTALL_MARKER" ] || [ ! -d "$CODE_SERVER_DIR/bin" ] || [ ! -d "$ROOTFS_DIR/bin" ]; then
    log_error "Environment not installed"
    exit 1
fi

log_info "Starting VS Code Server..."

mkdir -p "$WORKSPACE_DIR" "$VSCODE_DATA_DIR/extensions" "$VSCODE_DATA_DIR/user-data"
mkdir -p "$(dirname "$PID_FILE")"
mkdir -p "$ROOTFS_DIR/root/.local/share/code-server/User"

if [ -f "$CONFIG_DIR/vscode-settings.json" ]; then
    cp "$CONFIG_DIR/vscode-settings.json" "$ROOTFS_DIR/root/.local/share/code-server/User/settings.json"
fi

PROOT_BIN="$RUNTIME_BIN_DIR/proot"
if [ ! -x "$PROOT_BIN" ]; then
    log_error "proot not found at $PROOT_BIN"
    exit 1
fi

PROOT_CMD="$PROOT_BIN -r $ROOTFS_DIR -b /dev:/dev -b /proc:/proc -b /sys:/sys -b $WORKSPACE_DIR:/root/workspace -b $VSCODE_DATA_DIR:/root/.local/share/code-server -b $CODE_SERVER_DIR:/opt/code-server"

PROOT_CMD="$PROOT_CMD -- /bin/sh -c 'export PATH=\"/opt/code-server/bin:\$PATH\" && code-server --auth none --bind-addr 0.0.0.0:$CODE_SERVER_PORT --extensions-dir /root/.local/share/code-server/extensions --user-data-dir /root/.local/share/code-server/user-data --disable-telemetry /root/workspace'"

eval "$PROOT_CMD" > "$CODE_SERVER_LOG" 2>&1 &
PROOT_PID=$!
echo "$PROOT_PID" > "$PID_FILE"

log_info "VS Code Server starting with PID: $PROOT_PID"
log_info "Logs: $CODE_SERVER_LOG"

if [ "$1" = "--foreground" ] || [ "$1" = "-f" ]; then
    wait "$PROOT_PID"
    rm -f "$PID_FILE"
fi

exit 0
