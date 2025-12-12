#!/bin/bash

# --- Header Guard ---
if [[ -n "${BIN_INSTALLER_SH_LOADED:-}" ]]; then
    return 0
fi
BIN_INSTALLER_SH_LOADED=1

# --- Source Guard ---
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
    echo "Error: This script must be sourced."
    exit 1
fi

# --- Dependency Loading ---
# Automatically find and source loggers.sh from the same directory.
# This ensures log_info, log_debug, and log_error are available.
_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${_CURRENT_DIR}/loggers.sh" ]]; then
    # shellcheck source=/dev/null
    source "${_CURRENT_DIR}/loggers.sh"
else
    echo "❌ [ERR] Required dependency 'loggers.sh' not found in ${_CURRENT_DIR}"
    return 1
fi

if [[ -f "${_CURRENT_DIR}/symlink_creator.sh" ]]; then
    # shellcheck source=/dev/null
    source "${_CURRENT_DIR}/symlink_creator.sh"
else
    echo "❌ [ERR] Required dependency 'symlink_creator.sh' not found in ${_CURRENT_DIR}"
    return 1
fi


# --- Helper Functions ---

_check_command_exists() {
    command -v "$1" &> /dev/null
}

# Function: install_to_bin
# Arguments: $1 (source script path), $2 (desired command name)
install_to_bin() {
    local script_path="${1:-}"
    local command_name="${2:-}"
    local bin_dir="/usr/local/bin"
    local destination="${bin_dir}/${command_name}"

    # 1. Validation
    if [[ -z "$script_path" || -z "$command_name" ]]; then
        log_error "Usage: install_to_bin <script_path> <command_name>"
        return 1
    fi

    if [[ ! -f "$script_path" ]]; then
        log_error "Source script not found at: $script_path"
        return 1
    fi

    log_info "---------------------------------------------------------------------"
    log_info "Installing [$command_name] to [$bin_dir]..."

    # 2. Make source executable
    log_info "Ensuring source script is executable..."
    chmod +x "$script_path"

    # 3. Create Symlink (using your existing symlink_creator function)
    # Note: This might require sudo if /usr/local/bin is protected
    if [[ ! -w "$bin_dir" ]]; then
        log_info "Requesting sudo to create link in $bin_dir..."
        sudo ln -sf "$script_path" "$destination"
    else
        create_symlink "$script_path" "$destination"
    fi

    # 4. Verify Installation
    if _check_command_exists "$command_name"; then
        log_info "Success: Command [$command_name] is now available."
    else
        log_error "Failure: Command [$command_name] not found in PATH."
        return 1
    fi
    log_info "---------------------------------------------------------------------"
}

unset _CURRENT_DIR_BI