---
name: debugging
description: Systematic debugging workflow for NP-Next across frontend, API, worker, and Playwright layers.
---

# Debugging Skill

Use the smallest reproduction first.

Workflow:
1. Reproduce.
2. Capture exact error/state.
3. Localize the failing boundary.
4. Form one or more hypotheses.
5. Add a focused regression test.
6. Implement the smallest safe fix.
7. Run focused tests.
8. Run relevant broader validation.
9. Review logs/state for collateral impact.

For automation failures inspect:
- run state
- worker heartbeat
- ARQ job state
- browser/context lifecycle
- external-system response
- timeout classification
- cancellation/retry behavior

Do not hide failures with broad catches or infinite retries.
