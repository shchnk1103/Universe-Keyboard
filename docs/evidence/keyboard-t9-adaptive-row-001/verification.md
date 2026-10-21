# KEYBOARD-T9-ADAPTIVE-ROW-001 — local implementation evidence

> Historical adaptive candidate5cc4a74 evidence. Current Sticky policy and fresh checks supersede per-composition collapse claims below: [Sticky correction](sticky-verification.md). Original log/manifests remain preserved.

Baseline `096183ca118cc40ffc16854d1a5336a42cfcbd89`; Writer `codex-t9-adaptive-row`; branch `codex/keyboard-t9-adaptive-row-001`; worktree `t9-adaptive-row-001`. Implementation complete, Runtime validation pending. No independent review, Product Gate, product push/PR/merge/TestFlight. UI-1 PR216 is not included.

## Implementation and boundaries

Five UIKit files: T9PinyinPathBarView plus Controller T9PinyinPath/Layout/Presentation/T9InputRecovery. Visibility is derived from the existing coherent snapshot and current composition/Partial Commit/Recovery signals, not candidates or Path emptiness alone. All signals idle collapses0pt; active or uncertain composition and blocked Recovery retain34pt. Both atomic and ordinary snapshot entry points apply row visibility with the same root-height request. Same height reuses the one existing750-priority constraint; no timer, RIME change, root refactor or allowsSelfSizing.

The arranged Path row sets its own required height0/34 and matching hidden/AX/hit state; collapsed collection edges use0 instead of−1 to avoid negative required viewport height. Deferred Path scrolling waits for an existing UIKit layout with a nonzero viewport, without a timed delay. Existing Path identity, selected-cell rendering, direct action and 选拼音 plumbing remain. Recovery tail updates visibility after enforcing existing safety controls. No idle hint added.

Candidate container stays48pt (34 visual +14 bridge), top2/bottom0, key45 and spacing8/group10. Only the top Path reservation changes. Candidate/action/Blur/Cell sources, KeyboardCore/RimeBridge and R174 code have no changes. Presentation adds the missing zero custom-spacing after Path in the preexisting expanded-Path rebuild branch; main's expanded candidate overlay architecture is untouched.

One small hostless KeyboardLayoutIntegrationTests target compiles real Keyboard sources with production MainActor/Swift6/bridge/linker settings. Existing targets/isolation remain unchanged. The existing recovery fixture gains only a no-op layout hook; it is not claimed as real Controller evidence.

## Verification

Task-owned Simulator: `5DEEF120-CB85-47BB-A690-303613DD85EC`, iPhone17Pro/iOS26.5. No shared device reset/deletion, GUI retries or real Extension activation attempted this round. Dedicated DerivedData `/private/tmp/t9-adaptive-row-001-build`; raw logs/results `/private/tmp/t9-adaptive-row-001-evidence`.

Commands: `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination 'platform=iOS Simulator,id=5DEEF120-CB85-47BB-A690-303613DD85EC' -derivedDataPath /private/tmp/t9-adaptive-row-001-build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`, with distinct result bundles; tests use the only-testing filters below. Exit receipts were written after process return.

| Level/check | Pass / fail / skip | Artifacts under raw root |
|---|---|---|
| L1 real Controller + Path view, final | 4 / 0 / 0 | l1-complete.log/.exit/.xcresult |
| L2 KeyboardTests | 49 / 0 / 0 | l2.log/.exit/.xcresult |
| L2 KeyboardExtensionTests | 35 / 0 / 0 | same l2 run |
| Debug build-for-testing | Pass, exit0 | debug-build-for-testing.log/.exit/.xcresult |
| Changed Swift strict format/lint,7 files | Pass, exit0 | strict-format.log/.exit |
| pbxproj plist and diff whitespace | Pass | local checks |

L1 filters `-only-testing:KeyboardLayoutIntegrationTests`; L2 `-only-testing:KeyboardTests -only-testing:KeyboardExtensionTests`. Debug build-for-testing compiles targets but does not execute App/Bridge/Core suites. L3/full Core/App/Bridge/Release/hosted CI intentionally not run under Human's bounded authorization; no mergeability claim.

L1 covers widths320/390/430, idle→first raw→temporary-empty Path→delete empty→quick retype, unchanged candidate/key objects and constraint identity, raw/preedit/source/confirmed/prefix/provisional signals, candidate-only idle, snapshot-driven heights, selected Path Cell and direct selector delivery,0-height AX/hit suppression, waiting/terminal R174 recovery and failed Partial Commit disable/notice, page/layout/readiness switches and active layout reconstruction, expanded overlay across row changes and collapse restore. State fixtures are presentation inputs, not real RIME/input-loss behavioral proof. Controller loadView/setupRootStack/reloadKeyboard/layout run production code; bootstrap is omitted to prevent session/deployment side effects. Standalone production Path view uses UIWindow to materialize Cells; no actual Extension or system event delivery is implied.

At width390 (root input-view coordinates; not screen coordinates):

| Geometry | idle | composing |
|---|---|---|
| UIInputView target height | 256 | 290 |
| rootStack frame | (7,2,376,254) | (7,2,376,288) |
| Path frame in stack | (0,0,376,0) | (0,0,376,34) |
| Candidate container | (7,2,376,48) | (7,36,376,48) |
| First function/key | (7,50,69.667,45) | (7,84,69.667,45) |
| Bottom space | (158,211,145,45) | (158,245,145,45) |

Root-local candidate/key y coordinates change34pt together; their offsets from root bottom and from each other remain identical, and key sizes remain identical. The test explicitly gives UIInputView the requested height; it proves internal geometry when the request is honored, not system acceptance or absolute screen stability.

Final L1/L2 logs contain no `Unable to simultaneously satisfy constraints` / required-constraint conflict diagnostic. Key-frame assertions pass; no unexplained Auto Layout conflict. Hostless `needsInputModeSwitchKey` warnings explicitly note no host connection; SDK invalidDigitCount and no-AppIntents metadata warnings are environmental/build-tool residuals, not Swift warnings-as-errors failures.

## Failed trials retained

Initial L1 was3/0/0. Additional Path Cell test failed in l1-final, l1-reveal and l1-viewport (each3 passed/1 failed). A temporary FlowLayout-size invalidation experiment did not fix it and is absent from final source. path-diagnostic.log proves viewport376×33 and delegate item44×33, but without UIWindow cached attributes were0×0; attaching a window created one visible Cell/content52×33. Attaching the Controller also triggered real host lifecycle/rebuild, so subsequent assertions referenced a detached old row (two failures). This was corrected by keeping Controller geometry hostless and attaching only the standalone production Path view. No assertion was removed: selected Cell, direct selector, collapse hit suppression and restore remain verified. l1-window-corrected4/0/0; final l1-complete4/0/0 adds the explicit waiting/terminal Recovery, readiness/rebuild and expanded-transition cases. No product constraint/input failure is inferred from those test-boundary failures. Raw failed logs, results and exit65 receipts remain preserved.

## Remaining review and Human Gate

Ready for independent Claude review as a local implementation candidate, not Architecture/Quality Pass. Real activated Extension: not verified. Actual host acceptance/timing of0/34 root changes, screen coordinates, first appearance/return, fast native delete/retype/selection, live RIME temporary paths/Recovery, system touches/VoiceOver and flicker need Human Simulator/device evidence. UI-1 integration/rebaseline46pt is separately authorized future work. No TestFlight admission follows from these tests.

Source and protected-boundary digests plus raw log hashes are adjacent JSON files. Task carrier remotely contains initial KOS docs only; local product/checkpoint descendants must not be pushed. Writer remains codex-t9-adaptive-row, P=none; review does not transfer Writer. Stop for Human.
