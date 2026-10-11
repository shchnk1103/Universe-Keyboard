# RIME-SYNC-001 Quality re-review — P1-remediated candidate — 2026-09-23

## Verdict

**Pass with conditions** for the bounded iOS V1 Simulator evidence and local
candidate identified below. This is not Product Close, merge, TestFlight or
Release approval. `RIME-SYNC-001` remains `Active`.

## Exact candidate identity

- Base: `4a51228fc8e435d538e9a5f7342ae325502e1e66`
- Candidate manifest: 29 modified/added worktree paths; canonical manifest
  SHA-256 `8055d758fe34edd376ff9c85474f2b2335bcf0d237af596368d3cdfc1479d786`.
  Manifest rows are sorted by path and encode `status<TAB>path<TAB>SHA256(file
  bytes or DELETED)<LF>`. The Quality receipt itself is excluded.
- Reviewer: independent fresh runtime, GPT-6 Luna, agent `01a0ce77-d696-78c0-82d1-6debb52c10e6` (Mendel)
- Review mode: read-only; reviewer independently enumerated the paths and
  recomputed the manifest.

## Evidence reviewed

The reviewer independently inspected the RIME Sync contract and Assignment,
the prior Quality receipts, P1 Architecture re-review, remediation/readiness
evidence, current RIME source/tests/CI changes, test trees and logs.

| Claim | Outcome | Evidence |
|---|---|---|
| P1 fail-closed correction and regression coverage | `pass` | Only confirmed Cocoa `fileReadNoSuchFile` is treated as an absent settings object. Other read failures propagate before any package write. The missing-object/first-publish and stale-ETag path plus existing-but-unreadable path with nil ETag/no `format.json` are covered by the focused tests. Architecture independently accepted the P1 fix on its exact source/test snapshot. |
| Focused local-folder tests | `pass` (`Quality-reverified`) | iPhone 18 Pro / iOS 27.0 Simulator: 2 passed, 0 failed, 0 skipped. xcresult: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T13-20-29-418Z_pid5815_033d32f2.xcresult`; log: `.../logs/test_sim_2026-09-23T13-20-29-418Z_pid5815_0ac239e2.log`. |
| Full App + Keyboard XCTest suite | `pass` (`Quality-reverified`) | `Universe Keyboard` Debug scheme, iPhone 18 Pro / iOS 27.0 Simulator: 396 executed = 386 passed + 10 skipped + 0 failed. xcresult: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T13-21-27-384Z_pid5815_d036b9ff.xcresult`; log: `.../logs/test_sim_2026-09-23T13-21-27-384Z_pid5815_9c5e3c48.log`. Reviewer inspected result tree/log. |
| Swift format and patch hygiene | `pass` (`Executor-recorded`, independently noted) | Strict `swift-format lint` for all 10 changed Swift files and `git diff --check` passed; no later Swift edits. |
| Test discovery count | `inconclusive` (`Quality-reverified`) | Tool reported 397 discovered; xcresult contains 396 executed. Raw discovery output and cause of the one-count discrepancy are unavailable; retain `UNKNOWN`, do not count discovery as execution. |

The full-suite skips were individually checked in the xcresult and are not
passes: five scheme-coexistence fixtures, three authorization-gated physical
device cases, one RIME artifact fixture and one unsigned Keychain entitlement
case. The unsigned entitlement skip does not prove Keychain integration.

## Residual ledger and conditions

| ID | Owner | Disposition / status | Evidence boundary |
|---|---|---|---|
| `ARCH-RIME-SYNC-001-P1-01` | Main App / RIME Sync; Architecture | `Resolved` for the bound snapshot | [Architecture re-review](rime-sync-v1-architecture-rereview-2026-09-23.md) and focused/full xcresults. |
| `ARCH-RIME-SYNC-001-P2-01` | Architecture & Knowledge Steward / Main App diagnostics | `Pending`; non-blocking for this bounded verdict | [Original Architecture review](rime-sync-v1-architecture-review-2026-09-23.md); stable diagnostic error-code mapping remains open. |
| `397 discovered / 396 executed` | Quality / test-runner evidence owner | `Pending`, cause `UNKNOWN`; does not block using the xcresult executed count | Current full-run log and xcresult above; raw discovery output unavailable. |
| `TD-002` | Main App / RIME Platform | `tech_debt:TD-002`, risk open | Cross-process exclusion remains unproven; see [TECH_DEBT](../TECH_DEBT.md#td-002-validate-rimeuser-concurrent-access). |
| `TD-008` | Main App data operations / RIME Platform | `tech_debt:TD-008`, full portability deferred | Cross-platform fixtures, scheme portability and staged YAML/TXT import remain out of scope. |
| `TD-013` | Diagnostics owner / Quality | `tech_debt:TD-013`, open | Legacy diagnostics/query gaps remain; this review does not imply they are harmless. |
| `TD-017` | Main App RIME sync / RIME Platform | `tech_debt:TD-017`, open | Sandbox-extension attribution remains unknown; later successes do not resolve it. |
| Historical exact error `UNKNOWN` | Main App diagnostics / Quality | `tech_debt:TD-013` | Unrecoverable historical diagnostic detail remains unknown. |
| Run 02 `INVALID` | RIME-SYNC-001 Product / Quality | `accept` only as invalid historical record | Preserve its prior `INVALID/HOLD`; do not relabel as sync pass. |
| `UI-01` | Main App / Quality | `fix`; remaining cases pending | Authentication/wrong-key recovery and actual disconnect/deletion outcomes are not verified. |
| `UI-02` | Human owner / Quality | `fix`; provenance/independent review pending | Human-reported VoiceOver/enlarged-text check lacks exact installed source/build digest and screenshot/audio receipt. |
| `SEC-01` | Main App / Quality | `fix`; Simulator/CI/device residuals pending | Prior signed Simulator Keychain CRUD evidence is not a rerun on this final P1 snapshot; this run's unsigned Keychain case skipped. No hosted CI or physical-device Keychain claim. |

## Limits and non-claims

The current P1 snapshot did not rerun KeyboardCore, RimeBridgeTests or Release
build. Earlier-candidate results remain historical and are not treated as
final-snapshot reruns. No hosted workflow result, physical payload provenance,
physical-device Keychain result, production `BGProcessingTask` delivery,
provider-side deletion result or Product Gate/merge/Release conclusion is
claimed. CloudKit is deferred; full cross-platform compatibility remains
`TD-008`; previous Run 02 `INVALID/HOLD` is unchanged.

The result xcresults and logs provide path/operation association to the
isolated worktree and Simulator, not a cryptographic digest binding of the
executed binary to the candidate manifest.

## Handoff

Test / Release Maintainer owns this bounded Quality conclusion and the
discovery-count discrepancy. Main App / Quality owner retains UI-01 and SEC-01
follow-ups; Human owner and Quality retain UI-02 provenance; Architecture owner
retains the diagnostic-code P2. Product Lead alone decides parent lifecycle.
