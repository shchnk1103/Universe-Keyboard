# ADR 0015: Contextual Multi-Error Typo Correction

## Status

Accepted; implementation in progress.

## Context

The existing typo-correction path is a conservative one-edit suggestion layer. Its runtime correction lookup uses `KeyboardController.candidateProvider`, whose production bootstrap defaults to `FakeCandidateProvider`; real RIME powers the normal live composition but does not verify arbitrary correction hypotheses.

Expanding character-edit enumeration alone cannot recover multi-error sentence intent. It would also either mutate the live RIME session while probing alternatives or grow without a bounded cost model.

## Decision

1. Keep typo correction as a parallel suggestion layer. The live composition, marked text and normal RIME session remain authoritative for ordinary typing.
2. Add one lazy, process-local correction query session inside the existing `RimeSessionManager` runtime. It shares the initialized librime runtime but has independent composition state.
3. Expose that session to KeyboardCore through a small query protocol. The fallback dictionary remains a test/degraded implementation only.
4. Generate hypotheses with a bounded local beam search over conservative touch-key edits. Query only the bounded surviving hypotheses.
5. Use a combined score of edit cost, generation order and verified RIME candidate order. Multi-edit candidates are display-only/near-front candidates; no automatic top promotion is introduced by this ADR.
6. Keep all hypotheses ephemeral. Do not persist raw pinyin, candidate text, host context or sentence history.

## Alternatives Considered

### Mutate and restore the live RIME session for each hypothesis

Rejected because a failed restore could corrupt the visible composition, candidate paging or Delete/Partial Commit semantics.

### Add broad RIME schema/Lua derive rules

Rejected because touch-error probability and bounded multi-edit ranking are KeyboardCore product semantics, not schema spelling expansion.

### Enumerate every edit combination

Rejected because the number of paths grows combinatorially and cannot meet the Extension hot-path boundary.

### Use a cloud language model

Rejected because keyboard input is privacy-sensitive and the Product Contract is local-only.

## Consequences

- RimeBridge gains sidecar-session lifecycle responsibility.
- KeyboardCore gains an engine-independent hypothesis-query seam and pure bounded search.
- Tests must prove that query input never changes the live session.
- Real RIME and designated Device Hub simulator performance evidence become mandatory for V2 conclusions.

## Risks

- A sidecar query can add main-thread RIME work; bounded query count and measured performance are required.
- Multi-edit recall can increase false positives; normal-input and dangerous-case gates remain mandatory.
- Multiple librime sessions share a process runtime; session destruction/restart must retire both safely.

## Follow-up Work

- Implement `TYPO-CORRECTION-002` according to its active plan.
- Publish immutable Registry IDs for V2 semantics before treating new benchmark cases as accepted.
- Collect Device Hub iOS 27 iPhone 17 Pro Max evidence before Product acceptance.

## Related Documents

- [`TYPO-CORRECTION-002 Assignment`](../../assignments/typo-correction-002.md)
- [`Contextual Typo Correction Product Contract`](../../TYPO_CORRECTION.md)
- [`Typo Correction Benchmark`](../../TYPO_BENCHMARK.md)
- [`ADR 0004: RIME Runtime Session Model`](0004-rime-runtime-session-model.md)
- [`ADR 0008: Fallback Engine Product Semantics`](0008-fallback-engine-product-semantics.md)
