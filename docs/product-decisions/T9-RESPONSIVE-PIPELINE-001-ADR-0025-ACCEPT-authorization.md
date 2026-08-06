# Product Decision: T9-RESPONSIVE-PIPELINE-001 / ADR-0025-ACCEPT-001 — ADR 0025 Formal Acceptance Review

**Decision ID:** `PD-T9-RESPONSIVE-PIPELINE-001-ADR-0025-ACCEPT`
**Lifecycle status:** `Recorded — Acceptance-review completed 2026-08-06; ADR 0025 Accepted with residuals; Product Gate / default-on not authorized`
**Date / timezone:** `2026-08-06 Asia/Shanghai`
**Parent:** [`PD-T9-RESPONSIVE-PIPELINE-001`](T9-RESPONSIVE-PIPELINE-001-authorization.md)
**Related disposition:** [`CANARY-001 Stop/Retain`](T9-RESPONSIVE-PIPELINE-001-CANARY-001-disposition.md)
**Assignment:** [`ADR-0025-ACCEPT-001`](../assignments/adr-0025-accept-001.md)
**Architecture target:** [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) (currently **Proposed**)

## Authority

- **Product Approver / Decision maker:** Human Product Owner / Product Lead
- **Decision source / date:** In-session authorization, 2026-08-06 Asia/Shanghai:
  “我觉得可以授权你开始 ADR 0025 的工作，请你严格按照 KOS2.0 设定的继续。”
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)
- **Architecture acceptance authority (if earned):** 🏛️ Architecture & Knowledge Steward
  after independent review — not the implementing Executor alone
- **Does not transfer:** permanent ownership, Quality authority, or Product Gate authority

## Product problem this phase answers

CANARY-001 device evidence was **Stop/Retain** under default-off. Directional
evidence (P2-PERF-03 + CANARY A/B/K/O) supports the responsive serial-owner
direction, but ADR 0025 remains **Proposed** and is not yet a binding
architecture contract.

This Decision opens only the **formal acceptance-review workstream** for ADR 0025.

## Bound Product Decision

### 1. Authorize ADR-0025-ACCEPT-001 only

Product Lead authorizes Assignment `ADR-0025-ACCEPT-001` to:

1. Inventory ADR 0025 Decision clauses against implemented default-off code and
   already-reviewed evidence.
2. Produce a readiness dossier with Accept / Conditional-Accept / Blocked
   recommendation and explicit residual risks.
3. Run **independent** Architecture review (and Quality review of the evidence
   stack when required by Exit Criteria).
4. If and only if independent Architecture concludes **Accept** (or a
   documented Conditional Accept with named residuals), update ADR 0025 status
   and the minimum navigation/downstream docs listed in the Assignment.
5. Synchronize Dashboard / parent Assignment lifecycle language only after the
   owning Architecture conclusion is recorded.

### 2. Explicit non-authorization

This Decision **does not** authorize:

- Release default-on or user-facing enablement of the responsive path
- Product Gate / App Store / shipping claims
- New feature implementation beyond documentation and acceptance-record hygiene
- Erasure of Formal R5 FAIL history
- Treating single-pair canary A/B as a performance SLO or benchmark
- Reopening CANARY-001 multi-device evidence phase
- Changing dual-gate Release default (remains **off**)
- Accepting ADR 0025 by Product fiat without Architecture independence

### 3. Acceptance bar (Product view)

Product accepts that ADR 0025 may become **Accepted** only when Architecture
concludes the Decision text is binding and implementable, with:

- serialization + single serial owner preserved;
- MainActor UI/proxy ownership preserved;
- ordered input + versioned publish + fail-closed stale interaction preserved;
- Swift 6 isolation without `@unchecked Sendable` shortcuts;
- gate-off remaining behavior-equivalent to ADR 0004 until a later Product Gate;
- residuals honestly disclosed (may remain open if they do not invalidate the
  Decision).

If Architecture finds the Decision still requires R2/R3 contract completion
before Accept, Product expects a **Blocked or Conditional** recommendation with
a minimal gap list — not a silent Accept.

### 4. Relationship to parent PD and CANARY disposition

- Parent [`PD-T9-RESPONSIVE-PIPELINE-001`](T9-RESPONSIVE-PIPELINE-001-authorization.md)
  remains the product direction source.
- [`CANARY-001 Stop/Retain`](T9-RESPONSIVE-PIPELINE-001-CANARY-001-disposition.md)
  remains the device-evidence disposition; this Decision is the reopening
  trigger named there for **ADR 0025 acceptance review only**.
- Default-off and no-Product-Gate non-claims from CANARY disposition remain in
  force unless a future Product Decision supersedes them.

## Implementation / Executor follow-through (authorized)

| Action | Authorized? |
|---|---|
| Create/update Assignment `ADR-0025-ACCEPT-001` | **Yes** |
| Read-only readiness inventory + dossier | **Yes** |
| Independent Architecture (and required Quality) reviews | **Yes** |
| ADR status flip to Accepted / Conditional Accept **only after** independent Architecture Pass | **Yes** |
| Minimum doc sync listed in Assignment Exit Criteria | **Yes** when Accept is earned |
| New runtime/feature code, default-on, Product Gate | **No** |
| Physical-device retest campaign | **No** (unless a later Decision reopens it) |

## Explicit non-claims

- Not ADR 0025 Accepted at the moment this Decision is recorded
- Not Product Gate / Release approval / default-on
- Not Quality Pass by itself
- Not a rewrite of ADR 0004 outside the threading-locus revision described in
  ADR 0025 §6 when Accepted

## Human Product Owner

- In-session authorization on 2026-08-06 is the product act that opens this
  acceptance-review phase.
- Override window: same calendar day if Owner rejects the scope language.
