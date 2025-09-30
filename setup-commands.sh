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

echo "Done! All commands have been symlinked to ~/.claude/commands/"