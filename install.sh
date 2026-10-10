#!/usr/bin/env bash
# Lumen Launcher installer: installs the Flatpak (it brings everything it needs) and starts it.
# Usage: curl -fsSL https://raw.githubusercontent.com/LumenBedrock/lumen-launcher/main/install.sh | bash
# No sudo is used. The only file this script ever deletes is its own download in /tmp.
set -euo pipefail

APP=io.github.LumenBedrock.LumenLauncher
URL=https://github.com/LumenBedrock/lumen-launcher/releases/latest/download/Lumen-Launcher.flatpak
FLATHUB=https://dl.flathub.org/repo/flathub.flatpakrepo

if ! command -v flatpak >/dev/null 2>&1; then
  echo "Flatpak is not installed. Install it once, then run this command again:"
  echo "  Ubuntu / Linux Mint / Debian:  sudo apt install flatpak"
  echo "  Fedora:                        sudo dnf install flatpak"
  echo "  Arch / Manjaro:                sudo pacman -S flatpak"
  echo "  openSUSE:                      sudo zypper install flatpak"
  exit 1
fi

if [ "$(uname -m)" != "x86_64" ]; then
  echo "Lumen Launcher is only built for x86_64 (64-bit Intel/AMD) PCs." >&2
  exit 1
fi

# the old, failed AppImage download is only removed when it is clearly that file (an AppImage, not running)
OLD="$HOME/Lumen-Launcher.AppImage"
if [ -f "$OLD" ] && [ -x "$OLD" ] && ! pgrep -f "$OLD" >/dev/null 2>&1; then
  echo "Removing the old Lumen-Launcher.AppImage download..."
  rm -f -- "$OLD"
fi

echo "Setting up Flathub (the source of the runtime Lumen Launcher needs)..."
flatpak remote-add --user --if-not-exists flathub "$FLATHUB"

TMP="$(mktemp -d)"
trap 'rm -f "$TMP/Lumen-Launcher.flatpak"; rmdir "$TMP" 2>/dev/null || true' EXIT

echo "Downloading Lumen Launcher..."
if [ -t 2 ]; then PROG=--progress-bar; else PROG=-sS; fi
curl -fL $PROG -o "$TMP/Lumen-Launcher.flatpak" "$URL"

echo "Installing (this also downloads the required runtime on the first install, a few hundred MB)..."
# an identical build that is already installed is not an error; your game data in ~/Lumen is never touched
if flatpak install --user -y --reinstall "$TMP/Lumen-Launcher.flatpak" >"$TMP/install.log" 2>&1; then
  echo "Installed."
elif grep -q "already installed" "$TMP/install.log"; then
  echo "Already up to date."
else
  cat "$TMP/install.log" >&2
  exit 1
fi
rm -f "$TMP/install.log"

rm -f "$TMP/Lumen-Launcher.flatpak"; rmdir "$TMP" 2>/dev/null || true
echo "Done. Starting Lumen Launcher (next time: flatpak run $APP, or use your app menu)."
exec flatpak run "$APP"
