# Feature Specification Template

Use this for meaningful feature work. Small fixes may only need a PR description.

## Context

What problem are we solving?

## Goal

What observable product behavior should exist when done?

## Non-goals

What is explicitly not changing?

## User flow

```text
User -> UI -> API -> Domain/Service -> Queue/Worker -> Result
```

## Business rules

- Rule 1
- Rule 2

## Data contract

Inputs:

```text
...
```

Outputs:

```text
...
```

## Failure cases

- invalid input
- authorization failure
- concurrency conflict
- timeout
- cancellation
- external-system failure

## State transitions

```text
...
```

## Security

Document credential, authorization, upload, and logging implications.

## Observability

Events:

```text
...
```

Metrics:

```text
...
```

## Tests

- unit
- integration
- API
- worker
- E2E

## Acceptance criteria

- Given ... when ... then ...

## Migration / rollback

Describe schema or runtime implications.

## Documentation updates

List docs/contracts that must change with this feature.
