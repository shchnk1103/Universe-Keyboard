# Stage B Run 1 — App + Keyboard Compile Failure

- Work item: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Candidate: pre-fix source/test manifest r1, SHA-256 `32d8a402f9a683348b6ef3395156112491d10aeead74ad61fb89e41d0d7edb7c`
- Exact base / `HEAD`: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Destination: iPhone 17 / iOS 26.0 / `D3C353BE-3AA6-499B-8F87-349073D65BE4`
- Command: Assignment CI-equivalent `Universe Keyboard` Debug `xcodebuild test` command, with task-local DerivedData and result bundle.
- Raw log: `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/Logs/UniverseKeyboardTests.log`
- Result bundle: `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/UniverseKeyboardTests.xcresult`
- Result: **Failed to compile, exit code 65; zero tests ran.**

## Finding

The three compiler diagnostics point to calls of `V1DiagnosticsLogSource.merging` at source lines 228, 248, and 280. Swift 6 treated the private static method declared inside the actor as actor-isolated when called after awaited reader operations. The method reads no actor state; it only unions rejection-reason sets on `DiagnosticsJournalCompleteness`, a `Sendable` value.

## Disposition

The helper is now explicitly `nonisolated` with a comment documenting that boundary. This does not change completeness merge semantics. The changed file's current SHA-256 is `bc874c7f019645e18c04b8b2c3a9d21c8247afc75b44cc8951a857078d558a70`; the corrected seven-file source/test identity is frozen in manifest r2. All run-1 results belong to the superseded r1 candidate and are not reused for r2 acceptance. The full matrix must pass on r2.
