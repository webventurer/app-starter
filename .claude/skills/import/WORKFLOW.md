# Import workflow

<mark>**Follow these steps in order.**</mark>

---

## Execution sequence

| Step | Action | Goal |
|:-----|:-------|:-----|
| 1 | **Pre-flight** | Confirm target app exists, add upstream remote |
| 2 | **Build replay checklist** | Write every commit to `references/REPLAY-CHECKLIST.md` |
| 3 | **Replay loop** | Orchestrator spawns one subagent per commit — fresh context every time |
| 4 | **Verify** | Confirm every checklist row has a status |
| 5 | **Domain map** | Holistic summary of both repos |

---

## Step 1: Pre-flight

Confirm the target app exists and runs:

```bash
pnpm build
```

If this fails, fix it before importing anything. You need a working baseline.

**Ask the user for the upstream repo URL** if not provided as an argument to `/import`.

Then check if the remote already exists:

```bash
git remote get-url upstream 2>/dev/null
```

If it doesn't exist, add it:

```bash
git remote add upstream <repo-url>
git fetch upstream
```

If it already exists, just fetch new commits:

```bash
git fetch upstream
```

---

## Step 2: Build the replay checklist

Get the full commit history in chronological order:

```bash
git log upstream/main --oneline --reverse
```

If the user specifies a branch other than `main`, use that instead.

### Write the checklist to a file

<mark>**Create `references/REPLAY-CHECKLIST.md` with every upstream commit as a numbered row.**</mark> This is the source of truth for progress — not your memory, not the conversation context.

```bash
mkdir -p references
```

```markdown
# Replay checklist

| # | Hash | Message | Status |
|:--|:-----|:--------|:-------|
| 1 | abc1234 | Initial scaffold | |
| 2 | def5678 | Add user model | |
| 3 | ghi9012 | Add login page | |
```

Status values: `skipped`, `applied`, `deferred`

**Update this file after processing each commit.** This ensures progress survives context compression and session boundaries.

---

## Step 3: Replay loop

<mark>**You are the orchestrator.** Do not process commits yourself — spawn a subagent for each one using the Agent tool. Each subagent gets fresh context, so quality stays high across the entire import.</mark>

### Orchestrator loop

```
while checklist has rows without a status:
    1. Read references/REPLAY-CHECKLIST.md
    2. Find the first row without a status
    3. Spawn a subagent (Agent tool) to process that commit
    4. When the subagent returns, verify the checklist was updated
    5. Report progress to the user (commit #, message, status, how many remain)
    6. Continue to the next commit
```

**Batch skips:** If the next several commits are all clearly skippable (scaffolding, config, dependency bumps), you may skip them in a batch — update all their statuses at once without spawning subagents.

### Subagent prompt template

<mark>**The subagent has no context from the orchestrator's conversation.** The prompt must be fully self-contained — include all skip criteria, technology mappings, and conventions inline.</mark>

```
Process upstream commit <hash> for the import into an app-starter project.

Read these files first:
- references/REPLAY-CHECKLIST.md — import progress so far
- docs/tech-spec.md and docs/stack.md — target stack details

Your commit: <hash> — <message>

## Steps

1. Run: git show <hash>
2. Decide: apply or skip
3. If applying: adapt to target stack, verify build with pnpm build
4. Invoke /commit using the Skill tool to commit (reference upstream hash in body)
5. Update references/REPLAY-CHECKLIST.md with the status (applied, skipped, or deferred)

## Skip criteria

Skip if the commit is:
- Initial scaffolding (create-react-app, vite init, etc.)
- Package manager config (package.json, lockfiles, .npmrc)
- CI/CD pipelines (.github/workflows/, Dockerfiles)
- Linter/formatter config (.eslintrc, .prettierrc — target uses Biome)
- Framework boilerplate that only exists because the source framework requires it
- Dependency bumps with no code changes
- Config for tools the target doesn't use
- Changes to files that have no equivalent in the target

## Technology mapping

When applying, map source concepts to target equivalents:
- Database models (ActiveRecord, Sequelize, Prisma) → Drizzle schema in server/db/schema.ts
- API routes (Express, Rails controllers, Flask) → Hono routes in server/routes/
- Views/templates (ERB, EJS, Jinja, jQuery) → React components in src/features/
- Auth (Devise, Passport, custom) → Clerk (drop custom auth entirely)
- Tests (RSpec, Jest, Mocha) → Vitest + Testing Library
- CSS frameworks (Bootstrap, Material UI) → Tailwind + shadcn/ui
- Animation (framer-motion) → Motion (motion/react)

## Conventions

- Feature-based directory structure (src/features/<name>/)
- React Query for data fetching
- Hono for API routes with Zod validation
- The commit should make sense on its own — someone reading the history
  shouldn't need to see the upstream repo

## Build failure recovery

If pnpm build fails after applying:
1. Try to fix the build error (missing import, type issue)
2. If non-trivial, revert with git checkout .
3. Mark the commit as deferred in the checklist
```

The subagent handles everything — read, decide, apply, commit, update checklist — then returns to the orchestrator.

---

## Step 4: Verify

<mark>**Read `references/REPLAY-CHECKLIST.md` — every row must have a status.**</mark> If any row is blank, go back to Step 3.

- [ ] Every checklist row has a status (`applied`, `skipped`, or `deferred`)
- [ ] All relevant upstream features are present in the target
- [ ] No source-stack idioms leaked in (Express patterns, wrong imports, etc.)
- [ ] App builds and runs
- [ ] Skipped commits were genuinely irrelevant
- [ ] Commit history tells a coherent story

---

## Step 5: Domain map

Write a holistic summary of both repos to `references/DOMAIN-MAP.md`. You've just walked every commit — capture what you learned while it's fresh.

The domain map should cover:

- **What was imported** — features, models, routes, UI components that made it into the target
- **What was skipped** — and why (dead code, framework boilerplate, not needed yet)
- **How concepts mapped** — source entity → target equivalent (e.g. Prisma model → Drizzle schema, Express route → Hono route)
- **What's deferred** — features noted as future work during the replay
- **Divergences** — where the target deliberately differs from the source (simplified, restructured, dropped)

This document is for future you — when you need to understand the relationship between the two repos or resume work later.

### 5b. Cross-repo scan

After writing the domain map, scan both repos to verify nothing was missed:

1. **List the upstream repo's current files** — `git ls-tree -r --name-only upstream/main`
2. **List the target repo's files** — `ls -R` or `git ls-files`
3. **Compare** — for every meaningful upstream file (not config/boilerplate), confirm it has a target equivalent or was deliberately skipped
4. **Update the domain map** if the scan reveals gaps — features that were in the upstream but didn't come through during the replay

This is the safety net. The commit-by-commit replay can miss things that were spread across multiple commits or that don't show up as obvious feature additions.

---

## Stopping rules

- All upstream commits have been replayed or skipped
- The user says to stop
- A commit requires infrastructure not yet available (note as future work, skip, continue)

---

## Resuming

To continue a previous import session:

1. `git fetch upstream` to get any new commits
2. Read `references/REPLAY-CHECKLIST.md` — find the first row without a status
3. Continue the replay loop from that commit
