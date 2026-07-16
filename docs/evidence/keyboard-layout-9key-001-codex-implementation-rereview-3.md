# KEYBOARD-LAYOUT-9KEY-001 — Codex Implementation Re-review 3

Reviewer: Codex

Date: 2026-07-16 Asia/Shanghai

Branch: `feature/keyboard-layout-9key-spike`

Reviewed HEAD: `b203ba0` plus Grok's uncommitted implementation changes

Primary handoff: `docs/evidence/keyboard-layout-9key-001-implementation-handoff.md`

Previous review: `docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview-2.md`

## Review result

**Code Review Approved — no blocking implementation findings.**

The P1 lifecycle gap from re-review 2 is closed:

- `RimeEngineImpl` now publishes a fail-closed realized selection before every relevant resume/recovery early return: resume runtime/session initialization failure, resume schema-selection failure, and recovery session-recreation failure.
- Every realized or fail-closed publication updates `runtimeSelection` and invokes `onRuntimeSelectionChanged`.
- The extension wires that callback when creating the engine, applies the published selection to chrome and `KeyboardController`, and reloads the key grid only when the observed layout or T9 semantics change.
- The controller also synchronizes semantics after resume and in-place recovery, covering the path where recovery is initiated while the keyboard remains visible.
- `RealizedSelectionLifecycleTests` cover prior T9 followed by resume initialization failure, resume schema-selection failure, in-place recovery to `rime_ice`, recovery-session failure, and the controller rebuild path.

The production enable transaction, T9 custom-YAML plan/synchronization, and handoff whitespace fixes remain correctly closed.

## Verification performed by Codex

| Check | Result |
|---|---|
| `swift test --package-path Packages/KeyboardCore` | **PASS** — 594 tests, 0 failures |
| Full `Universe Keyboard` scheme on iOS Simulator | **PASS** — `UniverseKeyboardTests` 115 + `KeyboardTests` 6, 0 failures |
| Full `RimeBridgeTests` scheme on iOS Simulator | **PASS** — 31 tests, 0 failures, 3 fixture-dependent skips |
| Release simulator build, signing disabled | **PASS** — `BUILD SUCCEEDED` |
| `git diff --check HEAD` and staged whitespace check | **PASS** |

The main-App suite continues to emit pre-existing duplicate runtime-class warnings for bundled test code; the suite still passes, and this review found no evidence that the 9-key change introduced them.

## Gate boundary

This approves the **implementation/code-review gate only**. It does not close the Product Gate or Assignment lifecycle.

Still required before final product acceptance:

1. Interactive simulator or physical-device proof for switching 26/9-key layout, thumbnails, digit input, candidates, deletion, space/return, persistence, hide/show, recovery, and fallback UX.
2. Light/dark compact screenshot evidence, or an explicit Product Lead waiver.
3. Product Lead decision on the remaining human-dependency evidence.

## Grok handoff

The code findings are closed. Grok may prepare the scoped implementation commit, retaining this and the two prior Codex review documents as evidence. Do not claim final Product Gate acceptance until the human evidence above is supplied or explicitly waived.
