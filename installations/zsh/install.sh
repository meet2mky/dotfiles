#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail

# --- Helper Functions ---
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1"
}

# --- Main Script ---
log_info ""
log_info ""
log_info "Starting ZSH installation script..."

# Check for sudo privileges upfront
# Note: This script assumes Linux with apt, so sudo is likely needed.
if ! sudo -v; then
    log_error "❌ Cannot obtain sudo privileges. Please run using sudo or ensure sudo access."
    exit 1
fi

# Check for apt package manager and install zsh
if command -v apt &>/dev/null; then
    log_info "Using apt package manager (Debian/Ubuntu based)."
    log_info "Updating package lists..."
    sudo apt update >> /dev/null 2>&1 || true
    log_info "Installing ZSH..."
    sudo apt install -y zsh
    log_info "ZSH installation done."
else
    # This script currently only supports apt.
    log_error "❌ apt package manager not found. This script only supports apt-based systems."
    log_error "❌ Unable to install zsh."
    exit 1
fi

# Verify if zsh command is available after installation attempt
log_info "Verifying ZSH installation..."
if ! command -v "zsh" &>/dev/null; then
    log_error "❌ Command 'zsh' installation failed. Exiting..."
    exit 1
fi
log_info "✅ Verification successful: 'zsh' installation completed."
log_info "To make Zsh your default shell, you may need to run: chsh -s $(which zsh)"
log_info "Zsh installation script finished."
log_info ""
log_info ""
exit 0
