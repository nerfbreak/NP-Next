# Code Style and Engineering Rules

## General

Prefer simple, explicit code over clever abstractions. Keep domain logic independent from UI, database transport, queue transport, and browser automation.

## Python

- Python 3.13.15 baseline.
- Type hints required for public functions.
- Pydantic models for API contracts and external input validation.
- Async code for FastAPI, ARQ, and Playwright operations.
- No blocking I/O inside async request/job paths.
- Raise domain errors instead of rendering/UI errors.
- Keep pure processing functions deterministic and side-effect free where practical.

## TypeScript

- TypeScript strict mode.
- No `any` unless a boundary truly cannot be typed and the reason is documented.
- Keep API types aligned with backend contracts.
- Server/client boundaries must be explicit.
- Do not put secrets into client components or browser-readable config.

## Architecture

```text
UI -> API -> Domain/Services -> Repository
                         |
                         +-> ARQ

Worker -> Domain/Automation -> Repository
```

Do not let a repository or parser silently start jobs. Keep side effects at service/orchestration boundaries.

## Playwright

- Centralize browser/session creation.
- Avoid duplicated login logic.
- Prefer stable selectors over brittle visual selectors.
- Capture diagnostics on failure when safe.
- Always close context/browser in `finally` paths.
- Cancellation must be handled explicitly.

## Database

- Use migrations for schema changes.
- Do not edit production schema manually.
- Add constraints for invariants that must hold under concurrency.
- Do not store secrets in plaintext.

## Logging

Logs must be structured and useful. Never log passwords, tokens, cookies, authorization headers, or full credential-bearing objects.

## Error handling

Use stable error codes and user-safe messages. Preserve technical details in server-side logs/events where safe.

## Tests

Every non-trivial behavior change should include a regression test. Business invariants should have tests independent of UI implementation.
