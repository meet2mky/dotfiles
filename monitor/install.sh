#!/bin/bash

set -e # Exit immediately if a command fails

# --- Configuration ---
ZSHRC="$HOME/.zshrc"
DOTFILE_MONITOR_PATH="$HOME/dotfiles/monitor/main.sh" # Use a variable for the path
BEGIN_MARKER="# --- BEGIN DOTFILE MONITOR ---"
END_MARKER="# --- END DOTFILE MONITOR ---"

# --- Helper Functions ---

# Function to check if a line exists in a file
line_exists() {
  grep -qF "$1" "$2"
}

# Function to add the dotfiles check to .zshrc
add_dotfile_monitor_to_zshrc() {
  local zsh_code="
TEMP_FILE=\"/tmp/dotfiles_changed\"
if [ -f \"\$TEMP_FILE\" ]; then
   echo \"Dotfile changes detected...\"
fi
/bin/bash $DOTFILE_MONITOR_PATH &! # Run in background and disown
"

  # Check if both markers already exist
  if line_exists "$BEGIN_MARKER" "$ZSHRC" && line_exists "$END_MARKER" "$ZSHRC"; then
    echo "Dotfile monitor already configured in $ZSHRC."
    return 1 # Indicate already configured
  else
    echo "Adding Dotfile monitor to $ZSHRC..."
    echo "$BEGIN_MARKER" >> "$ZSHRC"
    echo "$zsh_code" >> "$ZSHRC"
    echo "$END_MARKER" >> "$ZSHRC"
    echo "Dotfile monitor added to $ZSHRC. You might need to source it (exec zsh) or open a new terminal."
    return 0 # Indicate success
  fi
}

# --- Main Execution ---

add_dotfile_monitor_to_zshrc

exit 0