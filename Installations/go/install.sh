#!/bin/bash

# Script to install Go version 1.24.0 on Linux, using uname to detect architecture

# Variables
GO_VERSION="1.24.0" # Change this to the desired Go version
GO_INSTALL_DIR="/usr/local"
GO_EXTRACT_DIR="go"

# Detect architecture using uname
ARCH=$(uname -m)

case "$ARCH" in
  x86_64)
    GO_ARCH="linux-amd64"
    ;;
  aarch64|arm64)
    GO_ARCH="linux-arm64"
    ;;
  armv7l|armv6l)
    GO_ARCH="linux-armv6l" # Or armv7l depending on your specific device
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

GO_URL="https://go.dev/dl/go${GO_VERSION}.${GO_ARCH}.tar.gz"
GO_FILENAME="go${GO_VERSION}.${GO_ARCH}.tar.gz"

# Check if wget is installed
if ! command -v wget &> /dev/null; then
    echo "wget is not installed. Please install it (e.g., sudo apt install wget or sudo yum install wget)."
    exit 1
fi

# Check if tar is installed
if ! command -v tar &> /dev/null; then
    echo "tar is not installed. Please install it (e.g., sudo apt install tar or sudo yum install tar)."
    exit 1
fi

echo "Installing Go version $GO_VERSION for $GO_ARCH architecture..."

# Download Go
echo "Downloading Go from $GO_URL..."
wget "$GO_URL"

if [[ ! -f "$GO_FILENAME" ]]; then
        echo "Download failed."
        exit 1
fi

# Extract Go
echo "Extracting Go..."
tar -xzf "$GO_FILENAME"

# Move Go to installation directory
echo "Moving Go to $GO_INSTALL_DIR..."
sudo mv "$GO_EXTRACT_DIR" "$GO_INSTALL_DIR"

# Set environment variables
echo "Setting environment variables..."

# Add Go to PATH in ~/.zshrc
ZSHRC="$HOME/.zshrc"

GO_PATH_LINE="export PATH=\"\$PATH:$GO_INSTALL_DIR/go/bin\""
BEGIN_MARKER="# --- BEGIN GO PATH ---"
END_MARKER="# --- END GO PATH ---"

# Check if the markers are already present to avoid duplicates
if grep -q "$BEGIN_MARKER" "$ZSHRC"; then
  echo "Go PATH management already present in $ZSHRC."
  exit 1
else
  echo "Adding Go PATH to $ZSHRC..."
  cat <<EOF >> "$ZSHRC"
$BEGIN_MARKER
$GO_PATH_LINE
$END_MARKER
EOF
  echo "Go PATH added to $ZSHRC. You might need to source it (exec zsh) or open a new terminal."
fi

echo "Removing downloaded files.."
rm $GO_FILENAME
