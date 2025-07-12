#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail


# --- Configuration ---
FILE_PATH="$HOME/.zshrc"
DOTFILE_MONITOR_PATH="$HOME/dotfiles/monitor/main.sh" # Use a variable for the path
START_MARKER="# --- BEGIN DOTFILE MONITOR ---"
END_MARKER="# --- END DOTFILE MONITOR ---"
TEXT="
TEMP_FILE=\"/tmp/dotfiles_changed\"
if [ -f \"\$TEMP_FILE\" ]; then
    echo \"Dotfile changes detected...\"
fi
/bin/bash $DOTFILE_MONITOR_PATH &! # Run in background and disown
"

./installations/tools/block_manager.sh "$FILE_PATH" "$START_MARKER" "$END_MARKER" "REMOVE"

./installations/tools/block_manager.sh "$FILE_PATH" "$START_MARKER" "$END_MARKER" "INSERT" "$TEXT"