# Release Process

## Branch flow

```text
feature/* -> develop -> main
```

## Pre-release checklist

- Relevant unit tests pass.
- Integration/API tests pass.
- Worker tests pass.
- Relevant Playwright tests pass.
- No forbidden dependency/prerelease is present.
- Database migrations are reviewed.
- Security review is complete for sensitive changes.
- `PRD.md` and contracts are still accurate.
- `IMPLEMENTATION_STATUS.md` is updated.
- Changelog entry is added for user-visible changes.

## Release to develop

Merge a reviewed feature PR into `develop`.

## Release to main

Only stable, tested `develop` changes are promoted to `main`.

## Database migrations

Migrations are forward-only by default. Never rely on destructive rollback as the normal deployment strategy.

Before a schema change reaches production:

1. Validate against a fresh Supabase database.
2. Run integration tests.
3. Check compatibility with the currently deployed application.
4. Define a recovery/rollback plan for data-affecting changes.

## Dependency updates

Dependency upgrades are separate from feature work unless required for a blocker/security issue. Follow `docs/VERSION_POLICY.md`.

## Hotfix

Hotfixes may branch from `main`, receive focused tests, and then be merged back into both `main` and `develop` as appropriate.
