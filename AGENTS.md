# Agent Operating Rules

## Mission
Build the native fullstack Newspage Automation rewrite. The legacy repository is reference-only.

## Architecture
- Web: Next.js + TypeScript
- API: FastAPI
- Queue: ARQ + Redis
- Browser automation: Playwright workers
- Database/Auth: Supabase PostgreSQL/Auth
- Realtime: server-side events / Supabase realtime where appropriate

## Forbidden
- Streamlit
- Celery
- scheduler-based execution
- hardcoded distributor credentials
- hardcoded distributor warehouse
- hardcoded SKU exceptions when a rule belongs in configuration
- credentials in logs, events, queue payloads, or frontend state
- direct browser automation from the frontend

## Business invariants
- A distributor can have at most one active automation run.
- Other distributors remain runnable while one distributor is busy.
- Cancellation must terminate the automation/browser execution and clean up the worker.
- Worker state must expose standby/busy/offline information.
- INVT_MASTER is a fixed legacy-compatible data contract.
- SKU leading-zero rules and distributor multiplier rules are data-driven.
- Distributor stock Excel defaults to SKU column index 20; quantity uses StokAkhir when present, otherwise index 71. UI still permits override.

## Workflow
Plan → implement → test → review. Do not invent business behavior when legacy behavior can be inspected.

## Safety
Never commit secrets. Do not change verified Playwright selectors or business formulas without tests and an explicit migration note.
