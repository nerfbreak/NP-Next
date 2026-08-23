# NP-Next Product Requirements Document

## 1. Product

NP-Next is the native fullstack successor to `newspage_automation`. It automates Newspage/distributor workflows for an operations team and provides a shared operational dashboard.

Legacy Streamlit is reference-only. Streamlit is not part of the target system and must be removed completely.

## 2. Goals

- Native Next.js frontend.
- FastAPI backend.
- Python + Playwright automation workers.
- ARQ + Redis for manually triggered background jobs.
- Supabase PostgreSQL as persistent source of truth.
- Shared dashboard for team activity and worker capacity.
- Per-distributor concurrency locking.
- Real cancellation that stops the automation worker/browser.
- Superuser-managed distributor configuration.
- Observable, auditable, recoverable executions.
- Preserve verified legacy business behavior unless explicitly changed.

## 3. Non-goals

Do not introduce:

- Streamlit.
- Celery.
- Scheduler/beat/cron-based business workflows.
- Direct frontend access to distributor credentials.
- Hardcoded distributor credentials, warehouse names, multiplier rules, or SKU exceptions.
- Blind rewrites that change verified automation behavior.

## 4. Roles

### SUPERUSER

The owner/admin role. Can manage users, distributors, global settings, SKU rules, multiplier rules, workers, audit logs, execution history, and any task.

### OPERATOR

Can sign in, run workflows, view dashboard/tasks/workers, and cancel their own tasks. Cannot manage users, credentials, global rules, or other users' tasks.

## 5. Target Architecture

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

Responsibilities:

- Next.js: UI, auth UI, forms, uploads, dashboard, realtime display.
- FastAPI: auth enforcement, RBAC, validation, orchestration, locks, runs, audit, SSE, ARQ control.
- ARQ/Redis: queue and job transport only. No scheduler required.
- Workers: actual Playwright automation, heartbeat, events, cleanup.
- Supabase: persistent business state and configuration.

## 6. Authentication

Use Supabase Auth for identity.

Application profile is stored in `profiles`:

```text
id
full_name
role = superuser | operator
is_active
```

Credentials must never be exposed to the browser after storage.

## 7. Distributor Management

Superuser manages distributors from the application UI. Operators do not need to use the Supabase dashboard.

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

All distributors share the same Newspage login URL, stored globally in system settings. `base_url` is not a distributor field.

`warehouse` belongs to the distributor. It is the source of truth for warehouse selection/filtering in workflows.

A disabled distributor cannot start new tasks.

There may be 95+ distributors, so distributor selectors must support search.

## 8. Distributor Concurrency

Locking is per distributor, not per user and not global.

Active run states are:

```text
queued
running
cancelling
```

One distributor may have at most one active run.

Example:

```text
Distributor A -> Budi -> running
Distributor B -> Sinta -> running
Distributor C -> available
```

The backend must reject any second active run for the same distributor regardless of frontend state. PostgreSQL enforces this with a partial unique index.

Frontend must disable the Run action for a locked distributor and show who is using it. Other distributors remain runnable.

## 9. Dashboard

The dashboard is the shared operational control center.

Show:

- total workers
- standby workers
- busy workers
- offline/error workers
- active/queued runs
- active/locked distributors
- available distributors
- user running each task
- workflow type
- worker assignment
- current step
- progress
- start time/duration
- recent runs

Dashboard must update without full-page refresh.

## 10. Worker Management

Worker states:

```text
starting
standby
busy
stopping
offline
error
```

One worker handles one active automation in the initial architecture.

Worker records include heartbeat and current run/distributor.

Baseline heartbeat:

```text
interval: 15 seconds
stale threshold: 180 seconds
```

These values are configurable.

Worker failure must not permanently lock a distributor.

Worker capacity may be scaled dynamically based on queue pressure. Infrastructure is responsible for creating/removing worker processes/containers.

## 11. Automation Run Lifecycle

```text
queued
  |
  v
running
  | \
  |  +--> completed
  |  +--> failed
  |  +--> stale
  v
cancelling
  |
  v
cancelled
```

`automation_runs` stores at minimum:

- workflow type
- distributor
- requested_by
- worker
- status
- current step
- progress
- heartbeats
- parser config snapshot
- timeout snapshot
- retry snapshot
- result summary
- errors
- timestamps

Snapshots are required so historical runs remain reproducible after configuration changes.

## 12. Task Cancellation

Cancellation must terminate real execution, not only update a database row.

```text
Cancel request
  -> verify permission
  -> run = cancelling
  -> abort ARQ job
  -> cancel worker coroutine
  -> close/terminate Playwright browser/context/processes
  -> persist run = cancelled
  -> release distributor lock
  -> worker = standby
```

The lock is not released until the worker has actually stopped.

Operators may cancel their own tasks. Superuser may cancel any task.

Cancelled runs remain in history/audit data.

## 13. Adaptive Timeout

Timeout is dynamic rather than one fixed duration.

Layers:

- navigation timeout
- element/action timeout
- overall job timeout

Timeout may extend while:

- heartbeat is healthy
- progress is being made
- a known long-running step is active
- transient network retry/backoff is occurring

A configurable hard maximum remains as a safety ceiling.

Baseline configuration may start near:

```text
navigation: 60s
avigation max: 180s
action: 30s
action max: 60s
overall baseline: 30m
overall max: several hours
```

Exact values are settings, not business invariants.

ARQ infrastructure timeout is a safety ceiling, not the only business timeout mechanism.

## 14. Realtime

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

## 15. Inventory Adjustment

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

### 15.1 Distributor Excel Defaults

Preserve the legacy default behavior:

```text
SKU column
-> zero-based index 20

Quantity column
-> prefer header "StokAkhir"
-> if not found, fallback to zero-based index 71
```

The UI must still expose column dropdowns so operators can override the defaults.

Mapping priority:

```text
user override
    >
distributor stock_import_mapping JSONB override
    >
global default
```

The final mapping used by a run must be snapshotted in `automation_runs`.

### 15.2 INVT_MASTER

`INVT_MASTER` is a fixed Newspage integration contract. Operators do not map its columns manually.

Changes to its format are integration changes and must be handled in the parser deliberately.

### 15.3 SKU Leading-Zero Rules

Global rules exist because Excel can drop leading zeroes.

Current rules:

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

Each rule means prepend exactly one `0` during normalization.

Examples:

```text
135428 -> 0135428
137118 -> 0137118
22583  -> 022583
373112 -> 0373112
```

There is no hardcoded exception list for:

```text
8021803
8021804
```

They remain normal unless a future explicit rule says otherwise.

### 15.4 Multiplier Rules

Multipliers are scoped to a distributor:

```text
distributor_id + sku
```

Maximum one active rule per distributor/SKU pair.

Multiplier is applied to distributor quantity before aggregation/comparison.

Example:

```text
raw distributor qty = 50
multiplier = 2
comparison qty = 100
```

### 15.5 Warehouse

The warehouse is loaded from `distributors.warehouse`.

Do not hardcode:

- `GOOD_WHS`
- `GUDANG UTAMA`
- legacy distributor exception mappings

### 15.6 Comparison

Canonical formula:

```text
Selisih = Distributor - Newspage
```

Examples:

```text
Newspage 100, Distributor 80  -> Selisih -20
Newspage 100, Distributor 120 -> Selisih +20
```

`Selisih` becomes the adjustment quantity sent to execution.

Only valid mismatches are eligible for execution.

### 15.7 Review UI

Minimum columns:

```text
SKU
Newspage Qty
Distributor Qty
Multiplier
Selisih
Status
```

Execution is a separate explicit action after review.

## 16. Other Workflows

Existing workflow domains to migrate using the same execution architecture:

- Sales Extraction
- Promotion Comparison
- Stock Mutation
- Clearance Stock
- Initial Stock

Each must preserve verified legacy behavior until an explicit product decision changes it.

## 17. Security

- Distributor credentials are encrypted at rest.
- Plaintext credentials are never returned after save.
- Credentials never appear in ARQ payloads.
- Credentials never appear in logs or SSE events.
- Server/service credentials never belong in the frontend.
- Sensitive operational tables must not be broadly writable from the browser.
- Configuration and administrative changes are audited.

## 18. Database

Target core tables:

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

PostgreSQL is the source of truth. Redis is queue/execution transport, not permanent business state.

## 19. Audit

Audit at minimum:

- distributor create/update/enable/disable
- user/role changes
- SKU rule changes
- multiplier rule changes
- global setting changes
- task start/cancel/failure where relevant

Audit records should include actor, action, entity, before/after where appropriate, and timestamp.

## 20. API Expectations

Core endpoints follow these patterns:

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

The exact API contract lives in `docs/API.md`.

## 21. ARQ Contract

Jobs are triggered manually through the API.

ARQ payload should be minimal and contain a run identifier, not credentials:

```python
await redis.enqueue_job("run_inventory_adjustment", run_id)
```

Worker loads the run and distributor configuration server-side.

Use ARQ abort/cancellation plus explicit Playwright cleanup.

Do not implement automatic retry of inventory mutations blindly. A partial stock adjustment must be recoverable by state inspection, not duplicated by a blind re-run.

## 22. Testing

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
4. Cancellation stops the actual automation resources.
5. Credentials never appear in logs/events/job payloads.
6. Multiplier happens before comparison.
7. `Selisih = Distributor - Newspage`.
8. SKU leading-zero rules prepend exactly one zero.
9. `8021803` and `8021804` are not hardcoded exclusions.
10. INVT_MASTER remains a fixed contract.
11. Distributor warehouse comes from distributor configuration.
12. Default distributor Excel mapping stays compatible with the legacy behavior.

## 23. Migration Strategy

Repository roles:

```text
nerfbreak/newspage_automation
= legacy reference only

nerfbreak/NP-Next
= new project source of truth
```

Migration order:

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
11. Remove remaining legacy dependencies
12. Remove Streamlit completely
```

Legacy automation files such as `playwright_engine.py`, `data_processor.py`, and `error_taxonomy.py` may be directly refactored and decomposed. Protect verified behavior, not file boundaries.

## 24. Native Fullstack Rule

No new code may import or depend on Streamlit.

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

The final product must have zero runtime dependency on Streamlit.

## 25. Definition of Done

A feature is done when:

- implementation satisfies the PRD
- tests pass
- relevant business invariants are covered
- security requirements are respected
- run/worker state is persisted correctly
- realtime/audit behavior exists where required
- documentation/contracts are updated when behavior changes
- no forbidden Streamlit dependency is introduced

For automation work, done also means worker execution, heartbeat, cancellation, distributor locking, persistence, and failure paths are verified.

## 26. Acceptance Criteria

### AC-001 Native frontend

Given a clean NP-Next checkout, the application uses Next.js for the frontend and FastAPI for the API. Streamlit is not required.

### AC-002 Distributor lock

Given Distributor A is running under Budi, Sinta cannot start Distributor A, but Sinta can start Distributor B.

### AC-003 Dashboard visibility

Given Budi is running Distributor A, the dashboard shows Distributor A as locked, identifies Budi/workflow, and keeps other distributors available.

### AC-004 Worker visibility

Given workers are registered, the dashboard accurately shows standby/busy/offline state and current assignment.

### AC-005 Manual jobs only

No business automation job is created without an explicit operator/system action defined by the product.

### AC-006 Excel defaults

For a legacy-format distributor stock file, SKU defaults to zero-based index 20. Quantity prefers `StokAkhir`, otherwise falls back to zero-based index 71.

### AC-007 Manual mapping override

Operators can override the detected SKU/quantity/warehouse/active columns via dropdowns before processing.

### AC-008 SKU normalization

`135428` becomes `0135428`; `22583` becomes `022583`; `8021803` remains `8021803` without a special hardcoded exclusion.

### AC-009 Multiplier

Given raw quantity 50 and multiplier 2, comparison quantity is 100 before comparison.

### AC-010 Comparison

Given Newspage 100 and Distributor 80, `Selisih = -20` and the adjustment quantity is -20.

### AC-011 Cancellation

An authorized cancel request moves the run through `cancelling`, aborts the ARQ job, terminates Playwright resources, persists `cancelled`, and only then releases the distributor lock.

### AC-012 Credential safety

No plaintext distributor credential is present in the ARQ payload, logs, SSE events, or frontend response after storage.

### AC-013 Reproducibility

A run preserves the parser/timeout/retry configuration snapshot used for that execution.

### AC-014 Audit

Administrative configuration changes are recorded with actor, action, entity and timestamp.

## 27. Locked Decisions

The following are accepted product decisions unless explicitly changed:

1. Project repo: `nerfbreak/NP-Next`.
2. Legacy repo remains reference-only.
3. Streamlit is removed completely.
4. Next.js + TypeScript frontend.
5. FastAPI backend.
6. ARQ + Redis queue.
7. No scheduler required.
8. Python + Playwright workers.
9. Roles: Superuser and Operator only.
10. Lock per distributor.
11. Different distributors can run concurrently.
12. Distributor stores credential + warehouse + optional parser override.
13. Login URL is global.
14. Distributor selectors are searchable because the fleet is 95+ and growing.
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
