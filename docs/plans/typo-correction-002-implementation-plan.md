# TYPO-CORRECTION-002 Implementation Plan

> **Status:** Active — Core/bridge and iOS UI baseline evidence captured; contextual UI and Device Hub acceptance pending
>
> **Assignment:** [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md)
>
> **Current source of truth:** [`Contextual Typo Correction Product Contract`](../TYPO_CORRECTION.md) and [ADR 0015](../architecture/decisions/0015-contextual-multi-error-typo-correction.md)

## Work Packages

1. **RIME query boundary** — add a lazy sidecar session that can evaluate a corrected pinyin input without touching the live session.
2. **Core hypothesis search** — generate an ordered, bounded set of one- and multi-edit hypotheses from safe touch-key operations.
3. **Candidate integration** — make the controller prefer real-RIME query results and retain the fallback provider only for test/degraded paths.
4. **Benchmark and regression** — add synthetic phrase/sentence cases, normal/dangerous negatives, session-isolation and UI semantics tests.
5. **Evidence** — collect performance and Device Hub iOS 27 iPhone 17 Pro Max results, then hand off for Product Review.

## Current Execution Record

1. **Completed:** `RimeSessionManager` now owns a lazy sidecar session and destroys/restarts it with the live session.
2. **Completed:** KeyboardCore has a bounded two-edit hypothesis engine and an explicit corrected-input query protocol; multi-edit output is display-only.
3. **Completed:** production bootstrap injects `RimeEngineImpl` into that query seam, while fallback remains degraded/test-only.
4. **Partial:** KeyboardCore focused/full tests, iOS Debug/Release builds, RimeBridge contract tests, and the 2026-07-15 iOS 27 iPhone 17 Pro Max Simulator UI baseline (8 passed, 1 designed skip) passed. The runtime-fixture smoke test is skipped without a complete rime_ice fixture; the contextual-candidate pause scenario has no dedicated UI trace yet.
5. **Pending designated-environment evidence:** the Product Owner clarified that Device Hub's iOS 27 iPhone 17 Pro Max is the designated simulator. It is available and has a generic UI baseline, but the contextual-candidate, cancellation, real-RIME and paired-performance scenarios have not run. See the [Device Hub Validation Record](../evidence/typo-correction-002-device-hub-validation.md).
6. **Open semantic-ranking gap:** `TYPO-CORRECTION-003` proved that a default-off 60/64/8 pure plan can recall `wimenjintianquhongyuan → womenjintianqugongyuan` without an allowlist. That is recall evidence only: production remains on the 12-state/eight-hypothesis budget, and no supported cross-input semantic score or incremental real-RIME execution policy has been accepted.

## Invariants

- Maximum hypothesis count, edit cost, real-RIME query count and candidates-per-query are compile-time bounded.
- The sidecar query never selects, commits, pages or changes the live RIME session.
- Multi-edit candidates never auto-commit or receive top promotion merely from search score.
- When a real query is unavailable, the keyboard remains usable and falls back safely.
- Tests use curated synthetic inputs only.

## Archive Condition

Archive or supersede this plan after Product Review closes `TYPO-CORRECTION-002` or replaces its V2 scope.
