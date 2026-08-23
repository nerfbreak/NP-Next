# Delivery Tasks

This file is the high-level migration board. Detailed implementation work belongs in feature branches and issues/PRs.

## Phase 0 - Foundation

- [x] Select NP-Next as the new repository.
- [x] Establish `main`, `develop`, and `feature/*` workflow.
- [x] Add PRD and architecture/agent documentation.
- [x] Define stable dependency baseline.
- [x] Prepare fresh Supabase schema.

## Phase 1 - Runtime foundation

- [ ] Pin Node/Python/package versions in runtime files.
- [ ] Complete Next.js app shell.
- [ ] Complete FastAPI app shell.
- [ ] Complete ARQ worker shell.
- [ ] Add Redis health checks.
- [ ] Add Supabase connectivity checks.
- [ ] Add CI validation for stable versions.

## Phase 2 - Identity and RBAC

- [ ] Supabase Auth integration.
- [ ] Profile provisioning.
- [ ] Superuser promotion/setup.
- [ ] Operator role checks.
- [ ] API auth middleware.
- [ ] Frontend protected routes.

## Phase 3 - Distributor management

- [ ] Distributor CRUD for Superuser.
- [ ] Credential encryption service.
- [ ] Searchable 95+ distributor selector.
- [ ] Warehouse configuration.
- [ ] Optional `stock_import_mapping` JSONB override.
- [ ] Distributor audit events.

## Phase 4 - Run/lock/worker foundation

- [ ] Automation run service.
- [ ] PostgreSQL distributor lock.
- [ ] Worker registration.
- [ ] Worker heartbeat.
- [ ] Worker state dashboard API.
- [ ] Queue depth metrics.
- [ ] SSE run events.
- [ ] SSE worker/distributor events.

## Phase 5 - Inventory Adjustment

- [ ] Analyze legacy Inventory Adjustment end-to-end.
- [ ] Extract data processing domain logic.
- [ ] Implement fixed INVT_MASTER parser.
- [ ] Implement distributor Excel parser defaults.
- [ ] Keep column dropdown overrides.
- [ ] Implement global SKU leading-zero rules.
- [ ] Implement per-distributor multipliers.
- [ ] Implement distributor warehouse filtering.
- [ ] Implement preview.
- [ ] Implement review UI.
- [ ] Implement ARQ execution.
- [ ] Implement Playwright execution.
- [ ] Implement cancellation.
- [ ] Add regression tests for known SKU cases.

## Phase 6 - Remaining workflows

- [ ] Sales Extraction.
- [ ] Promotion Comparison.
- [ ] Stock Mutation.
- [ ] Clearance Stock.
- [ ] Initial Stock.

## Phase 7 - Hardening

- [ ] Audit coverage.
- [ ] Credential exposure tests.
- [ ] Stale worker recovery.
- [ ] Partial-execution recovery.
- [ ] Artifact storage.
- [ ] Backup/recovery procedure.
- [ ] Production deployment checklist.

## Phase 8 - Legacy removal

- [ ] Remove Streamlit runtime.
- [ ] Remove Streamlit UI/pages.
- [ ] Remove legacy session-state coupling.
- [ ] Remove `EXCLUDE_PREFIX`.
- [ ] Remove hardcoded warehouse constants.
- [ ] Remove legacy distributor exception mapping.
- [ ] Remove obsolete legacy DB adapters.
- [ ] Verify zero Streamlit imports.
