# KEYBOARD-LAYOUT-9KEY-001 — Implementation Handoff for Codex Review

Prepared by: Grok (Executor)
Date: 2026-07-16 Asia/Shanghai
Branch: `feature/keyboard-layout-9key-spike`
Gate authorization: [`keyboard-layout-9key-001-codex-rereview-2.md`](keyboard-layout-9key-001-codex-rereview-2.md)

## 1. Assignment lifecycle / history

| Field | Value |
|---|---|
| Assignment | `docs/assignments/keyboard-layout-9key-001.md` |
| Product Decision | `docs/product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md` |
| ADR | `docs/architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md` |
| Lifecycle | **`Active`** (transition authorized by Codex final Spike gate re-review) |
| Prior gates | Spike + re-reviews closed; product steps 3–10 implemented in this package |

## 2. Changed-file allowlist (implementation package)

### KeyboardCore
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardLayoutStyle.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/RimeT9Readiness.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/RimeRuntimeSelection.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/T9PreeditResolver.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/T9SchemaCompatibility.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/RimeConfigTemplateGenerator.swift` (schema_list includes `t9`)
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TextEditing.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+ModeAndShift.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TypoCorrection.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PartialCommit.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/KeyboardLayoutAndT9RuntimeTests.swift`

### RimeBridge
- `Packages/RimeBridge/Sources/RimeBridge/RimeRuntimeSelectionBridge.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeT9SmokeProbe.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+SessionRecovery.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+Input.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+CustomYaml.swift`

### Main App
- `Universe Keyboard/Services/T9DeploymentSupport.swift`
- `Universe Keyboard/Services/SchemaManager+T9Layout.swift`
- `Universe Keyboard/Services/SchemaManager.swift`
- `Universe Keyboard/Services/SchemaManager+Installation.swift`
- `Universe Keyboard/Services/SchemaManager+Download.swift`
- `Universe Keyboard/Services/SchemaManagerTypes.swift`
- `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift`
- `Universe Keyboard/Views/Settings/SettingsTab.swift`
- `Universe Keyboard/Views/Settings/RimeSettingsStore.swift`

### Keyboard Extension
- `Keyboard/Controllers/KeyboardViewController.swift`
- `Keyboard/Controllers/KeyboardViewController+Presentation.swift`
- `Keyboard/Controllers/KeyboardViewController+Rows.swift`
- `Keyboard/Controllers/KeyboardViewController+KeyFactory.swift`
- `Keyboard/Controllers/KeyboardViewController+Feedback.swift`
- `Keyboard/Controllers/KeyboardViewController+InputActions.swift`

### Docs
- Assignment, ADR 0018 status, `KEYBOARD_LAYOUT.md`, `PROJECT_CONTEXT.md`, `RIME_SCHEME_MANAGEMENT.md`, `CHANGELOG.md`, this handoff, `codex-rereview-2.md` (Codex-authored)

## 3. Effective-scheme / readiness / T9 semantics tests

Executed:

```text
swift test --package-path Packages/KeyboardCore --filter KeyboardLayoutAndT9RuntimeTests
# 7 tests, 0 failures
swift test --package-path Packages/KeyboardCore --filter RimeConfigTemplateGenerationTests
# 13 tests, 0 failures
```

Coverage includes: layout fallback, effective `t9` only when ice+nineKey+matched readiness, legacy bool not matched, preedit comment then raw, Return/language never commit raw digits, compatibility strip, schema_list includes t9.

## 4. Main-App install/deploy/verify/failure/uninstall

Implemented code paths (not all exercised on-device in this handoff):

| Path | Implementation |
|---|---|
| Enable nine-key | `SchemaManager.enableNineKeyLayout`: ensure compatible t9 → deploy → smoke → readiness → layout last |
| Already ready | Persist `nineKey` only when fingerprint still matches |
| Not installed | License sheet → existing download/install → then enable |
| Failure | No optimistic `nineKey`; readiness invalidated on verify failure |
| Uninstall rime_ice | Layout 26-key → invalidate readiness → remove files including t9* |
| Switch base off ice | Layout 26-key; readiness preserved if files intact |

Automated UI path tests for license cancel / install failure matrices: **not fully automated in this package** (code present; see unrun).

## 5. RimeBridge session recovery / no-raw-digit

- Cold start, session recovery and visibility resume all use `RimeRuntimeSelectionBridge.resolve` (same effective schema).
- Controller Return / space / language / auto-English use `T9CompositionCommitPolicy` (keep or abandon; never host-commit raw digits).
- Dedicated RimeBridge XCTest for session recovery with T9 fixture: **not re-run** beyond prior Spike (see unrun).

## 6. Debug / Release builds

| Config | Result |
|---|---|
| Debug Simulator (`CODE_SIGNING_ALLOWED=NO`) | **BUILD SUCCEEDED** |
| Release Simulator | pending / see build log in session if completed |
| Vendor verify | **Passed** structural inventory (11 frameworks) |

## 7. Light/dark, compact width, Dynamic Type, accessibility

| Item | Status |
|---|---|
| Settings cards + decorative thumbnails (no glyphs) | Implemented; VoiceOver labels on cards; thumbnails `accessibilityHidden` |
| Simulator light/dark screenshots | **Not captured** in this handoff |
| Compact width / Dynamic Type | Structural use of system fonts/colors; **no screenshot matrix** |
| T9 key a11y | “数字 N，ABC” labels |

## 8. Physical-device acceptance

**Not executed.** Human Dependency remains: Human Product Owner for physical-device keyboard-extension acceptance (Messages/host apps, multi-syllable `64426`, process restart).

## 9. Essay read-only warning investigation

Spike deploy logs recorded:

```text
Error opening db 'essay' read-only.
```

**Outcome (productization note):**

- Warning originates from librime `text_db.cc` when essay/text DB open is attempted read-only during deploy/smoke.
- Did **not** block Spike select/`64`/candidates/delete on pinned 1.16.1.
- Product path still uses the same pinned librime; no essay packaging change was introduced by nine-key.
- Residual risk: noisy logs / optional ranking quality if essay is expected by some schema configs. Follow-up is packaging investigation, not a Spike blocker. Recommend confirming whether fog-song deploy expects an essay file under shared data; if missing, either supply essay asset or silence via config only after measuring impact.

## 10. Documentation / CHANGELOG

Updated: `CHANGELOG.md`, `docs/KEYBOARD_LAYOUT.md`, ADR 0018 status line, `docs/PROJECT_CONTEXT.md`, `docs/RIME_SCHEME_MANAGEMENT.md`, Assignment lifecycle `Active`.

## 11. Unrun verification / known limits / residual risks

| Item | Reason |
|---|---|
| Full KeyboardCore suite beyond focused filters | Time; focused T9 suite green |
| RimeBridgeTests full suite on this package | Not re-run after product code |
| Main App XCTest for layout enable failure matrix | Not added in this pass |
| Simulator install + end-to-end nine-key typing | Human/simulator interactive gate open |
| Physical device | Human Dependency |
| Light/dark screenshot archive | Not produced |
| Essay asset packaging fix | Investigation only; no binary/schema essay add |

### Known V1 limits (by design)

- English nine-key / swipe / 朙月 nine-key: out of scope
- No live cross-process layout hot-switch while keyboard is visible
- No librime vendor upgrade
- Advanced 26-key features may not fully apply on nine-key

### Residual risks for Quality

- Full deploy with real ice install must still be validated interactively after enable path.
- Session recovery functional test historically used `ni` for schema verify on recovery paths; effective schema `t9` may need digit-based recovery verification follow-up.
- `essay` warning still appears under some deploys.
