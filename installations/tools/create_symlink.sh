#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail

# --- Helper Functions ---
# --- Helper Functions ---
log_info() {
    echo "✅[INF] $1"
}

log_debug() {
    echo "🔍[DBG] $1"
}

log_error() {
    echo "❌[ERR] $1"
}

# Check for arguments
if [ "$#" -ne 2 ]; then # Check if exactly two arguments are provided
    log_error "argument missing or incorrect number of arguments."
    log_debug "Usage: $0 actual_link  symbolic_link"
    exit 1
fi

ACTUAL_LINK=$1
SYMLINK=$2

log_debug ""
log_debug ""
log_debug "---------------------------------------------------------------------"
log_debug "Creating symlink from [$SYMLINK] --> [$ACTUAL_LINK]...."
bash "$HOME/dotfiles/installations/tools/remove_existing_symlink.sh" "$SYMLINK"
sudo ln -s "$ACTUAL_LINK" "$SYMLINK"
log_info "Symlink [$SYMLINK] created successfully..."
log_debug "---------------------------------------------------------------------"
log_debug ""
log_debug ""