#!/bin/bash
# Script to install Zsh using apt.

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipe failures should cause the script to exit.
set -o pipefail

# --- Helper Functions ---
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Command '$1' not found. Please install it first."
        exit 1
    fi
}


# --- Main Script ---
log_info "Starting Zsh installation script..."

# Check for sudo privileges upfront
# Note: This script assumes Linux with apt, so sudo is likely needed.
if ! sudo -v; then
    log_error "Cannot obtain sudo privileges. Please run using sudo or ensure sudo access."
    exit 1
fi

# Check for apt package manager and install zsh
if command -v apt &> /dev/null; then
  log_info "Using apt package manager (Debian/Ubuntu based)."
  log_info "Updating package lists..."
  sudo apt update
  log_info "Installing zsh..."
  sudo apt install -y zsh
  log_info "'apt install' command completed."
else
  # This script currently only supports apt.
  log_error "apt package manager not found. This script only supports apt-based systems."
  log_error "Unable to install zsh."
  exit 1
fi

# Verify if zsh command is available after installation attempt
log_info ""
log_info "-------------------------------------------------------------------------"
log_info ""
log_info "Verifying zsh installation..."
check_command "zsh"
log_info "Verification successful: 'zsh' command is available."
# You may still need to log out and log back in or run `chsh` to make it your default shell.
log_info "To make Zsh your default shell, you may need to run: chsh -s $(which zsh)"
log_info "Zsh installation script finished."
log_info ""
log_info "-------------------------------------------------------------------------"
log_info ""
exit 0