# Assignment: TYPO-CORRECTION-002 — Contextual Multi-Error Pinyin Recovery

**Policy version:** `1.0.0`

**Lifecycle status:** `Active`

**Repository change types:** `Contract`, `Implementation`, `Evidence`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner authorization in Codex task `019f6101-b9db-7821-9db6-ca288d9e1189` / `2026-07-14 Asia/Shanghai`; designated simulator clarification / `2026-07-15 Asia/Shanghai`
- **Product Approver:** Product Lead acting under the human owner's explicit delegation
- **Product Contract:** [`docs/TYPO_CORRECTION.md`](../TYPO_CORRECTION.md)

## Boundary

- **Scope:** Replace the fallback-only typo-correction candidate query with a bounded real-RIME sidecar query session; add bounded multi-error pinyin hypothesis generation and sentence-candidate ranking; add contracts, tests, benchmark cases, performance evidence and acceptance on the designated Device Hub iOS 27 iPhone 17 Pro Max simulator.
- **Non-goals:** Network/cloud correction; host context; automatic commit; RIME schema/weight/user-dictionary changes; unbounded search; input-history persistence; changes to `TYPING-INTELLIGENCE-001`; substituting another simulator or physical device for the designated Device Hub target.
- **Required Inputs:** `TYPO_CORRECTION.md`; ADR 0002, 0004, 0008, 0009, 0010 and 0015; `TYPO_BENCHMARK.md`; `TYPO_BENCHMARK_REGISTRY.md`; `PERFORMANCE_BASELINE.md`; `DEBUGGING.md`; `RELEASE_CHECKLIST.md`; current KeyboardCore/RimeBridge source and tests.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer
- **Executor:** Input Intelligence Maintainer, acting through bounded RIME Platform and Keyboard Experience work packages
- **Environment Executor:** Quality, Performance & Release Maintainer for automated evidence and Device Hub iOS 27 iPhone 17 Pro Max validation
- **Human Dependency:** `Not Applicable — the human owner delegated Product and execution decisions and clarified that the designated Device Hub target is a simulator.`
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer
- **Product Approver:** Product Lead
- **Handoff Target:** Product Lead for Product Review, then Program Manager for source-linked Dashboard synchronization

## Gates

### Entry Criteria

- Product Contract and ADR 0015 are accepted.
- This Assignment has no `UNKNOWN` field.
- The implementation plan defines a bounded query/search budget and negative cases.
- The active composition/session boundary remains unchanged before implementation starts.

### Exit Criteria

- Real RIME sidecar queries are isolated from the live session and verified by tests.
- Multi-error hypotheses and candidate ranking are bounded, tested and default-safe.
- Registry and benchmark cases distinguish single-edit legacy behavior from V2 multi-error behavior.
- Focused and full affected-package tests pass, along with Debug and Release builds.
- Performance evidence records the required environment and comparison results.
- Device Hub iOS 27 iPhone 17 Pro Max acceptance records candidate recovery and interaction regression results.
- Documentation, changelog and Dashboard impacts are complete.

### Stop Conditions

- A design requires mutating the live composition to query a hypothesis.
- A design requires raw sentence persistence, host context, network or synchronous key-path I/O.
- Search/query work cannot be bounded or produces unexplained normal-input regressions.
- The designated Device Hub iOS 27 iPhone 17 Pro Max simulator is unavailable or its runtime/build identity cannot be verified.
- An Accepted ADR or this Assignment requires revalidation.

## Handoff

- **Required Handoff Content:** changed-file inventory, candidate/session boundary evidence, benchmark results, performance evidence, Device Hub result, residual risks and documentation impact.
- **Revalidation Trigger:** any change to data retention, learning semantics, query-session lifecycle, RIME/session ownership, default promotion, device constraint or Product Contract.
