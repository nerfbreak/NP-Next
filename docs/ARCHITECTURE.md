# Architecture

```text
Next.js
   ↓
FastAPI
   ↓
ARQ / Redis
   ↓
Playwright Worker
   ↓
Newspage

FastAPI / Workers
   ↓
Supabase PostgreSQL
```

## Boundaries

Frontend handles UI, auth presentation, dashboard state and upload initiation. It never performs distributor automation.

FastAPI owns authorization, business orchestration, validation, run lifecycle and database access.

ARQ transports manually triggered jobs. Redis is queue/runtime state, not the business source of truth.

Workers execute Playwright and publish progress/heartbeat/cancellation state.

Supabase is the source of truth for users, distributors, configuration, runs, audit records and persistent workflow results.
