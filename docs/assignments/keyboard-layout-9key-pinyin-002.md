# Assignment: KEYBOARD-LAYOUT-9KEY-PINYIN-002 — 九宫格精准选项与选拼音循环

**Policy version:** `1.0.0`  
**Lifecycle status:** `Active — Amendment B local implementation; review/Product Gate pending`
**Repository change types:** `Contract`, `State`, `Implementation`, `Evidence`, `Documentation`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-002`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md), `2026-07-19 Asia/Shanghai`
- **Product Approver:** Product Lead under KOS 2.0
- **Related Closed predecessor:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-001`](keyboard-layout-9key-pinyin-001.md)
- **Required Architecture Decision:** [ADR 0021](../architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md)

## Acknowledgement And Lifecycle

- Human Product Owner explicitly approved continuation under KOS 2.0 on `2026-07-19 Asia/Shanghai`.
- Assignment Decision is complete; no required field is `UNKNOWN`.
- Executor acknowledges Scope, Non-goals, phase gates, and Stop Conditions.
- Lifecycle advanced `Assignment Required -> Assigned -> Acknowledged -> Ready -> Active` on `2026-07-19 Asia/Shanghai`.
- Phase 1 ADR accepted and Phase 2 Spike passed on `2026-07-19 Asia/Shanghai`.
- Phase 3 KeyboardCore and Phase 4 Keyboard UI implementation completed locally; focused/full Core tests, RimeBridgeTests, main scheme Simulator tests, and Debug/Release strict builds passed. Phase 5 remains `Active` for independent handoffs, clean-commit evidence, and physical-device Product Gate.
- Human Product Owner authorized Amendment A segmented disambiguation on `2026-07-19 Asia/Shanghai`. Its real-RIME hard gate passed, and the bounded Core/UI implementation plus automated validation completed locally; independent review and physical-device Product Gate remain open.

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer — choice/cycle state, refinement transaction, lifecycle invariants
- **Executor:** Codex — bounded implementation and documentation within this Assignment
- **Supporting domains:**
  - 🔧 RIME Platform Maintainer — pinned-librime Spike and session evidence
  - ⌨️ Keyboard Experience Maintainer — path-bar rendering, button forwarding, accessibility
- **Environment Executor:** Codex for local Spike preparation, Simulator tests/builds, and evidence packaging; Human Product Owner for physical-device Product Gate capture
- **Human Dependency:** Human Product Owner — physical-device native comparison and final product acceptance
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward through a separate review handoff
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer through a separate review handoff
- **Handoff Target:** Architecture and Quality review after implementation; Product Lead after physical-device evidence

## Boundary

### Scope

1. Publish this Product Decision, Assignment, ADR 0021, and KOS navigation/status mirrors.
2. Extend KeyboardCore precise-path state to preserve an authorized displayed choice set and cycle selection across successful `replaceInput` refinement.
3. Provide deterministic single-digit key-group choices using one canonical T9 key-identity mapping.
4. Continue using current compatible RIME comments for multi-key full paths.
5. Add a Core-owned next-choice action; route direct tap and **选拼音** cycling through the same transactional selection path.
6. Replace **选拼音** full-panel presentation with first/next/wrap selection behavior.
7. Preserve no-raw-host-commit, rollback, stale-state invalidation, session-only Extension, and bounded hot-path contracts.
8. Add focused KeyboardCore tests, real RimeBridge Spike coverage, Keyboard UI/contract coverage, strict Simulator builds, documentation, changelog, and Product Gate handoff.
9. Amendment A: add whole-composition versus segmented modes; retain a focused tentative segment across later digit groups; confirm/advance by tapping the already selected path; display the next segment's RIME-authorized choices; show **选定** on active T9 composition while preserving candidate commit semantics.

### Non-goals

- Every Non-goal in the linked Product Decision
- Unrelated candidate-bar, keyboard-layout, settings, typo-correction, or RIME deployment refactors
- Reopening or rewriting the Closed `001` Assignment
- Claiming Architecture, Quality, or Product acceptance from implementation alone

### Required Inputs

- Linked Product Decision and this Assignment
- ADR 0018, ADR 0020, proposed ADR 0021
- `KEYBOARD_LAYOUT.md`, input-pipeline architecture, UI style guide, debugging and release checklist
- KeyboardCore, RimeBridge, Keyboard UI, Test/Release, Coordinator, and Documentation playbooks
- Pinned librime `1.16.1`, compatible deployed `t9` fixture, existing T9 Spike harness
- User-provided three screenshots as Product reference inputs; repository evidence must record behavior without depending on temporary clipboard paths

## Gates

### Entry Criteria

| Criterion | Status |
|---|---|
| Stable Product Decision | **Met** |
| Required Assignment fields complete | **Met — no `UNKNOWN`** |
| Single Domain Owner | **Met** |
| Closed predecessor preserved | **Met** |
| Phase-specific Stop Conditions explicit | **Met** |

### Phase Gates

| Phase | Entry condition |
|---|---|
| 1 — Contract / ADR | Assignment `Active` |
| 2 — Real RIME Spike | ADR 0021 Proposed; pinned fixture available |
| 3 — KeyboardCore tests/implementation | Spike proves `m/n/o`; ADR 0021 Accepted |
| 4 — Keyboard UI | Core focused tests green |
| 5 — Integrated validation/docs | Core/UI implementation complete |
| Product Gate | Independent Architecture + Quality handoffs complete; Human Dependency device comparison captured |

Amendment A repeats Phase 1 Contract/ADR and Phase 2 real-RIME Spike before any segmented Core/UI implementation. Earlier baseline implementation evidence does not waive the new gate.

### Exit Criteria

- ADR 0021 Accepted and linked from domain authority
- Real Spike evidence proves all single-digit `6` choices are safe refinements
- Focused and full KeyboardCore tests pass
- RimeBridge Simulator tests and affected Debug/Release builds pass
- UI shows `m/n/o`, direct selection, `m -> n -> o -> m` cycling, and selected accessibility state
- Lifecycle and rollback regression matrix passes
- `KEYBOARD_LAYOUT.md`, input pipeline, UI guide, release checklist, Dashboard, Knowledge Index, and changelog are synchronized
- Independent Architecture and Quality conclusions are recorded
- Physical-device Product Gate is decided by Product Lead

### Stop Conditions

Stop and return to Architecture/Product Lead when:

1. Any Assignment field becomes `UNKNOWN` or authority conflicts appear.
2. Pinned librime cannot safely refine any displayed `m/n/o` choice without commit or candidate loss.
3. Meeting the behavior requires librime upgrade, schema mutation, Extension deployment, or a second pinyin/candidate engine.
4. Cycle state cannot be invalidated safely across Delete, new key, commit, page/language, visibility, fallback, or recovery.
5. Production implementation begins before Spike PASS and ADR acceptance.
6. Unbounded path probing, synchronous persistence, private host-text logging, or raw-input host commit is introduced.
7. Automated evidence is presented as physical-device Product acceptance.

## Handoff

- **Current phase:** Amendment B local implementation complete; independent review and physical-device Product Gate next (covers A+B)
- **Completed gate evidence:** [`keyboard-layout-9key-pinyin-002-spike-summary.md`](keyboard-layout-9key-pinyin-002-spike-summary.md) — librime `1.16.1`, deterministic `m/n/o`, candidate counts `9/9/4`, no host commit
- **Local implementation evidence:** focused `T9PinyinPathTests` passed (`27`, zero failures); KeyboardCore full suite passed; RimeBridgeTests and main scheme Simulator tests passed; Debug/Release generic iOS Simulator builds passed with strict concurrency and warnings-as-errors. Counts describe this local run only and are not release invariants.
- **Known environment skips:** the default RimeBridgeTests run skipped four fixture-gated real-runtime cases as designed; the new `m/n/o` real T9 case was separately executed with explicit fixture and passed under the tracked Spike summary.
- **Acceptance clarification fix:** visible preferred-candidate-style path highlight plus exact selected-path marked text are implemented. Focused path tests, KeyboardCore full suite, main scheme Simulator tests, and Debug/Release strict builds were refreshed after the fix and passed.
- **Pending validation:** clean-commit Spike re-run; independent Architecture/Quality conclusions; physical-device Product Gate.
- **Amendment A evidence:** [`keyboard-layout-9key-pinyin-002-native-segmented-observation.md`](keyboard-layout-9key-pinyin-002-native-segmented-observation.md)
- **Amendment A Spike:** [`keyboard-layout-9key-pinyin-002-segmented-spike-summary.md`](keyboard-layout-9key-pinyin-002-segmented-spike-summary.md) — PASS; `authorizedSuffixes=g|h`, with fallback-only `i` rejected.
- **Amendment A local validation:** focused path tests `34/34`; KeyboardCore full suite `628/628`; main App + Extension Debug and Release strict generic-Simulator builds PASS. Interactive product comparison remains pending.
- **Amendment B (2026-07-20):** Product authorized progressive first-syllable compact paths + syllable-level confirm/advance; multi-syllable whole labels banned from path bar; UI single-line defense; direct path tap confirms/advances immediately while **选拼音** only cycles tentative selection. Focused `T9PinyinPathTests` `39/39` PASS.
- **Independent Architecture Review (2026-07-21):** [Pass with mandatory Quality and physical-device follow-up](../evidence/keyboard-layout-9key-pinyin-002-architecture-review-2026-07-21.md). This does not close the Assignment or replace Quality/Product Gate evidence.
- **Review handoff:** [`keyboard-layout-9key-pinyin-002-review-handoff.md`](keyboard-layout-9key-pinyin-002-review-handoff.md)
- **Human Product Gate handoff:** [`keyboard-layout-9key-pinyin-002-product-gate-human-handoff.md`](keyboard-layout-9key-pinyin-002-product-gate-human-handoff.md)
- **Required handoff content:** changed behavior/files, state-transition examples, exact commands/results, skipped validation, Stop Condition status, docs impact, and physical-device matrix
- **Revalidation Trigger:** librime/T9 schema change; choice-source or cycle-order change; panel restoration; new multi-digit generation strategy; lifecycle/session contract change; scope expansion

## Completeness Checklist

| Required field | Value |
|---|---|
| Task ID / Title | `KEYBOARD-LAYOUT-9KEY-PINYIN-002` / 九宫格精准选项与选拼音循环 |
| Assignment Authority | Product Lead |
| Decision Source / Date | `PD-...-002`, `2026-07-19 Asia/Shanghai` |
| Domain Owner | Input Intelligence Maintainer |
| Executor | Codex |
| Environment Executor | Codex local/Simulator; Human Product Owner device |
| Human Dependency | Human Product Owner |
| Architecture Reviewer | Architecture & Knowledge Steward, separate handoff |
| Quality Reviewer | Quality, Performance & Release, separate handoff |
| Product Approver | Product Lead |
| Required Inputs | Present |
| Entry / Exit / Stop Conditions | Present |
| Handoff Target | Present |
| Revalidation Trigger | Present |
| Any `UNKNOWN` | **None** |
