# bm - simple path bookmark manager for zsh
# Usage:
#   bm save <name> [path]  - bookmark current dir or specified path
#   bm cd <name>           - cd to bookmarked path
#   bm ls                  - list all bookmarks
#   bm rm <name>           - remove a bookmark
#   bm path <name>         - print the path (useful in $() or backticks)
#
# Add to your .zshrc:
#   source /path/to/bm.zsh

BM_FILE="${HOME}/.bookmarks"

bm() {
  local cmd="$1"
  shift 2>/dev/null

  case "$cmd" in
    save)
      local name="$1"
      local target="${2:-$(pwd)}"
      if [[ -z "$name" ]]; then
        echo "Usage: bm save <name> [path]"
        return 1
      fi
      target="$(cd "$target" 2>/dev/null && pwd || realpath "$target" 2>/dev/null || echo "$target")"
      # Remove existing entry with same name, then add
      if [[ -f "$BM_FILE" ]]; then
        local tmp=""
        while IFS= read -r line; do
          [[ "$line" == "${name}="* ]] && continue
          tmp+="${line}"$'\n'
        done < "$BM_FILE"
        printf '%s' "$tmp" > "$BM_FILE"
      fi
      echo "${name}=${target}" >> "$BM_FILE"
      echo "Saved: ${name} -> ${target}"
      ;;

    cd)
      local name="$1"
      if [[ -z "$name" ]]; then
        echo "Usage: bm cd <name>"
        return 1
      fi
      local target="$(_bm_get "$name")"
      if [[ -z "$target" ]]; then
        echo "Bookmark '${name}' not found"
        return 1
      fi
      cd "$target" || return 1
      ;;

    ls)
      if [[ ! -f "$BM_FILE" ]] || [[ ! -s "$BM_FILE" ]]; then
        echo "No bookmarks saved"
        return 0
      fi
      while IFS='=' read -r name path; do
        [[ -z "$name" ]] && continue
        if [[ -e "$path" ]]; then
          printf "  %-15s %s\n" "$name" "$path"
        else
          printf "  %-15s %s (missing)\n" "$name" "$path"
        fi
      done < "$BM_FILE"
      ;;

    rm)
      local name="$1"
      if [[ -z "$name" ]]; then
        echo "Usage: bm rm <name>"
        return 1
      fi
      local found=0
      local tmp=""
      if [[ -f "$BM_FILE" ]]; then
        while IFS= read -r line; do
          if [[ "$line" == "${name}="* ]]; then
            found=1
          else
            tmp+="${line}"$'\n'
          fi
        done < "$BM_FILE"
      fi
      if (( ! found )); then
        echo "Bookmark '${name}' not found"
        return 1
      fi
      printf '%s' "$tmp" > "$BM_FILE"
      echo "Removed: ${name}"
      ;;

    path)
      local name="$1"
      if [[ -z "$name" ]]; then
        echo "Usage: bm path <name>"
        return 1
      fi
      local target="$(_bm_get "$name")"
      if [[ -z "$target" ]]; then
        echo "Bookmark '${name}' not found" >&2
        return 1
      fi
      echo "$target"
      ;;

    *)
      echo "bm - path bookmark manager"
      echo ""
      echo "  bm save <name> [path]  Save bookmark (default: current dir)"
      echo "  bm cd <name>           cd to bookmark"
      echo "  bm ls                  List bookmarks"
      echo "  bm rm <name>           Remove bookmark"
      echo "  bm path <name>         Print path (for use in commands)"
      echo ""
      echo "Examples:"
      echo "  bm save work"
      echo "  bm save proj ~/projects/myapp"
      echo "  bm cd work"
      echo "  cp file.txt \$(bm path proj)/"
      ;;
  esac
}

_bm_get() {
  local name="$1"
  [[ ! -f "$BM_FILE" ]] && return 1
  while IFS='=' read -r key val; do
    if [[ "$key" == "$name" ]]; then
      echo "$val"
      return 0
    fi
  done < "$BM_FILE"
  return 1
}

# Tab completion
_bm_completions() {
  local subcmds=(save cd ls rm path)

  if (( CURRENT == 2 )); then
    _describe 'command' subcmds
  elif (( CURRENT == 3 )); then
    case "${words[2]}" in
      cd|rm|path)
        if [[ -f "$BM_FILE" ]]; then
          local -a names
          while IFS='=' read -r key _; do
            [[ -n "$key" ]] && names+=("$key")
          done < "$BM_FILE"
          _describe 'bookmark' names
        fi
        ;;
      save)
        _files -/
        ;;
    esac
  fi
}

[[ -n "$ZSH_VERSION" ]] && compdef _bm_completions bm 2>/dev/null
