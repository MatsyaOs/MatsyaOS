# MatsyaOS

MatsyaOS is an Arch Linux-based distribution featuring the Matsya desktop environment — a modern, Qt6/KDE Plasma-based desktop built from the ground up.

## Repository Structure

This is the meta-repository for building the MatsyaOS live ISO. It contains:

- **`matsya-iso/profiles/matsya/`** — Archiso profile (packages, pacman.conf, customizations)
- **`.github/workflows/build-iso.yml`** — CI workflow that builds and publishes the ISO
- **Submodules** — Individual MatsyaOS desktop components:
  - `libmatsya` — Core library
  - `matsyaui` — Qt Quick UI components
  - `appmotor`, `calculator`, `daemon`, `dock`, `filemanager`, `launcher`, `screenlocker`, `screenshot`, `settings`, `statusbar`, `terminal`, `texteditor`, `wallpappers` — Desktop apps
  - `kwin-plugins`, `qt-plugins`, `gtk-themes`, `sddm-theme` — Desktop integration
  - `icons` — Icon theme
  - `mpvz`, `plaympv`, `plaympvz` — Media players
- **`matsya-calamares/`, `matsya-calameres-config/`, `matsya-grub/`, `matsya-namaste/`, `matsyaos-grub-theme/`, `plymouth-theme-matsya/`** — Package build files

## Building the ISO

### Locally

```bash
# Install dependencies
sudo pacman -S archiso arch-install-scripts squashfs-tools libisoburn mtools syslinux grub

# Build
sudo mkarchiso -v -w /tmp/iso-work -o out matsya-iso/profiles/matsya
```

### Using Docker/Podman

```bash
./build-iso-container.sh
```

### GitHub Actions

Push to the `master` branch or trigger manually via the Actions tab. The workflow will:
1. Check out the repository and submodules
2. Install build dependencies
3. Build the ISO using `mkarchiso`
4. Upload the ISO as a build artifact
5. Publish a GitHub Release with the ISO and checksum

## Package Repository

MatsyaOS packages are hosted at [matsyaos-repo](https://github.com/MatsyaOs/matsyaos-repo). The `pacman.conf` includes:
- `media.githubusercontent.com` — serves package files (Git LFS)
- `raw.githubusercontent.com` — serves repository metadata (`.db`, `.files`)

## License

GPL-2.0-only
