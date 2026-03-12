#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$STARTER_DIR/templates"

TEMPLATE_FILES=(
    vite.config.ts
    tsconfig.app.json
    tsconfig.json
    drizzle.config.ts
    vitest.config.ts
    src/lib/query-client.ts
    src/lib/db.ts
    server/index.ts
)

DOC_FILES=(tech-spec.md stack.md)

SHADCN_COMPONENTS=(
    card table badge tabs
    separator skeleton dialog drawer input
)

resolve_absolute_path() {
    case "$1" in
        /*) echo "$1" ;;
        *)  echo "$(pwd)/$1" ;;
    esac
}

APP_PATH="$(resolve_absolute_path "${1:-my-app}")"

if [ -d "$APP_PATH" ]; then
    echo "Error: Directory '$APP_PATH' already exists"
    exit 1
fi

scaffold_vite_app() {
    local app_dir="$(dirname "$APP_PATH")"
    local app_base="$(basename "$APP_PATH")"
    (cd "$app_dir" && pnpm create vite@latest "$app_base" --template react-ts --no-interactive)
}

install_dependencies() {
    cp "$STARTER_DIR/package.json" "$APP_PATH/package.json"
    cd "$APP_PATH"
    pnpm install
}

copy_templates() {
    for file in "${TEMPLATE_FILES[@]}"; do
        mkdir -p "$(dirname "$file")"
        cp "$TEMPLATES_DIR/$file" "$file"
    done
}

configure_tooling() {
    rm -f eslint.config.js
    cp "$STARTER_DIR/biome.json" biome.json
    copy_templates
    echo '@import "tailwindcss";' > src/index.css
    pnpx shadcn@latest init --template vite --base radix --preset nova -y
    pnpx shadcn@latest add -y --overwrite "${SHADCN_COMPONENTS[@]}"
}

link_docs() {
    mkdir -p docs
    for file in "${DOC_FILES[@]}"; do
        ln -s "$STARTER_DIR/$file" "docs/$file"
    done
}

STARTER_SKILLS=(import readme update-tech)

link_starter() {
    ln -s "$STARTER_DIR" "$APP_PATH/.app-starter"
    mkdir -p "$APP_PATH/.claude/skills"
    for skill in "${STARTER_SKILLS[@]}"; do
        ln -s "$STARTER_DIR/.claude/skills/$skill" "$APP_PATH/.claude/skills/$skill"
    done
}

init_git() {
    rm -rf .git
    git init
    git add -A
    git commit -m "feat: Initial app from app-starter"
}

scaffold_vite_app
install_dependencies
configure_tooling
link_docs
link_starter
init_git

echo "Done! Next steps:"
echo "  cd $APP_PATH"
echo "  cp .env.example .env  # add your keys"
echo "  /readme               # generate README.md"
echo "  pnpm dev"
