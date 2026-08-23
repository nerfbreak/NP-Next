# Version Policy

## Purpose

NP-Next prioritizes stability and reproducibility over chasing the newest release.

## Approved baseline

| Component | Version |
|---|---|
| Node.js | 24.19.0 LTS |
| Next.js | 16.3.x stable |
| React | 19.2.0 stable |
| TypeScript | 5.9.3 |
| Python | 3.13.15 |
| FastAPI | 0.141.1 |
| Pydantic | 2.13.4 |
| ARQ | 0.28.0 |
| Playwright Python | 1.62.0 |
| Redis | 8.2.x GA |
| pnpm | 10.x stable |
| uv | 0.12.3 |

## Rules

- Never use beta, alpha, RC, canary, nightly, experimental, or dev builds.
- Never use `latest` as a production dependency declaration.
- Lock exact versions in lockfiles.
- Keep Node and Python runtime versions pinned in CI/container/tooling files.
- Patch/security upgrades should be isolated and tested.
- Major/minor upgrades require an explicit decision record and compatibility review.
- Agents must not upgrade dependencies opportunistically while implementing unrelated features.

## Update procedure

1. Identify the security/bugfix reason.
2. Check the official release notes.
3. Confirm the release is stable/GA/LTS.
4. Update the lockfile.
5. Run unit, integration, API, worker, and relevant E2E tests.
6. Review browser compatibility for Playwright changes.
7. Update this document only when the approved baseline changes.
8. Record the change in `DECISIONS.md` or a version-upgrade ADR.

## Current rationale

Python 3.13.15 is intentionally selected over 3.14.x for the initial automation baseline. Python 3.14 is stable, but the project prefers the more conservative automation compatibility baseline while the worker stack is migrated. This is a deliberate stability choice, not a statement that Python 3.14 is beta.

ARQ 0.28.0 is the selected queue library because the project explicitly wants ARQ and no scheduler. ARQ is in maintenance-only mode, so the code must keep the queue abstraction narrow and avoid deep coupling to ARQ-specific internals.

Playwright Python 1.62.0 is the stable browser automation baseline. Browser binaries must be installed from the pinned package during image/build setup.

## Anti-drift check

CI should fail when a dependency resolves to a prerelease or when runtime versions differ from the approved baseline.
