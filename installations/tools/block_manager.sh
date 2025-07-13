#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail

# --- Helper Functions ---
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1"
}

# A script to insert or remove a text block defined by markers in a file.

# --- Helper Function for Usage ---
usage() {
    echo "Usage: $0 FILE_PATH START_MARKER END_MARKER OP [ACTUAL_INSERT_TEXT]"
    echo "  OP: Must be 'INSERT' or 'REMOVE'."
    echo "  ACTUAL_INSERT_TEXT: Required only for the 'INSERT' operation."
    exit 1
}

# --- Argument Validation ---
if [[ "$#" -lt 4 || "$#" -gt 5 ]]; then
    log_error "nvalid number of arguments."
    usage
fi

FILE_PATH="$1"
START_MARKER="$2"
END_MARKER="$3"
OP=$(echo "$4" | tr '[:lower:]' '[:upper:]') # Make OP case-insensitive
ACTUAL_INSERT_TEXT="${5:-}"                  # Default to empty if not provided

# Validate that the file exists
if [[ ! -f "$FILE_PATH" ]]; then
    log_error "File not found at '$FILE_PATH'"
    exit 1
fi

# Validate that markers are single-line text
if [[ "$START_MARKER" == *$'\n'* || "$END_MARKER" == *$'\n'* ]]; then
    log_error "START_MARKER and END_MARKER must be single-line text."
    exit 1
fi

# --- Main Operation Logic ---
case "$OP" in
"INSERT")
    # Validate arguments for INSERT operation
    if [[ "$#" -ne 5 ]]; then
        log_error "5 arguments are required for the INSERT operation."
        usage
    fi
    if [[ -z "$ACTUAL_INSERT_TEXT" ]]; then
        log_error "ACTUAL_INSERT_TEXT cannot be empty for INSERT."
        exit 1
    fi
    # Append the block to the end of the file
    printf "\n%s%s%s\n" "$START_MARKER" "$ACTUAL_INSERT_TEXT" "$END_MARKER" >>"$FILE_PATH"
    log_info "✅ Block successfully inserted into '$FILE_PATH'."
    ;;

"REMOVE")
    # Validate arguments for REMOVE operation
    if [[ "$#" -ne 4 ]]; then
        log_error "4 arguments are required for the REMOVE operation."
        usage
    fi

    # Check for the presence of markers using grep (-F for fixed string, -q for quiet)
    start_found=$(
        grep -qF -- "$START_MARKER" "$FILE_PATH"
        echo $?
    )
    end_found=$(
        grep -qF -- "$END_MARKER" "$FILE_PATH"
        echo $?
    )

    if [[ $start_found -eq 0 && $end_found -eq 0 ]]; then
        # Both markers found: remove the block including markers
        # Escape special sed characters in markers to ensure they are treated literally
        escaped_start=$(printf '%s\n' "$START_MARKER" | sed -e 's/[\\/&.*^$[]/\\&/g')
        escaped_end=$(printf '%s\n' "$END_MARKER" | sed -e 's/[\\/&.*^$[]/\\&/g')

        # Use sed to delete the lines from START_MARKER to END_MARKER
        sed -i.bak "/$escaped_start/,/$escaped_end/d" "$FILE_PATH"
        log_info "✅ Block successfully removed from '$FILE_PATH'. Backup created: ${FILE_PATH}.bak"

    elif [[ $start_found -ne 0 && $end_found -ne 0 ]]; then
        # Neither marker found: do nothing, exit successfully
        log_info "✅ Markers not found. No changes made to '$FILE_PATH'."
        exit 0
    else
        # Only one marker found: fail with an error
        log_error "❌ Inconsistent state. Only one of the two markers was found. Aborting."
        exit 1
    fi
    ;;

*)
    log_error "❌ Invalid operation '$4'. Must be 'INSERT' or 'REMOVE'."
    usage
    ;;
esac

cleanup_empty_lines_awk() {
    local file_path="$1"

    if [[ -z "$file_path" ]]; then
        log_error "❌ No file path provided."
        return 1
    fi
    if [[ ! -f "$file_path" ]]; then
        log_error "❌ File not found at '$file_path'."
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    # awk script to print only the first of consecutive empty lines
    awk '!NF{if(c++<1)print} NF{c=0;print}' "$file_path" >"$temp_file"

    mv "$temp_file" "$file_path"
}

# Cleanup empty lines to keep config tidy.
if ! cleanup_empty_lines_awk "$FILE_PATH"; then
    log_error "❌ Unable to cleanup empty lines."
    exit 1
fi
exit 0
