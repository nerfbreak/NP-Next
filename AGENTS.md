# Agent Operating Rules

## Mission
Build the native fullstack Newspage Automation rewrite in `nerfbreak/NP-Next`. The legacy repository is reference-only.

## Required reading order

Before implementation:

1. `PRD.md`
2. `AGENTS.md`
3. `docs/AI_CONTEXT.md` when present
4. relevant `docs/*` domain/workflow document
5. `docs/VERSION_POLICY.md` before dependency changes
6. current implementation and legacy reference before changing verified automation

## Architecture

- Web: Next.js + TypeScript
- API: FastAPI
- Queue: ARQ + Redis
- Browser automation: Python Playwright workers
- Database/Auth: Supabase PostgreSQL/Auth
- Realtime: SSE initially
- Storage: private Supabase Storage for artifacts

## Stable version policy

Use only stable/GA/LTS releases.

Baseline:

```text
Node.js 24.19.0 LTS
Next.js 16.3.x stable
React 19.2.0 stable
TypeScript 5.9.3
Python 3.13.15
FastAPI 0.141.1
Pydantic 2.13.4
ARQ 0.28.0
Playwright Python 1.62.0
Redis 8.2.x GA
pnpm 10.x stable
uv 0.12.3
```

Never use beta, alpha, RC, canary, nightly, experimental, dev builds, or `latest` as runtime dependencies. Do not upgrade versions during unrelated feature work.

## Forbidden

- Streamlit
- Celery
- Celery Beat
- scheduler-based business execution
- hardcoded distributor credentials
- hardcoded distributor warehouse
- hardcoded multiplier rules
- hardcoded SKU exceptions such as `8021803` and `8021804`
- credentials in logs, events, queue payloads, screenshots, or frontend state
- direct browser automation from the frontend
- direct operator edits in Supabase for normal product workflows

## Business invariants

- A distributor can have at most one active automation run.
- Other distributors remain runnable while one distributor is busy.
- Cancellation must terminate automation/browser execution before releasing the distributor lock.
- Worker state must expose standby/busy/offline information.
- One worker handles one active automation initially.
- INVT_MASTER is a fixed legacy-compatible data contract.
- SKU leading-zero rules are data-driven and prepend exactly one zero.
- `8021803` and `8021804` are not hardcoded exclusions.
- Distributor multiplier rules are scoped by distributor + SKU.
- Multiplier is applied before aggregation/comparison.
- `Selisih = Distributor - Newspage`.
- Distributor warehouse comes from `distributors.warehouse`.
- Distributor Excel default mapping is SKU index 20; quantity prefers `StokAkhir`, fallback index 71; dropdown override remains available.

## Workflow

Plan → implement → test → review.

Prefer vertical slices. Inventory Adjustment is the first migration slice.

Do not invent business behavior when legacy behavior can be inspected. Protect verified behavior, not legacy file boundaries.

## Refactoring

`playwright_engine.py`, `data_processor.py`, and `error_taxonomy.py` may be decomposed directly. Extract domain logic and contracts without copying Streamlit dependencies into the new system.

## Security

Never commit secrets. Do not return plaintext distributor passwords after storage. Keep service credentials server-side. Add tests for credential non-exposure.

## Database

PostgreSQL is the source of truth. Redis is queue transport. Concurrency invariants that matter under parallel requests must be enforced by the database as well as application checks.

## Definition of done

Implementation is not done until relevant tests pass, contracts/docs are updated, business invariants are covered, and no forbidden dependency or unstable version is introduced.
