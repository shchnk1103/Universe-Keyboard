# CI Change Classification

## Purpose And Authority

This document is the Source of Truth for deciding whether a GitHub change runs the
lightweight documentation path or the full Swift 6 quality path. Classification
is owned by [`TD-016-CI-TIERING-001`](assignments/td-016-ci-tiering-001.md) and
[`ADR 0031`](architecture/decisions/0031-fail-closed-ci-change-classification.md).
The `full` heavy job graph is owned by
[`CI-HEAVY-JOB-SPLIT-001`](assignments/ci-heavy-job-split-001.md).

Classification selects validation work; it never grants merge, Product, Quality,
TestFlight or Release authority.

## Frozen Classification Table

| Changed path | Tier | Reason |
|---|---|---|
| Root-level `*.md` | `docs_only` | Repository navigation/governance text only |
| `docs/**` | `docs_only` | Documentation, governance and evidence artifacts |
| `.kos/**` | `docs_only` | KOS Profile and machine-readable governance records |
| Every other path | `full` | Product/build/test/tooling input or unknown path; fail closed |
| Empty diff or invalid base/head | classification failure/full | Never infer a safe skip without an exact comparison |

Rename detection is disabled for classification. A rename is therefore evaluated as
an old-path deletion plus a new-path addition, preventing a source-to-docs rename from
hiding the original sensitive path.

## Job Contract

```text
classify-change
       |
       v
lightweight-checks -------------------+
       |                               |
       +--> format-swift               |
       +--> test-keyboardcore          |
       +--> test-rimebridge            |  (full only; parallel)
       +--> test-app-keyboard          |
       +--> build-release              |
                                       v
                            final-quality-gate
```

- `classify-change` always runs and emits the exact base/head and tier.
- Manual `workflow_dispatch` requires an explicit `base_sha`; it never infers a
  branch-wide decision from only `HEAD^`.
- `lightweight-checks` always runs: diff whitespace, changed Markdown local links,
  `.kos/project.json` JSON syntax and classifier/link-checker unit tests.
- The five named heavy jobs run only when classification requires `full`. They
  do not introduce path-based skips. Debug `test` covers Debug compilation; there
  is no extra Debug `build`. `test-app-keyboard` and `build-release` still fetch
  pinned RIME artifacts. `format-swift` and `test-keyboardcore` do not.
- `final-quality-gate` always runs. For `full` every heavy job must be `success`.
  For `docs_only` every heavy job must be exactly `skipped`. Missing or
  contradictory outputs fail closed.
- One concurrency group per PR/ref cancels older in-progress runs after a new commit.

## KOS Validation Boundary

The adopted `kos-agent-kit@v0.8.0` repository is private. This project does not add a
PAT or assume sibling-private-repository access for `GITHUB_TOKEN`. Therefore:

- CI always validates changed Markdown links and Profile JSON syntax;
- when KOS governance records change, the lightweight job prints an explicit note;
- before merge, the Executor runs the pinned full validator locally with
  `KOS_AGENT_KIT_ROOT=/path/to/kos-agent-kit`;
- remote full KOS validation requires a separate reviewed distribution decision.

This is an explicit residual, not a claim that JSON syntax equals KOS validation.

## Local Commands

```bash
python3 -m unittest discover -s scripts/ci/tests -p 'test_*.py'
python3 scripts/ci/classify_changes.py --base <base-sha> --head <head-sha>
KOS_AGENT_KIT_ROOT=/path/to/kos-agent-kit \
  bash scripts/ci/run_lightweight_checks.sh <base-sha> <head-sha>
```

Workflow changes, classifier/checker scripts and unknown paths classify as `full`, so
this implementation must pass the full local/hosted suite before it is merge-ready.

## Branch Protection And Rollback

`main` had no branch protection when TD-016 entered Active. Enabling protection or
making `final-quality-gate` required is a separate Human-authorized operation. Observe
both a docs-only PR and a full PR before changing required checks.

Rollback restores the TD-016 single conditional `build-and-test` job, including
its extra Debug `build` step. The revert set is both
[`.github/workflows/swift6-quality.yml`](../.github/workflows/swift6-quality.yml)
and [`scripts/ci/verify_final_gate.sh`](../scripts/ci/verify_final_gate.sh) with
[`scripts/ci/tests/test_verify_final_gate.sh`](../scripts/ci/tests/test_verify_final_gate.sh).
The Gate script now takes eight arguments (`requires_full` third); restoring
only the YAML or only the script leaves a calling-convention mismatch. That
mismatch fail-closes the Gate (safe) but is not a working rollback. Do not use
workflow-level `paths-ignore` as a shortcut. Do not add UI/Rime/KeyboardCore
path skips during rollback.

## Revalidation Triggers

Revalidate this table when a new executable/build-input directory is added, files under
`docs/**` become executable inputs, job names or branch protection change, KOS Kit
distribution changes, or the release/local CI contract changes.

The classifier and final script are checked out from the proposed change itself. This is
acceptable while the workflow is advisory and unprotected, but it is not an independent
trust root. Before any required-check migration, TD-016 must add protected review or an
equivalent baseline-owned/external guard.
