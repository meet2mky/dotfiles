#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
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

# Installs tmux by detecting the package manager (apt, dnf, yum, pacman).
install_tmux() {
    # Check if tmux is already installed
    if command -v tmux &>/dev/null; then
        log_debug " tmux is already installed. Installation Skipped."
        return 0
    fi

    log_debug "Attempting to install tmux..."

    # Detect package manager and install tmux
    if command -v apt-get &>/dev/null; then
        # For Debian, Ubuntu, etc.
        sudo apt-get update && sudo apt-get install -y tmux
    elif command -v dnf &>/dev/null; then
        # For Fedora, RHEL 8+, etc.
        sudo dnf install -y tmux
    elif command -v yum &>/dev/null; then
        # For CentOS 7, older RHEL, etc.
        sudo yum install -y tmux
    elif command -v pacman &>/dev/null; then
        # For Arch Linux, Manjaro, etc.
        sudo pacman -Syu --noconfirm tmux
    else
        log_error "Could not find a supported package manager."
        log_debug "Please install tmux manually."
        return 1
    fi

    # Verify installation
    if command -v tmux &>/dev/null; then
        log_info "tmux has been installed successfully."
    else
        log_error "tmux installation failed."
        return 1
    fi
}

log_debug ""
log_debug ""
if ! install_tmux; then 
    exit 1
fi

# --- Configuration ---
FILE_PATH="$HOME/.tmux.conf"
rm -rf "$FILE_PATH"
touch "$FILE_PATH"
START_MARKER="# --- BEGIN TMUX ---"
END_MARKER="# --- END TMUX ---"
TEXT=$(cat <<'EOF'

# Set zsh as the default shell
set-option -g default-shell '/usr/bin/zsh'
# Enable mouse mode
set-option -g mouse on
# Update PATH environment variable
set-option -g update-environment 'PATH DISPLAY SSH_AUTH_SOCK'
# Show an indicator on the right when prefix is active
set -g status-right '#[fg=white,bg=default]#{?client_prefix,#[reverse] PREFIX_PRESSED #[noreverse],} %H:%M %d-%b-%y'
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'nhdaly/tmux-better-mouse-mode'
# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
x
EOF
)
# Remove the placeholder 'x' character, leaving the newlines intact
TEXT=${TEXT%x}

if ! ./installations/tools/block_manager.sh "$FILE_PATH" "$START_MARKER" "$END_MARKER" "$TEXT"; then 
    log_error "Unable to update tmux marker. Exiting..."
else
    log_info "tmux marker successfully added."
fi


START_MARKER="# --- BEGIN ALIAS ---"
END_MARKER="# --- END ALIAS ---"
FILE_PATH="$HOME/.zshrc"
TEXT=$(cat <<'EOF'

alias tmux-path-refresh='source ~/.zshrc && for var in $(env | cut -d= -f1); do tmux set-environment -g "$var" "$(printenv "$var")"; done && echo "✅ tmux environment refreshed!"'
add-to-path() { if [[ -d "$1" ]] && (( ! ${path[(I)$1:A]} )); then path=("$1:A" $path); fi; }
x
EOF
)
# Remove the placeholder 'x' character, leaving the newlines intact
TEXT=${TEXT%x}

bash "$HOME/dotfiles/installations/tools/block_manager.sh" "$FILE_PATH" "$START_MARKER" "$END_MARKER" "$TEXT"

