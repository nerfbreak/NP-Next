# Migration

Source repository: `nerfbreak/newspage_automation`

Target repository: `nerfbreak/NP-Next`

The legacy repository is reference-only. Do not preserve its Streamlit architecture.

Migration order:
1. establish database and auth
2. build FastAPI foundation
3. build ARQ/worker lifecycle
4. migrate Inventory Adjustment domain behavior
5. migrate Playwright behavior without changing verified selectors unnecessarily
6. build dashboard and realtime progress
7. migrate remaining workflows one vertical slice at a time
8. remove legacy-only dependencies from the new system
9. run regression tests against legacy-compatible behavior

`playwright_engine.py`, `data_processor.py` and `error_taxonomy.py` should be extracted/refactored into domain services rather than copied blindly. Preserve behavior first, then improve structure behind tests.
