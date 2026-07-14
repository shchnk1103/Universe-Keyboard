# Assignment: NATIVE-EXPERIENCE-002 — Keyboard Startup Optimization

**Policy version:** `1.0.0`

**Decision source / date:** Human Product Owner authorization in the active keyboard-startup objective / `2026-07-13 Asia/Shanghai`

**Lifecycle status:** `Completed`

**Repository change types:** `Implementation`, `Evidence`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Product Approver:** Product Lead acting under the human owner's explicit implementation authorization
- **Assignment Revalidation Authority:** Product Lead
- **Product source:** Current keyboard feedback settings plus the accepted RIME runtime/session architecture

## Acknowledgement And Activation

- **Executor acknowledgement:** `2026-07-13 Asia/Shanghai` — Scope, Non-goals and Stop Conditions accepted.
- **Architecture acknowledgement:** ADR 0001, ADR 0003 and ADR 0004 remain binding; this task does not move deployment or RIME calls into a new owner or thread.
- **Quality acknowledgement:** Automated tests and Debug/Release builds are required before device handoff; physical-device AirPods and startup evidence remains open until supplied by the human owner.
- **Product lifecycle decision:** `Ready -> Active`, `2026-07-13 Asia/Shanghai`.

## Assignment

- **Domain Owner:** Keyboard Experience Maintainer
- **Executor:** Keyboard Experience Maintainer, coordinating the bounded RimeBridge startup work package
- **Environment Executor:** Quality, Performance & Release Maintainer for automated build/test evidence; human owner for physical-device AirPods and startup evidence
- **Human Dependency:** Human owner with an iPhone, iPad and AirPods for final route-ownership and physical-device performance validation
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer
- **Product Approver:** Product Lead
- **Handoff Target:** Human owner for device validation, followed by Product Lead for acceptance

## Objective

Reduce Keyboard Extension cold-start work and stop keyboard feedback from activating an app-owned audio session that can take AirPods away from audio already playing on another Apple device.

## Scope

1. Replace Extension-owned `AVAudioSession` / `AVAudioPlayer` key clicks with the UIKit input-click contract.
2. Keep the main-App feedback settings truthful about system-owned click behavior.
3. Remove Extension startup-time click WAV generation, temporary-file writes and player preparation.
4. Add a healthy RIME startup fast path that selects the requested schema without synthetic input or eager schema enumeration.
5. Preserve deeper schema functional validation for explicit recovery/failure paths.
6. Avoid duplicate settings loading during first presentation and cache appearance settings used during layout.
7. Prepare haptic generators only when haptics are enabled.
8. Reduce normal RIME startup diagnostics and Release librime log volume while retaining actionable failure and aggregate performance logs.
9. Add focused tests and perform Debug/Release build validation.

## Non-goals

- No keyboard geometry, candidate UI, animation or layout optimization.
- No RIME deployment, maintenance, schema repair or file scan in the Extension.
- No background-thread librime calls or session ownership change.
- No candidate, composition, commit, Delete, Space or Return semantic change.
- No attempt to claim AirPods or physical-device performance acceptance from Simulator/build evidence.
- No modification or reinterpretation of NATIVE-EXPERIENCE-001 evidence.
- No unrelated refactor and no overwrite of unrelated dirty-worktree changes.

## Required Inputs

- `AGENTS.md`
- `docs/PERFORMANCE_BASELINE.md`
- `docs/UI_STYLE_GUIDE.md`
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- ADR 0001, ADR 0003, ADR 0004 and ADR 0008
- `docs/architecture/swift6-migration.md`
- `docs/DEBUGGING.md`
- `docs/RELEASE_CHECKLIST.md`
- current iOS SDK `UIInputViewAudioFeedback` and `UIDevice.playInputClick()` contract
- current Extension feedback/bootstrap and RimeBridge session sources

## Entry Criteria

- Human owner has explicitly approved implementation of the six bounded optimization areas.
- Assignment contains no `UNKNOWN` field.
- The audio fix removes app-owned route activation rather than merely moving the same activation later.
- RIME remains session-only and serialized on its current thread/actor boundary.
- UI layout work remains out of scope.
- Unrelated worktree changes can remain untouched.

## Exit Criteria

- Extension startup performs no app-owned audio-session activation, click WAV generation or click-player preparation.
- Key clicks use the UIKit input-click contract and remain gated by the App toggle plus system input-click settings.
- Main-App feedback UI does not claim that a custom volume level controls system keyboard clicks.
- Healthy RIME cold startup does not enumerate all schemas or synthesize `ni` input.
- Failure/recovery paths retain actionable schema diagnostics and functional validation.
- First presentation loads shared settings once; layout does not repeatedly read the material flag from App Group defaults.
- Disabled haptics do not trigger haptic preparation.
- Focused tests and required Debug/Release builds pass, or blockers are recorded exactly.
- Human-owner AirPods route and physical-device cold/warm startup checks are handed off with an exact matrix.
- Documentation impact and changelog review are complete.

## Stop Conditions

Stop and return to the owning authority if:

- UIKit system clicks still require the Extension to activate its own `AVAudioSession`;
- preserving a custom click volume requires app-owned Bluetooth route participation;
- RIME optimization requires deployment, repair, maintenance or arbitrary background calls from the Extension;
- a schema fast path cannot preserve safe fallback and recovery behavior;
- unrelated dirty changes must be overwritten;
- automated validation exposes a product/runtime failure outside this scope;
- final AirPods or physical-device claims are requested without the named hardware evidence.

## Verification Matrix

- Focused source/test checks for feedback settings and RIME schema-selection behavior.
- KeyboardCore and RimeBridge contract tests affected by the change.
- Debug and Release Simulator builds with Swift 6 warnings as errors.
- Physical iPhone: silent mode on/off and App key-click toggle on/off.
- AirPods connected to iPad and iPhone while iPad audio is playing; typing on iPhone must not transfer route ownership because of Universe Keyboard.
- Cold startup with a fresh Keyboard PID and warm return with the same PID; record multiple comparable Release samples.
- First English key, first Chinese composition key and first candidate remain functional.

## Handoff

Provide changed-file inventory, automated command results, skipped evidence, exact device matrix, AirPods reproduction steps, residual risk, documentation impact and confirmation that NATIVE-EXPERIENCE-001 files were not modified.

## Revalidation Trigger

Product and Architecture revalidation are required if the task reintroduces custom Extension audio playback, changes RIME session ownership/threading, changes Full Access behavior, changes keyboard lifecycle semantics, expands into UI layout work or alters the named owners/reviewers.

## Completion Record

- **Executor completion:** `2026-07-13 Asia/Shanghai` — scoped implementation, focused tests, documentation and automated builds delivered.
- `swift test --package-path Packages/KeyboardCore`: 544 tests passed, 0 failures.
- `RimeBridgeTests` on iPhone 17 Pro Max / iOS 27.0 Simulator: 23 tests executed, 0 failures; the environment-gated real Lua fixture test was skipped as designed.
- `Universe Keyboard` Debug and Release generic iOS Simulator builds passed with Swift warnings treated as errors.
- Release binary/source checks found no Keyboard-target `AVAudioSession`, `AVAudioPlayer`, generated click WAV or custom click-player path. Debug-only `RIME_DIAGNOSTICS` was absent from the Release compile response files.
- Existing vendor xcframework x86_64 compatibility notices remain unchanged; arm64 Simulator linking and the complete builds succeeded.
- Human dependency remains open: physical iPhone/iPad/AirPods route ownership plus comparable Release cold/warm startup samples.
- NATIVE-EXPERIENCE-001 protocol, evidence and automation files were not modified by this Assignment.

## Post-completion Regression Correction

- **Correction date:** `2026-07-13 Asia/Shanghai`.
- Physical-device crash reports showed six consecutive Extension crashes during keyboard selection. The main-thread fault was `KeyboardViewController.synchronizeAfterTextChange()`, reached from `textDidChange(_:)` before `viewDidLoad` had initialized the KeyboardCore controller.
- The lifecycle callback now ignores document changes until the view and controller bootstrap are complete. This is safe because bootstrap reads the current keyboard type and capitalization context before normal input begins.
- The correction preserves the UIKit system-click path and does not reintroduce an Extension-owned audio session.
- Debug physical-device and unsigned Release generic-iOS builds passed, and the corrected Debug app was installed on the connected iPhone. Final continuous-typing and AirPods acceptance remains owned by the human device tester.

## Post-completion Lifecycle Root-cause Correction

- **Correction date:** `2026-07-14 Asia/Shanghai`.
- Device Hub reproduced a blank keyboard followed by system fallback. The Extension log identified the remaining crash at `KeyboardViewController+Presentation.swift:80`, where `reloadKeyboard()` read `controller.state` before bootstrap.
- The primary cause was installing `KeyboardAudioFeedbackInputView` by assigning `inputView` inside `KeyboardViewController.init`. On the observed iOS 27 Simulator path, UIKit entered `viewWillAppear` without first running `viewDidLoad`, so the earlier `textDidChange` guard removed one early callback crash but did not restore the controller lifecycle invariant.
- The audio-feedback view is now created in `loadView`. Standard `UIViewController` ordering therefore constructs the view, runs `viewDidLoad` / KeyboardCore bootstrap, and only then installs keyboard content during presentation. The UIKit system-click contract remains unchanged and no Extension-owned audio session was reintroduced.
- Device Hub completed two isolated cold activations without a fatal error. English key input, `nihao -> 你好` candidate commit, `zhongguo` candidate expansion and switch-away composition cleanup all succeeded. The isolated `testNE1ColdActivationAndFirstInput` UI test also passed.
- Physical iPhone/iPad/AirPods acceptance remains open because both physical devices were unavailable in Device Hub during this correction.
