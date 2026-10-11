# Paired Rollout v5 Compatibility Stage — Validation Record

## Identity

- Assignment: [KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001](../assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md)
- Stage authorization: v5 compatibility candidate validation (`../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v5-stage-authorization-2026-09-30.md`), SHA-256 `7204731eb1af58ab428b56235e0602aeff86373f395fbf9e7681bb5cf0576375`
- Entry receipt: v5 stage Entry (`keyboard-wake-diagnostic-extension-paired-rollout-001-v5-stage-entry-2026-09-30.md`), SHA-256 `d0f5092e458778ec0e1eac387edcdf3dd9f8e9bc7dc6d9983e9fce9228727842`
- Worktree / branch: `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard` / `codex/keyboard-wake-v3-compatibility-gate`
- Base commit: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Candidate source/test manifest r2: [manifest](keyboard-wake-diagnostic-v3-compatibility-gate-001-source-test-manifest-2026-09-29-r2.json), SHA-256 `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- Candidate contract: reader accepts v3/v4/v5; production writer remains v5; production wake-marker emission remains off.
- Validation artifact index: `/private/tmp/ukey-wake-v5-20260930.nBWReN/validation-artifacts.json`, SHA-256 `80147fb5288926695569dc33f411e1e6687e1212b4a22b7ee728e7d0621151c2`
- Recursive `.xcresult` file manifest: `/private/tmp/ukey-wake-v5-20260930.nBWReN/xcresult-bundle-hashes.json`, SHA-256 `8c429cc52f0b1c020454b8646c53c6c169b2286b4dfc0fd53f8a916507ede138`; each result bundle's files and aggregate tree digest are recorded there.

This identity binds only the seven source/test paths in manifest r2. It does not claim that the larger worktree is clean or that all dirty documentation in the worktree belongs to this stage.

## Environment

- Simulator: iPhone 18 Pro / iOS 27.0, UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`, runtime build `24A434`.
- The exact Simulator was confirmed exclusively available for the stage and was observed Booted before and after the test matrix. Simulator-backed work used the task-specific non-persistent XcodeBuildMCP profile and separate DerivedData at `/private/tmp/ukey-wake-v5-20260930.nBWReN/DerivedData`.
- Toolchain: Xcode 27.0 (build `27A266a`), Swift driver 1.168.6 / Swift 6.4.0.34.1, `swift-format` version `main`. Xcode builds used Swift 6.0 language mode, complete strict concurrency, and warnings-as-errors.
- RIME vendor verification: `bash scripts/ensure_rime_vendor.sh verify` passed for 12 framework artifacts; vendor version `rime-vendor-ios-1.16.1-lua.1-octagram.1`, pinned SHA-256 `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`. Raw output: `/private/tmp/ukey-wake-v5-20260930.nBWReN/rime-vendor-verify.log`.

## Evidence matrix

| Check | Result | Evidence |
|---|---|---|
| Swift format and strict lint for all seven manifest Swift files | Passed; format made no content changes and all seven hashes remained equal to manifest r2 | `/private/tmp/ukey-wake-v5-20260930.nBWReN/swift-format.log` |
| `swift test --package-path Packages/KeyboardCore` | 1,177 passed, 0 failures | `/private/tmp/ukey-wake-v5-20260930.nBWReN/KeyboardCore.log` |
| `RimeBridgeTests`, Debug, exact Simulator, CI Swift settings | 105 total: 85 passed, 20 skipped, 0 failed | `/private/tmp/ukey-wake-v5-20260930.nBWReN/RimeBridgeTests.xcresult`; raw log `/private/tmp/ukey-wake-v5-20260930.nBWReN/RimeBridgeTests.log`; recursive bundle manifest above |
| `Universe Keyboard` App + Keyboard tests, Debug, exact Simulator, CI Swift settings | `.xcresult`: 428 total, 418 passed, 10 skipped, 0 failed. Raw suite totals: 412 `UniverseKeyboardTests` + 16 `KeyboardTests`, 0 failures | `/private/tmp/ukey-wake-v5-20260930.nBWReN/UniverseKeyboardTests.xcresult`; raw log `/private/tmp/ukey-wake-v5-20260930.nBWReN/UniverseKeyboardTests.log`; recursive bundle manifest above |
| Signed Keychain persistence integration test, exact Simulator | 1 passed, 0 skipped, 0 failed: `UniverseKeyboardTests/RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem` | `/private/tmp/ukey-wake-v5-20260930.nBWReN/RimeSyncKeychain.xcresult`; raw log `/private/tmp/ukey-wake-v5-20260930.nBWReN/RimeSyncKeychain.log`; recursive bundle manifest above |
| `Universe Keyboard` Release build, exact Simulator destination | Succeeded; 0 errors, 0 warnings. Build only; no app launch | `/private/tmp/ukey-wake-v5-20260930.nBWReN/UniverseKeyboardRelease.xcresult`; raw log `/private/tmp/ukey-wake-v5-20260930.nBWReN/UniverseKeyboardRelease.log`; recursive bundle manifest above |
| RIME pinned vendor verification | Passed, 12 framework artifacts verified | `/private/tmp/ukey-wake-v5-20260930.nBWReN/rime-vendor-verify.log` |
| `git diff --check` | Passed, exit 0 | `/private/tmp/ukey-wake-v5-20260930.nBWReN/git-diff-check.log` |
| Documentation handoff links and whitespace | Passed; 941 Markdown links checked across 8 scoped records, with no missing local targets or trailing whitespace | `/private/tmp/ukey-wake-v5-20260930.nBWReN/documentation-links.log` |

The XcodeBuildMCP `test_sim` response announced 429 discovered tests for the `Universe Keyboard` run. The `.xcresult` summary reports 428 total and the raw xcodebuild log reports 412 + 16 = 428. No failing test is reported, but the one-test discovery/count discrepancy has no established explanation and is explicitly handed to Quality review.

## Skips and coverage limits

The 20 `RimeBridgeTests` skips were conditional real-engine/Lua checks: 2 Lua smoke tests lacked their runtime fixtures; 1 frozen paired matrix lacked its immutable S4 commit identity; 9 T9 runtime-matrix tests lacked isolated runtime directories; 1 T9 compatibility Spike lacked its runtime directories; 6 T9 pinyin-selection Spike tests lacked their runtime directories; and 1 R4-B real-engine proof lacked its runtime directories. The raw log records each reason.

The 10 App + Keyboard skips were: 2 pinned Ice archive-source checks without the independently downloaded archives; 3 installer-coexistence checks without fixed Wanxiang/Ice extract trees; 1 Ice recovery check without the pinned `default.yaml` fixture; 1 unsigned host Keychain test (the separate signed Simulator integration test passed); and 3 TD-012 physical-device-only checks. The raw log records each reason.

These conditional tests remain unverified by this run. Passing host and Simulator suites does not claim real-device behavior, Lua smoke success, manual keyboard operation, or a root-cause finding.

## Candidate identity after validation

The seven in-scope source/test files were rehashed after formatting and all validation. Every digest still matches the manifest r2 values listed below; no source/test edit or candidate identity change occurred during this stage.

| Path | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` | `346efd59225cdf71fc61917fcb26bc72f3b1cf84aea19d873b3f238e791b492b` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` | `49077a7a6ade1b41724fda92314cb4a41071163dc9f6c5e2a8666ee38273dbc9` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift` | `965667328c2db1cba4c4f99e21a82ee13ae3890ff18bf510b9967c5396273534` |
| `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift` | `bc874c7f019645e18c04b8b2c3a9d21c8247afc75b44cc8951a857078d558a70` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` | `7da854233e4454ccd44c587acca5cf8b4d4b89b15c726277748fa172da1e7c53` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` | `8760b930ff9f1045f8689f73c2dddb33bf199b86d7246cc6dd6e50feb2af1ba5` |
| `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift` | `ad24cef7d5512b621a53724b3b1043b29a5b1863ef163aa8de0e25b6e2fa855c` |

## Disposition

The authorized v5 validation matrix is complete with no reported test failures, and independent Architecture and Quality evidence review is pending. Keep the Assignment **Active** until those reviews and remaining Assignment handoffs are resolved. This record is not a Product Gate, Quality Gate, Release decision, v6 authorization, installation approval, Maps reproduction, keyboard behavior result, or root-cause conclusion. The parent diagnostic Assignment remains Active with root cause unresolved.

No Extension source, v6 implementation, App installation/launch, Simulator UI interaction, Maps reproduction, commit, push, PR, merge, changelog, or release document was performed as part of this validation stage.
