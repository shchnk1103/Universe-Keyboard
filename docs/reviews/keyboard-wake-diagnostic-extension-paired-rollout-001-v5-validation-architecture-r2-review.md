# Architecture Review Record — Paired Rollout v5 Validation Evidence R2 Supplemental

## Identity and verdict

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`
- Stable review lane: `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001/v5-validation-architecture`
- Review round: `2` — supplemental to R1; R1 remains an immutable historical result
- Packet SHA-256: `cfd059f12e7aecb58a1e0a9b4929a92b28866e15ae69ff6338a9758c0b6f30c3`
- Baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Assignment SHA-256: `a7da9fb1dae3cbf178ddf7a3c56c9a1f2ed0cd7bbe93d907004fe81e37abc1a9`
- Validation report SHA-256: `f35b9e13a546450616a32c852f88e84fddfd7f638f5efc5e3a435440a2a88cde`
- Manifest r2 SHA-256: `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- Stage authorization SHA-256: `7204731eb1af58ab428b56235e0602aeff86373f395fbf9e7681bb5cf0576375`
- Validation Entry SHA-256: `d0f5092e458778ec0e1eac387edcdf3dd9f8e9bc7dc6d9983e9fce9228727842`
- Verdict: **Partial / incomplete**

R2 confirmed the frozen document identities and all seven candidate file hashes. The saved result summaries agree with the report's main test counts. Full source/test inspection and complete skip-reason verification did not fit within the frozen 12-interaction budget, so the required complete-coverage criteria were not met. `ARV5-R1-COV-02` remains open.

## Findings

1. **Frozen identity — Partial.** Packet, Assignment, validation report, manifest r2, stage authorization and Entry receipt hashes match the frozen values. All seven manifest file hashes match. The target worktree `HEAD` equals the specified baseline. The artifact-index and recursive `.xcresult` inventory file hashes match the report. All four bundle `Info.plist.rootId` values appear in the corresponding frozen inventory entries, and available summary metadata matches the report's counts.

   **Uncovered:** The reviewer did not recompute the complete recursive tree digest for each result bundle, so this review does not claim a fresh full-tree digest match.

   Evidence: packet frozen identity; manifest r2 `source_files` / `test_files`; target worktree `git rev-parse HEAD`; `/private/tmp/ukey-wake-v5-20260930.nBWReN/validation-artifacts.json`; `xcresult-bundle-hashes.json`; the four named `.xcresult/Info.plist` files and read-only summary metadata.

2. **Full candidate source/test review — Partial.** Visible portions of the exact-baseline diffs are consistent with the frozen v5 compatibility boundary. `DiagnosticEvent` retains writer schema v5 and reader v3/v4/v5 validation; v4-only payloads are limited to old-record reading; the journal writer rejects events that are not writable as v5. Visible tests cover mixed v3/v4/v5 history, rejection of rewriting old records as v5, invalid or mismatched wire content, and incomplete status propagation.

   **Uncovered:** The seven files total 6,793 lines. Full-file output and parts of the diffs were truncated, particularly the wire validator, journal and test-file remainder. No conflict was found in the portions inspected, but the review cannot establish a whole-file conclusion. The three Extension production call sites were outside this round's manifest allowlist, so production wake-marker emission off is not upgraded to an independently proven fact by R2.

   Evidence: the four source and three test paths in manifest r2; their bounded diffs against `84b9c19227330b0fe6ff391be001ee398010fd6a`; ADR 0036 compatibility decision and v6 addendum.

3. **Test-to-claim mapping — Partial.** Inspected assertions support compatibility and diagnostics-reader contracts, including mixed schema history, preservation of older labels, and rejection/completeness propagation. The validation report limits the result to the authorized matrix and does not claim installed paired-build behavior, typing recovery, runtime keyboard behavior or v6 production marker behavior. Generic `.xcresult` summaries do not establish those runtime outcomes.

   **Uncovered:** Relevant source/test files were not fully reviewed, so the test-to-claim mapping is not complete.

   Evidence: visible assertions in `DiagnosticEventTests.swift`, `DiagnosticsJournalTests.swift` and `DiagnosticsLogSourceTests.swift`; validation report sections “Evidence matrix” and “Disposition”.

4. **Raw evidence, skips and 429/428 — Partial.** The read-only result summaries report:

   - RimeBridgeTests: 105 total, 85 passed, 20 skipped, 0 failed.
   - App + Keyboard: 428 total, 418 passed, 10 skipped, 0 failed.
   - Signed Keychain integration: 1 passed, 0 skipped, 0 failed.
   - Release build: succeeded, 0 errors, 0 warnings.

   The App + Keyboard raw suite totals are 412 + 16 = 428, matching `.xcresult`. The validation report's contemporaneous XcodeBuildMCP discovery count is 429. The difference remains unexplained; neither count is substituted for the other. The report's conditional skip groups total 20 RimeBridge and 10 App + Keyboard checks; no skip is counted as a pass. Raw-log inspection confirmed some fixture, identity, entitlement and physical-device limitations.

   **Uncovered:** Skip-line output was truncated, preventing line-by-line independent confirmation of every recorded skip reason. Preserve all skip statuses.

   Evidence: `RimeBridgeTests.summary.json`, `UniverseKeyboardTests.summary.json`, `RimeSyncKeychain.summary.json`, `UniverseKeyboardRelease.summary.json`; corresponding `.xcresult` `Info.plist` and summary metadata; `UniverseKeyboardTests.log` suite totals; validation report sections “Evidence matrix” and “Skips and coverage limits”.

5. **Bounded handoff — Pass within this review's scope.** Conclusions remain limited to the exact frozen v5 candidate and listed validation evidence. R2 does not close the paired-rollout Assignment, authorize v6 implementation/promotion, determine root cause, or constitute a Product, Quality or Release Gate. The accepted v6 addendum keeps future implementation, same-version App + Extension identity, exact-candidate review, installation and Maps reproduction separate.

   Evidence: validation report “Disposition”; Architecture R1 “Residuals” and “Coverage and stop reason”; ADR 0036 v6 addendum “Decision” / “Follow-up Work”; wire-version Product Decision.

## Residuals and status

| ID | Owner | Status / proposed disposition | Evidence pointer |
|---|---|---|---|
| `ARV5-R1-COV-02` | Architecture & Knowledge Steward / Coordinator | **Open** — `fix`; complete full source/test and exact-diff review under a new Product-approved packet | Manifest r2 seven paths; validation report |
| `ARV5-R1-EVID-04` | Quality Reviewer | **Open** — R2 checked summaries and Info.plist metadata but did not reconcile every raw skip reason; retain with Quality | Named raw logs and summaries under `/private/tmp/ukey-wake-v5-20260930.nBWReN/` |
| `V5-Q-001` | Executor / Environment Executor; Product Lead decides added scope | No disposition made; Quality R1 proposed bounded acceptance unless a later decision depends on the discovery denominator | Validation report; `UniverseKeyboardTests.summary.json` and `.log` |
| `V5-Q-002` | Executor / Environment Executor; Product Lead decides future test scope | No disposition made; Quality R1 proposed acceptance as unverified conditional coverage, or future fixture-backed fix under new authorization | Validation report “Skips and coverage limits”; `RimeBridgeTests.log` |
| `V5-Q-003` | Executor / Environment Executor; Product Lead decides future test scope | No disposition made; Quality R1 proposed acceptance as unverified conditional coverage, or future fixture-backed fix under new authorization | Validation report “Skips and coverage limits”; `UniverseKeyboardTests.log`; `RimeSyncKeychain` results |

No Product disposition for `V5-Q-001..003` is made or inferred here.

**Completed coverage:** frozen document hashes; seven candidate hashes; baseline identity; available bundle `Info.plist` and summary metadata; visible portions of candidate diffs; report claim boundaries.

**Uncovered coverage:** full source/test contents and all exact diffs; complete raw skip-reason reconciliation; complete `.xcresult` tree-digest recomputation.

## Coordinator integrity note

The reviewer returned a note that it could not find the “Independent Reviewer Lane Packet” section in `docs/ASSIGNMENT_POLICY.md`. The coordinator had read that section before dispatch and confirmed it is present in the current worktree at line 206. The frozen R2 packet's allowed-files list did not include `docs/ASSIGNMENT_POLICY.md`, although the dispatch preamble directed the reviewer to read that policy section. This is a packet-boundary inconsistency; it does not change the candidate findings or close any residual. Any next review packet must list and hash its required governance input explicitly.

## Non-claims

No runtime keyboard conclusion, root cause, Product/Quality/Release Gate, v6 authorization, Maps reproduction, or Assignment closure is claimed. The R1 receipt remains Partial / incomplete; R2 is a supplemental Partial / incomplete result.
