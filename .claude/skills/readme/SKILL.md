---
name: readme
description: Generate or update README.md from CLAUDE.md and package.json. Triggers on "readme", "update readme", "generate readme".
---

# README

Generate a project README by reading what the project actually is (`CLAUDE.md`) and what it depends on (`package.json`).

---

## When to use

- After creating a new project from app-starter
- After significant stack changes (new dependencies, removed features)
- When the README is stale or contains boilerplate

## When NOT to use

- The README has been manually customised beyond what this skill generates — update by hand instead

---

## Quick reference

<mark>**Read the project, don't guess.** The README is derived from `CLAUDE.md` (description, commands, architecture) and `package.json` (dependencies). Never invent content.</mark>

---

## Inputs

| Source | What to extract |
|:-------|:----------------|
| `CLAUDE.md` | Project name, description, commands, stack overview |
| `package.json` | All dependencies and devDependencies with versions |
| `docs/stack.md` | Canonical tech stack with categories and purpose descriptions |
| `.app-starter` symlink | Whether to include the "Created from app-starter" line |

---

## Output structure

The README must follow this exact structure:

```markdown
# {Project Name}

{1-2 sentence description from CLAUDE.md "What This Is" section}

Created from [app-starter](https://github.com/webventurer/app-starter).

## Getting started

\```bash
pnpm install
pnpm dev
\```

## Commands

| Command | Description |
|:--------|:------------|
| `pnpm dev` | ... |
| ... | ... |

## Tech stack

### Frontend

| Technology | Purpose |
|:-----------|:--------|
| ... | ... |

### Backend

| Technology | Purpose |
|:-----------|:--------|
| ... | ... |

### Tooling

| Technology | Purpose |
|:-----------|:--------|
| ... | ... |

### Services

| Technology | Purpose |
|:-----------|:--------|
| ... | ... |

### Fonts

| Font | Usage |
|:-----|:------|
| ... | ... |
```

---

## Rules

- **"Created from app-starter" line**: include only if `.app-starter` symlink exists
- **Commands table**: pull from `CLAUDE.md` Commands section. Use the short descriptions, not the full explanations
- **Tech stack tables**: derive from `docs/stack.md` (the canonical source), cross-referenced with `package.json` to confirm what's actually installed. Use human-readable names, not npm package names (e.g. "React 19" not "@types/react", "Tailwind CSS v4" not "tailwindcss")
- **Skip internal/utility deps**: don't list `clsx`, `tailwind-merge`, `tw-animate-css`, `class-variance-authority`, `@hookform/resolvers`, `zod` unless they are a primary part of the stack
- **Version numbers**: include major version in the name where it aids clarity (e.g. "React 19", "Vite 6", "TypeScript 5") but not patch versions
- **Fonts section**: only include if `@fontsource` packages are in dependencies
- **Services section**: only include if service SDKs (PostHog, Loops, Sentry, etc.) are in dependencies

---

## Reference template

See [references/TEMPLATE.md](references/TEMPLATE.md) for a complete example of the expected output. **Read this file before generating.** Match its tone, structure, and level of detail.

---

## Execution

1. Read [references/TEMPLATE.md](references/TEMPLATE.md) — this is your target structure
2. Read `docs/stack.md` — canonical tech stack with categories
3. Read `CLAUDE.md` — extract project name, description, commands
4. Read `package.json` — confirm which dependencies are actually installed
5. Check for `.app-starter` symlink
6. Generate `README.md` following the template, populating tech stack from `docs/stack.md`
7. Show the user the result
