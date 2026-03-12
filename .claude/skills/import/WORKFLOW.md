# Import workflow

<mark>**Follow these steps in order.**</mark>

**Resuming?** If `references/REPLAY-CHECKLIST.md` already exists, run `git fetch upstream` and skip to Step 3.

---

## Execution sequence

| Step | Action | Goal |
|:-----|:-------|:-----|
| 1 | **Pre-flight** | Confirm target app exists, add upstream remote |
| 2 | **Build replay checklist** | Write every commit to `references/REPLAY-CHECKLIST.md` |
| 3 | **Replay loop** | Orchestrator spawns one subagent per commit — fresh context every time |
| 4 | **Verify** | Confirm every checklist row has a status |
| 5 | **Domain map** | Holistic summary of both repos |
| 6 | **Cross-repo scan** | Verify nothing was missed with `compare_repos` |

---

## Step 1: Pre-flight

Check that codefu is available (needed for cross-repo scan in Step 5b):

```bash
python -m codefu.codetidy.compare_repos --help
```

If this fails, tell the user: "codefu is not installed. Clone it and add it to this project: `add-codefu codefu https://github.com/webventurer/codefu`" — then stop.

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
git log upstream/main --oneline --reverse --no-merges
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
    5. If status is "applied", run git log -1 --oneline to confirm a new commit exists
    6. Report progress to the user (commit #, message, status, how many remain)
    6. Continue to the next commit
```

**Batch skips:** If the next several commits are all clearly skippable (scaffolding, config, dependency bumps), you may skip them in a batch — update all their statuses at once without spawning subagents.

### Subagent prompt

<mark>**The subagent has no context from the orchestrator's conversation.** Read [references/SUBAGENT-PROMPT.md](references/SUBAGENT-PROMPT.md) and send its contents to the subagent, replacing `<hash>` and `<message>` with the actual commit details. Do not paraphrase or shorten — send the file contents verbatim.</mark>

The subagent handles everything — read, decide, apply, commit, update checklist — then returns to the orchestrator.

**If the subagent cannot invoke `/commit`** (Skill tool unavailable in subagent context), the orchestrator should commit after the subagent returns, using `/commit` itself.

---

## Step 4: Verify

<mark>**Read `references/REPLAY-CHECKLIST.md` — every row must have a status.**</mark> If any row is blank, go back to Step 3.

- [ ] Every checklist row has a status (`applied`, `skipped`, or `deferred`)
- [ ] All relevant upstream features are present in the target
- [ ] No source-stack idioms leaked in (Express patterns, wrong imports, etc.)
- [ ] App builds and runs (`pnpm build`)
- [ ] Skipped commits were genuinely irrelevant
- [ ] Commit history tells a coherent story
- [ ] Deferred commits reviewed — apply now or permanently skip with a reason

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

---

## Step 6: Cross-repo scan

After writing the domain map, run `compare_repos` to verify nothing was missed.

If the upstream repo isn't available as a local directory, clone it first:

```bash
git clone <upstream-url> /tmp/upstream-checkout
```

Then run the comparison:

```bash
python -m codefu.codetidy.compare_repos /tmp/upstream-checkout .
```

Review the report — pay attention to `source_only` files (upstream files with no target equivalent). Update the domain map if the scan reveals gaps.

This is the safety net. The commit-by-commit replay can miss things that were spread across multiple commits or that don't show up as obvious feature additions.

---

## Stopping rules

- All upstream commits have been replayed or skipped
- The user says to stop
- A commit requires infrastructure not yet available (mark as `deferred`, continue)
