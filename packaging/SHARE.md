# Lumen Launcher (AppImage)

1. Download `Lumen-Launcher-<version>-x86_64.AppImage`, then `chmod +x` it and run it.
2. Sign in with the Google account that owns Minecraft, download a game version, press Play.

Your game, worlds and settings live in the visible folder `~/Lumen`. The Lumen client (`liblumen.so`) is installed there
automatically; a newer one inside a new AppImage replaces it the next time you start the launcher with the game closed.

Lumen Launcher is a modified version of the Minecraft Linux Launcher (https://github.com/minecraft-linux/mcpelauncher-ui-manifest,
maintained by ChristopherHX and contributors), licensed under the GNU GPL v3. Source and licence text are inside the AppImage
(usr/share/doc/lumen-launcher).

The game engine is bundled. If it ever fails on your system, `LUMEN_USE_FLATPAK=1` runs the AppImage with the flatpak engine
(`flatpak install flathub io.mrarm.mcpelauncher`) instead.

## AppImageLauncher shows "Integrate and run" but nothing opens

AppImageLauncher (an optional desktop helper) crashes in sessions that set `QT_QPA_PLATFORM=wayland` because it is built on Qt5.
Run the AppImage with `APPIMAGELAUNCHER_DISABLE=1 ./Lumen-Launcher-x86_64.AppImage`, or install `qt5-wayland`.
