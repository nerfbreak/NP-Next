# Newspage Automation Next

Native fullstack rewrite of the legacy Newspage automation project.

## Target architecture

Next.js + TypeScript → FastAPI → ARQ/Redis → Playwright workers → Supabase PostgreSQL.

Streamlit is intentionally removed from the target architecture.

## Development branches

- `main`: production-ready code
- `develop`: integration branch
- `feature/*`: implementation branches

See `AGENTS.md` and `docs/` for the project contracts and agent workflow.
