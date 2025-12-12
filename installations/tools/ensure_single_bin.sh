#!/bin/bash

# --- Header Guard ---
if [[ -n "${ENSURE_SINGLE_BIN_SH_LOADED:-}" ]]; then
    return 0
fi
ENSURE_SINGLE_BIN_SH_LOADED=1

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

# --- Helper Function ---

# Function: ensure_single_bin
# Description: Validates that exactly one version of a binary exists in the PATH.
# Arguments: $1 - The name of the binary to check.
ensure_single_bin() {
    local binary_name="${1:-}"
    local locations=()

    # 1. Argument Validation
    if [[ -z "$binary_name" ]]; then
        log_error "Binary name is required for check_single_binary."
        return 1
    fi

    log_debug "Checking for installations of '$binary_name' in PATH..."

    # 2. Find Locations using 'type -a'
    # We use 'type -a' which is a shell builtin and more reliable than 'which -a'
    while IFS= read -r found_path; do
        # Check if found_path is already in locations to ensure uniqueness
        local is_duplicate=false
        for loc in "${locations[@]:-}"; do
            if [[ "$loc" == "$found_path" ]]; then
                is_duplicate=true
                break
            fi
        done
        
        if [[ "$is_duplicate" == "false" ]]; then
            locations+=("$found_path")
        fi
    done < <(type -a "$binary_name" 2>/dev/null | grep -E 'is .*[/]' | sed -e 's/.* is //')

    local count="${#locations[@]}"

    # 3. Evaluate and Report
    if [[ "$count" -eq 0 ]]; then
        log_error "Binary '$binary_name' not found in your PATH."
        return 1
    elif [[ "$count" -eq 1 ]]; then
        log_info "SUCCESS: Single installation of '$binary_name' found: ${locations[0]}"
        return 0
    else 
        log_error "Multiple installations of '$binary_name' found in your PATH:"
        for loc in "${locations[@]}"; do
            echo "  - $loc" >&2
        done
        log_debug "Please resolve the conflict by adjusting your PATH."
        return 1
    fi
}

unset _CURRENT_DIR