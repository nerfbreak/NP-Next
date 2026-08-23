---
name: inventory-adjustment
description: Safe implementation workflow for NP-Next Inventory Adjustment.
---

# Inventory Adjustment Skill

Use for Inventory Adjustment work.

Read first:
- PRD.md
- docs/DOMAIN.md
- docs/WORKFLOWS.md
- docs/DATABASE.md
- docs/API.md
- `.opencode/rules/20-inventory.md`

Required sequence:
1. Inspect legacy implementation and characterization behavior.
2. Parse fixed INVT_MASTER.
3. Resolve distributor Excel mapping using global default, distributor override, then user override.
4. Normalize SKU using data-driven leading-zero rules.
5. Filter the distributor warehouse from configuration.
6. Apply distributor-specific multiplier before aggregation/comparison.
7. Calculate `Selisih = Distributor - Newspage`.
8. Present reviewable mismatch rows.
9. Create an automation run only for explicit execution.
10. Enqueue ARQ using `run_id` only.
11. Execute via worker/Playwright with heartbeat, progress, cancellation, and cleanup.

Never restore `EXCLUDE_PREFIX`, hardcoded `GUDANG UTAMA`, or other distributor-specific source-code exceptions.

Test positive/negative adjustment quantities, leading-zero examples, multiplier ordering, warehouse filtering, mapping fallback, duplicate-run lock, and cancellation.
