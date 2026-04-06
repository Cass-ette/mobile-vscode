#!/system/bin/sh
# Fix missing libraries in Ubuntu RootFS for app-private runtime

SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/config.sh"

log_info "Fixing library dependencies..."

# Check if running in correct directory
if [ ! -d "$ROOTFS_DIR" ]; then
    log_error "RootFS not found at $ROOTFS_DIR"
    exit 1
fi

# Create library directory
mkdir -p "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu"

# Check for busybox
if [ ! -x "$RUNTIME_BIN_DIR/busybox" ]; then
    log_warn "busybox not available, library fix may fail"
fi

# Fix libreadline.so.8
if [ ! -f "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/libreadline.so.8" ]; then
    log_info "Downloading libreadline8..."
    cd "$BASE_DIR"

    LIB_URL="http://ports.ubuntu.com/ubuntu-ports/pool/main/r/readline/libreadline8_8.1-1ubuntu1_arm64.deb"
    if "$RUNTIME_BIN_DIR/busybox" wget -O libreadline8.deb "$LIB_URL" 2>/dev/null; then
        # Extract using busybox ar and tar
        mkdir -p ./libreadline
        cd ./libreadline
        "$RUNTIME_BIN_DIR/busybox" ar -x "$BASE_DIR/libreadline8.deb" 2>/dev/null || true
        if [ -f data.tar.xz ]; then
            "$RUNTIME_BIN_DIR/busybox" tar -xf data.tar.xz 2>/dev/null || true
            cp ./lib/aarch64-linux-gnu/libreadline.so.8* "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/" 2>/dev/null || \
            cp ./usr/lib/aarch64-linux-gnu/libreadline.so.8* "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/" 2>/dev/null || true
        fi
        cd "$BASE_DIR"
        rm -rf ./libreadline ./libreadline8.deb
        log_info "libreadline.so.8 installed"
    else
        log_warn "Failed to download libreadline8"
    fi
fi

# Fix libz.so.1
if [ ! -f "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/libz.so.1" ]; then
    log_info "Downloading zlib1g..."
    cd "$BASE_DIR"

    LIB_URL="http://ports.ubuntu.com/ubuntu-ports/pool/main/z/zlib/zlib1g_1.2.11.dfsg-2ubuntu9_arm64.deb"
    if "$RUNTIME_BIN_DIR/busybox" wget -O zlib1g.deb "$LIB_URL" 2>/dev/null; then
        mkdir -p ./zlib1g
        cd ./zlib1g
        "$RUNTIME_BIN_DIR/busybox" ar -x "$BASE_DIR/zlib1g.deb" 2>/dev/null || true
        if [ -f data.tar.xz ]; then
            "$RUNTIME_BIN_DIR/busybox" tar -xf data.tar.xz 2>/dev/null || true
            cp ./lib/aarch64-linux-gnu/libz.so.1* "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/" 2>/dev/null || \
            cp ./usr/lib/aarch64-linux-gnu/libz.so.1* "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/" 2>/dev/null || true
        fi
        cd "$BASE_DIR"
        rm -rf ./zlib1g zlib1g.deb
        log_info "libz.so.1 installed"
    else
        log_warn "Failed to download zlib1g"
    fi
fi

# Update library cache inside rootfs
mkdir -p "$ROOTFS_DIR/etc"
echo "/usr/lib/aarch64-linux-gnu" > "$ROOTFS_DIR/etc/ld.so.conf.d/aarch64-linux-gnu.conf" 2>/dev/null || true

log_info "Library fix complete!"
