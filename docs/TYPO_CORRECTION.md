# Contextual Typo Correction Product Contract

> **Version:** `2.2.0`
>
> **Status:** Accepted contract; V2.1 progressive-recall preflight is implemented while production defaults remain unchanged
>
> **Product authority:** Human Product Owner authorization in Codex task `019f6101-b9db-7821-9db6-ca288d9e1189` / `2026-07-14` and continuation instruction / `2026-07-15 Asia/Shanghai`
>
> **Assignments:** [`TYPO-CORRECTION-002`](assignments/typo-correction-002.md), [`TYPO-CORRECTION-003`](assignments/typo-correction-003.md)
>
> **Architecture decisions:** [ADR 0015](architecture/decisions/0015-contextual-multi-error-typo-correction.md), [ADR 0016](architecture/decisions/0016-progressive-contextual-recall-preflight.md)

## Product Decision

V2.0 remains the current production behavior and acceptance target. V2.1 authorizes a default-off progressive-recall preflight that can build a larger, still bounded set of synthetic multi-error hypotheses and divide it into cancellable query-sized batches.

This decision separates **recall** from **semantic ranking**. The preflight may prove that a plausible corrected pinyin enters a bounded search pool; it may not claim that RIME would return the intended Chinese sentence, that candidates are correctly ordered across different input codes, or that the production keyboard may execute the larger query pool. Production wiring requires a separate Quality and Architecture revalidation with real-RIME and performance evidence.

V2.2 records the Product Owner's environment clarification: the designated Device Hub iOS 27 iPhone 17 Pro Max is a **simulator**, not a physical device. Only fresh evidence from that designated simulator may satisfy the environment-specific Gate; earlier generic simulator baselines do not retroactively satisfy the contextual correction scenarios.

## Purpose

Small touch keyboards make several mistakes in one pinyin composition common. Contextual Typo Correction recovers the user's intended Chinese phrase or sentence from a bounded set of plausible multi-error pinyin hypotheses, while preserving ordinary RIME typing when confidence is insufficient.

This capability is a local, on-device input aid. It is not telemetry, cloud correction, a replacement for RIME's own ranking, or a guarantee that every ambiguous input has one correct interpretation.

## Product Principles

1. **Useful uncertainty.** The system returns a small ranked set of plausible sentence candidates; it abstains when evidence is weak.
2. **Normal RIME first.** Valid input and RIME's already-satisfactory best candidate remain protected.
3. **Composition integrity.** Hypothesis evaluation never mutates the user's live RIME composition or marked text.
4. **Bounded work.** Hypothesis generation, RIME queries, candidate materialization and UI display have explicit bounds.
5. **Local by construction.** No raw input, sentence, host context or correction history is uploaded.
6. **Explicit learning only.** Any personalization starts only after an explicit correction selection and must remain bounded, resettable and non-reconstructable.

## V2 Behavior

While Chinese pinyin composition is active, the keyboard may generate candidates from a bounded number of locally evaluated hypotheses. A candidate is represented as a correction candidate and commits only after an explicit tap. To protect rapid typing, V2 schedules this work after a cancellable 180 ms input pause rather than in the synchronous key path.

The first V2 implementation supports at most two combinations of safe touch-key substitutions, conservative vowel insertions, deletions and adjacent transpositions. It keeps a 12-state local first beam, returns at most eight hypotheses, resolves at most four candidate groups, and limits each query to three candidates. Multi-edit candidates may enter the front candidate area only after a real RIME query returns a verified candidate. They never receive automatic top promotion solely because they exist.

## V2.1 Progressive-Recall Preflight

- The preflight supports the same two-edit safety model and 8–30 character input boundary as V2.0.
- It may retain at most 60 first-layer states and at most 64 final hypotheses.
- A search plan divides hypotheses into batches of at most eight; building a plan performs no RIME query, persistence or UI mutation.
- The preflight is not called by the production controller or Keyboard Extension scheduling path.
- Candidate scoring, cross-input comparison, incremental RIME execution and production enablement remain outside this preflight.

## Non-goals

- No network, model download, cloud inference, analytics or telemetry.
- No surrounding host-text, clipboard, application identity or committed sentence inspection.
- No mutation of RIME schema, RIME weights or RIME user dictionary for typo correction.
- No synchronous persistence, deployment, directory scan or network work in the key path.
- No automatic commit or silent rewrite of user text.
- No claim that every multi-error input is recoverable or unambiguous.

## Data And Privacy Boundary

- Raw composition and generated hypotheses exist only in memory for the current refresh.
- Debug/evidence runs use curated synthetic inputs only.
- The existing exact-pair learning store is not extended to persist sentence-level raw pinyin or candidate text.
- A future generalized error-pattern learner requires a separate Product and ADR review.

## Acceptance Contract

V2 is acceptable only when evidence proves:

- real RIME, rather than the fallback test dictionary, verifies runtime correction candidates;
- multi-error synthetic sentence cases recover the expected intent within the documented Top-K position;
- valid and dangerous-input regression cases preserve their current behavior;
- live composition, marked text, Delete, Space, Return, paging, Partial Commit and visibility semantics remain correct;
- work remains bounded and fails safely when the correction query session is unavailable;
- controlled performance evidence has no unexplained key-path, memory or lifecycle regression;
- environment-specific validation uses only the designated Device Hub iOS 27 iPhone 17 Pro Max simulator.

## Related Documents

- [`Typo Correction Benchmark`](TYPO_BENCHMARK.md)
- [`Typo Correction Benchmark Registry`](TYPO_BENCHMARK_REGISTRY.md)
- [`Typo Correction Benchmark v2.0 Incremental Registry`](TYPO_BENCHMARK_REGISTRY_V2.md)
- [`Input Pipeline And Marked Text`](architecture/input-pipeline-and-marked-text.md)
- [`Performance Baseline`](PERFORMANCE_BASELINE.md)
- [`TYPO-CORRECTION-002 Implementation Plan`](plans/typo-correction-002-implementation-plan.md)
