#!/data/data/com.termux/files/usr/bin/bash
# Mobile VS Code - Stop VS Code Server

source "$(dirname "$0")/config.sh"

log_info "Mobile VS Code Stopper"
log_info "======================="

# Kill code-server
log_info "Stopping VS Code Server..."
pkill -f "code-server.*0.0.0.0:8080" 2>/dev/null && log_info "VS Code Server stopped" || log_warn "VS Code Server not running"

# Kill proot processes
log_info "Stopping Proot containers..."
pkill -f "proot.*$ROOTFS_DIR" 2>/dev/null && log_info "Proot stopped" || log_warn "Proot not running"

# Clean up PID file
if [ -f "$BASE_DIR/code-server.pid" ]; then
    rm -f "$BASE_DIR/code-server.pid"
fi

# Verify stopped
sleep 1
if pgrep -f "code-server.*0.0.0.0:8080" > /dev/null 2>&1; then
    log_warn "Some processes may still be running"
    log_info "Force killing..."
    pkill -9 -f "code-server" 2>/dev/null || true
    pkill -9 -f "proot" 2>/dev/null || true
fi

log_info "All services stopped"
