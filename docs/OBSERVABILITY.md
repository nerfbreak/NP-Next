# Observability

## Principles

Every automation must answer four questions:

1. Who started it?
2. Which distributor is being used?
3. Which worker is executing it?
4. What is happening right now?

## Persistent observability

`automation_runs` stores business execution state.

`automation_run_events` stores event history.

`workers` stores worker lifecycle and heartbeat.

`audit_logs` stores administrative/configuration actions.

## Event rules

Emit events at important boundaries:

```text
run.created
run.started
run.progress
run.cancelling
run.completed
run.failed
run.cancelled

worker.online
worker.standby
worker.busy
worker.offline
worker.error

distributor.locked
distributor.unlocked
```

Events must be safe for dashboard display. Never include passwords, tokens, cookies, auth headers, or secret configuration values.

## Progress

Progress is a best-effort operational indicator, not a claim of exact completion percentage unless the workflow can calculate it reliably.

Prefer:

```text
current_step
completed_items
total_items
progress
```

over arbitrary percentage updates.

## Logs

Structured logs should include:

- timestamp
- service
- worker/run id where applicable
- event/error code
- workflow
- distributor id/name when safe

Do not log sensitive request bodies or credential-bearing objects.

## Diagnostics

Automation failures may create safe artifacts such as screenshots or trace files. Artifacts are stored in private Supabase Storage and referenced by `automation_run_artifacts`.

## Metrics

Initial metrics:

```text
workers_total
workers_standby
workers_busy
workers_offline
queue_depth
runs_queued
runs_running
runs_completed
runs_failed
runs_cancelled
run_duration_seconds
stale_runs
```

Metrics can be exposed to the deployment platform later; do not build a custom monitoring stack prematurely.
