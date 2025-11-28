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

# ==============================================================================
# Script: check_single_binary.sh
# Description: Checks if exactly one executable version of a given binary
#              exists in the directories specified by the PATH environment
#              variable. Exits with status 0 on success (exactly one found),
#              and status 1 on failure (wrong usage, zero found, or multiple
#              found).
#
# Usage:
#   ./check_single_binary.sh <binary_name>
#
# Arguments:
#   <binary_name> - The name of the binary to check (e.g., "python", "git").
#                   This argument is required.
#
# Exit Codes:
#   0 - Success: Exactly one executable found in PATH.
#   1 - Failure: Incorrect usage (wrong number of arguments),
#                zero executables found in PATH, or
#                multiple executables found in PATH.
#
# Dependencies: bash, type (built-in), grep, sed
# Date: 2025-04-05
# ==============================================================================

# --- Argument Validation ---
# Check if exactly one argument was provided.
if [[ "$#" -ne 1 ]]; then
    # Print usage instructions and error.
    log_error "Exactly one argument (the binary name) is required." >&2
    log_debug "Usage: $0 <binary_name>" >&2
    exit 1 # Exit with failure status code
fi

# Store the first argument in a variable for clarity.
binary_name="$1"
# Initialize an array to store found paths safely.
locations=()

log_debug "Checking for installations of '$binary_name' in PATH..."

# --- Find Locations using 'type -a' ---
# Use 'type -a' to find all interpretations of the command name by the shell.
# Filter the output using 'grep' to keep only lines indicating a file path
# (typically formatted as "... is /path/to/binary").
# Use 'sed' to extract only the path part after " is ".
# Use a 'while read' loop with process substitution '< <(...)' for robustly
# reading each found path, even those containing spaces or special characters,
# into the 'locations' array.
# The 'found_path' variable is implicitly created/used by 'read' here.
while IFS= read -r found_path; do
    # Check if found_path is already in locations to ensure uniqueness
    is_duplicate=false
    for loc in "${locations[@]}"; do
        if [[ "$loc" == "$found_path" ]]; then
            is_duplicate=true
            break
        fi
    done
    if [[ "$is_duplicate" == "false" ]]; then
        locations+=("$found_path")
    fi
done < <(type -a "$binary_name" 2>/dev/null | grep -E 'is .*[/]' | sed -e 's/.* is //')

# --- Evaluate Count ---
# Get the number of elements (found paths) in the 'locations' array.
# The 'count' variable is implicitly created upon assignment here.
count="${#locations[@]}"

# --- Report Results and Exit ---
if [[ "$count" -eq 0 ]]; then
    # No installations found in PATH.
    log_error "Binary '$binary_name' not found in your PATH."
    log_debug "Current PATH=$PATH" 
    exit 1 # Exit script with failure status code
elif [[ "$count" -eq 1 ]]; then
    # Exactly one installation found.
    log_info "SUCCESS: Single installation of '$binary_name' found: ${locations[0]}"
    # Script execution finishes here successfully.
    exit 0 # Exit script with success status code
else # count > 1
    # Multiple installations found.
    log_error "Multiple installations of '$binary_name' found in your PATH:"
    # Print each found location clearly, prefixed with '  - '.
    printf "  - %s\n" "${locations[@]}"
    log_debug "Please resolve the conflict by adjusting your PATH or removing duplicate installations."
    log_debug "Current PATH=$PATH"
    exit 1 # Exit script with failure status code
fi