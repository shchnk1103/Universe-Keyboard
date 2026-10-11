# Typo Correction Benchmark v2.0 Incremental Registry

> **Status:** Active — bounded observations and accepted P1/P2 evidence recorded; parent Gate/Close pending.
>
> **Registry version:** `2.2.0`
>
> **Published:** 2026-07-15 Asia/Shanghai
>
> **Work Items:** [`TYPO-CORRECTION-002`](assignments/typo-correction-002.md), [`TYPO-CORRECTION-003`](assignments/typo-correction-003.md)
>
> **Authority:** [`Contextual Typo Correction Product Contract`](TYPO_CORRECTION.md), [ADR 0015](architecture/decisions/0015-contextual-multi-error-typo-correction.md) and [ADR 0016](architecture/decisions/0016-progressive-contextual-recall-preflight.md)

## Purpose

This incremental Registry adds V2 identities without modifying the frozen v1.0 Registry. It records the bounded, local multi-error recovery path and its evidence gates; an identifier here does not itself claim a passing device result.

## V2 Contract Registry

| Contract ID | Name | Frozen product intent |
|---|---|---|
| `TC2-CTR-STB-001` | Bounded Contextual Search | Search accepts only 8–30 character compositions, at most two edits, a 12-state first beam and eight final hypotheses. |
| `TC2-CTR-STB-002` | Display-only Multi-edit Position | A multi-edit result never receives automatic first-position promotion. |
| `TC2-CTR-INT-001` | Sidecar Session Isolation | Corrected-input queries use an independent RIME session and cannot alter the live composition. |
| `TC2-CTR-INT-002` | Debounced Query Scheduling | Multi-error generation and RIME queries run only after a 180 ms cancellable input pause, never in the synchronous key path. |
| `TC2-CTR-INT-003` | Real-RIME Query Seam | Production bootstrap supplies `RimeEngineImpl`; the fallback provider remains only a test/degraded path. |
| `TC2-CTR-QA-001` | Device Acceptance Boundary | Environment-specific acceptance may use only the designated Device Hub iOS 27 iPhone 17 Pro Max simulator. |
| `TC2-CTR-EXP-001` | Progressive Recall Isolation | Expanded recall planning is default-off and cannot execute production RIME queries or change candidate UI. |
| `TC2-CTR-EXP-002` | Progressive Recall Boundedness | The preflight retains at most 60 first-layer states, 64 final hypotheses and eight hypotheses per batch. |
| `TC2-CTR-EXP-003` | Scoring Provenance Boundary | Recall inclusion does not prove sentence intent; cross-input scores require a supported source and real-RIME evidence. |

## V2 Case Registry

| Case ID | Primary Contract | Frozen case | Required evidence | Current state |
|---|---|---|---|---|
| `TC2-CASE-STB-001` | `TC2-CTR-STB-001` | 7-character and 31-character inputs | Core unit test | Passed locally |
| `TC2-CASE-STB-002` | `TC2-CTR-STB-001` | A sentence-like synthetic input produces at most eight two-edit hypotheses | Core unit test | Passed locally |
| `TC2-CASE-STB-003` | `TC2-CTR-STB-002` | Two-edit Chinese phrase candidate stays display-only | Core unit test | Passed locally |
| `TC2-CASE-INT-001` | `TC2-CTR-INT-003` | Controller uses its dedicated corrected-input query seam | Core unit test | Passed locally |
| `TC2-CASE-INT-002` | `TC2-CTR-INT-001` | Sidecar query preserves live composition | Real rime_ice runtime fixture | Default fixture remains skipped; separate bounded sidecar Run recorded (see dated evidence below) |
| `TC2-CASE-INT-003` | `TC2-CTR-INT-002` | Rapid typing cancels stale contextual work | iOS UI/Device Hub trace | Bounded Pass with conditions; query-density/P1/P2 follow-up accepted, not whole-app performance Pass |
| `TC2-CASE-QA-001` | `TC2-CTR-QA-001` | Curated multi-error sentence recovers intended candidate without interaction regression | Designated Device Hub iOS 27 iPhone 17 Pro Max simulator | Designated simulator target observed (reval-08); child Closed, parent Gate pending |
| `TC2-CASE-EXP-001` | `TC2-CTR-EXP-001` | Progressive planner is not referenced by production controller/UI code | Source audit + Core tests | Passed locally |
| `TC2-CASE-EXP-002` | `TC2-CTR-EXP-002` | `wimenjintianquhongyuan` recall pool contains `womenjintianqugongyuan` without an allowlist | Core unit test | Passed locally |
| `TC2-CASE-EXP-003` | `TC2-CTR-EXP-002` | Progressive plan contains at most 64 hypotheses and each batch at most eight | Core unit test | Passed locally |
| `TC2-CASE-EXP-004` | `TC2-CTR-EXP-003` | Pure/Fake evidence cannot populate a semantic or Product acceptance result | Documentation/source audit | Boundary published |

## Evidence Interpretation

- KeyboardCore tests prove local bounds, safety assessment and the injectable query seam. They do not prove RIME language-model quality.
- The 2026-07-15 designated iOS 27 iPhone 17 Pro Max Simulator UI baseline (8 passed, 1 designed skip) proves existing activation and interaction coverage only. It does not exercise the contextual phrase-recovery scenario and therefore does not satisfy `TC2-CASE-QA-001`.
- Historical pure-Core preflight evidence covers the default-off 60/64/8 planner. Later reval-08 records the exact target observation on its deployed package; it does not prove every phrase or every search budget. The public RIME C API supplies no supported cross-hypothesis candidate-quality value; opaque ABI fields must not be interpreted as one.
- The sidecar smoke test is intentionally skipped when no complete rime_ice fixture is supplied; a skipped fixture is not a pass.
- `TC2-CASE-QA-001` remains the sole Product-acceptance gate for the requested real-device restriction.
- The prepared [Device Hub Validation Record](evidence/typo-correction-002-device-hub-validation.md) is historical unavailable evidence; the dated observations below supersede only their named cases.

## 2026-10-11 scoped evidence synchronization

| Case / stage | Existing evidence | Interpretation |
|---|---|---|
| INT-002 | [Sidecar reval-01](evidence/typo-correction-002-sim-run-2026-09-19-sidecar-reval-01.md) | Direct real-sidecar isolation observation; default missing-fixture skip remains a skip |
| INT-003 | [Stale-cancel Product Capture](evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md) | Bounded observation; fence_discarded=0 retained, no Gate inferred |
| QA-001 | [Target observed reval-08](evidence/typo-correction-002-sim-run-2026-09-22-qa001-reval-08-target-observed.md) / [Closed child](assignments/typo-correction-002-qa001-revalidation-08-fresh-package-001.md) | Exact designated simulator / fresh package / target selectable; earlier July baseline does not certify this result |
| P1 / final matrix | [Delivery audit](evidence/typo-correction-002-fixed-candidate-delivery-audit-001.md) / [Final CI](evidence/typo-correction-002-final-ci-validation-001.md) | Fixed baseline bounded convergence and full default CI, skips explicit |
| P2 query cost | [Accepted contract](product-decisions/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LOCAL-EVIDENCE-REQUIREMENTS-001.md) / [Run](evidence/typo-correction-002-int003-query-cost-p2-partial-export-001.md) | Six cases plus extra retained; 61 provider-facade calls, not native nonempty-result cost or whole CPU/UI/memory proof |
| Parent performance | [Human-approved scope amendment](product-decisions/TYPO-CORRECTION-002-PARENT-PERFORMANCE-SCOPE-PROPOSAL-001.md) | No further paired capture required; unknown whole-app performance remains explicit |

No frozen case/contract was changed. The 180 ms **scheduler pause** remains; a Human typing cadence below 180 ms is not a mandatory pass condition. No restored RimeRuntimeProvenance, Gate, Release or parent Close. Existing evidence is not a certification of a future integration candidate.
