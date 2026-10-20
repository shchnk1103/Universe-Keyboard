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


## Continuous Candidate Surface — bounded phase A / B, 2026-10-20

Entry bb74235 / product86df674, same Writer codex-compact-header and P=none. Human pasted authorization
permits UI-only feasibility→implementation/L1/L2/local commit/checkpoint, no product publication or UI-2.
Phase A found the two existing CollectionViews already read presentedCandidates and retain shared
CandidateItem identities, ordering, font/width calculation and guarded paging. No Core, RIME, authority,
native selection, owner/epoch/revision rules or height framework changes are required. This is bounded
source feasibility, not an independent Architecture Review.

Implementation: CandidateReadingPosition.swift stores one observed CandidateItem/index plus visible
fraction/leading offset, original compact offset, and a token read from existing generation, published
and live revision/origin, raw input and compact-view identity. It is not another datasource or selection
permission. Before index reuse, token and item-at-index must match; duplicates are not rebound by title.
Snapshot refresh invalidates/resets to zero, even for same-size data; layout reload removes the view and
cleans its context. Append-only pagination with unchanged publication keeps anchors and order. Collapsing
also reloads the inactive compact view from the existing published list so appended items are reachable.

Readable partial threshold is max(12pt,20% of cell extent), capped at the whole cell extent. Iterate
visible items in original order; skip fully action-covered cells. Prefer the first passing threshold;
for a degenerate viewport with none passing, use the largest real visible remainder rather than invent
an index. Half-visible item15 is retained,1pt tail selects16. The original offset and clipped local
position are recorded. Expanded row aligns at the first readable region; when its column intersects
the action, put the anchor immediately below that action so it is fully visible (an earlier row can
remain visible above). All earlier candidates stay in content and can be scrolled back to. No-user-pan
collapse restores the exact observed/clamped compact offset, including fractional pixel position. A
recognized user pan marks the UI context; collapse selects the current valid visible item and positions
its compact Cell fully when it fits. Programmatic positioning/paging does not mark a user pan.

Adaptive flow retains measured text widths, shared CandidateCollectionCell font/weight/padding and
left alignment. New tokens name existing42pt expanded rows,3/8/6/8 section insets,0 layout gaps, reading
threshold and existing0.18/0.16s durations. Initial top rows reserve action width; all subsequent rows
use full width. No per-scroll invalidation/reflow or snapping is added; frame-equality tests pass while
scrolling and appending. Compact46pt/action56pt/symbol22pt remain unchanged.

The panel has no independent RGB fill: it is clear over the actual original keyboard surface/material.
An owned CAShapeLayer on the content stack removes covered keys progressively, retaining the real T9
path region and original key geometry. It never masks the Controller root or system globe/microphone.
The compact header/material stays hidden while the stack mask is installed; remove mask before showing
it again. Save/restore the prior mask and covered accessibility flags; removal/reload/recovery cancels
stale reveal completions. This supersedes the prior full-panel gray fill. No screenshot-derived color
match is claimed.

A single fixed UIVisualEffectView sits behind the collapse button, separate from the revealed content,
with tint/fallback derived from the existing keyboardSurfaceMaterialTintColor source. Reduce Transparency
uses that shared color opaque; no new RGB or gradient. The action is not faded/masked with the reveal,
remains56×46pt at the original screen position, and has priority hit routing. Later rows may scroll
behind it; button points never forward to the collection while visible cells outside the zone do.

Reveal viewport clipping and one matching content-stack mask path animation uncover rows and cover
keys on the same ease-out curve. Collection/root frames and root height do not animate. Compact text
is hidden until overlay removal to avoid duplicates. A short UI-only transition token disables cell/
action interaction and ignores repeated toggles; immediate recovery/removal invalidates old callbacks.
Reduce Motion or disabled UIView animations snap directly. No input/sticky expansion state machine
was added or changed. Existing paging's UI interaction flag is settled when its vertical view closes;
all original window requests, prefetch bounds and native selection checks remain unchanged.

Verification (same task simulator5F983B43-FAAC-46ED-B2B0-33E0E30F099F, /private/tmp/kch001-build;
Swift6/complete concurrency, CODE_SIGNING_ALLOWED=NO, visible warnings/as-errors):

| Current check | Result | Completed local log under /private/tmp/kch001-continuous |
|---|---|---|
| L1: Controller10 + compact6 + recovery4 + adapter6 + idle1 | 27 passed /0 failed /0 skipped | l1-final.log/.exit + xcresult |
| L2 KeyboardTests | 49/0/0 | l2.log/.exit + xcresult |
| L2 KeyboardExtensionTests | 41/0/0 | same L2 run |
| Debug build-for-testing | Pass,exit0 | debug-build-for-testing.log/.exit + xcresult |
| Changed Swift6 files strict lint | Pass,exit0 | format-final.log/.exit |

L1 covers320/390/430,26/T9, initial/mid/half/sliver, upward/downward access, exact unscrolled return,
new vertical anchor return, long/short/mixed natural widths,0/1/3 candidate boundaries, publication/raw/
value/layout invalidation, actual UIKit incremental append, fixed frame equality during scrolling,
covered/uncovered hit routing, local material/reduce-transparency policy, small repeated toggles,
short real UIView transition lifecycle and immediate recovery dismissal. These are in-process production
Controller/layout tests and existing adapter suites, not live RIME/Extension/user-gesture execution.
No required Auto Layout unsatisfiable diagnostic; rendered required-equation assertions pass. The
previous complete Core/App/Bridge and PR216 CI are background evidence, not rerun/current L3 proof.

Preserved failure: first l1 command exit65 had6 measurement assertions in the half-visible case,
49.7435897% versus exact50% after UIKit pixel-quantized scrolling. Functional anchor/index assertions
passed. Corrected the test tolerance to one actual display pixel / cell width; production threshold
unchanged. Original failed log/bundle remain failed. No unexplained retry or skipped test hidden.

Human saved project.pbxproj during implementation and explicitly asked to preserve it uncommitted.
The observed Xcode rewrite is mostly ordering/comments; parsed semantic diff against entry has one
change: KeyboardLayoutIntegrationTests membershipExceptions no longer lists Keyboard.entitlements.
Only a non-Swift file exclusion changed; actual resource packaging is not inferred from that field.
Swift source membership is unchanged. Tests/build used the preserved Human
project; source and config hashes/copies are recorded. No project changes are included in this lane's
product commit. Do not restore/clean that Human file. Artifact project-entry.pbxproj and
project-observed.pbxproj retain the comparison. Product review must distinguish this unstaged config.

All hashes are collected only after command exit receipts. continuous-evidence.json records product
source, current test configuration and completed success/failure logs. Raw evidence remains local;
no Push, PR update, merge/release, Writer handoff or task closure. New code not in PR216; UI-2#217
untouched. Human now explicitly allows an empty fixed34pt T9 path region; candidate content starts at
original header top, never inside that region. V1–V6 geometry/idle/material/icon/corner fixes are retained.

P0/P1 directed evidence passes. P2 animation fluency, true backdrop blur/readability/color matching,
actual iPhone VoiceOver/fast swipe/touch, host apps and corner compositing still require Human device
review. Compare mid-list half-visible expand, scroll upward then downward to ~40 and collapse; rapidly
toggle and trigger recovery; light/dark/Reduce Transparency; both keyboard layouts including empty T9
path area. No claim of complete real-device acceptance, no infinite attempts to manufacture visual proof.


## V7–V10 bounded visual delivery — 2026-10-20

Entry CP006 c61cd895 / product a415f599; same Writer codex-compact-header, P=none. Human
reports all five Continuous Candidate Surface device interactions accepted. This iteration only
changes three presentation files and their two existing test files. Anchor thresholds, reading/snapshot
semantics, ordered data/paging/selection, reveal animation, fixed34pt path/root/key sizing are unchanged.
No UI-2/main/other-worktree edits. No Push, PR update, merge, release or closure.

- V7 cause: full-width ordinary action material and flat tint terminate at the same hard edge.
  Replace the flat tint's appearance with one persistent10pt edge gradient using the existing dynamic
  semantic background color. Use tint-only fallback for this ordinary disjoint zone (no live blur to
  mask or expose a second backdrop seam); expanded action retains systemMaterial. Gradient stays
  entirely inside the56pt action zone, not candidate viewport. Idle/recovery hide it; Reduce Transparency
  uses opaque semantic fill and hides gradient. No effect-view/ancestor alpha or fade mask introduced.
- V8 cause: full56×46 material intersects panel's34pt outer corner, yielding irregular clipping.
  Center a36×36 circular material (radius18) inside the unchanged56×46 hit rectangle. Round geometry
  is independent of panel corners/background/reveal. Panel stays clear over original keyboard surface;
  action still consumes its full touch zone while candidates scroll beneath it.
- V9 measured before production edits:320/390/430 × QWERTY/T9 all +2pt right/+1pt down, including
  actual UILabel textRect and font-derived baseline. Compact inset left6/top0, Cell46; expanded
  left8/top3, Cell42. Now shared leading6, top=(46−42)/2=2; contentInset remains zero, initial offset0.
  Final six fixtures show text delta0/0 and equal font-derived baseline (0.01pt tolerance), not just
  Cell frames. At390pt: QWERTY text x16/y15/baseline31.1865234375; T9 x16/y49/baseline65.1865234375,
  identical in both presentations. Font17pt, measured title29.8413×20.2871; actual text rect30×20.3333.
  Natural wrap and noninitial reading-anchor placement are intentionally not forced into identical x.
- V10 cause: compact.secondaryLabel versus expanded.label (including state-update path).
  All three tint sites now use CandidateActionAppearance.symbolColor = secondaryLabel; shared22pt
  medium glyph and pi rotation unchanged. Dynamic semantic color, no new RGB.

L1 final28/0/0: Controller11 + Extension16 + Keyboard idle1; same actual Controller hierarchy,
widths/modes, reading-anchor half/sliver/scroll-back/exact-unscrolled-return/invalidation, rapid toggles,
Reduce Motion/recovery, fixed42/46 rows, symbol geometry, right-boundary and covered hit routing.
L2 Keyboard49/0/0 + Extension41/0/0. Debug build-for-testing exit0. Format-before-commit and strict
lint over all16 branch-changed Swift files exit0. No required unsatisfiable/UISV-canvas-connection
log diagnostics; rendered required-equation assertions pass. Hostless Keyboard screen/host-connection
warnings are expected harness limitations, not real Extension evidence. No L3 rerun requested.

Preserved first L1 exit65:214 repeated old-leading-inset assertions within one natural-flow case;
all errors at old test line383 expected8 but actual6, matching authorized shared leading change.
Updated that assertion to the shared token; kept row contiguity, stable-frame, access and hit checks.
No unexplained retry, skip, failed-log deletion or relabeling. Measurement and final logs/bundles remain
in /private/tmp/kch001-v7-v10; v7-v10-evidence.json hashes only completed files after exit receipts.
Human project.pbxproj remains unstaged, hash298cfdc9cd121ac2413463f5cc9360db2c3317ae024af17ee9d4f57dfceecc9e,
identical to entry; tests use that preserved Human configuration, excluded from product commit.

Real-device follow-up: both layouts, idle versus populated compact, light/dark/Reduce Transparency,
compare10pt ordinary edge blend and no idle plate; same first word before/after expansion (left/top/
baseline and gray glyph),36pt local circle and outer panel corners; scroll under fixed action and last
candidate; repeat five previously accepted reading/return/rapid-toggle checks, recovery and VoiceOver.
These visual/gesture properties are pending Human, not declared device-passed by unit tests.
This is a bounded presentation refinement; verification/tokens capture it, no new architecture document
or broad design-system migration needed. Existing CHANGELOG UI-1 entry remains applicable.
