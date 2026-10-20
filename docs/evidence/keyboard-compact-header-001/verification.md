# KEYBOARD-COMPACT-HEADER-001 — UI-1 local candidate

Baseline: actual remote main `096183ca118cc40ffc16854d1a5336a42cfcbd89` (#213/#214/#215), verified 2026-10-20. Writer `codex-compact-header`; branch `codex/keyboard-compact-header-001`; managed worktree `compact-header-001`. No independent review or Gate result.

## Delivered and protected

- Local `Keyboard/Views/KeyboardDesignTokens.swift`: CandidateBar / T9PinyinBar / CandidateActionAppearance. Compact total and normal Cell share 46pt; action zone 56 × 46pt; medium symbol 22pt. No 48pt fallback needed in UIKit checks.
- Viewport clips; its right edge equals the action zone left edge, with no duplicate 56pt content inset. Only the header extends beyond unchanged 7pt key margins; parent hit routing admits that extension.
- Persistent material view, semantic tint, internal 8pt transition, opaque Reduce Transparency fallback. Recovery hides action layers; expanded transitions hide the root rather than fading a material ancestor. Expanded Cell height and candidate fonts unchanged.
- No changes to Packages/KeyboardCore, Packages/RimeBridge, Bootstrap/R174 gates, candidate selection/authority/paging rules or recovery adapter. [Source hashes](candidate-files.json).
- UI-2 prototype withdrawn. Original fixed 34pt T9 reservation, root-height priority, key size/spacing and T9 presentation remain.

## Checks

Task-owned device: `5F983B43-FAAC-46ED-B2B0-33E0E30F099F`, CompactHeader-001 iPhone 17 Pro, iOS 27.0 (24A434). Existing devices/workspaces were not reset/erased/terminated/cleaned. Output roots: `/private/tmp/kch001-build`, `/private/tmp/kch001-release`, `/private/tmp/kch001-runtime-build`. Raw evidence: `/private/tmp/kch001-evidence`.

xcodebuild used explicit device ID, Swift 6 complete strict concurrency, warnings visible/as-errors and task-specific DerivedData. Final app tests/Debug/Release use CODE_SIGNING_ALLOWED=NO. Runtime trials alone used ad-hoc signing.

| Check | Result | Raw artifact under evidence root |
|---|---|---|
| `swift test --package-path Packages/KeyboardCore` | 1277 passed / 0 failed / 0 skipped | core-tests.log |
| Universe Keyboard Debug `test` | App 407 passed / 0 failed / 10 skipped; Keyboard 49/0/0; Extension 40/0/0 | final-app-tests-r2.log + xcresult |
| Final KeyboardExtensionTests, test-only snapshot correction | 40/0/0 | final-ui-snapshots.log + xcresult |
| Debug `build-for-testing` | Pass | final-debug-build-for-testing.log |
| Release `build` | Pass | final-release-build.log |
| Changed Swift format then strict lint | Pass; final formatting changed no bytes | strict-format.log |
| pbxproj plist / diff whitespace | Pass | final local checks |

Ten App skips: source archive fixtures (2), coexistence extract trees (3), fingerprint default.yaml fixture (1), physical-device TD-012 (3), unsigned-host Keychain (1). Signed Keychain integration and RimeBridgeTests were not rerun in this UI-only local slice; no full merge-gate claim.

Real production UIKit objects at widths 320/390/430 verify 46pt geometry, disjoint button/viewport edge hits, clipping, scroll-to-final-item/padding, label bounds under content-size traits, independent 42pt expanded Cell, effect identity, light/dark traits, opaque accessibility fallback and notification refresh, recovery hide/disable/restore. Existing paging-consumer/recovery-adapter suites pass. Accessibility preference injection tests material policy, not an actual OS settings toggle.

Final light/dark offscreen layer captures in `final-offscreen-attachments/` were visually inspected: readable text/highlight and contrasting fills, no observed vertical clipping. They do not prove live backdrop blur, VoiceOver navigation, system gesture delivery, actual paging/preload timing, performance or physical-device behavior. Earlier `final-attachments/` drawHierarchy captures are black/unusable and rejected; earlier detached-view images did not establish dark appearance. Initial UIKit test compile errors and the accidental swift-format invocation on pbxproj are preserved in raw logs; corrected final checks pass.

## UI-2 trial and stop

The experimental real UIView 0/34pt hide/restore/selection/recovery test passed (ui2-view-tests: 40/0/0). It is not system-host proof and is absent from final candidate.

The ad-hoc Main App deployed resources and enabled nine-key through normal installer/readiness flow, without fabricated readiness. Runtime entry XCTest passed. Subsequent harness trials first hit a re-presented welcome sheet covering Search (corrected). The final field then showed Apple's `UIKeyboardLayoutStar Preview`, not Universe. A `Next keyboard` control existed; a subsequent system switcher trial could not find a selectable `Universe Keyboard` menu entry. `runtime-t9*.log/xcresult` preserve failed assertions and AX trees. No key/candidate screen-coordinate assertion executed. No host dynamic-height acceptance/rejection, input regression or 0–2pt stability conclusion is drawn.

Per authorized fallback, save `ui2-deferred/experiment.patch` and experimental Swift tests, then restore/remove only task-owned UI-2 changes. Final T9 Path/height-priority changes are absent; no new height framework or reliability edit.

## Review and next decision

UI-1 source/local machine evidence can enter independent Architecture/Quality review with explicit real-Extension/interaction/visual gaps. No independent Gate Pass, complete Product acceptance or mergeability. Human assigns reviewers or the next bounded runtime step; UI-2 needs a working real Extension entry or Human device evidence before resumption. Only initial four-doc carrier initialization was pushed; no product push/PR/merge/TestFlight. Final product/records stay local.

[Raw log hashes](raw-log-hashes.json). Raw bundles are transient local artifacts; preserve/export before moving hosts. UI_STYLE_GUIDE, KEYBOARD_LAYOUT and CHANGELOG are updated; no Core contract/ADR change is needed for UI-1.


## A1/A3 targeted correction — 2026-10-20

Human relayed Claude Architecture/Quality Partial and reopened only the bounded A1/A3 slice.
Same Writer/worktree/carrier; no product publication or handoff. UI-2 stays withdrawn, fixed34pt.

A1 was **not reproduced as a UIKit unsatisfiable-constraint diagnostic**: historical logs and this
round's real Controller logs contain no `Unable to simultaneously satisfy constraints` diagnostic.
The initial test checker incorrectly treated private solver-spacer/layout-guide frames and intrinsic
hugging/resistance wrappers as rendered required equalities; those failures are not conflict proof.
Generated `UISV-canvas-connection` descriptions in the diagnostic dump are constraints, not warnings.
To remove the structural concern, root alignment is restored to fill. Its ordinary CandidateBarRowView
obeys the unchanged 7pt key margins; the nested bar alone anchors to the full surface. No priorities
were lowered. Pinyin expanded-view filtering follows the row wrapper; no Core or path state changed.

Real KeyboardViewController/loadView/setupRootStack/reloadKeyboard/reloadKeyboardContent run in the
new hostless KeyboardLayoutIntegrationTests target, compiling production Keyboard sources with their
production actor isolation. The existing test targets retain their isolation/source membership.
Widths320/390/430 × QWERTY/T9 verify surface-aligned46pt bar, x=W−1 action hit, first-key edge hits,
45pt key height, unchanged key frames across reloads, Recovery blocking, and required equations between
rendered public UIViews. Private solver proxy/guide frames are not observable constraint evidence.
No new UIKit constraint-conflict diagnostic occurred. This is in-process UIKit, **not activated Extension**.

A3: presented overlay spans the surface and starts at compact bar.top; collapse shares56×46pt tokens,
22pt symbol and exact bounds-only hits. First-row reservation clears the46pt action before the next
row; candidate Cells remain42pt. Test verifies identical action frames, targets/labels, expand/collapse
restoration and scroll-to-last with80 candidates. In T9, the old34pt path area remains above the panel
(root hidden during expansion); no dynamic row or root-height change. The original panel scroll-overlay
architecture and animations are retained; live scrolling/gesture/VoiceOver still need host evidence.
Unused collapsedHeight token removed. Short L1/L2/L3 guidance added; CI full gate is unchanged.

| Current check | Passed / failed / skipped | Local artifact under `/private/tmp/kch001-corrections` |
|---|---|---|
| L1: real Controller integration (2), compact (5), recovery view (4), recovery adapter (6), idle-dismiss (1) | 18 / 0 / 0 | l1-final-r3.log + xcresult |
| L2 KeyboardTests | 49 / 0 / 0 | l2-keyboard.log + xcresult |
| L2 KeyboardExtensionTests | 40 / 0 / 0 | l2-keyboard.log + xcresult |
| Debug build-for-testing | Pass | debug-build-for-testing.log + xcresult |
| Changed Swift strict lint (6 files), plist and diff whitespace | Pass | strict-format.log; local checks |

Commands use the same task-owned simulator5F983B43-FAAC-46ED-B2B0-33E0E30F099F and
/private/tmp/kch001-build, Debug, CODE_SIGNING_ALLOWED=NO, Swift6 complete concurrency,
SWIFT_SUPPRESS_WARNINGS=NO and SWIFT_TREAT_WARNINGS_AS_ERRORS=YES. No other device reset/cleanup.
All failed attempts are preserved: a1-before/r2 were test-target actor-isolation wiring failures;
r3/r4 exposed the invalid private-frame checker; l1-layout used the wrong surface subtree for panel
hits; l1-final used UIApplication dispatch absent from hostless XCTest; l1-final-r2 checked restoration
before UIKit animation completion. Final tests verify the target registration, invoke the target, and
await the existing0.16s transition completion (250ms), without changing production animation behavior.
No unexplained/flaky product failure was hidden by retry; no new test was skipped.

Prior Core1277/0/0 and App407/0/10 at the original UI-1 snapshot are reused only for unchanged
Core/App behavior; they do not prove this changed layout. Prior Release build is historical, not a new
Release check. No full Core/App/RimeBridge rerun under Human risk selection; no prior RimeBridge run
is claimed. Actual Extension screen coordinates, live backdrop/VoiceOver and system touch delivery
remain unverified. A2/A4/A6 and UI-2 are deferred. Ready for Claude targeted re-review, not Gate Pass.
Source/log digests: correction-evidence.json. Original snapshot manifests remain intact.
