# Runtime design package: TYPO-CORRECTION-002 bounded second-stage recall

**Lifecycle:** `Proposed`

**Status:** docs-only design output for independent Architecture review. It is
not runtime implementation guidance or a production authorization.

## Exact source boundary

| Item | Value |
|---|---|
| Source worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-design-001/Universe Keyboard` |
| Source commit | `4d1050f4b677494e06448cb40a83ef2da46d7b27` (`origin/main`) |
| Source state | clean before static inspection |
| Governing Assignment | [`runtime design Assignment`](../assignments/typo-correction-002-second-stage-recall-runtime-design-001.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001`](../authorizations/AUTH-TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001.md) |

## Frozen facts

1. The production contextual engine defaults to `productionV2 = 12/8`. The
   `60/64` plan is default-off preflight only; neither changes in this package.
2. The canonical corrected pinyin is absent from production `12/8` and is
   observed at rank `55` in expanded substitution-only search. Its first
   observed reachability is not a proof of a real-RIME Chinese candidate.
3. Current contextual refresh waits `180 ms` after a pause, then calls a
   synchronous controller loop. Each generated hypothesis calls
   `correctionCandidates(..., limit: 3)`; at most four non-empty groups are
   resolved. The `180 ms` value is a debounce, not a query, scheduler or
   performance budget.
4. The production RimeBridge implementation uses a sidecar session. Current
   candidate deduplication is by candidate text; pure Core's opaque group token
   ledger has no production scheduler mapping from corrected input to token.
5. The current stale guard only rejects a refresh when the expected composition
   has already changed before the synchronous work begins. A future async
   second stage needs a fence after every awaited query before it can publish.

## First-principles contract

The input is the current in-memory composition and its revision/epoch. The
only permitted side effect is an optional, display-only correction group in
the existing candidate state. The result is valid only while it belongs to the
same composition operation. Therefore a second stage must be an independently
cancellable operation, not an enlarged synchronous loop on the key path.

### Proposed operation identity

`RecallOperation` must contain the existing `compositionRevision` and
`sessionEpoch`, plus an in-memory operation ordinal. It is not persisted or
written to routine diagnostics. A result may be accepted only when all three
values still equal the controller's current operation.

### Proposed canonical group mapping

Within one `RecallOperation`, normalize a corrected pinyin exactly as the
existing typo input normalization does, deduplicate equal normalized corrected
inputs in memory, then assign the first ordered occurrence an opaque monotonic
`GroupID`. The scheduler keeps the private mapping only for its operation;
the ledger and diagnostics receive the opaque ID and counters, not the pinyin.

This is deliberately a design contract, not a claim that current runtime
already has that mapping. The future implementation must test that duplicate
inputs share one group, different inputs do not, and a new operation cannot
reuse the old operation's mapping.

### Proposed two-stage state machine

```text
idle
  -> waitingForPause(revision, epoch)
  -> stageOne(unchanged production 12/8)
  -> assessCoverageDeficit
  -> stageTwo(selected groups only) | abstain
  -> publish(display-only) | discard(stale/cancelled) | complete
```

`stageTwo` is eligible only when all of the following hold:

- the composition still satisfies the existing letter/Chinese/minimum-length
  eligibility checks;
- the same `RecallOperation` remains current after the pause and after stage
  one;
- the first stage has not produced an accepted display-eligible correction;
- a deterministic, local coverage-deficit predicate selects a bounded group
  slice; and
- a fresh hard attempt budget remains.

The predicate may use only the local normalized composition, the safe-edit
model and structural coverage categories. It must not inspect host text,
clipboard, user history, semantic model output or network data.

## Budget design: separate generation from queries

The rank-55 fact means that taking the first eight hypotheses from an expanded
ordered list is not a valid second-stage strategy: it would still omit the
canonical corrected pinyin. Generation, selection and querying must remain
separate:

| Counter / limit | Required meaning | Current decision |
|---|---|---|
| `N_generated` | all bounded substitution-only hypotheses generated for the operation | no production number selected |
| selected group count | unique groups chosen by the coverage matrix | must be capped before runtime implementation |
| `N_query_attempts` | sidecar calls actually started | future cap must be explicit; the existing preflight value `8` is only a candidate ceiling, not an approved runtime value |
| `N_resolved_groups` | non-empty, current-operation, unique groups accepted for display evaluation | future cap must remain separate from query attempts |
| `N_candidates_returned` | candidates returned by started sidecar calls | candidate limit remains separately explicit; it is not a quality score |

The future coverage matrix must select groups by deterministic structural bins
(for example, safe substitution positions, replacement-neighbor order and
edit-position spread), then demonstrate that its chosen slice contains the
canonical structural pattern without recording the pinyin or candidate text in
routine evidence. The matrix, its selected cap and `maxQueryAttempts` remain
**UNKNOWN** until a separately authorized runtime-preflight chooses and tests
them.

## Cancellation and publish fence

Any future runtime slice must:

1. cancel the pending pause when composition changes;
2. check `RecallOperation` before starting each sidecar call;
3. check it again after every sidecar result and before group accounting;
4. discard stale/cancelled results without creating resolved groups or writing
   `state.typoCorrection`;
5. publish only display-eligible candidates through the existing correction
   merge path; never rewrite composition or auto-commit; and
6. terminate immediately at the selected query, batch, resolved-group or
   cancellation boundary.

The existing sidecar session must remain separate from the live RIME session.
This package neither adds an async API nor claims that cancellation is currently
possible once a synchronous sidecar query has begun.

## Observability and privacy boundary

Routine runtime evidence may record operation correlation, route class,
schema/provenance receipt binding, counter deltas, termination reason and
elapsed bounds. It must not persist raw composition, corrected pinyin,
candidate text, host text, clipboard or learned history. A future request to
prove which pinyin was queried or which candidate text returned requires its
own content-bearing diagnostic Authorization and retention boundary.

## Required future lanes

| Lane | Separate authorization required | Required outcome |
|---|---|---|
| Runtime implementation | Yes | scheduler implementation, explicit selected caps, cancellation and focused tests |
| Real-RIME observability | Yes | provenance-bound route and, only if authorized, content-bearing query/result proof |
| QA-001 | Yes, new package and Run ID | candidate visibility/selection on the revised package; no reuse of revalidation 07 |
| Paired performance | Yes, same extension process | baseline/treatment measurement independent of sidecar elapsed logs |
| Publication | Yes | commit/push/PR scope and post-change independent reviews |

## Rejected shortcuts

- Increasing every input from `12/8` to `60/64/8`;
- treating rank `55` as a real-RIME candidate or product success;
- using FakeCandidateProvider, an old Ice directory, host text, clipboard,
  local/cloud model or synthetic fixture as runtime evidence;
- using the UI's `180 ms` debounce as a throughput claim; and
- allowing a stale second-stage result to replace the current candidate bar.

## Architecture review request

Independent Architecture review should verify that the proposed mapping is
private and operation-scoped, that the coverage selector is bounded before any
sidecar call, and that the cancellation/publish fence does not create a second
composition or commit path. It must preserve the open unknowns for real RIME,
candidate visibility, performance and `contextual 7/8`.
