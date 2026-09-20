# TYPO-CORRECTION-002 recall remediation — bounded design note

## Status and identity

| Field | Value |
|---|---|
| **Status** | `Draft — read-only design; no implementation authorization` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-001`](../assignments/typo-correction-002-recall-remediation-001.md) |
| **Authorization** | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CONDITIONS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CONDITIONS-001.md) |
| **Worktree** | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-recall-remediation-001/Universe Keyboard` |
| **Branch / HEAD at condition reconciliation start** | `codex/typo-correction-002-recall-remediation-001` / `c38578231baa05cf76821e0db5c4bd7d68b3acfb` |
| **Source implementation freeze** | `fb27b24ff85c48302e85309e834dbbe9a777871e` |
| **Evidence boundary** | Static source/contract analysis only; no new build, install, Run or device capture |

## Executive conclusion

The current evidence supports a **recall-coverage problem hypothesis**, not a
candidate-quality or RIME-provenance conclusion:

- the production engine explicitly defaults to a 12-state first beam and 8
  final hypotheses;
- the default-off preflight explicitly expands to 60 first-layer states and 64
  final hypotheses, in batches of 8, and the Registry records that the
  canonical `womenjintianqugongyuan` hypothesis enters that pool;
- the production controller keeps the preflight separate, queries corrected
  inputs through the sidecar seam, limits each query to 3 candidates and stops
  after 4 non-empty resolved groups;
- ADR 0016 records that the canonical target is locally rank 55 in the
  expanded search, so simply tuning the current top-8 ordering is not a
  defensible fix.

This does **not** prove that the production target is absent solely because of
the 12-state beam, and it does **not** prove that real RIME would return the
intended Chinese sentence. The next safe decision is a deterministic coverage
matrix followed by independent Architecture/Product review. The first
Architecture review has now accepted the direction **with conditions**; those
conditions are recorded below and must be reconciled before implementation is
considered.

## Source findings

### 1. Production generation boundary

`Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift`
shows:

- the default initializer selects `ContextualTypoCorrectionSearchBudget.productionV2`
  (`:16–20`);
- the first layer is truncated by `budget.maximumFirstLayerStates` at
  `:53–56`;
- the completed states are sorted and truncated by
  `budget.maximumHypotheses` at `:59–62`;
- `productionV2` is `12` first-layer states / `8` final hypotheses at
  `:253–260`.

The engine's `diverseBeam` protects edit-position diversity, but it still has a
hard first-layer count. Its heuristic is an explainable retrieval priority,
not a semantic confidence score (`:210–234`).

### 2. Preflight boundary

The same source file defines `progressiveRecallPreflight` as `60` first-layer
states / `64` final hypotheses (`:262–265`).
`ContextualTypoCorrectionSearchPlan` selects that budget only for a pure local
plan and exposes batches of at most 8 (`:268–288`). The comments and ADR state
that this planner does not query RIME or touch the production controller/UI.

### 3. Runtime query boundary

`KeyboardController+TypoCorrection.swift` constructs the default production
engine only when contextual refresh is explicitly requested (`:36–40`). Each
corrected input is queried with a limit of 3 candidates (`:55–58`), and the
controller stops after 4 non-empty resolved groups (`:71–81`). The controller
also combines contextual and legacy suggestions, so the resolved-group limit
is not a total query-attempt limit. This is a separate budget from hypothesis
generation and must remain separate in any future design.

### 4. Existing contract and evidence

- [`ADR 0016`](../architecture/decisions/0016-progressive-contextual-recall-preflight.md)
  records the target as reachable in the expanded search but locally rank 55,
  and keeps production V2 unchanged.
- [`TYPO_BENCHMARK_REGISTRY_V2.md`](../TYPO_BENCHMARK_REGISTRY_V2.md) records
  the 12/8 production contract, the 60/64/8 preflight contract and the
  `TC2-CASE-EXP-002` preflight test.
- [`TYPO_CORRECTION.md`](../TYPO_CORRECTION.md) requires recall, real-RIME
  candidate quality, composition integrity and performance to remain separate
  claims.
- The existing QA-001 receipt did not show the target candidate. That remains
  an inconclusive runtime observation, not a causal proof for this design.

## First-principles failure model

The pipeline has three independent gates:

1. **Recall gate:** the corrected pinyin must survive the first-layer beam and
   final-hypothesis truncation.
2. **RIME gate:** the corrected pinyin must be queried through the real sidecar
   session and return candidates without mutating the live session.
3. **Product gate:** a returned candidate must be safe to display/select and
   satisfy the benchmark and interaction contract.

The preflight currently demonstrates only a bounded instance of gate 1. The
sidecar receipt demonstrates a bounded route instance for gate 2. The missing
QA-001 candidate and paired-performance evidence leave gate 3 open. No single
one of these observations may substitute for another.

## Recommended bounded strategy

The preferred direction is a **coverage-aware second-stage recall pass**, not a
blind production expansion and not a local model:

1. Keep the existing production 12/8 pass as the fast, conservative first
   stage.
2. Detect a deterministic coverage deficit using only the local composition,
   safe-edit model and bounded structural signals; do not inspect host text,
   clipboard, history or semantic model output.
3. If the deficit qualifies, evaluate a separately bounded second-stage slice
   chosen by a coverage matrix. The cap must be selected from measured recall
   coverage and hypothesis-generation cost; `60/64` is a preflight ceiling,
   not a proposed production default.
4. Preserve the existing cancellable post-pause scheduling, independent RIME
   sidecar session, per-query candidate limit, resolved-group limit and
   display-only multi-edit policy.
5. Stop at the first hard budget/cancellation boundary. A second-stage miss
   remains an abstention, not an automatic rewrite.

This direction gives the system a chance to recover separated edit positions
without making every keystroke pay for the expanded pool. The exact trigger,
second-stage cap and candidate-query schedule are deliberately **undecided**
until the coverage matrix and Architecture review are complete.

## Architecture conditions before implementation

The independent Architecture review returned **Pass with conditions**. The
following requirements are now part of the design boundary; this docs-only
reconciliation does not choose a runtime number or authorize code.

### B1 — Separate work counters and a hard attempt fence

Any future second-stage implementation must record these as distinct metrics:

- `N_generated`: hypotheses produced by the selected search stage;
- `N_query_attempts`: query invocations actually started, including empty or
  failed responses;
- `N_resolved_groups`: non-empty corrected-input groups accepted by the
  controller;
- `N_candidates_returned`: candidate texts returned by successful queries.

`resolved-group = 4` and `candidate limit = 3` imply only a possible returned
candidate ceiling under stated assumptions; they do not bound query attempts.
A future implementation Authorization must bind a concrete stage-level
`maxQueryAttempts`. This design slice intentionally leaves its numeric value
`UNKNOWN` until coverage and paired cost evidence select it.

The future execution contract must check cancellation before and after each
query and between batches, carry the current composition revision/epoch into
the operation, discard stale sidecar results, and refuse to publish
`state.typoCorrection` after cancellation or a revision/epoch mismatch.

### B2 — 7/8 contextual boundary remains explicit

The Registry names a `7/31` boundary case, but the exact current contextual
tests visibly cover `5/31`. The matrix therefore records the contextual
7-character rejection and 8-character acceptance as `UNKNOWN`; the legacy
single-edit `zhonghuo` test is not promoted to contextual two-edit evidence.
The boundary cannot be silently closed by referring to the generic Registry
row.

### B3 — Narrow first implementation operation set

The contextual generator has substitution, transposition, deletion and
insertion paths. The recommended first second-stage slice is **substitution-
only**, because the canonical target uses two safe substitutions and the
existing replacement guard is explicit. Transposition, deletion and insertion
remain excluded until each has a separately reviewed safety rule and evidence.
Two-edit results remain display-only: no automatic promotion, silent rewrite,
commit or host-text mutation.

## Options rejected at this stage

| Option | Reason |
|---|---|
| Blindly change production `12 → 60` | The preflight ceiling is not a performance budget; it would multiply possible sidecar work without paired evidence |
| Only reorder the current 8 hypotheses | ADR 0016 records the target at expanded-search rank 55; ordering alone may not recover it |
| Query all 64 hypotheses after the pause | Violates the current measured-query and cancellation assumptions unless a new scheduler and paired performance evidence are authorized |
| Add a local/cloud language model now | Outside the accepted local-only contract; introduces new assets, licensing, memory, privacy and performance decisions |
| Use candidate counts or opaque RIME quality fields as a semantic scorer | Not supported by the current RIME provenance/ordering evidence |

## Required coverage matrix before implementation

The next read-only artifact must enumerate, for the canonical case and
neighboring benchmark cases:

- edit positions and operation types;
- the first-layer rank/order at production 12;
- whether the target survives into the final 8;
- the first bounded expansion size at which it enters the pool;
- number of potential sidecar query groups and worst-case candidate count;
- `N_generated`, `N_query_attempts`, `N_resolved_groups` and
  `N_candidates_returned` as separate fields;
- the stage-level `maxQueryAttempts` and cancellation/revision/epoch publish
  fence;
- the explicit 7-character/8-character contextual boundary pair;
- the permitted second-stage edit operations and their safety guards;
- pure generation cost separately from RIME query cost;
- preservation of short/long input bounds and unsafe-edit exclusions.

The matrix must label each row as **recall reachability**, not sentence
correctness. It must not use FakeCandidateProvider, an old Ice directory or
host text as a substitute for real-RIME evidence.

## Later implementation evidence contract

If Architecture and Product accept the design, a separate implementation
Authorization must bind:

- exact source/package identity and changed-file manifest;
- focused KeyboardCore tests for production coverage, second-stage bounds,
  cancellation and no live-composition mutation;
- real-RIME sidecar query-count/session evidence;
- paired same-process baseline/treatment performance evidence;
- new Run IDs after every rebuild, reinstall, schema or measurement change;
- independent Architecture and Quality review before any Product decision.

No item in this design note authorizes those actions.

## Current decision

**Proceed with docs-only reconciliation of Architecture conditions B1–B3 and a
fresh independent Architecture re-review.** Do not implement yet. The
existing direction is compatible with the current product contract and leaves
the local-model question deferred rather than foreclosed for all future
products.
