# Architecture re-review: TYPO-CORRECTION-002 runtime integration design

## Review identity and exact package boundary

| Field | Value |
|---|---|
| Reviewer role | Independent Architecture & Knowledge Steward; not the design author or either prior reviewer |
| Review mode | Strict read-only Architecture re-review; docs-only record after review |
| Review time | `2026-09-21T21:36:12+08:00 Asia/Shanghai` |
| Revised design | `docs/plans/typo-correction-002-runtime-integration-design-2026-09-21.md` |
| Revised design SHA-256 | `b91e11cf327f9ad3e5974ff0e5b4a53fe755920356927efffed12cfe9c28a848` |
| Prior review | `docs/reviews/typo-correction-002-runtime-integration-design-architecture-review-2026-09-21.md` |
| Prior review SHA-256 | `9f32fdf754ccde13218cdbadaf0dd90517f5ec4f6d98415abbca8856f7d5d15f` |
| Authorization | `AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-ARCHITECTURE-REREVIEW-001`, consumed |
| Review path | `docs/reviews/typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md` |

The source review set was inspected read-only: the controller typo-correction
path, KeyboardCore typo-correction path, serial MainActor owner, thread-affine
owner/facade, RimeBridge correction query, input/marked-text architecture, and
ADR 0004. No source, design, Assignment, ACTIVE_WORK, test, build, RIME or
device state was changed or executed.

## Verdict

**Conditional Accept.** The revised design resolves the prior F-01, F-02 and
F-03 findings at the contract level and is coherent with the existing single
RIME-owner and marked-text boundaries. It does not authorize implementation.
Implementation remains blocked until the separately authorized lane pins the
adapter API, concrete budgets/predicate, and required contract tests. The
remaining conditions are implementation gates, not permission to fill in an
ambiguous design by inference.

## Finding review

### F-01 — yielded one-query turns and invalidate-first cancellation

**Verdict: Pass with conditions.** The design now makes the important causal
boundary explicit: a synchronous owner-facade call is not retroactively
cancellable; its return is followed by a post-return fence; the next attempt
is scheduled through at most one `RunLoop.main.perform(inModes: [.default])`
turn rather than called recursively from the return stack. It also requires
input, page/mode, visibility and owner lifecycle hooks to increment the
controller-owned epoch and cancel before existing work, so invalidations
already serviced by the main run loop can be observed before the next
pre-query fence. This correctly describes an execution opportunity, not an
interrupt for input that has not reached the run loop and not interruption of
an already-started synchronous call.

Condition: implementation must enumerate and prove every relevant invalidation
entry point is invalidate-first, and must retain both the pre-query and
post-return fences. `.default` mode is a scheduling choice and provides no
real-time delivery guarantee; delay in another run-loop mode must fail safe,
not justify a tight synchronous loop or a cancellation claim.

### F-02 — controller-owned epoch, route-local observation, and no bypass

**Verdict: Pass with conditions.** The design correctly separates the
controller-owned `recallEpoch` from native/session epochs: default
`RimeEngineImpl` uses no fabricated native epoch, while responsive and
thread-affine routes may contribute only route-local observations. The
controller epoch remains authoritative on every route, and a route-local
observation can only fail a fence. The proposed single
`TypoCorrectionSidecarOwner` adapter selects the installed query facade rather
than reaching through to a raw engine.

The current source supports the boundary: responsive rebuild wiring replaces
the correction query with the installed bridge, and the existing casts are
typed bridge/diagnostic plumbing rather than a raw-engine correction entry.
However, the design intentionally leaves the exact adapter API and its proof
of default/MainActor-responsive/thread-affine coverage as UNKNOWN. That is a
clear implementation precondition. The future lane must not implement the
adapter as a cast-based escape hatch, expose the underlying engine, or merge a
native epoch into `recallEpoch` by numeric coincidence.

### F-03 — material join, one conditional Core apply, and commit boundary

**Verdict: Pass with conditions.** The revised contract gives stage one and
stage two one operation identity, preserves the original snapshot and opaque
GroupIDs, forbids re-querying accounted-for groups, and requires the final
join to perform cross-stage deduplication, normal-top suppression and ranking
exactly once. It names one conditional Core apply as the only writer of
`TypoCorrectionState`; the no-stage-two case uses that same boundary.

The input-pipeline contract remains consistent: the sidecar result is
display-only, while existing user selection remains the sole host commit path.
The design also explicitly forbids `TextInputClient`, `insertText`,
`setMarkedText`, pasteboard use, live RIME candidate selection and direct
candidate-bar mutation in this lane. Condition: implementation must make the
material handoff and the single apply point structurally unambiguous and test
that stale/empty/budget-stop results are display no-ops; no second commit or
marked-text path may be introduced as a convenience.

## Finding and residual disposition

| Item | Disposition |
|---|---|
| F-01 | Resolved in design contract; retain implementation conditions above |
| F-02 | Resolved in design contract; exact adapter API and route proof remain implementation blockers |
| F-03 | Resolved in design contract; concrete material/apply structure and tests remain implementation blockers |
| Coverage-deficit predicate and production budgets | `UNKNOWN`; Product/implementation authorization required |
| Default and responsive/thread-affine adapter proof | `UNKNOWN`; Architecture-visible implementation evidence required |
| One-call interaction budget | `UNKNOWN`; no performance claim made |
| Operation receipt schema/retention/privacy | `UNKNOWN`; separate diagnostics/privacy authorization required |
| Real RIME, QA-001, INT-003, paired performance | Out of scope and unclaimed |

## F-04 disposition

**Retained as tech debt.** The design keeps routine telemetry content-free,
does not repurpose the DEBUG decision trace, and defers any operation receipt
to a separately authorized diagnostics/privacy change. F-04 does not require an
ADR change or a design rewrite at this stage.

## ADR judgment

**ADR 0004 remains applicable and needs no amendment.** The design preserves
the accepted single-consumer/session ownership rule, keeps the default
MainActor-synchronous route distinct from the responsive/thread-affine route,
and rejects detached RIME access, a second session and a parallel query lane.
An ADR review would become necessary only if implementation changes the
RIME owner/executor, introduces a cross-executor async bridge, bypasses the
installed facade, or changes session lifecycle semantics.

## Non-claims

This review claims no implementation approval, runtime behavior, test or build
result, RIME query/deployment, Simulator/device evidence, QA-001, INT-003,
paired-performance or `180 ms` result. It claims no Product, Quality, Release,
publication, commit, push, PR, merge, TestFlight, Assignment Close or release
decision. No design, Assignment, ACTIVE_WORK or Swift file was modified.
