# Execution evidence: TYPO-CORRECTION-002 runtime-integration hardening blocker remediation

## Authorization consumption and entry checks

Current Codex task consumed
[`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001.md)
after the prior docs-only executor reassignment and input-manifest correction.

| Check | Result |
|---|---|
| New worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-hardening-blockers/Universe Keyboard` |
| Branch/base requested | `codex/typo-correction-002-runtime-hardening-blockers` / `4d1050f4b677494e06448cb40a83ef2da46d7b27` |
| New worktree HEAD / tree before bootstrap | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| New worktree status before bootstrap | clean |
| Source review worktree HEAD / tree | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Source 15 code/test paths | present |
| Original sixteenth path | absent; corrected before consumption to existing predecessor implementation evidence path |
| Predecessor tracked-diff SHA-256 | `7eb4b6714c27230c212ec9b7ad398b9dc419291c9aaf4303cdb12b4532a68d95` |
| Remediation delta SHA-256 | `15b6c539b85265b7be09eabf2deae625e869b5386676e650ed846ae2bf7cb0e4` |
| Final target HEAD / base tree | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Final tracked diff SHA-256 | `3f3de3aba53820340c25cafc6adaa87977c9ffe58b6a7e61e165c3c64e26db5e` |

The 16-path bootstrap was byte-identical before editing. The preserved original
implementation worktree remains bound to tracked-diff SHA-256
`d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b`, and the
preserved pure-Core checkpoint remains bound to
`8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab`.
Neither was modified.

## Remediation performed

Only the three named Architecture blockers were addressed:

1. **Invalidate-first ordering.** Production Canary and P3D1 bootstrap paths
   invalidate the controller-owned recall before changing responsive/thread-
   affine flags. The default and dual-gate paths install the owner after their
   route state is established.
2. **Yielded continuation ownership.** `TypoCorrectionRecallCoordinator`
   carries an operation-bound `YieldedTurnToken` through the RunLoop callback.
   The callback checks recall epoch, composition revision and operation ordinal
   before advancing a driver; an invalidated callback cannot advance a newer
   operation. The token is explicitly `Sendable` so the Swift 6 boundary is
   compiler-checked.
3. **Unique writer / route ownership.** A recall cannot start until the
   controller query is wrapped by the sidecar owner. Route selection is derived
   from controller state (`threadAffine` → `mainActorResponsive` → default),
   and all bootstrap installs use the same façade. The adapter tests cover all
   three route values and forwarding; no second live RIME session or alternate
   query loop was added.

The production search budgets and host-text/marked-text paths were not changed.

## Local verification

| Check | Result | Evidence / boundary |
|---|---|---|
| `swift-format format --in-place` + `lint --strict` | PASS | All 15 changed/inherited Swift paths in the authorized source/test inventory. |
| `swift test --package-path Packages/KeyboardCore` | PASS | 1,153 executed, 0 failures. An existing unrelated optional-string-interpolation warning in `T9PinyinPathTests.swift` remains recorded; it did not fail this command. |
| Fixed vendor `ensure_rime_vendor.sh verify` | PASS | Structural inventory of 12 framework artifacts. The source directory was pre-existing and unchanged. |
| `RimeBridgeTests` strict Debug test | PASS | 82 passed, 0 failed, 20 skipped. Result bundle: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-22T06-05-20-590Z_pid16549_d91469ba.xcresult`. |
| `Universe Keyboard` strict Debug test, first attempt | FAIL → repaired | Swift 6 reported two data-race errors and one Sendable warning for the full fence captured by the `@Sendable` RunLoop callback. No test case executed. |
| `Universe Keyboard` strict Debug test, final attempt | PASS | 379 passed, 0 failed, 9 skipped. Result bundle: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-22T06-08-55-625Z_pid16549_3ecc2f8c.xcresult`. |
| Temporary vendor cleanup | PASS | Symlink target was the pre-verified implementation worktree Vendor directory; symlink was removed and target path is absent. |
| `git diff --check` | PASS | No whitespace errors. |

The App test result is a local build/test result only. It is not a Simulator
capture, real-RIME deployment proof, QA-001, INT-003, performance evidence or
Product/Quality/Release Gate.

## Handoff

The implementation slice is ready for a **new independent Architecture review**
against the exact uncommitted target worktree and the hashes above. The current
Authorization does not permit commit, push, PR, merge, capture, publication or
Assignment closure. Quality and Product decisions remain downstream of that
review.

## Later review status

The supplied independent Architecture report was subsequently reconciled as
`Pass with conditions`; its named source blockers are closed while its detached
worktree and other explicit residuals remain open. The first independent Quality
review Authorization was consumed, but its assigned reviewer returned no verdict
before stop. That event is not a Quality review, and it leaves Quality,
Product, publication and Assignment closure unreviewed.

QUALITY-002 subsequently supplied the bounded Quality verdict. Product accepted
its named residuals in
[`PD … RESIDUAL-001`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-RESIDUAL-001.md).
The child is `Reviewed`; the parent remains `Active`; neither result authorizes
publication or a parent conclusion.

## Independent Quality review (QUALITY-002)

| Field | Value |
|---|---|
| Authorization | [`AUTH … QUALITY-002`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-QUALITY-002.md) — consumed |
| Prior attempt | [`QUALITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-QUALITY-001.md) — consumed, no verdict; not reused |
| Review record | [`Quality review 2026-09-22`](../reviews/typo-correction-002-runtime-integration-hardening-blocker-remediation-quality-review-2026-09-22.md) |
| Verdict | **Pass with conditions** (bounded) |
| Identity | HEAD/tree/tracked-diff/`15b6c539…` seven-path delta Quality-reverified; detached residual retained |
| Executor tests | Format/lint, KeyboardCore 1153/0, RimeBridge 82/0/20, App 379/0/9 remain **Executor-recorded**; RimeBridge/App xcresult summaries spot-checked only |
| Architecture residuals | Detached worktree, dual-gate failure rollback, CandidateProvider façade — retained |
| Non-claims | No real RIME, capture, QA-001, INT-003, performance/180 ms, commit/push/PR/merge, Product/Release Gate, Assignment Close |

Quality did **not** rerun build/test and did **not** modify Swift, vendor, or schema.
