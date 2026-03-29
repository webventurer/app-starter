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

Add `.env` to `.gitignore`.

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

## Deployment (Railway)

1. Connect your GitHub repo in Railway
2. Add a Neon Postgres database (or provision one in Railway)
3. Set environment variables in Railway dashboard
4. Railway auto-detects the Vite build and deploys on push

## Coding conventions

- TypeScript strict mode
- Feature-based directory structure (not file-type-based)
- Collocate tests next to source files (`Component.tsx` + `Component.test.tsx`)
- Use React Query for all server state — no `useEffect` + `useState` for API calls
- CSS transitions first, Motion when interactive, GSAP when cinematic
- Zod schemas for all API request/response validation
