# T9 responsive pipeline R5-Rem-1 + R5-Rem-2 evidence — 2026-07-31

**Status:** `Dual review Pass with conditions; Arch P1-1 Closed 2026-07-31; Quality baseline 841/0; no Product Gate / Rem-Device yet`  
**Product auth:** Human Product Owner authorized Rem-1 + Rem-2 only (no Rem-3, no default-on, no ADR Accept, no Product Gate)  
**Design:** [`r5-remediation-design`](../assignments/t9-responsive-pipeline-001-r5-remediation-design.md)  
**Baseline tip before work:** `87d3e7c`  
**Formal R5 FAIL predecessor:** [`t9-responsive-pipeline-r5-formal-2026-07-31.md`](t9-responsive-pipeline-r5-formal-2026-07-31.md)

## Scope delivered

### Rem-1 (O1 observability)

| Item | Location |
|---|---|
| Marker grammar + lag helpers | `ResponsiveRimeFeltMetrics.swift` |
| Accept/visible/publish/burst tracker | `ResponsiveRimeFeltMetricsTracker` |
| ACCEPT on key accept | `KeyboardController.recordResponsiveAcceptMetrics` + insert path |
| PUBLISH lagMs / coalesced / VISIBLE / BURST | `performResponsivePresentationApply` |
| Unit tests | `ResponsiveRimeFeltMetricsTests` (3) |

Markers (content-free):

```text
T9RESP marker=ACCEPT action=k rev=… pending=… epoch=… fixture=T9RESP-R5P
T9RESP marker=VISIBLE lagMs=… rev=… source=engine fixture=T9RESP-R5P
T9RESP marker=PUBLISH lagMs=… rev=… pendingAfter=… coalesced=0|1 fixture=T9RESP-R5P
T9RESP marker=BURST count=… windowMs=… fixture=T9RESP-R5P
```

(Existing PATH / epoch-rev PUBLISH preflight lines retained where dual-gate.)

### Rem-2 (O2 presentation coalesce)

| Item | Location |
|---|---|
| MainActor R2 uses real `.latestOnly` | `rebuildResponsiveRimeCoordinatorIfNeeded` (removed force-`everyResult`) |
| Dual-gate UI coalesce under pending ≥ 2 | `applyResponsivePublishedSnapshot` + `scheduleDualGateCoalescedPresentation` |
| R3 context → applied head (last pk context) | `performResponsivePresentationApply` |
| Wire coalesce test | `testDualGateCoalescesPresentationUnderOwnerBacklog` |
| R2 latestOnly burst paint test | `testLatestOnlyPublishCountIsBelowKeyCountUnderBurst` |

**Unchanged:** engine FIFO (no drop/reorder); dual-gate default **off**; no provisional L1 (Rem-3); no ADR Accept; no Product Gate.

## Tests

```bash
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveRimeFeltMetricsTests|ThreadAffineRimeWireTests|ResponsiveRimeR2CoordinatorTests|ResponsiveRimePipelineTests'
swift test --package-path Packages/KeyboardCore
```

| Suite | Result |
|---|---|
| Focused (felt + wire + R2 + pipeline) | **48 / 0** |
| KeyboardCore full | **841 / 0** |

## Explicit non-claims

- Formal R5 FAIL not overturned (no new Human A/B on device in this knife)
- Rem-3 provisional L1 not implemented
- Release default-on / ADR 0025 Accept / Product Gate
- Numeric product SLO
- Subjective non-stutter proof

## Independent dual review (2026-07-31)

| Role | Verdict | File |
|---|---|---|
| 🏛️ Architecture | **Pass with conditions** (0 P0, **1 P1**, 2 P2, 3 P3) | [`t9-responsive-pipeline-001-r5-rem-1-2-architecture-review.md`](../assignments/t9-responsive-pipeline-001-r5-rem-1-2-architecture-review.md) |
| 🧪 Quality | **Pass with conditions** (re-run focused **48/0**, full **841/0**; 0 P0, 0 P1) | [`t9-responsive-pipeline-001-r5-rem-1-2-quality-review.md`](../assignments/t9-responsive-pipeline-001-r5-rem-1-2-quality-review.md) |

### Arch P1-1 Closed (2026-07-31)

| Fix | Location |
|---|---|
| `responsivePresentationGeneration` bump on clear/abandon | `clearResponsiveKeyApplyContexts` |
| Coalesce Task generation capture + fail-closed | `scheduleDualGateCoalescedPresentation` |
| Live epoch + revision gate | `isLivePresentationSnapshot` / `performResponsivePresentationApply` |
| Owner diagnostics expose `sessionEpoch` | `ThreadAffineRimeOwnerDiagnostics` |
| Test | `testDualGateAbandonDropsDeferredCoalescedPresentation` |

Focused re-run after fix: Wire + R2 + Felt **26/0** (includes new abandon test). Full suite recommended before Rem-Device.

## Residual

1. Quality optional re-review of P1-1 delta (not required for device prep if Product accepts Executor + Arch close).
2. Device re-pair (Rem-Device) — next Product auth.
3. Coalesce threshold = 2 is a named constant, not an SLO.
4. No L1 provisional — long stall may still feel empty (Rem-3).
5. Path/auto-anchor under multi-key latestOnly uses **last** context only (intentional).
