# Worker Rules

Worker lifecycle:

```text
starting -> standby -> busy -> standby
                    -> stopping -> offline
                    -> error
```

One worker handles one active automation initially.

Heartbeat baseline:
- interval: 15s
- stale threshold: 180s

Requirements:
- persist worker status and heartbeat
- persist current run/distributor
- reconcile stale workers so locks do not remain forever
- emit progress/state events
- use bounded, explicit timeouts
- cancellation must stop actual browser execution
- cleanup browser/context/process resources in `finally` paths

ARQ:
- jobs are manually triggered
- payloads use identifiers such as `run_id`
- never put credentials into job payloads
- do not blindly retry inventory mutations after partial side effects

ARQ is transport/orchestration. PostgreSQL remains authoritative business state.
