# KEYBOARD-LAYOUT-9KEY-001 — Implementation Handoff for Codex Review

Prepared by: Grok (Executor)  
Date: 2026-07-16 Asia/Shanghai  
Branch: `feature/keyboard-layout-9key-spike`  
Codex implementation review addressed: `docs/evidence/keyboard-layout-9key-001-codex-implementation-review.md` (**not modified**)  
Gate authorization: `docs/evidence/keyboard-layout-9key-001-codex-rereview-2.md`

## Assignment lifecycle

| Field | Value |
|---|---|
| Assignment | `docs/assignments/keyboard-layout-9key-001.md` |
| Lifecycle | **`Active`** |
| Product Decision | `PD-KEYBOARD-LAYOUT-9KEY-001` |
| ADR | `docs/architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md` |

---

## Codex findings — closure map

### [P1] Resume/recovery omit fingerprint — **Fixed**

| Item | Detail |
|---|---|
| Files | `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl.swift` — store immutable `sharedDataDir` / `userDataDir`; `resolveRuntimeSelection()` always passes `sharedDataDir`. `RimeEngineImpl+SessionRecovery.swift` and `resumeAfterVisibilityChange()` call `resolveRuntimeSelection()` (not bare `resolve()`). |
| Tests | `Packages/RimeBridge/Tests/RimeBridgeTests/RimeRuntimeSelectionBridgeTests.swift` — without sharedDataDir fail-closed; with matching fingerprint selects `t9`. |
| Command / result | `xcodebuild test -scheme RimeBridgeTests -only-testing:RimeBridgeTests/RimeRuntimeSelectionBridgeTests` → **3 tests, 0 failures, TEST SUCCEEDED** |

### [P1] T9 behavior inferred from digit shape — **Fixed**

| Item | Detail |
|---|---|
| Files | `T9PreeditResolver.swift` — policies require `usesT9InputSemantics`. `KeyboardController.usesT9InputSemantics` set from same `RimeRuntimeSelection` in `KeyboardViewController+Feedback.refreshCachedSettings`. Call sites: TextEditing (space/return), ModeAndShift (language/auto-English), TypoCorrection, PartialCommit. |
| Tests | `KeyboardLayoutAndT9RuntimeTests` (digit shape without semantics → `.notT9Composition`); `T9ControllerSemanticsTests` (return keeps composition under T9; language abandon; typo suppress only when semantics on). |
| Command / result | `swift test --package-path Packages/KeyboardCore --filter 'KeyboardLayoutAndT9RuntimeTests\|T9ControllerSemanticsTests'` → **13 tests, 0 failures** |

### [P1] Enable failures leave stale readiness — **Fixed**

| Item | Detail |
|---|---|
| Files | `Universe Keyboard/Services/SchemaManager+T9Layout.swift` — `beginNineKeyEnableTransaction()` persists **26-key** and **invalidates readiness** before any asset-mutating step; readiness + nineKey written only after prepare → deploy → smoke → fingerprint all succeed (nineKey last). |
| Tests | `UniverseKeyboardTests/NineKeyEnableTransactionTests.swift` — transaction forces 26-key + unmatched readiness; success order readiness-before-nineKey. |
| Command / result | `xcodebuild test -scheme 'Universe Keyboard' -only-testing:UniverseKeyboardTests/NineKeyEnableTransactionTests` → **2 tests, 0 failures, TEST SUCCEEDED** |

### [P2] `t9.custom.yaml` not synced — **Fixed**

| Item | Detail |
|---|---|
| Files | `RimeConfigManager+CustomYaml.swift` — when fog-song installed, writes `t9.custom.yaml` using **rime_ice** user-dictionary preference + simplification. `RimeUserDictionarySettings.isEnabled(for: "t9")` maps to ice preference. Public `makeSchemaCustomYamlContent` for unit tests. |
| Tests | `RimeRuntimeSelectionBridgeTests.testT9CustomYamlUsesIceUserDictionaryPreference`; `testUserDictionaryPreferenceAppliesToT9SchemaID`. |
| Command / result | Covered in RimeBridge selection suite (above) and KeyboardCore layout suite. |

---

## Automated verification summary

| Suite | Command | Result |
|---|---|---|
| KeyboardCore full | `swift test --package-path Packages/KeyboardCore` | **586 tests, 0 failures** |
| RimeBridge selection/custom | `xcodebuild test -scheme RimeBridgeTests -only-testing:RimeBridgeTests/RimeRuntimeSelectionBridgeTests` | **3/0, TEST SUCCEEDED** |
| Main App enable transaction | `xcodebuild test -scheme 'Universe Keyboard' -only-testing:UniverseKeyboardTests/NineKeyEnableTransactionTests` | **2/0, TEST SUCCEEDED** |
| Real T9 fixture Spike | `UK_RIME_T9_SPIKE_*` → existing isolated runtime `evidence/keyboard-layout-9key-spike/20260716-195542/runtime/{shared,user}` + `-only-testing:RimeBridgeTests/RimeT9CompatibilitySpikeTests` | **passed** (`schema=t9 rawAfter64=64 candidateCount=9 firstCandidateComment=ni rawAfterDelete=6`) |
| Release Simulator build | `xcodebuild … -configuration Release CODE_SIGNING_ALLOWED=NO build` | **BUILD SUCCEEDED** |
| Debug Simulator build | previously green; re-validated via test builds | **OK** |

### Real T9 fixture note

- Source: prior Spike isolated tree (gitignored local `evidence/…/20260716-195542/runtime`), not formal App Group.
- Scripted full runner failed only because the original Simulator App Group path was gone; XCTest was run with explicit env dirs against the archived isolated fixture.
- Result line: `T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 …`

---

## Simulator / physical-device evidence

| Item | Status |
|---|---|
| Interactive main-app enable UI (thumbnails, failure copy, persisted selection) | **Not re-captured** this pass (code paths updated; no new screenshot archive) |
| Extension E2E: cold start / hide-show / recovery / CN-EN / Space-Return-Delete | **Not executed** this pass |
| Physical device | **Not executed** — Human Dependency |
| Light/dark compact screenshots | **Not produced** |

---

## Remaining skipped / UNKNOWN validation

| Item | Reason |
|---|---|
| Full RimeBridgeTests scheme without filter | Not re-run entire suite after fix (focused suites + Spike green) |
| Full UniverseKeyboardTests suite | Only NineKeyEnableTransactionTests executed |
| Interactive simulator keyboard host lifecycle | Requires human operator time |
| Physical-device acceptance | Human Product Owner dependency |
| Screenshot matrix | Not produced |
| Essay packaging productization | Prior investigation stands; no code change in this pass |

---

## Residual risks (honest)

1. Interactive enable path after `beginNineKeyEnableTransaction` will **briefly** force 26-key during deploy even for a re-enable of already-ready nine-key (fail-closed by design; UX may show intermediate 26-key).
2. Session recovery still depends on App Group readiness + on-disk `t9.schema.yaml` integrity; interactive hide/show not re-observed on device.
3. Essay read-only warning may still appear during deploy logs.

---

## Requested Codex action

Re-review implementation against ADR 0018 fail-closed and single effective-selection contracts. Do not accept final Product Gate until interactive simulator/device evidence is supplied or explicitly waived by Human Product Owner.
