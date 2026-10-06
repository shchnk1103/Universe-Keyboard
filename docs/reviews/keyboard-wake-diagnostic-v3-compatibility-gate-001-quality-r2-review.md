# Quality Review R2 — V3 Compatibility Gate

## Identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Assignment SHA-256 reviewed: `49638b87156ff489aa444307833e7a354259418818dd148762c60527c4b2fa2b`
- Quality packet SHA-256: `1841350e16bf6c225a4cab66affc09e8e90f1d841df46d1ba1fb1c38b2ad693b`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- Proposal addendum SHA-256: `102707357458ff2c0e965ae3bf7b00d82c61ef218450eacd5101e437004a5024`
- ADR 0036 addendum SHA-256: `1d78cffb211800187d8f72a22789c8a789ca72ab98f9c68a12ddc969bae8f8ce`
- CI workflow SHA-256: `cb4a41108ba0e9268b04b1aaca8bd06480da3e0dd8706221acbbce3ad6a0a6a8`
- Exact base: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Disposition: **Pass with conditions**

This was a read-only validation-plan review. It is not an implementation-candidate review, test result, Quality Gate, or Product Gate.

## Findings

- Producer-off does not remove a required validation target. The Runtime API, reader, Main App fallback, compatible Extension surfaces, and existing v5 behavior still require candidate-level evidence.
- The v4 marker fixtures are restricted to temporary or in-memory storage and must not touch production App Group storage, `DiagnosticsJournalRuntime`, or real Extension ingress.
- Candidate coverage must include per-record v3/v4/v5 validation, mixed history, v5 `typo_recall`, malformed/unsupported/mismatched records, query-wide incomplete continuation, and fallback suppression. Current baseline behavior does not prove future v3 coverage.
- All six current CI heavy jobs are present, including strict format, KeyboardCore, RimeBridge, App + Keyboard, signed Keychain, and Release build. The Keychain entry includes signing flags and the exact test selector `testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem`.
- The pinned RIME manifest/digest must be verified on the candidate. Stage A remains host-only; Stage B requires a fresh exclusive reservation and a single exact UDID for all Simulator validation.
- Historical candidate/test evidence remains historical and cannot substitute for the integrated candidate's source manifest and result bundles.

## Conditions before implementation evidence can complete

1. Freeze a new exact source/test manifest and prove the v4 fixture isolation boundary.
2. Execute the full required matrix and the accepted reader/fallback test coverage against that candidate; do not reuse predecessor results.
3. Verify the pinned RIME artifact manifest/digest.
4. Obtain the fresh exclusive Simulator reservation before Stage B and keep one UDID throughout.
5. Obtain new numbered Architecture and Quality reviews bound to the exact implementation candidate and evidence.

The Assignment remains **Assigned / Not Ready** until all exact-revision role acknowledgments and Entry Criteria are satisfied. This plan review does not establish test, build, runtime, or behavior results.

## Evidence boundary

The reviewer verified the frozen R2 packet, Assignment, Product Authorization, addenda, workflow, and necessary current-source context by read-only inspection. No files were modified; no tests, builds, Simulator operations, installation, network access, root-cause finding, behavior conclusion, Gate, Release, or parent closure occurred.

The reviewer reported 10 of 12 allowed calls and approximately two minutes of active time. A separate checkpoint record was not included in the final response; see the [R2 usage record](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r2-usage-2026-09-29.md). The reviewer did not write this receipt; the coordinator recorded it from the final response.
