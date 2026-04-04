#!/data/data/com.termux/files/usr/bin/bash
# Mobile VS Code - Start VS Code Server

source "$(dirname "$0")/config.sh"

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
    if [ -n "$PROOT_PID" ]; then
        kill "$PROOT_PID" 2>/dev/null
    fi
}

trap cleanup EXIT

# Check if VS Code Server is already running
check_running() {
    if pgrep -f "code-server" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Kill existing VS Code Server processes
kill_existing() {
    log_info "Stopping existing VS Code Server..."
    pkill -f "code-server" 2>/dev/null || true
    sleep 2
}

# Wait for port to be available with timeout
wait_for_port() {
    local port=$1
    local timeout=${2:-30}
    local count=0

    log_info "Waiting for VS Code Server on port $port..."

    while [ $count -lt $timeout ]; do
        if nc -z localhost $port 2>/dev/null; then
            log_info "VS Code Server is ready!"
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done

    log_error "Timeout waiting for VS Code Server"
    return 1
}

# Main function
main() {
    # Check if environment is installed
    if [ ! -d "$VSCODE_DIR" ] || [ ! -d "$ROOTFS_DIR" ]; then
        log_error "VS Code Server not installed"
        log_info "Run install.sh first"
        exit 1
    fi

    # Check if already running
    if check_running; then
        log_warn "VS Code Server is already running"
        log_info "Visit http://localhost:8080"
        exit 0
    fi

    # Kill any existing processes
    kill_existing

    # Fix libraries if needed
    if [ -f "$SCRIPTS_DIR/fix-libs.sh" ]; then
        bash "$SCRIPTS_DIR/fix-libs.sh" || true
    fi

    log_info "Starting VS Code Server..."

    # Ensure directories exist
    mkdir -p "$WORKSPACE_DIR"
    mkdir -p "$VSCODE_DATA_DIR/extensions"
    mkdir -p "$VSCODE_DATA_DIR/user-data"

    # Prepare settings file path inside RootFS
    mkdir -p "$ROOTFS_DIR/root/.local/share/code-server/User"
    if [ -f "$CONFIG_DIR/vscode-settings.json" ]; then
        cp "$CONFIG_DIR/vscode-settings.json" "$ROOTFS_DIR/root/.local/share/code-server/User/settings.json"
    fi

    # Build proot command with bind mounts
    PROOT_CMD="proot-distro login ubuntu --shared-tmp"

    # Add bind mounts
    PROOT_CMD="$PROOT_CMD --bind /dev:/dev"
    PROOT_CMD="$PROOT_CMD --bind /proc:/proc"
    PROOT_CMD="$PROOT_CMD --bind /sys:/sys"
    PROOT_CMD="$PROOT_CMD --bind $WORKSPACE_DIR:/root/workspace"
    PROOT_CMD="$PROOT_CMD --bind $VSCODE_DATA_DIR:/root/.local/share/code-server"

    # Add code-server to path and run
    PROOT_CMD="$PROOT_CMD -- /bin/bash -c 'export PATH=\"$VSCODE_DIR/bin:\$PATH\" && code-server \\"
    PROOT_CMD="$PROOT_CMD --auth none"
    PROOT_CMD="$PROOT_CMD --bind-addr 0.0.0.0:8080"
    PROOT_CMD="$PROOT_CMD --extensions-dir /root/.local/share/code-server/extensions"
    PROOT_CMD="$PROOT_CMD --user-data-dir /root/.local/share/code-server/user-data"
    PROOT_CMD="$PROOT_CMD --disable-telemetry"
    PROOT_CMD="$PROOT_CMD /root/workspace'"

    # Start in background and capture PID
    eval "$PROOT_CMD" > "$LOGS_DIR/code-server.log" 2>&1 &
    PROOT_PID=$!

    log_info "VS Code Server starting with PID: $PROOT_PID"

    # Wait for port 8080
    if wait_for_port 8080 30; then
        log_info "VS Code Server is running at http://localhost:8080"
        log_info "Workspace: $WORKSPACE_DIR"

        # Run in foreground mode (wait for process)
        if [ "$1" = "--foreground" ] || [ "$1" = "-f" ]; then
            wait "$PROOT_PID"
        else
            # Background mode - just report and exit
            log_info "Running in background mode"
            log_info "Logs: $LOGS_DIR/code-server.log"
        fi
    else
        log_error "Failed to start VS Code Server"
        log_info "Check logs: $LOGS_DIR/code-server.log"
        exit 1
    fi
}

main "$@"
