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

execute_script() {
    if [ "$#" -eq 0 ]; then
        log_error "Requires at least one argument." >&2
        return 1
    fi
    
    local SCRIPT_PATH="$1"
    shift # Remove the first argument from the list

    log_debug ""
    log_debug ""
    log_debug "---------------------------------------------------------------------"
    log_debug "---------------------------------------------------------------------"

    if [ "$#" -gt 0 ]; then
        bash "$SCRIPT_PATH" "$@"
    else
        bash "$SCRIPT_PATH"
    fi
    log_debug "---------------------------------------------------------------------"
    log_debug "---------------------------------------------------------------------"
    log_debug ""
    log_debug ""
}

gum_installer() {
    if present_command "gum"; then
        log_debug "gum is already installed, Installation and configuration skipped..."
        return 0
    fi
    log_debug "gum is not detected on system. Installation and configuration started..."
    execute_script "$HOME/dotfiles/installations/gum/install.sh"
}

show_menu() {
    local options=(
        "zsh"
        "go"
        "fuse"
        "gcsfuse"
        "oh-my-zsh"
        "python3"
        "tmux"
        "vscode"
        "monitor"
        "dotfiles_setup executable"
        "dotfiles_vscode_symlink_creator executable"
    )
    local commands=(
        "execute_script "$HOME/dotfiles/installations/zsh/install.sh""
        "execute_script "$HOME/dotfiles/installations/go/install.sh" "1.24.0""
        "execute_script "$HOME/dotfiles/installations/fuse/install.sh""
        "execute_script "$HOME/dotfiles/installations/gcsfuse/install.sh""
        "execute_script "$HOME/dotfiles/installations/oh-my-zsh/install.sh""
        "execute_script "$HOME/dotfiles/installations/python3/install.sh""
        "execute_script "$HOME/dotfiles/installations/tmux/install.sh""
        "go run "$HOME/dotfiles/vscode/main.go""
        "execute_script "$HOME/dotfiles/monitor/install.sh""
        "bash "$HOME/dotfiles/installations/tools/add_script_to_executable.sh" "$HOME/dotfiles/setup.sh" "dotfiles_setup""
        "bash "$HOME/dotfiles/installations/tools/add_script_to_executable.sh" "$HOME/dotfiles/vscode/vscode_symlink_creator.sh" "dotfiles_vscode_symlink_creator""
    )

    log_debug "Choose the components to install:"
    
    local chosen_options
    chosen_options=$("$(go env GOPATH)/bin/gum" choose --no-limit "${options[@]}")

    if [ -z "$chosen_options" ]; then
        log_debug "No components selected. Aborting installation."
        exit 0
    fi

    log_info "Following components will be installed:"
    echo "$chosen_options"

    read -p "Proceed with installation? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Installation aborted."
        exit 0
    fi

    for option in $chosen_options; do
        for i in "${!options[@]}"; do
            if [ "${options[$i]}" == "$option" ]; then
                log_info "Running: ${options[$i]}"
                eval "${commands[$i]}"
                log_info "------------------"
                break
            fi
        done
    done
}
GUM="$HOME/go/bin/gum"

main(){
    # Go to Home Dir
    pushd "$HOME"

    # Install gum
    gum_installer

    # Setup Git
    $GUM confirm "Install Github & Steup" && git_installer
    $GUM confirm "Remove dotfiles and Install again" && (rm -rf $HOME/dotfiles && git clone https://github.com/meet2mky/dotfiles.git)
    # Go to dotfiles repo
    pushd "dotfiles"
    
    show_menu

    # Come out of dotfiles repo
    popd

    # Come out of Home Dir
    popd
    exec zsh
}

main