# TYPO-CORRECTION-002 Runtime integration design — controller-owned second-stage recall

**Status:** Revised docs-only design awaiting a new independent Architecture
re-review. This is not an implementation authorization, runtime claim,
performance result, or Product Gate.

## Revision receipt — 2026-09-21 Asia/Shanghai

This revision consumes [`AUTH … DESIGN-REVISION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-REVISION-001.md)
and addresses F-01 through F-03 from the prior
[`Architecture review`](../reviews/typo-correction-002-runtime-integration-design-architecture-review-2026-09-21.md).
It changes only the proposed contract below. No source, RIME, device, test or
performance evidence changed.

## 1. Exact inputs and factual boundary

This design is bound to the pure-Core checkpoint whose baseline/tree/diff are:

| Input | Identity |
|---|---|
| Baseline commit | `4d1050f4b677494e06448cb40a83ef2da46d7b27` |
| Baseline tree | `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Pure-Core checkpoint diff SHA-256 | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |

The inspected production facts are deliberately narrow:

1. `KeyboardViewController` is `@MainActor`. It currently owns the 180 ms
   debounce `DispatchWorkItem`, captures an expected composition, asks
   `KeyboardController` for correction refresh, then refreshes the candidate bar.
2. `KeyboardController.refreshTypoCorrectionSuggestions(includingContextual:)`
   synchronously generates hypotheses, synchronously calls
   `TypoCorrectionCandidateQuerying.correctionCandidates`, and directly writes
   `state.typoCorrection` after existing ranking/suppression.
3. Production non-responsive setup injects `RimeEngineImpl` as the query object.
   Its sidecar query is synchronous. Responsive thread-affine setup instead
   injects `ThreadAffineRimeEngineBridge`, whose synchronous facade flushes the
   owner backlog and waits for the owner-thread result.
4. RIME has an explicit single-consumer ownership rule. The MainActor serial
   owner warns that a non-Sendable engine cannot be moved to a background actor
   without unsafe isolation; the thread-affine bridge is likewise accessed through
   a synchronous owner facade.
5. Existing diagnostics already record content-free route and individual sidecar
   events. They exclude raw input and candidate strings. The DEBUG decision trace
   has a different, content-bearing debugging purpose and is not routine telemetry.

Therefore, an `async` spelling or a detached task would not by itself make the
sidecar call concurrent, cancellable, or free of owner contention. This design
does not authorize either technique.

## 2. First-principles contract

The user's visible composition is the only mutable input state. A second-stage
recall operation may *read* a normalized snapshot of it, but must never create a
new live RIME composition, alter marked text, insert host text, select a RIME
candidate, or replace the composition.

The operation's output is only an additional, conditionally accepted
`TypoCorrectionSuggestion` set. The already-existing candidate rendering and
user selection path remain the sole display/commit route.

## 3. Proposed ownership and operation identity

### 3.1 Single lifecycle owner

The future lifecycle owner should be a controller-bound, `@MainActor`
coordinator held by `KeyboardViewController`, adjacent to the existing debounce
work item. It owns:

- the one pending debounce item and any one active second-stage operation;
- cancellation on each composition, page, input-mode, visibility, engine, or
  epoch change;
- the composition snapshot and operation identity; and
- the final candidate-bar refresh after a conditionally accepted application.

`KeyboardController` remains the only owner that mutates
`state.typoCorrection`. The pure-Core `RecallOperation`, selection plan and
ledger remain value-level policy/acceptance helpers, not UI or RIME owners.

### 3.2 Identity and fences

At operation creation, capture a content-private tuple:

`(recallEpoch, compositionRevision, operationOrdinal, normalizedComposition)`.

`normalizedComposition` is held only in memory for equality and query work; it
is not logged or persisted. `operationOrdinal` is monotonic only within the
keyboard lifecycle. `recallEpoch` is a controller-owned lifecycle counter, not
a claim that the default and thread-affine RIME implementations expose the same
native epoch. The coordinator increments it *before* any composition mutation,
page/mode change, visibility teardown, RIME owner rebind/recovery or explicit
correction disable. It is the authoritative recall invalidation fence on every
route.

The coordinator may retain a route-local owner observation alongside this tuple:

- default `RimeEngineImpl`: `ownerEpoch = nil`; only `recallEpoch` binds recall
  lifecycle because ADR 0004 does not expose an equivalent native epoch;
- MainActor responsive owner: the current serial-owner epoch, if available;
- thread-affine owner: its published lifecycle `sessionEpoch`, if available.

Route-local epochs are supplementary no-bypass observations. They can only make
a fence fail; they never replace the controller-owned `recallEpoch` or permit a
direct/raw engine call. The future integration exposes this through one
`TypoCorrectionSidecarOwner` adapter assembled by the existing engine-install /
responsive-rebuild wiring. It selects the already-installed query facade, not an
underlying engine cast.

The coordinator must fence at these points:

1. after debounce and before planning;
2. before starting every sidecar query;
3. immediately after every synchronous owner-facade return;
4. before applying an aggregated result to `KeyboardController`; and
5. before refreshing the candidate bar; and
6. after a deliberate main-run-loop yield and before a subsequent query.

A fence passes only if the coordinator still owns the same operation and the
current normalized composition, page/mode, `recallEpoch`, and any available
route-local owner epoch agree. Any failed fence drops the result without changing
displayed correction state.

## 4. Scheduling, cancellation and bounded work

### 4.1 Two stages

Stage one and stage two are material-producing phases of one contextual-recall
operation. Stage one computes bounded ordinary-correction material; stage two
begins only after a later implementation defines, tests and Product-accepts a
coverage-deficit predicate over that material. It must abstain when stage one
already supplies a sufficient accepted display result; it must not query merely
because a debounce elapsed.

Neither phase writes `state.typoCorrection` while the operation is running.
Their in-memory results retain the same operation identity, original input
snapshot and opaque group IDs. They are joined only after all bounded work stops
or the coverage predicate abstains; the final fence then admits one Core apply.

For an eligible operation, use the pure-Core structural selector and its
operation-private opaque `GroupID` registry. Do not use hypothesis-array order as
execution order, and do not persist GroupID-to-input mapping.

### 4.2 Budgets

The future implementation must enforce separately:

- selected-group budget;
- started-query-attempt budget;
- per-query candidate limit; and
- accepted-display-result budget.

The pure-Core defaults are policy inputs, not automatically approved production
numbers. A later implementation Authorization must pin the concrete values and
test every stop reason. It must issue at most one owner-side call at a time.
Each call occupies one scheduler turn; the scheduler must never synchronously
loop into the next query after a return.

### 4.3 Cancellation is cooperative, not retroactive

Cancelling a pending debounce or an operation prevents all not-yet-started
queries. It cannot interrupt a query already inside the current synchronous RIME
owner facade. That one call may return, but its post-return fence must discard the
result if stale/cancelled.

After each returned call, the coordinator schedules at most one next-query turn
with `RunLoop.main.perform(inModes: [.default])`; it does not invoke the next
query from the return stack. Every keyboard action that can mutate composition,
page or mode, and every visibility/owner lifecycle callback, first increments
`recallEpoch` and cancels the pending operation token before doing its existing
work. Thus invalidations already serviced by the main run loop are observed before
the next query turn's pre-query fence. This is an execution opportunity, not a
claim that input which has not yet reached the run loop can interrupt an already
started query. At worst, such later input may overlap one call; it cannot cause a
tight synchronous loop of later attempts.

The future automated contract must test: cancellation before the yielded turn,
composition/page/mode/visibility/owner invalidation between turns, post-return
staleness, and the fact that no second query begins without a new yielded turn.

The design specifically rejects `Task.detached`, direct raw-engine access, a
second RIME session, semaphore waiting on the keyboard main path, and a new
parallel query lane. Any proposal to change the owner/executor must first receive
a separate concurrency and RIME-architecture decision.

## 5. Display-only merge

The later implementation must expose one *conditional apply* API on
`KeyboardController`: it accepts the operation identity plus joined stage-one and
stage-two material only after the final fence. It performs cross-stage candidate
deduplication, existing normal-top suppression and ranking exactly once, then is
the only operation path permitted to write `TypoCorrectionState`.

The join must preserve the original input snapshot and may never re-query a group
already accounted for by either stage. If no stage-two work is eligible, the same
conditional-apply boundary accepts the stage-one material. A stale/cancelled
operation does not clear or overwrite a newer operation's display state.

It must not call `TextInputClient`, `insertText`, `setMarkedText`, pasteboard,
live RIME candidate selection, or a direct candidate-bar mutation. A failed
fence, an empty result, a budget stop, unavailable route, or rejected ranking is
display no-op.

## 6. Observability and privacy boundary

The existing `TypoCorrectionQueryRouteEvent` and
`TypoCorrectionSidecarQueryEvent` prove individual content-free route/query
facts, but do not bind those events to one controller operation. A later,
separately authorized diagnostics change may add an operation receipt only if it
contains exclusively:

- ephemeral opaque operation ID / epoch / ordinal;
- finite stage and terminal reason enums;
- selected, attempted, returned, accepted and dropped counters;
- route, bounded elapsed measurement and current provenance receipt reference;
- whether a post-return fence accepted or dropped a result.

It must never include raw composition, normalized/corrected input, candidate
text, host document context, clipboard, a durable GroupID map, a text hash, or a
cross-lifecycle user identifier. The existing DEBUG decision trace must not be
repurposed as this receipt. Journal emission remains non-blocking and must stay
outside the key-event critical section.

## 7. Future implementation and verification matrix

| Future lane | Likely owned paths / proof | Requires new authorization |
|---|---|---|
| Controller lifecycle | `Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift`; recallEpoch, invalidate-first hooks, yielded one-query turns, fences and final refresh | Yes |
| Core conditional merge | `Packages/KeyboardCore/.../KeyboardController+TypoCorrection.swift` plus `TypoCorrectionRecallPreflight.swift`; material phases, one join/dedup/rank/apply | Yes |
| RIME ownership adapter | existing injected query facade plus `Packages/RimeBridge/.../RimeEngineImpl+CorrectionQuery.swift` and/or serial/thread-affine bridge; no raw cast, route-local observation only | Yes, plus Architecture sign-off |
| Diagnostics receipt | `DiagnosticEvent`, `DiagnosticsJournalRuntime`, controller diagnostic ingress | Yes, privacy review required |
| Automated tests | KeyboardCore contract tests, app/keyboard integration tests, RimeBridge tests; no provider fixture may stand in for real RIME evidence | Yes |
| Real-RIME observability | new provenance-bound Run ID and raw-artifact receipt | Yes |
| QA-001 / INT-003 | new separately authorized interaction Runs | Yes |
| Paired performance | same-package, paired, provenance-bound performance plan and Run | Yes |

The implementation lane must run the CI-equivalent suite required by its actual
changed paths. Real RIME, QA, and performance claims are separate evidence lanes;
passing unit tests cannot substitute for them.

## 8. Open questions and stop conditions

The following remain `UNKNOWN` and block implementation approval, not this design:

1. The precise coverage-deficit predicate and production numeric budgets.
2. The exact API shape for the adapter and the tests that prove default and
   responsive/thread-affine paths use it without a bypass.
3. Whether one bounded synchronous call fits the interaction budget on target
   hardware. Existing elapsed observations are not a paired-performance result.
4. The exact operation-receipt schema and its retention/privacy review.

Stop and return to Product/Architecture if any implementation needs raw text
telemetry, a second composition/commit path, an unbounded query loop, a detached
RIME call, or a performance conclusion without its dedicated evidence lane.

## 9. Non-claims

No Swift or runtime behavior changed. No RIME query or deployment ran. No
Simulator/device capture, QA-001, INT-003, paired performance, `180 ms` result,
publication, commit, push, PR, merge, Gate, Release or Assignment Close is
claimed.
