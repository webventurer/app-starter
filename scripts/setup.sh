#!/bin/bash
set -euo pipefail

# Links app-starter skills and docs into a project.
# Run from the target project, or pass the project path as $1.
# Discovers what to link automatically — no hardcoded lists.

PROJECT_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
PARENT_DIR="$(cd "$PROJECT_DIR/.." && pwd)"
STARTER_DIR="$PARENT_DIR/app-starter"
CODEFU_DIR="$PARENT_DIR/codefu"
GITIGNORE="$PROJECT_DIR/.gitignore"
MARKER="# app-starter symlinks (recreated by scripts/setup.sh)"
LINKED_PATHS=(.app-starter)

link() {
  local src="$1" dest="$2"
  [ -L "$dest" ] || [ -e "$dest" ] && rm -f "$dest"
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "  $(basename "$dest")"
}

is_codefu_skill() {
  [ -d "$CODEFU_DIR/.claude/skills/$1" ]
}

clean_stale_links() {
  for symlink in "$PROJECT_DIR/.app-starter" "$PROJECT_DIR"/.claude/skills/* "$PROJECT_DIR"/docs/*; do
    [ -L "$symlink" ] && readlink "$symlink" | grep -q "$STARTER_DIR" && rm -f "$symlink"
  done
}

link_skills() {
  for skill_dir in "$STARTER_DIR"/.claude/skills/*/; do
    local skill="$(basename "$skill_dir")"
    if ! is_codefu_skill "$skill"; then
      link "$skill_dir" "$PROJECT_DIR/.claude/skills/$skill"
      LINKED_PATHS+=(".claude/skills/$skill")
    fi
  done
}

link_docs() {
  for doc in "$STARTER_DIR"/*.md; do
    local name="$(basename "$doc")"
    case "$name" in README.md|CLAUDE.md) continue ;; esac
    link "$doc" "$PROJECT_DIR/docs/$name"
    LINKED_PATHS+=("docs/$name")
  done
}

update_gitignore() {
  [ -f "$GITIGNORE" ] || return
  grep -q "$MARKER" "$GITIGNORE" || return
  {
    local skip=false
    while IFS= read -r line; do
      if [ "$line" = "$MARKER" ]; then skip=true; continue; fi
      if $skip && [ -z "$line" ]; then
        skip=false
        echo "$MARKER"
        printf '%s\n' "${LINKED_PATHS[@]}"
        echo ""
        continue
      fi
      $skip || echo "$line"
    done
  } < "$GITIGNORE" > "$GITIGNORE.tmp"
  mv "$GITIGNORE.tmp" "$GITIGNORE"
}

echo "Linking app-starter into $(basename "$PROJECT_DIR")"
clean_stale_links
link "$STARTER_DIR" "$PROJECT_DIR/.app-starter"
link_skills
link_docs
update_gitignore
echo "Done."
