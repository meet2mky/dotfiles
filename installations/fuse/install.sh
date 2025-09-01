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


check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Command '$1' not found. Please install it first."
        exit 1
    fi
}

check_fuse_version_linux() {
    log_debug "Attempting to check installed FUSE version..."
    local fuse_version=""
  
    # Try FUSE 2 command if FUSE 3 not found or version flag failed
    if command -v fusermount >/dev/null 2>&1; then
         # Try --version first, then -V
        if fuse_version=$(fusermount --version 2>&1); then
             log_debug "Detected FUSE 2 version: ${fuse_version}"
             return 0
        elif fuse_version=$(fusermount -V 2>&1); then
            log_debug "Detected FUSE 2 version: ${fuse_version}"
            return 0
        fi
    fi
  
    # Try FUSE 3 command first
    if command -v fusermount3 >/dev/null 2>&1; then
        # Try --version first, then -V as flags vary
        if fuse_version=$(fusermount3 --version 2>&1); then
            log_debug "Detected FUSE 3 version: ${fuse_version}"
            return 0
        elif fuse_version=$(fusermount3 -V 2>&1); then
             log_debug "Detected FUSE 3 version: ${fuse_version}"
             return 0
        fi
    fi

    # If commands exist but version flags failed (unlikely for both)
    if command -v fusermount3 >/dev/null 2>&1 || command -v fusermount >/dev/null 2>&1; then
       log_error "Could not determine FUSE version using standard flags (-V/--version)."
       log_error "However, a fusermount executable was found."
    else
       log_error "Neither fusermount3 nor fusermount command found after installation attempt."
    fi
    return 1 # Indicate version check wasn't fully successful
}


# --- Main Script ---
log_debug "Starting FUSE installation/check script..."

# Check the operating system
if [[ "$(uname -s)" == "Linux" ]]; then
  log_debug "Detected Linux operating system."

  # Optional: Check sudo upfront
  if ! sudo -v; then
      log_error "Cannot obtain sudo privileges. Please run as root or ensure sudo access."
      exit 1
  fi

  # Check for common package managers and install
  package_installed=false
  if command -v apt >/dev/null 2>&1; then
    log_debug "Using apt package manager (Debian/Ubuntu based)."
    log_debug "Updating package lists..."
    sudo apt update >> /dev/null 2>&1 || true
    log_debug "Installing fuse3..."
    sudo apt install -y fuse3 >> /dev/null 2>&1
    log_info "FUSE installation command finished via apt."
    package_installed=true
  elif command -v yum >/dev/null 2>&1; then
    log_debug "Using yum package manager (CentOS/RHEL based)."
    log_debug "Installing fuse and fuse-libs..."
    sudo yum install -y fuse fuse-libs
    log_info "FUSE installation command finished via yum."
    package_installed=true
  elif command -v dnf >/dev/null 2>&1; then
    log_debug "Using dnf package manager (Fedora/CentOS 8+ based)."
    log_debug "Installing fuse and fuse-libs..."
    sudo dnf install -y fuse fuse-libs
    log_info "FUSE installation command finished via dnf."
    package_installed=true
  elif command -v zypper >/dev/null 2>&1; then
    log_debug "Using zypper package manager (openSUSE based)."
    log_debug "Installing fuse..."
    sudo zypper --non-interactive install -y fuse # Added --non-interactive
    log_info "FUSE installation command finished via zypper."
    package_installed=true
  elif command -v pacman >/dev/null 2>&1; then
    log_debug "Using pacman package manager (Arch Linux based)."
    log_debug "Installing fuse..."
    sudo pacman -S --noconfirm --needed fuse # Added --noconfirm
    log_info "FUSE installation command finished via pacman."
    package_installed=true
  else
    log_error "Could not detect a supported package manager (apt, yum, dnf, zypper, pacman)."
    log_error "Please install FUSE manually using your distribution's instructions."
    exit 1 # Exit with error as we couldn't install
  fi

  # Check version after successful package installation attempt
  if [[ "$package_installed" = true ]]; then
      check_fuse_version_linux
  fi

elif [[ "$(uname -s)" == "Darwin" ]]; then
  log_debug "Detected macOS operating system."
  log_debug "Checking if macFUSE (osxfuse) is already installed..."

  macfuse_installed=false
  macfuse_version="N/A"
  # Check using pkgutil (standard macOS package receipts)
  if pkgutil --pkg-info io.macfuse.pkg.Core >/dev/null 2>&1; then
      macfuse_version=$(pkgutil --pkg-info io.macfuse.pkg.Core | grep '^version:' | awk '{print $2}')
      log_debug "Found macFUSE version ${macfuse_version} installed (via pkgutil)."
      macfuse_installed=true
  elif pkgutil --pkg-info com.github.osxfuse.pkg.Core >/dev/null 2>&1; then # Check older ID if needed
       macfuse_version=$(pkgutil --pkg-info com.github.osxfuse.pkg.Core | grep '^version:' | awk '{print $2}')
       log_debug "Found osxfuse (older macFUSE) version ${macfuse_version} installed (via pkgutil)."
       macfuse_installed=true
  fi

  # Optionally suggest brew check if brew is installed
  if command -v brew >/dev/null 2>&1; then
      log_debug "Homebrew detected. You can also check with: brew info --cask macfuse"
  fi

  # If not found, provide installation instructions
  if [[ "$macfuse_installed" = false ]]; then
      log_debug "macFUSE does not appear to be installed."
      log_debug "On macOS, FUSE is typically provided by third-party packages like FUSE for macOS (macfuse)."
      log_debug "This script will not install it automatically. Please use Homebrew or manual download:"
      log_debug "  Using Homebrew: brew install --cask macfuse"
      log_debug "  Manual Download: https://osxfuse.github.io/"
      # Optional: Exit non-zero as no action was performed by this script
      # exit 1
  fi

else
  log_error "Unsupported operating system: $(uname -s)"
  exit 1
fi
FUSE_BINARY_NAME="fusermount"
log_debug "---------------------------------------------------------------------"
log_debug "FUSE installation/check script finished."
log_debug ""
log_debug "Checking command: [$FUSE_BINARY_NAME]..."
check_command "$FUSE_BINARY_NAME"
log_info "Command: [$FUSE_BINARY_NAME] is available for use ..."
log_debug ""
log_debug "---------------------------------------------------------------------"
exit 0