---
name: legacy-migration
description: Evidence-first workflow for migrating verified behavior from newspage_automation into NP-Next.
---

# Legacy Migration Skill

Legacy repo is reference-only:
`nerfbreak/newspage_automation`

Target:
`nerfbreak/NP-Next`

Method:
1. Locate current implementation.
2. Trace inputs, transformations, side effects, and outputs.
3. Record characterization behavior.
4. Identify Streamlit/UI coupling.
5. Map behavior into domain/service/worker boundaries.
6. Write tests before or alongside refactoring.
7. Compare outputs against legacy behavior where possible.
8. Document deliberate differences.

High-risk areas:
- Playwright selectors
- inventory formulas
- SKU normalization
- multiplier ordering
- warehouse filtering
- file parsing defaults
- cancellation behavior

Never migrate secrets or legacy technical debt just because it exists.
