# Worker Rules

Use ARQ + Redis. No scheduler. Workers heartbeat, expose state, claim one job at a time, and support hard cancellation of Playwright execution. Timeout values are configuration-driven and adaptive.
