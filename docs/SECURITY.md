# Security

- Never commit credentials or secrets.
- Distributor passwords are encrypted at rest.
- Credentials never enter frontend state, ARQ payloads, logs, SSE events or exception text.
- Server-only Supabase credentials stay on the server.
- RBAC is enforced by the API, not only the UI.
- Distributor CRUD is SUPERUSER-only.
- Automation execution is authorized server-side.
- Configuration and cancellation actions are auditable.
