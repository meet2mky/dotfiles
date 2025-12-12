#!/bin/bash

# --- Source Guard ---
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
    echo "❌ Error: This script must be sourced. Use: source reload.sh"
    exit 1
fi

# Function to perform the reload
reload_shell_utils() {
    echo "🔄 Reloading shell utilities..."

    # 1. Unset Header Guards
    unset ENSURE_SINGLE_BIN_SH_LOADED

    # 2. Identify the directory of this script
    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

    # 3. Re-source the main entry point
    if [[ -f "${script_dir}/ensure_single_bin.sh" ]]; then
        # shellcheck source=/dev/null
        source "${script_dir}/ensure_single_bin.sh"
        
        # We can now use log_info because all_in_one has been re-sourced
        if command -v log_info &> /dev/null; then
            log_info "All utilities have been refreshed in the current shell."
        else
            echo "✅ All utilities refreshed."
        fi
    else
        echo "❌ Error: Could not find all_in_one.sh in ${script_dir}"
        return 1
    fi
}

# Execute the reload
reload_shell_utils