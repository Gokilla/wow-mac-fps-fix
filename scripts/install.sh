#!/bin/bash
# Builds wow-composite from source and installs it as a per-user LaunchAgent.
set -euo pipefail

LABEL="io.github.gokilla.wow-composite"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="$HOME/.local/bin"
BIN="$BIN_DIR/wow-composite"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

if ! command -v swiftc >/dev/null 2>&1; then
  echo "swiftc not found. Install Command Line Tools first:  xcode-select --install" >&2
  exit 1
fi

mkdir -p "$BIN_DIR" "$HOME/Library/LaunchAgents"
echo "→ Building $BIN"
swiftc -O -o "$BIN" "$REPO_DIR/src/wow-composite.swift"

echo "→ Installing LaunchAgent $PLIST"
cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>$BIN</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>ProcessType</key><string>Background</string>
</dict>
</plist>
PLIST

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "✓ Installed. It starts at login and only shows its 2×2 px window while WoW is running."
echo "  Check in game with Metal HUD: it should say 'Composited'.  Uninstall: scripts/uninstall.sh"
