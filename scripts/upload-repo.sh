#!/bin/bash
# Upload / sync the local matsyaos package repo to GitHub (MatsyaOs/matsyaos-repo).
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-/home/mister/matsyaos-repo}"
PKG_DIR="$REPO_ROOT/x86_64"
REMOTE="${REMOTE:-origin}"
BRANCH="${BRANCH:-main}"
MSG="${1:-Update MatsyaOS packages to $(date +%Y.%m.%d)}"

if [ ! -d "$REPO_ROOT/.git" ]; then
    echo "ERROR: $REPO_ROOT is not a git repository"
    exit 1
fi

if [ ! -d "$PKG_DIR" ]; then
    echo "ERROR: missing package dir $PKG_DIR"
    exit 1
fi

cd "$REPO_ROOT"

# Ensure db files are real files (GitHub raw cannot follow broken symlinks well)
cd "$PKG_DIR"
if [ -f matsyaos.db.tar.gz ]; then
    for link in matsyaos.db matsyaos.files; do
        if [ -L "$link" ]; then
            target=$(readlink "$link")
            rm -f "$link"
            cp -a "$target" "$link"
        fi
    done
fi
# Drop repo-add backups
rm -f matsyaos.db.tar.gz.old matsyaos.files.tar.gz.old 2>/dev/null || true
cd "$REPO_ROOT"

echo "=== Packages to publish ==="
ls -lh "$PKG_DIR"/*.pkg.tar.zst 2>/dev/null || true
ls -lh "$PKG_DIR"/matsyaos.db* "$PKG_DIR"/matsyaos.files* 2>/dev/null || true

# Update README with current server URL
cat > "$REPO_ROOT/README.md" << 'EOF'
# MatsyaOS Package Repository

This repository hosts compiled MatsyaOS packages used by the live ISO and installed systems.

## Usage

Add to `/etc/pacman.conf`:

```
[matsyaos]
SigLevel = Optional TrustAll
Server = https://raw.githubusercontent.com/MatsyaOs/matsyaos-repo/main/x86_64
```

Then:

```
sudo pacman -Syu
```

## Layout

```
x86_64/
  *.pkg.tar.zst
  matsyaos.db
  matsyaos.db.tar.gz
  matsyaos.files
  matsyaos.files.tar.gz
```

Packages are built from https://github.com/MatsyaOs/MatsyaOS and versioned from each component PKGBUILD (release line 1.1+).
EOF

git add -A
if git diff --cached --quiet; then
    echo "Nothing new to commit."
else
    git status -sb
    git commit -m "$MSG"
fi

echo "=== Pushing to GitHub ($REMOTE/$BRANCH) ==="
git push -u "$REMOTE" "$BRANCH"

echo "=== Published ==="
echo "Server = https://raw.githubusercontent.com/MatsyaOs/matsyaos-repo/main/x86_64"
