# CI Change Classification

## Purpose And Authority

This document is the Source of Truth for deciding whether a GitHub change runs the
lightweight documentation path or the full Swift 6 quality path. The implementation
is owned by [`TD-016-CI-TIERING-001`](assignments/td-016-ci-tiering-001.md) and
[`ADR 0031`](architecture/decisions/0031-fail-closed-ci-change-classification.md).

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
lightweight-checks -----------+
       |                       |
       +--> build-and-test     |
            (full only)        |
                               v
                    final-quality-gate
```

- `classify-change` always runs and emits the exact base/head and tier.
- Manual `workflow_dispatch` requires an explicit `base_sha`; it never infers a
  branch-wide decision from only `HEAD^`.
- `lightweight-checks` always runs: diff whitespace, changed Markdown local links,
  `.kos/project.json` JSON syntax and classifier/link-checker unit tests.
- `build-and-test` retains the existing artifact preparation, Swift formatting,
  KeyboardCore, RimeBridge, App/Keyboard tests and Debug/Release builds. It is skipped
  only for `docs_only`.
- `final-quality-gate` always runs. It requires the heavy job to be `success` for
  `full` or exactly `skipped` for `docs_only`; missing/contradictory outputs fail.
- One concurrency group per PR/ref cancels older in-progress runs after a new commit.

## KOS Validation Boundary

The adopted `kos-agent-kit@v0.6.0` repository is private. This project does not add a
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

Rollback is one workflow revert: restore the single unconditional `build-and-test`
job. Do not use workflow-level `paths-ignore` as a shortcut.

## Revalidation Triggers

Revalidate this table when a new executable/build-input directory is added, files under
`docs/**` become executable inputs, job names or branch protection change, KOS Kit
distribution changes, or the release/local CI contract changes.

The classifier and final script are checked out from the proposed change itself. This is
acceptable while the workflow is advisory and unprotected, but it is not an independent
trust root. Before any required-check migration, TD-016 must add protected review or an
equivalent baseline-owned/external guard.
