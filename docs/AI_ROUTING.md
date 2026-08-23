# AI Routing Policy

## Purpose

NP-Next uses OpenCode for agent execution and 9Router for model routing. The routing policy is quota-bucket aware.

## Quota buckets

### Bucket 1 — WRL
All `wrl/*` models share one WRL API quota. Switching between `wrl/*` models does not create additional quota capacity.

### Bucket 2 — Thinking
`4.6-Opus-Thinking` and `4.6-Sonnet-Thinking` share one quota.

### Bucket 3 — Gemini Flash 3.7
`3.7-Flash-High`, `3.7-Flash-Medium`, and `3.7-Flash-Low` share one quota.

### Bucket 4 — Free pool
Use the free models available in the live 9Router/OpenCode catalog as the last-resort pool. Exact IDs must be discovered from the live catalog.

## Agent routing intent

| Agent | Primary | Cross-bucket fallback |
|---|---|---|
| architect | `wrl/claude-opus-5` | Thinking → Gemini High → Free |
| reviewer | `wrl/claude-opus-5` | Thinking → Gemini High → Free |
| backend | `wrl/gpt-5.6-sol` | Thinking → Gemini High → Free |
| worker | `wrl/gpt-5.6-sol` | Thinking → Gemini High → Free |
| migrator | `wrl/gpt-5.6-luna` | Thinking → Gemini High → Free |
| frontend | `wrl/claude-sonnet-5` | Thinking → Gemini High → Free |
| qa | `3.7-Flash-Medium` | WRL lightweight → Free |

## Cheap/background routing

For simple background tasks use `3.7-Flash-Low → Free`.
Do not spend reasoning models on trivial edits, formatting, simple test generation, or mechanical refactors.

## 9Router logical combos

Create these five logical combos in 9Router:

1. `NP-Next-REASONING`
2. `NP-Next-CODING`
3. `NP-Next-UI`
4. `NP-Next-QA`
5. `NP-Next-CHEAP`

The exact external combo/model IDs are environment-specific. Do not invent or commit guessed combo IDs.

Recommended cross-bucket behavior:

- REASONING: WRL primary → Thinking → Gemini High → Free
- CODING: WRL primary → Thinking → Gemini High → Free
- UI: WRL primary → Thinking → Gemini High → Free
- QA: Gemini Medium → WRL lightweight → Free
- CHEAP: Gemini Low → Free

## Failure policy

Quota exhaustion, provider rate limits, and transient provider failures should be handled by 9Router without interrupting the user.

The agent reports only real blockers, such as missing access/credentials, contradictory requirements, unverifiable legacy behavior, destructive operations requiring approval, unsafe recovery, or exhaustion of all relevant fallback buckets.

## Repository rules

- Do not encode fallback chains in application business logic.
- Do not treat models inside the same quota bucket as independent quota capacity.
- Never put provider credentials, 9Router tokens, or private endpoints in the repository.
- Use the live model catalog for exact external IDs.
- Keep agent role-to-routing intent stable even if router internals change.
