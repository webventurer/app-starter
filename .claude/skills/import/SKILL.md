---
name: import
description: Import an upstream repo commit-by-commit — add as git remote, replay each commit, adapt relevant changes to the target stack, skip what doesn't apply. Triggers on "import", "absorb repo", "replay commits".
---

# Import

Walk every upstream commit, adapt what belongs to the target stack, skip what doesn't — and never drop one.

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

## Atomic imports

This skill applies the same atomicity principle as `/commit`, but at the commit level. Just as an atomic commit contains exactly one logical change, each upstream commit gets its own **subagent with fresh context** — so quality stays high across the entire import.

**Why this matters:** Processing many commits in a single context degrades over time. By commit 15 the AI forgets the technology mapping, misapplies conventions, or silently stops. Subagents prevent this. Every commit gets the full context window and full attention it deserves.

**How it works:**

1. `/import` builds a checklist of every upstream commit to `references/REPLAY-CHECKLIST.md`
2. The orchestrator loops through the checklist, spawning a subagent for each commit
3. Each subagent processes one commit — read, decide, apply or skip, commit, update checklist — then returns
4. When every row has a status, the orchestrator runs verification and writes the domain map

<mark>**The checklist file is the source of truth for progress.** It's what makes the process resumable, auditable, and immune to context degradation.</mark>

---

## Key principles

| Principle | Explanation |
|:----------|:------------|
| **Atomic sessions** | One subagent per commit. Fresh context every time. The checklist file carries the state |
| **Commit-by-commit** | Walk the upstream history in chronological order. Each commit is a decision point: apply or skip |
| **Adapt, don't copy** | Source code is written for a different stack. Translate the intent of each commit into the target technologies |
| **Skip what's irrelevant** | Config files, CI pipelines, framework boilerplate from the source stack — skip these entirely |
| **Commit as you go** | After applying each upstream commit, invoke `/commit` in this repo. Keep the history clean and traceable |
| **Preserve the narrative** | The upstream commit messages tell you *why* each change was made. Carry that reasoning forward into your commits |

---

## Execution

<mark>**Read and follow every step in [WORKFLOW.md](WORKFLOW.md).**</mark>

---

## The governing principle

> Walk the upstream history, carry forward the intent, adapt to the target stack, skip what doesn't belong.
