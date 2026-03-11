# App Starter

One command to bootstrap a React + TypeScript app with the full stack pre-configured.

## Quick start

```bash
git clone git@github.com:webventurer/app-starter.git
./app-starter/scripts/create.sh my-app
```

This scaffolds a Vite + React + TypeScript project, installs all dependencies, initialises shadcn/ui (Radix + Nova), sets up Biome, and copies the reference docs into the new project.

## What's in this repo

| File | Purpose |
|:-----|:--------|
| `scripts/create.sh` | One-command setup — scaffold, install, configure |
| `package.json` | All dependencies — used by the script |
| `stack.md` | Why each technology was chosen |
| `tech-spec.md` | Project structure, config snippets, environment variables |

## After install

1. Create a `.env` file (see `tech-spec.md` for the full list of variables)
2. Set up your project structure (see `tech-spec.md` for the directory layout)
3. Add config files — `drizzle.config.ts`, `vitest.config.ts`, `src/lib/query-client.ts` (snippets in `tech-spec.md`)

## Optional dependencies

These are not in `package.json` — add them only when needed:

```bash
# Animation — when CSS transitions aren't enough
pnpm add motion          # interactive: mount/unmount, layout, gestures
pnpm add gsap            # cinematic: timelines, scroll-driven, SVG morphing

# State management — when useState outgrows local state
pnpm add zustand
```

## Further reading

- [stack.md](stack.md) — the rationale behind every technology choice
- [tech-spec.md](tech-spec.md) — the actionable setup guide
