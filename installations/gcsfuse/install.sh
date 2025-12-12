#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../tools/all_in_one.sh"

# --- Configuration ---
REPO_URL="https://github.com/GoogleCloudPlatform/gcsfuse.git"
CLONE_DIR="gcsfuse_source"
INSTALL_DIR="/usr/local/bin"
GCSFUSE_BINARY_NAME="gcsfuse"

# --- Core Functions ---

# Function to check for necessary dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    check_command "git"
    check_command "go"
    check_command "sudo" # Needed for the install step
    log_info "Dependencies found."
}

# Function to clone the gcsfuse repository
clone_gcsfuse_repo() {
    log_info "Cloning gcsfuse repository from $REPO_URL into $CLONE_DIR..."
    if [ -d "$CLONE_DIR" ]; then
        log_info "Directory $CLONE_DIR already exists. Removing it first."
        rm -rf "$CLONE_DIR" || { log_error "Failed to remove existing directory $CLONE_DIR"; exit 1; }
    fi
    git clone "$REPO_URL" "$CLONE_DIR" || { log_error "Failed to clone repository"; exit 1; }
    log_info "Repository cloned successfully."
}

# Function to clean up the cloned source directory (NEW)
cleanup_source_directory() {
    log_info "Cleaning up source directory: $CLONE_DIR..."
    if [ -d "$CLONE_DIR" ]; then
        rm -rf "$CLONE_DIR" || { log_error "Failed to remove source directory $CLONE_DIR"; exit 1; }
        log_info "Source directory removed successfully."
    else
        log_info "Source directory $CLONE_DIR not found, skipping cleanup."
    fi
}

# Function to build and install gcsfuse
build_and_install_gcsfuse() {
    log_info "Navigating into $CLONE_DIR..."
    cd "$CLONE_DIR" || { log_error "Failed to change directory to $CLONE_DIR"; exit 1; }

    log_info "Building gcsfuse..."
    # Build the binary. The '-o' flag specifies the output name.
    go build -o "$GCSFUSE_BINARY_NAME" . || { log_error "Go build failed"; cd ..; exit 1; } # Go back if build fails
    log_info "Build successful: $GCSFUSE_BINARY_NAME"

    log_info "Installing $GCSFUSE_BINARY_NAME to $INSTALL_DIR..."
    # Use 'install' command which can set permissions and ownership
    # Requires sudo privileges
    sudo install -m 0755 "$GCSFUSE_BINARY_NAME" "$INSTALL_DIR/" || { log_error "Failed to install $GCSFUSE_BINARY_NAME to $INSTALL_DIR"; cd ..; exit 1; } # Go back if install fails

    log_info "$GCSFUSE_BINARY_NAME installed successfully to $INSTALL_DIR."

    log_info "Navigating back to the original directory..."
    cd .. || { log_error "Failed to change directory back"; exit 1; } # Should ideally not fail here
}

# --- Main Execution ---
main() {
    log_info "Starting gcsfuse installation from source..."
    check_dependencies
    clone_gcsfuse_repo
    build_and_install_gcsfuse
    cleanup_source_directory
    log_info "---------------------------------------------------------------------"
    log_info "gcsfuse installation process completed."
    log_info "Binary installed at: [$INSTALL_DIR/$GCSFUSE_BINARY_NAME]"
    log_info ""
    log_info "Confirming single [$GCSFUSE_BINARY_NAME] installation..."
    ensure_single_bin "$GCSFUSE_BINARY_NAME"
    log_info "Checking command: [$GCSFUSE_BINARY_NAME]..."
    check_command "$GCSFUSE_BINARY_NAME"
    log_info "Command: [$GCSFUSE_BINARY_NAME] is available for use ..."
    log_info ""
    log_info "---------------------------------------------------------------------"
}

# Run the main function
main