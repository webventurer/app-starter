# Tech spec

Drop this into a new repo's `CLAUDE.md` or `docs/` to tell an AI or developer exactly how to set up the project. This is the actionable version of [stack.md](stack.md) — that doc explains *why*, this one explains *how*.

## Scaffold

```bash
pnpm create vite@latest my-app -- --template react-ts
cd my-app
```

## Install: frontend

```bash
# Core
pnpm add react-router-dom @tanstack/react-query

# Styling
pnpm add -D tailwindcss @tailwindcss/vite
pnpx shadcn@latest init --template vite --base radix --preset nova -y

# Forms + validation
pnpm add react-hook-form zod @hookform/resolvers

# Icons + charts
pnpm add lucide-react recharts

# Animation
pnpm add motion gsap
```

## Install: backend

```bash
# API server
pnpm add hono @hono/node-server

# Auth
pnpm add @clerk/react

# ORM + database
pnpm add drizzle-orm @neondatabase/serverless
pnpm add -D drizzle-kit tsx
```

## Install: services

```bash
pnpm add stripe @stripe/react-stripe-js @stripe/stripe-js
pnpm add posthog-js
pnpm add loops
```

## Install: linting + formatting

```bash
pnpm add -D @biomejs/biome
pnpx @biomejs/biome init
```

## Install: testing

```bash
pnpm add -D vitest @testing-library/react @testing-library/jest-dom jsdom
```

## Install: infrastructure CLIs

Neon, Railway and Clerk are driven from the command line — provisioning, auth config, and deploys all run from the terminal, so the whole loop happens inside Claude with no dashboard clicks. Install once per machine:

```bash
pnpm add -g neonctl @railway/cli   # Neon + Railway
# Clerk runs via npx — no install needed
```

Then authenticate each:

```bash
neonctl auth        # Neon — opens a browser
railway login       # Railway — opens a browser
npx clerk init      # Clerk — links your account (or mints temp dev keys with no account)
```

Every command takes `--help`; reach for it when a flag isn't obvious.

## Install: optional (add when needed)

```bash
# State management — only when useState outgrows local state
pnpm add zustand
```

## Project structure

```
src/
├── components/          # Shared UI components
│   └── ui/              # shadcn/ui generated components
├── features/            # Feature modules (one directory per feature)
│   └── dashboard/
│       ├── components/  # Feature-specific components
│       ├── hooks/       # Feature-specific hooks
│       └── api.ts       # Feature-specific API calls
├── hooks/               # Shared custom hooks
├── lib/                 # Utilities, config, helpers
│   ├── api.ts           # Hono client setup
│   ├── db.ts            # Drizzle + Neon connection
│   └── query-client.ts  # React Query client
├── routes/              # Route components (one per page)
├── styles/              # Global styles
├── App.tsx              # Root component, providers, router
└── main.tsx             # Entry point
server/
├── index.ts             # Hono app entry
├── routes/              # API route handlers
├── db/
│   ├── schema.ts        # Drizzle schema definitions
│   └── migrations/      # Generated migrations
└── middleware/           # Auth, error handling
```

## Configuration

### Vite (`vite.config.ts`)

```typescript
import path from "node:path";
import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
```

### Tailwind

Tailwind v4 uses the Vite plugin — no `tailwind.config.ts`. Configuration is CSS-based:

```css
/* src/index.css */
@import "tailwindcss";
```

### Drizzle (`drizzle.config.ts`)

```typescript
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  schema: "./server/db/schema.ts",
  out: "./server/db/migrations",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

### React Query (`src/lib/query-client.ts`)

```typescript
import { QueryClient } from "@tanstack/react-query";

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60,       // 1 minute
      refetchOnWindowFocus: false,
    },
  },
});
```

### Hono server (`server/index.ts`)

```typescript
import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { cors } from "hono/cors";

const app = new Hono();

app.use("/*", cors());

// Mount route modules here
// app.route("/api/users", usersRoute);

serve({ fetch: app.fetch, port: 3001 });
```

### Drizzle + Neon connection (`src/lib/db.ts`)

```typescript
import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";

const sql = neon(process.env.DATABASE_URL!);
export const db = drizzle(sql);
```

### Vitest (`vitest.config.ts`)

```typescript
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: "./src/test/setup.ts",
  },
});
```

## Environment variables

```bash
# .env (never commit this file)
DATABASE_URL=              # Neon connection string
CLERK_PUBLISHABLE_KEY=     # Clerk frontend key
CLERK_SECRET_KEY=          # Clerk backend key
STRIPE_SECRET_KEY=         # Stripe API key
STRIPE_PUBLISHABLE_KEY=    # Stripe frontend key
POSTHOG_KEY=               # PostHog project key
LOOPS_API_KEY=             # Loops.so API key
```

Add `.env` to `.gitignore`. You don't fill these in by hand: `neonctl connection-string` prints `DATABASE_URL` and `npx clerk init` writes the two `CLERK_*` keys — paste the rest from each service.

## Scripts (`package.json`)

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "lint": "biome check .",
    "format": "biome check --write .",
    "server": "tsx watch server/index.ts",
    "db:generate": "drizzle-kit generate",
    "db:migrate": "drizzle-kit migrate",
    "db:studio": "drizzle-kit studio"
  }
}
```

## Provision & deploy (CLI-first)

The whole loop — database, auth, hosting — runs from the terminal. No dashboard clicks.

### 1. Database with Neon

```bash
neonctl projects create --name my-app
neonctl connection-string --pooled    # prints DATABASE_URL
```

Paste the string into `.env` as `DATABASE_URL`, then push the schema:

```bash
pnpm db:generate && pnpm db:migrate
```

### 2. Auth with Clerk

```bash
npx clerk init        # detects the framework, scaffolds Clerk, writes CLERK_* keys to .env
npx clerk config      # sign-in methods, redirects, session policy
```

### 3. Hosting on Railway

```bash
railway init                                          # create the project
railway variables --set "DATABASE_URL=$DATABASE_URL"  # push env vars (repeat per key)
railway up                                            # deploy
```

Railway hosts the app while Neon stays the database. To run an all-Railway stack instead, `railway add --database postgres` provisions Postgres on Railway and sets `DATABASE_URL` for you.

Take it to production with Clerk's guided deploy:

```bash
npx clerk deploy      # clones the dev instance to production, walks you through DNS + OAuth
```

## Coding conventions

- TypeScript strict mode
- Feature-based directory structure (not file-type-based)
- Collocate tests next to source files (`Component.tsx` + `Component.test.tsx`)
- Use React Query for all server state — no `useEffect` + `useState` for API calls
- CSS transitions first, Motion when interactive, GSAP when cinematic
- Zod schemas for all API request/response validation
