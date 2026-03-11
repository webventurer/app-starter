#!/bin/bash
set -euo pipefail

# Create a new starter app with all dependencies

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_PATH="${1:-my-app}"

# Resolve to absolute path
case "$APP_PATH" in
    /*) ;;
    *)  APP_PATH="$(pwd)/$APP_PATH" ;;
esac

if [ -d "$APP_PATH" ]; then
    echo "Error: Directory '$APP_PATH' already exists"
    exit 1
fi

echo "Creating $APP_PATH..."

# Scaffold Vite project (--no-interactive skips the framework menu)
# Vite treats the directory arg as relative to cwd, so cd to parent first
APP_DIR="$(dirname "$APP_PATH")"
APP_BASE="$(basename "$APP_PATH")"
(cd "$APP_DIR" && pnpm create vite@latest "$APP_BASE" --template react-ts --no-interactive)

# Replace generated package.json with starter
cp "$STARTER_DIR/package.json" "$APP_PATH/package.json"

# Install all dependencies
cd "$APP_PATH"
pnpm install

# Remove Vite's default ESLint config (we use Biome instead)
rm -f eslint.config.js

# Initialise Biome
pnpx @biomejs/biome init

# Configure Tailwind v4 + Vite plugin (required before shadcn init)
cat > vite.config.ts << 'VITE'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import path from "path";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
VITE

# Add import alias to tsconfig
cat > tsconfig.app.json << 'TSCONFIG'
{
  "compilerOptions": {
    "tsBuildInfoFile": "./node_modules/.tmp/tsconfig.app.tsbuildinfo",
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedSideEffectImports": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"]
}
TSCONFIG

# Add import alias to tsconfig.json (shadcn reads this file directly)
cat > tsconfig.json << 'ROOTTSCONFIG'
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "files": [],
  "references": [
    { "path": "./tsconfig.app.json" },
    { "path": "./tsconfig.node.json" }
  ]
}
ROOTTSCONFIG

# Add Tailwind CSS import to main stylesheet
echo '@import "tailwindcss";' > src/index.css

# Initialise shadcn/ui (Radix components, Nova preset)
pnpx shadcn@latest init --template vite --base radix --preset nova -y

# Copy reference docs
mkdir -p docs
cp "$STARTER_DIR/tech-spec.md" docs/
cp "$STARTER_DIR/stack.md" docs/

echo ""
echo "Done! Next steps:"
echo "  cd $APP_PATH"
echo "  cp .env.example .env  # add your keys"
echo "  pnpm dev"
