# Assignment: TYPO-CORRECTION-002-PARENT-CHECKPOINT-001

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | Checkpoint `84978748d89d329a7d2c6e89400c1ff556cfd9b5` was created and pushed; docs-only state sync completed. |
| **Non-claims** | This checkpoint does not close `TYPO-CORRECTION-002`, does not establish INT-003, QA-001, paired performance, Product/Quality/Release approval, and does not change the RIME schema or search budget. |
| **Next** | After the checkpoint is reachable from the remote branch, create a new bounded recall-remediation Assignment/Authorization from its exact commit. |
| **Residuals** | Existing UNKNOWN/inconclusive receipts remain valid only for their original source/build/Run ID bindings; they are not reinterpreted by this publication. |

---

## Authority and purpose

- **Assignment Authority:** Product Lead / Human Product Owner, by the current task instruction on 2026-09-19 Asia/Shanghai.
- **Parent:** [`TYPO-CORRECTION-002`](typo-correction-002.md).
- **Matching Authorization:** `AUTH-TYPO-CORRECTION-002-PARENT-CHECKPOINT-PUBLISH-001`.
- **Objective:** create a recoverable, immutable Git checkpoint for the current parent sidecar/provenance implementation and its KOS evidence pack before the work direction changes to bounded production recall remediation.
- **Reason:** the current worktree contains intentional parent changes and uncommitted KOS records, while its local base predates the already-merged PR #140. A precise allowlist is required to preserve the parent snapshot without re-publishing or deleting the child merge.

## Frozen starting identity

| Item | Value |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar` |
| Branch | `codex/typo-correction-002-provenance-sidecar` |
| Local HEAD before checkpoint | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` |
| Remote default branch observed | `origin/main` at `162b09fd58ba60538a944026b1902efa405c75aa` |
| Child merge already present on main | PR #140, merge `162b09fd`; child publication tip `9403a84` |

## Authorized scope

The Executor may, without changing file contents for product behavior:

1. record the current allowlist and exclusions in this Assignment and its evidence receipt;
2. stage only the parent implementation, parent tests, parent evidence/authorization/review records, and the required checkpoint records identified by the pre-commit manifest;
3. run the required read-only integrity checks and Swift-format hard gate for the staged Swift delta;
4. create one checkpoint commit and push the named feature branch to `origin`;
5. update the checkpoint evidence and KOS status mirror in a docs-only follow-up commit so the exact checkpoint commit and remote branch are recorded.

## Explicit exclusions

- Do not use `git add -A`, reset, clean, restore, rebase, merge, or overwrite unrelated work.
- Do not stage or re-publish the PR #140 AX/testability implementation that is already in `origin/main`.
- Do not treat child files absent from this old local base as deletions from `main`.
- Do not change production recall/search bounds, hypothesis ranking, debounce, candidate ordering, RIME schema/vendor/archive or deployment.
- Do not build, reinstall, capture a new Simulator/device run, reuse an old Run ID, or modify existing evidence claims.
- Do not create a pull request, merge, close the parent Assignment, run TestFlight, or perform Release work.

## Required evidence

- pre-commit `git status --short`, exact staged path manifest, `git diff --cached --check`, and staged Swift-format result;
- checkpoint commit SHA, remote branch and push result;
- post-checkpoint docs-only state-sync receipt naming the exact commit and the next bounded remediation handoff;
- explicit record that no Product/Quality/Release Gate was closed.

## Future handoff

The next work item is a separate bounded `TYPO-CORRECTION-002` recall-remediation Assignment. It must start from the exact checkpoint commit and define a coverage-aware, bounded hypothesis-recall change plus focused tests and new build/Run IDs. The existing sidecar observability, INT-003, QA-001 and paired-performance receipts remain historical evidence and cannot be promoted by the checkpoint.

## Close receipt

- Checkpoint evidence: [`parent checkpoint receipt`](../evidence/typo-correction-002-parent-checkpoint-2026-09-19.md).
- Authorization: `AUTH-TYPO-CORRECTION-002-PARENT-CHECKPOINT-PUBLISH-001`, consumed after commit and push.
- Parent `TYPO-CORRECTION-002` remains `Active`; no PR, merge, Product Gate, Quality Gate, Release or TestFlight action was performed.
