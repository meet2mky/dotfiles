#!/bin/bash

# Script to uninstall Go from Linux using 'which go' and 'whereis go'
echo "Uninstalling Go..."

# Find Go binary using 'which go'
go_bin=$(which go)

if [[ -n "$go_bin" ]]; then
  echo "Found Go binary: $go_bin"
  echo "Removing: $go_bin"
  sudo rm -f "$go_bin"
else
  echo "Go binary not found using 'which go'."
fi

# Find Go installation paths using 'whereis go'
go_paths=$(whereis go | awk '{for(i=2;i<=NF;i++)print $i}')

if [[ -n "$go_paths" ]]; then
  echo "Found Go paths: $go_paths"
  for path in $go_paths; do
    if [[ -d "$path" ]]; then
      echo "Removing directory: $path"
      sudo rm -rf "$path"
    elif [[ -f "$path" ]]; then
      echo "Removing file: $path"
      sudo rm -f "$path"
    else
      echo "Path not found: $path"
    fi
  done
else
  echo "Go paths not found using 'whereis go'."
fi

# Get the original user's home directory
HOME=$(getent passwd "$original_user" | cut -d: -f6)

# Remove residual go directory in home folder.
if [[ -d "$HOME/go" ]]; then
  echo "Removing: $HOME/go"
  rm -rf "$HOME/go"
fi

# Removing the PATH for go.
HOME=$(getent passwd "$USER" | cut -d: -f6)
if [ -z "$HOME" ]; then
  echo "Error: Could not determine the user's home directory."
  exit 1
fi
ZSHRC="$HOME/.zshrc"
BEGIN_MARKER="# --- BEGIN GO PATH ---"
END_MARKER="# --- END GO PATH ---"

if grep -q "$BEGIN_MARKER" "$ZSHRC"; then
  echo "Removing Go PATH from $ZSHRC..."
  # Use sed to remove the lines between the markers (inclusive)
  sed -i "/$BEGIN_MARKER/,/$END_MARKER/d" "$ZSHRC"
  echo "Go PATH removed from $ZSHRC. You might need to source it (exec zsh) or open a new terminal."
else
  echo "Go PATH markers not found in $ZSHRC. Assuming it was not managed by this script."
fi

echo "Go uninstallation complete."