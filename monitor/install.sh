#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail


# --- Configuration ---
FILE_PATH="$HOME/.zshrc"
START_MARKER="# --- BEGIN DOTFILE MONITOR ---"
END_MARKER="# --- END DOTFILE MONITOR ---"


TEXT=$(cat <<'EOF'

TEMP_FILE="/tmp/dotfiles_changed"
if [ -f "$TEMP_FILE" ]; then
    echo "Dotfile changes detected..."
fi
DOTFILE_MONITOR_PATH="$HOME/dotfiles/monitor/main.sh"
/bin/bash $DOTFILE_MONITOR_PATH &! # Run in background and disown
x
EOF
)
# Remove the placeholder 'x' character, leaving the newlines intact
TEXT=${TEXT%x}

./installations/tools/block_manager.sh "$FILE_PATH" "$START_MARKER" "$END_MARKER" "$TEXT"