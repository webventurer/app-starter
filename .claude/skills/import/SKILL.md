---
name: import
description: Import an upstream repo commit-by-commit — add as git remote, replay each commit, adapt relevant changes to the target stack, skip what doesn't apply. Triggers on "import", "absorb repo", "replay commits".
---

# Import

> Ask for the upstream repo URL, add it as a git remote, fetch the history, then walk through each commit in order — applying relevant changes (adapted to the target stack) and skipping what doesn't apply. Commit as you go.

---

## When to use

- Absorbing an existing app into a new app-starter project
- Replaying upstream changes into a project that's already been set up
- Catching up with new commits from a source repo

## When NOT to use

- Building from scratch with no source repo — use `/create` instead
- The source repo has no meaningful commit history (single squashed commit)

---

## Quick reference

<mark>**Replay, don't re-implement.** Walk the upstream commits in order. For each one, decide: apply (adapted to this stack) or skip. Commit after each applied change.</mark>

---

## Required reading

Read these before starting an import session:

1. [tech-spec.md](../../../tech-spec.md) — target stack configuration and project structure
2. [stack.md](../../../stack.md) — why each technology was chosen and when to reach for alternatives

---

## Key principles

| Principle | Explanation |
|:----------|:------------|
| **Commit-by-commit** | Walk the upstream history in chronological order. Each commit is a decision point: apply or skip |
| **Adapt, don't copy** | Source code is written for a different stack. Translate the intent of each commit into the target technologies |
| **Skip what's irrelevant** | Config files, CI pipelines, framework boilerplate from the source stack — skip these entirely |
| **Commit as you go** | After applying each upstream commit, create a matching commit in this repo. Keep the history clean and traceable |
| **Preserve the narrative** | The upstream commit messages tell you *why* each change was made. Carry that reasoning forward into your commits |

---

## Skill documents

| Document | Purpose | When to read |
|:---------|:--------|:-------------|
| **This file** (SKILL.md) | Principles and entry point | First — understand before doing |
| [WORKFLOW.md](WORKFLOW.md) | Step-by-step execution | When running an import session |

---

## Technology mapping

When adapting upstream commits, map source concepts to target equivalents:

| Source concept | Target equivalent | Notes |
|:---------------|:-----------------|:------|
| Database models (ActiveRecord, Sequelize, Prisma) | Drizzle schema in `server/db/schema.ts` | Map types to Postgres equivalents |
| API routes (Express, Rails controllers, Flask) | Hono routes in `server/routes/` | REST conventions, Zod validation |
| Views/templates (ERB, EJS, Jinja, jQuery) | React components in `src/features/` | Feature-based directory structure |
| Auth (Devise, Passport, custom) | Clerk | Drop custom auth — use Clerk's prebuilt components |
| Tests (RSpec, Jest, Mocha) | Vitest + Testing Library | Rewrite tests for the new implementation |
| CSS frameworks (Bootstrap, Material UI) | Tailwind + shadcn/ui | Use existing component library |
| Animation (framer-motion) | Motion (`motion/react`) | Same API, different import path |

---

## What to skip

These upstream commits are typically irrelevant to the target project:

- **Initial scaffolding** — `create-react-app`, `vite init`, etc. (already done by `/create`)
- **Package manager config** — `package.json`, lockfiles, `.npmrc` (target has its own deps)
- **CI/CD pipelines** — `.github/workflows/`, Dockerfiles
- **Linter/formatter config** — `.eslintrc`, `.prettierrc` (target uses Biome)
- **Framework boilerplate** — files that exist only because the source framework requires them
- **Dependency bumps** — version upgrades with no code changes

---

## Cross-references

| Skill | Relationship |
|:------|:-------------|
| [commit](../commit/SKILL.md) | Each applied change gets an atomic commit |
| [agility](../agility/SKILL.md) | The loop: apply, verify, adjust — one commit at a time |
| [strive-for-simplicity](../strive-for-simplicity/SKILL.md) | Resist importing complexity — simpler is better |

---

## The governing principle

> Walk the upstream history, carry forward the intent, adapt to the target stack, skip what doesn't belong.
