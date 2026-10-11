# Architecture Review — R2 (Partial)

- Work item: `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`
- Lane / round: `UK-WAKE-V6-B-ARCH` / R2
- Packet SHA-256: `7ec8cfdbe82ec22434bb79bfcff624744ae0d11b3cc5dbb527e78c54e2835e4b`
- Candidate root: `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`
- Baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`; Stage A manifest `71ab90d528b598f6bd7a2d19f2f20dd942e2e4eeb91d5c14791dbf4ec15a0e18`.

## Identity and scope

At R2 entry, the packet and sidecar digests matched, all 28 allowlisted paths at the explicit root matched their listed hashes, and `HEAD` matched the required baseline. Review was read-only and limited to the packet allowlist. The combined diff output was truncated by the tool; only the visible evidence below is treated as reviewed.

After that snapshot, the Root Coordinator reported that `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift` was repaired because its temporary fixture lacked `g1/open`, and that this file's hash changed. I did not read the updated file. The earlier snapshot therefore cannot establish final-candidate AS4 behavior.

## AS1–AS6 coverage

| Claim | Coverage | Evidence and finding | Owner / disposition |
|---|---|---|---|
| AS1 reader version and marker contracts | Covered at source level | `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift`: `supportsReading` explicitly admits 3/4/5/6; wake markers are gated to 4/6; typo-recall is gated to 5/6; decoding reads `schemaVersion` as `Int` and rejects values outside the supported set. No AS1 defect found in the inspected source. | No corrective disposition indicated by this review. |
| AS2 writer remains v5 and producers stay unchanged | Uncovered | The visible diff shows `schemaVersion = 5`, `isWritableV5`, and the journal writer's v5 guard. The full writer path and Runtime/Ingress/Extension comparison against the Stage A manifest were not completely visible in the truncated result. | Root Coordinator: retain these exact allowlisted paths as remaining review locators; no new input requested. |
| AS3 strict validation and incomplete propagation | Uncovered | The visible `DiagnosticEvent` decoder has version and marker/code/payload pairing guards; the visible journal diff adds completeness values. I did not complete review of `DiagnosticEventWireValidator`, all Journal/App propagation paths, or the disclosed duplicate-member parser limitation. | Root Coordinator: review the listed validator, journal, App source, and decision/evidence documents under a separately authorized budget. |
| AS4 Core and App test coverage | Uncovered for the final candidate | The pre-repair App test snapshot visibly had five composite-query scenarios (`v6-only`, `mixed-complete`, `v6-incomplete`, `mixed-incomplete`, `rejected-only`) and a complete-empty fallback test. The coordinator reports this file changed after review to create the fixture directory; I did not inspect that final content. Core test coverage was not visible in the truncated output. No final-candidate test claim is made. | Root Coordinator: exact locator `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift` plus `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` and `DiagnosticsJournalTests.swift`; require the new content identity before relying on AS4. |
| AS5 no heat-path synchronous I/O, unsafe concurrency, or boundary expansion | Uncovered | The complete changed-source diff, including controller, bootstrap, proxy, and journal paths, was not available in the truncated result. | Root Coordinator: remaining locators are those exact allowlisted source paths; no expansion to adjacent files. |
| AS6 documentation separates reader-only scope and avoids false gate/release/root-cause claims | Uncovered | Documentation diff was truncated before the applicable Assignment, ADR, Product Decision, Stage A evidence, and Stage B authorization could be checked against this candidate. | Root Coordinator: remaining locators are the corresponding entries in `architecture-inputs.json`; no broad governance audit implied. |

## Verdict and remaining dependencies

**Partial / incomplete.** AS1 is covered at source level; AS2–AS6 remain uncovered. The App fixture update means the prior AS4 snapshot cannot be reused as final-candidate evidence. This review makes no Gate, Release, root-cause, Simulator, Stage C producer, full CI, real-device, or performance claim. No new risk acceptance is proposed.

For any continuation, preserve the current scope and bind the repaired App test to a fresh explicit digest. The remaining source and documentation locators are the exact AS2–AS6 rows above; excluded Stage C and broad governance evidence are still outside this Architecture verdict.
