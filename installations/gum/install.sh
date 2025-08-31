#!/bin/bash

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

# Check if go is installed
if ! command -v go &> /dev/null
then
    log_error "Go is not installed. Please install Go first."
    exit 1
fi

log_debug "Installing gum..."
go install github.com/charmbracelet/gum@latest
log_info "Gum installation complete."
