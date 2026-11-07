#!/bin/bash
# Toggle Apple's Metal Performance HUD for all Metal apps (shows FPS, GPU time, Direct/Composited).
# Usage: scripts/metal-hud.sh on|off   — restart the game afterwards.
case "${1:-}" in
  on)  defaults write -g MetalForceHudEnabled -bool YES && echo "Metal HUD: on" ;;
  off) defaults delete -g MetalForceHudEnabled 2>/dev/null; echo "Metal HUD: off" ;;
  *)   echo "usage: $0 on|off"; exit 1 ;;
esac
