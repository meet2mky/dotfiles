#!/bin/bash

# Dynamic tmux session manager
# ===========================
# This script should be sourced in your shell's startup file (e.g., ~/.bashrc or ~/.zshrc)
# by adding the line:
#   source /path/to/this/tmux_manager.sh
#
# It provides two main functions:
#   ts          - Intelligently creates or attaches to a tmux session named after the current directory.
#   tmux-cleanup- Start a manual cleanup to remove sessions pointing to deleted directories.
#
# The script is designed to automatically run the cleanup and then start/attach a session
# when you source it.

# --- ts: Start or Attach to a Session ---
# Usage:
#   ts
ts() {
  # perform cleanup..
  tmux-cleanup
  # Use the canonical, real path of the current working directory.
  local full_path
  full_path=$(realpath "$PWD")

  # Check if the directory actually exists before proceeding.
  if [ ! -d "$full_path" ]; then
    echo "Error: Directory '$full_path' does not exist." >&2
    return 1
  fi

  # Generate a clean, human-readable session name from the path.
  local session_name
  if [[ "$full_path" == "$HOME"* ]]; then
    if [[ "$full_path" == "$HOME" ]]; then
      session_name="home"
    else
      # For paths inside home, use the relative path.
      session_name="${full_path#"$HOME"/}"
      # Replace characters that are problematic in session names.
      session_name=$(echo "$session_name" | tr '/.:' '_')
    fi
  else
    # For paths outside home (e.g., /var/www), create a name from the full path.
    session_name=$(echo "$full_path" | tr -d '/' | cut -c 1-200)
  fi

  # A final fallback in case the name ends up empty (e.g., for the root directory '/').
  [[ -z "$session_name" ]] && session_name="root"
  echo "Session Name is: [$session_name]"
  # Use `tmux has-session` with an exact match `='session_name'` to avoid ambiguity.
  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    echo "Creating new tmux session [$session_name]."
    # Create the session detached (-d), name it (-s), and set its starting directory (-c).
    tmux new-session -d -s "$session_name" -c "$full_path"

    # Store the full, original path in a session environment variable. This is crucial for the cleanup script.
    tmux set-environment -t "=$session_name" CREATION_PATH "$full_path"
  else 
    echo "Attaching to existing tmux session [$session_name]."
  fi
  if [ -n "$TMUX" ]; then
    echo "I am inside the TMUX already ✅"
    echo "Going to swith client to session [$session_name]."
    tmux switch-client -t "$session_name"
  else
    echo "I am not in a tmux session ❌."
    echo "Going to attach the session [$session_name]."
    tmux attach-session -t "$session_name"
  fi
}


# --- tmux-cleanup: Remove Sessions with Deleted Directories ---
# Usage:
#   tmux-cleanup
tmux-cleanup() {
  # FIX: Check if the tmux server is running. If not, there's nothing to clean.
  # This is the most likely reason the script fails in an automated SSH context,
  # as it might run before the server is initialized.
  if ! tmux info &>/dev/null; then
    echo "Tmux server not running. Skipping cleanup."
    return 0
  fi

  echo "🧹 Starting tmux cleanup..."

  # Loop through every running session name.
  # Using a "here string" (`<<<`) is a robust way to feed command output to a loop.
  while IFS= read -r session_name; do
    # Skip empty lines from the input, just in case.
    if [[ -z "$session_name" ]]; then
      continue
    fi

    # Retrieve the 'CREATION_PATH' variable we stored.
    # Use an exact match `='session_name'` for safety.
    local creation_path_var
    creation_path_var=$(tmux show-environment -t "=$session_name" CREATION_PATH 2>/dev/null)

    # If the variable is empty, it means this session wasn't created by our 'ts' script.
    # We should skip it to avoid accidentally killing manually created sessions.
    if [[ -z "$creation_path_var" ]]; then
      continue
    fi

    # This is more efficient and safer than `cut`, as it doesn't create a new process.
    # It removes everything up to and including the first '='.
    local creation_path="${creation_path_var#*=}"

    # If a path was found but the directory no longer exists, kill the session.
    if [[ -n "$creation_path" ]] && [[ ! -d "$creation_path" ]]; then
      echo "Directory '$creation_path' not found. Killing session '$session_name'."
      tmux kill-session -t "=$session_name"
    fi
  done <<< "$(tmux ls -F '#{session_name}')"

  echo "✅ Cleanup complete."
}
# --- SCRIPT EXECUTION ---
# This should only run in an interactive shell, and not when we are already inside tmux,
# to prevent recursive calls when tmux starts its default-shell.
if [[ -z "$TMUX" ]]; then
  true > "$HOME/dotfiles/installations/tmux/tmux.log" 2>&1
  ts >> "$HOME/dotfiles/installations/tmux/tmux.log" 2>&1
fi
