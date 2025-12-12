#!/bin/bash

# Exit immediately if a command exits with a non-zero status/ encounters unset variable/ pipe failure.
set -euo pipefail

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../tools/all_in_one.sh"

sudo apt update >> /dev/null 2>&1 || true
sudo apt-get install -y "python3" >> /dev/null 2>&1