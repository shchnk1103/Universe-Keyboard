# KEYBOARD-LAYOUT-9KEY-001 — Codex Implementation Re-review

Reviewer: Codex

Date: 2026-07-16 Asia/Shanghai

Branch: `feature/keyboard-layout-9key-spike`

Reviewed HEAD: `b203ba0` (`fix(9key): close Codex implementation review P1/P2 findings`)

Primary handoff: `docs/evidence/keyboard-layout-9key-001-implementation-handoff.md`

## Review result

**Changes Required — implementation is not accepted yet.**

The previous review's four implementation directions are materially improved: runtime selection now retains the real shared data directory across cold start, resume, and recovery; input semantics have an explicit flag; the main-App transaction fails closed before deployment work; and a T9 custom YAML is generated. The pinned-librime T9 fixture also passes.

However, the requested/effective selection is still not reconciled with the schema that librime actually selected after fallback. This can leave the visible keyboard and controller in 9-key/T9 mode while the engine is running `rime_ice`. Two new tests also simulate the intended order or test a generic helper instead of exercising the production wiring, so they do not protect the claimed fixes from regression.

## Findings

### P1 — Actual schema fallback does not fail the visible layout and input semantics closed

Evidence:

- `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl.swift:98-105` stores the readiness-derived selection before `selectSchemaForStartup`, then records the fallback in `activeSchemaID` without replacing `runtimeSelection`.
- The resume path repeats this split at `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl.swift:217-230`.
- Recovery repeats it at `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+SessionRecovery.swift:30-35`.
- `Keyboard/Controllers/KeyboardViewController+Feedback.swift:116-130` chooses both chrome and controller semantics from defaults plus readiness, before knowing what schema librime actually selected.
- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift:143-149` installs the engine but does not reconcile `engine.activeSchemaID` back into `cachedLayoutStyle` or `controller.usesT9InputSemantics`.

Failure mode:

1. The readiness marker and on-disk fingerprint match, so the extension resolves `t9` and renders 9-key chrome.
2. librime cannot select or retain `t9`, so `selectSchemaForStartup` falls back to `rime_ice`.
3. `activeSchemaID` says `rime_ice`, but `runtimeSelection`, the visible layout, and `usesT9InputSemantics` still say T9.
4. Digit/T9 input policy is then applied against a non-T9 schema.

This violates ADR 0018's single effective-selection/fail-closed boundary. A marker match proves that a prepared artifact is eligible; it does not prove that the current librime session actually selected it.

Required change:

- Represent the **realized runtime selection** after schema selection, not only the requested selection.
- If requested T9 is not the schema actually selected, force the observable layout and input semantics to 26-key for that runtime lifecycle. The extension must still not deploy or mutate RIME assets.
- Propagate the realized selection after cold activation, resume, and session recovery.
- Add regression coverage for `requested=t9, actual=fallback` and verify that schema, chrome, and input semantics all converge to the same fail-closed state.

### P2 — Transaction tests simulate the contract instead of testing the production transaction

Evidence:

- `UniverseKeyboardTests/NineKeyEnableTransactionTests.swift:27-29` explicitly says it is simulating `beginNineKeyEnableTransaction`, then directly calls the two persistence helpers.
- `UniverseKeyboardTests/NineKeyEnableTransactionTests.swift:48-70` manually reconstructs the desired success order; it never calls the production enable flow and cannot inject preparation, deployment, smoke-test, or fingerprint failures.

These tests remain green if the production transaction is removed, reordered, or bypassed. Therefore they do not substantiate the handoff's failure-path closure claim.

Required change:

- Exercise the production transaction/enable orchestration through injectable dependencies, or extract a production coordinator that the tests call directly.
- Cover failures at preparation, deployment, runtime smoke, and final fingerprint/marker validation.
- Assert every failure leaves layout at 26-key with unmatched readiness, and assert the success path writes matched readiness before publishing 9-key.

### P2 — The T9 custom-YAML test does not cover T9 file wiring

Evidence:

- `Packages/RimeBridge/Tests/RimeBridgeTests/RimeRuntimeSelectionBridgeTests.swift:84-100` only calls the generic `makeSchemaCustomYamlContent` helper.
- It does not execute the production custom-file synchronization, assert that `t9.custom.yaml` exists, or prove that T9 receives the `rime_ice` user-dictionary preference.

The T9 mapping or conditional write can regress while this test remains green.

Required change:

- Add a filesystem-level production-path test, or extract a pure custom-file plan returning the schema-to-content mapping and test that production plan.
- Verify `t9.custom.yaml` is generated only when appropriate and that its user-dictionary setting follows the `rime_ice` preference.

### P3 — The reviewed handoff fails repository whitespace validation

`git diff --check origin/main...HEAD` reports trailing whitespace at `docs/evidence/keyboard-layout-9key-001-implementation-handoff.md:3-6`.

Required change: remove the Markdown hard-break spaces or replace them with blank-line-separated metadata so the repository diff check passes.

## Verification performed by Codex

| Check | Result |
|---|---|
| `swift test --package-path Packages/KeyboardCore` | **PASS** — 586 tests, 0 failures |
| Full `RimeBridgeTests` scheme on iOS Simulator | **PASS** — 29 executed, 0 failures, 3 skipped in the unconfigured full-suite run |
| Full `Universe Keyboard` scheme on iOS Simulator | **PASS** — `UniverseKeyboardTests` 110 + `KeyboardTests` 6, 0 failures |
| Release simulator build with signing disabled | **PASS** — `BUILD SUCCEEDED` |
| Focused real T9 fixture with shared/user runtime environment injected | **PASS** — librime 1.16.1, schema `t9`, raw `64`, 9 candidates, deletion to `6` |
| `git diff --check origin/main...HEAD` | **FAIL** — trailing whitespace in the implementation handoff lines 3-6 |

The first focused T9 invocation omitted the XCTest runner environment aliases and therefore skipped. Codex reran it with host, `TEST_RUNNER_`, and `SIMCTL_CHILD_` variables; that execution ran rather than skipped and passed.

## Remaining product evidence

The handoff still records no interactive simulator or physical-device evidence for switching layouts, rendering the thumbnail choices, typing digits, candidate selection, deletion, persistence across relaunch, or fallback UX. Automated green status does not replace that Product Gate evidence. After the code findings are closed, provide simulator/device evidence or obtain an explicit Product Lead waiver before final acceptance.

## Grok handoff

1. Fix P1 by reconciling requested T9 with the schema actually selected and propagate one fail-closed realized selection to the engine, chrome, and input policy across cold start, resume, and recovery.
2. Replace the simulated transaction tests with production-path failure-matrix coverage.
3. Add production-wiring coverage for `t9.custom.yaml` and the `rime_ice` preference mapping.
4. Remove the handoff trailing whitespace.
5. Update `docs/evidence/keyboard-layout-9key-001-implementation-handoff.md` with exact code/test evidence and return it to Codex for another review.
