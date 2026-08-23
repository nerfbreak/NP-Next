# AI Context

This repository is the clean fullstack rewrite of `nerfbreak/newspage_automation`.

Target stack: Next.js, FastAPI, ARQ/Redis, Playwright workers, Supabase.

Never introduce Streamlit or Celery. Jobs are manually triggered, not scheduled.

Concurrency rule: one active run per distributor, while other distributors remain available.

Inventory Adjustment uses fixed INVT_MASTER semantics, configurable SKU leading-zero rules, distributor-specific multiplier rules, distributor warehouse configuration, and a stock Excel parser with defaults plus UI overrides.

Cancellation must terminate the Playwright execution and return the worker to a known state.
