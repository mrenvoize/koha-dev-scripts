#!/usr/bin/env bash
# install.sh — sync koha-dev-scripts into place on this machine. Re-runnable.
#
#   bin/*        → ~/.local/bin           (the kd wrapper, etc.)
#   workspace/** → $KOHA_DIR              (Koha CLAUDE.md files + core/docs)
#
# Every target is a symlink back into this repo, so the repo is the single
# source of truth: edit + commit + push here, then `git pull && ./install.sh`
# on the other machine.
#
# Real (non-symlink) files already sitting at a target are treated carefully:
#   - identical content → adopted silently (replaced with the symlink; nothing lost)
#   - differing content → a unified diff is printed and the file is LEFT IN PLACE,
#                         unless --force is given, in which case it is backed up to
#                         <path>.bak and then replaced with the symlink.
#
# Usage: ./install.sh [--force]
#   KOHA_DIR   Koha workspace root  (default: ~/Projects/koha)
#   BIN_TARGET script install dir   (default: ~/.local/bin)

set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
BIN_TARGET="${BIN_TARGET:-$HOME/.local/bin}"
KOHA_DIR="${KOHA_DIR:-$HOME/Projects/koha}"

FORCE=0
for arg in "$@"; do
    case "$arg" in
        --force|-f) FORCE=1 ;;
        -h|--help)  sed -n '2,/^set /{/^set /!p}' "$0"; exit 0 ;;
        *) echo "unknown option: $arg" >&2; exit 1 ;;
    esac
done

conflicts=0

# link_file <src> <dest> — idempotently point dest at src.
link_file() {
    local src="$1" dest="$2"

    # Already the correct symlink → nothing to do.
    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        echo "  ok      $dest"
        return
    fi

    # Some other symlink (or a broken one) → safe to repoint; no user data at risk.
    if [ -L "$dest" ]; then
        ln -sf "$src" "$dest"
        echo "  relink  $dest"
        return
    fi

    # A real file exists → conflict handling.
    if [ -e "$dest" ]; then
        if cmp -s "$src" "$dest"; then
            ln -sf "$src" "$dest"
            echo "  adopt   $dest (identical content)"
            return
        fi
        echo ""
        echo "  DIFF    $dest differs from repo copy (< current, > repo):"
        diff "$dest" "$src" | sed 's/^/            /' || true
        echo ""
        if [ "$FORCE" -eq 1 ]; then
            cp -p "$dest" "$dest.bak"
            ln -sf "$src" "$dest"
            echo "  forced  $dest  (backup at $dest.bak)"
        else
            echo "  SKIP    $dest — real file differs; re-run with --force to replace"
            conflicts=$((conflicts + 1))
        fi
        return
    fi

    # Nothing there → create it.
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo "  link    $dest"
}

# Legacy symlinks removed by the kd consolidation.
for old in koha-feature-up koha-feature-down koha-feature-tmux; do
    if [ -L "$BIN_TARGET/$old" ]; then
        rm -f "$BIN_TARGET/$old"
        echo "removed legacy symlink $BIN_TARGET/$old"
    fi
done

mkdir -p "$BIN_TARGET"
echo "scripts → $BIN_TARGET"
for script in "$REPO/bin/"*; do
    [ -e "$script" ] || continue
    link_file "$script" "$BIN_TARGET/$(basename "$script")"
done

if [ -d "$REPO/workspace" ]; then
    echo ""
    echo "workspace docs → $KOHA_DIR"
    while IFS= read -r -d '' f; do
        rel="${f#"$REPO"/workspace/}"
        link_file "$f" "$KOHA_DIR/$rel"
    done < <(find "$REPO/workspace" -type f -print0)
fi

echo ""
if [ "$conflicts" -gt 0 ]; then
    echo "$conflicts conflict(s) left untouched. Reconcile them, or re-run with --force"
    echo "to replace (a .bak copy of each is kept). Nothing else changed."
    exit 1
fi
echo "done. Ensure $BIN_TARGET is on your PATH."
