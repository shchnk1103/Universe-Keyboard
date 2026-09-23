# Evidence: Cadence-003 → Product INT-003 gap matrix — 2026-09-23

## Identity

| Field | Value |
|---|---|
| **Kind** | Docs-only gap matrix (no capture; no Live AUTH) |
| **Tip SHA** | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| **Cadence Run** | `TC2-SIM-20260922-225841-INT003-CADENCE-003` |
| **Cadence evidence** | [`typo-correction-002-int003-cadence-2026-09-22-003.md`](typo-correction-002-int003-cadence-2026-09-22-003.md) |
| **Product residual** | [`PD-TYPO-CORRECTION-002-INT003-CADENCE-003-RESIDUAL`](../product-decisions/TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL.md) |
| **Observability audit** | [`typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md`](typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md) |
| **Registry** | `TC2-CASE-INT-003` / `TC2-CTR-INT-002` still **Pending** |
| **Recorded at** | 2026-09-23T09:30:00+08:00 |

## Purpose

Map what Cadence-003 **cleared** versus what a formal Product INT-003 claim still **needs**. Does not invent a Product Gate.

## Gap matrix

| Item | Cadence-003 status | Product INT-003 need | Evidence pointer | Next AUTH / action |
|---|---|---|---|---|
| Same-process smoke→rapid | **Cleared for Run** (`F9245C6C-…` / `A7A38761-…`) | Must repeat on Product capture Run | Cadence-003 evidence; Capture-002 contrast | Proposed Product capture AUTH (Live later) |
| Rapid &lt;180 ms inter-key starts | **Cleared for Run** (3/3: 158.984 / 153.957 / 136.267) | Long synthetic composition continuous &lt;180 then pause | Cadence-003; Device Hub scenario table | Same Proposed capture; longer stimulus than Cadence-003’s short rapid slice |
| Long composition scenario (≥8 chars; registry target-length intent) | **Not exercised** (Cadence was cadence-bar only; no phrase/target claim) | Long synthetic composition per Device Hub / registry | Device Hub INT-003 row; Registry INT-003 Pending | Product capture Assignment scope |
| No contextual candidate while typing | **Not proven** (no candidate-select / contextual observation in Cadence) | Required observation | Device Hub; audit (journal weak) | Human attestation + journal lifecycle; stop rules if disputed |
| Stale cancel proof | **Not proven** | Required for formal INT-003 | Reval-02 “no cancellation marker”; audit | Human+journal bounded obs **or** future implementation AUTH for marker — **do not implement now** |
| Post-pause single lookup | **Not proven** | Only final unchanged composition gets post-pause lookup | Device Hub INT-003 row | Product capture observation plan |
| Cancel marker in Diagnostics journal | **Absent** (schema gap on tip) | Prefer explicit marker; Product may accept absence with conditions | Audit § present vs missing | Docs-only path vs separate implementation AUTH |
| Bundle SHA freeze (main-app / extension) | **Accepted with condition** (tip + Sim + journal hashes bound Cadence) | Product may require fresh package/bundle hashes | Product residual; Arch review | Bind on Live capture / Product Gate AUTH as demanded |
| `RimeRuntimeProvenance` gap | **Retained capability-gap** | Not required to invent on this path; do not restore under preflight | Residual; QA-001 reval-08 Arch | Separate lane only; **OUT** of this Proposed AUTH |
| Third-runtime Architecture / Quality re-review | **Accepted with condition** (same-lineage OK for Cadence residual) | Product may require third-runtime before Gate | Residual; Arch/Quality reviews | Optional separate AUTH if Product demands |
| Product Gate AUTH | **Not granted** | Explicit Product Gate / Close AUTH after capture package | Residual “Not granted” | **After** Live capture + reviews; not this Proposed preflight |
| App Group container arm + HF | **Proven method** (Cadence Pass) | Required precondition for Product capture | Cadence-003 arm binding | Carry into Proposed capture AUTH |
| Dynamic JSONL + even-index touch starts | **Proven method** | Required measurement method | Cadence-003 tables | Carry into observation plan |
| Designated Simulator only | Assumed Cadence target `06C5BC3E-…` | **Required** for Product claim path | Device Hub | Freeze UDID on Live AUTH |

## Explicitly OUT of scope (this preflight + Proposed capture AUTH)

| Out-of-scope item | Why listed |
|---|---|
| QA-001 Product Gate | Separate case / AUTH lineage |
| Paired performance | Separate performance lane |
| Physical device as substitute for designated Simulator | Device Hub forbids for Product claim |
| Parent `TYPO-CORRECTION-002` Close | Residual and parent remain Active |
| Release / TestFlight | Not authorized |
| Swift / ObjC / RIME implementation under this AUTH | Docs + Proposed only |
| Restore `RimeRuntimeProvenance` | Retained gap; separate lane |
| Marking AUTH Live / running Simulator from office-hours docs-only | Human Live gate required first |

## Summary

Cadence-003 cleared **process-churn** and **rapid &lt;180** residuals for its Run. Product INT-003 still needs a **new Live capture** covering long composition, no-contextual-while-typing, stale-cancel (marker-aware), and post-pause single lookup — with cancel observability treated per the 2026-09-23 audit. This matrix does not Close parent or grant Product Gate.

## Non-claims

- No Live capture; no Simulator; no Swift edits; no push/PR/merge; no parent Close.
