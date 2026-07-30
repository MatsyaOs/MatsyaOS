#!/bin/bash
# Shared package version helpers for MatsyaOS builds.
# Resolves pkgver/pkgrel from PKGBUILD, CMakeLists, git history, or a release default.

# Default release line when nothing else is available.
# Bump this when cutting a new MatsyaOS package release.
MATSYA_DEFAULT_PKGVER="${MATSYA_DEFAULT_PKGVER:-2.0.0}"
MATSYA_DEFAULT_PKGREL="${MATSYA_DEFAULT_PKGREL:-1}"

# Optional global override: MATSYA_PKGVER / MATSYA_PKGREL force every package.
# Optional date stamp: MATSYA_VERSION_DATE=1 appends .YYYYMMDD to pkgver.

_strip_quotes() {
    local v="$1"
    v="${v%%#*}"
    v="${v// /}"
    v="${v//\'/}"
    v="${v//\"/}"
    printf '%s' "$v"
}

# Read a simple KEY=value assignment from a PKGBUILD (first match).
_pkgbuild_get() {
    local file="$1" key="$2"
    [ -f "$file" ] || return 1
    local line
    line=$(grep -E "^${key}=" "$file" | head -1) || return 1
    line="${line#*=}"
    _strip_quotes "$line"
}

# Best-effort CMake project version (project(... VERSION x.y) or set(FOO_VERSION ...)).
_cmake_version() {
    local dir="$1"
    local cmake="$dir/CMakeLists.txt"
    [ -f "$cmake" ] || return 1
    local ver
    ver=$(grep -Eo 'VERSION[[:space:]]+[0-9]+(\.[0-9]+)+' "$cmake" | head -1 | awk '{print $2}')
    if [ -n "$ver" ]; then
        printf '%s' "$ver"
        return 0
    fi
    ver=$(grep -Eo 'set\([A-Za-z0-9_]*VERSION[[:space:]]+[0-9]+(\.[0-9]+)+' "$cmake" | head -1 | grep -Eo '[0-9]+(\.[0-9]+)+' | head -1)
    if [ -n "$ver" ]; then
        printf '%s' "$ver"
        return 0
    fi
    return 1
}

# Git-based fallback: 1.1.r<count>.g<short>
_git_version() {
    local dir="$1"
    local count hash
    if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 1
    fi
    count=$(git -C "$dir" rev-list --count HEAD 2>/dev/null || echo 0)
    hash=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null || echo unknown)
    # Ensure numeric sort beats old 1.0 packages
    printf '%s.r%s.g%s' "$MATSYA_DEFAULT_PKGVER" "$count" "$hash"
}

# Resolve version for a source directory.
# Prints: pkgver  pkgrel   (two words)
# Usage: read -r pkgver pkgrel < <(resolve_pkg_version /path/to/src [fallback-name])
resolve_pkg_version() {
    local dir="${1:-.}"
    local pkgver="" pkgrel=""

    if [ -n "${MATSYA_PKGVER:-}" ]; then
        pkgver="$MATSYA_PKGVER"
        pkgrel="${MATSYA_PKGREL:-1}"
    elif [ -f "$dir/PKGBUILD" ]; then
        pkgver=$(_pkgbuild_get "$dir/PKGBUILD" pkgver || true)
        pkgrel=$(_pkgbuild_get "$dir/PKGBUILD" pkgrel || true)
        # Normalize bare integers (pkgver=1) to dotted release line
        if [[ "$pkgver" =~ ^[0-9]+$ ]]; then
            pkgver="${MATSYA_DEFAULT_PKGVER}"
        fi
        # Old 1 / 1.0 lines get bumped to the current default release
        if [ "$pkgver" = "1" ] || [ "$pkgver" = "1.0" ] || [ "$pkgver" = "0.7" ]; then
            pkgver="$MATSYA_DEFAULT_PKGVER"
        fi
        pkgrel="${pkgrel:-$MATSYA_DEFAULT_PKGREL}"
    elif pkgver=$(_cmake_version "$dir"); then
        pkgrel="$MATSYA_DEFAULT_PKGREL"
    elif pkgver=$(_git_version "$dir"); then
        pkgrel="$MATSYA_DEFAULT_PKGREL"
    else
        pkgver="$MATSYA_DEFAULT_PKGVER"
        pkgrel="$MATSYA_DEFAULT_PKGREL"
    fi

    if [ "${MATSYA_VERSION_DATE:-0}" = "1" ]; then
        # Avoid double-dating
        if [[ ! "$pkgver" =~ [0-9]{8} ]]; then
            pkgver="${pkgver}.$(date +%Y%m%d)"
        fi
    fi

    # Final safety: never emit empty / 1.0 when default is higher
    if [ -z "$pkgver" ] || [ "$pkgver" = "1.0" ] || [ "$pkgver" = "1" ]; then
        pkgver="$MATSYA_DEFAULT_PKGVER"
    fi
    pkgrel="${pkgrel:-$MATSYA_DEFAULT_PKGREL}"

    printf '%s %s\n' "$pkgver" "$pkgrel"
}

# Full epoch-less pacman version string: ver-rel
pkg_version_string() {
    local dir="$1"
    local pkgver pkgrel
    read -r pkgver pkgrel < <(resolve_pkg_version "$dir")
    printf '%s-%s\n' "$pkgver" "$pkgrel"
}

# Package filename stem: name-ver-rel-arch
pkg_filename() {
    local name="$1"
    local dir="$2"
    local arch="${3:-x86_64}"
    local ver
    ver=$(pkg_version_string "$dir")
    printf '%s-%s-%s.pkg.tar.zst\n' "$name" "$ver" "$arch"
}
