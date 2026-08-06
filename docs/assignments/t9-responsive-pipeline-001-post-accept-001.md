# Assignment: T9-RESPONSIVE-PIPELINE-001 / POST-ACCEPT-001 — Binding Hygiene + R3 Residual

Policy version: 1.0.0

**Task ID:** `POST-ACCEPT-001`  
**Lifecycle status:** `Completed — hygiene + R3 inventory evidence recorded; independent review optional; Product Gate not claimed`  
**Date / timezone:** `2026-08-06 Asia/Shanghai`  
**Repository Change Type:** `Documentation` + `Tests` (+ `Implementation` only if a
contract gap requires Core fix under default-off)  
**Product Decision:**
[`PD-…-POST-ACCEPT-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-POST-ACCEPT-001-authorization.md)  
**Parent:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Architecture:** [`ADR 0025 Accepted`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)  
**Predecessor:** [`ADR-0025-ACCEPT-001`](adr-0025-accept-001.md)

## Authority

- **Assignment Authority:** Product Lead  
- **Decision Source / Date:** PD-…-POST-ACCEPT-001; Human authorization
  2026-08-06 Asia/Shanghai  
- **Product Approver:** Human Product Owner  

## Boundary

### Scope

1. ADR 0025 Follow-up **#9**: refresh `swift6-migration.md` ownership for
   gate-off (ADR 0004) vs gate-on (serial owner) paths.  
2. ADR 0025 Follow-up **#10**: document dual input pipeline in
   `input-pipeline-and-marked-text.md`.  
3. R3 residual inventory (Delete, selection, recover, visibility, ordered
   enqueue, epoch invalidation, fail-closed stale interaction) mapped to
   existing tests and open debts (Accept dossier R-05 / R-09, P2 debts).  
4. Close **automatable** Core gaps found by the inventory; no default-on.  
5. KeyboardCore validation evidence.  
6. State sync: Dashboard / parent lifecycle language only.

### Non-goals

- Product Gate / Release default-on / SLO  
- Multi-device canary reopen  
- UIKit Extension candidate-prefetch device matrix (P2 UI debt — separate)  
- P3-D1 T02/T03 host accessibility reopen (Product Hold)  
- `@unchecked Sendable`  

### Required Inputs

- ADR 0025 Accepted + §6/§8 gate contract  
- Accept dossier residuals R-05 / R-09  
- Existing Responsive* KeyboardCore tests  
- P2 regression matrix evidence  

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer  
- **Executor:** Current Grok primary agent  
- **Environment Executor:** Current agent for local `swift test --package-path
  Packages/KeyboardCore` only  
- **Human Dependency:** `Not Applicable` for this phase (no device)  
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward (required if
  ownership/pipeline contracts change beyond hygiene, or new Core behavior)  
- **Quality Reviewer:** 🧪 Quality Maintainer (required for new tests /
  residual-close claims)

## Gates

### Entry Criteria

- [x] ADR 0025 Accepted  
- [x] Product Decision for this phase  
- [x] Default-off non-claim locked  
- [x] Responsibilities assigned without `UNKNOWN`  

### Exit Criteria

- [x] `swift6-migration.md` dual-path ownership updated  
- [x] `input-pipeline-and-marked-text.md` dual pipeline documented  
- [x] R3 residual inventory published:
      [`evidence/…-post-accept-001-r3-residual-inventory-2026-08-06.md`](../evidence/t9-responsive-pipeline-post-accept-001-r3-residual-inventory-2026-08-06.md)  
- [x] Automatable Core gaps: **none requiring new code**; deferred rows owned
      by UI/device/Product Gate  
- [x] KeyboardCore: Responsive **98/0**, full **906/0** (2026-08-06)  
- [x] Explicit non-claims retained  
- [x] Dashboard / parent Assignment / KNOWLEDGE_INDEX state synced  

### Stop Conditions

- Attempt to enable Release default-on or claim Product Gate  
- Isolation policy weakening  
- Scope expansion into canary multi-device or auto-anchor  
- Required field becomes `UNKNOWN`  

## Handoff

- **Handoff Target:** Product Lead after evidence; optional R6 Product Gate only
  under a **new** Decision  
- **Required Handoff Content:** inventory table, tests run, remaining debts  
- **Revalidation Trigger:** ADR 0025 substantive rewrite; default-on Decision  

## Explicit non-claims

- Not Product Gate  
- Not default-on  
- Not SLO  
- Not Formal R5 FAIL rewrite  
