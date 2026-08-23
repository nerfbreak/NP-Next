# Domain

## Roles
- SUPERUSER: owner-level configuration and administration.
- OPERATOR: team member who runs workflows.

## Distributor
A distributor is an independently runnable automation target. Each distributor has credentials, warehouse configuration and active status.

## Automation Run
One execution of one workflow against one distributor. A distributor may have only one active run at a time.

## Inventory Adjustment
Stock is imported, normalized, compared with INVT_MASTER/Newspage data, multiplier rules are applied according to the legacy business flow, and resulting adjustments are executed through Playwright.

## SKU formatting
Configured SKUs whose leading zero was lost by Excel numeric conversion are normalized back to their Newspage representation.

## Multiplier
A distributor-specific quantity transformation applied before the comparison/aggregation stage according to the legacy rules.
