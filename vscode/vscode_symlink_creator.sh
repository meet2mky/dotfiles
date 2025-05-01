#!/bin/bash

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

ACTUAL_LINK="$HOME/dotfiles/vscode/.vscode"
SYMLINK=".vscode"

bash "$HOME/dotfiles/Installations/tools/create_symlink.sh" "$ACTUAL_LINK" $SYMLINK

