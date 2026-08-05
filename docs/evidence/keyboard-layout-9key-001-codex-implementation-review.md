# KEYBOARD-LAYOUT-9KEY-001 Codex Implementation Review

- Review date: 2026-07-16
- Reviewed branch: `feature/keyboard-layout-9key-spike`
- Reviewed commit: `a7a6bf1` (`feat(9key): implement 26/9-key layout under ADR 0018`)
- Primary input: `docs/evidence/keyboard-layout-9key-001-implementation-handoff.md`
- Authority: Assignment `KEYBOARD-LAYOUT-9KEY-001`, ADR 0018, accepted Spike evidence
- Review result: **Changes Required — do not enter final acceptance yet**

## Executive conclusion

The implementation compiles in Release and its current automated suites pass, but three runtime safety contracts are not actually preserved:

1. T9 readiness is resolved with the on-disk fingerprint only at cold initialization; visibility resume and session recovery omit the shared-data directory and therefore silently fall back away from T9.
2. KeyboardCore infers “T9 mode” from any non-empty all-digit raw input instead of receiving the effective runtime mode. This applies T9 commit/abandon/suppression semantics to digit compositions outside effective 9-key Chinese mode.
3. The main-app enable transaction invalidates readiness only after smoke verification failure. Preparation, deployment, and fingerprint failures can leave a previously matched readiness marker and 9-key layout active while assets are stale or partially replaced.

These are acceptance blockers because they violate ADR 0018's single effective-selection and fail-closed requirements. Passing builds do not close them.

## Findings

### [P1] Resume and recovery omit the T9 resource fingerprint

Evidence:

- `RimeRuntimeSelectionBridge.resolve(defaults:sharedDataDir:)` derives `t9.schema.yaml` fingerprint only when `sharedDataDir` is provided (`Packages/RimeBridge/Sources/RimeBridge/RimeRuntimeSelectionBridge.swift:8-16`).
- `RimeEngineImpl.resumeAfterVisibilityChange()` calls `resolve()` without that directory (`RimeEngineImpl.swift:192-204`).
- `restoreInputSession()` also calls `resolve()` without it (`RimeEngineImpl+SessionRecovery.swift:20-34`).

Impact:

- A matched 9-key selection can work after cold start, then switch to `rime_ice` after keyboard visibility suspension or session recovery because `onDiskFingerprint` becomes `nil`.
- UI layout and RIME schema can diverge: the extension may still render 9-key while the recovered engine uses the base 26-key schema.
- The implementation handoff statement that cold start, recovery, and resume use the same effective scheme is therefore not true for the reviewed commit.

Required change:

- Preserve the immutable `sharedDataDir` in `RimeEngineImpl` and pass it to every runtime-selection resolution path, or provide one centralized resolver that always has the same fingerprint source.
- Add RimeBridge tests proving that cold start, visibility resume, and session recovery all preserve `effectiveSchemaID == "t9"` when readiness and fingerprint match, and all fail closed consistently when they do not.

### [P1] T9 behavior is inferred from raw digits instead of effective runtime mode

Evidence:

- `T9CompositionCommitPolicy.isT9DigitComposition` returns true for every non-empty all-decimal raw input (`Packages/KeyboardCore/Sources/KeyboardCore/T9PreeditResolver.swift:54-57`).
- That shape-only predicate controls space/return behavior, language and auto-English switching, partial commit, display preedit, and typo-correction suppression across KeyboardCore.
- `KeyboardController` has no explicit `usesT9InputSemantics` or equivalent effective-layout state. The effective runtime selection currently remains outside the controller.

Impact:

- Pure-digit raw input in a 26-key/non-T9 context can be treated as T9 composition: Return or space may keep/commit differently, language switching may abandon it, and typo correction may be suppressed.
- Input shape is not product state. A string containing digits cannot prove that the active schema and layout are T9.

Required change:

- Feed an explicit effective T9 semantic flag/state into `KeyboardController`, derived from the same `RimeRuntimeSelection` used to choose schema and render layout.
- Centralize the invariant. T9-only policies must require effective T9 semantics (and, where applicable, Chinese letters page), then inspect digit composition.
- Add regression tests for identical digit raw input under effective 26-key and effective 9-key modes, including Space, Return, language toggle, auto-English, partial commit, and typo-correction paths.

### [P1] Enable failures do not always invalidate previously matched readiness

Evidence:

- `enableNineKeyLayout()` returns directly on compatibility preparation failure (`Universe Keyboard/Services/SchemaManager+T9Layout.swift:17-21`).
- It returns directly on deployment failure (`:23-26`).
- It returns directly on fingerprint failure (`:37-39`).
- Only smoke verification failure invalidates readiness (`:32-34`).

Impact:

- If the user already has matched readiness and 9-key selected, a later update/redeploy can modify assets and fail before the smoke-check branch. The old marker and layout can remain active even though the new asset state was not proven.
- “已保持原布局” is not a safe outcome when the original layout is 9-key and deployment may have partially changed its dependencies.

Required change:

- Before the first operation that can alter T9/RIME assets, persist 26-key and invalidate T9 readiness.
- Only after compatibility preparation, deployment, smoke verification, and fingerprint generation all succeed may the code write the new readiness marker and persist 9-key last.
- Add deterministic failure-matrix tests for directory acquisition, preparation, deployment, smoke verification, and fingerprint generation, plus ordering assertions that an interruption cannot expose 9-key with unmatched resources.

### [P2] `t9.custom.yaml` is not synchronized with user preferences

Evidence:

- `RimeConfigManager+CustomYaml` writes schema custom files only for `luna_pinyin` and `rime_ice` (`Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+CustomYaml.swift:46-63`).
- Simplification and `translator/enable_user_dict` are schema-scoped patches (`:65-100`), so `rime_ice.custom.yaml` does not automatically establish those settings for the distinct `t9` schema ID.

Impact:

- Switching to 9-key can silently stop honoring the user's simplification and Rime Ice user-dictionary preference.
- This creates behavioral drift between the base scheme and its T9 presentation.

Required change:

- Generate `t9.custom.yaml` using the Rime Ice preference contract, with explicit tests for simplification and user-dictionary enable/disable behavior.

## Verification performed by Codex

- `git diff --check origin/main...HEAD`: passed.
- `swift test --package-path Packages/KeyboardCore`: passed, 580 tests, 0 failures.
- Release simulator build:
  - `xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'Universe Keyboard' -configuration Release -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build`
  - Result: `BUILD SUCCEEDED`.
- Full currently runnable RimeBridge scheme:
  - `xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme RimeBridgeTests -destination 'platform=iOS Simulator,id=900FB396-39BF-4A84-9E75-FF813C155FA7' test`
  - Result: 26 executed, 0 failures, 3 skipped.
  - Skipped: two Lua fixture smoke tests and one real T9 compatibility Spike because their external fixture directories were not configured.

## Still required after fixes

1. Re-run KeyboardCore and RimeBridge suites, including the new recovery and failure-matrix coverage.
2. Run the real T9 fixture smoke test with `UK_RIME_T9_SPIKE_SHARED_DIR` and `UK_RIME_T9_SPIKE_USER_DIR` configured against the implementation assets.
3. Validate in the main app that 26-key/9-key thumbnails, installation progress, failure copy, and persisted selection agree with actual state.
4. Validate the extension end to end: cold start, hide/show, forced session recovery, app relaunch, layout switching, Chinese/English switching, numbers/symbols, Space, Return, Delete, and candidate selection.
5. Capture simulator screenshots and physical-device evidence. The custom keyboard's host-app lifecycle makes device-observed recovery behavior part of acceptance.

## Grok handoff

Please address the findings in priority order. Do not close them by weakening readiness checks or by adding tests around the current shape-only behavior. The target architecture is one effective runtime selection shared by schema choice, layout rendering, and controller input semantics, with 26-key as the observable state before every risky deployment/update operation.

After implementation, update `docs/evidence/keyboard-layout-9key-001-implementation-handoff.md` with:

- exact files changed for each finding;
- tests added and commands/results;
- real T9 fixture result;
- simulator and physical-device evidence paths;
- any remaining `UNKNOWN` or skipped validation.
