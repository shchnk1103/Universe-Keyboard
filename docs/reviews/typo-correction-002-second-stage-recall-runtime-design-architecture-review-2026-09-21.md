# Architecture Review: TYPO-CORRECTION-002 bounded second-stage recall runtime design

## Verdict

**Conditional Accept**，仅接受为 docs-only 架构设计输入。它不接受 runtime
implementation、production authorization、真实 RIME、设备或产品行为。

## Independent review boundary

| Item | Value |
|---|---|
| Reviewer | Independent Architecture & Knowledge Steward（与设计 Executor 分离） |
| Design package | [`runtime design package`](../plans/typo-correction-002-second-stage-recall-runtime-design-2026-09-21.md) |
| Assignment | [`runtime design Assignment`](../assignments/typo-correction-002-second-stage-recall-runtime-design-001.md) |
| Review Authorization | [`AUTH-TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-ARCHITECTURE-001.md) |
| Source worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-design-001/Universe Keyboard` |
| Source commit | `4d1050f4b677494e06448cb40a83ef2da46d7b27` (`origin/main`) |

The reviewer read the design/Assignment and the exact source boundaries for the
current `12/8` synchronous controller loop, `180 ms` debounce, candidate query
interface and sidecar isolation. No files were changed and no build, RIME,
Simulator or device activity ran.

## Findings and residual disposition

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| AR-01 | High | The coverage selector, selected-group cap, `maxQueryAttempts` and matrix coverage proof remain candidate contracts, not a selected/tested algorithm. | `fix` before runtime implementation |
| AR-02 | High | Current production remains ordered synchronous `12/8` generation/query with at most four non-empty groups. Rank `55` shows that taking the first eight expanded hypotheses is insufficient, but does not create a valid selector. `180 ms` is debounce only. | `fix` before runtime implementation |
| AR-03 | High | Current refresh checks composition only before synchronous work. There is no per-query async operation fence or cancellation path after a sidecar call starts. | `fix` before runtime implementation |
| AR-04 | Medium | Runtime has candidate-text dedupe but no operation-scoped canonical corrected-input → opaque `GroupID` mapping bound to sidecar accounting. | `fix` before runtime implementation |

The design correctly preserves the intended boundaries: production `12/8` and
default-off `60/64/8` are distinct; sidecar must remain separate from the live
session; display-only output cannot create a second composition or commit path;
and routine diagnostics must not receive pinyin/candidate/host content.

## Required conditions before a future implementation Authorization

1. Select and test a deterministic coverage selector, including a bounded
   selected-group cap and an explicit `maxQueryAttempts`; prove the selected
   structural slice rather than relying on global rank order.
2. Specify a cancellable scheduler with a check before each sidecar call and
   after every result; stale/cancelled results must neither resolve a group nor
   publish candidate state.
3. Define canonical corrected-input mapping to an operation-scoped opaque
   `GroupID`; test duplicate/different/new-operation behavior without routine
   content logging.
4. Bind all later claims to a changed exact source/package snapshot and repeat
   independent Architecture/Quality review.

## Explicit non-claims

This review does not prove real RIME return content or ranking, candidate
visibility/selection, `12/8`/`60/64`/four-group/`180 ms` performance, QA-001,
INT-003, paired performance, `contextual 7/8`, device behavior, RIME query
cancellation, Product/Quality/Release Gate, publication or parent close.

## Next authorization boundary

Only a new, bounded runtime-preflight/implementation Authorization may address
AR-01 through AR-04. It must separately name selector/caps, scheduler fences,
GroupID/sidecar integration and focused tests. Real-RIME observability,
QA-001, paired performance and publication remain independently authorized
lanes.
