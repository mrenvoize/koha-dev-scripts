#!/usr/bin/env bash
# install.sh — symlink all scripts in bin/ into ~/.local/bin/
# Safe to re-run: existing symlinks are updated, non-symlink files are skipped.

set -e

REPO="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-$HOME/.local/bin}"

mkdir -p "$TARGET"

for script in "$REPO/bin/"*; do
    name="$(basename "$script")"
    dest="$TARGET/$name"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "SKIP $dest — exists and is not a symlink (remove it manually to replace)"
        continue
    fi
    ln -sf "$script" "$dest"
    echo "linked $dest → $script"
done

echo "done. Make sure $TARGET is on your PATH."
