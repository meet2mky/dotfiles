#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipe failures should cause the script to exit.
set -o pipefail

# --- Configuration ---
# Standard Go installation directory
GO_ROOT_INSTALL_DIR="/usr/local/go"
# Directory for the symbolic link (usually in default PATH)
SYMLINK_DIR="/usr/local/bin"
# Default location for Go projects/packages
GOPATH_DEFAULT="$HOME/go"
# Temporary download path
DOWNLOAD_PATH="/tmp/go_installer_download.tar.gz" # Use a more specific tmp name

# --- Helper Functions ---
log_info() {
    # Log informational messages to standard output
    echo "[INFO] $1"
}

log_error() {
    # Log error messages to standard error
    echo "[ERROR] $1" >&2
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Command '$1' not found. Please install it first."
        exit 1
    fi
}

print_usage() {
  # Print usage instructions to standard error using log_error
  log_info "Usage: $0 <go_version>"
  log_info "Example: $0 1.24.0"
  log_info "Find versions at: https://go.dev/dl/"
}

cleanup_download() {
    if [ -f "$DOWNLOAD_PATH" ]; then
        log_info "Cleaning up downloaded file: ${DOWNLOAD_PATH}"
        rm -f "$DOWNLOAD_PATH"
    fi
}

# --- Script Logic ---

# Register cleanup function to run on script exit (including errors)
trap cleanup_download EXIT

# 1. Check for version argument
if [ "$#" -ne 1 ]; then # Check if exactly one argument is provided
    log_error "Go version argument missing or incorrect number of arguments."
    print_usage
    exit 1
fi
GO_VERSION="$1"
log_info "Target Go Version: ${GO_VERSION}"

# 2. Detect OS and Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64 | arm64) ARCH="arm64" ;;
  *)
    log_error "Unsupported architecture: $(uname -m)"
    exit 1
    ;;
esac

case "$OS" in
  linux | darwin) ;; # Supported OS
  *)
    log_error "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

log_info "Detected OS: ${OS}"
log_info "Detected Arch: ${ARCH}"

# 3. Construct Filename and Download URL
FILENAME="go${GO_VERSION}.${OS}-${ARCH}.tar.gz"
DOWNLOAD_URL="https://dl.google.com/go/${FILENAME}"

# 4. Download the Go archive
log_info "Downloading Go version ${GO_VERSION} for ${OS}-${ARCH}..."
log_info "URL: ${DOWNLOAD_URL}"
# Clear any previous download artifact first
cleanup_download

if curl --fail -Lfo "$DOWNLOAD_PATH" "$DOWNLOAD_URL"; then
  log_info "Download successful: ${DOWNLOAD_PATH}"
else
  log_error "Download failed. Check version number (${GO_VERSION}), OS/Arch (${OS}/${ARCH}), and internet connection."
  # cleanup_download runs automatically via trap EXIT
  exit 1
fi

# 5. Remove existing Go installation (requires sudo)
if [ -d "$GO_ROOT_INSTALL_DIR" ]; then
  log_info "Removing existing Go installation at ${GO_ROOT_INSTALL_DIR}..."
  if sudo rm -rf "$GO_ROOT_INSTALL_DIR"; then
     log_info "Previous installation removed."
  else
     log_error "Failed to remove existing Go installation. Check sudo permissions for ${GO_ROOT_INSTALL_DIR}."
     # cleanup_download runs automatically via trap EXIT
     exit 1
  fi
fi

# 6. Remove existing symlink if it exists (requires sudo)
SYMLINK_PATH="${SYMLINK_DIR}/go"
bash "$HOME/dotfiles/Installations/tools/remove_existing_symlink.sh" "$SYMLINK_PATH"


# 7. Extract the new Go archive to /usr/local (creates /usr/local/go) (requires sudo)
log_info "Extracting ${FILENAME} to /usr/local ..."
# Use sudo to extract to /usr/local
if sudo tar -C /usr/local -xzf "$DOWNLOAD_PATH"; then
  log_info "Extraction complete to ${GO_ROOT_INSTALL_DIR}."
else
  log_error "Extraction failed. The downloaded file might be corrupted or incomplete (${DOWNLOAD_PATH})."
  # cleanup_download runs automatically via trap EXIT
  exit 1
fi

# 8. Create the symbolic link (requires sudo)
GO_EXECUTABLE_PATH="${GO_ROOT_INSTALL_DIR}/bin/go"
log_info "Creating symbolic link from ${SYMLINK_PATH} to ${GO_EXECUTABLE_PATH}..."
if sudo ln -sf "$GO_EXECUTABLE_PATH" "$SYMLINK_PATH"; then
  log_info "Symbolic link created successfully."
else
  log_error "Failed to create symbolic link. Check sudo permissions for ${SYMLINK_DIR}."
  # cleanup_download runs automatically via trap EXIT
  exit 1
fi

# 9. Clean up (Download already handled by trap)
# cleanup_download runs automatically via trap EXIT

# 10. Provide Environment Variable Instructions (Using log_info for all lines)
GOROOT="${GO_ROOT_INSTALL_DIR}"
GOPATH="${GOPATH_DEFAULT}" # You can change this if needed
GO_BINARY_NAME="go"
log_info "Go ${GO_VERSION} installation process finished."
log_info ""
log_info "------------------- Installation Summary & Next Steps -------------------"
log_info "-> Go ${GO_VERSION} installed to: ${GOROOT}"
log_info "-> Go executable linked to: ${SYMLINK_PATH}"
log_info "   (Should be accessible if ${SYMLINK_DIR} is in your PATH)"
log_info ""
log_info "Confirming single [$GO_BINARY_NAME] installation..."
bash "$HOME/dotfiles/Installations/tools/check_single_binary.sh" "$GO_BINARY_NAME"
log_info "Checking command: [$GO_BINARY_NAME]..."
check_command "$GO_BINARY_NAME"
log_info "Command: [$GO_BINARY_NAME] is available for use ..."
log_info ""
log_info "IMPORTANT: Set GOROOT and GOPATH environment variables."
log_info "While the 'go' command might be found via the symlink, setting GOROOT"
log_info "explicitly ensures tools and IDEs can find the Go installation reliably."
log_info "GOPATH is essential for managing your Go workspace and packages."
log_info ""
log_info "Add the following lines to your shell profile (~/.bashrc, ~/.zshrc, ~/.profile, etc.):"
log_info ""
log_info "  export GOROOT=${GOROOT} # Root of the Go installation"
log_info "  export GOPATH=${GOPATH} # Your Go workspace"
log_info "  export PATH=\$PATH:\${GOPATH}/bin # Add GOPATH/bin for Go tools you install"
log_info ""
log_info "NOTE: We are NOT adding GOROOT/bin to PATH, as the symlink should handle finding 'go'."
log_info "      However, adding GOPATH/bin is still recommended for tools installed via 'go install'."
log_info ""
log_info "After adding these lines, either restart your terminal or run:"
log_info "  source ~/.your_profile_file  (e.g., source ~/.bashrc)"
log_info ""
log_info "-------------------------------------------------------------------------"
log_info ""

# trap EXIT will handle final cleanup if needed
exit 0