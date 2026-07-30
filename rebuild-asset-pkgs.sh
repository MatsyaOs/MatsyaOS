#!/bin/bash
# Rebuild asset packages with proper directory structure to avoid conflicts
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/pkg-version.sh"

REPO_DIR="${REPO_DIR:-/home/mister/matsyaos-repo/x86_64}"
MATSYA_ROOT="${MATSYA_ROOT:-$SCRIPT_DIR}"
BUILD_ROOT="/tmp/matsya-build"
arch="x86_64"

remove_old_pkg() {
    local name="$1"
    find "$REPO_DIR" -maxdepth 1 -type f -name "${name}-*.pkg.tar.zst" -delete 2>/dev/null || true
}

write_pkginfo() {
    local pkg_dir="$1" name="$2" ver_rel="$3" arch="$4"
    local size
    size=$(du -sb "$pkg_dir" --exclude=.PKGINFO --exclude=.MTREE 2>/dev/null | cut -f1 || echo 0)
    cat > "$pkg_dir/.PKGINFO" << PKGINFO
pkgname = $name
pkgver = $ver_rel
pkgdesc = MatsyaOS $name package
arch = $arch
builddate = $(date +%s)
size = $size
PKGINFO
}

pack_dir() {
    local pkg_dir="$1" name="$2" ver_rel="$3" arch="$4"
    local out="$REPO_DIR/${name}-${ver_rel}-${arch}.pkg.tar.zst"
    write_pkginfo "$pkg_dir" "$name" "$ver_rel" "$arch"
    remove_old_pkg "$name"
    ( cd "$pkg_dir" && tar -I zstd -cf "$out" .PKGINFO $(find . -mindepth 1 -maxdepth 1 ! -name .PKGINFO -printf '%P ') )
    echo "==> Packaged $name ${ver_rel} -> $(basename "$out")"
}

# ====== 1. Rebuild matsya-icons ======
name="matsya-icons"
read -r pkgver pkgrel < <(resolve_pkg_version "$MATSYA_ROOT/icons")
ver_rel="${pkgver}-${pkgrel}"
echo "==> Rebuilding $name $ver_rel..."
pkg_dir="$BUILD_ROOT/$name-pkg"
rm -rf "$pkg_dir"
mkdir -p "$pkg_dir/usr/share/icons"
cp -r "$MATSYA_ROOT/icons/Matsya" "$pkg_dir/usr/share/icons/"
cp -r "$MATSYA_ROOT/icons/Matsya-dark" "$pkg_dir/usr/share/icons/"
pack_dir "$pkg_dir" "$name" "$ver_rel" "any"
rm -rf "$pkg_dir"

# ====== 2. Rebuild matsya-gtk-themes ======
name="matsya-gtk-themes"
read -r pkgver pkgrel < <(resolve_pkg_version "$MATSYA_ROOT/gtk-themes")
ver_rel="${pkgver}-${pkgrel}"
echo "==> Rebuilding $name $ver_rel..."
pkg_dir="$BUILD_ROOT/$name-pkg"
rm -rf "$pkg_dir"
mkdir -p "$pkg_dir/usr/share/themes"
cp -r "$MATSYA_ROOT/gtk-themes/Matsya" "$pkg_dir/usr/share/themes/"
cp -r "$MATSYA_ROOT/gtk-themes/Matsya-dark" "$pkg_dir/usr/share/themes/"
cp -r "$MATSYA_ROOT/gtk-themes/Matsya-light" "$pkg_dir/usr/share/themes/"
pack_dir "$pkg_dir" "$name" "$ver_rel" "any"
rm -rf "$pkg_dir"

# ====== 3. Rebuild matsya-wallpappers ======
name="matsya-wallpappers"
read -r pkgver pkgrel < <(resolve_pkg_version "$MATSYA_ROOT/wallpappers")
ver_rel="${pkgver}-${pkgrel}"
echo "==> Rebuilding $name $ver_rel..."
pkg_dir="$BUILD_ROOT/$name-pkg"
rm -rf "$pkg_dir"
mkdir -p "$pkg_dir/usr/share/backgrounds/matsyaos"
cp -r "$MATSYA_ROOT/wallpappers/sources/." "$pkg_dir/usr/share/backgrounds/matsyaos/"
rm -f "$pkg_dir/usr/share/backgrounds/matsyaos/CMakeLists.txt"
pack_dir "$pkg_dir" "$name" "$ver_rel" "any"
rm -rf "$pkg_dir"

echo "=== Done rebuilding asset packages ==="
ls -lh "$REPO_DIR"/matsya-icons-*.pkg.tar.zst "$REPO_DIR"/matsya-gtk-themes-*.pkg.tar.zst "$REPO_DIR"/matsya-wallpappers-*.pkg.tar.zst
