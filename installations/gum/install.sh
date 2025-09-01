#!/bin/bash

set -euo pipefail

# --- Helper Functions ---
log_info() {
    echo "✅[INF] $1"
}

log_debug() {
    echo "🔍[DBG] $1"
}

log_error() {
    echo "❌[ERR] $1"
}

# Check if brew is installed
if ! command -v brew &> /dev/null
then
    log_error "Brew is not installed. Please install Brew first."
    exit 1
fi

log_debug "Installing gum..."
brew install gum

START_MARKER="# --- BEGIN BREW ENV ---"
END_MARKER="# --- END BREW ENV ---"
FILE_PATH="$HOME/.zshrc"
TEXT=$(cat <<'EOF'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
x
EOF
)
# Remove the placeholder 'x' character, leaving the newlines intact
TEXT=${TEXT%x}

bash "$HOME/dotfiles/installations/tools/block_manager.sh" "$FILE_PATH" "$START_MARKER" "$END_MARKER" "$TEXT"

log_info "Gum installation complete."
