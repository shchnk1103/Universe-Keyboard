# Product Decision: TYPO-CORRECTION-002 runtime-preflight implementation residual

## Decision

**Accepted — bounded pure-Core preflight foundation only.**

The Human Product Owner accepts the independently reviewed implementation as a
non-production foundation: it provides an auditable structural selector,
preflight-only limits, operation-private identity and stale-result decision
fences. This decision does **not** accept a user-visible correction behavior,
does not authorize publication, and does not close the implementation or parent
TYPO-CORRECTION-002 Assignment.

| Input | Disposition |
|---|---|
| [Implementation evidence](../evidence/typo-correction-002-runtime-preflight-implementation-001.md) | Accepted as exact-snapshot executor evidence |
| [Architecture review](../reviews/typo-correction-002-runtime-preflight-implementation-architecture-review.md) | Accepted as Conditional Accept within the pure-Core boundary |
| [Quality review](../reviews/typo-correction-002-runtime-preflight-implementation-quality-review.md) | Accepted as Pass with conditions within the pure-Core boundary |
| Exact code diff | Bound to uncommitted SHA-256 `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |

## Why publication is not the next step

The reviewed code is deliberately unreachable from the production controller.
Publishing it now would make a reviewed internal foundation durable, but would
not advance the product objective: no sidecar query starts, no candidate is
merged, and QA-001 cannot observe a difference. It would also force a separate
publication/merge lane before the architectural runtime contract is decided.

Therefore Product chooses **not to request publication now**. The exact
uncommitted worktree and evidence remain retained as a reproducible checkpoint;
this is not authorization to reset, discard, commit, push or merge it.

## Accepted residuals

1. The structural selector and its provisional selected-group/query caps have
   only been accepted as a pure-Core contract; their production suitability and
   complete coverage matrix remain unknown.
2. The operation ordinal and ledger fences model stale/cancelled decisions, but
   no asynchronous scheduler, controller cancellation or real sidecar lifecycle
   exists.
3. GroupID mapping is private in-memory Core data only. It is not bound to
   sidecar accounting, diagnostics or a runtime privacy review.
4. No real RIME result, candidate visibility/selection, QA-001, INT-003,
   paired performance, latency/throughput or `180 ms` conclusion exists.

## Next Product direction

Before any runtime code, request a new bounded **controller/sidecar runtime
integration design** Authorization. Its design must settle, and then receive
independent Architecture review for:

- the operation owner and async scheduler boundary;
- checks before and after every sidecar call, cancellation and stale discard;
- bounded selected-group/query/resolved-group lifecycle;
- display-only candidate merge without a second composition or commit path;
- sidecar accounting/diagnostics privacy boundary; and
- a later, separately authorized real-RIME observability, QA-001 and paired
  performance plan.

Only after that design is accepted should a separate implementation
Authorization name controller/RimeBridge paths, verification and new Run IDs.

## Explicit non-decisions

This is not a Quality Gate, Product Gate, Release decision, publication,
commit, push, PR, merge, TestFlight, Release, runtime enablement, QA-001,
INT-003, performance result, or Assignment close.

**Decision source:** Human Product Owner / Product Lead, current task
instruction `接受` on `2026-09-21 Asia/Shanghai`.
