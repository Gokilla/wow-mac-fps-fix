#!/bin/bash
# Removes the wow-composite LaunchAgent and binary.
set -uo pipefail
LABEL="io.github.gokilla.wow-composite"
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/$LABEL.plist" "$HOME/.local/bin/wow-composite"
echo "✓ wow-composite removed."
