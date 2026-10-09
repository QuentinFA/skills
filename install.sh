#!/usr/bin/env bash
# Symlink this repo's skills into ~/.claude/skills so edits here are live.
# Idempotent. Never clobbers a real file or directory; re-points only its own stale symlinks.
#
#   ./install.sh            link everything
#   ./install.sh --dry-run  show what would change
#   ./install.sh --force    replace foreign symlinks too (real files still untouched)

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

DRY_RUN=false
FORCE=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --force)   FORCE=true ;;
    -h|--help) sed -n '2,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

linked=0 skipped=0 blocked=0

link() {
  local src="$1" dest="$2" label="$3"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      skipped=$((skipped + 1))
      return
    fi
    if [ "$FORCE" = false ]; then
      echo "  skip    $label — symlink points elsewhere ($current); use --force"
      blocked=$((blocked + 1))
      return
    fi
    $DRY_RUN || rm "$dest"
  elif [ -e "$dest" ]; then
    echo "  BLOCKED $label — a real file/dir is already there, move it aside first"
    blocked=$((blocked + 1))
    return
  fi

  echo "  link    $label"
  $DRY_RUN || ln -s "$src" "$dest"
  linked=$((linked + 1))
}

if $DRY_RUN; then echo "DRY RUN — nothing will be written"; fi
echo "repo:   $REPO"
echo "target: $CLAUDE_DIR"

echo "skills:"
$DRY_RUN || mkdir -p "$CLAUDE_DIR/skills"
for dir in "$REPO"/skills/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  name="$(basename "$dir")"
  link "$REPO/skills/$name" "$CLAUDE_DIR/skills/$name" "$name"
done

echo "linked $linked, already current $skipped, blocked $blocked"
if [ "$blocked" -gt 0 ]; then exit 1; fi
exit 0
