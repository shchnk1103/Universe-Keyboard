# Fixture: CI-HEAVY-JOB-SPLIT-001 hosted docs_only path

This file exists only so a GitHub `pull_request` diff is entirely inside
`docs/**` and classifies as `docs_only`.

Expected hosted result for Assignment residual CHS-Q-02:

- `classify-change` success, `classification=docs_only`, `requires_full=false`
- `lightweight-checks` success
- `format-swift`, `test-keyboardcore`, `test-rimebridge`, `test-app-keyboard`,
  `build-release` all exactly `skipped`
- `final-quality-gate` success

This fixture PR must be closed without merge after evidence lands.
It is not merge policy, Product Gate, Quality Pass, or required-check evidence.
