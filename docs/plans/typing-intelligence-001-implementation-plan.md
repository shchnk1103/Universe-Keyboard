# TYPING-INTELLIGENCE-001 Implementation Plan

> **Status:** Active
>
> **Start date:** 2026-07-11 Asia/Shanghai
>
> **Assignment:** `TYPING-INTELLIGENCE-001`
>
> **Current source of truth:** `docs/TYPING_INTELLIGENCE.md` and ADR 0011
>
> **Archive condition:** Archive after Product Review closes the Assignment and current behavior has moved into architecture/debugging/performance/release sources.

## Delivery Strategy

Work proceeds through independently reviewable gates. A later gate may not reinterpret an earlier Product or Architecture contract.

## Gate 0 — Contract And Baseline

- [x] Product Contract published.
- [x] Assignment published with no `UNKNOWN` field.
- [x] ADR 0011 accepted; implementation pending.
- [x] NE1 isolation boundary recorded.
- [x] Record exact implementation baseline commit and dirty-file exclusions.
- [x] Record the implementation baseline and capture focused synthetic performance evidence where the current environment permits it.
- [x] Inventory privacy manifests and Required Reason APIs.

Exit: implementation can begin without guessing product, data or ownership semantics.

Implementation baseline snapshot:

- Date: `2026-07-11 Asia/Shanghai`
- Commit: `cd31785d00dc234021f44e89b432576b01fe0825`
- Excluded pre-existing changes: `Universe Keyboard.xcodeproj/project.pbxproj`, `docs/PROJECT_CONTEXT.md`, `UniverseKeyboardUITests/`, its shared scheme, all `native-experience-001-*` plans, `ne1-ui-automation-feasibility.md` and `result.json`
- Revalidation: refresh this snapshot if implementation rebases or any excluded file must enter Typing Intelligence scope.

## Gate 1 — KeyboardCore Commit Contract

- [x] Define committed-text event/source contracts.
- [x] Define pure grapheme classification and aggregate delta types.
- [x] Emit from final commit exits with automated exactly-once verification.
- [x] Preserve marked-text, Partial Commit, candidate and RIME design boundaries; full KeyboardCore regression passed.
- [x] Add and execute focused positive and negative tests.

Exit: synthetic tests prove the Core contract independently from UIKit and persistence.

## Gate 2 — Extension Aggregation And Persistence

- [x] Add ordered, non-blocking runtime aggregator.
- [x] Add bounded versioned store protocol and V1 backend.
- [x] Add coalescing, retention and payload bounds.
- [x] Add reset epoch and stale-write rejection.
- [x] Add unavailable/corruption recovery.
- [x] Route Emoji/direct UIKit commits through the single commit contract.
- [x] Verify by code review and synthetic measurement that the key path only classifies and enqueues an in-memory delta.

Exit: controlled Extension integration survives disable, failure and process restart without affecting typing.

## Gate 3 — Main App Experience

- [x] Add shared read/reset/settings model.
- [x] Build disabled, empty, active, unavailable and error states.
- [x] Build today, 7-day, 30-day and all-time summaries.
- [x] Build trend, composition and streak presentations.
- [x] Add privacy explanation and destructive clear confirmation.
- [ ] Verify light/dark, Dynamic Type, VoiceOver and reduced motion.
- [x] Capture and inspect a representative active-state Simulator screenshot; broader appearance coverage remains open.

Exit: the main App presents a complete, native and accessible product rather than a debug dashboard.

## Gate 4 — Privacy, Performance And Release Hardening

- [x] Add privacy manifests for the source-audited Required Reason APIs and validate their presence in built Release bundles.
- [x] Complete source and serialized-payload audits for prohibited content; final Quality recheck pending.
- [x] Run focused and full automated tests plus strict Debug and Release builds.
- [ ] Compare key-path latency and memory against a physical-device baseline; synthetic Release evidence is recorded separately.
- [x] Verify 365-bucket retention and bounded compaction with automated store tests.
- [ ] Verify Full Access on/off and process-death behavior on a physical device.
- [x] Update current architecture, debugging, performance and release sources.
- [x] Record the implemented, not-yet-released behavior in `CHANGELOG.md`.
- [ ] Audit NE1 files and evidence for contamination.

Exit: Quality Review has enough evidence to issue an explicit conclusion.

Automated performance evidence: [`typing-intelligence-001-performance-evidence.md`](../evidence/typing-intelligence-001-performance-evidence.md). Its PASS conclusion is limited to the synthetic gate and does not close physical-device release acceptance.

## Gate 5 — Reviews And Closure

- [x] Architecture Review: PASS for ADR 0011 conformance.
- [x] Quality Review: automated implementation evidence passed; release acceptance BLOCKED by the recorded physical-device and accessibility/appearance gates.
- [ ] Product Review.
- [ ] Program Manager Dashboard synchronization.
- [ ] Archive this plan with current-source links.

Review record: [`typing-intelligence-001-review-record.md`](../evidence/typing-intelligence-001-review-record.md).

## Initial File Ownership Map

| Area | Expected files/modules |
|---|---|
| Core contracts | `Packages/KeyboardCore/Sources/KeyboardCore/` |
| Core tests | `Packages/KeyboardCore/Tests/KeyboardCoreTests/` |
| Extension wiring | `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`, input/Emoji actions, new bounded service files |
| Main-App model/store | `Universe Keyboard/Models/` or `Universe Keyboard/Services/` |
| Main-App UI | `Universe Keyboard/Views/Settings/` and reusable components |
| Privacy | target `PrivacyInfo.xcprivacy` files and submission documentation |
| Current contracts | typing-intelligence, architecture, debugging, performance and release documents |

This map is directional, not permission to modify unrelated code. Existing user changes remain untouched.
