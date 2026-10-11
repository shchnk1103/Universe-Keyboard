# KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001 — Stage B Validation

## Current Status

Stage B's CI-equivalent validation matrix completed against source/test manifest r2. All five required matrix jobs succeeded. The exact-candidate Architecture and Quality reviews remain pending. This evidence does not close the Assignment or its parent.

## Candidate and reservation identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Worktree: `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`
- Branch: `codex/keyboard-wake-v3-compatibility-gate`
- Base commit: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Candidate state: local, uncommitted
- Source/test manifest: [`manifest r2`](keyboard-wake-diagnostic-v3-compatibility-gate-001-source-test-manifest-2026-09-29-r2.json), SHA-256 `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- Manifest files: 4 source + 3 test files; all 7 current hashes matched the manifest before and after the final matrix.
- Stage B reservation: [`receipt`](keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-reservation-2026-09-29.md), iPhone 17 / iOS 26.0 / `D3C353BE-3AA6-499B-8F87-349073D65BE4`.
- XcodeBuildMCP inventory at 2026-09-29 14:49 UTC showed that exact simulator still Booted. The inventory was read-only; no other simulator was operated.
- XcodeBuildMCP used the task-local profile `v3-compat-stage-b-2026-09-29` with `persist:false`; the user's other profiles/defaults were not changed.
- All Xcode DerivedData, result bundles, and raw run logs were directed to `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2`.

## Toolchain and host

- Xcode 27.0, build `27A266a`
- Swift 6.4, `swift-driver` 1.168.6, `swiftlang-6.4.0.34.1`, clang `2100.3.34.1`
- Host target: `arm64-apple-macosx27.0.0`
- Simulator destination for all Xcode jobs: `platform=iOS Simulator,id=D3C353BE-3AA6-499B-8F87-349073D65BE4` (iPhone 17 / iOS 26.0)
- Toolchain capture: `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/Logs/toolchain.log`

## Validation matrix

| Job | Result | Evidence |
|---|---|---|
| KeyboardCore host tests | Exit 0; 1,177 tests, 0 failures | Raw log `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/Logs/KeyboardCore.log`, SHA-256 `c4cfe7d0f78e8bb8608ecf57b298f306278442d6514cc859015b8e2c78ba3ac4` |
| RimeBridgeTests on reserved simulator | Exit 0; 105 tests, 20 skipped, 0 failures | Raw log `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/Logs/RimeBridgeTests.log`, SHA-256 `03bace0f98cf9b4dae16834fff0d0d9bb56f776c66c729bf38fb6725119bc608`; result bundle `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/RimeBridgeTests.xcresult`, `Info.plist` SHA-256 `2a496c8ace5d8d5b4e9f9a3dd6f16c6e96c574efccb730f3d65c7d4301044531` |
| UniverseKeyboardTests + KeyboardTests on reserved simulator | Exit 0; 412 + 16 = 428 tests, 10 skipped, 0 failures | Raw log `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/Logs/UniverseKeyboardTests.log`, SHA-256 `3f80b1dbf8038e0c2a5f32337913d5acab3886b4a59abfb42dcd51b87daa8339`; result bundle `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/UniverseKeyboardTests.xcresult`, `Info.plist` SHA-256 `75ef8f21d89e1a7738d3195b0b9a0b3c0b8a77a4386746d4d87e97c58626b97d` |
| Signed Keychain selector | Exit 0; 1 test, 0 skipped, 0 failures | Raw log `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/Logs/RimeSyncKeychain.log`, SHA-256 `fcceb32dc240b2c2500543dc9606267cfa334ed03bf84b5227fa73b6b10cb344`; result bundle `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/RimeSyncKeychain.xcresult`, `Info.plist` SHA-256 `4ad9bb01acb160fac85d68245f474d2174412eeb60de280004ad456b445363c0` |
| Release build | Exit 0; `** BUILD SUCCEEDED **` | Raw log `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/Logs/UniverseKeyboardRelease.log`, SHA-256 `36c18fe2bb0048b366e22c55b40f364933b2608b03f096586c1715667a4065bc`; result bundle `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/UniverseKeyboardRelease.xcresult`, `Info.plist` SHA-256 `2378c91fc67bde2a78edd5a203371d87b4491c3fead16f00c866cce14bd10fc7` |

### Skipped test dispositions

- RimeBridgeTests' 20 skips require external real-runtime fixtures: Lua shared/user directories, isolated T9 spike directories, a pinned S4 commit, or R4-B real-engine directories. Their names and individual reasons are in `RimeBridgeTests.log`.
- App + Keyboard's 10 skips are environment-gated: one unsigned-host Keychain case (the separate signed simulator selector passed), downloaded scheme archive/tree fixtures, and three TD-012 physical-device-only cases. Their names and individual reasons are in `UniverseKeyboardTests.log`.
- These are test-level skips, not failures. No skipped test is represented as passed or as evidence for a physical-device/runtime claim.

### Exact commands

The following commands are recorded from the raw logs. The `xcodebuild` command lines also specify the per-run result bundle and isolated DerivedData path shown above.

```bash
env CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/ClangModuleCache \
  swift test --package-path Packages/KeyboardCore \
  --scratch-path /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/KeyboardCoreBuild \
  --cache-path /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/SwiftPMCache \
  --config-path /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/SwiftPMConfig \
  --security-path /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/SwiftPMSecurity

xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "RimeBridgeTests" -configuration Debug \
  -destination "platform=iOS Simulator,id=D3C353BE-3AA6-499B-8F87-349073D65BE4" \
  -derivedDataPath /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/DerivedData \
  -resultBundlePath /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/RimeBridgeTests.xcresult \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test

xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug \
  -destination "platform=iOS Simulator,id=D3C353BE-3AA6-499B-8F87-349073D65BE4" \
  -derivedDataPath /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/DerivedData \
  -resultBundlePath /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/UniverseKeyboardTests.xcresult \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test

xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug \
  -destination "platform=iOS Simulator,id=D3C353BE-3AA6-499B-8F87-349073D65BE4" \
  -derivedDataPath /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/DerivedData \
  -resultBundlePath /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/RimeSyncKeychain.xcresult \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
  -only-testing:UniverseKeyboardTests/RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem test

xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Release \
  -destination "platform=iOS Simulator,id=D3C353BE-3AA6-499B-8F87-349073D65BE4" \
  -derivedDataPath /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/DerivedData \
  -resultBundlePath /private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/r2/UniverseKeyboardRelease.xcresult \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
```

For formatting, the r2 source fix was formatted with `xcrun swift-format format --in-place --configuration .swift-format "Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift"`; its raw log is `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425/Logs/actor-isolation-fix-format.log`, SHA-256 `53da5082693d8d80b63f86c4cd559876f716bd6c6d29d79b2ee0c0bad9d3134e`. The final strict lint command covered all seven changed Swift files and returned exit 0; its [raw lint receipt](keyboard-wake-diagnostic-v3-compatibility-gate-001-swift-format-lint-2026-09-29.log) has SHA-256 `a2df4fc4322b02db0cc690119989d28505c7a8bec2f3ba8c0071e00b0659ede0`. The pinned RIME verification returned exit 0 and confirmed structural inventory of 12 framework artifacts; see the [RIME verification receipt](keyboard-wake-diagnostic-v3-compatibility-gate-001-rime-vendor-verify-2026-09-29.log). `git diff --check` returned exit 0 after the final matrix. The seven source/test file identities were re-read and matched manifest r2.

## Failure and rerun history

1. The first App + Keyboard Debug attempt used manifest r1 and failed Swift 6 compilation at three calls to actor-isolated `V1DiagnosticsLogSource.merging`; XCTest did not run. The failure and disposition are preserved in the [run-1 receipt](keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-run1-compilation-failure-2026-09-29.md).
2. The bounded source fix makes the pure `Sendable` completeness-merging helper `nonisolated`. This is the only manifest r1 → r2 source change. The fix was formatted, strict-linted, and then the entire required matrix was run on manifest r2. No r1 test/build result is reused for the final candidate.
3. Initial host sandbox attempts to run SwiftPM stopped during package-manifest sandbox setup before tests began. The successful command redirected all package cache/build paths into this task's `/private/tmp` directory and ran through the approved external-command lane. This was an execution-permission constraint, not a test failure.

## Scope and claims

- No production wake-marker emission was enabled.
- No standalone Main App install/launch or manual Maps reproduction was performed. The automated test runners performed their required simulator test setup on the reserved simulator.
- These results validate the exact local compatibility candidate and its build/test matrix. They do not diagnose the keyboard-wake runtime failure, establish a root cause, prove recovery behavior, or claim a Product/Quality Gate or Release.
- The parent `KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001` remains Active. The Stage B handoff is the manifest r2 candidate, this validation record, the raw results above, and exact-candidate Architecture/Quality review.
