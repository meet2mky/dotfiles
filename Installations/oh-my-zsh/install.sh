#!/bin/bash

# Script to install Zsh and Oh My Zsh.
# Assumes git, curl, and sh are already available.

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipe failures should cause the script to exit.
set -o pipefail

# --- Helper Functions ---
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

# --- Main Script ---
log_info "Starting Oh My Zsh installation script..."
OMZ_DIR="$HOME/.oh-my-zsh" # Define standard install directory
log_info ""
log_info "-------------------------------------------------------------------------"
log_info "Prepating for installation..."
log_info "Checking for existing Oh My Zsh installation at $OMZ_DIR..."
if [ -d "$OMZ_DIR" ]; then
    log_info "Oh My Zsh directory found. Starting Uninstallation First..."
    log_info "Fixing uninstall script to work automatically..."
    sed -i 's/^  if chsh -s "$old_shell"; then/  if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$old_shell" ] \&\& chsh -s "$old_shell"; then/' "$OMZ_DIR/tools/uninstall.sh"
    log_info "Removing unnecessary exit statements.."
    sed -i 's/^.*exit.*$//' "$OMZ_DIR/tools/uninstall.sh"
    log_info "Uninstalling Oh My Zsh..."
    echo "y" | bash "$OMZ_DIR/tools/uninstall.sh"
    log_info "Removing unwanted backup files..."
    rm $HOME/.zshrc.omz-uninstalled-*
else
  log_info "No existing Oh My Zsh installation found. Continuing with installation..."
fi
log_info "-------------------------------------------------------------------------"
log_info ""

# --- Install Oh My Zsh ---
# Assumes curl, sh, and git (needed by Oh My Zsh internally) are present.
log_info ""
log_info "Installing Oh My Zsh..."

# The "" argument attempts to bypass the chsh prompt for non-interactive use.
# The --unattended flag selects default options during installation.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Note: Oh My Zsh installation might change the default shell automatically.
# If not, the user might need to run 'chsh -s $(which zsh)' manually.

log_info "Oh My Zsh installation script finished successfully!"
log_info ""
log_info "-------------------------------------------------------------------------"
log_info "Tuning some knobs for Oh My Zsh..."
log_info "Setting the THEME to agnoster..."
sed -i "s/^ZSH_THEME=\"[^\"]*\"/ZSH_THEME=\"agnoster\"/" "$HOME/.zshrc"
log_info "Setting the CASE_SENSITIVE completion to true..."
sed -i 's/^# CASE_SENSITIVE="true"/CASE_SENSITIVE="true"/' "$HOME/.zshrc"
sed -i 's/^CASE_SENSITIVE="false"/CASE_SENSITIVE="true"/' "$HOME/.zshrc"
log_info ""
log_info "-------------------------------------------------------------------------"
log_info ""
log_info "Please close and reopen your terminal, or log out and back in, to start using Zsh with Oh My Zsh."

exit 0