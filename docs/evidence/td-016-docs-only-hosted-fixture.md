# TD-016 hosted docs-only fixture

This file exists only on the temporary TD-016 fixture branch. Its Pull Request targets
`codex/td016-ci-tiering`, so the exact PR diff contains one path under `docs/**` and no
workflow, script, source, project, package, test or product-resource change.

Expected hosted result:

- `classify-change`: `docs_only`, `requires_full=false`;
- `lightweight-checks`: success;
- `build-and-test`: skipped;
- `final-quality-gate`: success.

The fixture PR must not be merged. Its GitHub run is external evidence for
`TD-016-CI-TIERING-001`; closing the fixture does not authorize #86/#87 merge,
branch protection, required checks, Product acceptance or Release.
