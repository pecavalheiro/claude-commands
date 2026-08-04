#!/bin/bash
# Installs this repo's Claude Code commands and support bundles into ~/.claude
# via symlinks, so `git pull` updates everything in place. Safe to re-run;
# re-run whenever files are added, moved, or renamed.
#
# Conventions:
#   commands/**/*.md            -> ~/.claude/commands/<basename>  (flat: subfolders
#                                  are organizational only; basenames must be unique)
#   <top-level dir>/            -> ~/.claude/<dirname>            (support bundles,
#                                  e.g. requirements-phases, review-lenses)
#   commands/ and docs/ are exempt from the bundle rule.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CMD_SRC="$REPO_DIR/commands"
CMD_TARGET="$HOME/.claude/commands"

# Extra names for existing commands: "<alias>:<canonical file basename>"
ALIASES="
rt:refine-ticket
remind:requirements-remind
r:requirements-remind
synth:synthesize
implement:synthesize
"

mkdir -p "$CMD_TARGET"

# --- Guard: commands install flat, so basenames must be unique across subfolders
dups=$(find "$CMD_SRC" -type f -name '*.md' -exec basename {} \; | sort | uniq -d)
if [ -n "$dups" ]; then
    echo "ERROR: duplicate command filenames: $dups" >&2
    exit 1
fi

# --- Prune symlinks that point into this repo but whose target no longer exists
for link in "$CMD_TARGET"/*.md; do
    [ -L "$link" ] || continue
    dest=$(readlink "$link")
    case "$dest" in
        "$REPO_DIR"/*) [ -e "$dest" ] || { rm "$link"; echo "Pruned stale symlink: $link"; } ;;
    esac
done

link_command() { # $1 = source file, $2 = target basename
    local target="$CMD_TARGET/$2"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "SKIP: $target exists and is not a symlink — not touching it" >&2
        return 0
    fi
    ln -sfn "$1" "$target"
    echo "  /$(basename "$2" .md) -> ${1#"$REPO_DIR"/}"
}

echo "Commands:"
while IFS= read -r file; do
    link_command "$file" "$(basename "$file")"
done < <(find "$CMD_SRC" -type f -name '*.md' | sort)

echo "Aliases:"
for pair in $ALIASES; do
    alias_name="${pair%%:*}"
    canonical="${pair#*:}"
    src=$(find "$CMD_SRC" -type f -name "$canonical.md" | head -n 1)
    if [ -z "$src" ]; then
        echo "ERROR: alias '$alias_name' points at missing command '$canonical'" >&2
        exit 1
    fi
    link_command "$src" "$alias_name.md"
done

echo "Support bundles:"
for dir in "$REPO_DIR"/*/; do
    name=$(basename "$dir")
    case "$name" in commands|docs) continue ;; esac
    target="$HOME/.claude/$name"
    if [ -d "$target" ] && [ ! -L "$target" ]; then
        echo "ERROR: $target exists as a real directory — move it aside first." >&2
        exit 1
    fi
    ln -sfn "${dir%/}" "$target"
    echo "  ~/.claude/$name -> $name/"
done

echo "Done."
