# Product Decision: KOS-2.1-OPS-001 — Knowledge OS 2.1 Operational Maturity Design

**Decision ID:** `PD-KOS-2.1-OPS-001`  
**Lifecycle status:** `Recorded — Design / review phase authorized`  
**Date / timezone:** `2026-08-06 Asia/Shanghai`  
**Classification:** `Level S — System Governance`  
**Related:** Knowledge OS 2.0 ([`knowledge-os-2.0-specification.md`](../kos/knowledge-os-2.0-specification.md));
[`KOS-MIG-001`](../assignments/kos-mig-001.md) (closed); [`DOC-HYGIENE-001`](../assignments/doc-hygiene-001.md) (closed)  
**Assignment:** [`KOS-2.1-OPS-001`](../assignments/kos-2.1-ops-001.md)

## Authority

- **Product Approver / Decision maker:** Human Product Owner / Product Lead  
- **Decision source / date:** In-session authorization 2026-08-06 Asia/Shanghai:
  选择「按 KOS 建档：起 PD + Assignment，只做设计/复盘，不改冻结原则」  
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)  
- **Domain Owner (governance):** 🏛️ Architecture & Knowledge Steward  

## Product / governance problem

Knowledge OS 2.0 has been the single operational track since KOS-MIG-001
(`2026-07-17`). Intensive product work (responsive pipeline Accept, all-layouts,
Product Gate default-on, stacked PRs, large Assignment/evidence volume) has
shown that **2.0 principles remain sound**, while **operational drift and scale
friction** accumulate:

- Dashboard / Index lag behind Assignment tip  
- Stacked PR / tip-merge coordination is ad hoc  
- Conditional Accept / Pass with conditions often lacks forced residual closure  
- Historical “default-off / not claimed” language confuses current status  
- Lightweight State/doc work still tends to invoke full dual-review ceremony  
- Evidence grades (Executor-recorded vs Quality-reverified) are informal  

Product Lead therefore authorizes a **design-and-review** work item for a
possible **Knowledge OS 2.1 Operational Maturity** package — **not** Knowledge
OS 3.0, and **not** an immediate migration or frozen-principle rewrite.

## Bound Product Decision

### 1. Authorize design / review only

Assignment `KOS-2.1-OPS-001` may:

1. Produce a **pain inventory** from post-2.0 operational use (repo facts +
   observed process friction).  
2. Draft a **KOS 2.1 proposal** that distinguishes:  
   - changes to **operational** docs (`KNOWLEDGE_OS.md`, workflows, templates);  
   - optional **additive** amendments to frozen 2.0 (only if required);  
   - explicit **non-changes** (2.0 principles preserved).  
3. Define Must / Should / Could priorities and a migration readiness note
   (whether a later `Migration` Assignment is warranted).  
4. Run Architecture review of the proposal (and Product Review for acceptance
   of the design package).  
5. Update navigation/Dashboard **State** only for this Work Item’s lifecycle.  

### 2. Explicit non-authorization

This Decision **does not** authorize:

- Knowledge OS **3.0** redesign  
- Immediate rewrite of frozen 2.0 principles without a later Product Decision  
- Repository **Migration** of domain docs or bulk tree moves  
- Changes to product runtime, RIME, keyboard behavior, or RELEASE gates  
- Skipping Assignment Policy for future formal work  
- Treating the design draft as already-accepted 2.1  

### 3. Relationship to 2.0

- Knowledge OS **2.0 remains the single operational governance track** until a
  future Product Decision accepts 2.1 (and, if needed, a separate Migration).  
- This work is **evolution under 2.0**, not dual-track reintroduction.  

### 4. Acceptance of design package (later)

Product Review of the design package may result in:

| Outcome | Meaning |
|---|---|
| **Accept design; implement 2.1 ops only** | Operational docs/templates; no frozen rewrite |
| **Accept design; schedule frozen additive amendment** | Requires explicit later Contract Assignment |
| **Accept design; schedule Migration** | Separate `Migration` Assignment required |
| **Hold / revise design** | No 2.1 publication |
| **Reject 2.1; keep 2.0** | Close Assignment with residual notes |

No outcome above is pre-selected by this Decision.

## Implementation follow-through (this phase)

| Action | Authorized? |
|---|---|
| Create Assignment + pain inventory + 2.1 design draft | **Yes** |
| Architecture (and Product) review of the design package | **Yes** |
| Navigation / Dashboard State for this Work Item | **Yes** |
| Edit frozen 2.0 principles in place as accepted 2.1 | **No** (this phase) |
| Migration / bulk doc moves | **No** |
| Product runtime code | **No** |

## Explicit non-claims

- Not Knowledge OS 2.1 Accepted  
- Not KOS 3.0  
- Not operational dual-track  
- Not permission to weaken Product / Architecture / Quality separation  

## Human Product Owner

- In-session selection of formal design bootstrap (option 2) on 2026-08-06 is
  the product act for this Decision.  
