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

# Function to check for remote changes
check_remote_changes() {
  git -C "$REPO_PATH" fetch "$REMOTE_NAME" > /dev/null 2>&1
  local local_head=$(git -C "$REPO_PATH" rev-parse "HEAD")
  local remote_head=$(git -C "$REPO_PATH" rev-parse "$REMOTE_NAME/$BRANCH_NAME")

  if [ "$local_head" != "$remote_head" ]; then
    local behind=$(git -C "$REPO_PATH" rev-list --count "$local_head".."$REMOTE_NAME/$BRANCH_NAME")
    local ahead=$(git -C "$REPO_PATH" rev-list --count "$REMOTE_NAME/$BRANCH_BRANCH".."$local_head")

    local notification_body=""
    if [ "$behind" -gt 0 ]; then
      notification_body+="Your local $BRANCH_NAME is behind $REMOTE_NAME/$BRANCH_NAME by $behind commit(s).\n"
    fi
    if [ "$ahead" -gt 0 ]; then
      notification_body+="Your local $BRANCH_NAME is ahead of $REMOTE_NAME/$BRANCH_NAME by $ahead commit(s).\n"
    fi
    if [ -n "$notification_body" ]; then
      return 1 # Indicate changes
    fi
  fi
  return 0 # No changes
}

# --- Main Execution ---

check_local_changes
local_changes_detected=$? # Capture exit code

check_remote_changes
remote_changes_detected=$? # Capture exit code

if [ "$local_changes_detected" -ne 0 ] || [ "$remote_changes_detected" -ne 0 ]; then
  if [ ! -f "$TEMP_FILE" ]; then
    touch "$TEMP_FILE"  # Create the temporary file if it doesn't exist
  fi
else
  if [ -f "$TEMP_FILE" ]; then
    rm "$TEMP_FILE"    # Remove the file if it exists
  fi
fi