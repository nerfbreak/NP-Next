# Testing

Required layers:
1. unit tests for parsers, SKU normalization and comparison rules
2. integration tests for database/run locking
3. API tests
4. ARQ worker tests
5. Playwright automation tests
6. end-to-end workflow tests

Critical invariants:
- one active run per distributor
- one active job per worker
- cancellation terminates browser execution
- credentials never appear in logs
- multiplier is applied at the legacy-defined comparison stage
- INVT_MASTER semantics remain compatible
