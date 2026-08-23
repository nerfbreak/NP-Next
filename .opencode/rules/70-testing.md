# Testing Rules

Required layers by risk:
- unit
- integration
- API
- worker
- Playwright/automation
- E2E

Every feature must map tests to acceptance criteria.

Critical invariants:
1. one distributor -> at most one active run
2. different distributors may run concurrently
3. one worker -> one active automation initially
4. cancel -> actual execution stops and resources clean up
5. credentials never leak
6. multiplier -> before aggregation/comparison
7. `Selisih = Distributor - Newspage`
8. leading-zero rules add exactly one zero
9. `8021803` and `8021804` are not special exclusions
10. INVT_MASTER is fixed
11. warehouse comes from distributor config
12. Excel defaults remain legacy-compatible

Do not delete or weaken tests to make a change pass. Fix the implementation or explicitly update the requirement/decision.
Run focused tests first, then the broad relevant suite.
