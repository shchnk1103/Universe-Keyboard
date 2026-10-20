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


## N2 layout / N1 evidence reconciliation — 2026-10-20

Human relayed Claude second-review Architecture Pass / Quality Pass (A1/A3 blockers removed), then
reopened only N2/N1 and focused validation. Same Writer/branch/worktree; no HANDOFF/ACCEPT.

N2: the presented panel and collection now start at keyboardSurfaceView.top, with an opaque semantic
background across the entire panel. The collapse action has a separate required top constraint to the
compact candidate bar; its56×46pt frame and22pt symbol remain aligned in both layouts. Top rows whose
42pt Cells intersect the action's vertical band reserve its trailing width, including both top rows
in T9. Collection starts at y=0 (first Cell y=3), reclaiming the old34pt region for candidate content.
No constraint priority lowered; compact46pt, fixed T9 path34pt, keys, root-height policy, recovery/input
logic and animations unchanged. N3/A4/UI-2 remain deferred.

Focused current run: **12 passed / 0 failed / 0 skipped**, xcodebuild exit0. Real Controller integration2
includes widths320/390/430 × QWERTY, T9 idle, T9 path-presentation fixture: top coverage/background
geometry, identical action frames, no Cell/action overlap,42pt Cells, scroll-to-last of80 candidates,
restored key/action frames and Recovery-notice hits after collapse. Existing recovery view4 and
recovery adapter6 also passed. Path fixture uses real Path Bar.setPaths; it is not live engine path
issuance/selection evidence. Adapter tests retain their existing test boundary; not live host proof.
No `Unable to simultaneously satisfy constraints` diagnostic in the completed run; rendered-view
required-equation assertions pass. Only geometric/background configuration correctness is established,
not final pixel compositing, transparency, animation appearance or system touch/VoiceOver delivery.

Command: Universe Keyboard scheme Debug test, task-owned simulator5F983B43-FAAC-46ED-B2B0-33E0E30F099F,
/private/tmp/kch001-build, only KeyboardLayoutIntegrationTests, CandidateBarRecoveryViewTests and
T9RecoveryPresentationAdapterTests, CODE_SIGNING_ALLOWED=NO, Swift6/complete concurrency,
SWIFT_SUPPRESS_WARNINGS=NO and SWIFT_TREAT_WARNINGS_AS_ERRORS=YES. The test command compiled production
Keyboard and integration sources successfully. Changed Swift2 files format + strict lint exit0.
No separate build, L2/L3, full Core/App/Bridge/Keyboard suite or Release rerun needed for this bounded
slice. Raw completed artifacts: /private/tmp/kch001-final/n2-focused.log + .xcresult + .exit;
strict-format.log + strict-format.exit. Exit receipts were written only after each command returned.

N1 read-only reconciliation: all requested files exist. Old recorded digests match exact byte prefixes
of current files, so the recorded original snapshots remain independently verifiable. Current file
hashes/byte sizes/UTC mtimes and old digests are in correction-evidence.json, separated into successful
and historical-failure sections. No raw log, timestamp or failed outcome was edited, regenerated or
deleted. The appended suffixes contain xcodebuild simulator diagnostic-collection timeout after600s,
then final TEST FAILED; the prior manifest was captured before those processes finished writing.
This conclusion is supported by exact prefix hashes and timestamped process suffixes, not mtime alone.

| Historical failed log | Preserved old-prefix bytes | Current total bytes | Current mtime (Asia/Shanghai) |
|---|---:|---:|---|
| a1-before-r3 | 1217424 | 1359045 | 2026-10-20 12:10:25.663007 +08:00 |
| a1-before-r4 | 167531 | 183657 | 2026-10-20 12:11:56.014243 +08:00 |
| l1-layout | 166438 | 167273 | 2026-10-20 12:15:29.885702 +08:00 |

The same manifest audit additionally found historical failure l1-final-r2 with the same exact-prefix
and600s timeout suffix pattern (old-prefix126226 bytes/current127063); recorded alongside the three,
not silently retained with a stale hash. All successful test/build log hashes still match the prior
manifest. These historical assertion failures plus diagnostic timeouts remain failures.

Historical strict-format.log is0 bytes. The retained execution command used strict lint && L2 test,
and the downstream L2 run is recorded, supporting lint exit0; the empty file alone does not prove it.
This round's independent lint exit0 receipt resolves the current-format evidence boundary explicitly.
Prior Release/Core/App evidence remains historical/unchanged-module context only. No live Extension
screen-coordinate, color-compositing or interaction acceptance is claimed. Ready for Claude final diff
review; stop for Human, no product push/PR/merge/release.


## V1–V6 real-iPhone feedback: bounded local visual polish — 2026-10-20

Entry: clean branch/head ddcd81cec41720b5ea1490936e693500fa8cf875, same Writer codex-compact-header,
P=none. Remote Carrier/PR216 still at that head. Human reports six interaction checks passed on real
iPhone before this slice. These are Human observations, not this lane's new device validation. New
permission is local changes/tests/commit/checkpoint only; previous Push authority is not reused.
UI-2 PR217/worktree, core/session/authority/epoch/recovery/sticky-expansion logic were untouched.

| Item | Confirmed local cause / observation | Bounded action |
|---|---|---|
| V1 | With target height, QWERTY surface y0; root/row/viewport y2; fixed46pt header; first key y48; target254pt, safe area0 in hostless fixture | No height/key changes: no extra placeholder beyond original2pt inset and required46pt found. Device host-container contribution remains unmeasured; screenshot was not supplied to this run |
| V2 | Idle hid material but retained35% tint; Reduce Transparency made idle tint opaque | Hide material and tint in idle/recovery, retain56×46pt action and dual-mode semantics; expandable mode keeps existing material/opaque fallback |
| V3 | Compact uses custom/unconfigured button; collapse used Configuration.plain and separate chevron.up glyph | Both now use custom rendering and same22pt-medium chevron.down image, collapse rotated pi. Same56×46 frame, symbol image bytes and UIImageView bounds verified; no transform on button frame |
| V4 | N2 placed collection at surface top while action stayed at header; hiding entire root removed original paths | Panel/collection begin at original header top, first Cell retains3pt section padding. Keep real fixed34pt path above visible/interactable; hide only covered compact header, opaque panel intercepts underlying keys. Save/restore covered rows' accessibilityElementsHidden; path row untouched |
| V5 | Surface relies on iOS container outline, own cornerRadius0; sibling overlay had no clipping | Clip only panel's top two corners with existing keyboardSurfaceMaskCornerRadius34/continuous; no root/bottom mask. Hidden compact header prevents its text showing through rounded cutouts. Actual host-radius visual match requires iPhone review |
| V6 | Source has one decorative action gradient composited over flat tint plus material, not two separate shadow layers; no collection trailing gradient in CandidateScrollViewStyle | Remove redundant gradient and now-unused edge/idle tokens. Disjoint clipped viewport already prevents text under action; no fade needed in idle or over actionable candidate text |

V1 measurements at widths320/390/430: surface=(0,0,W,254), root=(7,2,W−14,252), candidate row=
(7,2,W−14,46), actual bar=(0,2,W,46), viewport=(0,2,W−56,46), first-key top48. These are actual
production Controller UIKit fixture frames at its requested height, not real-iPhone screen coordinates.
No rule deleting the fixed candidate row or overriding host height has been introduced.

Tests use same task-owned simulator5F983B43-FAAC-46ED-B2B0-33E0E30F099F and /private/tmp/kch001-build,
Universe Keyboard scheme Debug test, Swift6 complete concurrency, CODE_SIGNING_ALLOWED=NO,
SWIFT_SUPPRESS_WARNINGS=NO, SWIFT_TREAT_WARNINGS_AS_ERRORS=YES. Only selected targets are run.

- L1:20/0/0 (Controller3 + compact6 + recovery4 + adapter6 + idle1). Width320/390/430,
  QWERTY and T9 idle/path fixtures, expanded/restored geometry, path hit route, first/last candidate,
  clipped viewport/action hits, material/light/dark/reduce-transparency policy and Recovery.
- L2 KeyboardTests49/0/0 and KeyboardExtensionTests41/0/0. Combined l2 command exit65 because the
  strengthened Controller glyph-size test used exact equality after pi rotation: observed widths
  24.666666666666668 vs24.666666666666664, heights15 vs15.000000000000004. Nine assertions failed;
  all failed records remain failed. Fixed only that test to0.001pt tolerance, far below one pixel.
- Controller integration then3/0/0; final added covered-accessibility save/restore verified3/0/0.
  Final file checks include actual rendered UIImageView sizes, matching shared images and custom
  config, both light/dark traits, panel top-only clipping, visible original path hit and no key hit
  through panel, same keys/action frames after collapse. No repeated whole-module rerun: module
  evidence reused; final production panel changes compiled/executed in actual Controller target.
- Changed Swift5 files strict format exit0; xcodebuild test includes Debug production/test compilation.
  No separate redundant build-for-testing, full Core/App/Bridge, Release or L3 CI run in this slice.
- No Unable-to-simultaneously-satisfy-constraints/UISV-canvas warning in local logs; rendered required
  equations remain satisfied. Hostless keyboard connection/screen warnings are not real-host proof.

Raw completed runs/exit receipts: /private/tmp/kch001-visual/{l1,l2,integration-final,
integration-accessibility}.{log,exit,xcresult}; final format-delivery.log/.exit. Checksums and source
identity: visual-polish-evidence.json. No hashes were captured before their command exit receipts.
Old manifests remain snapshots of their prior product versions, not current visual-polish source.

Existing selection/scroll/paging/gesture code and button hit geometry are unchanged. Physical rapid
swipes, live blur/color, actual rounded-edge compositing and animation appearance cannot be proven by
these tests; no claim that all six visual findings now pass on iPhone. Same historical anti-flicker
principle retained: never animate material ancestor alpha; hide covered compact material, not the
path-bearing root. No new input state machine, height framework or sticky-expansion changes.

Human screenshot comparison: (1) QWERTY idle full keyboard including host boundary; (2) QWERTY with
candidates and expanded/collapsed action at same scale; (3) T9 with actual selected path, expanded and
restored, preserving path row; (4) light/dark and Reduce Transparency on/off for idle and populated
bar; include both top corners, action bottom edge and system bottom area. Recheck rapid horizontal
swipes/edge candidates, path selection, recovery and collapse restoration as interactions, not static
screenshots. VoiceOver focus and contrast require a real system pass. Stop for Human; no Push, remote
PR update, merge, release, task closure or UI-2 integration.

V4 boundary: fixed34pt Path reservation and its existing idle-hint/recovery display policy remain unchanged. No new idle text or conditional height is introduced. If a real host presents expandable continuation candidates with no path/hint, that original reserved row can still be empty; this slice does not silently solve it via UI-2 or invent a second presentation policy. Human should specifically compare that state. Normal no-candidate trailing action still dismisses rather than opens the panel.
