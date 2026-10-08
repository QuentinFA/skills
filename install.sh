#!/usr/bin/env bash
# Symlink this repo's skills into ~/.claude/skills, and list its mods in settings.json's
# env.CLAUDE_CODE_PLUGIN_DIRS, so edits here are live.
# Idempotent. Never clobbers a real file or directory, never drops another plugin dir; re-points
# only its own stale links and mod paths.
#
#   ./install.sh            link everything
#   ./install.sh --dry-run  show what would change
#   ./install.sh --force    replace foreign symlinks and other checkouts' mod paths too

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

DRY_RUN=false
FORCE=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --force)   FORCE=true ;;
    -h|--help) sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
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

# A mod is a plugin folder; Claude Code loads each path in CLAUDE_CODE_PLUGIN_DIRS
# (':'-separated) and watches it, so the repo's folder is listed rather than copied.
mods=()
for dir in "$REPO"/mods/*/; do
  [ -f "$dir/.claude-plugin/plugin.json" ] && mods+=("$(basename "$dir")")
done

if [ "${#mods[@]}" -gt 0 ]; then
  echo "mods:"
  settings="$CLAUDE_DIR/settings.json"
  if ! command -v jq >/dev/null; then
    echo "  BLOCKED mods — jq is needed to edit $settings"
    blocked=$((blocked + ${#mods[@]}))
  else
    current=""
    [ -f "$settings" ] && current="$(jq -r '.env.CLAUDE_CODE_PLUGIN_DIRS // ""' "$settings")"
    updated="$current"
    for name in "${mods[@]}"; do
      path="$REPO/mods/$name"
      case ":$updated:" in
        *":$path:"*) skipped=$((skipped + 1)); continue ;;
      esac
      # Another checkout's copy of the same mod would load it twice.
      other="$(printf '%s' "$updated" | tr ':' '\n' | grep -E "/mods/$name/?\$" || true)"
      if [ -n "$other" ]; then
        if [ "$FORCE" = false ]; then
          echo "  skip    $name — already listed from $other; use --force"
          blocked=$((blocked + 1))
          continue
        fi
        updated="$(printf '%s' "$updated" | tr ':' '\n' | grep -vxF "$other" | paste -sd: -)"
      fi
      echo "  add     $name to env.CLAUDE_CODE_PLUGIN_DIRS"
      updated="${updated:+$updated:}$path"
      linked=$((linked + 1))
    done
    if [ "$updated" != "$current" ] && ! $DRY_RUN; then
      [ -s "$settings" ] || echo '{}' > "$settings"
      next="$(jq --arg dirs "$updated" '.env.CLAUDE_CODE_PLUGIN_DIRS = $dirs' "$settings")"
      printf '%s\n' "$next" > "$settings" # in place: a symlinked settings.json stays one
    fi
  fi
fi

echo "linked $linked, already current $skipped, blocked $blocked"
if [ "$blocked" -gt 0 ]; then exit 1; fi
exit 0
