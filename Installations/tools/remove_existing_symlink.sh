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

# --- Main Function Definition ---

# Function remove_existing_symlink
# Description:
#   Checks if a file exists at the given path.
#   If it's a symlink, attempts to remove it using sudo.
#   If it's a regular file or directory, logs an error and exits.
#   If removal fails, logs an error and exits.
#   Exits the *entire script* with status 1 on any error or conflict.
# Arguments:
#   $1: The full path to the symbolic link to check and potentially remove.
# Usage:
#   remove_existing_symlink "/path/to/symlink"
remove_existing_symlink() {
    # Use local variable for the path argument
    local symlink_path="$1"
    local symlink_dir

    # Basic input validation
    if [ -z "$symlink_path" ]; then
        log_error "Internal Script Error: remove_existing_symlink function called without an argument."
        exit 1 # Exit the entire script
    fi

    # Determine the directory containing the potential symlink for error messages
    symlink_dir=$(dirname "$symlink_path")

    # Check if the path exists and is specifically a symbolic link (-L)
    if [ -L "$symlink_path" ]; then
        log_info "Removing existing symlink at ${symlink_path}..."
        # Attempt removal using sudo, -f suppresses errors if it doesn't exist (though -L already checked)
        if sudo rm -f "$symlink_path"; then
            log_info "Previous symlink removed successfully."
        else
            # Removal command failed (likely permissions)
            log_error "Failed to remove existing symlink at ${symlink_path}. Check sudo permissions for the directory '${symlink_dir}'."
            # Assuming a 'trap cleanup_download EXIT' is set elsewhere as in the original context
            exit 1 # Exit the entire script
        fi
    # Check if the path exists (-e) but is NOT a symbolic link
    elif [ -e "$symlink_path" ]; then
        log_error "A file or directory (which is NOT a symlink) already exists at ${symlink_path}."
        log_error "Please remove this file/directory manually before running this script again."
        # Assuming a 'trap cleanup_download EXIT' is set elsewhere
        exit 1 # Exit the entire script
    else
        # Path does not exist, which is fine. Log for clarity.
        log_info "No conflicting file or symlink found at ${symlink_path}. OK to proceed."
    fi
    # If the function reaches here, it means either the symlink was removed successfully
    # or no conflicting file/link existed in the first place. The script can continue.
}

# --- main script ---

# 1. Check for symlink path argument
if [ "$#" -ne 1 ]; then # Check if exactly one argument is provided
    log_error "symlink path argument missing or incorrect number of arguments."
    log_info Usage: $0 /path/to/symlink
    exit 1
fi
SYMLINK_PATH="$1"

# Call the helper function
remove_existing_symlink "$SYMLINK_PATH"

# The script will only continue here if the function didn't exit due to an error or conflict
log_info "Symlink check/removal passed. Ready to create new symlink..."
