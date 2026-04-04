#!/data/data/com.termux/files/usr/bin/bash
# Mobile VS Code - One-click installer
# This script sets up the complete VS Code development environment

set -e

# Source configuration
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/config.sh"

# Parse arguments
SKIP_CLEAN=false
for arg in "$@"; do
    case $arg in
        --skip-clean)
            SKIP_CLEAN=true
            shift
            ;;
        --help)
            echo "Mobile VS Code Installer"
            echo ""
            echo "Usage: install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-clean    Skip cleaning old environment"
            echo "  --help          Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  VSCODE_VERSION  Set VS Code Server version (default: 4.90.3)"
            exit 0
            ;;
    esac
done

# Display version info
echo "========================================"
echo "  Mobile VS Code Installer"
echo "========================================"
echo "Version: $VSCODE_VERSION"
echo "Install path: $BASE_DIR"
echo ""

# Check dependencies
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Missing dependency: $1"
        return 1
    fi
    return 0
}

log_info "Checking dependencies..."
MISSING_DEPS=()

for dep in curl tar proot; do
    if ! check_dependency "$dep"; then
        MISSING_DEPS+=("$dep")
    fi
done

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    log_error "Please install missing dependencies:"
    for dep in "${MISSING_DEPS[@]}"; do
        echo "  - $dep"
    done
    log_info "Run: pkg install ${MISSING_DEPS[*]}"
    exit 1
fi

log_info "All dependencies satisfied"

# Clean old environment
if [ "$SKIP_CLEAN" = false ] && [ -d "$BASE_DIR" ]; then
    log_warn "Found existing installation at $BASE_DIR"
    log_info "Cleaning old environment..."

    # Kill any running processes
    pkill -f "code-server" 2>/dev/null || true
    pkill -f "proot" 2>/dev/null || true
    sleep 2

    # Backup workspace if exists
    if [ -d "$WORKSPACE_DIR" ]; then
        BACKUP_DIR="$HOME/mobile-dev-env-backup-$(date +%Y%m%d-%H%M%S)"
        log_info "Backing up workspace to $BACKUP_DIR..."
        mkdir -p "$BACKUP_DIR"
        cp -r "$WORKSPACE_DIR" "$BACKUP_DIR/" 2>/dev/null || true
    fi

    # Remove old installation
    rm -rf "$BASE_DIR"
    log_info "Old environment cleaned"
fi

# Create directory structure
log_info "Creating directory structure..."
mkdir -p "$ROOTFS_DIR"
mkdir -p "$VSCODE_DIR"
mkdir -p "$VSCODE_DATA_DIR/extensions"
mkdir -p "$WORKSPACE_DIR/projects"
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOGS_DIR"
mkdir -p "$SCRIPTS_DIR"

# Download and extract Ubuntu RootFS
if [ ! -f "$ROOTFS_DIR/bin/bash" ]; then
    log_info "Downloading Ubuntu RootFS (this may take a while)..."
    cd /tmp

    # Try primary URL first, fallback to direct URL
    if ! curl --progress-bar -L -o ubuntu-rootfs.tar.xz "$ROOTFS_URL" 2>&1; then
        log_warn "Primary download failed, trying fallback URL..."
        ROOTFS_URL_FALLBACK="https://github.com/termux/proot-distro/releases/download/v4.6.0/ubuntu-arm64-pd-v4.6.0.tar.xz"
        curl --progress-bar -L -o ubuntu-rootfs.tar.xz "$ROOTFS_URL_FALLBACK" 2>&1
    fi

    log_info "Extracting RootFS..."
    tar -xf ubuntu-rootfs.tar.xz -C "$ROOTFS_DIR" --strip-components=1 2>&1 || {
        log_error "Failed to extract RootFS"
        rm -f ubuntu-rootfs.tar.xz
        exit 1
    }
    rm -f ubuntu-rootfs.tar.xz
    log_info "Ubuntu RootFS installed"
else
    log_info "Ubuntu RootFS already exists, skipping download"
fi

# Run fix-libs.sh
log_info "Running library fix script..."
if [ -f "$SCRIPT_DIR/fix-libs.sh" ]; then
    bash "$SCRIPT_DIR/fix-libs.sh"
else
    log_warn "fix-libs.sh not found, library issues may occur"
fi

# Download and extract VS Code Server
VSCODE_BINARY="$VSCODE_DIR/bin/code-server"
if [ ! -f "$VSCODE_BINARY" ]; then
    log_info "Downloading VS Code Server v${VSCODE_VERSION}..."
    cd /tmp

    VSCODE_TARBALL="code-server-${VSCODE_VERSION}-linux-arm64.tar.gz"

    # Try primary URL first, fallback to direct URL
    if ! curl --progress-bar -L -o "$VSCODE_TARBALL" "$VSCODE_URL" 2>&1; then
        log_warn "Primary download failed, trying fallback URL..."
        VSCODE_URL_FALLBACK="https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/code-server-${VSCODE_VERSION}-linux-arm64.tar.gz"
        curl --progress-bar -L -o "$VSCODE_TARBALL" "$VSCODE_URL_FALLBACK" 2>&1
    fi

    log_info "Extracting VS Code Server..."
    tar -xzf "$VSCODE_TARBALL" -C "$VSCODE_DIR" --strip-components=1 2>&1 || {
        log_error "Failed to extract VS Code Server"
        rm -f "$VSCODE_TARBALL"
        exit 1
    }
    rm -f "$VSCODE_TARBALL"
    log_info "VS Code Server installed"
else
    log_info "VS Code Server already exists, skipping download"
fi

# Copy scripts to persistent location
log_info "Copying scripts to persistent location..."
cp "$SCRIPT_DIR/config.sh" "$SCRIPTS_DIR/"
cp "$SCRIPT_DIR/fix-libs.sh" "$SCRIPTS_DIR/"

# Create start.sh if not exists
if [ ! -f "$SCRIPTS_DIR/start.sh" ]; then
    log_warn "start.sh not found in source directory"
fi

# Create stop.sh if not exists
if [ ! -f "$SCRIPTS_DIR/stop.sh" ]; then
    log_warn "stop.sh not found in source directory"
fi

# Create initial VS Code settings
log_info "Creating initial VS Code settings..."
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

# Create bashrc for container
log_info "Creating bashrc configuration..."
cat > "$CONFIG_DIR/bashrc" << 'EOF'
# Mobile VS Code - Container Bash Configuration

# Basic environment
export HOME=/root
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export TERM=xterm-256color

# Better history
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'

# Colors for ls
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'

# PS1 with colors
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Welcome message
echo "Welcome to Mobile VS Code!"
echo "Workspace: /root/workspace"
echo ""
EOF

# Set permissions
chmod +x "$SCRIPTS_DIR/"*.sh 2>/dev/null || true

# Installation complete
log_info "========================================"
log_info "Installation Complete!"
log_info "========================================"
echo ""
echo "Installation path: $BASE_DIR"
echo "VS Code Version: $VSCODE_VERSION"
echo ""
echo "Next steps:"
echo "  1. Run: ~/mobile-dev-env/scripts/start.sh"
echo "  2. Open your browser to http://localhost:8080"
echo ""
echo "Workspace location: $WORKSPACE_DIR"
echo ""

if [ -n "$BACKUP_DIR" ]; then
    log_warn "Your previous workspace was backed up to: $BACKUP_DIR"
fi

exit 0
