#!/bin/bash
set -e

LIB_DIR="$HOME/.local/lib/zsh"
LINK_PATH="$LIB_DIR/bm.zsh"
SOURCE_PATH="$(cd "$(dirname "$0")" && pwd)/bm.zsh"
ZSHRC="$HOME/.zshrc"
SOURCE_LINE='source ~/.local/lib/zsh/bm.zsh'

# Create directory
mkdir -p "$LIB_DIR"

# Create symlink
if [ -L "$LINK_PATH" ]; then
  echo "Updating existing symlink..."
  rm "$LINK_PATH"
elif [ -e "$LINK_PATH" ]; then
  echo "Error: $LINK_PATH already exists and is not a symlink"
  exit 1
fi

ln -s "$SOURCE_PATH" "$LINK_PATH"
echo "Linked: $LINK_PATH -> $SOURCE_PATH"

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
