#!/bin/bash
set -e

REPO_DIR="/home/mister/Downloads/repo/x86_64"
mkdir -p "$REPO_DIR"

build_pkg() {
    local dir="$1"
    echo "==> Building $dir..."
    cd "/home/mister/MatsyaOS/$dir"
    rm -rf build
    mkdir build && cd build
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_BUILD_TYPE=Release ..
    make -j$(nproc)
    # Install into DESTDIR for packaging
    DESTDIR="$REPO_DIR/$dir-pkg" make install
    cd ..
    rm -rf build
    echo "==> $dir built successfully"
}

# Build order (dependencies first)
build_pkg "libmatsya"
build_pkg "matsyaui"
build_pkg "icons"
build_pkg "gtk-themes"
build_pkg "wallpappers"
build_pkg "qt-plugins"
build_pkg "daemon"
build_pkg "core"
build_pkg "kwin-plugins"
build_pkg "screenlocker"
build_pkg "launcher"
build_pkg "dock"
build_pkg "statusbar"
build_pkg "appmotor"
build_pkg "calculator"
build_pkg "terminal"
build_pkg "texteditor"
build_pkg "filemanager"
build_pkg "screenshot"
build_pkg "debinstaller"
build_pkg "matsya-settings"
build_pkg "matsya-updater"
build_pkg "sddm-theme"

# Build pacman database
cd "$REPO_DIR"
repo-add matsyaos.db.tar.gz *.pkg.tar.* 2>/dev/null || true
echo "==> All packages built and repo database updated"
