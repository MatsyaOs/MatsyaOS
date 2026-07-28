#!/bin/bash
set -e

REPO_DIR="/home/mister/matsyaos-repo/x86_64"
mkdir -p "$REPO_DIR"
BUILD_ROOT="/tmp/matsya-build"
mkdir -p "$BUILD_ROOT"

build_cmake_pkg() {
    local name="$1"
    local dir="$2"
    local pkgver="$3"
    echo "==> Building $name from $dir..."
    
    local build_dir="$BUILD_ROOT/$name-build"
    local pkg_dir="$BUILD_ROOT/$name-pkg"
    rm -rf "$build_dir" "$pkg_dir"
    mkdir -p "$build_dir"
    
    cd "$dir"
    cmake -DCMAKE_INSTALL_PREFIX=/usr \
          -DCMAKE_BUILD_TYPE=Release \
          -B "$build_dir" \
          -S "$dir"
    
    cmake --build "$build_dir" -j$(nproc)
    
    DESTDIR="$pkg_dir" cmake --install "$build_dir"
    
    # Create .pkg.tar.zst package
    cd "$pkg_dir"
    tar -czf "$REPO_DIR/$name-${pkgver}-1-x86_64.pkg.tar.zst" -- *
    
    echo "==> $name packaged"
}

# Build foundation libraries
build_cmake_pkg "libmatsya" "/home/mister/MatsyaOS/libmatsya" "1.0"
build_cmake_pkg "matsyaui" "/home/mister/MatsyaOS/matsyaui" "1.0"

# Build core components
build_cmake_pkg "matsya-daemon" "/home/mister/MatsyaOS/daemon" "1.0"
build_cmake_pkg "matsya-core" "/home/mister/MatsyaOS/core" "1.0"
build_cmake_pkg "matsya-kwin-plugins" "/home/mister/MatsyaOS/kwin-plugins" "1.0"
build_cmake_pkg "matsya-screenlocker" "/home/mister/MatsyaOS/screenlocker" "1.0"

# Build apps
build_cmake_pkg "matsya-launcher" "/home/mister/MatsyaOS/launcher" "1.0"
build_cmake_pkg "matsya-dock" "/home/mister/MatsyaOS/dock" "1.0"
build_cmake_pkg "matsya-statusbar" "/home/mister/MatsyaOS/statusbar" "1.0"
build_cmake_pkg "matsya-appmotor" "/home/mister/MatsyaOS/appmotor" "1.0"
build_cmake_pkg "matsya-calculator" "/home/mister/MatsyaOS/calculator" "1.0"
build_cmake_pkg "matsya-terminal" "/home/mister/MatsyaOS/terminal" "1.0"
build_cmake_pkg "matsya-texteditor" "/home/mister/MatsyaOS/texteditor" "1.0"
build_cmake_pkg "matsya-filemanager" "/home/mister/MatsyaOS/filemanager" "1.0"
build_cmake_pkg "matsya-screenshot" "/home/mister/MatsyaOS/screenshot" "1.0"
build_cmake_pkg "matsya-debinstaller" "/home/mister/MatsyaOS/debinstaller" "1.0"
build_cmake_pkg "matsya-settings" "/home/mister/MatsyaOS/matsya-settings" "1.0"
build_cmake_pkg "matsya-updater" "/home/mister/MatsyaOS/matsya-updater" "1.0"
build_cmake_pkg "matsya-qt-plugins" "/home/mister/MatsyaOS/qt-plugins" "1.0"
build_cmake_pkg "matsya-sddm-theme" "/home/mister/MatsyaOS/sddm-theme" "1.0"

# Build asset-only packages (icons, themes, wallpapers)
for asset in icons gtk-themes wallpappers; do
    echo "==> Packaging $asset..."
    pkg_dir="$BUILD_ROOT/$asset-pkg"
    rm -rf "$pkg_dir"
    dst="$pkg_dir/usr/share"
    mkdir -p "$dst"
    cp -r "/home/mister/MatsyaOS/$asset"/* "$dst/" 2>/dev/null || true
    cd "$pkg_dir"
    tar -czf "$REPO_DIR/matsya-$asset-1.0-1-x86_64.pkg.tar.zst" -- *
done

# Build pacman database
cd "$REPO_DIR"
repo-add matsyaos.db.tar.gz *.pkg.tar.zst 2>/dev/null || true

echo ""
echo "============================================"
echo "All packages built and repo database updated"
echo "Packages in: $REPO_DIR"
echo "============================================"
