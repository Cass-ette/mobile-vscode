#!/system/bin/sh
# Mobile VS Code - Stop VS Code Server

SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/config.sh"

log_info "Mobile VS Code Stopper"
log_info "======================="

if [ -f "$PID_FILE" ]; then
    PID="$(cat "$PID_FILE")"
    if /system/bin/toybox kill -0 "$PID" 2>/dev/null; then
        log_info "Stopping VS Code Server (PID: $PID)..."
        /system/bin/toybox kill "$PID" 2>/dev/null || true
        sleep 2
        if /system/bin/toybox kill -0 "$PID" 2>/dev/null; then
            log_warn "Process still running, force killing..."
            /system/bin/toybox kill -9 "$PID" 2>/dev/null || true
        fi
        log_info "VS Code Server stopped"
    else
        log_warn "Process not running (stale PID file)"
    fi
    rm -f "$PID_FILE"
fi

rm -f "$PID_FILE"
log_info "All services stopped"
