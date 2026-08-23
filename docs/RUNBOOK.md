# Operational Runbook

## Purpose

This document describes safe operational actions for NP-Next after deployment.

## Before starting

Verify:

- Supabase is reachable.
- Redis is reachable.
- API health endpoint is healthy.
- Worker heartbeat is healthy.
- Required environment variables are present.
- No unexpected schema migration is pending.

## Worker health

A worker is healthy when:

```text
status = standby/busy
last_heartbeat_at is fresh
```

Default stale threshold: 180 seconds.

If a worker is stale:

1. Do not immediately restart all workers.
2. Inspect the active run and current distributor.
3. Determine whether the worker process/browser actually stopped.
4. Mark/recover the run according to the recovery workflow.
5. Release the distributor only after execution is confirmed stopped.

## Stuck task

Never release a distributor lock simply because the UI says a task is old.

Check:

- `automation_runs.status`
- `last_heartbeat_at`
- `current_step`
- worker state
- browser/process state

If cancellation is required, use the cancel API so the run moves through `cancelling` and the worker performs cleanup.

## Redis outage

Redis is queue transport. PostgreSQL remains the business source of truth.

During Redis outage:

- do not create duplicate runs manually
- existing persistent run records remain authoritative
- queued jobs may need reconciliation after Redis recovery

## Database outage

Do not execute automation if the worker cannot persist authoritative run state. A worker without reliable state persistence can create duplicate or unrecoverable operations.

## Credential rotation

Use the Superuser distributor configuration UI. Do not edit encrypted credentials directly in SQL.

After rotation:

1. Verify login with a safe read-only workflow.
2. Confirm old credential is not present in logs.
3. Record the configuration audit event.

## Deployment rollback

Rollback rules:

- Application code rollback must not blindly roll back database migrations.
- Check whether the new schema is backward compatible with the previous application version.
- Stop new automation starts before a risky rollback.
- Let active tasks finish or cancel them deliberately.

## Incident evidence

Preserve:

- run id
- distributor
- worker name
- timestamps
- current step
- error code
- safe event logs
- screenshots/artifacts where available

Never attach secrets or cookies to incident records.
