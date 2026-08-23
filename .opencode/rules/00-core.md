# Core Agent Rules

Read `PRD.md` and the task-relevant documentation/rules before changing code.

Project:
- repo: `nerfbreak/NP-Next`
- legacy reference: `nerfbreak/newspage_automation`

Non-negotiables:
- no Streamlit
- no Celery
- no scheduler/beat/cron-driven business execution
- no frontend Playwright
- no hardcoded distributor credentials
- no hardcoded warehouse values
- no hardcoded SKU exceptions that belong in data/configuration
- no credentials in logs, queue payloads, events, browser-visible state, or API responses

Engineering loop:
plan -> implement -> test -> review -> commit

Do not invent business behavior when legacy source or the PRD can answer it.
Do not change locked business invariants casually. New decisions belong in `docs/DECISIONS.md`.
