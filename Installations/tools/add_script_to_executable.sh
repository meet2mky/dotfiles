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

# Check for arguments
if [ "$#" -ne 2 ]; then # Check if exactly two arguments are provided
    log_error "argument missing or incorrect number of arguments."
    log_info "Usage: $0 script_path command_name"
    exit 1
fi

DIR_TO_INSTALL="/usr/local/bin"
COMMAND_NAME="$2"
SCRIPT_PATH="$1"
log_info ""
log_info ""
log_info "---------------------------------------------------------------------"
log_info "Adding script [$SCRIPT_PATH] to [$DIR_TO_INSTALL] as an executable command [$COMMAND_NAME]..."
bash "$HOME/dotfiles/Installations/tools/create_symlink.sh" $SCRIPT_PATH "$DIR_TO_INSTALL/$COMMAND_NAME"
sudo chmod +x "$SCRIPT_PATH"
check_command "$COMMAND_NAME"
log_info "Command [$COMMAND_NAME] is available to use"
log_info "---------------------------------------------------------------------"
log_info ""
log_info ""