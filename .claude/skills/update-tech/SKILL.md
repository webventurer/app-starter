---
name: update-tech
description: Scan git commits for technology changes since the last run, document each change with before/replacement/reason, and save progress. Use when catching up on tech stack changes after importing a repo or periodically auditing dependencies. Triggers on "update-tech", "tech changes", "scan commits".
---

# Update tech

> Walk the git history forward from a saved cursor, detect technology changes, and document each one.

---

## When to use

- After importing a repo, to catalogue what changed in the upstream
- Periodic audits of dependency or tooling changes
- Building a changelog of tech decisions over time

## When NOT to use

- Adding a brand-new technology to the stack — use [add-to-stack](../add-to-stack/SKILL.md)
- One-off dependency bumps with no functional change

---

## Quick reference

<mark>**The skill is incremental — it reads `.tech-commit-ref`, scans only new commits, documents changes, and writes the ref forward. Each run picks up where the last one left off.**</mark>

---

## Skill documents

| Document | Purpose |
|:---------|:--------|
| [WORKFLOW.md](WORKFLOW.md) | Step-by-step execution process |
| [PREPARE.md](PREPARE.md) | Session setup and commit ref management |
| [assets/TEMPLATE.md](assets/TEMPLATE.md) | Template for each tech change document |

---

## Key principles

| Principle | Explanation |
|:----------|:------------|
| **Incremental** | Never re-scan commits already processed — `.tech-commit-ref` is the source of truth |
| **One document per change** | Each technology swap gets its own file so the history is browsable |
| **Ask why** | Pause and ask the user for the reason behind each change — don't guess motivation |
| **Forward-only** | Always walk commits oldest-to-newest so context builds naturally |

---

## How it detects changes

The workflow looks for signals in each commit's diff:

- **package.json** — added/removed dependencies
- **Config files** — new or deleted configs (e.g. `.eslintrc` → `biome.json`)
- **Import statements** — switched libraries in source files
- **Lock files** — large-scale dependency tree changes

Not every dependency bump is a tech change. Focus on **replacements** (X replaced by Y) and **additions/removals** of significant tools.

---

## Cross-references

| Skill | Relationship |
|:------|:-------------|
| [add-to-stack](../add-to-stack/SKILL.md) | Documents a single technology choice in depth |
| [import](../import/SKILL.md) | Often runs before this skill — imports upstream commits |
| [harvest](../harvest/SKILL.md) | Can distill the generated change docs into a summary |

---

## The governing principle

> A technology change without a recorded reason becomes folklore — update-tech turns folklore into documentation.
