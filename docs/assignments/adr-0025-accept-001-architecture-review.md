# ADR-0025-ACCEPT-001 — Architecture Review

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-06 Asia/Shanghai` |
| **Tip commit (inventory / dossier)** | `49272b0` (Assignment + readiness dossier) |
| **Reviewer role** | Independent 🏛️ Architecture & Knowledge Steward (read-only; **not** Executor dossier author) |
| **Authority inputs** | `PD-T9-RESPONSIVE-PIPELINE-001-ADR-0025-ACCEPT`; Assignment `ADR-0025-ACCEPT-001`; CANARY-001 Stop/Retain |
| **ADR under review** | [`0025-responsive-rime-serial-input-pipeline.md`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) — Status at review: **Proposed** |
| **Related baseline ADR** | [`0004-rime-runtime-session-model.md`](../architecture/decisions/0004-rime-runtime-session-model.md) — Status: **Accepted** |
| **Dossier reviewed** | [`adr-0025-accept-001-readiness-dossier.md`](adr-0025-accept-001-readiness-dossier.md) |

## Verdict

### **Conditional Accept**

ADR 0025 **may become a binding architecture Decision** for the **responsive serial RIME input pipeline design**, with production enablement remaining **explicitly gated** and **Release default remaining ADR 0004 MainActor-synchronous**, **only after** the **Required amendments** below are applied in the ADR text (and ADR 0004 cross-link is made consistent with §6 as amended).

| Outcome | Meaning for this review |
|---|---|
| **Accept (unconditional)** | **Not earned** — Follow-up #8 / R3 completeness residual, §6 supersession wording risk, and stale Follow-up / “remains Proposed” language must not be left as silent ambiguity |
| **Conditional Accept** | **Earned (Architecture)** — core §§1–9 Decision is sound, implementable behind gates, and evidence-backed enough for binding design SoT **with named residuals** |
| **Fail-Blocked** | **Not applied** — no P0 dual-entry / isolation-bypass / Product-Gate-overclaim found that invalidates the Decision itself |

### Status-field mapping (DOCUMENTATION_GOVERNANCE)

Architecture verdict “Conditional Accept” maps to ADR **Status: `Accepted`**, with acceptance date / authority / residual pointers and explicit non-claims. There is no formal governance token named “Conditional Accept.”

## Finding counts

| Severity | Count |
|---|---:|
| **P0** | **0** |
| **P1** | **2** |
| **P2** | **5** |
| **P3** | **3** |
| **Total** | **10** |

## Scope and non-claims reviewed

### In scope

1. Whether ADR 0025 Decision clauses are binding-ready as architecture SoT for the **gated** responsive serial-owner design.
2. Independence / authority separation: Executor dossier **≠** Architecture acceptance.
3. §6 relationship to ADR 0004: Accept must **not** silently make gate-on the Release default.
4. Follow-up #8 (“after R2/R3 evidence”) as Accept blocker vs residual under Conditional Accept.
5. Spot-check of dual-entry / default-off claims.

### Explicitly out of scope

- Product Gate / shipping / default-on
- Performance SLO from n=1 canary A/B
- New implementation or multi-device canary reopen
- Full live dual-entry re-audit beyond pointer-level inventory
- Erasure of Formal R5 FAIL history

## Authority separation (enforced)

Executor dossier is not acceptance. This review does not rubber-stamp the Executor pre-recommendation; it independently concludes **Conditional Accept** with required text amendments.

## Code spot-check (default-off / dual-entry)

- `isResponsiveRimePipelineEnabled` and thread-affine owner flags default **false**.
- Bootstrap canary/preflight arms only under explicit paths; fail-closed restores gates to false.
- Ordinary path remains available when gates are off (ADR 0004 shape).

## Clause-by-clause vs dossier

Architecture **agrees** with dossier Met/Partial dispositions for §§1–5, 7–13, with **one severity dissent**: §6 is **Partial until amendment** (must restate gate-off Release default on Accept). Follow-up #8 is **residual under Conditional Accept**, not Fail-Blocked.

### Explicit ruling: Follow-up #8

| Question | Ruling |
|---|---|
| Blocks unconditional Accept with zero residual disclosure? | **Yes** |
| Blocks Conditional Accept as binding Decision under default-off? | **No** |
| Forces Fail-Blocked? | **No** |

## Findings table

| ID | Sev | Finding | Disposition |
|---|---|---|---|
| **A-P1-01** | **P1** | §6 Accept wording risks unconditional supersession of 0004 threading locus for all traffic | **Required amendment before Status flip** |
| **A-P1-02** | **P1** | Follow-up #6–#8 stale relative to later Product-authorized gated work + canary | **Required Follow-up refresh on flip** |
| **A-P2-01** | **P2** | §8 “remains Proposed” becomes false on Accept | Mechanical update on flip |
| **A-P2-02** | **P2** | Nested “does not Accept” language present-tense confusion | Hygiene / historical annotation |
| **A-P2-03** | **P2** | CANARY FA per-arm attestation gap (R-01) | Residual; not Decision-blocking |
| **A-P2-04** | **P2** | n=1 A/B + broader proof debts (R-04/R-05) | Residual; no SLO |
| **A-P2-05** | **P2** | Formal R5 FAIL retained; incomplete R3 matrix rows (R-07/R-09) | Residual; keep R5 FAIL visible |
| **A-P3-01** | **P3** | Human-mediated kill marker | Residual |
| **A-P3-02** | **P3** | powerThermal operator observation | Residual |
| **A-P3-03** | **P3** | §5.1 nested Proposed; Follow-up #9–#10 doc hygiene | Residual / post-Accept |

## Required amendments before Status flip

1. ADR 0025 Status block → `Accepted` with residuals and non-claims.
2. ADR 0025 §6 operational note: gate-on-only placement revision; gate-off = 0004 Release default.
3. ADR 0025 §8 remove “remains Proposed”; retain Product Gate for shipping/default-on.
4. Follow-up #6–#10 honesty refresh.
5. ADR 0004 Follow-up cross-link: gate-on-only locus revision.
6. Nested “does not Accept” historical annotation where present-tense would confuse.

## Explicit non-claims (Architecture)

Does not authorize Product Gate, Release default-on, performance SLO, closure of canary process residuals as “done”, erasure of Formal R5 FAIL, full supersession of ADR 0004, completeness of every R3 matrix row, or Executor-only acceptance.

## Handoff

- **Product:** Conditional Accept earned after amendments + Quality Exit Criteria; default remains off; Product Gate needs a new Decision.
- **Quality:** separate evidence-stack integrity review required (completed as peer review).
- **Executor:** apply required amendments only; no runtime/default changes.

## Summary

Core Decision is sound and evidence-backed enough under default-off / production-shaped canary to become binding design Source of Truth. Hard precondition for Status flip is **text honesty** around §6 / Follow-up / Proposed language and ADR 0004 cross-link.

**Verdict: Conditional Accept (0 P0 / 2 P1 / 5 P2 / 3 P3).**  
**Status flip: allowed only after required amendments + Quality Exit Criteria.**
