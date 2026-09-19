# Authorization: AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — attempt inconclusive; retry prohibited under this receipt` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Case | `TC2-CASE-INT-003` / `TC2-CTR-INT-002` |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | Build one local-only testability-enabled snapshot and collect one controlled INT-003 trace |
| Run ID | `TC2-SIM-20260919-175102-INT003-AX-REVAL-01` |
| Consumed at | `2026-09-19T17:51:02+08:00` |

This Authorization is a bounded exception to the ordinary evidence-only INT-003 lane. It permits only the already-reviewed testability/accessibility merge to be present in the local test snapshot so that an AI-controlled AX harness can send real key taps. It does not authorize new product behavior or a publication action.

## Snapshot transition

- Parent implementation source remains the dirty parent snapshot bound by the continuation Assignment:
  - Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
  - Branch: `codex/typo-correction-002-provenance-sidecar`
  - Parent HEAD: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
  - Tracked production/test diff SHA-256: `c9225a435b833aa1c637c21bead8f85f1465d2b6d161c30a74b5789408c523be`
  - Untracked production/test content SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Testability input is the already-reviewed and merged PR #140 result at `162b09fd58ba60538a944026b1902efa405c75aa`. The relevant AX/harness changes are included as an immutable input; no new AX/product code may be authored under this Authorization.
- The combined snapshot must receive fresh source/build/package hashes before the first runtime capture. It is not the same build as the sidecar Run Receipt and must not reuse that receipt's package identity.

## Build facts before capture

- Build/run: XcodeBuildMCP `build_run_sim` succeeded in `44.4 s`; the new Debug package was installed and launched on the designated Simulator.
- Derived-data output: `/tmp/universe-keyboard-typo-correction-002-int003-ax-derived/Build/Products/Debug-iphonesimulator/Universe Keyboard.app`.
- Combined tracked source/test diff SHA-256 (binary `git diff --binary HEAD` over `Keyboard`, `Packages`, `Universe Keyboard`, `UniverseKeyboardTests`, `KeyboardTests` and `UniverseKeyboardUITests`): `7df4fe1a6bed9c4d8600fa4ccd6bbe96adf85705ce7aa46b3b0ea847c84d319d`.
- Untracked parent production/test files are unchanged from the bound parent snapshot; their individual SHA-256 values are recorded in the capture receipt.
- Main executable SHA-256: `903328dbef69e1adba5be240a856f7279f8771bfb1ef945f33fcb4ca6d6423fc`.
- Keyboard executable SHA-256: `5a45906aafc3c8ee42db7cc256c225671abc62d1c27892c07a15ccb5149df6e5`.
- Main debug dylib SHA-256: `113338d1d867ba33fab319a303599746d5513342002f7aa9b378773d1ed8280f`.
- Keyboard debug dylib SHA-256: `07210559b724548f00d8ebcfcdc2fdbcdb18c9e7f6a445d9a0573e87b0be110c`.
- Main-App runtime snapshot showed `输入方案 = 雾凇拼音` and `资源状态 = 已就绪`.
- The existing App Group provenance file is readable at the new installed runtime path and has SHA-256 `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54`; its contents remain bound to active schema `rime_ice` and receipt `078F7EA2-F9CA-4033-B7DD-48BE636BEB38` pending the capture-time re-read.

## Attempt disposition

- The AX preflight was successful, but the external batch attempt used one incorrect letter ref and the post-batch snapshot no longer proved Universe Keyboard identity. It is recorded as [`INT-003 AX attempt 01 — inconclusive`](../evidence/typo-correction-002-sim-run-2026-09-19-int003-ax-reval-01-inconclusive.md).
- This Authorization is consumed and cannot be reused for a retry. A new bounded Authorization and Run ID are required for the XCTest-internal cadence harness.

## Authorized operation

1. Materialize a local combined build containing the parent implementation snapshot and the merged PR #140 testability/accessibility changes.
2. Run the existing app/extension on the designated iPhone 17 Pro Max / iOS 27 Simulator and record the new signed package identity, active schema and exact RIME provenance.
3. Use an opt-in AX harness to select Universe Keyboard, verify the product-owned keyboard surface, resolve independent key elements and invoke their existing `tap()` action path.
4. Generate a controlled INT-003 stimulus: inter-key gaps below the documented 180 ms debounce boundary, followed by a pause beyond the boundary. Record actual diagnostic timestamps, debounce arm/cancel, query start/finish, owner publication, UI application and stale-result handling.
5. Retain only content-free diagnostics and a SHA-256 manifest. Record raw input length and timing bounds, not raw pinyin, candidate text or host text.

The harness must fail closed unless it has selected Universe Keyboard and resolved the independent key targets. `typeText`, pasteboard, host injection, `documentContext` and `setMarkedText` are prohibited. A planned delay is not evidence of cadence; the Run Receipt must use observed diagnostic timestamps.

## Exact target

- Simulator: iPhone 17 Pro Max / iOS 27.0.
- UDID: `06C5BC3E-7599-4761-A1A2-71DAEA991474`.
- Host: Messages, synthetic conversation `+1 (888) 555-1212`.
- The existing `rime_ice` provenance must be re-read from the new installed App Group; the previous sidecar provenance receipt is historical and cannot be silently reused.

## Explicit exclusions

- No change to the 180 ms threshold, search budget, recall enablement, RIME schema, vendor archive or production behavior.
- No FakeCandidateProvider, old Ice directory, synthetic RIME fixture or candidate-count inference.
- No reuse of `TC2-SIM-20260919-171730-SIDECAR-REVAL-01` or the original `AUTH-TYPO-CORRECTION-002-INT003-REVALIDATION-001` as this build's evidence identity.
- No commit, push, pull request, merge, TestFlight, Release, Product Gate, Quality Gate or Assignment closure.
- No QA-001, paired-performance or Product conclusion may be written under this Authorization.

## Stop / completion

Stop and record an explicit inconclusive receipt if the combined snapshot cannot be proven, Universe Keyboard cannot be selected, independent AX key targets are unavailable, the input is routed to the system keyboard, or the actual cadence cannot be observed. A successful capture produces an INT-003 Run Receipt only; it does not close `TC2-CASE-INT-003`.
