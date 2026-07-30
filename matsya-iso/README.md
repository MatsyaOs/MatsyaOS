# MatsyaOS ISO

This directory contains the MatsyaOS live ISO profile.

## Build

```bash
sudo pacman -S archiso
sudo mkarchiso -v -w /tmp/work -o /tmp/out profiles/matsya
```

The ISO uses the standard Arch Linux `archiso` / `mkarchiso` system.
