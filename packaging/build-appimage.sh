#!/usr/bin/env bash
# Builds Lumen-Launcher-<version>-x86_64.AppImage from ../lumen-launcher (Qt6 build) and the Lumen client.
set -euo pipefail
cd "$(dirname "$0")"
SRC=../lumen-launcher
CLIENT="${LUMEN_CLIENT_SO:-../mcbe-qol/build-lumen/liblumen.so}"
ENGINE="${LUMEN_ENGINE_BIN:-../lumen-engine/bldc/mcpelauncher-client/mcpelauncher-client}"
VERSION="$(grep -m1 'LAUNCHER_VERSION_NAME' $SRC/mcpelauncher-ui-qt/CMakeLists.txt | sed -E 's/.*"([0-9.]+)".*/\1/')"
rm -rf AppDir out && mkdir -p out
DESTDIR="$PWD/AppDir" cmake --install $SRC/build --prefix /usr >/dev/null
rm -f AppDir/usr/share/applications/mcpelauncher-ui-qt.desktop
install -Dm755 assets/mcpelauncher-client AppDir/usr/bin/mcpelauncher-client
install -Dm755 assets/AppRun AppDir/AppRun
install -Dm755 "$ENGINE" AppDir/usr/lib/lumen/mcpelauncher-engine
mkdir -p AppDir/usr/share && cp -r ../lumen-engine/share/mcpelauncher AppDir/usr/share/
install -Dm644 "$CLIENT" AppDir/usr/share/lumen/liblumen.so
date +%s > AppDir/usr/share/lumen/VERSION
install -Dm644 $SRC/mcpelauncher-ui-qt/LICENSE AppDir/usr/share/doc/lumen-launcher/LICENSE
install -Dm644 $SRC/README.md AppDir/usr/share/doc/lumen-launcher/README.md
install -Dm644 $SRC/mcpelauncher-ui-qt/Resources/lumen-icon.svg AppDir/usr/share/icons/hicolor/scalable/apps/lumen-launcher.svg
export EXTRA_PLATFORM_PLUGINS=libqoffscreen.so NO_STRIP=1 QMAKE=qmake6 QML_SOURCES_PATHS="$PWD/$SRC/mcpelauncher-ui-qt/qml" LINUXDEPLOY_OUTPUT_VERSION="$VERSION" ARCH=x86_64
export PATH="$PWD/tools/bin:$PATH"
# helper libs only needed so the Qt plugin tool can resolve optional plugin dependencies (not shipped)
export LD_LIBRARY_PATH="$PWD/extra/usr/lib:${LD_LIBRARY_PATH:-}"
./tools/linuxdeploy-x86_64.ex/AppRun --appdir AppDir --plugin qt \
  --desktop-file assets/lumen-launcher.desktop --icon-file assets/lumen-icon-256.png --executable AppDir/usr/bin/mcpelauncher-ui-qt --executable AppDir/usr/lib/lumen/mcpelauncher-engine
# the AppRun written above is ours; linuxdeploy keeps an existing one
./tools/appimagetool-x86_64.ex/AppRun --no-appstream AppDir "out/Lumen-Launcher-$VERSION-x86_64.AppImage"
# keep a master copy outside the project: AppImageLauncher MOVES any AppImage you "integrate" out of its folder
mkdir -p "$HOME/Lumen-Releases"
install -m755 "out/Lumen-Launcher-$VERSION-x86_64.AppImage" "$HOME/Lumen-Releases/"
cp -f SHARE.md "$HOME/Lumen-Releases/SHARE.md"
ls -la out "$HOME/Lumen-Releases"
