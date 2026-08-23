# Version Policy

Use only stable, GA, or LTS releases for production dependencies.

Forbidden unless explicitly approved:
- beta
- alpha
- canary
- nightly
- release candidate
- floating `latest`
- unbounded dependency ranges for core runtime packages

Current baseline is defined in `docs/VERSION_POLICY.md` and package manifests must agree with it.

Do not upgrade major/minor runtime versions as part of an unrelated feature.
Dependency upgrades are deliberate changes with validation, changelog review, and tests.

Prefer lockfiles and reproducible runtime declarations.
