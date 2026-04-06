#!/system/bin/sh
# Mobile VS Code - Stop VS Code Server

SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/config.sh"

log_info "Mobile VS Code Stopper"
log_info "======================="

stop_process_tree() {
    local parent_pid="$1"
    if [ -n "$parent_pid" ] && /system/bin/toybox kill -0 "$parent_pid" 2>/dev/null; then
        log_info "Stopping process tree (PID: $parent_pid)..."
        # Kill the entire process group
        /system/bin/toybox kill -TERM -"$parent_pid" 2>/dev/null || true
        sleep 2
        # Force kill if still running
        if /system/bin/toybox kill -0 "$parent_pid" 2>/dev/null; then
            log_warn "Force killing..."
            /system/bin/toybox kill -9 -"$parent_pid" 2>/dev/null || true
            sleep 1
        fi
    fi
}

if [ -f "$PID_FILE" ]; then
    PID="$(cat "$PID_FILE")"
    stop_process_tree "$PID"
    rm -f "$PID_FILE"
fi

# Also find any proot processes that might be orphaned
PROOT_PIDS=$(ps -A 2>/dev/null | grep proot | grep -v grep | awk '{print $1}')
for proot_pid in $PROOT_PIDS; do
    log_info "Found orphaned proot (PID: $proot_pid), cleaning up..."
    stop_process_tree "$proot_pid"
done

# Clean up any stale node processes in app's namespace
NODE_PIDS=$(ps -A 2>/dev/null | grep "node.*code-server" | grep -v grep | awk '{print $1}')
for node_pid in $NODE_PIDS; do
    log_info "Stopping node (PID: $node_pid)..."
    /system/bin/toybox kill -9 "$node_pid" 2>/dev/null || true
done

log_info "All services stopped"
