#!/bin/bash
# Build the MatsyaOS ISO inside a container.
# Packages are fetched ONLY from the GitHub matsyaos-repo (no local file:// mirrors).
set -euo pipefail

CONTAINER_NAME="matsyaos-iso-builder"
IMAGE_NAME="localhost/matsyaos-builder:latest"
PACMAN_CONF="/home/mister/MatsyaOS/matsya-iso/profiles/matsya/pacman.conf"

echo "=== MatsyaOS ISO build (container, GitHub packages only) ==="

if [ ! -f "$PACMAN_CONF" ]; then
    echo "ERROR: missing $PACMAN_CONF"
    exit 1
fi

if grep -qE '^\s*Server\s*=\s*file://' "$PACMAN_CONF"; then
    echo "ERROR: pacman.conf still references a local file:// package repo."
    echo "ISO builds must use only GitHub. Fix matsya-iso/profiles/matsya/pacman.conf:"
    grep -nE 'Server\s*=' "$PACMAN_CONF" || true
    exit 1
fi

if ! grep -qE 'raw\.githubusercontent\.com/MatsyaOs/matsyaos-repo|github\.com/MatsyaOs/matsyaos-repo' "$PACMAN_CONF"; then
    echo "ERROR: pacman.conf has no MatsyaOs/matsyaos-repo GitHub Server entry."
    exit 1
fi

echo "Package source(s):"
grep -E '^\s*Server\s*=' "$PACMAN_CONF" || true

# Ensure builder image exists (reuse if present)
if ! echo mister | sudo -S podman image exists "$IMAGE_NAME" 2>/dev/null; then
    echo "Builder image missing; building via build-container.sh (packages only)..."
    BUILD_ISO=0 bash /home/mister/MatsyaOS/build-container.sh
fi

echo mister | sudo -S podman run --privileged --rm --replace --name "$CONTAINER_NAME" \
    -v /home/mister/MatsyaOS:/workspace/MatsyaOS:z \
    "$IMAGE_NAME" \
    /bin/bash -c '
set -euo pipefail

WORK_DIR="/workspace/MatsyaOS/matsya-iso/work"
OUT_DIR="/workspace/MatsyaOS/out"
mkdir -p "$OUT_DIR"

# Confirm runtime pacman.conf is GitHub-only
CONF="/workspace/MatsyaOS/matsya-iso/profiles/matsya/pacman.conf"
if grep -qE "^\s*Server\s*=\s*file://" "$CONF"; then
    echo "ERROR: file:// server still present in profile pacman.conf"
    exit 1
fi

echo "=== Building MatsyaOS ISO (packages from GitHub) ==="
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" \
    /workspace/MatsyaOS/matsya-iso/profiles/matsya

echo "=== ISO BUILD COMPLETE ==="
ls -lh "$OUT_DIR"/
'

echo "=== Done. ISO (if produced) in /home/mister/MatsyaOS/out/ ==="
