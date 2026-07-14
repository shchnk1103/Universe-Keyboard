# Assignment: NATIVE-EXPERIENCE-003 — Keyboard Input Hot-Path Optimization

**Policy version:** `1.0.0`

**Decision source / date:** Human Product Owner authorization in the active performance objective / `2026-07-13 Asia/Shanghai`

**Lifecycle status:** `Completed`

**Repository change types:** `Implementation`, `Evidence`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Product Approver:** Product Lead acting under the human owner's explicit authorization to implement the two accepted P0 recommendations
- **Assignment Revalidation Authority:** Product Lead
- **Product source:** Current keyboard interaction behavior plus the accepted Extension performance measurement contract

## Acknowledgement And Activation

- **Executor acknowledgement:** `2026-07-13 Asia/Shanghai` — Scope, Non-goals and Stop Conditions accepted.
- **Architecture acknowledgement:** The task preserves UIKit hit-test geometry, KeyboardCore input semantics and the existing main-thread RIME session boundary.
- **Quality acknowledgement:** Focused logger tests and Debug/Release builds are required; physical-device latency conclusions remain with the human owner and Quality reviewer.
- **Product lifecycle decision:** `Ready -> Active`, `2026-07-13 Asia/Shanghai`.

## Assignment

- **Domain Owner:** Keyboard Experience Maintainer
- **Executor:** Keyboard Experience Maintainer, coordinating the bounded KeyboardCore logger-writer work package
- **Environment Executor:** Quality, Performance & Release Maintainer for automated test/build evidence; human owner for physical-device performance evidence
- **Human Dependency:** Human owner with the current physical iPhone for before/after touch latency and sustained-input validation
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer
- **Product Approver:** Product Lead
- **Handoff Target:** Human owner for device validation, followed by Product Lead for acceptance

## Objective

Remove confirmed redundant work from the direct key-touch path and prevent routine Release diagnostics from generating per-key formatting, queue and whole-log persistence work.

## Scope

1. Compute keyboard key touch cells once per layout pass and reuse the resulting snapshot during hit testing.
2. Preserve the existing continuous gap coverage and exact key-selection behavior.
3. Keep detailed successful key/candidate timing diagnostics in Debug builds while retaining slow/failure warnings in Release.
4. Batch enabled diagnostic records on the existing ordered utility writer and persist each batch with one read/trim/write cycle.
5. Add focused logger-writer tests and perform Debug/Release build validation.

## Non-goals

- No candidate data-source, paging, sizing or memory-warning optimization.
- No visual geometry, spacing, animation, key appearance or accessibility change.
- No input, candidate, Delete, Space, Return or marked-text semantic change.
- No RIME thread, session, deployment, schema or recovery change.
- No audio/haptic behavior change.
- No numeric performance acceptance claim without comparable physical-device evidence.
- No modification or reinterpretation of NATIVE-EXPERIENCE-001 evidence.
- No unrelated refactor and no overwrite of unrelated dirty-worktree changes.

## Required Inputs

- `AGENTS.md`
- `docs/ASSIGNMENT_POLICY.md`
- `docs/PROJECT_CONTEXT.md`
- `docs/PERFORMANCE_BASELINE.md`
- `docs/TECH_DEBT.md` TD-003
- `docs/RELEASE_CHECKLIST.md`
- `docs/playbooks/keyboard-ui.md`
- current keyboard hit-test, input diagnostics and KeyboardCore logger-writer sources

## Entry Criteria

- Human owner has explicitly approved implementation of both P0 recommendations.
- Assignment contains no `UNKNOWN` field.
- The touch-cell optimization can preserve the current layout-derived geometry.
- Release diagnostics retain actionable slow and failure events.
- Unrelated worktree changes can remain untouched.

## Exit Criteria

- A normal hit test does not recursively rediscover and sort all keys or restyle touch backing views.
- Touch-cell frames and expanded button outsets are regenerated after layout.
- Routine successful key/candidate timing logs do not enter the Release input path.
- Enabled diagnostics preserve FIFO order and bounded storage while coalescing multiple records into one persistence cycle.
- Focused logger tests and required Debug/Release builds pass, or blockers are recorded exactly.
- Documentation impact and changelog review are complete.
- Physical-device verification steps and residual risks are handed off explicitly.

## Stop Conditions

Stop and return to the owning authority if:

- caching requires changing key hit regions or candidate-bar gesture ownership;
- Release failure or slow-path diagnostics cannot be retained;
- logger batching requires synchronous waiting from the input thread;
- unrelated dirty changes must be overwritten;
- automated validation exposes a product/runtime failure outside this scope;
- final physical-device performance acceptance is requested without comparable device evidence.

## Verification Matrix

- Focused KeyboardCore logger ordering, filtering, bounding, non-blocking and batching tests.
- Debug and Release Simulator builds with Swift 6 warnings as errors.
- Source inspection confirming routine key/candidate diagnostics are Debug-only and Release slow warnings remain.
- Physical iPhone: key-edge and key-gap hit behavior on all pages.
- Physical iPhone: controlled continuous English and Chinese input before/after comparison.
- Physical iPhone: diagnostics disabled/enabled comparison without private input content.

## Handoff

Provide changed-file inventory, automated command results, skipped physical-device evidence, exact device scenarios, residual risk, documentation impact and confirmation that NATIVE-EXPERIENCE-001 files were not modified.

## Completion Record

- **Executor completion:** `2026-07-13 Asia/Shanghai` — Both bounded P0 implementation items are complete.
- **Touch-path evidence:** `KeyboardInputHitAreaStackView` now rebuilds its layout-derived touch-cell snapshot once in `layoutSubviews()` and uses that snapshot during normal hit testing. Candidate-bar gap ownership and existing expanded button outsets remain unchanged.
- **Diagnostic-path evidence:** Routine successful key, candidate refresh, candidate paging and expanded-panel diagnostics are Debug-only. Release retains slow-key, slow-candidate and failure warnings.
- **Writer evidence:** The ordered asynchronous writer batches up to 32 pending records or 250 ms, then performs one format/read/trim/write cycle. Explicit flush, clear, category filtering, FIFO order and bounded persisted storage remain covered.
- **Automated verification:** Focused `LoggerTests` passed `12/12`; full `KeyboardCore` tests passed `545/545`; Debug and Release generic iOS Simulator builds passed with Swift concurrency warnings treated as errors.
- **Release artifact inspection:** Detailed success strings such as `KEY BEGIN`, `KEY END`, candidate refresh totals and paging start markers are absent from the Release keyboard executable; retained slow-candidate warnings remain present.
- **Known environment note:** Existing RimeBridge vendor XCFramework x86_64 compatibility notes were emitted by both builds; they did not fail compilation or linking and are outside this Assignment.
- **Physical-device evidence:** Not executed in this environment. Human validation remains required for key edges/gaps across pages and controlled sustained English/Chinese input before Product acceptance of the performance outcome.
- **Documentation impact:** `CHANGELOG.md` and this Assignment were updated. No architecture invariant or UI style contract changed, so no ADR or architecture document update is required.
- **Scope confirmation:** NATIVE-EXPERIENCE-001 protocol and evidence files were not modified by this implementation.
- **Product lifecycle decision:** `Active -> Completed`, with physical-device outcome acceptance handed to the human owner, `2026-07-13 Asia/Shanghai`.

## Revalidation Trigger

Product and Architecture revalidation are required if the task changes touch geometry, candidate gesture ownership, input semantics, RIME ownership/threading, diagnostic privacy, or the named owners/reviewers.
