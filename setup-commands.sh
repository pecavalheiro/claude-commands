#!/bin/bash

# Create the target directory if it doesn't exist
mkdir -p ~/.claude/commands/

# Get the absolute path of the commands directory
COMMANDS_DIR="$(cd "$(dirname "$0")/commands" && pwd)"

# Create symlinks for all files in the commands directory
for file in "$COMMANDS_DIR"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$HOME/.claude/commands/$filename"

        # Remove existing symlink or file if it exists
        if [ -e "$target" ] || [ -L "$target" ]; then
            rm "$target"
        fi

        # Create the symlink
        ln -s "$file" "$target"
        echo "Created symlink: $target -> $file"
    fi
done

# Symlink the phase files directory (read by the commands at runtime)
PHASES_DIR="$(cd "$(dirname "$0")/phases" && pwd)"
PHASES_TARGET="$HOME/.claude/requirements-phases"
if [ -d "$PHASES_TARGET" ] && [ ! -L "$PHASES_TARGET" ]; then
    echo "ERROR: $PHASES_TARGET exists as a real directory — move it aside first." >&2
    exit 1
fi
ln -sfn "$PHASES_DIR" "$PHASES_TARGET"
echo "Created symlink: $PHASES_TARGET -> $PHASES_DIR"

echo "Done! All commands have been symlinked to ~/.claude/commands/"