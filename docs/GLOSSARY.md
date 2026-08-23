# Domain Glossary

## Distributor
A distributor account/configuration used to access the target stock/application workflow. A distributor can be actively used by only one automation run at a time.

## Operator
A normal team user who can execute workflows and monitor their own work.

## Superuser
The application owner/admin with full administrative permissions.

## Automation Run
A persisted record representing one actual workflow execution.

## Preview
A calculation/parsing result that can be reviewed before an execution run is created.

## Worker
An execution process/container that consumes an ARQ job and runs the automation.

## Standby
Worker state meaning the worker is healthy and available for a job.

## Busy
Worker state meaning the worker is executing an automation.

## Stale
A run or worker has stopped producing expected heartbeats and requires recovery handling.

## INVT_MASTER
Fixed data exported/taken from Newspage and used as the Newspage-side comparison input for Inventory Adjustment.

## Stock Import Mapping
Optional per-distributor JSONB overrides for interpreting distributor stock Excel files. Global legacy-compatible defaults are used when no override exists.

## SKU Leading-Zero Rule
A global rule that prepends exactly one `0` to a known SKU because Excel may drop a leading zero.

## Multiplier Rule
A distributor-specific quantity multiplier applied to distributor stock before comparison.

## Selisih
The canonical stock difference:

```text
Selisih = Distributor - Newspage
```

The result becomes the adjustment quantity for Inventory Adjustment execution.

## Distributor Lock
The database-enforced rule that prevents more than one active run from using the same distributor.

## Run Event
A persistent execution event used by the dashboard, audit, diagnostics, and SSE stream.

## Artifact
A stored file such as an input workbook, output report, screenshot, or diagnostic trace associated with an automation run.
