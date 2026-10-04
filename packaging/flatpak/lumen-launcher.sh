#!/bin/sh
# Lumen Launcher (Flatpak) entry point: keeps everything in the visible ~/Lumen folder and installs the bundled Lumen client.
LUMEN_HOME="$HOME/Lumen"
mkdir -p "$LUMEN_HOME/mods" "$XDG_DATA_HOME"
ln -sfn "$LUMEN_HOME" "$XDG_DATA_HOME/mcpelauncher"
BUNDLED=/app/share/lumen/liblumen.so
if [ -f "$BUNDLED" ]; then
  NEW="$(cat /app/share/lumen/VERSION 2>/dev/null || echo 0)"
  OLD="$(cat "$LUMEN_HOME/mods/.lumen-version" 2>/dev/null || echo 0)"
  if [ "$NEW" -gt "$OLD" ] 2>/dev/null; then
    if ps -eo comm | grep -q mcpelauncher-cl; then
      echo "Lumen Launcher: newer Lumen client bundled, but the game is running" >&2
    else
      cp "$BUNDLED" "$LUMEN_HOME/mods/.liblumen.so.new" && mv "$LUMEN_HOME/mods/.liblumen.so.new" "$LUMEN_HOME/mods/liblumen.so" && echo "$NEW" > "$LUMEN_HOME/mods/.lumen-version"
    fi
  fi
fi
exec mcpelauncher-ui-qt "$@"
