#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail

# --- Helper Functions ---
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1"
}

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
  local repo_path="$1" # Accept path as an argument
  local upstream='@{u}' # Shorthand for the upstream branch of the current branch
  local local_hash remote_hash remote_status remote_err

  if [[ -z "$repo_path" || ! -d "$repo_path/.git" ]]; then
    echo "Error: check_remote_changes: Invalid repository path: '$repo_path'" >&2
    return 2 # Indicate error
  fi

  # echo "Checking remote changes for $repo_path..."

  # 1. Update information about the remote repository quietly
  #    'git remote update' fetches from all remotes, '--prune' removes stale branches
  #    'git fetch -q' is simpler if you only care about the default remote ('origin')
  #    Using fetch here for simplicity. Redirect stderr to capture fetch errors.
  remote_err=$(git -C "$repo_path" fetch -q 2>&1)
  if [[ $? -ne 0 ]]; then
      # Check if the error is just "no upstream configured" vs actual fetch failure
      if [[ "$remote_err" =~ fatal:\ .*no\ upstream\ configured ]]; then
          echo "Info: No upstream branch configured in '$repo_path'. Cannot check remote." >&2
          # Treat as "no changes to pull" since we can't check
          return 0
      else
          echo "Error: Failed to fetch updates for '$repo_path'." >&2
          echo "Git Output: $remote_err" >&2
          # Treat as "no changes to pull" to avoid pull prompts on network errors
          return 0
      fi
  fi

  # 2. Get the commit hash of the local HEAD and the remote upstream branch
  local_hash=$(git -C "$repo_path" rev-parse HEAD)
  remote_hash=$(git -C "$repo_path" rev-parse "$upstream") # @{u} refers to the upstream commit

  # Handle case where upstream might not be set correctly after fetch attempt
  if [[ $? -ne 0 ]]; then
      echo "Info: Could not determine upstream branch commit for '$repo_path'. Maybe not configured or branch doesn't exist remotely?" >&2
      return 0 # Cannot check if upstream isn't clear
  fi

  # 3. Compare the hashes
  if [[ "$local_hash" == "$remote_hash" ]]; then
    # Local HEAD matches the remote upstream - Up-to-date
    # echo "Local repository is up-to-date with remote."
    return 0 # No changes to pull
  else
    # Hashes differ, need to know *how*
    # Use 'git rev-list' to count commits unique to the remote
    remote_status=$(git -C "$repo_path" rev-list --count HEAD.."$upstream")
    if [[ "$remote_status" -gt 0 ]]; then
      # echo "Remote has $remote_status new commit(s). Need to pull."
      return 1 # Indicate remote changes exist (remote is ahead)
    else
      # If count is 0 or less (shouldn't be less), local might be ahead or diverged.
      # In either case, a simple 'pull' isn't needed / might require merging/rebasing.
      # We only return 1 if remote is strictly ahead.
      echo "Local repository is not behind remote (may be ahead or diverged)."
      return 0 # No *pull* needed for simple fast-forward
    fi
  fi
}

# --- Main Execution ---

check_local_changes
local_changes_detected=$? # Capture exit code

check_remote_changes $REPO_PATH
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