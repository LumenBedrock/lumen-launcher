# Lumen Launcher

A launcher for Minecraft: Bedrock Edition on Linux, built for the **Lumen** client (in-game menu, HUD modules,
server profiles with their own texture packs and module setups).

## Install (AppImage)

```
curl -L -o Lumen-Launcher.AppImage https://github.com/LumenBedrock/lumen-launcher/releases/latest/download/Lumen-Launcher-x86_64.AppImage
chmod +x Lumen-Launcher.AppImage
./Lumen-Launcher.AppImage
```

Then sign in with the Google account that owns Minecraft: Bedrock Edition, download a game version and press Play.
Your game, worlds and settings live in the visible folder `~/Lumen`. The Lumen client is installed there automatically
(a newer one inside a new AppImage replaces it the next time you start the launcher with the game closed).
The launcher tells you when a new release is out. Needs a desktop session with X11 or XWayland.

> If you use *AppImageLauncher* and nothing opens, see the note in `packaging/SHARE.md`.

## What you need to know

- **You must own Minecraft: Bedrock Edition.** The game is downloaded from Google Play with your account; no game files are shipped here.
- The bundled Lumen client is checked on game versions 1.26.33.1 and 1.26.50.4. Other versions can lack features or crash.
- The game engine (`mcpelauncher-client`) is an unmodified build of [minecraft-linux/mcpelauncher-manifest](https://github.com/minecraft-linux/mcpelauncher-manifest).

## Based on the Minecraft Linux Launcher

Lumen Launcher is a **modified version of the Minecraft Linux Launcher Qt UI**
([mcpelauncher-ui-manifest](https://github.com/minecraft-linux/mcpelauncher-ui-manifest) /
[mcpelauncher-ui-qt](https://github.com/minecraft-linux/mcpelauncher-ui-qt)) by the
[minecraft-linux](https://github.com/minecraft-linux) project, created by MrARM and maintained by ChristopherHX and
contributors. All credit for the launcher foundation (version management, Google Play handling, game launching) goes to them.
Upstream docs: https://minecraft-linux.github.io

Licensed under the **GNU GPL v3** like upstream, see `mcpelauncher-ui-qt/LICENSE`. The Lumen UI changes are in the
[lumen-launcher-ui](https://github.com/LumenBedrock/lumen-launcher-ui) repository (branch `lumen`), which is a submodule here.
This is an unofficial fork, not affiliated with or endorsed by upstream or Mojang.

## Build from source (Arch, Qt6)

```
git clone --recurse-submodules https://github.com/LumenBedrock/lumen-launcher
cd lumen-launcher
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build
scripts/run.sh
```

Needs `qt6-base qt6-declarative qt6-svg qt6-webengine qt6-5compat qt6-tools`. `packaging/` has the AppImage and Flatpak recipes.
