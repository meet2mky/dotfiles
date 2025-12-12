#!/bin/bash

# --- Header Guard ---
# Prevents multiple sourcing of the entire utility suite
if [[ -n "${ALL_IN_ONE_SH_LOADED:-}" ]]; then
    return 0
fi
ALL_IN_ONE_SH_LOADED=1

# --- Source Guard ---
# Ensures this registry is sourced and not run as a standalone script
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
    echo "Error: This script must be sourced. Use: source all_in_one.sh"
    exit 1
fi

# --- Path Resolution ---
# Identify the directory where this script resides to locate sibling files
_UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Central Sourcing Logic ---
# We define an array of utilities to load in a specific order of dependency
_UTIL_FILES=(
    "loggers.sh"
    "symlink_creator.sh"
    "block_manager.sh"
    "ensure_single_bin.sh"
    "bin_installer.sh"
)

for _util in "${_UTIL_FILES[@]}"; do
    _util_path="${_UTILS_DIR}/${_util}"
    
    if [[ -f "${_util_path}" ]]; then
        # shellcheck source=/dev/null
        source "${_util_path}"
    else
        # If a core utility is missing, we should notify the user immediately
        echo "❌ [ERR] Utility file not found: ${_util_path}"
        return 1
    fi
done

# Clean up internal variable to keep the environment tidy
unset _UTILS_DIR _UTIL_FILES _util _util_path

# Log that the environment is ready if DEBUG_MODE is on
if [[ -n "${DEBUG_MODE:-}" ]]; then
    log_debug "All utilities sourced successfully from all_in_one.sh"
fi