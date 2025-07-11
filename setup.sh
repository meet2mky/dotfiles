#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail

# --- Helper Functions ---
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

present_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    fi
    return 1
}
git_installer() {
    log_info ""
    log_info ""
    log_info "Git Installation and configuration..."
    if present_command "git"; then
        log_info "Git is already installed, Installation and configuration skipped..."
        return 0
    fi
    log_info "Git is not detected on system. Installation and configuration started..."
    sudo apt update && sudo apt install git -y
    log_info "Checking git version..."
    git --version
    log_info ""
    log_info ""
    log_info "Installing Github CLI for login..."
    if present_command "gh"; then
        log_info "Github CLI is already installed. Installation skipped..."
    else
        log_info "Github CLI is not detected on system. Installation started..."
        sudo apt install gh -y
        log_info "Checking Github CLI version..."
        gh --version
    fi
    log_info ""
    log_info ""
    log_info "Performing login to git using Github CLI..."
    log_info "Authenticate using browser..."
    yes | gh auth login --hostname github.com --protocol https --web
}

main(){
    git_installer
    ./dotfiles_installer.sh
}

main
