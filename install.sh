#!/bin/bash
set -e

LIB_DIR="$HOME/.local/lib/zsh"
LINK_PATH="$LIB_DIR/bm.zsh"
SOURCE_PATH="$(cd "$(dirname "$0")" && pwd)/bm.zsh"
ZSHRC="$HOME/.zshrc"
SOURCE_LINE='source ~/.local/lib/zsh/bm.zsh'

# Create directory
mkdir -p "$LIB_DIR"

# Copy file
cp "$SOURCE_PATH" "$LINK_PATH"
echo "Copied: $SOURCE_PATH -> $LINK_PATH"

# Add source line to .zshrc if not present
if ! grep -qF "$SOURCE_LINE" "$ZSHRC" 2>/dev/null; then
  echo "" >> "$ZSHRC"
  echo "# Tools" >> "$ZSHRC"
  echo "$SOURCE_LINE" >> "$ZSHRC"
  echo "Added source line to $ZSHRC"
else
  echo "Source line already in $ZSHRC"
fi

echo "Done! Restart your shell or run: source $ZSHRC"
