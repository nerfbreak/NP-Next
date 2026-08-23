# Architecture Decisions

## ADR-001: Native fullstack
Streamlit is removed from the target architecture.

## ADR-002: ARQ instead of Celery
Jobs are manually triggered; a scheduler is unnecessary.

## ADR-003: Per-distributor concurrency
One distributor may run one automation at a time. Other distributors remain runnable.

## ADR-004: Worker visibility
Dashboard exposes standby/busy/offline worker state and active run ownership.

## ADR-005: Hard cancellation
Canceling a run must terminate the active browser/automation execution.

## ADR-006: Configuration over hardcode
Warehouse, credentials, SKU rules and multipliers are data/configuration driven.

## ADR-007: INVT_MASTER compatibility
INVT_MASTER remains a fixed legacy-compatible contract.
