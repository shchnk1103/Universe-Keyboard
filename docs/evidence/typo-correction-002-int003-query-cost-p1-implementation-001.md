# INT-003 P1 query-cost instrumentation implementation receipt

Status: **implementation committed and KeyboardCore verification passed; independent implementation/Quality review, full iOS Simulator lanes, and P2 capture are still pending.** This is not a Product cost conclusion.

## Identity and authority

- Parent: [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) remains **Active**.
- Child: [`TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001`](../assignments/typo-correction-002-int003-query-cost-measurement-001.md) remains **Active**.
- P1 AUTH: [`AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001.md), consumed at `2026-09-27T18:01:36+08:00` before the first source edit.
- Architecture input: round-3 packet commit `7ef0b4679f4f8cff9dd9e3cc9bcf93b666c86acc`; independent review **Pass with conditions**, result SHA-256 `08136d4a0fbc1afb3d74d2626306dda9b2b6795a939a35225368d81fe2d760bd`.
- Frozen source baseline: `1160ac6fd8696c3036391cdf59bc9fe096d0b219`; manifest `docs/evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r3.json`, SHA-256 `a98a722b03e2c66de61ab41ae30f59791ccb53a3b365f55a18e96d373732b395`.
- Implementation commit: `6606fbe0ad57cb0a2c636c2383f066a0a09e55e7` (`feat(int003): measure correction query cost`), parent `5c6a18b30a70921aec9a3286e446f9010bc3506a`, on isolated branch `codex/typo-correction-002-int003-query-cost-p1-implementation-20260927`.
- P2 AUTH remains **Active / unconsumed**. No Simulator boot, install, diagnostics arm, or input was performed.

## Implemented boundary

- The existing installed correction-query facade returns a finite result envelope from the same sidecar call: readiness (`ready` / `unavailable` / `unknown`) and result state (`candidates_returned`, `sidecar_unavailable`, `context_unavailable`, `empty_input`, `zero_limit`). Empty input takes precedence over zero limit. The existing candidate-array API remains available to its other callers.
- The recall driver attaches `stage_one` / `stage_two` when it dequeues the suggestion. The coordinator measures only the call to the installed facade with monotonic ticks, then derives the bucket, fence disposition, event and bounded journal admission after the end tick.
- The P1 path emits one `typo_recall.query_measured` typed field per facade invocation and no longer emits `query_begin` / `query_outcome` for that invocation. Historical code values remain decodable. A post-call stale fence is represented by `discarded_after_facade`; pre-call cancellation has no measured-query event.
- `DiagnosticEvent` now writes schema 5 and explicitly accepts schema 4 and 5. The new event requires exactly one matching `Field.typoRecallQuery`; other codes cannot carry it. The finite payload has no input, candidate, host, or fingerprint member. The existing bounded asynchronous `record(code:fields:)` path is unchanged.
- RIME readiness and context state come from the existing correction sidecar operation. No second RIME route, runtime budget change, synchronous persistence, or session ownership change was added.

## Verification performed

- `xcrun swift-format lint --strict --configuration .swift-format` passed for all changed Swift source and test files before the implementation commit.
- `swift test --package-path Packages/KeyboardCore` passed: **1,170 tests, 0 failures**, Xcode 27.0 / Swift 6.4, macOS arm64. This includes the new v4/v5 matrix, typed-field rejection/privacy, Stage 1/2, bucket, duration floor/zero/saturation/regression, bounded-ingress, queue-full and suspend-drop tests.
- `clang -fsyntax-only` passed for the changed `RimeSessionManager.m` against the iOS Simulator SDK and the checked-in RIME headers. This is a syntax check only; it does not link or execute librime.
- `xcodebuild` could not resolve the project packages in this task sandbox: the SwiftPM manifest compiler attempted to write the host-level Clang module cache, and CoreSimulatorService was unavailable. The command failed before compiling the RimeBridge test target. No App + Keyboard Simulator tests, RimeBridge Simulator tests, or Release build are claimed as passed.
- The event construction and `record(code:fields:)` admission remain after the measured call by code placement; tests confirm the same fixed-capacity asynchronous ingress can admit or drop the typed event. No runtime observer-overhead number was measured here; the controlled Debug Simulator overhead receipt belongs to P2.

## Remaining conditions and non-claims

- Independent implementation/Quality review remains pending. The focused RimeBridge Simulator tests and full local CI-equivalent iOS lanes remain unverified; hosted CI evidence is also pending.
- P2 still requires a separately reviewed P1 implementation, exact installed App/Extension hashes, designated Simulator/OS, schema/access/host/diagnostics state, Run ID and archive location in a frozen Run manifest. Consume P2 before any Simulator operation.
- No Product query-cost acceptability, numeric budget, Gate, parent Close, TestFlight, Release, ADR Accept, or `RimeRuntimeProvenance` restoration is claimed.
