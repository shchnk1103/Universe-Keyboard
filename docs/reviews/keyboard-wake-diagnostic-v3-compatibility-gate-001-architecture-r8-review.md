# Architecture R8 Review — V3 Compatibility Gate 001

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Stable lane: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001/architecture`
- Reviewer: independent Architecture & Knowledge Steward runtime `/root/architecture_r8_luna`
- Packet: [Architecture R8 packet](keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r8-packet.md)
- Packet SHA-256: `ea4b4bd5dbd8d28e4d9a797d9fb5c256a6dc1b2b4605d54f19eae1cd6ed0300d`
- Baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Assignment SHA-256: `9ff30b053cc66e690d2bbf03950a7ec2047ce7a76ae799d3b2aa2c5793a61a55`
- Manifest r2 SHA-256: `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- Verdict: **Pass with conditions**

## Summary

The packet, Assignment, Product Authorization, manifest r2, Stage B report, prior R7 receipt/usage, baseline, and all seven manifest-listed source/test hashes matched. The reviewer completed the source and test coverage that R7 left open. This review is bound to the source/test candidate and does not claim that every documentation file in the worktree is identical to its state during Stage B.

## Review questions

1. **Versioned read and retained history — Pass.** The decoder accepts v3/v4/v5 per-record, restricts v4 marker and v5-only typo-recall codes/fields, checks typed payload/code pairing, retains mixed-version history without relabeling, and preserves v5 `typoRecallQueryMeasured`. Tests cover v3/v4/v5 decoding, mixed history, old-record re-encoding, and v5 writer rejection for retained v3 records.
2. **Closed wire schema / raw-key validation — Pass with accepted non-claim.** The reader calls the raw-key validator before `JSONDecoder`; envelope, field, and typed payload allowlists/required keys/enums are checked, with validator assertions for raw unknown keys, unsupported/non-integer versions, malformed payload, and code/payload mismatch. Duplicate JSON member detection remains an explicit Proposal/ADR non-claim requiring a separate decision if changed.
3. **Incomplete continuation and fallback — Pass.** Reader snapshots/pages/queries preserve rejection completeness; Main App aggregation carries it across first-page, preview, and continuation reads. Tests cover incomplete propagation, incomplete-empty fallback suppression, and known-complete empty-v1 fallback.
4. **Production writer and fixture boundary — Pass.** No changed production Extension file adds a wake-marker call site. The existing writer remains v5 and rejects v4-only marker through `isWritableV5`. Test marker records are constructed via raw records in temporary storage without production Extension ingress or `DiagnosticsJournalRuntime`. No dedicated spy asserts that those production paths can never be invoked by future code.
5. **Privacy and actor boundary — Pass.** New marker fields are bounded enums/categories/integers, output formatting is content-free, and the `nonisolated` helper only combines `Sendable` completeness values without actor state access.
6. **Test strength — Adequate for the R7 coverage gap, with bounded breadth.** Tests directly assert version/raw-key/payload rejection, mixed-version and v5 retention behavior, continuation completeness, and fallback behavior. The reader propagation tests use unknown-code/malformed-payload rejection as representatives; not every rejection reason is separately asserted through the Reader. The v5 fixture exercises `typoRecallQueryMeasured` but not each typo-recall code.
7. **Candidate binding — Pass for source/test scope.** Base, manifest r2, Stage B record and seven source/test hashes match. A current `docs/ACTIVE_WORK.md` status edit is outside the source/test manifest; this review does not make a whole-worktree identity claim.

## Residuals

| ID | Owner | Disposition | Evidence |
|---|---|---|---|
| `AR7-COV-01` | Product Lead / Coordinator and independent Architecture reviewer | `fix` — **closed by this round** | R7 receipt and this R8 source/test review. |
| `AR7-ACCEPT-01` | Product Lead and Architecture Authority | `accept` | Proposal 0.4 and ADR 0036 addenda preserve duplicate-member detection as a non-claim. |
| `AR8-SCOPE-01` | Product Lead / Coordinator | `fix` | Current `docs/ACTIVE_WORK.md` has a later status-only edit outside manifest r2. No whole-worktree equality claim is made; source/test identity remains bound to manifest r2. |

This review is not a Product decision, Quality Gate, runtime diagnosis, root-cause conclusion, Release decision, or parent Assignment closure. It does not authorize production marker emission, publication, or any release action.
