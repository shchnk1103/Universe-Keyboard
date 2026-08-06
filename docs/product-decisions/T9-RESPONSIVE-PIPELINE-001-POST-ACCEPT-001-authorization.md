# Product Decision: T9-RESPONSIVE-PIPELINE-001 / POST-ACCEPT-001 — Post-Accept Binding Hygiene + R3 Residual Close-in

**Decision ID:** `PD-T9-RESPONSIVE-PIPELINE-001-POST-ACCEPT-001`  
**Lifecycle status:** `Recorded — Phase Completed 2026-08-06 (hygiene + R3 inventory; Product Gate / default-on not authorized)`  
**Date / timezone:** `2026-08-06 Asia/Shanghai`  
**Parent:** [`PD-T9-RESPONSIVE-PIPELINE-001`](T9-RESPONSIVE-PIPELINE-001-authorization.md)  
**Predecessor:** [`PD-…-ADR-0025-ACCEPT`](T9-RESPONSIVE-PIPELINE-001-ADR-0025-ACCEPT-authorization.md)  
**Assignment:** [`POST-ACCEPT-001`](../assignments/t9-responsive-pipeline-001-post-accept-001.md)  
**Architecture:** [`ADR 0025 Accepted`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)

## Authority

- **Product Approver:** Human Product Owner / Product Lead  
- **Decision source / date:** In-session authorization 2026-08-06 Asia/Shanghai:
  “不用了，先开始正式的工作吧，我授权给你。”  
- **Scope of authorization:** formal post-Accept engineering under ADR 0025 as
  binding design SoT, **without** Product Gate or Release default-on.

## Bound Product Decision

### 1. Authorize POST-ACCEPT-001

Product Lead authorizes Assignment `POST-ACCEPT-001` to:

1. Apply ADR 0025 Follow-up **#9 / #10** architecture Source-of-Truth hygiene:
   - `docs/architecture/swift6-migration.md` ownership table for dual-path
   - `docs/architecture/input-pipeline-and-marked-text.md` dual pipeline diagram
2. Inventory the R3 residual contract matrix (Delete / selection / recover /
   visibility / ordered enqueue / fail-closed) against existing automated
   evidence and close **automatable Core gaps** behind default-off gates.
3. Run focused / full KeyboardCore validation as evidence.
4. Update Dashboard / parent Assignment lifecycle language for this phase only.
5. Hand off residuals that remain Product Gate– or device-bound without claiming
   them closed.

### 2. Explicit non-authorization

This Decision **does not** authorize:

- Release default-on or user-facing enablement of the responsive path  
- Product Gate / App Store / shipping claims  
- Performance SLO locks  
- Multi-device canary reopen  
- Auto-anchor expansion  
- Changing ordinary Release gate defaults  

### 3. Relationship to Accept

ADR 0025 is already **Accepted** as gated design SoT. This phase implements
**binding-document and residual-contract maturity**, not re-opening Accept.

## Implementation follow-through

| Action | Authorized? |
|---|---|
| Architecture doc hygiene (#9 / #10) | **Yes** |
| R3 residual inventory + Core tests under default-off | **Yes** |
| Local `swift test` on KeyboardCore | **Yes** |
| Independent Arch/Quality for any new code contract | **Yes** when implementation lands |
| Product Gate / default-on | **No** |

## Explicit non-claims

- Not Product Gate  
- Not default-on  
- Not SLO  
- Not erasure of Formal R5 FAIL  
