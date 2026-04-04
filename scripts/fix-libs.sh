#!/data/data/com.termux/files/usr/bin/bash
# Fix missing libraries in Ubuntu RootFS

source "$(dirname "$0")/config.sh"

log_info "Fixing library dependencies..."

# Check if running in correct directory
if [ ! -d "$ROOTFS_DIR" ]; then
    log_error "RootFS not found at $ROOTFS_DIR"
    log_info "Run install.sh first"
    exit 1
fi

# Create library directory
mkdir -p "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu"

# Fix libreadline.so.8
if [ ! -f "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/libreadline.so.8" ]; then
    log_info "Downloading libreadline8..."
    cd /tmp
    curl -L -o libreadline8.deb "${GHPROXY}http://ports.ubuntu.com/ubuntu-ports/pool/main/r/readline/libreadline8_8.1-1ubuntu1_arm64.deb" 2>/dev/null || \
    curl -L -o libreadline8.deb "http://ports.ubuntu.com/ubuntu-ports/pool/main/r/readline/libreadline8_8.1-1ubuntu1_arm64.deb"

    dpkg -x libreadline8.deb ./libreadline
    cp ./libreadline/lib/aarch64-linux-gnu/libreadline.so.8* "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/" 2>/dev/null || \
    cp ./libreadline/usr/lib/aarch64-linux-gnu/libreadline.so.8* "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/"
    rm -rf libreadline libreadline8.deb
    log_info "libreadline.so.8 installed"
fi

# Fix libz.so.1
if [ ! -f "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/libz.so.1" ]; then
    log_info "Downloading zlib1g..."
    cd /tmp
    curl -L -o zlib1g.deb "${GHPROXY}http://ports.ubuntu.com/ubuntu-ports/pool/main/z/zlib/zlib1g_1.2.11.dfsg-2ubuntu9_arm64.deb" 2>/dev/null || \
    curl -L -o zlib1g.deb "http://ports.ubuntu.com/ubuntu-ports/pool/main/z/zlib/zlib1g_1.2.11.dfsg-2ubuntu9_arm64.deb"

    dpkg -x zlib1g.deb ./zlib1g
    cp ./zlib1g/lib/aarch64-linux-gnu/libz.so.1* "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/" 2>/dev/null || \
    cp ./zlib1g/usr/lib/aarch64-linux-gnu/libz.so.1* "$ROOTFS_DIR/usr/lib/aarch64-linux-gnu/"
    rm -rf zlib1g zlib1g.deb
    log_info "libz.so.1 installed"
fi

# Update library cache inside chroot
log_info "Updating library cache..."
mkdir -p "$ROOTFS_DIR/etc"
echo "/usr/lib/aarch64-linux-gnu" > "$ROOTFS_DIR/etc/ld.so.conf.d/aarch64-linux-gnu.conf"

# Create ld.so.cache
export LD_LIBRARY_PATH="$ROOTFS_DIR/usr/lib/aarch64-linux-gnu:$ROOTFS_DIR/lib/aarch64-linux-gnu"

log_info "Library fix complete!"
