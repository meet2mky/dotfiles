#!/bin/bash

# --- Configuration ---
REPO_PATH="$HOME/dotfiles"
REMOTE_NAME="origin"
BRANCH_NAME="master"
TEMP_FILE="/tmp/dotfiles_changed"

# --- Helper Functions ---

# Function to check for local changes
check_local_changes() {
  # Optimized local change detection
  if [[ $(git -C "$REPO_PATH" diff --quiet HEAD) -ne 0 || -n "$(git -C "$REPO_PATH" status --porcelain)" ]]; then
      return 1 # Indicate changes
  fi
  return 0 # No changes
}

# --- Main Execution ---

check_local_changes
local_changes_detected=$? # Capture exit code


if [ "$local_changes_detected" -ne 0 ]; then
  if [ ! -f "$TEMP_FILE" ]; then
    touch "$TEMP_FILE"  # Create the temporary file if it doesn't exist
  fi
else
  if [ -f "$TEMP_FILE" ]; then
    rm "$TEMP_FILE"    # Remove the file if it exists
  fi
fi