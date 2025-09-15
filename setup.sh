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

if [[ $# -ne 1 ]]; then 
    log_error "Required go verison for this script..."
fi
# Required go version.
GO_VERSION="$1"

present_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    fi
    return 1
}

git_installer() {
    log_debug ""
    log_debug ""
    log_debug "Git Installation and configuration..."
    if present_command "git"; then
        log_debug "Git is already installed, Installation and configuration skipped..."
        return 0
    fi
    log_debug "Git is not detected on system. Installation and configuration started..."
    sudo apt update >> /dev/null 2>&1 || true
    sudo apt install git -y
    log_debug "Checking git version..."
    git --version
    log_debug ""
    log_debug ""
    log_debug "Installing Github CLI for login..."
    if present_command "gh"; then
        log_debug "Github CLI is already installed. Installation skipped..."
    else
        log_debug "Github CLI is not detected on system. Installation started..."
        sudo apt install gh -y
        log_debug "Checking Github CLI version..."
        gh --version
    fi
    log_debug ""
    log_debug ""
    log_debug "Performing login to git using Github CLI..."
    log_debug "Authenticate using browser..."
    yes | gh auth login --hostname github.com --protocol https --web
}

show_menu() {
    local options=(
        "zsh"
        "oh-my-zsh"
        "tmux"
        "fuse"
        "gcsfuse"
        "python3"
        "vscode_extensions"
        "dotfile_monitor"
        "dotfiles_setup executable"
        "dotfiles_vscode_symlink_creator executable"
    )
    local commands=(
        "$HOME/dotfiles/installations/zsh/install.sh"
        "$HOME/dotfiles/installations/oh-my-zsh/install.sh"
        "$HOME/dotfiles/installations/tmux/install.sh"
        "$HOME/dotfiles/installations/fuse/install.sh"
        "$HOME/dotfiles/installations/gcsfuse/install.sh"
        "$HOME/dotfiles/installations/python3/install.sh"
        "go run $HOME/dotfiles/vscode/main.go"
        "$HOME/dotfiles/monitor/install.sh"
        "$HOME/dotfiles/installations/tools/add_script_to_executable.sh $HOME/dotfiles/setup.sh dotfiles_setup"
        "$HOME/dotfiles/installations/tools/add_script_to_executable.sh $HOME/dotfiles/vscode_symlink_creator.sh dotfiles_vscode_symlink_creator"
    )

    log_debug "Choose the components to install:"
    
    local chosen_options
    chosen_options=$(gum choose --no-limit "${options[@]}")

    if [ -z "$chosen_options" ]; then
        log_debug "No components selected. Aborting installation."
        exit 0
    fi

    log_info "Following components will be installed:"
    echo "$chosen_options"

    if gum confirm; then 
        for option in $chosen_options; do
            for i in "${!options[@]}"; do
                if [ "${options[$i]}" == "$option" ]; then
                    gum spin --spinner dot --show-error --title "Installing $option" -- ${commands[$i]}
                    break
                fi
            done
        done
    fi
}

gum_installer() {
    # Check if go is installed
    wget -qO - https://raw.githubusercontent.com/meet2mky/dotfiles/master/installations/go/install.sh | bash -s "$GO_VERSION"

    log_debug "Installing gum from source..."
    go install github.com/charmbracelet/gum@latest
    log_info "Gum installation complete."
}

main(){
    gum_installer
    # Go to Home Dir
    CWD=$(pwd)
    cd "$HOME"

    # Setup Git
    gum confirm "Install Github & Steup" && git_installer
    gum confirm "Remove dotfiles and Install again" && (rm -rf dotfiles && git clone https://github.com/meet2mky/dotfiles.git)
    cd "dotfiles"
    show_menu
    cd ..
    # Come out of Home Dir
    cd "$CWD"
    exec zsh
}

main