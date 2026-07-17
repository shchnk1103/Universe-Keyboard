# TYPO-CORRECTION-003 Progressive Recall Preflight Plan

> **Status:** Archived
>
> **Closure date:** 2026-07-15 Asia/Shanghai
>
> **Current source of truth:** `docs/TYPO_CORRECTION.md` and ADR 0016
>
> **Related ADR:** ADR 0016
>
> **Guidance:** This plan is no longer current development guidance.

## Work Packages

1. Parameterize the pure contextual hypothesis engine without changing its V2.0 default budget.
2. Add a progressive plan using the accepted 60/64/8 bounds.
3. Prove canonical separated-error recall, input limits, final bound and batch bound.
4. Run focused and full KeyboardCore tests.
5. Record that semantic scoring, real-RIME execution and production wiring remain blocked on a later decision and evidence Gate.

## Invariants

- No production controller, UI or RIME bridge call references the new planner.
- No raw input or candidate is persisted or logged.
- V2.0 continues to return at most eight hypotheses.
- Recall-pool inclusion is not candidate-quality or Product-acceptance evidence.

## Archive Condition

Satisfied on 2026-07-15. The Assignment reached `Completed`; the scoring/runtime gap returned to `TYPO-CORRECTION-002` Product/Architecture review. This plan is retained as an execution record and is no longer current implementation guidance.
