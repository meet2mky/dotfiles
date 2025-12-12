#!/bin/bash
# UTILS for ZSHRC SHELL
# Adds to current path removing duplicates
add-to-path() { if [[ -d "$1" ]] && (( ! ${path[(I)$1:A]} )); then path=("$1:A" $path); fi; }
# Fixes the 'code' command in Tmux by locating the active VS Code IPC socket.
fix_vscode_tmux() {
    # Only proceed if we are inside a TMUX session
    if [[ -n "${TMUX:-}" ]]; then
        
        # Check if the IPC hook is missing or points to a non-existent socket
        if [[ -z "${VSCODE_IPC_HOOK_CLI:-}" || ! -e "${VSCODE_IPC_HOOK_CLI:-}" ]]; then
            echo "🔍 Fixing code command for vscode..."

            # 1. Look for the most recently created, active VS Code socket file
            # Uses $UID for portability
            local socket_path
            socket_path=$(ls -1t "/run/user/${UID}/vscode-ipc-"*.sock 2>/dev/null | head -1)

            # 2. If a valid, existing socket path is found, export it
            if [[ -n "${socket_path}" && -e "${socket_path}" ]]; then
                export VSCODE_IPC_HOOK_CLI="${socket_path}"
                echo "✅ VSCODE_IPC_HOOK_CLI successfully set to: $socket_path"
            else
                echo "❌ Could not find a valid VS Code IPC socket to fix."
            fi
        fi
    fi
}

# Monitors dotfile changes and runs the monitor script in the background
run_dotfile_monitor() {
    local temp_file="/tmp/dotfiles_changed"
    local monitor_path="$HOME/dotfiles/monitor/main.sh"

    # 1. Check for change notification from previous sessions
    if [[ -f "$temp_file" ]]; then
        echo "🔍 Dotfile changes detected..."
        # Optional: Uncomment the next line to clear the notification after seeing it
        # rm "$temp_file"
    fi

    # 2. Start the monitor script if it exists
    if [[ -f "$monitor_path" ]]; then
        # Run in background. 
        # Using '&!' is Zsh specific for background + disown.
        # For cross-shell compatibility, we use '& disown'.
        /bin/bash "$monitor_path" >/dev/null 2>&1 & disown
    else
        echo "❌ Dotfile monitor script not found at: $monitor_path"
    fi
}

# PATH VARIABLE ADDITIONS
add-to-path "/usr/local/go/bin"
add-to-path "$(go env GOROOT)/bin"
add-to-path "$(go env GOPATH)/bin"

# Code Command Fixes
fix_vscode_tmux

# Run dotfile monitor
run_dotfile_monitor
