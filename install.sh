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

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Command '$1' not found. Please install it first."
        exit 1
    fi
}

execute_script() {
    if [ "$#" -eq 0 ]; then
        log_error "Requires at least one argument." > &2
        return 1
    fi
    
    local SCRIPT_PATH="$1"
    shift # Remove the first argument from the list

    log_info ""
    log_info ""
    log_info "---------------------------------------------------------------------"
    log_info "---------------------------------------------------------------------"

    if [ "$#" -gt 0 ]; then
        bash $1 $@
    else
        bash $1
    fi
    log_info "---------------------------------------------------------------------"
    log_info "---------------------------------------------------------------------"
    log_info ""
    log_info ""
}

execute_script "$HOME/dotfiles/Installations/zsh/install.sh"
execute_script "$HOME/dotfiles/Installations/go/install.sh" "1.24.0"
execute_script "$HOME/dotfiles/Installations/fuse/install.sh"
execute_script "$HOME/dotfiles/Installations/oh-my-zsh/install.sh"

go run "vscode/main.go"

execute_script "$HOME/dotfiles/monitor/install.sh"

DIR_TO_INSTALL="/usr/local/bin"
INSTALL_COMMAND_NAME="dotfiles_install"
log_info ""
log_info ""
log_info "---------------------------------------------------------------------"
log_info "Adding install script to $DIR_TO_INSTALL..."
bash "$HOME/dotfiles/Installations/tools/remove_existing_symlink.sh" "$DIR_TO_INSTALL/$INSTALL_COMMAND_NAME"
ln -s "$HOME/dotfiles/install.sh" "$DIR_TO_INSTALL/$INSTALL_COMMAND_NAME"
check_command "$INSTALL_COMMAND_NAME"
log_info "---------------------------------------------------------------------"
log_info ""
log_info ""

exec zsh