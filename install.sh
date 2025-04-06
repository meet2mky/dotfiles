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
    log_info ""
    log_info ""
    log_info "---------------------------------------------------------------------"
    log_info "---------------------------------------------------------------------"
    bash $1
    log_info "---------------------------------------------------------------------"
    log_info "---------------------------------------------------------------------"
    log_info ""
    log_info ""
}

execute_script "$HOME/dotfiles/Installations/zsh/install.sh"
execute_script "$HOME/dotfiles/Installations/go/install.sh"
execute_script "$HOME/dotfiles/Installations/fuse/install.sh"
execute_script "$HOME/dotfiles/Installations/oh-my-zsh/install.sh"

go run "vscode/main.go"

execute_script "$HOME/dotfiles/monitor/install.sh"

exec zsh