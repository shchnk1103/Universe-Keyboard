# Architecture Review: T9-RESPONSIVE-PIPELINE-001 / R5-Rem-Device

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent）  
**Date:** `2026-07-31 Asia/Shanghai`  
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Phase:** R5-Rem-Device — Human A/B after Rem-1+2+P1-1（direction only）  
**Device evidence:** [`../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md)  
**Predecessor Formal FAIL:** [`../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md)  
**Prior code review:** [`t9-responsive-pipeline-001-r5-rem-1-2-architecture-review.md`](t9-responsive-pipeline-001-r5-rem-1-2-architecture-review.md)（P1-1 Closed）  
**ADR 0025:** remains **Proposed**

| Field | Value |
|---|---|
| **Verdict** | **Pass with conditions** |
| **P0** | 0 |
| **P1** | 0 |
| **P2** | 3 |
| **P3** | 3 |

## Verdict (scoped)

**Direction PASS (key-feel)** is justified for one Debug A→B pair after Rem-1+2+P1-1:

- vs gate-off A: subjective stall ~2 → ~0–1; integrity OK  
- vs Formal dual-gate FAIL: no multi-second freeze-then-burst; progressive lag instead  
- Felt metrics used correctly; KEY END not sole claim; VISIBLE lag spikes disclosed  

**Not** Product Gate / ADR Accept / default-on / Rem-3 complete / multi-pair Gate evidence.

## Conditions

1. Scope lock: key-feel direction only.  
2. Attribution lock: do not credit O2 coalesce alone (`coalesced=0` this pair).  
3. Formal FAIL lock: Formal R5 remains **historical FAIL**; successor direction PASS for key-feel only — avoid unqualified “superseded”.  
4. Metric lock: cite VISIBLE with p95/worst or ≥100 counts; ban KEY END or p50-only smoothness claims.  
5. Next Gate needs separate auth (immutable SHA, multi-pair or stress, Release-like optional).

## Findings

### P2

| ID | Finding |
|---|---|
| **P2-1** | O2 coalesce under-exercised (`coalesced=0`, pending max 1) |
| **P2-2** | “superseded” wording risk for Formal FAIL history |
| **P2-3** | Log truncation + dirty tree without immutable device knife SHA |

### P3

Rem-3 open; single pair Debug-only; dual PUBLISH grammar carry-over.

## Non-claims held

Product Gate, default-on, ADR Accept, Rem-3 done, numeric SLO, Formal FAIL rewrite.

## Handoff

Product may record Rem-Device direction PASS under conditions; Quality re-ran 842/0 separately; Gate remains closed.
