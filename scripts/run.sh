#!/usr/bin/env bash
# Run the locally built Lumen launcher. Game data lives in the visible folder ~/Lumen
# (versions, mods, worlds, lumen.conf ...); the launcher's own settings live in
# ~/.config/lumen-launcher and ~/.cache/lumen-launcher.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LUMEN_HOME="${LUMEN_HOME:-$HOME/Lumen}"
if ps -eo comm | grep -q mcpelauncher-cl; then echo "game already running" >&2; exit 1; fi
mkdir -p "$HOME/.local/share/lumen-launcher" "$LUMEN_HOME"
ln -sfn "$LUMEN_HOME" "$HOME/.local/share/lumen-launcher/mcpelauncher"
# our own build of the game engine (../lumen-engine); LUMEN_USE_FLATPAK=1 falls back to the flatpak's
ENGINE_BIN="$ROOT/../lumen-engine/bldc/mcpelauncher-client/mcpelauncher-client"
if [ -x "$ENGINE_BIN" ]; then
  export LUMEN_ENGINE="${LUMEN_ENGINE:-$ENGINE_BIN}"
  export LUMEN_MSA_DIR="${LUMEN_MSA_DIR:-$ROOT/../lumen-msa/stage}"
  # the engine looks up its data files (libsqliteX.so, gamecontrollerdb.txt) in <XDG_DATA_DIRS>/mcpelauncher
  export XDG_DATA_DIRS="$ROOT/../lumen-engine/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
fi
export PATH="$ROOT/scripts:$PATH"
export XDG_DATA_HOME="$HOME/.local/share/lumen-launcher" XDG_CONFIG_HOME="$HOME/.config/lumen-launcher" XDG_CACHE_HOME="$HOME/.cache/lumen-launcher"
export QT_QPA_PLATFORM=xcb  # runs via XWayland
exec "$ROOT/build/mcpelauncher-ui-qt/mcpelauncher-ui-qt" "$@"
