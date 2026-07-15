# Assignment: TYPO-CORRECTION-003 — Progressive Multi-error Recall Preflight

**Policy version:** `1.0.0`

**Lifecycle status:** `Completed`

**Repository change types:** `Contract`, `Implementation`, `Evidence`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner continuation instruction in Codex task `019f6101-b9db-7821-9db6-ca288d9e1189` / `2026-07-15 Asia/Shanghai`
- **Product Approver:** Product Lead acting under the human owner's explicit delegation
- **Product Contract:** [`docs/TYPO_CORRECTION.md`](../TYPO_CORRECTION.md) V2.2

## Boundary

- **Scope:** Publish the progressive-recall product and architecture increment; implement a pure, default-off two-edit search plan with bounded first-layer retention, final hypothesis count and batch size; prove that the canonical separated two-error input reaches the recall pool; record the next real-RIME scoring and performance Gate.
- **Non-goals:** Production controller/UI wiring; additional sidecar queries; cross-input interpretation of librime `Candidate::quality`; model download or bundled language-model assets; schema/weight/user-dictionary changes; more than two edits; persistence; host context; network; Product or Quality acceptance.
- **Required Inputs:** `TYPO_CORRECTION.md`; ADR 0015 and 0016; `TYPO_BENCHMARK_REGISTRY_V2.md`; `TYPO-CORRECTION-002`; `PERFORMANCE_BASELINE.md`; current contextual typo implementation and tests.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer
- **Executor:** Input Intelligence Maintainer
- **Environment Executor:** `Not Applicable — pure KeyboardCore planning and repository evidence only`
- **Human Dependency:** `Not Applicable — the human owner explicitly authorized continuation under KOS 2.0`
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer
- **Product Approver:** Product Lead
- **Handoff Target:** `TYPO-CORRECTION-002` Product/Architecture revalidation for any real-RIME or production wiring

## Gates

### Entry Criteria

- V2.1 Product Decision and ADR 0016 are published.
- This Assignment contains no `UNKNOWN` field.
- V2.0 production query and UI paths remain unchanged.

### Exit Criteria

- The canonical `wimenjintianquhongyuan → womenjintianqugongyuan` hypothesis appears in the bounded recall plan without an allowlist.
- The plan contains at most 64 hypotheses and every batch contains at most eight.
- Existing V2.0 12-state/eight-hypothesis behavior remains covered and unchanged.
- Focused and full KeyboardCore tests pass.
- Documentation and Dashboard state distinguish recall evidence from semantic or runtime acceptance.

### Stop Conditions

- Implementation requires a production query/UI change.
- Implementation assumes librime quality is comparable across different input codes.
- Search becomes unbounded, enters the synchronous key path or persists input/candidates.
- A test requires hardcoding the expected corrected sentence into production generation logic.
- Real-RIME, performance or device conclusions are requested from pure/Fake Provider evidence.

## Handoff

- **Required Handoff Content:** changed-file inventory, recall/batch bounds, canonical-case result, focused/full test results, unchanged production-path evidence and residual scoring gap.
- **Revalidation Trigger:** any change to edit depth, production default, query count, scoring source, RIME/session ownership, data boundary or Product Contract.

## Completion Record

- The pure planner retains at most 60 first-layer states, 64 final hypotheses and eight hypotheses per batch.
- `wimenjintianquhongyuan → womenjintianqugongyuan` is present in the bounded plan without a production allowlist.
- Source audit confirms that production controller/UI code still instantiates the V2.0 default 12-state/eight-hypothesis engine and does not reference the progressive planner.
- Focused typo-correction tests and the full KeyboardCore suite passed on 2026-07-15; semantic scoring, real-RIME execution, performance and Product acceptance remain with `TYPO-CORRECTION-002`.
