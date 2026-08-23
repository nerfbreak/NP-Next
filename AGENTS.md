# NP-Next Agent Operating Rules

## Mission
Build the native fullstack Newspage Automation rewrite in `nerfbreak/NP-Next`. The legacy repository `nerfbreak/newspage_automation` is reference-only.

## Required reading

Always read:
1. `PRD.md`
2. `docs/AI_CONTEXT.md`
3. task-relevant docs in `docs/`
4. relevant `.opencode/rules/*.md`
5. the current implementation and legacy source when changing verified behavior

## Agent map

- `architect`: planning, boundaries, ADRs, migration design
- `backend`: FastAPI, Supabase, RBAC, locks, runs, API, SSE, audit
- `frontend`: Next.js, React, Tailwind, shadcn/ui, dashboard/UI
- `worker`: ARQ, Redis, Playwright, heartbeat, timeout, cancel, cleanup
- `migrator`: legacy tracing, characterization, behavior-preserving migration
- `qa`: acceptance, integration, regression, worker, Playwright, E2E verification
- `reviewer`: read-only final quality/security/architecture gate

Use the smallest set of agents needed for a task. Do not fan out every task to every agent.

## Architecture

```text
Next.js + TypeScript
        -> FastAPI
        -> Domain/Services
        -> ARQ + Redis
        -> Playwright Workers
        -> External systems

FastAPI/Workers -> Supabase PostgreSQL/Auth/Storage
```

## Stable version policy

Use only stable/GA/LTS runtime releases. Never introduce beta, alpha, RC, canary, nightly, experimental, dev, or floating `latest` runtime dependencies. Dependency versions are governed by `docs/VERSION_POLICY.md` and `.opencode/rules/90-version-policy.md`.

## Forbidden

- Streamlit
- Celery/Celery Beat
- scheduler-driven business execution
- hardcoded distributor credentials
- hardcoded distributor warehouse
- hardcoded multiplier rules
- hardcoded SKU exceptions, including `8021803` and `8021804`
- credentials in logs, events, queue payloads, screenshots, browser state, or frontend state
- frontend Playwright/browser automation
- direct operator configuration through the Supabase dashboard for normal workflows
- unrelated dependency upgrades

## Business invariants

- A distributor can have at most one active automation run.
- Other distributors remain runnable while one distributor is busy.
- Cancellation must stop automation/browser execution before releasing the distributor lock.
- One worker handles one active automation initially.
- Worker state exposes standby/busy/offline information.
- INVT_MASTER is a fixed legacy-compatible contract.
- SKU leading-zero rules are data-driven and prepend exactly one zero.
- `8021803` and `8021804` are normal SKUs unless an explicit future rule changes that.
- Multiplier is scoped by distributor + SKU and applied before aggregation/comparison.
- `Selisih = Distributor - Newspage`.
- Warehouse comes from `distributors.warehouse`.
- Distributor Excel defaults are SKU index 20 and quantity `StokAkhir`, fallback index 71; dropdown override remains available.

## Workflow

```text
plan -> implement -> focused tests -> QA -> review -> commit -> PR
```

Prefer vertical slices. Inventory Adjustment is the first migration slice.

## Migration

`playwright_engine.py`, `data_processor.py`, and `error_taxonomy.py` may be decomposed directly. Protect verified behavior, not legacy file boundaries. Do not migrate Streamlit state, secrets, hardcoded warehouse values, or exception hacks into the target system.

## Security

Never commit secrets. Never return plaintext distributor passwords after storage. Keep service credentials server-side. Add tests for credential non-exposure.

## Database

PostgreSQL is source of truth. Redis is queue transport. Important concurrency invariants must be enforced by the database as well as application checks.

## Done means done

A change is complete only when relevant tests pass, acceptance criteria are covered, contracts/docs are updated, security is preserved, and no forbidden dependency or unstable version is introduced.
