# Subagent prompt for import replay

The orchestrator sends this prompt to each subagent, replacing `<hash>` and `<message>` with the actual commit details.

---

Process upstream commit `<hash>` for the import into an app-starter project.

Read these files first:
- `references/REPLAY-CHECKLIST.md` — import progress so far
- `docs/tech-spec.md` and `docs/stack.md` — target stack details (if they exist)

Your commit: `<hash>` — `<message>`

## Steps

1. Run: `git show <hash>`
2. Decide: apply or skip
3. If applying: adapt to target stack, verify build with `pnpm build`
4. Invoke `/commit` using the Skill tool to commit (reference upstream hash in body)
5. Update `references/REPLAY-CHECKLIST.md` with the status (`applied`, `skipped`, or `deferred`)

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
- Database models (ActiveRecord, Sequelize, Prisma) → Drizzle schema in `server/db/schema.ts`
- API routes (Express, Rails controllers, Flask) → Hono routes in `server/routes/`
- Views/templates (ERB, EJS, Jinja, jQuery) → React components in `src/features/`
- Auth (Devise, Passport, custom) → Clerk (drop custom auth entirely)
- Tests (RSpec, Jest, Mocha) → Vitest + Testing Library
- CSS frameworks (Bootstrap, Material UI) → Tailwind + shadcn/ui
- Animation (framer-motion) → Motion (`motion/react`)

## Conventions

- Feature-based directory structure (`src/features/<name>/`)
- React Query for data fetching
- Hono for API routes with Zod validation
- The commit should make sense on its own — someone reading the history shouldn't need to see the upstream repo

## Build failure recovery

If `pnpm build` fails after applying:
1. Try to fix the build error (missing import, type issue)
2. If non-trivial, revert with `git restore --staged --worktree .`
3. Mark the commit as deferred in the checklist
