#!/bin/bash

# --- Header Guard ---
# Prevents the script from being loaded multiple times in the same session.
# Using ${VAR:-} syntax to ensure compatibility with 'set -u'.
if [[ -n "${LOGGERS_SH_LOADED:-}" ]]; then
    return 0
fi
LOGGERS_SH_LOADED=1

# --- Source Guard ---
# Ensures the script is sourced (source loggers.sh) rather than executed directly.
# This protects the shell environment from accidental exits.
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
    echo "❌[ERR] This script must be sourced. Use: source loggers.sh"
    exit 1
fi

# --- Helper Functions ---

# Log informative messages
log_info() {
    echo "✅[INF] $1"
}

# Log debug messages
# Only executes if DEBUG_MODE is set to a non-empty value.
# ${DEBUG_MODE:-} prevents 'unbound variable' errors under 'set -u'.
log_debug() {
    if [[ -n "${DEBUG_MODE:-}" ]]; then
        echo "🔍[DBG] $1"
    fi
}

# Log error messages to stderr
log_error() {
    echo "❌[ERR] $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Command '$1' not found. Please install it first."
        exit 1
    fi
}