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

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Command '$1' not found. Please install it first."
        exit 1
    fi
}

execute_script() {
    if [ "$#" -eq 0 ]; then
        log_error "Requires at least one argument." >&2
        return 1
    fi
    
    local SCRIPT_PATH="$1"
    shift # Remove the first argument from the list

    log_info ""
    log_info ""
    log_info "---------------------------------------------------------------------"
    log_info "---------------------------------------------------------------------"

    if [ "$#" -gt 0 ]; then
        bash "$SCRIPT_PATH" "$@"
    else
        bash "$SCRIPT_PATH"
    fi
    log_info "---------------------------------------------------------------------"
    log_info "---------------------------------------------------------------------"
    log_info ""
    log_info ""
}

execute_script "$HOME/dotfiles/installations/zsh/install.sh"
execute_script "$HOME/dotfiles/installations/go/install.sh" "1.24.0"
execute_script "$HOME/dotfiles/installations/fuse/install.sh"
execute_script "$HOME/dotfiles/installations/gcsfuse/install.sh"
execute_script "$HOME/dotfiles/installations/oh-my-zsh/install.sh"
execute_script "$HOME/dotfiles/installations/python3/install.sh"
execute_script "$HOME/dotfiles/installations/tmux/install.sh"

go run "$HOME/dotfiles/vscode/main.go"

execute_script "$HOME/dotfiles/monitor/install.sh"

bash "$HOME/dotfiles/installations/tools/add_script_to_executable.sh" "$HOME/dotfiles/setup.sh" "dotfiles_setup"
bash "$HOME/dotfiles/installations/tools/add_script_to_executable.sh" "$HOME/dotfiles/vscode/vscode_symlink_creator.sh" "dotfiles_vscode_symlink_creator"

exec zsh