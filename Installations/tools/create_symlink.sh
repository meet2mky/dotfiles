
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

# Check for arguments
if [ "$#" -ne 2 ]; then # Check if exactly two arguments are provided
    log_error "argument missing or incorrect number of arguments."
    log_info "Usage: $0 actual_link  symbolic_link"
    exit 1
fi

ACTUAL_LINK=$1
SYMLINK=$2

log_info ""
log_info ""
log_info "---------------------------------------------------------------------"
log_info "Creating symlink from [$SYMLINK] --> [$ACTUAL_LINK]...."
bash "$HOME/dotfiles/Installations/tools/remove_existing_symlink.sh" "$SYMLINK"
sudo ln -s "$ACTUAL_LINK" "$SYMLINK"
log_info "Symlink [$SYMLINK] created successfully..."
log_info "---------------------------------------------------------------------"
log_info ""
log_info ""