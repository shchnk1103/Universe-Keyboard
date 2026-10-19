# INPUT-RELIABILITY-DELIVERY-003 — Local candidate verification

Historical verification receipt for product `286d3e91c0cc0e94d1d439c10d799948abcb9a1f`; later publication authority/status is owned by the Assignment and task log.

Date: 2026-10-19 Asia/Shanghai. Executor / Writer: current Codex session, lane `codex-batch3`. Independent reviewer assigned: Claude; not run by this lane. This is not independent Quality, Product acceptance, merge readiness or Release.

## Identity and scope

- Actual fetched baseline: `d08175b915aee40998398d7fdc03f2fd7cf0833f`; includes Batch 1 `bb430f914deaf7b19a61183f744b5dcf2fdb8eae` and Batch 2 `d08175b915aee40998398d7fdc03f2fd7cf0833f`.
- New worktree: the isolated task carrier checkout.
- Carrier: `codex/input-reliability-delivery-003`. Remote synchronized docs-only initialization ends at `582a5a54267e6f5813626f1ef48ce53d4e992137`; no product ancestor is pushed.
- Read-only extraction source: original Codex worktree at `eedbee993f8d89cd283c1487356f27f66c5e044a` plus uncommitted files. No original/main/Grok checkout or backup was written.
- Extraction: bounded T9 short-delete history; affine post-delete continuous digits/ledger; R174 bounded policy/controller integration; failed Partial Commit checkpoint recovery; candidate/Path/paging/direct action rejection; UIKit notices, disabled controls and cache invalidation; numeric 26-key finalization compatibility, no internal T9 digits to host.
- No production Bridge, deploy lifecycle or owner implementation changes. No R345/R349, Build94 or C/D work.

## Adaptations and safety

1. Shared files were patched by hunk. The old source would remove Batch 2's origin-free authority-engine rejection; that hunk was not extracted. Candidates.swift differs only by four recovery-entry guards. Other Batch 1/2 critical blobs are byte-identical; see `protected-boundaries.json`.
2. The old PartialCommitFailureProtectionTests selected a native candidate without origin, so all six fixture prerequisites failed under merged Batch 2. The fixture now takes the actual published origin and page/global index. No product validation was relaxed; 6/6 then passed.
3. Only recovery presentation refresh was extracted from Presentation.swift. Historical Simulator observation / bootstrap fixtures were excluded. CandidateBar notice uses the aggregate composition recovery message so Partial Commit failures are visible with R174 disabled.
4. Reused UIKit test-source wiring only. Production candidate bar, key class, accessibility, paging and recovery adapter compile into the existing hostless test target against its existing lightweight owner. No new framework or product test switches.
5. Two affine single/burst retype tests and their small bootstrap were extracted. An intermediate extraction accidentally included existing duplicate tests; compilation rejected them and the range was corrected before runtime. Final formatting includes required mechanical formatting of the touched original test file.
6. Normal R174 initial value stays false. Only the pre-existing `DEBUG && targetEnvironment(simulator) && INPUT_RELIABILITY_R174_SIMULATOR_TEST` branch initializes true. No user API, persistence or normal-build/project flag was added.

## Final results

| Check | Result | Coverage / limits |
|---|---|---|
| Swift format then strict lint | Pass, 33 changed/new Swift files | Same .swift-format; no lint bypass |
| KeyboardCore final full package | 1277 Pass / 0 Fail / 0 Skip | `core-serial-final.log`, final formatted content |
| RimeBridge full scheme | 97 Pass / 0 Fail / 20 Skip (117 total) | `rime-full.log`; optional external runtime fixtures absent, skips are not passes |
| UniverseKeyboardTests | 407 Pass / 0 Fail / 10 Skip (417 total) | `app-keyboard.log`; archive fixtures, unsigned Keychain entitlement and physical-device staging prerequisites absent |
| KeyboardTests | 49 Pass / 0 Fail / 0 Skip | Includes normal-build R174 default-off assertion and Batch 1 identity tests |
| KeyboardExtensionTests | 35 Pass / 0 Fail / 0 Skip | 29 directed recovery/paging/key tests plus 6 existing tests |
| Debug build-for-testing | Pass | App, Extension and scheme test bundles; normal flags |
| Release build | Pass | Normal product build, no R174 test condition |
| Explicit R174 Simulator test build + test | Pass, 1/1 | Separate products, existing test flag only; R174 default true assertion actually ran |
| Pinned Kit v0.9.0 structural validation | Pass with advisory warnings | Exact `c98b2813240e22b2ac7fec44b2445321b03f73e0`; no Profile migration or Gate claim |

All Xcode builds use `CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`. Simulator: task-created `Input Reliability Batch 3`, iPhone 17 Pro equivalent on iOS 27.0, `F767AD33-45BA-4693-86FD-D32F325AFF56`. Test execution uses `-parallel-testing-enabled NO`. No shared device reset, cleanup or tests on another Agent's simulator.

Commands (run from the new worktree):

```sh
swift test --package-path Packages/KeyboardCore
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme RimeBridgeTests -configuration Debug -destination 'platform=iOS Simulator,id=F767AD33-45BA-4693-86FD-D32F325AFF56' -derivedDataPath /private/tmp/ird003-derived -resultBundlePath /private/tmp/ird003-evidence/rime-full.xcresult CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES -parallel-testing-enabled NO test
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination 'platform=iOS Simulator,id=F767AD33-45BA-4693-86FD-D32F325AFF56' -derivedDataPath /private/tmp/ird003-app-derived -resultBundlePath /private/tmp/ird003-evidence/debug-build.xcresult CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build-for-testing
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination 'platform=iOS Simulator,id=F767AD33-45BA-4693-86FD-D32F325AFF56' -derivedDataPath /private/tmp/ird003-app-derived -resultBundlePath /private/tmp/ird003-evidence/app-keyboard.xcresult CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES -parallel-testing-enabled NO test-without-building
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Release -destination 'platform=iOS Simulator,id=F767AD33-45BA-4693-86FD-D32F325AFF56' -derivedDataPath /private/tmp/ird003-release-derived -resultBundlePath /private/tmp/ird003-evidence/release-build.xcresult CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
```

The separate R174 run uses the same strict arguments with `/private/tmp/ird003-r174-derived`, `SWIFT_ACTIVE_COMPILATION_CONDITIONS='DEBUG INPUT_RELIABILITY_R174_SIMULATOR_TEST'`, and `-only-testing:KeyboardTests/R174BuildGateTests`: build-for-testing followed by test-without-building. Normal-build test and controlled test both assert the actual controller initial flag, rather than merely scanning text.

Raw logs and xcresult bundles are retained under `/private/tmp/ird003-evidence/`; per-log digests: `logs.json`. Final product/test file hashes: `candidate-files.json`; original extraction-source identities: `extraction.json`; skip diagnostics: `skips.json`. All product Swift was unchanged after successful normal iOS builds/tests; subsequent edits were documentation and required formatting of the Core-only test file, followed by final Core verification.

## UI evidence boundary

- Real UIKit candidate row/cells: geometry at 320/390/430 widths, candidate/expand hit routing during notice and after restore, no out-of-row hidden-chevron hit, gestures disabled/restored, semantic label color in light/dark: 4/4.
- Production recovery adapter: stale cache/prefetch invalidation, candidate/Path dismissal calls, Space/Return/selection disabled/restored, R174-independent checkpoint notice, English/symbol escape and preservation of unrelated disablement: 6/6.
- Production key class + AX configuration: hit refusal and unavailable trait during recovery, restored hit routing and target registration: 3/3.
- Production paging methods: actual reads/consumption routing, stale identity/generation rejection, recovery gate with R174 off, bar/expanded append boundaries: 16/16.
- The hostless owner records panel callbacks/selectors. This does NOT prove UIApplication event delivery, actual Extension activation, system keyboard candidate commit/expanded-panel flow, physical-device behavior or live native R174 restore. These remain explicit review/PR evidence gaps; no fake is labeled native.

## Preserved failed attempt and residuals

Final formatted full Core attempt `core-formatted-final.log` failed once in unchanged `DiagnosticsJournalIngressTests.testQueueFullCanDropQueryMeasurementWithoutChangingItsMeaning`: read 0 events vs expected 256. Test and implementation match baseline. The helper waits for directory existence, not completed writing; a timing race is plausible, not a proven root cause. No out-of-scope edit was made. One isolated rerun passed 1/1, then the single no-parallel-build full rerun passed 1277/1277. Preserve the failed run and report the observed instability to Claude; no universal flake resolution claimed.

PR-frontier requirements: Claude independent Architecture/Quality review; explicit disposition or completion of the 30 skipped environment-dependent cases as applicable, native T9/R174 and full Extension/system-event evidence gaps, and the observed unrelated timing failure; later product push/hosted-CI/PR authority. This local candidate is reviewable, not declared mergeable. No Closeout, product push, PR, merge, TestFlight, branch/worktree deletion or backup cleanup occurred.
