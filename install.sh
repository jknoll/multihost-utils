#!/bin/bash

# multihost-utils installer
# Symlinks commands to ~/.claude/commands/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing multihost-utils commands..."

mkdir -p ~/.claude/commands

for cmd in "$SCRIPT_DIR/commands"/*.md; do
  if [ -f "$cmd" ]; then
    basename=$(basename "$cmd")
    ln -sf "$cmd" ~/.claude/commands/"$basename"
    echo "  ~/.claude/commands/$basename -> $cmd"
  fi
done

echo ""
echo "multihost-utils commands installed:"
for cmd in "$SCRIPT_DIR/commands"/*.md; do
  if [ -f "$cmd" ]; then
    basename=$(basename "$cmd" .md)
    echo "  /$basename"
  fi
done
echo ""
echo "Done!"
