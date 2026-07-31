# T9 responsive pipeline R5-Rem-3 — Executor evidence — 2026-07-31

**Status:** `Executor complete + P1 remediation — awaiting re-review disposition`  
**Product authorization:** Human Product Owner selected implement option **1** after
Rem-3 design freeze + Amendment A (dual design reviews @ `617773e` / `7524f34`)  
**Implementation tip (initial):** `9b9bbeb`  
**Design:** [`../assignments/t9-responsive-pipeline-001-r5-rem-3-design.md`](../assignments/t9-responsive-pipeline-001-r5-rem-3-design.md)  
**Independent implementation reviews (on `9b9bbeb`):**  
  Arch [`../assignments/t9-responsive-pipeline-001-r5-rem-3-implementation-architecture-review.md`](../assignments/t9-responsive-pipeline-001-r5-rem-3-implementation-architecture-review.md) — Pass with conditions (**P1=2**)  
  Quality [`../assignments/t9-responsive-pipeline-001-r5-rem-3-implementation-quality-review.md`](../assignments/t9-responsive-pipeline-001-r5-rem-3-implementation-quality-review.md) — Pass with conditions (**P1=2**; suite re-run blocked in that subagent)  
**Non-claims:** no Product Gate / ADR Accept / default-on / Rem-Device rewrite /
Formal R5 FAIL rewrite / device Rem-3-Device knife

## Scope delivered

| Item | Implementation |
|---|---|
| Pure L1 ledger + `·`×N builder | `ResponsiveProvisionalComposition.swift` |
| Dual-gate accept → L1 paint | `applyResponsiveProvisionalL1IfEligible` after affine `scheduleProcessKey` |
| L2 atomic replace + revision floor | `isLivePresentationSnapshot` + clear mirror on engine apply |
| provisionalAhead fail-closed | candidate / Path / cycle / Space |
| VISIBLE provisional→engine | `ResponsiveRimeFeltMetricsTracker.recordVisible` upgrade path |
| L1_SKIP closed reasons | `ResponsiveProvisionalL1SkipReason` |
| Delete path A | unchanged `performOrderedNow` (no async Delete redesign) |
| Gate-off | no L1 |

## Validation

### Initial Executor (tip `9b9bbeb`)

| Command | Result |
|---|---|
| focused Rem-3 + wire + felt | **18/0** |
| full KeyboardCore | **850/0** |

### After Arch/Quality P1 remediation (same day)

| Command | Result |
|---|---|
| `swift test --package-path Packages/KeyboardCore --filter 'ResponsiveProvisional\|ThreadAffineRimeWire'` | **17/0** (includes Return-no-commit + coalesce+L1) |
| `swift test --package-path Packages/KeyboardCore` | **852/0** |

### P1 remediation (closes dual-review P1s)

| Finding | Fix |
|---|---|
| Arch/Quality P1-1 host commit `·` | Return / direct-text / finishActive* / mode switch abandon L1 **without** host commit |
| Arch P1-2 Delete ledger sticky | `alignResponsiveProvisionalAfterOrderedEngineApply` on dual-gate engine apply path |
| Quality P1-2 coalesce+L1 test | `testCoalesceBacklogStillPaintsL1` |
| Quality Return case | `testReturnWhileAheadDoesNotCommitDots` |

### Focused Rem-3 cases

- Pure builder: dots × N; no digits; mirror append/clear
- Tracker: provisional then engine at same revision
- Dual-gate blocked owner: 8× digit accept → composition `········` while stalled
- Selection while ahead → empty effects
- Return while ahead → no `·` in host text
- Coalesce backlog → L1 still paints dots
- After flush: L1 cleared; no dots remain
- Gate-off: no L1
- Abandon: clears L1

## Explicit residuals / not run

- Formal Arch/Quality **re-review** of P1 remediation (optional; addendum disposition recommended)
- Physical Rem-3-Device A/B
- RimeBridgeTests / main scheme xcodebuild on this machine (CI on push)
- Numeric product SLO lock
