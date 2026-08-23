# Workflows

## Inventory Adjustment

```text
Choose Distributor
  ↓
Upload stock Excel
  ↓
Auto-detect parser defaults
  ↓
Optional column overrides
  ↓
Load INVT_MASTER
  ↓
Normalize SKU
  ↓
Select distributor warehouse
  ↓
Apply distributor multiplier rules
  ↓
Compare
  ↓
Preview adjustment
  ↓
Run Playwright
```

Distributor stock parser defaults:
- SKU column index = 20
- quantity column = `StokAkhir` when present
- quantity fallback index = 71
- UI may override mapping for exceptional files

The user does not need to configure mappings for every upload when the default format matches.

The workflow must expose progress, allow cancellation, and preserve a persistent run record.
