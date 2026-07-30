#!/bin/bash
# Build MatsyaOS packages (and optionally the ISO) inside a container.
# Package versions come from PKGBUILDs via scripts/pkg-version.sh (default 1.1).
set -euo pipefail

CONTAINER_NAME="matsyaos-builder"
IMAGE_NAME="localhost/matsyaos-builder:latest"
BUILD_ISO="${BUILD_ISO:-0}"
UPLOAD_REPO="${UPLOAD_REPO:-0}"

echo "=== Building MatsyaOS Build Container ==="

cat > /tmp/Containerfile.build << 'EOF'
FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm \
        base-devel git cmake extra-cmake-modules ninja pkgconf \
        qt6-base qt6-declarative qt6-tools qt6-svg qt6-sensors qt6-shadertools qt6-5compat \
        bluez-qt \
        kconfig kconfigwidgets kcoreaddons kguiaddons kwindowsystem kwayland \
        kdecoration kio kidletime kdeclarative kwin solid \
        syntax-highlighting \
        networkmanager-qt modemmanager-qt \
        kscreen qqc2-desktop-style taglib \
        polkit polkit-qt6 \
        libkscreen libqtxdg libdbusmenu-lxqt \
        accountsservice \
        freetype2 fontconfig \
        libxcursor libpulse libxcb libxtst \
        xorg-server-devel xf86-input-libinput xf86-input-synaptics vulkan-headers vulkan-icd-loader \
        archiso arch-install-scripts \
        libisoburn squashfs-tools erofs-utils dosfstools mtools grub syslinux edk2-shell pacman-contrib zstd \
        openssh rsync sudo && \
    pacman -Scc --noconfirm

RUN useradd -m -G wheel builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /workspace
EOF

echo "Building container image..."
podman build -t "$IMAGE_NAME" -f /tmp/Containerfile.build /tmp

echo "=== Running package build inside container ==="

podman run --privileged --rm --replace --name "$CONTAINER_NAME" \
    -v /home/mister/MatsyaOS:/workspace/MatsyaOS:z \
    -v /home/mister/matsyaos-repo:/workspace/repo:z \
    -e MATSYA_DEFAULT_PKGVER="${MATSYA_DEFAULT_PKGVER:-1.1}" \
    -e MATSYA_DEFAULT_PKGREL="${MATSYA_DEFAULT_PKGREL:-1}" \
    -e MATSYA_PKGVER="${MATSYA_PKGVER:-}" \
    -e MATSYA_PKGREL="${MATSYA_PKGREL:-}" \
    -e MATSYA_VERSION_DATE="${MATSYA_VERSION_DATE:-0}" \
    -e BUILD_ISO="$BUILD_ISO" \
    "$IMAGE_NAME" \
    /bin/bash -c '
set -euo pipefail
cd /workspace/MatsyaOS

export REPO_DIR="/workspace/repo/x86_64"
export MATSYA_ROOT="/workspace/MatsyaOS"
export BUILD_ROOT="/tmp/matsya-build"
mkdir -p "$REPO_DIR"

# Build all packages with proper versioning
bash /workspace/MatsyaOS/build-all.sh

echo "=== Packages ready in $REPO_DIR ==="
ls -lh "$REPO_DIR"/*.pkg.tar.zst

if [ "${BUILD_ISO:-0}" = "1" ]; then
    echo "=== Building MatsyaOS ISO ==="
    rm -rf /tmp/iso-work
    mkdir -p /workspace/MatsyaOS/out
    mkarchiso -v -w /tmp/iso-work -o /workspace/MatsyaOS/out \
        /workspace/MatsyaOS/matsya-iso/profiles/matsya
    echo "=== ISO BUILD COMPLETE ==="
    ls -lh /workspace/MatsyaOS/out/
fi
'

echo "=== Build complete ==="
echo "Packages: /home/mister/matsyaos-repo/x86_64/"
if [ "$BUILD_ISO" = "1" ]; then
    echo "ISO output: /home/mister/MatsyaOS/out/"
fi
echo ""
echo "To upload packages to GitHub:"
echo "  bash /home/mister/MatsyaOS/scripts/upload-repo.sh"
