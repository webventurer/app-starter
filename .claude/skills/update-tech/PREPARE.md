# Prepare: update tech

## Inputs

| Input | Required | Source |
|:------|:---------|:-------|
| **Start commit** | Only on first run | User or `.tech-commit-ref` |

## Before starting

1. Check for `.tech-commit-ref` in the project root
2. If missing, show `git log --oneline -20` and ask which commit to start from — write their answer to `.tech-commit-ref`
3. Ensure `docs/tech-changes/` directory exists — create it if not
4. Read `assets/TEMPLATE.md` to confirm the template is available

## Commit ref file format

`.tech-commit-ref` contains a single line — the full SHA of the last processed commit:

```text
a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2
```

## Cleanup

No session artifacts to clean up — the cursor file and tech change documents are persistent outputs.
