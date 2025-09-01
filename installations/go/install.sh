#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail

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

# --- Configuration ---
# Standard Go installation directory
GO_ROOT_INSTALL_DIR="/usr/local/go"
# Default location for Go projects/packages
GOPATH_DEFAULT="$HOME/go"
# Temporary download path
DOWNLOAD_PATH="/tmp/go_installer_download.tar.gz" # Use a more specific tmp name

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Command '$1' not found. Please install it first."
        exit 1
    fi
}

print_usage() {
  log_debug "Usage: $0 <go_version>"
  log_debug "Example: $0 1.24.0"
  log_debug "Find versions at: https://go.dev/dl/"
}

cleanup_download() {
    if [ -f "$DOWNLOAD_PATH" ]; then
        log_debug "Cleaning up downloaded file: ${DOWNLOAD_PATH}"
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
log_debug "Target Go Version: ${GO_VERSION}"

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

log_debug "Detected OS: ${OS}"
log_debug "Detected Arch: ${ARCH}"

# 3. Construct Filename and Download URL
FILENAME="go${GO_VERSION}.${OS}-${ARCH}.tar.gz"
DOWNLOAD_URL="https://dl.google.com/go/${FILENAME}"

# 4. Download the Go archive
log_debug "Downloading Go version ${GO_VERSION} for ${OS}-${ARCH}..."
log_debug "URL: ${DOWNLOAD_URL}"
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
  log_debug "Removing existing Go installation at ${GO_ROOT_INSTALL_DIR}..."
  if sudo rm -rf "$GO_ROOT_INSTALL_DIR"; then
     log_debug "Previous installation removed."
  else
     log_error "Failed to remove existing Go installation. Check sudo permissions for ${GO_ROOT_INSTALL_DIR}."
     # cleanup_download runs automatically via trap EXIT
     exit 1
  fi
fi


# 6. Extract the new Go archive to /usr/local (creates /usr/local/go) (requires sudo)
log_debug "Extracting ${FILENAME} to /usr/local ..."
# Use sudo to extract to /usr/local
if sudo tar -C /usr/local -xzf "$DOWNLOAD_PATH"; then
  log_info "Extraction complete to ${GO_ROOT_INSTALL_DIR}."
else
  log_error "Extraction failed. The downloaded file might be corrupted or incomplete (${DOWNLOAD_PATH})."
  # cleanup_download runs automatically via trap EXIT
  exit 1
fi

# 7. Provide Environment Variable Instructions (Using log_info for all lines)
GOROOT="${GO_ROOT_INSTALL_DIR}"
GO_BINARY_NAME="go"
log_debug "Go ${GO_VERSION} installation process finished."
log_debug ""
log_debug "------------------- Installation Summary -------------------"
log_debug "-> Go ${GO_VERSION} installed to: ${GOROOT}"
log_debug ""
log_debug "Confirming single [$GO_BINARY_NAME] installation..."
bash "$HOME/dotfiles/installations/tools/check_single_binary.sh" "$GO_BINARY_NAME"
log_debug "Checking command: [$GO_BINARY_NAME]..."
check_command "$GO_BINARY_NAME"
log_info "Command: [$GO_BINARY_NAME] is available for use ..."
START_MARKER="# --- BEGIN GO ENV ---"
END_MARKER="# --- END GO ENV ---"
FILE_PATH="$HOME/.zshrc"
TEXT=$(cat <<'EOF'

add-to-path "/usr/local/go/bin"
add-to-path "$(go env GOROOT)/bin"
add-to-path "$(go env GOPATH)/bin"
x
EOF
)
# Remove the placeholder 'x' character, leaving the newlines intact
TEXT=${TEXT%x}

bash "$HOME/dotfiles/installations/tools/block_manager.sh" "$FILE_PATH" "$START_MARKER" "$END_MARKER" "$TEXT"
log_debug ""
log_debug ""
log_debug "----------------------------------------------------------"
log_debug ""

# trap EXIT will handle final cleanup if needed
exit 0