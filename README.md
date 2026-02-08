# bm-zsh

Simple path bookmark manager for zsh.

## Install

```bash
git clone https://github.com/MionMion18/bm-zsh.git
cd bm-zsh
./install.sh
```

## Usage

```bash
bm save <name> [path]  # Bookmark current dir or specified path
bm cd <name>           # cd to bookmarked path
bm ls                  # List all bookmarks
bm rm <name>           # Remove a bookmark
bm path <name>         # Print the path (useful in $() or backticks)
```

## Examples

```bash
bm save work
bm save proj ~/projects/myapp
bm cd work
cp file.txt $(bm path proj)/
```

## Uninstall

```bash
rm ~/.local/lib/zsh/bm.zsh
# Remove "source ~/.local/lib/zsh/bm.zsh" from ~/.zshrc
```
