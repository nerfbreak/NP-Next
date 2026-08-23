# Workers

ARQ is the job queue. There is no scheduler.

Worker states:
- starting
- standby
- busy
- stopping
- offline
- error

A worker claims one automation job at a time. Heartbeats are persisted/observed so the dashboard can show active and standby capacity.

Cancellation is cooperative at the API/job layer but must terminate the active Playwright/browser execution, release distributor ownership, and return the worker to a known state.

Timeouts are adaptive:
- navigation timeout: configurable, normally 60–180s
- element/action timeout: configurable, normally 15–60s
- overall job timeout: configurable, normally 15–60m or longer for slow environments

Timeouts must be configuration-driven rather than hardcoded constants scattered through automation code.
