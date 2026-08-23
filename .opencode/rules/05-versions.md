# Stable Version Rules

Read `docs/VERSION_POLICY.md` before changing dependencies.

Allowed baseline:

```text
Node.js 24.19.0 LTS
Next.js 16.3.x stable
React 19.2.0 stable
TypeScript 5.9.3
Python 3.13.15
FastAPI 0.141.1
Pydantic 2.13.4
ARQ 0.28.0
Playwright Python 1.62.0
Redis 8.2.x GA
pnpm 10.x stable
uv 0.12.3
```

Never introduce beta, alpha, RC, canary, nightly, experimental, or `latest` dependencies.

An implementation agent must not upgrade versions while working on an unrelated task.
