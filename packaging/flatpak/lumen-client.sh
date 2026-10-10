#!/bin/bash
# Lumen Launcher (Flatpak) game engine wrapper: always loads the bundled upstream "mcpelauncher-updates" compatibility
# mod (patches libmaesdk/PlayFab for current Minecraft builds), in addition to whatever mod dirs the launcher passes.
MOD="$HOME/Lumen/mods/mcpelauncher-updates/lumen-bundled/x86_64"
if [ ! -f "$MOD/libmcpelauncher-updates.so" ] && [ -d /app/share/lumen/updates-mod ]; then
  mkdir -p "$MOD" && cp -r /app/share/lumen/updates-mod/. "$MOD/"
fi
REAL=/app/bin/mcpelauncher-client.real
if [ ! -f "$MOD/libmcpelauncher-updates.so" ]; then exec "$REAL" "$@"; fi

# does the mod list the launcher passed (-m dir1,dir2) already contain a working updates mod?
has_updates() {
  local IFS=, d
  for d in $1; do [ -f "${d%/}/libmcpelauncher-updates.so" ] && return 0; done
  return 1
}

args=()
seen_m=0
while [ $# -gt 0 ]; do
  case "$1" in
    -m|--mods)
      seen_m=1
      val="${2:-}"
      if has_updates "$val"; then args+=("$1" "$val"); else args+=("$1" "${val:+$val,}$MOD"); fi
      shift; [ $# -gt 0 ] && shift ;;
    --mods=*)
      seen_m=1
      val="${1#--mods=}"
      if has_updates "$val"; then args+=("$1"); else args+=("--mods=${val:+$val,}$MOD"); fi
      shift ;;
    *) args+=("$1"); shift ;;
  esac
done
[ "$seen_m" = 0 ] && args+=(-m "$MOD")
exec "$REAL" "${args[@]}"
