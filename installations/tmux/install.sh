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

# Installs tmux by detecting the package manager (apt, dnf, yum, pacman).
install_tmux() {
    # Check if tmux is already installed
    if command -v tmux &>/dev/null; then
        log_info "✅ tmux is already installed. Installation Skipped."
        return 0
    fi

    log_info "Attempting to install tmux..."

    # Detect package manager and install tmux
    if command -v apt-get &>/dev/null; then
        # For Debian, Ubuntu, etc.
        sudo apt-get update && sudo apt-get install -y tmux
    elif command -v dnf &>/dev/null; then
        # For Fedora, RHEL 8+, etc.
        sudo dnf install -y tmux
    elif command -v yum &>/dev/null; then
        # For CentOS 7, older RHEL, etc.
        sudo yum install -y tmux
    elif command -v pacman &>/dev/null; then
        # For Arch Linux, Manjaro, etc.
        sudo pacman -Syu --noconfirm tmux
    else
        log_error "❌ Could not find a supported package manager."
        log_info "Please install tmux manually."
        return 1
    fi

    # Verify installation
    if command -v tmux &>/dev/null; then
        log_info "✅ tmux has been installed successfully."
    else
        log_error "❌ tmux installation failed."
        return 1
    fi
}

log_info ""
log_info ""
if ! install_tmux; then 
    exit 1
fi

# --- Configuration ---
FILE_PATH="$HOME/.tmux.conf"
rm -rf "$FILE_PATH"
touch "$FILE_PATH"
START_MARKER="# --- BEGIN TMUX ---"
END_MARKER="# --- END TMUX ---"
TEXT="
# Set zsh as the default shell
set-option -g default-shell '/usr/bin/zsh'
# Enable mouse mode
set-option -g mouse on
# Update PATH environment variable
set-option -g update-environment 'PATH DISPLAY SSH_AUTH_SOCK'
# Show an indicator on the right when prefix is active
set -g status-right '#[fg=white,bg=default]#{?client_prefix,#[reverse] PREFIX_PRESSED #[noreverse],} %H:%M %d-%b-%y'
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'nhdaly/tmux-better-mouse-mode'
# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
"

if ! ./installations/tools/block_manager.sh "$FILE_PATH" "$START_MARKER" "$END_MARKER" "REMOVE"; then 
    log_error "❌ Unable to remove existing tmux marker. Exiting..."
    exit 1
else
    log_info "✅ tmux marker successfully cleaned up."
fi

if ! ./installations/tools/block_manager.sh "$FILE_PATH" "$START_MARKER" "$END_MARKER" "INSERT" "$TEXT"; then 
    log_error "❌ Unable to add tmux marker. Exiting..."
else
    log_info "✅ tmux marker successfully added."
fi
