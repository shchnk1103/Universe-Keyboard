# Assignment: TYPO-CORRECTION-002-RESIDUAL-RECONCILIATION-001

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | Reconcile the intentionally excluded AX/testability residuals and publish the already-used test-only harness plus canonical child governance records. |
| **Non-claims** | No new Run, build, install, Product/Quality/Release Gate, parent close, recall change, or PR/merge decision. |
| **Next** | After reconciliation, use a clean worktree for the separate recall-remediation Assignment; the current dirty worktree is not the implementation workspace. |
| **Residuals** | Two AX production files are origin-equivalent but local-base-dirty; the F-01 manifest remains outside this parent lane. |

---

## Authority and purpose

- **Assignment Authority:** Product Lead / Human Product Owner, current task instruction on 2026-09-19 Asia/Shanghai.
- **Parent:** [`TYPO-CORRECTION-002`](typo-correction-002.md).
- **Matching Authorization:** `AUTH-TYPO-CORRECTION-002-RESIDUAL-RECONCILIATION-001`.
- **Objective:** prevent the post-checkpoint residuals from becoming undocumented ambient state while preserving exact evidence provenance.

## Frozen identity

| Item | Value |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar` |
| Branch | `codex/typo-correction-002-provenance-sidecar` |
| Published tip before reconciliation | `5d3916d18449fe69895304b0d9be1501d021b9dc` |
| `origin/main` | `162b09fd58ba60538a944026b1902efa405c75aa` |
| INT-003 harness file SHA-256 | `3b4a57c1dc6033ce572b89812bb2ab80c4a079bcfdc8d4e166d273859b5be5f2` |
| Bound evidence | `TC2-SIM-20260919-181538-INT003-AX-REVAL-03`, `TC2-SIM-20260919-190945-INT003-AX-COORDINATE-FEAS-01` |

## Authorized scope

The Executor may:

1. correct the checkpoint receipt's inaccurate statement about the third AX-related Swift file;
2. publish the exact already-used test-only `NativeExperienceKeyboardAutomationFeasibilityTests.swift` content whose SHA-256 is bound above;
3. publish the seven canonical child Assignment/Authorization/review records that are currently untracked, after normalizing the F-02 records to repository-relative links and the reconciled `Reviewed` status;
4. record that `docs/evidence/typo-correction-002-f01-scope-manifest.md` belongs to the separate F-01 lane and is not part of this parent reconciliation;
5. run read-only integrity checks, Swift strict lint for the test-only file, and the required docs-only lightweight checks;
6. create and push one reconciliation commit, without opening a PR or merging.

## Explicit exclusions

- Do not delete, reset, restore or clean the two origin-equivalent AX production files in this old-base worktree.
- Do not alter production Swift/Objective-C, KeyboardCore, RimeBridge, schema, vendor archive, sidecar behavior, search budget or candidate ranking.
- Do not rebuild, reinstall, capture a Simulator/device run or allocate a new Run ID.
- Do not reinterpret the existing INT-003 receipts as a pass; the harness remains testability/evidence infrastructure only.
- Do not publish the F-01 scope manifest into the parent lane.
- Do not create a PR, merge, close `TYPO-CORRECTION-002`, run TestFlight or perform Release work.

## Completion evidence

- exact staged path manifest and `git diff --cached --check`;
- strict Swift-format lint for the published test-only file;
- SHA-256 equality between the published test-only file and the already-bound evidence receipt;
- changed-Markdown link check and lightweight CI result;
- residual reconciliation receipt naming what remains intentionally outside the lane.
