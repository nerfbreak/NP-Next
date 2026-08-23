# API Contract

API version prefix: `/api/v1`.

Core areas:
- `/auth`
- `/distributors`
- `/inventory`
- `/runs`
- `/workers`
- `/admin`

Representative operations:
- list active distributors
- create/update/deactivate distributor (SUPERUSER)
- preview Inventory Adjustment
- create an automation run
- get run status/progress
- cancel a run
- list workers and worker capacity

A busy distributor returns a conflict response for another run against the same distributor. This does not block other distributors.
