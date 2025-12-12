#!/bin/bash

# --- Header Guard ---
# Prevents the script from being loaded multiple times.
if [[ -n "${SYMLINK_CREATOR_SH_LOADED:-}" ]]; then
    return 0
fi
SYMLINK_CREATOR_SH_LOADED=1

# --- Source Guard ---
# Ensures the script is sourced, not executed directly.
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
    echo "Error: This script must be sourced. Use: source symlink_creator.sh"
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

# --- Helper Functions ---

# Function: create_symlink
# Description: Robustly creates a symbolic link with safety checks.
# Arguments: $1 = Target Path, $2 = Link Path
create_symlink() {
    local target="$1"
    local link_name="$2"

    # 1. Validation: Check for required arguments
    if [[ -z "${target:-}" || -z "${link_name:-}" ]]; then
        log_error "Missing arguments! Usage: create_symlink <target> <link_name>"
        return 1
    fi

    log_debug "Attempting to create symlink: ${link_name} -> ${target}"

    # 2. Target Check: Does the source file/directory exist?
    if [[ ! -e "$target" ]]; then
        log_error "Cannot create link: Target '${target}' does not exist."
        return 1
    fi

    # 3. Collision Check: Handle existing files or links
    if [[ -L "$link_name" ]]; then
        log_debug "Existing symlink found at '${link_name}'. Replacing it..."
        rm "$link_name"
    elif [[ -e "$link_name" ]]; then
        log_error "Conflict: A real file/directory already exists at '${link_name}'. Refusing to overwrite."
        return 1
    fi

    # 4. Directory Prep: Ensure the destination folder path exists
    local link_dir
    link_dir=$(dirname "$link_name")
    if [[ ! -d "$link_dir" ]]; then
        log_info "Creating directory path: ${link_dir}"
        mkdir -p "$link_dir" || { log_error "Failed to create directory ${link_dir}"; return 1; }
    fi

    # 5. Execution: Create the symlink
    if ln -s "$target" "$link_name"; then
        log_info "Created symlink: ${link_name} -> ${target}"
    else
        log_error "System failed to create symlink at '${link_name}'"
        return 1
    fi
}

unset _CURRENT_DIR