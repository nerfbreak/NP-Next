---
name: release-readiness
description: Final verification workflow before a NP-Next feature is merged or released.
---

# Release Readiness Skill

Verify in this order:
1. PRD/acceptance criteria satisfied.
2. Relevant unit/integration/API/worker/E2E tests pass.
3. No dependency drift or prerelease dependency was introduced.
4. Security checks pass; no credentials/secrets leaked.
5. Database migrations are reviewed and reversible where practical.
6. Operational states, logs, metrics, and audit events are adequate.
7. Cancellation and failure paths are verified for automation work.
8. Documentation/contracts are updated.
9. Working tree is clean and branch contains only intended changes.

For automation releases, explicitly verify distributor locks, worker cleanup, heartbeat/stale recovery, Playwright shutdown, and run-state reconciliation.
