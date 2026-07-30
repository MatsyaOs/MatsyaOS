#!/bin/bash
# Script to publish/update all MatsyaOS packages to AUR
# Ensure your SSH key is added to your AUR account at https://aur.archlinux.org/account/edit

set -e

BASE_DIR="/home/mister/MatsyaOS"
AUR_TMP_DIR="/tmp/matsya-aur-build"

mkdir -p "$AUR_TMP_DIR"

echo "=== Processing PKGBUILDs in $BASE_DIR ==="

find "$BASE_DIR" -maxdepth 2 -name "PKGBUILD" | while read -r pkgbuild; do
    dir=$(dirname "$pkgbuild")

    # Regenerate .SRCINFO
    if ! (cd "$dir" && makepkg --printsrcinfo > .SRCINFO 2>/dev/null); then
        echo "Warning: Could not generate .SRCINFO for $dir. Skipping."
        continue
    fi

    pkgname=$(grep -E "^pkgname = " "$dir/.SRCINFO" | head -n1 | awk '{print $3}')

    if [ -z "$pkgname" ]; then
        echo "Skipping $dir: no valid pkgname found."
        continue
    fi

    echo ""
    echo "========================================"
    echo "Processing AUR package: $pkgname (from $dir)"
    echo "========================================"

    TARGET_DIR="$AUR_TMP_DIR/$pkgname"
    rm -rf "$TARGET_DIR"

    echo "Cloning AUR repository for $pkgname..."
    if ! git clone "ssh://aur@aur.archlinux.org/${pkgname}.git" "$TARGET_DIR" 2>/dev/null; then
        echo "AUR repository ${pkgname} does not exist yet on AUR or clone failed."
        echo "Attempting initial push setup for ${pkgname}..."
        mkdir -p "$TARGET_DIR"
        cd "$TARGET_DIR"
        git init
        git checkout -b master 2>/dev/null || true
        git remote add origin "ssh://aur@aur.archlinux.org/${pkgname}.git"
    fi

    # Copy PKGBUILD and .SRCINFO
    cp "$dir/PKGBUILD" "$TARGET_DIR/"
    cp "$dir/.SRCINFO" "$TARGET_DIR/"

    # Copy optional patch, install, or hook files if present
    shopt -s nullglob
    for f in "$dir"/*.install "$dir"/*.patch "$dir"/*.hook "$dir"/*.default "$dir"/*.cfg; do
        if [ -f "$f" ]; then
            cp "$f" "$TARGET_DIR/"
        fi
    done
    shopt -u nullglob

    cd "$TARGET_DIR"
    git add .
    if git diff --staged --quiet; then
        echo "No changes for $pkgname."
    else
        git commit -m "Update AUR package $pkgname"
        echo "Pushing $pkgname to AUR..."
        git push -u origin master || echo "Failed to push $pkgname (Check if package exists on AUR or permissions)."
    fi
done

echo ""
echo "=== All packages processed ==="
