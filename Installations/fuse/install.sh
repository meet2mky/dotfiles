#!/bin/bash

# Script to install FUSE (Filesystem in Userspace)

# Check the operating system to determine the appropriate package manager
if [[ "$(uname -s)" == "Linux" ]]; then
  echo "Detected Linux operating system."

  # Check for common package managers
  if command -v apt >/dev/null 2>&1; then
    echo "Using apt package manager (Debian/Ubuntu based)."
    sudo apt update
    sudo apt install -y fuse libfuse2 # or libfuse3 depending on your system
    if [ $? -eq 0 ]; then
      echo "FUSE and its library have been installed successfully."
    else
      echo "Error installing FUSE using apt. Please check the output above."
    fi
  elif command -v yum >/dev/null 2>&1; then
    echo "Using yum package manager (CentOS/RHEL based)."
    sudo yum install -y fuse fuse-libs
    if [ $? -eq 0 ]; then
      echo "FUSE and its library have been installed successfully."
    else
      echo "Error installing FUSE using yum. Please check the output above."
    fi
  elif command -v dnf >/dev/null 2>&1; then
    echo "Using dnf package manager (Fedora/CentOS 8+ based)."
    sudo dnf install -y fuse fuse-libs
    if [ $? -eq 0 ]; then
      echo "FUSE and its library have been installed successfully."
    else
      echo "Error installing FUSE using dnf. Please check the output above."
    fi
  elif command -v zypper >/dev/null 2>&1; then
    echo "Using zypper package manager (openSUSE based)."
    sudo zypper install -y fuse
    if [ $? -eq 0 ]; then
      echo "FUSE has been installed successfully."
    else
      echo "Error installing FUSE using zypper. Please check the output above."
    fi
  elif command -v pacman >/dev/null 2>&1; then
    echo "Using pacman package manager (Arch Linux based)."
    sudo pacman -S --needed fuse
    if [ $? -eq 0 ]; then
      echo "FUSE has been installed successfully."
    else
      echo "Error installing FUSE using pacman. Please check the output above."
    fi
  else
    echo "Could not detect a supported package manager. Please install FUSE manually using your distribution's instructions."
  fi

elif [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Detected macOS operating system."
  echo "On macOS, FUSE is typically provided by third-party packages like FUSE for macOS (osxfuse)."
  echo "You can install it using Homebrew (if you have it installed):"
  echo "  brew install --cask macfuse"
  echo "Or download it manually from the official website:"
  echo "  https://osxfuse.github.io/"
else
  echo "Unsupported operating system: $(uname -s)"
fi

exit 0