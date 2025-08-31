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

# --- Main Script ---
log_debug "Starting Oh My Zsh installation script..."
OMZ_DIR="$HOME/.oh-my-zsh" # Define standard install directory
log_debug ""
log_debug "-------------------------------------------------------------------------"
log_debug "Prepating for installation..."
log_debug "Checking for existing Oh My Zsh installation at $OMZ_DIR..."
if [ -d "$OMZ_DIR" ]; then
    log_debug "Oh My Zsh directory found. Starting Uninstallation First..."
    log_debug "Fixing uninstall script to work automatically..."
    sed -i 's/^  if chsh -s "$old_shell"; then/  if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$old_shell" ] \&\& chsh -s "$old_shell"; then/' "$OMZ_DIR/tools/uninstall.sh"
    log_debug "Removing unnecessary exit statements.."
    sed -i 's/^.*exit.*$//' "$OMZ_DIR/tools/uninstall.sh"
    log_debug "Uninstalling Oh My Zsh..."
    echo "y" | bash "$OMZ_DIR/tools/uninstall.sh"
    log_debug "Removing unwanted backup files..."
    rm $HOME/.zshrc.omz-uninstalled-*
else
  log_debug "No existing Oh My Zsh installation found. Continuing with installation..."
fi
log_debug "-------------------------------------------------------------------------"
log_debug ""

# --- Install Oh My Zsh ---
# Assumes curl, sh, and git (needed by Oh My Zsh internally) are present.
log_debug ""
log_debug "Installing Oh My Zsh..."

# The "" argument attempts to bypass the chsh prompt for non-interactive use.
# The --unattended flag selects default options during installation.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Note: Oh My Zsh installation might change the default shell automatically.
# If not, the user might need to run 'chsh -s $(which zsh)' manually.

log_debug "Oh My Zsh installation script finished successfully!"
log_debug ""
log_debug "-------------------------------------------------------------------------"
log_debug "Tuning some knobs for Oh My Zsh..."
log_debug "Setting the THEME to agnoster..."
sed -i "s/^ZSH_THEME=\"[^\"]*\"/ZSH_THEME=\"agnoster\"/" "$HOME/.zshrc"
log_debug "Setting the CASE_SENSITIVE completion to true..."
sed -i 's/^# CASE_SENSITIVE="true"/CASE_SENSITIVE="true"/' "$HOME/.zshrc"
sed -i 's/^CASE_SENSITIVE="false"/CASE_SENSITIVE="true"/' "$HOME/.zshrc"
log_debug ""
log_debug "-------------------------------------------------------------------------"
log_debug ""
log_debug "Please close and reopen your terminal, or log out and back in, to start using Zsh with Oh My Zsh."

exit 0