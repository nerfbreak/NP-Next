# Architecture Rules

Target flow:

```text
Next.js
  -> FastAPI
  -> domain/services
  -> ARQ + Redis
  -> Playwright worker
  -> external systems

FastAPI/worker
  -> Supabase PostgreSQL/Auth/Storage
```

Boundaries:
- Next.js owns presentation, user interaction, uploads, and realtime display.
- FastAPI owns authentication enforcement, authorization, validation, orchestration, run state, locks, audit, and API contracts.
- Domain/services own business rules and transformations.
- ARQ/Redis transports jobs; it is not the permanent business source of truth.
- Workers own browser automation and execution lifecycle.
- Supabase/PostgreSQL is the persistent source of truth.

Prefer thin routes, explicit domain services, typed contracts, and dependency inversion where it reduces coupling.
