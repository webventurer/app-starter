# Starter app stack

A good starting point for building a modern web app. React + TypeScript + Vite on the frontend, Hono + Neon + Clerk + Drizzle on the backend, with sensible defaults for styling, animation, data fetching, and hosting. <mark>Each piece is independently replaceable — swap one layer without rewiring the rest.</mark>

Scaffold with `pnpm create vite@latest` and add pieces as needed.

## Why Vite, not Next.js

**Vite for apps. Next.js for content.** This stack is for interactive applications — dashboards, tools, SaaS products. Vite gives you a fast build with no framework opinions about routing, data fetching, or server components. Next.js shines for content-driven sites (blogs, marketing pages, docs) where SSR, ISR, and SEO matter — but its abstractions add complexity that apps don't need.

## Core technologies

- **Framework:** React 19 + TypeScript
- **Build tool:** Vite
- **Styling:** Tailwind CSS + shadcn/ui (Radix primitives)
- **Animation:** CSS transitions first, then Motion, then GSAP — see [animation choice](#animation) below
- **Routing:** React Router v6 — see [routing choice](#routing) below
- **Data fetching + server state:** TanStack React Query — handles caching, background refetching, loading/error states
- **Client state:** React `useState` / `useReducer` for UI state (modals, toggles, form inputs) — add Zustand if it outgrows local state
- **Charts:** Recharts
- **Forms:** React Hook Form + Zod validation
- **Icons:** Lucide React
- **Linting + formatting:** Biome — replaces ESLint + Prettier in one tool, faster, simpler config
- **Testing:** Vitest + Testing Library + jsdom
- **Dark mode:** Tailwind class-based dark mode + a small custom hook

**Backend & services:**

- **API layer:** Hono (REST) — see [API layer](#api-layer) below
- **Auth:** Clerk
- **ORM:** Drizzle
- **Database:** Neon (Postgres)
- **Hosting:** Railway
- **Email:** Loops.so
- **Payments:** Stripe
- **Analytics:** PostHog

## Why these choices

### Routing

Vite has no built-in router, so you pick one. Two real options:

| | React Router v6 | TanStack Router |
|:--|:-----------------|:----------------|
| **Maturity** | Established, massive ecosystem | Newer, smaller community |
| **Docs/examples** | Abundant | Growing but thinner |
| **Type safety** | Partial — paths are strings | Full — routes, params, and search params are typed |
| **React Query integration** | Manual | Built-in — route loaders use React Query directly |
| **Learning curve** | Lower — most React devs already know it | Higher — new concepts (route trees, search param validation) |

**Our default: React Router v6** — established, massive ecosystem, abundant docs. Most React devs already know it. TanStack Router is a good alternative if you want type-safe routing and built-in React Query integration — it keeps you in the same TanStack ecosystem you're already using for data fetching.

### Animation

Start with CSS. Reach for a library only when CSS can't do the job. Each level handles different complexity:

| Complexity | Use | Examples |
|:-----------|:----|:---------|
| **Simple** | **CSS transitions/animations** — no dependency, browser-native, performant | Hover effects, fade-ins, colour changes, simple transforms |
| **Interactive** | **Motion** — declarative React props for state-driven animation | Mount/unmount transitions, layout changes (FLIP), drag gestures, spring physics |
| **Cinematic** | **GSAP** — imperative timeline control for complex sequences | Scroll-driven storytelling, SVG morphing, coordinated multi-element timelines, Canvas/WebGL |

<mark>**Don't install Motion for a hover effect. Don't install GSAP for a modal transition.** Match the tool to the complexity.</mark>

See [Motion stack doc](../../stack/research/motion.md) and [GSAP vs Motion comparison](../../stack/research/gsap-vs-motion.md) for full details.

### UI library

**shadcn/ui** — copy-paste components built on Radix primitives. You own the code, style it however you want, and the bundle only includes what you use. Initialise with **Radix** (the component library) and the **Nova** preset (Lucide icons + Geist font) — Nova is just a starting theme you'll restyle anyway.

| Alternative | Why not |
|:------------|:--------|
| **[MUI](https://mui.com)** | High lock-in, recognisably Google unless heavily themed, ~80–100KB gzip for core + icons |
| **Chakra UI** | Heavier runtime than shadcn, opinionated theme system you fight against |
| **Mantine** | Good library but larger API surface — shadcn is simpler and more composable |

### API layer

The stack covers the frontend and the database — but how do they talk to each other?

| Option | Sweet spot | Trade-off |
|:-------|:-----------|:----------|
| **Hono** | Lightweight, fast, runs anywhere (serverless, edge, Node) — modern REST | No built-in type sharing with the client |
| **tRPC** | End-to-end type safety — database types flow through ORM to API to frontend with no manual schema sync | Couples client and server; needs a monorepo; harder if you need a public API |
| **Express** | Most documented Node.js server, massive middleware ecosystem | Heavier than Hono, less modern API design |

**Our default: Hono** — lightweight REST that works everywhere. Universal pattern, any client can consume it, easy to reason about. Reach for tRPC when both client and server are TypeScript in a monorepo and you want end-to-end type safety without maintaining API schemas.

### Authentication

- **Clerk** — hosted auth with prebuilt components, good DX, handles OAuth/MFA out of the box. If Clerk's pricing becomes a problem at scale, **Better Auth** or **Auth.js** are self-hosted alternatives

### ORM

- **Drizzle** — pure TypeScript, no binary engine, lighter in serverless, closer to SQL than Prisma. Connects to Neon via the `@neondatabase/serverless` driver

### Database

The real trade-off is **modular vs bundled**. Supabase and Firebase aren't "more advanced" — they're more bundled. Neon + Clerk + Drizzle is the more *modular* choice. The question is how much you value being able to swap pieces later.

| Approach | Pros | Cons |
|:---------|:-----|:-----|
| **Neon + Clerk + Drizzle** | Each piece replaceable, standard Postgres, no vendor coupling | You wire it all together yourself |
| **Supabase** | Auth + DB + realtime + storage in one dashboard | Tempting to lean on Supabase-specific APIs that lock you in |
| **Firebase** | Fastest from zero to working prototype, offline sync for free | **Hardest to leave** — Firestore's data model doesn't map to anything else |

**Our default: Neon + Clerk + Drizzle** — you learn each layer properly, and if one piece stops fitting, you swap just that piece. Supabase bundles convenience at the cost of understanding what each layer does independently.

**Reach for Supabase when:** you want auth, realtime, and storage bundled together without wiring separate services — and it's still Postgres underneath, so the exit cost is manageable. If you go this route, use Supabase Auth instead of Clerk — no point running two auth systems.

**Reach for Firebase when:** you're building a mobile-first app with offline sync. For web apps, the lock-in cost rarely justifies the speed gain.

### Database feature comparison

| Concern | Neon | Supabase | Firebase |
|:--------|:-----|:---------|:---------|
| **Database** | Postgres | Postgres | Firestore (NoSQL) |
| **Auth** | Bring your own (Clerk) | Built-in (GoTrue) | Built-in (Firebase Auth) |
| **Realtime** | No | Yes (Postgres changes) | Yes (Firestore listeners) |
| **Storage** | No | Yes (S3-compatible) | Yes (Cloud Storage) |
| **Edge functions** | No | Yes (Deno) | Yes (Cloud Functions) |
| **Offline support** | No | No | Yes (Firestore offline cache) |
| **Pricing model** | Pay for compute | Pay for usage | Pay for reads/writes/storage |
| **Vendor lock-in** | Low — standard Postgres | Low — standard Postgres | **High** — proprietary APIs |

### Hosting

| Option | Sweet spot | Trade-off |
|:-------|:-----------|:----------|
| **Railway** | Full-stack apps with databases — deploy from git, provision Postgres/Redis in clicks | Smaller ecosystem than the big clouds |
| **Google Cloud (Cloud Run)** | Containerised apps that scale to zero — pay only for requests | More setup, GCP console complexity |
| **Vercel** | Frontend and edge functions — works with Vite apps, but its main edge is Next.js integration | Backend-heavy apps outgrow it quickly |
| **Fly.io** | Apps needing low latency globally — runs containers at the edge | Debugging distributed deploys is harder |
| **Cloudflare Pages** | Static sites and edge workers — cheapest option, very fast CDN | Limited runtime (no Node.js, Workers runtime only) |

**Our default: Railway** — simplest path from git push to running app with a database. Reach for GCloud (Cloud Run) when you need scale-to-zero containerised deploys or are already in the GCP ecosystem.

### Services

- **Email:** Loops.so — built for product email (onboarding, transactional, drip). Resend is a good alternative for transactional-only
- **Payments:** Stripe — industry standard, best docs, widest payment method support
- **Analytics:** PostHog — open source, self-hostable, combines product analytics + session replay + feature flags. Mixpanel and Amplitude are alternatives if you want a pure analytics SaaS

### Scalability & data strategy

Start with **Neon/Postgres** (or Supabase Postgres). Reach for a dedicated analytics store when query patterns diverge from your app database — typically when you're aggregating millions of events or running analytical queries that would slow down your transactional DB.

| Option | Reach for when |
|:-------|:---------------|
| **ClickHouse** | High-volume event data, real-time aggregations, self-hosted or cloud |
| **BigQuery** | Already in GCP, need serverless analytics on massive datasets |
| **Snowflake** | Enterprise data warehousing, multi-cloud, heavy BI workloads |
