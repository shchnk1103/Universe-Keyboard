# KEYBOARD-LAYOUT-9KEY-001 — Codex Implementation Re-review 2

Reviewer: Codex

Date: 2026-07-16 Asia/Shanghai

Branch: `feature/keyboard-layout-9key-spike`

Reviewed HEAD: `b203ba0` plus Grok's uncommitted implementation changes

Primary handoff: `docs/evidence/keyboard-layout-9key-001-implementation-handoff.md`

Previous review: `docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview.md`

## Review result

**Changes Required — implementation is not accepted yet.**

Grok has genuinely implemented the three requested change directions. The production enable orchestration and failure matrix are materially improved; the T9 custom-YAML production plan is wired into synchronization and covered; the normal cold-start schema fallback now reconciles the engine selection before the extension applies chrome and input semantics. The implementation handoff whitespace is also clean.

One P1 lifecycle gap remains. The fail-closed state is not published on several early failure paths, and a realized-selection change produced by an in-place `recoverSession()` is not propagated from the engine back to the extension UI/controller. Consequently, the keyboard can still display 9-key chrome and retain T9 input policy after the usable runtime has disappeared or recovered onto a non-T9 schema.

## Finding

### P1 — Resume/recovery fail-closed propagation is incomplete

#### A. Resume early failures preserve the previous T9 selection

Evidence in `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl.swift:214-236`:

- If `initializeEngine()` or `createSession()` fails, the method returns at lines 216-221 before resolving and publishing a fail-closed selection.
- If `selectSchemaForStartup` returns `nil`, the method finalizes and returns at lines 227-233 before calling `applyRealizedSelection`.
- Therefore `runtimeSelection` remains the value from before suspension, which can still be T9.
- `Keyboard/Controllers/KeyboardViewController.swift:237-240` immediately reapplies that stale value to chrome and `controller.usesT9InputSemantics` after resume returns.

This means a completely unavailable resumed runtime can still present 9-key/T9 semantics.

#### B. Recovery changes the engine selection without notifying chrome/controller

Evidence:

- `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+SessionRecovery.swift:30-34` correctly reconciles the requested selection with the actual recovered schema inside the engine.
- `recoverSession()` is invoked from `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift:227-244` during an input action.
- The only extension calls to `applyRealizedRuntimeSelection` are engine activation, `viewWillAppear`, and settings refresh. There is no callback, result, observer, or post-action synchronization for an in-place recovery.
- Thus recovery can change `engine.runtimeSelection` from T9 to 26-key while `cachedLayoutStyle`, `cachedT9ReadinessMatched`, and `controller.usesT9InputSemantics` remain T9 for the rest of the visible lifecycle.

The recovery function also returns before publishing fail-closed state when session recreation/restart itself fails at `RimeEngineImpl+SessionRecovery.swift:23-26`.

#### Required change

- Publish a fail-closed realized state before returning from every resume/recovery failure path, including runtime/session initialization failure and total schema-selection failure.
- Propagate realized-selection changes produced during `recoverSession()` to the extension immediately. A callback/observer, a recovery result consumed by the controller/UI, or an equivalent single-source-of-truth mechanism is acceptable; polling only at later view lifecycle events is insufficient.
- Ensure chrome, `cachedT9ReadinessMatched`, and `controller.usesT9InputSemantics` transition together and reload the grid once when the effective layout changes.
- Add production-path tests for:
  1. previous T9 + resume initialization failure → observable 26-key semantics;
  2. previous T9 + resume schema-selection failure → observable 26-key semantics;
  3. visible T9 + in-place recovery selecting `rime_ice` → engine, chrome, and controller all become 26-key;
  4. recovery session recreation failure → no stale T9 semantics.

The current reconciliation unit tests only verify the pure `RimeRuntimeSelection.reconciled` value. They do not exercise these engine and extension lifecycle paths.

## Findings closed in this pass

### Production enable transaction — closed

`NineKeyEnableOrchestrator` is the production coordinator used by `SchemaManager.enableNineKeyLayout()`. Its tests execute that same coordinator and cover success ordering plus prepare, deploy, smoke, and fingerprint failures. Every post-transaction failure remains 26-key with unmatched readiness; preconditions correctly avoid beginning asset mutation.

### T9 custom-YAML wiring — closed

`syncCustomYamlFiles()` consumes `planSchemaCustomYamlFiles`. The plan includes `t9.custom.yaml` only when fog-song is installed and maps its user-dictionary preference to `rime_ice`. The plan and resulting file content are covered.

### Handoff whitespace — closed

`git diff --check HEAD` and `git diff --cached --check` are clean at review time.

## Verification performed by Codex

| Check | Result |
|---|---|
| `swift test --package-path Packages/KeyboardCore` | **PASS** — 589 tests, 0 failures |
| Full `RimeBridgeTests` scheme | **PASS** — 31 tests, 0 failures, 3 fixture-dependent skips |
| Full `Universe Keyboard` scheme | **PASS** — `UniverseKeyboardTests` 115 + `KeyboardTests` 6, 0 failures |
| Release simulator build, signing disabled | **PASS** — `BUILD SUCCEEDED` |
| Focused real T9 fixture with runner environment aliases | **PASS** — librime 1.16.1, schema `t9`, raw `64`, 9 candidates, deletion to `6` |
| Worktree/staged whitespace checks | **PASS** |

The main-App test run still emits the repository's existing duplicate Objective-C/Swift runtime-class warnings. No failure occurred, and this review does not attribute those baseline warnings to the 9-key changes.

## Remaining Product Gate evidence

Interactive simulator and physical-device evidence is still absent for layout switching, thumbnail rendering, candidate selection, delete/space/return behavior, persistence, hide/show, recovery, and fallback UX. After the P1 lifecycle gap is fixed, final Product Gate acceptance still requires that human evidence or an explicit Product Lead waiver.

## Grok handoff

1. Close the P1 early-failure and in-place recovery propagation gaps above.
2. Add engine/extension lifecycle tests rather than only pure selection tests.
3. Update `docs/evidence/keyboard-layout-9key-001-implementation-handoff.md` with exact failure-path and propagation evidence.
4. Leave both Codex review documents unchanged and return the updated handoff for another review.
