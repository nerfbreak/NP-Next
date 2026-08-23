# NP-Next Product Requirements Document

NP-Next is the native fullstack successor to the legacy `newspage_automation` project. It automates Newspage/distributor workflows for an operations team and provides a shared dashboard for active work, distributor availability, worker capacity, execution progress, and history.

Streamlit is reference-only and is not part of the target product.

## Goals

- Native Next.js + TypeScript frontend.
- FastAPI backend.
- Python + Playwright automation workers.
- ARQ + Redis for manually triggered background jobs.
- Supabase PostgreSQL as persistent source of truth.
- Shared dashboard with active tasks and worker state.
- Per-distributor concurrency locking.
- Real task cancellation that terminates automation resources.
- Superuser-managed distributor configuration.
- Observable, auditable, recoverable executions.
- Preserve verified legacy behavior unless explicitly changed.

## Non-goals

Do not introduce Streamlit, Celery, scheduler/beat/cron business workflows, direct frontend access to credentials, or hardcoded distributor/warehouse/multiplier/SKU exceptions.

## Roles

### SUPERUSER

Manage users, distributors, global settings, SKU rules, multiplier rules, workers, audit logs, execution history, and any task.

### OPERATOR

Run supported workflows, view dashboard/tasks/workers, and cancel their own tasks. Operators cannot manage users, credentials, global rules, or another user's task.

## Target Architecture

```text
Next.js + TypeScript
        |
      HTTP/SSE
        v
FastAPI
   |        \
   |         +--> Supabase PostgreSQL
   v
ARQ + Redis
   |
   v
Python Playwright Workers
   |
   v
Newspage / SharePoint / external systems
```

- Next.js: UI, forms, uploads, dashboard, realtime display.
- FastAPI: auth/RBAC, validation, orchestration, locks, runs, audit, SSE, ARQ control.
- ARQ/Redis: queue transport only. No scheduler.
- Workers: actual automation, heartbeat, events, cleanup.
- Supabase: persistent business state and configuration.

## Authentication

Use Supabase Auth for identity. Application profiles live in `profiles` with `role = superuser | operator` and `is_active`.

## Distributor Management

Superuser manages distributors from the application. Operators do not need to use the Supabase dashboard.

Distributor fields:

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

All distributors share the same Newspage login URL, stored globally in system settings. `base_url` is not a distributor field. `warehouse` belongs to the distributor and is the source of truth for warehouse filtering/selection.

Disabled distributors cannot start new tasks. The distributor fleet is 95+ and growing, so selectors must be searchable.

## Distributor Concurrency

Locking is per distributor, not global and not per user. Active states are `queued`, `running`, and `cancelling`.

A distributor can have at most one active run. Different distributors can run concurrently.

```text
Distributor A -> Budi -> running
Distributor B -> Sinta -> running
Distributor C -> available
```

Backend must enforce the lock regardless of frontend state. PostgreSQL is authoritative through a partial unique index. Frontend disables Run for the locked distributor and shows who is using it; other distributors stay runnable.

## Dashboard

The dashboard must show:

- total/standby/busy/offline workers
- active/queued runs
- locked/available distributors
- user running each task
- workflow type
- worker assignment
- current step
- progress
- start time/duration
- recent execution history

Updates must work without full-page refresh.

## Worker Management

Worker states:

```text
starting
standby
busy
stopping
offline
error
```

One worker handles one active automation initially.

Baseline heartbeat:

```text
interval = 15 seconds
stale threshold = 180 seconds
```

These are configurable. Worker failure must not leave a distributor locked forever.

Worker capacity may scale dynamically with queue pressure. Infrastructure, not the application, provisions/removes workers.

## Automation Run Lifecycle

```text
queued -> running -> completed
                   -> failed
                   -> stale
        -> cancelling -> cancelled
```

A run stores workflow, distributor, requester, worker, current step, progress, heartbeats, parser snapshot, timeout snapshot, retry snapshot, result summary, errors, and timestamps.

Configuration snapshots are required for reproducibility.

## Task Cancellation

Cancellation is real execution cancellation:

```text
Cancel request
  -> permission check
  -> run = cancelling
  -> abort ARQ job
  -> cancel worker coroutine
  -> close/terminate Playwright browser/context/processes
  -> run = cancelled
  -> release distributor lock
  -> worker = standby
```

The lock is not released until execution has actually stopped. Operators cancel their own tasks; Superuser can cancel any task. Cancelled runs remain in history/audit data.

## Adaptive Timeout

Timeout is dynamic. Separate navigation, action, and overall-job limits exist.

Timeout may extend when heartbeat is healthy, progress is being made, a known long-running step is active, or transient network retries are occurring. A configurable hard maximum remains as a safety ceiling.

Initial baselines may be:

```text
navigation: 60s
navigation max: 180s
action: 30s
action max: 60s
overall baseline: 30m
overall max: several hours
```

Exact values are settings. ARQ infrastructure timeout is a safety ceiling, not the only business timeout mechanism.

## Realtime

Use SSE initially.

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

## Inventory Adjustment

Inventory Adjustment is the first migration vertical slice.

Canonical flow:

```text
Select Distributor
 -> Upload Distributor Stock Excel
 -> Load distributor config
 -> Load parser defaults/override
 -> Detect mapping
 -> Show mapping dropdowns
 -> Optional user override
 -> Parse distributor stock
 -> Parse fixed INVT_MASTER
 -> Normalize SKU
 -> Filter distributor warehouse
 -> Apply distributor multiplier
 -> Aggregate
 -> Compare
 -> Review
 -> Create run
 -> ARQ
 -> Playwright worker
```

### Distributor Excel defaults

Preserve legacy behavior:

```text
SKU column
-> zero-based index 20

Quantity column
-> prefer header "StokAkhir"
-> if not found, fallback to zero-based index 71
```

Dropdown mapping remains available. Priority is:

```text
user override > distributor stock_import_mapping JSONB > global default
```

The final mapping used by a run must be snapshotted.

### INVT_MASTER

`INVT_MASTER` is a fixed Newspage integration contract. Operators do not map its columns manually. Format changes are integration changes.

### SKU leading-zero rules

Global rules exist because Excel may drop leading zeroes. Current rules:

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

Each rule prepends exactly one `0`:

```text
135428 -> 0135428
137118 -> 0137118
22583  -> 022583
373112 -> 0373112
```

`8021803` and `8021804` are not hardcoded exceptions.

### Multiplier rules

Multipliers are scoped by `distributor_id + sku`, with at most one active rule per pair. The multiplier is applied to distributor quantity before aggregation/comparison.

### Warehouse

Use `distributors.warehouse`. Do not hardcode `GOOD_WHS`, `GUDANG UTAMA`, or legacy distributor exception mappings.

### Comparison

Canonical formula:

```text
Selisih = Distributor - Newspage
```

Examples:

```text
Newspage 100, Distributor 80  -> -20
Newspage 100, Distributor 120 -> +20
```

`Selisih` becomes the adjustment quantity for execution.

### Review UI

At minimum show:

```text
SKU
Newspage Qty
Distributor Qty
Multiplier
Selisih
Status
```

Execution is a separate explicit action after review.

## Other Workflows

Migrate using the same architecture:

- Sales Extraction
- Promotion Comparison
- Stock Mutation
- Clearance Stock
- Initial Stock

Verified legacy behavior is preserved unless an explicit product decision changes it.

## Security

- Encrypt distributor credentials at rest.
- Never return plaintext credentials after storage.
- Never place credentials in ARQ payloads, logs, or SSE events.
- Server/service credentials stay server-side.
- Sensitive tables are not broadly writable from the browser.
- Administrative/config changes are audited.

## Database

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

PostgreSQL is the source of truth. Redis is queue/execution transport.

## API

Core patterns:

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
POST /api/v1/inventory/preview
GET  /api/v1/inventory/previews/{id}
POST /api/v1/inventory/runs
GET  /api/v1/runs/{id}
POST /api/v1/runs/{id}/cancel
GET  /api/v1/runs/{id}/events
```

Detailed contracts live in `docs/API.md`.

## ARQ

Jobs are manually triggered. No scheduler.

Job payloads use a `run_id`, not credentials:

```python
await redis.enqueue_job("run_inventory_adjustment", run_id)
```

The worker loads run and distributor configuration server-side. Use ARQ abort/cancellation plus explicit Playwright cleanup.

Do not blindly auto-retry inventory mutation after partial execution.

## Testing

Required layers:

```text
Unit
Integration
API
Worker
Playwright/automation
E2E
```

Critical invariants:

1. One distributor has at most one active run.
2. Different distributors may run concurrently.
3. One worker handles one active automation initially.
4. Cancellation stops actual automation resources.
5. Credentials never appear in logs/events/job payloads.
6. Multiplier happens before comparison.
7. `Selisih = Distributor - Newspage`.
8. SKU leading-zero rules prepend exactly one zero.
9. `8021803` and `8021804` are not hardcoded exclusions.
10. INVT_MASTER remains a fixed contract.
11. Distributor warehouse comes from distributor configuration.
12. Default Excel mapping remains legacy-compatible.

## Migration Strategy

```text
nerfbreak/newspage_automation
= legacy reference only

nerfbreak/NP-Next
= new project source of truth
```

Order:

```text
1. Supabase schema
2. Auth foundation
3. Distributor management
4. Run state + distributor locking
5. ARQ worker lifecycle
6. Inventory Adjustment vertical slice
7. Remaining workflows
8. Dashboard + SSE
9. Hard cancellation + recovery
10. Security/audit hardening
11. Legacy cleanup
12. Remove Streamlit completely
```

`playwright_engine.py`, `data_processor.py`, and `error_taxonomy.py` may be directly refactored/decomposed. Protect verified behavior, not file boundaries.

## Native Fullstack Rule

New code must not import or depend on Streamlit.

Forbidden:

```text
streamlit
st.*
st.session_state
st.cache_*
st.secrets
Streamlit routing
Streamlit auth/session handling
```

The final product has zero runtime dependency on Streamlit.

## Definition of Done

A feature is done when the PRD is satisfied, tests pass, business invariants are covered, security is respected, state is persisted correctly, required realtime/audit behavior exists, documentation/contracts are updated, and no forbidden Streamlit dependency is introduced.

Automation features also require worker execution, heartbeat, cancellation, distributor locking, persistence, and failure-path verification.

## Acceptance Criteria

### AC-001 Native frontend

A clean NP-Next checkout uses Next.js for the frontend and FastAPI for the API. Streamlit is not required.

### AC-002 Distributor lock

If Distributor A is running under Budi, Sinta cannot start Distributor A but can start Distributor B.

### AC-003 Dashboard visibility

If Budi runs Distributor A, the dashboard shows it as locked, identifies Budi/workflow, and keeps other distributors available.

### AC-004 Worker visibility

Dashboard accurately shows worker standby/busy/offline state and current assignments.

### AC-005 Manual jobs only

No business automation job is created without an explicit trigger defined by the product.

### AC-006 Excel defaults

Legacy-format stock files default to SKU index 20 and quantity `StokAkhir`, falling back to index 71.

### AC-007 Mapping override

Operators can override detected SKU/quantity/warehouse/active columns via dropdowns.

### AC-008 SKU normalization

`135428` becomes `0135428`; `22583` becomes `022583`; `8021803` remains `8021803` without a special exclusion.

### AC-009 Multiplier

Given raw quantity 50 and multiplier 2, comparison quantity is 100 before comparison.

### AC-010 Comparison

Given Newspage 100 and Distributor 80, `Selisih = -20` and adjustment quantity is -20.

### AC-011 Cancellation

Authorized cancel moves the run through `cancelling`, aborts ARQ, terminates Playwright resources, persists `cancelled`, and only then releases the distributor lock.

### AC-012 Credential safety

Plaintext distributor credentials never appear in ARQ payloads, logs, SSE events, or frontend responses after storage.

### AC-013 Reproducibility

A run stores the parser/timeout/retry configuration snapshot used for that execution.

### AC-014 Audit

Administrative configuration changes record actor, action, entity, and timestamp.

## Locked Decisions

1. Project repo: `nerfbreak/NP-Next`.
2. Legacy repo is reference-only.
3. Streamlit is removed completely.
4. Next.js + TypeScript frontend.
5. FastAPI backend.
6. ARQ + Redis queue.
7. No scheduler required.
8. Python + Playwright workers.
9. Roles: Superuser and Operator only.
10. Lock per distributor.
11. Different distributors can run concurrently.
12. Distributor stores credentials, warehouse, and optional parser override.
13. Login URL is global.
14. Distributor selectors are searchable.
15. Global Excel defaults: SKU index 20; quantity `StokAkhir`, fallback index 71.
16. Dropdown overrides remain available.
17. INVT_MASTER is fixed.
18. Leading-zero rules are global.
19. `8021803` and `8021804` have no special hardcoded exception.
20. Multipliers are per distributor.
21. Multiplier is applied before comparison.
22. `Selisih = Distributor - Newspage`.
23. Cancellation terminates actual worker/browser execution.
24. Worker heartbeat and adaptive timeout are required.
25. PostgreSQL is the source of truth.
26. Redis is queue transport, not permanent business state.
27. Run configuration snapshots are required.
28. Verified legacy behavior is preserved unless deliberately changed.
