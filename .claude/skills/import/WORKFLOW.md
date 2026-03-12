# Import workflow

<mark>**Follow these steps in order.**</mark>

---

## Execution sequence

| Step | Action | Goal |
|:-----|:-------|:-----|
| 1 | **Add remote** | Connect the upstream repo |
| 2 | **List commits** | See the full history to replay |
| 3 | **Replay loop** | Walk each commit: apply or skip |
| 4 | **Verify** | Confirm the import is complete |
| 5 | **Domain map** | Holistic summary of both repos |

---

## Before you start

Read these before executing:

- [SKILL.md](SKILL.md) — principles, technology mapping, what to skip
- [tech-spec.md](../../../tech-spec.md) — target stack and project structure
- [stack.md](../../../stack.md) — technology choices and rationale

---

## Step 1: Add the upstream remote

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

## Step 2: List the commits

Get the full commit history in chronological order:

```bash
git log upstream/main --oneline --reverse
```

This gives you the replay queue. If the user specifies a branch other than `main`, use that instead.

**If resuming a partial import**, find where you left off:

```bash
git log --oneline -1  # your last commit
git log upstream/main --oneline --reverse  # find the matching upstream commit, continue from the next one
```

---

## Step 3: Replay loop

For each upstream commit, in order:

### 3a. Read the commit

```bash
git show <commit-hash>
```

Understand: what changed, and why (from the commit message).

### 3b. Decide: apply or skip

**Skip** if the commit is:
- Scaffolding or boilerplate (see [What to skip](SKILL.md#what-to-skip))
- Config for tools the target doesn't use
- Dependency changes with no code impact
- Changes to files that have no equivalent in the target

**Apply** if the commit contains:
- Data model changes → adapt to Drizzle schema
- API route changes → adapt to Hono routes
- UI component changes → adapt to React + shadcn/ui + Tailwind
- Business logic → translate the intent, not the syntax
- Asset additions (images, fonts) → copy directly if needed

When skipping, note it briefly and move on. Don't dwell.

### 3c. Apply the change

Adapt the upstream commit to the target stack:

1. **Read the diff** — understand what the upstream commit does
2. **Implement the equivalent** in target technologies (see [Technology mapping](SKILL.md#technology-mapping))
3. **Follow target conventions** — feature-based directories, React Query for data fetching, Hono for API routes
4. **Test** — does the app still build? Does the feature work?

### 3d. Commit

<mark>**Always use the `/commit` skill — never raw git commit.**</mark> The skill enforces the four-pass methodology and ensures well-formatted, atomic commits.

- Reference the upstream commit in the body if helpful
- The commit should make sense on its own — someone reading your history shouldn't need to see the upstream repo

### 3e. Next commit

Move to the next upstream commit and repeat from 3a.

---

## Step 4: Verify

After replaying all commits (or reaching the stopping point):

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
2. Compare your latest commit with the upstream log to find where you left off
3. Continue the replay loop from the next upstream commit
