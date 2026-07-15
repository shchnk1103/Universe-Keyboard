# ADR 0016: Progressive Contextual Recall Preflight

## Status

Accepted.

**Implementation state:** Completed under `TYPO-CORRECTION-003` on 2026-07-15; production enablement is not authorized.

## Context

ADR 0015 introduced a bounded 12-state/eight-hypothesis search. Diagnostic expansion showed that the canonical separated two-error correction `womenjintianqugongyuan` is reachable but appears at local rank 55 for `wimenjintianquhongyuan`; therefore V2.0 cannot demonstrate the requested recall case.

librime internally stores candidate quality, but its ordering contract compares candidates covering the same segment range. The repository has no real `rime_ice` fixture proving that this value is comparable across different corrected input codes. The designated simulator currently lacks a complete deployed RIME runtime. Treating an internal value or a Fake Provider as semantic evidence would violate the repository's provenance rules.

## Decision

1. Keep ADR 0015 and the V2.0 production path unchanged.
2. Add a pure progressive-recall planner beside the existing search engine. It uses the same safe two-edit operations and 8–30 character boundary.
3. Bound the planner to at most 60 first-layer states, 64 final hypotheses and batches of at most eight.
4. The planner creates immutable local strings only. It performs no RIME query, persistence, logging, UI update or session operation.
5. The planner is default-off by construction because no production controller or Keyboard Extension path references it.
6. Do not add a semantic scorer in this Work Item. A future scorer must identify a supported source, prove cross-input meaning with real RIME, preserve main-thread/session ownership and receive Product, Architecture and Quality revalidation.

## Alternatives Considered

### Tune the existing eight-item heuristic until the canonical example appears

Rejected because it would overfit one phrase without adding a semantic signal.

### Query all expanded hypotheses immediately

Rejected because librime operations are main-thread serialized and an unmeasured burst would violate the performance and session contracts.

### Compare internal candidate quality across corrected inputs

Rejected for this preflight because the repository has no real-runtime evidence that the values are comparable across different input codes.

### Add an offline or cloud language model now

Rejected from this Work Item. Cloud processing violates the local-only contract; a bundled model introduces new assets, licensing, memory, privacy and performance decisions that require a separate Product/Architecture task.

## Consequences

- Recall coverage can be measured independently from candidate quality and UI behavior.
- The canonical two-error hypothesis can enter a bounded pool without changing production behavior.
- Semantic ranking and runtime query scheduling remain explicit blockers rather than hidden assumptions.
- A future production increment can consume the plan only after defining cancellation, batch execution, scoring and performance evidence.

## Risks

- Future work may mistake recall-pool inclusion for intended-sentence recovery.
- A 64-item plan may tempt direct main-thread iteration despite the explicit production stop condition.
- Later scoring may still fail if RIME candidate evidence is not comparable across hypotheses.

## Follow-up Work

- Keep the completed pure planner isolated from production until a later accepted decision authorizes runtime use.
- Preserve existing V2.0 focused and full-package regression results.
- Create a separate Product/Architecture decision for a supported semantic scoring source and incremental runtime execution.
- Collect real-RIME fixture and designated-environment evidence before any production enablement.

## Related Documents

- [`Contextual Typo Correction Product Contract`](../../TYPO_CORRECTION.md)
- [`TYPO-CORRECTION-003 Assignment`](../../assignments/typo-correction-003.md)
- [`ADR 0015`](0015-contextual-multi-error-typo-correction.md)
- [`V2 Incremental Registry`](../../TYPO_BENCHMARK_REGISTRY_V2.md)
- [`Performance Baseline`](../../PERFORMANCE_BASELINE.md)
