#!/bin/sh
# Lumen Launcher (Flatpak) entry point: keeps everything in the visible ~/Lumen folder and installs the bundled Lumen client.
LUMEN_HOME="$HOME/Lumen"
mkdir -p "$LUMEN_HOME/mods" "$XDG_DATA_HOME"
ln -sfn "$LUMEN_HOME" "$XDG_DATA_HOME/mcpelauncher"
BUNDLED=/app/share/lumen/liblumen.so
LIVE="$LUMEN_HOME/mods/liblumen.so"
REC="$LUMEN_HOME/mods/.lumen-bundled-md5"
# Install/update the bundled client, but never replace a client somebody installed locally (a dev build, or a newer one).
# The file is only replaced when it is missing, or still byte-identical to the bundled build installed last time, or (installs
# from before this check) a small stripped bundled build. Anything else is left alone. A replaced file is backed up.
if [ -f "$BUNDLED" ]; then
  NEWSUM="$(md5sum "$BUNDLED" | cut -d' ' -f1)"
  DO=0
  if [ ! -f "$LIVE" ]; then DO=1
  elif [ -f "$REC" ]; then
    [ "$(md5sum "$LIVE" | cut -d' ' -f1)" = "$(cat "$REC")" ] && [ "$NEWSUM" != "$(cat "$REC")" ] && DO=1
  elif [ "$(stat -c %s "$LIVE")" -lt 4000000 ] && [ "$NEWSUM" != "$(md5sum "$LIVE" | cut -d' ' -f1)" ]; then DO=1
  fi
  if [ "$DO" = 1 ]; then
    if ps -eo comm | grep -q mcpelauncher-cl; then
      echo "Lumen Launcher: newer Lumen client bundled, but the game is running" >&2
    else
      [ -f "$LIVE" ] && cp "$LIVE" "$LUMEN_HOME/mods/liblumen.so.bak"
      cp "$BUNDLED" "$LUMEN_HOME/mods/.liblumen.so.new" && mv "$LUMEN_HOME/mods/.liblumen.so.new" "$LIVE" && echo "$NEWSUM" > "$REC"
    fi
  fi
fi
# bundled upstream compat mod (patches libmaesdk/PlayFab); installed once, never overwrites an existing copy
UPD="$LUMEN_HOME/mods/mcpelauncher-updates/lumen-bundled/x86_64"
if [ ! -f "$UPD/libmcpelauncher-updates.so" ] && [ -d /app/share/lumen/updates-mod ]; then
  mkdir -p "$UPD" && cp -r /app/share/lumen/updates-mod/. "$UPD/"
fi
exec mcpelauncher-ui-qt "$@"
