# Database

Supabase PostgreSQL is the persistent source of truth.

Core entities:
- profiles
- distributors
- system_settings
- sku_leading_zero_rules
- distributor_sku_multipliers
- workers
- automation_runs
- automation_run_items
- automation_run_events
- automation_run_artifacts
- audit_logs

A distributor has one configured warehouse. A distributor has at most one active automation run. RLS and API authorization must enforce role boundaries.

INVT_MASTER is a fixed legacy-compatible source/data contract and is not redesigned casually during migration.
