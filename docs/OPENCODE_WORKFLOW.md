# OpenCode Workflow

NP-Next uses a small, responsibility-based agent system.

## Global tools

Expected reusable global tooling:
- Superpowers
- Ponytail
- Weave
- Context7 MCP
- Playwright MCP
- shadcn MCP

Project-specific rules, agents, skills, and commands live under `.opencode/`.
Do not duplicate global MCP definitions in the project unless portability explicitly requires it.

## Seven agents

| Agent | Responsibility |
|---|---|
| architect | planning, architecture, ADRs, migration boundaries |
| backend | FastAPI, Supabase, RBAC, locks, API, SSE, audit |
| frontend | Next.js, shadcn/ui, Tailwind, dashboard/UI |
| worker | ARQ, Redis, Playwright, heartbeat, timeout, cancellation |
| migrator | legacy tracing and behavior-preserving migration |
| qa | acceptance, regression, integration, worker, E2E verification |
| reviewer | read-only quality/security/architecture gate |

Use the smallest set of agents needed for the task.

## Four project skills

- `inventory-adjustment`: safe inventory vertical-slice implementation
- `legacy-migration`: evidence-first legacy migration
- `debugging`: systematic cross-layer debugging
- `release-readiness`: merge/release verification gate

## Seven commands

```text
/plan
/build
/migrate
/test
/review
/ui
/release
```

Commands select the appropriate specialist and enforce the project workflow.

## Recommended loop

```text
/plan
  -> implementation
  -> focused tests
  -> /test
  -> /review
  -> /release
  -> PR
```

For legacy behavior, use `/migrate` first. For UI work, use `/ui` so shadcn/ui rules are applied.

## Parallel work

Parallelize only independent tasks. Never parallelize edits to the same file or migration without explicit coordination.

## Completion

No task is complete until implementation, tests, review, docs/contracts, and git state are coherent.
