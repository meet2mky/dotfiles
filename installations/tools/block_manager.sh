#!/bin/bash

# --- Header Guard ---
if [[ -n "${BLOCK_MANAGER_SH_LOADED:-}" ]]; then
    return 0
fi
BLOCK_MANAGER_SH_LOADED=1

# --- Source Guard ---
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
    echo "❌[ERR] This script must be sourced. Use: source block_manager.sh"
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


# --- Internal Helper Functions ---

_is_empty() {
    [[ -z "${1:-}" ]]
}

_check_line_exists() {
    local line="$1"
    local file="$2"
    grep -qxF -- "$line" "$file"
}

_check_prefix() {
    [[ "$1" == "$2"* ]]
}

# --- Main Function ---

# Usage: manage_block <file_path> <start_marker> <end_marker> <content>
manage_block() {
    local file_path="${1:-}"
    local start_marker="${2:-}"
    local end_marker="${3:-}"
    local content="${4:-}"

    # 1. Validation
    if [[ ! -f "$file_path" ]]; then
        log_error "File not found: $file_path"
        return 1
    fi

    if ! _check_prefix "$start_marker" "# MARKER BEGIN"; then
        log_error "Start marker [$start_marker] must start with '# MARKER BEGIN'"
        return 1
    fi

    if ! _check_prefix "$end_marker" "# MARKER END"; then
        log_error "End marker [$end_marker] must start with '# MARKER END'"
        return 1
    fi

    if _is_empty "$content"; then
        log_error "Insert content cannot be empty."
        return 1
    fi

    # 2. State Checking
    local has_start=1
    local has_end=1
    _check_line_exists "$start_marker" "$file_path" || has_start=0
    _check_line_exists "$end_marker" "$file_path" || has_end=0

    # 3. Logic Branching
    if (( has_start && has_end )); then
        log_info "Updating existing block in '$file_path'..."
        
        # Escape markers for SED
        local escaped_start escaped_end
        escaped_start=$(printf '%s\n' "$start_marker" | sed -e 's/[\\/&.*^$[]/\\&/g')
        escaped_end=$(printf '%s\n' "$end_marker" | sed -e 's/[\\/&.*^$[]/\\&/g')

        # Create backup and delete existing range
        sed -i.bak "/$escaped_start/,/$escaped_end/d" "$file_path"
        
        # Append new block
        printf "\n%s\n%s\n%s\n" "$start_marker" "$content" "$end_marker" >> "$file_path"
        log_info "Block updated. Backup: ${file_path}.bak"

    elif (( !has_start && !has_end )); then
        log_info "Inserting new block into '$file_path'..."
        printf "\n%s\n%s\n%s\n" "$start_marker" "$content" "$end_marker" >> "$file_path"
        log_info "Block inserted successfully."

    else
        log_error "Inconsistent state in '$file_path':"
        [[ $has_start -eq 1 ]] && log_error " -> Found start marker but missing end marker."
        [[ $has_end -eq 1 ]] && log_error " -> Found end marker but missing start marker."
        return 1
    fi
}

# Clean up internal variables
unset _CURRENT_DIR