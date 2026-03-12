# Update tech workflow

<mark>**Follow these steps in order. Do not skip any step.**</mark>

---

## Execution sequence

| Step | Action | Detail |
|:-----|:-------|:-------|
| 1 | **Read** the principles | [SKILL.md](SKILL.md) |
| 2 | **Prepare** the session | [PREPARE.md](PREPARE.md) |
| 3 | **Execute** the phases below | This file |

---

## Phase 1: Load commit ref

**Goal**: Determine where to start scanning.

1. Look for `.tech-commit-ref` in the project root
2. If it exists, read the commit hash — this is the **start point** (exclusive)
3. If it does not exist, show recent commits with `git log --oneline -20` and ask: **"Which commit should I start scanning from?"**
4. Write the user's chosen commit hash to `.tech-commit-ref` — this sets the baseline
5. Store the start hash in a variable for Phase 2

---

## Phase 2: Scan commits

**Goal**: Walk the commit history forward and identify technology changes.

1. Run `git log --oneline --reverse <cursor>..HEAD` to get the list of commits to process
2. For each commit, run `git diff <commit>~1 <commit> --name-only` to see changed files
3. Flag a commit as a **potential tech change** if the diff touches:
   - `package.json` (added/removed deps, not just version bumps)
   - Config files (new/deleted/renamed — e.g. `.prettierrc`, `eslint.config.js`, `biome.json`)
   - Significant import changes across multiple source files
4. Skip commits that are purely:
   - Version bumps with no functional change
   - Documentation-only changes
   - Formatting/whitespace changes
5. Collect flagged commits into a list for Phase 3

---

## Phase 3: Document each change

**Goal**: Create a tech change document for each flagged commit.

For each flagged commit:

1. Show the user the commit message and key parts of the diff
2. Ask: **"What was replaced, and why?"** — wait for the user's answer
3. Read `assets/TEMPLATE.md` for the document structure
4. Fill the template with:
   - **Before** — the technology being replaced (from the diff)
   - **Replacement** — the new technology (from the diff)
   - **Why** — the user's stated reason
   - **Commit** — the hash and message
   - **Date** — the commit date
5. Write the document to `docs/tech-changes/<kebab-name>.md`
6. If the change is an addition (no "before"), use the same template with "Before" set to "None — new addition"

---

## Phase 4: Save commit ref

**Goal**: Record progress so the next run continues from here.

1. Write the hash of the last processed commit to `.tech-commit-ref`
2. Report how many commits were scanned and how many changes documented

---

## Stopping rules

- Stop if `git log` returns no commits between cursor and HEAD
- Stop if the user says "skip the rest" — save cursor at the last processed commit
- Stop if an error occurs reading the git history

---

## Verification

Before considering the session complete:

- [ ] All flagged commits have been reviewed with the user
- [ ] Each tech change has a document in `docs/tech-changes/`
- [ ] `.tech-commit-ref` contains the hash of the last processed commit
- [ ] Documents follow the template structure

<mark>**Do not commit.** The user will commit when ready using `/commit`.</mark>
