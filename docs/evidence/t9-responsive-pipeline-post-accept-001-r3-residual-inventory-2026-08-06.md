# POST-ACCEPT-001 — R3 Residual Contract Matrix Inventory

**Date / timezone:** `2026-08-06 Asia/Shanghai`  
**Assignment:** [`POST-ACCEPT-001`](../assignments/t9-responsive-pipeline-001-post-accept-001.md)  
**Architecture:** ADR 0025 **Accepted** (gate-off Release default retained)  
**Branch tip at inventory start:** `d031976` (ADR Accept docs) + working tree  
**Scope:** Map R3 residual rows to existing automated evidence; identify
automatable Core gaps vs deferred Product Gate / device debts.

## Legend

| Status | Meaning |
|---|---|
| **Covered** | Automated KeyboardCore evidence exists under default-off gated tests |
| **Partial** | Covered for Core/Fake path; Extension UIKit / real-device / host still open |
| **Open (deferred)** | Explicitly out of this phase or Product-held |
| **Gap (this phase)** | Automatable Core hole to close in POST-ACCEPT-001 |

## Matrix

| Contract row | Primary evidence (tests / docs) | Status | Notes |
|---|---|---|---|
| Ordered enqueue; no drop / no reorder | `ResponsiveRimePipelineTests` order/drain; `ResponsiveRimeR2CoordinatorTests` ordered keys | **Covered** | R1 + R2 coordinator |
| Accept does not wait on engine | Pipeline wall-time / deferred drain tests | **Covered** | Fake delay beds |
| Latest-only publish coalesce | Pipeline latest-only; R2 coordinator burst publish | **Covered** | Publish ≠ input drop |
| `sessionEpoch` bump clears pending | Pipeline epoch tests; R2 `testEpochBumpClearsPendingAccepts` | **Covered** | |
| Reset advances epoch + invalidates trailing | Pipeline `testEnqueuedResetAdvancesEpoch…` | **Covered** | |
| Recover advances epoch | Pipeline `testEnqueuedRecoverAdvancesEpoch` | **Covered** | Fake path |
| Delete ordered after pending keys | Pipeline + R2 `performOrderedDelete` / bridge delete order | **Covered** | |
| Stale candidate selection fail-closed | Pipeline selection tests; R2 owner stale select | **Covered** | |
| Stale Path replace fail-closed | Pipeline path-stale tests | **Covered** | |
| Dual-gate stale action matrix (candidate/Path/Space/page) | `ResponsiveProvisionalCompositionTests.testDualGateStaleActionMatrix…` | **Covered** | P2 matrix core |
| Ordered Delete refreshes stable shadow | Provisional `testOrderedDeleteRefreshesStableShadow…` | **Covered** | P1-D2 residual close |
| Visibility abandon clears L1 / bumps epoch | Provisional abandon tests; R2 abandon context clear | **Covered** | Core |
| Gate-off restores synchronous engine | R2 `testGateOffAfterOnRestoresUnderlyingEngine` | **Covered** | ADR 0004 path intact |
| Gate defaults off | R2 `testGateDefaultIsOffAndControllerStaysSynchronous` | **Covered** | |
| Marked text never shows internal T9 digits | Broader T9 / PartialCommit suite (parent contracts) | **Partial** | Not re-proven in this inventory run |
| 26-key unchanged with gate off | Parent non-goal + gate-default tests | **Partial** | No dedicated POST-ACCEPT re-matrix |
| UIKit Extension candidate-prefetch no-op | P2 debt | **Open (deferred)** | Needs UI / separate phase |
| Broader host-history proof after abandon | P2 debt / Accept R-05 | **Partial** | Core abandon covered; host proxy depth limited |
| Real-device / Release performance / jetsam | P2 / canary directional only | **Open (deferred)** | Product Gate territory; no SLO |
| P3-D1 T02/T03 host accessibility lifecycle | Product Hold | **Open (deferred)** | R-06 |
| CANARY process residuals (FA attestation, kill marker, thermal) | Accept R-01…R-03 | **Open (deferred)** | Process, not Core contract |
| Full R3 “every session API on owner under all lifecycle edges” | Live-session inventory + canary design freezes | **Partial** | Design freeze + canary; not every edge automated |

## Automatable Core gaps found this phase

| ID | Gap | Disposition |
|---|---|---|
| G-01 | Dedicated **recover-then-stale-publish** assertion on R2 coordinator (not only R1 pipeline) | **Close in this phase** if missing — verify before coding |
| G-02 | Explicit **visibility-abandon then ordered Delete** on dual-gate controller path | Check provisional suite; add only if absent |
| G-03 | Doc hygiene only (swift6 + input-pipeline) | **In scope** — Follow-up #9/#10 |

### G-01 / G-02 verification notes

R2 coordinator already has:

- `testEpochBumpClearsPendingAccepts`
- `testAbandonClearsResponsiveKeyApplyContexts`
- `testPerformOrderedDeleteAfterKeys` / delete-through-bridge order

Provisional suite already has abandon + ordered Delete + stale matrix.

**Conclusion:** No P0/P1 Core automation hole blocking R3 residual *maturity claim*
at KeyboardCore level. Remaining R3 “open residual” language is correctly
**Partial / deferred** (UIKit host, real-device, full live-API edge catalog), not
a missing Fake/Core bed.

## Phase claim (honest)

POST-ACCEPT-001 **closes** ADR Follow-up **#9 and #10** and **records** that
Core-level R3 contract rows are **Covered/Partial** with deferred rows owned by
Product Gate / UI / device phases.

It does **not** claim:

- Product Gate  
- default-on  
- full live-session API edge closure  
- performance SLO  

## Validation commands (this phase)

```bash
swift test --package-path Packages/KeyboardCore --filter Responsive
swift test --package-path Packages/KeyboardCore
```

### Results (`2026-08-06 Asia/Shanghai`, local)

| Command | Result |
|---|---|
| `swift test --package-path Packages/KeyboardCore --filter Responsive` | **98 tests, 0 failures** |
| `swift test --package-path Packages/KeyboardCore` | **906 tests, 0 failures** |

No production code changes were required in this phase: Core R3 rows were already
covered by existing Responsive* suites; work closed Follow-up **#9/#10** docs and
recorded residual honesty for deferred UI/device/Product Gate rows.
