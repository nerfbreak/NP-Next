# AI Routing Rules

- NP-Next uses quota-bucket-aware model routing through 9Router.
- WRL models share one WRL quota.
- 4.6 Opus/Sonnet Thinking models share one Thinking quota.
- Gemini 3.7 Flash High/Medium/Low share one Gemini quota.
- Free models are the last-resort pool.
- Never treat models within the same bucket as independent quota capacity.
- Never hardcode 9Router credentials, private endpoints, or API tokens.
- Keep fallback behavior in 9Router, not in application/business logic.
- Use the exact live model/Combo IDs exposed by the local provider catalog.
- Agent roles must keep a stable routing intent even if 9Router internals change.
- Quota/rate-limit/provider failures should be silently handled by the router when a fallback is available.
- Escalate only real blockers or when all relevant fallback capacity is exhausted.
