# NP-Next Product Requirements Document

Status: **Approved baseline**  
Repository: `nerfbreak/NP-Next`  
Legacy reference: `nerfbreak/newspage_automation`  
Last baseline: 2026-08-23

## 1. Product

NP-Next is the native fullstack successor to the legacy Newspage automation application. It automates operational workflows against Newspage and distributor data while giving a team a shared operational dashboard.

The target product has **zero runtime dependency on Streamlit**.

## 2. Goals

- Replace Streamlit with native Next.js.
- Keep automation in Python + Playwright workers.
- Expose application behavior through FastAPI.
- Use ARQ + Redis for manually triggered jobs.
- Use Supabase PostgreSQL as persistent source of truth.
- Allow operators to work concurrently on different distributors.
- Enforce one active task per distributor.
- Show active tasks, progress, users, distributors, and worker capacity.
- Support cancellation that actually stops the worker/browser.
- Allow Superuser management of distributors without editing Supabase manually.
- Make execution auditable, observable, and recoverable.
- Preserve verified legacy behavior unless a documented decision changes it.

## 3. Non-goals

Do not introduce:

- Streamlit.
- Celery.
- Celery Beat or business schedulers.
- Cron-based application scheduling.
- Direct browser access to distributor credentials.
- Hardcoded distributor credentials.
- Hardcoded warehouse values such as `GOOD_WHS` or `GUDANG UTAMA`.
- Hardcoded multiplier rules.
- Hardcoded SKU exceptions such as `8021803`/`8021804`.
- A rewrite that changes verified automation behavior merely to make the code look newer.

## 4. Users and Roles

Only two application roles exist.

### SUPERUSER

Initially the project owner. Can manage users, distributors, system settings, SKU rules, multiplier rules, workers, audit logs, execution history, and any task.

### OPERATOR

Can sign in, run supported workflows, browse distributors, view dashboard/task/worker status, view progress, and cancel their own tasks. Operators cannot manage credentials/configuration or cancel another operator's task.

## 5. Product Architecture

```text
Next.js + TypeScript
        |
      HTTP/SSE
        v
FastAPI
   |         \
   |          +----> Supabase PostgreSQL
   v
ARQ + Redis
   |
   v
Python Playwright Workers
   |
   +----> Newspage / SharePoint / external systems
```

Responsibilities:

- **Next.js**: UI, auth UX, searchable selectors, file upload, preview, dashboard, realtime display.
- **FastAPI**: authentication enforcement, RBAC, validation, orchestration, locks, runs, audit, SSE, ARQ control.
- **ARQ/Redis**: queue transport and job lifecycle. No scheduler.
- **Workers**: actual automation, Playwright, heartbeat, progress events, cancellation cleanup.
- **Supabase/PostgreSQL**: persistent business state and configuration.

Redis is transport/state for execution, not the permanent business source of truth.

## 6. Stable Technology Baseline

Only stable/GA/LTS releases are allowed. Never use beta, alpha, RC, canary, experimental, nightly, or `latest` tags as application dependency declarations.

| Component | Baseline | Policy |
|---|---|---|
| Node.js | **24.19.0 LTS** | Pin major/minor and patch in CI/runtime; update only through maintenance PRs |
| Next.js | **16.3.x stable** | Pin exact package version in lockfile; no canary |
| React | **19.2.0 stable** | No experimental/canary React builds |
| TypeScript | **5.9.3** | Stable compiler only |
| Python | **3.13.15** | Conservative production baseline for automation workers |
| FastAPI | **0.141.1** | Stable release |
| Pydantic | **2.13.4** | Stable release; do not use 2.14 pre-releases |
| ARQ | **0.28.0** | Stable release; manual jobs only |
| Playwright Python | **1.62.0** | Stable release |
| Redis | **8.2.x GA** | Use stable patch releases; no RC/nightly |
| pnpm | **10.x stable** | Workspace package manager |
| uv | **0.12.3** | Production/stable package manager |

Version rationale and update procedure live in `docs/VERSION_POLICY.md`.

## 7. Branching and Delivery

Repository workflow:

```text
main
  -> production-ready

develop
  -> integration

feature/*
  -> implementation work
```

Agent work must normally occur on `feature/*`, then merge into `develop`. Production releases come from `main`.

## 8. Authentication

Use Supabase Auth for identity. Application profile data is stored in `profiles` with `role` and `is_active`.

The browser must not receive distributor plaintext passwords or secret server credentials.

## 9. Distributor Management

Superuser manages distributors inside the dashboard. Operators do not need to open Supabase to add or configure a distributor.

Canonical distributor fields:

```text
id
name
code
username
encrypted_password
warehouse
stock_import_mapping JSONB NULL
is_active
created_by
updated_by
created_at
updated_at
```

All distributors use the same global Newspage login URL. `base_url` does not belong to a distributor.

The fleet is 95+ distributors and may grow, so all distributor selectors must be searchable.

Disabled distributors cannot start new jobs.

## 10. Distributor Concurrency

Lock scope is **one distributor**, never the entire system and never one user.

Active states:

```text
queued
running
cancelling
```

PostgreSQL is authoritative. A distributor can have at most one active run. Different distributors can run concurrently.

Example:

```text
Distributor A -> Budi  -> running/locked
Distributor B -> Sinta -> running/locked
Distributor C -> available
```

The UI must disable Run for a locked distributor and show who is using it, while keeping other distributors available.

## 11. Dashboard

Dashboard is the shared operational control center.

It must show:

- worker total, standby, busy, offline/error
- active and queued tasks
- distributor locked/available state
- user running each task
- workflow type
- assigned worker
- current step
- progress
- start time/duration
- recent runs

No manual refresh loop should be required. SSE is the initial realtime transport.

## 12. Worker Lifecycle

Worker states:

```text
starting
standby
busy
stopping
offline
error
```

Initial model: one worker handles one active automation.

Baseline heartbeat:

```text
interval = 15s
stale threshold = 180s
```

Both are configurable. A worker crash must not leave a distributor locked forever.

Worker capacity may scale dynamically according to queue pressure. Infrastructure owns worker provisioning; application code exposes/records capacity and queue metrics rather than spawning servers itself.

## 13. Automation Run Lifecycle

```text
queued
  -> running
       -> completed
       -> failed
       -> stale
       -> cancelling
            -> cancelled
```

A run stores:

- workflow type
- distributor
- requester
- worker
- current step
- progress
- timestamps
- heartbeat
- parser configuration snapshot
- timeout configuration snapshot
- retry configuration snapshot
- result summary
- errors
- metadata

Snapshots are required for reproducibility.

## 14. Cancellation

Cancellation must terminate execution, not merely set a status flag.

```text
cancel request
 -> permission check
 -> status = cancelling
 -> abort ARQ job
 -> cancel worker coroutine
 -> close/terminate Playwright browser/context/processes
 -> verify execution stopped
 -> status = cancelled
 -> release distributor lock
 -> worker = standby
```

The distributor lock is not released before actual automation stops.

Operator can cancel own task. Superuser can cancel any task.

## 15. Adaptive Timeout

Timeout is dynamic and separated into:

- navigation timeout
- element/action timeout
- overall job timeout

Baseline guidance:

```text
navigation      60s
navigation max  180s
action          30s
action max      60s
overall         30m baseline
overall max     several hours
```

Timeout may extend while progress/heartbeat remains healthy or a known slow network step is active, but a configurable hard ceiling always exists.

ARQ infrastructure timeout is a safety ceiling, not the only business timeout mechanism.

## 16. Realtime Events

Run events:

```text
run.created
run.started
run.progress
run.cancelling
run.completed
run.failed
run.cancelled
```

Worker events:

```text
worker.online
worker.standby
worker.busy
worker.offline
worker.error
```

Distributor events:

```text
distributor.locked
distributor.unlocked
```

Sensitive credentials and secrets must never appear in realtime events.

## 17. Inventory Adjustment

Inventory Adjustment is the first migration vertical slice.

Canonical flow:

```text
Select Distributor
 -> Upload Distributor Stock Excel
 -> Load distributor configuration
 -> Load global parser default
 -> Apply optional distributor JSONB override
 -> Auto-detect mapping
 -> Show dropdowns
 -> Optional user override
 -> Parse distributor stock
 -> Parse fixed INVT_MASTER
 -> Normalize SKU
 -> Filter by distributor.warehouse
 -> Apply distributor multiplier
 -> Aggregate
 -> Compare
 -> Review
 -> Create automation_run
 -> Enqueue ARQ by run_id
 -> Playwright worker
```

### 17.1 Distributor Excel mapping

Legacy compatible global default:

```text
SKU column       -> zero-based index 20
Quantity column  -> preferred header "StokAkhir"
Quantity fallback-> zero-based index 71
```

Mapping priority:

```text
user override > distributor stock_import_mapping JSONB > global default
```

Dropdowns remain intentionally available for flexibility. The operator must not be forced to map columns from scratch every upload.

The final mapping used for an executed run is snapshotted.

### 17.2 INVT_MASTER

`INVT_MASTER` is a fixed Newspage integration contract. It follows the verified legacy format. Operators do not configure it row-by-row or with manual column mappings.

### 17.3 SKU leading zero rules

Global rule table contains the currently verified SKUs:

```text
135428
137118
137120
167209
172130
172131
205901
22583
22595
260656
260659
304095
304100
304102
304157
304161
304164
323044
372264
373100
373103
373104
373105
373106
373108
373110
373112
```

Each rule prepends exactly one zero:

```text
135428 -> 0135428
137118 -> 0137118
22583  -> 022583
373112 -> 0373112
```

Never use `zfill()` for these rules because `22583` must become `022583`, not `0022583`.

`8021803` and `8021804` are normal SKUs and have **no hardcoded exclusion list**.

### 17.4 Multiplier rules

Multipliers are scoped by `distributor_id + sku`.

Constraint:

```text
distributor_id + sku = unique
```

Multiplier is applied to distributor quantity **before aggregation and comparison**.

### 17.5 Warehouse

Warehouse is always read from `distributors.warehouse`.

Forbidden legacy hardcodes:

```text
GOOD_WHS
GUDANG UTAMA
distributor exception dictionaries
```

### 17.6 Comparison

Canonical formula:

```text
Selisih = Distributor - Newspage
```

Examples:

```text
Newspage 100 + Distributor 80  = -20
Newspage 100 + Distributor 120 = +20
```

`Selisih` becomes the execution adjustment quantity.

Review table must show at minimum:

```text
SKU
Newspage Qty
Distributor Qty
Multiplier
Selisih
Status
```

Execution is explicit and occurs only after review.

## 18. Other Workflows

The same architecture is applied to:

- Sales Extraction
- Promotion Comparison
- Stock Mutation
- Clearance Stock
- Initial Stock

Each workflow must preserve verified legacy behavior and adopt the common run/worker/audit/cancel model.

## 19. Data Model

Core tables:

```text
profiles
system_settings
distributors
sku_leading_zero_rules
distributor_sku_multipliers
workers
automation_runs
automation_run_items
automation_run_events
automation_run_artifacts
audit_logs
```

Supabase/PostgreSQL is persistent source of truth. Redis is queue/execution transport.

## 20. API Surface

Core API patterns:

```text
GET  /api/v1/me
GET  /api/v1/dashboard/summary
GET  /api/v1/dashboard/active-runs
GET  /api/v1/dashboard/workers
GET  /api/v1/distributors?q=...
GET  /api/v1/distributors/{id}
POST /api/v1/admin/distributors
PATCH /api/v1/admin/distributors/{id}
POST /api/v1/admin/distributors/{id}/enable
POST /api/v1/admin/distributors/{id}/disable
GET  /api/v1/admin/sku-leading-zero-rules
POST /api/v1/admin/sku-leading-zero-rules
GET  /api/v1/admin/distributors/{id}/multipliers
POST /api/v1/admin/distributors/{id}/multipliers
POST /api/v1/inventory/preview
GET  /api/v1/inventory/previews/{id}
GET  /api/v1/inventory/previews/{id}/items
POST /api/v1/inventory/runs
GET  /api/v1/runs/{id}
GET  /api/v1/runs/{id}/events
POST /api/v1/runs/{id}/cancel
```

Detailed contracts live in `docs/API.md`.

## 21. ARQ Contract

Jobs are manually triggered. No scheduler is required.

Payload rule:

```python
await redis.enqueue_job("run_inventory_adjustment", run_id)
```

Never place username/password, warehouse config blobs, or secret tokens in the ARQ payload.

Worker loads run/distributor/configuration server-side.

Inventory mutation jobs must not be blindly auto-retried after a partial execution.

## 22. Security

- Encrypt distributor credentials at rest.
- Never return plaintext password after storage.
- Never place credentials in ARQ payloads.
- Never log credentials.
- Never emit credentials through SSE.
- Keep server/service credentials server-side.
- Use Supabase Auth for identity.
- Keep sensitive operational tables protected by RLS/server-side access.
- Audit configuration changes and destructive operations.
- Never commit `.env`, secrets, tokens, or credential dumps.

## 23. Testing

Required layers:

```text
unit
integration
API
worker
Playwright automation
E2E
```

Critical invariants:

1. Maximum one active run per distributor.
2. Different distributors can run concurrently.
3. One worker runs one active automation initially.
4. Cancellation stops actual automation resources.
5. Credentials never appear in logs/events/ARQ payloads.
6. Multiplier runs before comparison.
7. `Selisih = Distributor - Newspage`.
8. Leading-zero rules prepend exactly one zero.
9. `8021803` and `8021804` remain normal SKUs.
10. INVT_MASTER remains fixed.
11. Warehouse comes from distributor configuration.
12. Default Excel mapping remains compatible with legacy.

## 24. Migration Strategy

```text
nerfbreak/newspage_automation
= legacy reference only

nerfbreak/NP-Next
= new project source of truth
```

Migration order:

```text
1. Stable version baseline
2. Supabase schema
3. Auth foundation
4. Distributor management
5. Run state + distributor locking
6. Worker registration/heartbeat
7. Inventory Adjustment vertical slice
8. Dashboard + SSE
9. Hard cancellation + recovery
10. Remaining workflows
11. Security/audit hardening
12. Legacy cleanup
13. Remove Streamlit completely
```

`playwright_engine.py`, `data_processor.py`, and `error_taxonomy.py` may be directly refactored/decomposed. Protect verified behavior, not file boundaries.

## 25. Native Fullstack Rule

New code must never import or depend on Streamlit.

Forbidden:

```text
streamlit
st.*
st.session_state
st.cache_*
st.secrets
Streamlit page routing
Streamlit auth/session handling
```

Final runtime contains no Streamlit dependency.

## 26. Definition of Done

A feature is done only when:

- PRD requirements are satisfied.
- Relevant tests pass.
- Business invariants are covered.
- Security requirements are satisfied.
- Persistent state is correct.
- Lock/cancel/recovery behavior is verified when applicable.
- Required realtime events exist.
- Required audit entries exist.
- Documentation/contracts are updated.
- No forbidden dependency was introduced.
- No unreviewed version upgrade was introduced.

Automation work additionally requires verified worker execution and cleanup on both success and failure/cancellation paths.

## 27. Acceptance Criteria

### AC-001 Native fullstack

A clean NP-Next checkout runs with Next.js + FastAPI + workers. Streamlit is unnecessary and absent from runtime dependencies.

### AC-002 Per-distributor lock

When Distributor A is running under Budi, Sinta cannot start Distributor A but can start Distributor B.

### AC-003 Dashboard lock visibility

Locked distributor shows current user/workflow/started time and disables only that distributor's Run action.

### AC-004 Worker visibility

Dashboard accurately shows standby, busy, offline/error workers and their active assignment.

### AC-005 Manual jobs only

No business automation starts without an explicit product trigger.

### AC-006 Excel defaults

Legacy-format distributor stock defaults to SKU index 20 and quantity `StokAkhir`, falling back to index 71.

### AC-007 Mapping override

Operator can change mapping through dropdowns before processing.

### AC-008 SKU normalization

`135428 -> 0135428`, `22583 -> 022583`, and `8021803 -> 8021803`.

### AC-009 Multiplier

Raw distributor quantity 50 with multiplier 2 becomes 100 before comparison.

### AC-010 Comparison

Newspage 100 and Distributor 80 produce `Selisih = -20` and execution quantity `-20`.

### AC-011 Cancellation

Authorized cancellation reaches `cancelling`, aborts the ARQ job, stops Playwright resources, persists `cancelled`, releases the distributor lock, and returns the worker to standby.

### AC-012 Credential safety

Plaintext credentials never appear in ARQ payloads, logs, SSE events, or post-storage frontend responses.

### AC-013 Reproducibility

Executed run stores parser, timeout, and retry snapshots.

### AC-014 Audit

Administrative changes record actor, action, entity, before/after data when appropriate, and timestamp.

### AC-015 Stable versions

CI/build environments reject beta/canary/RC/nightly dependencies and use the approved version baseline.

## 28. Locked Decisions

1. Project repo: `nerfbreak/NP-Next`.
2. Legacy repo: reference-only.
3. Streamlit: removed completely.
4. Frontend: Next.js + TypeScript.
5. Backend: FastAPI.
6. Queue: ARQ + Redis.
7. Scheduler: not required.
8. Automation: Python + Playwright.
9. Roles: Superuser + Operator.
10. Lock: per distributor.
11. Different distributors can run concurrently.
12. Distributor config includes credential, warehouse, and optional JSONB parser override.
13. Login URL is global.
14. Distributor selector is searchable.
15. Global stock parser defaults: SKU index 20; quantity header `StokAkhir`; fallback index 71.
16. Dropdown overrides remain available.
17. INVT_MASTER is fixed.
18. Leading-zero rules are global.
19. `8021803` and `8021804` have no special hardcoded exclusion.
20. Multiplier rules are per distributor.
21. Multiplier applies before aggregation/comparison.
22. `Selisih = Distributor - Newspage`.
23. Cancellation terminates actual worker/browser execution.
24. Heartbeat and adaptive timeout are required.
25. PostgreSQL is source of truth.
26. Redis is queue transport, not permanent business state.
27. Run configuration snapshots are required.
28. Verified legacy behavior is preserved unless deliberately changed.
29. Stable/GA/LTS dependencies only; beta/canary/RC/nightly are forbidden.
30. `feature/* -> develop -> main` is the default delivery flow.
