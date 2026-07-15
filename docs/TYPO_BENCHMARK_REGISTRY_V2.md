# Typo Correction Benchmark v2.0 Incremental Registry

> **Status:** Active — implementation evidence is partial; Product acceptance is pending.
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
| `TC2-CASE-INT-002` | `TC2-CTR-INT-001` | Sidecar query preserves live composition | Real rime_ice runtime fixture | Skipped: fixture unavailable |
| `TC2-CASE-INT-003` | `TC2-CTR-INT-002` | Rapid typing cancels stale contextual work | iOS UI/Device Hub trace | Pending |
| `TC2-CASE-QA-001` | `TC2-CTR-QA-001` | Curated multi-error sentence recovers intended candidate without interaction regression | Designated Device Hub iOS 27 iPhone 17 Pro Max simulator | Pending: contextual scenario not executed |
| `TC2-CASE-EXP-001` | `TC2-CTR-EXP-001` | Progressive planner is not referenced by production controller/UI code | Source audit + Core tests | Passed locally |
| `TC2-CASE-EXP-002` | `TC2-CTR-EXP-002` | `wimenjintianquhongyuan` recall pool contains `womenjintianqugongyuan` without an allowlist | Core unit test | Passed locally |
| `TC2-CASE-EXP-003` | `TC2-CTR-EXP-002` | Progressive plan contains at most 64 hypotheses and each batch at most eight | Core unit test | Passed locally |
| `TC2-CASE-EXP-004` | `TC2-CTR-EXP-003` | Pure/Fake evidence cannot populate a semantic or Product acceptance result | Documentation/source audit | Boundary published |

## Evidence Interpretation

- KeyboardCore tests prove local bounds, safety assessment and the injectable query seam. They do not prove RIME language-model quality.
- The 2026-07-15 designated iOS 27 iPhone 17 Pro Max Simulator UI baseline (8 passed, 1 designed skip) proves existing activation and interaction coverage only. It does not exercise the contextual phrase-recovery scenario and therefore does not satisfy `TC2-CASE-QA-001`.
- The canonical two-error phrase is proven only in the default-off 60/64/8 recall preflight, not inside the production 12-state/eight-hypothesis budget. The public RIME C API supplies no supported cross-hypothesis candidate-quality value; opaque ABI fields must not be interpreted as one.
- The sidecar smoke test is intentionally skipped when no complete rime_ice fixture is supplied; a skipped fixture is not a pass.
- `TC2-CASE-QA-001` remains the sole Product-acceptance gate for the requested real-device restriction.
- The prepared [Device Hub Validation Record](evidence/typo-correction-002-device-hub-validation.md) owns the current unavailable observation and the required fresh-run scenarios.
