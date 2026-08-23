# Contributing

## Branches

```text
feature/* -> develop -> main
```

Do not develop directly on `main`.

## Agent workflow

1. Read `PRD.md`.
2. Read `AGENTS.md`.
3. Read the relevant domain/workflow docs.
4. Inspect the legacy implementation before changing verified automation.
5. Write or update tests.
6. Implement the smallest coherent change.
7. Run relevant checks.
8. Run `/review` before merge.
9. Update documentation when behavior/contracts change.

## Commit style

Use imperative, scoped commits where practical:

```text
feat(inventory): add stock preview
fix(worker): release distributor lock after cancellation
refactor(processing): extract SKU normalization
chore(deps): update approved patch versions
```

## Pull requests

Every PR should state:

- what changed
- why it changed
- affected workflows
- tests run
- migration implications
- security implications
- rollback considerations

Do not merge a migration that changes business behavior without documenting the change.

## Code review priorities

Review in this order:

1. correctness and business invariants
2. concurrency and cancellation
3. security and credential exposure
4. regression risk against legacy behavior
5. tests
6. maintainability

## No speculative dependencies

Do not add a library because it is convenient when the existing stack can solve the problem. Every new dependency needs a documented reason and stable-version check.
