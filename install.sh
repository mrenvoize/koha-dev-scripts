#!/usr/bin/env bash
# install.sh — symlink all scripts in bin/ into ~/.local/bin/
# Safe to re-run: existing symlinks are updated, non-symlink files are skipped.
# Also removes legacy koha-feature-* symlinks replaced by kd.

set -e

REPO="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-$HOME/.local/bin}"

mkdir -p "$TARGET"

# Remove legacy symlinks from before the kd consolidation
for old in koha-feature-up koha-feature-down koha-feature-tmux; do
    dest="$TARGET/$old"
    if [ -L "$dest" ]; then
        rm -f "$dest"
        echo "removed legacy symlink $dest"
    fi
done

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
