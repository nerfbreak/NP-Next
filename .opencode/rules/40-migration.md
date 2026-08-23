# Migration Rules

Legacy repository `nerfbreak/newspage_automation` is read-only reference material. Target repository is `nerfbreak/NP-Next`.

Migration principle:
- preserve verified business behavior
- improve boundaries and testability
- remove framework coupling
- document intentional behavior changes

Legacy cleanup targets:
- Streamlit pages/session/cache/secrets
- hardcoded warehouse values
- `EXCLUDE_PREFIX`
- legacy distributor exception hacks
- UI-coupled business logic
- credential leakage

For `playwright_engine.py`, `data_processor.py`, and `error_taxonomy.py`, refactor/decompose based on responsibilities. Do not preserve bad file boundaries merely for nostalgia.

Before changing a workflow:
1. trace the legacy source
2. identify inputs/outputs/side effects
3. write or update characterization tests
4. implement target behavior
5. compare results where practical
6. record any deliberate differences
