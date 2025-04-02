#!/bin/bash

# Script to uninstall FUSE (Filesystem in Userspace)

echo "Attempting to uninstall FUSE (Filesystem in Userspace)..."

# Check the operating system
if [[ "$(uname -s)" == "Linux" ]]; then
  echo "Detected Linux operating system."

  # Check for common package managers and attempt to uninstall
  if command -v apt >/dev/null 2>&1; then
    echo "Using apt package manager (Debian/Ubuntu based)."
    sudo apt remove --purge -y fuse
    if [ $? -eq 0 ]; then
      echo "FUSE and its libraries have been uninstalled successfully (apt)."
    else
      echo "Error uninstalling FUSE using apt. Please check the output above."
    fi
  elif command -v yum >/dev/null 2>&1; then
    echo "Using yum package manager (CentOS/RHEL based)."
    sudo yum remove -y fuse fuse-libs fuse-devel
    if [ $? -eq 0 ]; then
      echo "FUSE and its libraries have been uninstalled successfully (yum)."
    else
      echo "Error uninstalling FUSE using yum. Please check the output above."
    fi
  elif command -v dnf >/dev/null 2>&1; then
    echo "Using dnf package manager (Fedora/CentOS 8+ based)."
    sudo dnf remove -y fuse fuse-libs fuse-devel
    if [ $? -eq 0 ]; then
      echo "FUSE and its libraries have been uninstalled successfully (dnf)."
    else
      echo "Error uninstalling FUSE using dnf. Please check the output above."
    fi
  elif command -v zypper >/dev/null 2>&1; then
    echo "Using zypper package manager (openSUSE based)."
    sudo zypper remove -y fuse &> /dev/null
    if [ $? -eq 0 ]; then
      echo "FUSE has been uninstalled successfully (zypper)."
    else
      echo "Error uninstalling FUSE using zypper. Please check the output above."
    fi
  elif command -v pacman >/dev/null 2>&1; then
    echo "Using pacman package manager (Arch Linux based)."
    sudo pacman -Rsc --noconfirm fuse &> /dev/null
    if [ $? -eq 0 ]; then
      echo "FUSE has been uninstalled successfully (pacman)."
    else
      echo "Error uninstalling FUSE using pacman. Please check the output above."
    fi
  else
    echo "Could not detect a supported package manager. If you installed FUSE manually, you will need to uninstall it manually."
  fi

elif [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Detected macOS operating system."
  echo "If you installed FUSE using Homebrew:"
  echo "  brew uninstall --cask macfuse"
  echo "If you installed it manually, you will need to follow the uninstallation instructions provided by the FUSE for macOS (osxfuse) package."
  echo "Typically, this involves running an uninstaller application that comes with the DMG or following instructions on their website."
  echo "Refer to: https://osxfuse.github.io/"
else
  echo "Unsupported operating system: $(uname -s)"
fi

echo "Uninstallation process finished."
echo "Please check if FUSE is still installed (e.g., by trying to mount a FUSE filesystem)."

exit 0