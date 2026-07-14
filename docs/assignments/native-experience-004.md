# Assignment: NATIVE-EXPERIENCE-004 — Candidate Presentation Path Optimization

**Policy version:** `1.0.0`

**Decision source / date:** Human Product Owner authorization to continue the remaining keyboard performance work / `2026-07-14 Asia/Shanghai`

**Lifecycle status:** `Active`

**Repository change types:** `Implementation`, `Evidence`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Product Approver:** Product Lead acting under the human owner's explicit implementation and physical-device debugging authorization
- **Assignment Revalidation Authority:** Product Lead
- **Product source:** Current candidate presentation behavior, NATIVE-EXPERIENCE-003 handoff and the Extension performance measurement contract

## Acknowledgement And Activation

- **Executor acknowledgement:** `2026-07-14 Asia/Shanghai` — Scope, Non-goals and Stop Conditions accepted.
- **Architecture acknowledgement:** Candidate identity, KeyboardCore actions, UIKit touch geometry and main-thread RIME session ownership remain unchanged.
- **Quality acknowledgement:** Focused tests, strict Debug/Release builds and physical-device crash/interaction checks are required before completion.
- **Product lifecycle decision:** `Ready -> Active`, `2026-07-14 Asia/Shanghai`.

## Assignment

- **Domain Owner:** Keyboard Experience Maintainer
- **Executor:** Keyboard Experience Maintainer
- **Environment Executor:** Quality, Performance & Release Maintainer using the connected iPhone and user-opened Device Hub
- **Human Dependency:** Human owner for any required device unlock, trust prompt and final subjective typing judgment
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer
- **Product Approver:** Product Lead
- **Handoff Target:** Human owner for final physical-device acceptance

## Objective

Remove repeated shared-preference, candidate-array and layout-cache work from candidate touch, rendering and paging paths while preserving visible candidates, selection references, touch behavior and RIME session semantics.

## Scope

1. Cache candidate-touch diagnostic enablement outside `pointInside` and `hitTest`; refresh it with the existing settings snapshot lifecycle.
2. Establish one presentation-list invariant so collection data-source callbacks do not repeatedly filter the same candidate array.
3. Replace per-appended-candidate linear duplicate scans with one bounded global-index set for each paging merge.
4. Index expanded-layout attributes by `IndexPath` instead of linearly searching the cached array.
5. Release candidate sizing and expanded-layout resources under memory pressure without clearing active composition or candidate identity.
6. Add focused regression coverage where the boundary is testable and run strict Debug/Release plus physical-device verification.

## Non-goals

- No candidate text, ordering, preferred-candidate, correction-ranking or selection-reference change.
- No key or candidate touch geometry, gesture threshold, animation or visual-style change.
- No KeyboardCore input semantics, marked text, Delete, Space, Return or commit change.
- No RIME threading, session, schema, deployment, recovery or candidate-window API change.
- No new background work and no synchronous storage or logging in input paths.
- No numeric performance claim without comparable Release physical-device evidence.
- No overwrite or cleanup of unrelated dirty-worktree changes.

## Required Inputs

- `AGENTS.md`
- `docs/ASSIGNMENT_POLICY.md`
- `docs/PROJECT_CONTEXT.md`
- `docs/PERFORMANCE_BASELINE.md`
- `docs/TECH_DEBT.md` TD-003
- `docs/RELEASE_CHECKLIST.md`
- `docs/playbooks/keyboard-ui.md`
- NATIVE-EXPERIENCE-003 completion record
- current candidate collection, paging, expanded layout, diagnostics and memory-warning sources

## Entry Criteria

- Human owner explicitly authorizes continuing the remaining optimization work and use of the connected device environment.
- Assignment contains no `UNKNOWN` field.
- Candidate presentation sources prove that production snapshots contain selectable candidate/composition kinds rather than placeholder rows.
- Each optimization can preserve the current main-actor and UIKit lifecycle boundary.
- Existing unrelated worktree changes can remain untouched.

## Exit Criteria

- Candidate touch callbacks perform no App Group preference read and do not poll time solely to discover logging state.
- Collection data-source callbacks do not allocate a freshly filtered copy of the candidate list.
- Paging duplicate detection is linear in the existing plus appended candidate counts.
- Expanded-layout item lookup uses indexed cached attributes.
- Memory warnings clear recoverable candidate caches and dismiss the optional expanded panel without changing composition.
- Strict automated tests and Debug/Release builds pass, or exact blockers are recorded.
- The corrected app is installed and physical-device checks cover keyboard selection, continuous English/Chinese input, candidate paging/expansion and post-run crash reports.

## Stop Conditions

Stop and return to the owning authority if:

- an optimization requires changing candidate identity, ordering, touch geometry or gesture ownership;
- RIME work must move off its accepted main-thread/session boundary;
- a cache requires duplicating mutable business truth without a single update boundary;
- automated or device validation exposes a crash, wrong commit, stale candidate or system-keyboard fallback;
- Device Hub requires an unavailable human trust/unlock action;
- unrelated dirty changes must be overwritten;
- numeric acceptance is requested without comparable Release evidence.

## Verification Matrix

- Source/contract checks for candidate kinds, global selection references and no hot-path App Group reads.
- `KeyboardCore`, `KeyboardTests` and affected app/bridge tests as applicable.
- Debug and Release builds with Swift concurrency warnings treated as errors.
- Physical iPhone: select keyboard after install/process restart and continuously type English and Chinese.
- Physical iPhone: scroll the horizontal candidate list, expand/collapse, select later candidates and switch host apps.
- Device crash-log comparison before/after the installed build; distinguish crash, jetsam and ordinary lifecycle exit.

## Handoff

Provide the changed-file inventory, invariant reasoning, automated command results, Device Hub/device evidence, skipped measurements, residual risks, documentation impact and confirmation that input/RIME/touch semantics were not changed.

## Execution Evidence In Progress

- **Implementation date:** `2026-07-14 Asia/Shanghai`.
- Candidate-touch diagnostic enablement now refreshes with the existing keyboard settings snapshot. Disabled touch diagnostics perform only an in-memory Boolean read before returning.
- The collection data source reuses `accumulatedCandidates` as its single presentation list. Placeholder removal occurs once at the controller-to-presentation rebuild boundary; candidate windows continue to append only RIME candidate items with stable global selection references.
- Paging builds one global-index set per merge and preserves the previous nil-index fallback semantics. Expanded layout attributes use a non-trapping `IndexPath` dictionary, and memory warnings release the candidate sizing cache.
- `swift test --package-path Packages/KeyboardCore`: 545 tests passed, 0 failures.
- `Universe Keyboard` simulator test action: 99 tests passed, 0 failures, 0 skipped.
- The isolated `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests/testNE1ColdActivationAndFirstInput` scenario passed after the final lifecycle correction.
- Strict Debug and Release iOS Simulator builds passed with Swift concurrency warnings treated as errors after the final cache implementation.
- With user authorization, Device Hub enabled Universe Keyboard and Full Access on the iPhone 17 Pro Max Simulator. The first installed build exposed a blank keyboard and logged a fatal unwrap at `KeyboardViewController+Presentation.swift:80`; investigation traced this to the system-click input view being assigned during `init`, which allowed `viewWillAppear` to precede KeyboardCore bootstrap.
- The input view now loads through `loadView`. Two fresh Extension processes then completed cold activation without a fatal error. Device Hub verified English key insertion, Chinese `nihao -> 你好` candidate selection, `zhongguo` candidate expansion and switch-away cleanup of uncommitted composition.
- Device Hub emitted iOS 27 Simulator/Xcode beta coordinate-space and early `needsInputModeSwitchKey` diagnostics during hosted presentation. They did not terminate either corrected process or prevent input; they are not treated as physical-device evidence.
- Device Hub and `devicectl` both report the physical iPhone 13 Pro and iPad as unavailable. Physical installation, continuous typing, candidate paging/expansion and post-run crash-log checks remain open.
- No KeyboardCore input, candidate ordering, selection reference, RIME session/thread or touch geometry contract changed. No ADR or architecture update is required.

## Revalidation Trigger

Product and Architecture revalidation are required if work expands into candidate behavior, touch geometry, KeyboardCore semantics, RIME ownership/threading, lifecycle contracts, diagnostic privacy or a new numeric budget.
