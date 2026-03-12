# {Project Name}

{1-2 sentence description of what the project does and who it's for.}

Created from [app-starter](https://github.com/webventurer/app-starter).

## Getting started

```bash
pnpm install
pnpm dev
```

## Claude Code setup

This project uses [codefu](https://github.com/webventurer/codefu) for AI-assisted development skills and commands. Add if not already cloned:

```bash
gh repo clone webventurer/codefu
gh repo clone webventurer/app-starter
gh repo clone webventurer/{repo-name}
cd {repo-name}
add-codefu.sh
scripts/setup.sh
direnv allow
```

## Commands

<!-- Pull from CLAUDE.md Commands section -->

| Command | Description |
|:--------|:------------|
| `pnpm dev` | {description} |
| `pnpm build` | {description} |
| ... | ... |

## Tech stack

<!-- Populate from docs/stack.md, cross-referenced with package.json.
     Only include categories that have entries. -->

### Frontend

| Technology | Purpose |
|:-----------|:--------|
| {from docs/stack.md "Core technologies" — framework, build, styling, animation, routing, data fetching, charts, icons} | {purpose} |

### Backend

| Technology | Purpose |
|:-----------|:--------|
| {from docs/stack.md "Backend & services" — API, ORM, database, auth, payments} | {purpose} |

### Tooling

| Technology | Purpose |
|:-----------|:--------|
| {from docs/stack.md — linting, testing, package manager} | {purpose} |

### Services

<!-- Only include if service SDKs are in package.json -->

| Technology | Purpose |
|:-----------|:--------|
| {from docs/stack.md "Services" — analytics, email, etc.} | {purpose} |

### Fonts

<!-- Only include if @fontsource packages are in package.json -->

| Font | Usage |
|:-----|:------|
| {from package.json @fontsource packages} | {usage} |
