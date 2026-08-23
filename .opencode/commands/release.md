---
description: Run the release-readiness gate before merge or deployment.
agent: reviewer
---

Task:
$ARGUMENTS

Use the release-readiness skill. Verify tests, security, dependency policy, migrations, observability, cancellation, worker cleanup, and documentation. Do not edit files. End with: READY, READY WITH CONDITIONS, or NOT READY.
