#!/bin/bash

# multihost-utils updater
# Pulls latest changes and re-installs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Updating multihost-utils..."

cd "$SCRIPT_DIR"
git pull

"$SCRIPT_DIR/install.sh"
