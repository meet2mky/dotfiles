#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../installations/tools/all_in_one.sh"

create_symlink "$HOME/dotfiles/vscode/.vscode" ".vscode"

