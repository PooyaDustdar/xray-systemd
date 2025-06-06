#!/usr/bin/env bash
set -euo pipefail
# Script for installing Xray with systemd integration
# Author: PooyaDustdar
# License: MIT

# Constants
XRAY_VERSION="v24.10.31"
XRAY_INSTALL_DIR="/usr/bin/xray"
XRAY_CONFIG_DIR="/etc/xray"
XRAY_USER="xray"
XRAY_GROUP="xray"
SYSTEMD_DIR="/etc/systemd/system"
LOG_FILE="/var/log/xray_install.log"

# Function for logging
log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to check if script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root"
        exit 1
    fi
}

# Function to check required commands
check_requirements() {
    local requirements=("wget" "unzip" "systemctl")
    for cmd in "${requirements[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log "Error: Required command '$cmd' not found"
            exit 1
        fi
    done
}

# Function for cleanup on error
cleanup() {
    log "Error occurred. Cleaning up..."
    rm -f "Xray-linux-64.zip"
    exit 1
}

# Main installation function
install_xray() {
    # Set trap for cleanup
    trap cleanup ERR

    log "Starting Xray installation..."
    
    # Download Xray
    log "Downloading Xray version ${XRAY_VERSION}..."
    if ! wget "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip"; then
        log "Failed to download Xray"
        exit 1
    fi

    # Create directories and extract files
    log "Creating directories and extracting files..."
    mkdir -p "$XRAY_INSTALL_DIR"
    mkdir -p "$XRAY_CONFIG_DIR"
    
    if ! unzip -o Xray-linux-64.zip -d "$XRAY_INSTALL_DIR"; then
        log "Failed to extract Xray files"
        cleanup
    fi

    # Create user and group
    log "Setting up user and group..."
    id -u "$XRAY_USER" &>/dev/null || useradd -r -s /bin/false "$XRAY_USER"
    getent group "$XRAY_GROUP" || groupadd -r "$XRAY_GROUP"

    # Set permissions
    log "Setting up permissions..."
    touch "$XRAY_CONFIG_DIR/config.json"
    chown -R "$XRAY_USER:$XRAY_GROUP" "$XRAY_CONFIG_DIR"
    chmod 755 "$XRAY_INSTALL_DIR"
    chmod 644 "$XRAY_CONFIG_DIR/config.json"

    # Setup systemd service
    log "Setting up systemd service..."
    cp xray.service "$SYSTEMD_DIR/"
    chmod 644 "$SYSTEMD_DIR/xray.service"

    # Reload and enable service
    log "Enabling and starting Xray service..."
    systemctl daemon-reload
    systemctl enable xray
    systemctl start xray

    # Verify service status
    if systemctl is-active xray >/dev/null 2>&1; then
        log "Xray service is running successfully"
    else
        log "Error: Xray service failed to start"
        exit 1
    fi

    # Cleanup
    log "Cleaning up installation files..."
    rm -f Xray-linux-64.zip

    log "Installation completed successfully"
}

# Main execution
main() {
    check_root
    check_requirements
    install_xray
}

main
