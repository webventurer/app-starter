# App Starter

A modern web app starter — React + TypeScript + Vite on the frontend, Hono + Neon + Clerk + Drizzle on the backend, with sensible defaults for styling, data fetching, and hosting. Every layer is independently replaceable — swap one piece without rewiring the rest.

## Prerequisites

```bash
# GitHub CLI (for cloning private repos)
brew install gh
gh auth login

# pnpm (package manager)
brew install pnpm
```

## Quick start

```bash
gh repo clone webventurer/app-starter
./app-starter/scripts/create.sh my-app
```

This creates a new `my-app/` directory alongside the starter (`../my-app` relative to this repo) and scaffolds a Vite + React + TypeScript project, installs all dependencies, initialises shadcn/ui (Radix + Nova), sets up Biome, and copies the reference docs into it.

## Claude Code setup

This project uses [codefu](https://github.com/webventurer/codefu) for AI-assisted development skills and commands. Add if not already cloned:

```bash
gh repo clone webventurer/codefu
add-codefu.sh  # if not there already
gh repo clone webventurer/app-starter
cd app-starter
```

## What's in this repo

| File | What it is | When to read it |
|:-----|:-----------|:----------------|
| [`scripts/create.sh`](scripts/create.sh) | Automated setup script — scaffolds Vite, installs deps, configures Tailwind, shadcn/ui, and Biome | You don't — just run it |
| [`package.json`](package.json) | Declarative dependency list for the full stack — the script copies this into your new project | When you want to see exactly what gets installed |
| [`stack.md`](stack.md) | The *why* — explains every technology choice, what we considered, and what we rejected | Before starting a project, to understand the decisions |
| [`tech-spec.md`](tech-spec.md) | The *how* — project structure, config snippets, environment variables, deployment steps | During development, as a reference guide |

## Why React Query is a default

TanStack React Query is included from day one because it pays for itself almost immediately. The moment you have two or three API calls, you'd otherwise be hand-rolling `useState` + `useEffect` + `try/catch` for loading and error states in every component. React Query replaces all of that with a single `useQuery` hook and gives you caching, deduplication, and background refetching for free. Since this starter already has a real backend (Hono + Drizzle + Neon), every app will be fetching data from the start — React Query means you never write the boilerplate.

## After install

1. Create a `.env` file (see [tech-spec.md](tech-spec.md) for the full list of variables)
2. Set up your project structure (see [tech-spec.md](tech-spec.md) for the directory layout)
3. Add config files — `drizzle.config.ts`, `vitest.config.ts`, `src/lib/query-client.ts` (snippets in [tech-spec.md](tech-spec.md))

## Optional dependencies

These are not in `package.json` — add them only when needed:

```bash
# Typography — polished, branded feel (Vercel's Geist font)
pnpm add @fontsource-variable/geist
# then add to src/main.tsx: import "@fontsource-variable/geist";
# and set in src/index.css: font-family: "Geist Variable", sans-serif;

# State management — when useState outgrows local state
pnpm add zustand
```

## Further reading

- [stack.md](stack.md) — the rationale behind every technology choice
- [tech-spec.md](tech-spec.md) — the actionable setup guide
