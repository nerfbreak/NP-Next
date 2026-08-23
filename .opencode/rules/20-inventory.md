# Inventory Adjustment Rules

Inventory Adjustment is the first vertical slice.

Canonical flow:

```text
select distributor
 -> upload distributor stock Excel
 -> resolve parser defaults/override
 -> show mapping controls
 -> parse fixed INVT_MASTER
 -> normalize SKU
 -> filter configured warehouse
 -> apply distributor multiplier
 -> aggregate
 -> compare
 -> review
 -> create automation run
 -> enqueue ARQ
 -> Playwright execution
```

Locked rules:
- Distributor Excel default SKU column = zero-based index 20.
- Quantity prefers header `StokAkhir`; fallback = zero-based index 71.
- Mapping dropdowns remain available.
- Priority: user override > distributor JSONB override > global default.
- `INVT_MASTER` is fixed and not user-mapped.
- Leading-zero rules prepend exactly one zero.
- `8021803` and `8021804` have no hardcoded exclusion.
- Warehouse comes from `distributors.warehouse`.
- Multiplier applies to distributor quantity before aggregation/comparison.
- `Selisih = Distributor - Newspage` and becomes adjustment quantity.
- Positive/negative quantities must preserve the legacy adjustment semantics.

Never reintroduce `EXCLUDE_PREFIX`, `GUDANG UTAMA`, or other hardcoded distributor exceptions.
