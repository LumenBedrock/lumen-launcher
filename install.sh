#!/usr/bin/env bash
# Lumen Launcher installer: installs/updates the Flatpak from the signed Lumen repository (it brings everything it needs) and starts it.
# Usage: curl -fsSL https://raw.githubusercontent.com/LumenBedrock/lumen-launcher/main/install.sh | bash
# No sudo is used. Your game, worlds and settings in ~/Lumen are never touched.
set -euo pipefail

APP=io.github.LumenBedrock.LumenLauncher
REMOTE=lumen-launcher
REPO_FILE=https://lumenbedrock.github.io/lumen-flatpak/lumen-launcher.flatpakrepo
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

echo "Setting up the software sources (Flathub for the runtime, the Lumen repository for the launcher)..."
flatpak remote-add --user --if-not-exists flathub "$FLATHUB"
flatpak remote-add --user --if-not-exists "$REMOTE" "$REPO_FILE"

LOG="$(mktemp)"
trap 'rm -f "$LOG"' EXIT

# a copy installed from somewhere else (an older bundle) is replaced; ~/Lumen is outside the app and stays
if flatpak info --user "$APP" >/dev/null 2>&1; then
  ORIGIN="$(flatpak info --user --show-origin "$APP" 2>/dev/null || true)"
  if [ "$ORIGIN" != "$REMOTE" ]; then
    echo "Switching to the Lumen repository..."
    flatpak uninstall --user -y "$APP" >/dev/null 2>&1 || true
  fi
fi

if flatpak info --user "$APP" >/dev/null 2>&1; then
  echo "Updating Lumen Launcher..."
  if flatpak update --user -y "$APP" >"$LOG" 2>&1; then
    echo "Up to date."
  else
    cat "$LOG" >&2
    exit 1
  fi
else
  echo "Installing Lumen Launcher (this also downloads the required runtime on the first install, a few hundred MB)..."
  if flatpak install --user -y "$REMOTE" "$APP" >"$LOG" 2>&1; then
    echo "Installed."
  else
    cat "$LOG" >&2
    exit 1
  fi
fi

if [ "${LUMEN_NO_START:-0}" = 1 ]; then exit 0; fi
echo "Done. Starting Lumen Launcher (next time: flatpak run $APP, or use your app menu)."
exec flatpak run "$APP"
