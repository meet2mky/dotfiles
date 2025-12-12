#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../tools/all_in_one.sh"

# Installs tmux by detecting the package manager (apt, dnf, yum, pacman).
install_tmux() {
    # Check if tmux is already installed
    if command -v tmux &>/dev/null; then
        log_debug "tmux is already installed. Installation Skipped..."
        return 0
    fi

    log_debug "Attempting to install tmux..."

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
        log_error "Could not find a supported package manager."
        log_debug "Please install tmux manually."
        return 1
    fi

    # Verify installation
    if command -v tmux &>/dev/null; then
        log_info "tmux has been installed successfully."
    else
        log_error "tmux installation failed."
        return 1
    fi
}

log_debug ""
log_debug ""
if ! install_tmux; then 
    exit 1
fi

# --- Create Symlink for tmux configuration ---
create_symlink "$HOME/dotfiles/installations/tmux/tmux.conf" "$HOME/.tmux.conf"