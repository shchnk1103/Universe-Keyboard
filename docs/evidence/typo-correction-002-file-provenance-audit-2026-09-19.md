# Evidence: TYPO-CORRECTION-002 file provenance and ownership audit

## Purpose and boundary

This is a read-only inventory of the files currently relevant to
`TYPO-CORRECTION-002`. It does **not** claim that every historical repository
file has its own Assignment. KOS ownership is evaluated for changed, untracked,
generated or externally retained artifacts in the three worktrees involved in
the current handoff.

Audit date: `2026-09-19 Asia/Shanghai`.

## Worktree snapshots

| Location | Branch / HEAD | Status | Interpretation |
|---|---|---|---|
| `/Users/doubleshy0n/Dev/Universe Keyboard` | `main` / `9eb83158e49218c1e8f75dbe7dd9e0390db81409` | two user-retained evidence paths: one modified and one untracked | Existing parent evidence work; not touched by the recall lane or by this clean worktree |
| `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar` | `codex/typo-correction-002-provenance-sidecar` / `5d55ce981adc4ef5a34046292a6edbc727db280b` | two origin-equivalent AX production paths shown as `M`; F-01 manifest untracked | Deliberate residuals recorded by the parent reconciliation; not cleaned or absorbed |
| `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-recall-remediation-001/Universe Keyboard` | `codex/typo-correction-002-recall-remediation-001` / `5d55ce981adc4ef5a34046292a6edbc727db280b` | clean | Sole workspace for this read-only recall design slice |

## Changed and retained artifact ownership

| Artifact / path class | Current owner or authority | Traceability | Remaining gap / action |
|---|---|---|---|
| `docs/evidence/typo-correction-002-device-hub-validation.md` and `docs/evidence/typo-correction-002-sim-run-2026-09-17-debug-01.md` in `main` | Parent `TYPO-CORRECTION-002` and Run `TC2-SIM-20260917-191532-DEBUG-01` | Both records name the parent Assignment, Run identity, simulator and non-claims | They remain uncommitted user-owned `main` changes; publishing them would need a separate explicit publication decision |
| Parent sidecar/provenance production and test changes | Parent checkpoint Assignment / Authorization | Published by checkpoint `84978748d89d329a7d2c6e89400c1ff556cfd9b5`, then state-synced by `5d3916d` | Parent remains Active; no Product or Release conclusion |
| `Keyboard/Controllers/KeyboardInputHitAreaStackView.swift` and `Keyboard/Controllers/KeyboardViewController+KeyAccessibility.swift` in the parent worktree | Merged child PR #140 and child testability/accessibility records | Worktree blobs equal `origin/main`; the `M` state is an old-base presentation, not a content delta | Do not delete or stage them; a clean checkout from the published base removes the false residual |
| `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift` | Parent INT-003 coordinate/test-only authorization and Run receipts | Published at `fb27b24`; SHA-256 `3b4a57c1dc6033ce572b89812bb2ab80c4a079bcfdc8d4e166d273859b5be5f2` and bound to the two existing INT-003 receipts | No new Run or reinterpretation; remains testability infrastructure |
| Seven child testability/accessibility governance records and seven F-02 records | Child Assignments/Authorizations/reviews and residual reconciliation | Published in `fb27b24`; lifecycle writeback and receipt in `5d55ce9` | F-02 revalidation remains `Reviewed`, not Closed |
| `docs/evidence/typo-correction-002-f01-scope-manifest.md` | Parent evidence / historical F-01 review continuation | Manifest records `F01-TEST-01`, `F01-TEST-02` and open `F01-SCOPE-01` | **Incomplete ownership chain:** no dedicated F-01 Assignment/Authorization exists in the current repo; keep outside this recall lane and establish a separate F-01 remediation/reconciliation record before publication |
| Raw Run artifacts under `/private/tmp/...` | The corresponding immutable Run receipts | Each receipt records artifact paths and SHA-256 values | External artifacts are not Git files; retention remains receipt-governed |
| DerivedData, simulator containers and other generated files | Tool/run environment, not repository source | Referenced by Run receipts where material | Not part of repository file ownership; must not be mistaken for source provenance |

## Audit conclusion

The relevant committed parent and child source/evidence paths now have an
Assignment/Authorization/commit or Run Receipt chain. The two `main` evidence
paths are traceable but intentionally unpublished. The two AX `M` paths are
traceable false residuals caused by the old local base. The F-01 manifest is the
one material in-scope ownership gap: it has a parent/review pointer but lacks a
dedicated Assignment/Authorization. Therefore the accurate answer is **not
“every file has a complete individual record”**; it is **“all currently
relevant artifacts are classified, and the remaining gap is explicitly named
and not assigned to the wrong lane.”**

## Handoff

This audit belongs to the read-only recall-design slice. It does not close the
F-01 gap, publish the `main` evidence, clean the parent worktree or authorize
production recall code. Those actions require their own bounded authority.
