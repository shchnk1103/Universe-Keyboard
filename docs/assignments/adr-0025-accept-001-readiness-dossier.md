# ADR-0025-ACCEPT-001 — Readiness Dossier (draft for independent review)

**Task:** [`ADR-0025-ACCEPT-001`](adr-0025-accept-001.md)  
**Date / timezone:** `2026-08-06 Asia/Shanghai`  
**Repository tip at inventory:** `49272b0`  
**ADR under review:** [`0025-responsive-rime-serial-input-pipeline.md`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)  
**Status at inventory start:** `Proposed`  
**Executor (dossier only):** Current Grok primary agent  
**Authority:** [`PD-…-ADR-0025-ACCEPT`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-ADR-0025-ACCEPT-authorization.md)

> This dossier is **not** Architecture acceptance. Independent Architecture and
> Quality reviews must conclude before any ADR Status flip.

## 1. Recommendation (Executor pre-review)

| Field | Value |
|---|---|
| **Pre-review recommendation** | **Conditional Accept** of ADR 0025 as a **binding architecture Decision**, with production enablement remaining **default-off** until a future Product Gate |
| **Why not full unconditional Accept** | ADR Follow-up still lists R2/R3-style completeness language; open process residuals from canary; gate-on is not Product-gated shipping |
| **Why not Blocked** | Decision §§1–9 core model is already frozen, implemented behind gates, and repeatedly reviewed; CANARY Stop/Retain + P2-PERF-03 support the threading-locus revision described in §6 |
| **What Accept would mean** | ADR 0025 becomes Source of Truth for the responsive serial-owner **design**; ADR 0004 MainActor placement is revised **only when the responsive path is enabled**; Release default remains ADR 0004 sync path |
| **What Accept would not mean** | Product Gate, default-on, SLO, or erasure of Formal R5 FAIL |

## 2. Evidence stack (already reviewed; not re-run)

| Layer | Key sources | Independent reviews | Outcome retained |
|---|---|---|---|
| R1 Fake pipeline / epoch / publish | KeyboardCore `ResponsiveRimePipeline` + tests; ADR §§10–11 freezes | R1 lineage reviews under parent Assignment | Contract bed proven; not production owner alone |
| R4/R5 + Rem-3 L1 provisional | parent Assignment + Rem-3 evidence | Arch/Quality Rem-3 reviews | Dual-gate provisional path direction evidence |
| P1-D2 Amendment B | `evidence/…-p1-d2-amendment-b-2026-08-01.md` | final Arch/Quality **Pass with conditions** | Bounded presentation/guards |
| P2 Core regression | `…-p2-regression-matrix-2026-08-01.md` | Arch/Quality re-reviews **Pass with conditions** | 19/0 focused, 861/0 full (as recorded) |
| P2-PERF-02/03 A/B | canonical + replicated A/B evidence | Arch/Quality PERF reviews | Directional non-stutter support |
| CANARY-001 DEVICE-001 A/B/K/O | `…-canary-001-device-001-2026-08-04.md` | Arch **0/0/1/0**, Quality **0/0/5/3** Pass with conditions | Stop/Retain 2026-08-05 |
| Formal R5 | historical FAIL retained | — | Must remain visible; not rewritten by Accept |

## 3. Clause-by-clause disposition

Legend: **Met** = Decision text is satisfied by design+code+evidence for the
**gated/default-off** architecture; **Partial** = Decision holds with named residual;
**Open** = blocks honest unconditional Accept; **N/A** = not required for Accept
of the Decision (deferred to Product Gate or later phase).

| ADR clause | Intent | Inventory finding | Disposition |
|---|---|---|---|
| §1 Single serial RIME session owner | One owner for session APIs | Canary/Extension path installs bridge/coordinator; design freezes ban dual-entry; live-session inventory existed for CANARY | **Met** for gated path; residual: keep API-coverage vigilance under any future wire expansion |
| §2 MainActor UI / document proxy | UI stays MainActor | Controllers enqueue/apply; UIKit chrome on main | **Met** |
| §3 Ordered input; optional publish coalesce | No drop/reorder of session actions; UI may latest-only | Pipeline + dual-gate presentation buffer | **Met** |
| §4 sessionEpoch / revision | Stale discard; selection fail-closed | R1 bed + production-shaped wiring + fail-closed selection contracts | **Met** |
| §5 Atomic composition snapshot publish | composition/Path/candidates/revision together | Atomic publish policy + Amendment B guards | **Met** with residual test-matrix breadth (P2 evidence debts) |
| §5.1 content-free markers | ACCEPT/PUBLISH/VISIBLE/PAINT separation | Diagnostic contract Proposed amendment; canary content-free markers | **Partial** — diagnostic amendment may remain Proposed without blocking Decision Accept if §9 privacy holds |
| §6 vs ADR 0004 | Serialize remains; MainActor locus revised when Accepted | Text already defines Off=0004 sync, On=serial owner | **Met as design**; Accept must carefully word that 0004 revision applies to **enabled** path, not default Release behavior |
| §7 Swift 6 isolation | actor/serial executor; no `@unchecked Sendable` | Policy + canary isolation reviews; R2 owner shape freeze §10 | **Met** for authorized owner shapes; residual: any future code path must stay on frozen shapes |
| §8 Feature gating | Release default off until Product Gate | `isResponsiveRimePipelineEnabled` default false; canary/preflight only | **Met** |
| §9 Diagnostics | content-free | ADR 0010 + canary privacy reviews | **Met** |
| §10 R2 owner freeze | production owner shape | Implemented coordinators/bridges under gate; R1 class still documented as non-production bed | **Met** as freeze + gated implementation |
| §11 sessionEpoch mapping | who bumps epoch | Target table frozen; implementation aligned in pipeline/coordinator paths | **Partial** — full lifecycle matrix rows still have held P3 harness pieces historically; does not invalidate Decision if fail-closed barriers remain |
| §12+ provisional / dual-gate amendments | L1 shadow / stable chrome | Rem-3 + Amendment B | **Met** for gated design |
| Follow-up #8 “Accept after R2/R3 evidence” | Evidence maturity | R2-shaped gated owner + canary production-shaped path + P2 matrix exist; not every historical R3 row closed | **Partial** — treat as **evidence maturity residual**, not missing Decision |

## 4. Code surface inventory (pointer-level)

Observed on tip `49272b0` (non-exhaustive; for reviewers):

- `Packages/KeyboardCore/.../KeyboardController.swift` — `isResponsiveRimePipelineEnabled` default **false**; `responsiveRimeCoordinator`; dual-gate provisional mirror
- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` — canary/preflight arming, kill/restore, gate install paths
- Responsive pipeline types (`ResponsiveRimePipeline`, coordinators, canary terminals) under KeyboardCore
- Production ordinary path remains available when gate off (ADR 0004 behavior)

Reviewers should treat this as navigation, not a substitute for reading freeze
docs and prior Architecture reviews.

## 5. Open residuals (do not disappear on Accept)

| ID | Residual | Severity for ADR Accept | Notes |
|---|---|---|---|
| R-01 | CANARY P2-04 FA per-arm attestation gap | Process P2 | Does not invalidate Decision |
| R-02 | CANARY P3-01 Human-mediated kill marker | Process P3 | Physical-device limit |
| R-03 | CANARY P3-02 powerThermal operator observation | Process P3 | Not sensor |
| R-04 | Single-pair A/B n=1 / Human cadence confound | Evidence limit | Direction only; no SLO |
| R-05 | P1-D2/P2 broader stale-action / host-history proof debts | Quality residual | Keep visible |
| R-06 | P3-D1 T02/T03 host accessibility hold | Out of Accept scope | Product-held earlier |
| R-07 | Formal R5 historical FAIL | Historical | Retain; do not rewrite |
| R-08 | ADR §5.1 diagnostic amendment still “Proposed” language | Doc hygiene | May stay Proposed or be folded on Accept |
| R-09 | Follow-up R3 “full contract matrix” not every row closed | Completeness | Conditional Accept residual unless Architecture demands Block |

## 6. Proposed Accept language (if Architecture agrees)

Suggested Status line (Executor draft only):

```text
Status: Accepted (2026-08-06) — binding architecture Decision for the responsive
serial RIME input pipeline. Production enablement remains behind explicit gate;
Release default remains ADR 0004 MainActor-synchronous path until a future
Product Gate. Conditional residuals: R-01…R-09 in ADR-0025-ACCEPT-001 dossier.
Does not authorize default-on, Product Gate, or performance SLO.
```

Suggested §6 operational note:

```text
When Accepted: implementers must treat the serial-owner design as the architecture
Source of Truth for the gate-on path. Gate-off remains ADR 0004 as written for
session threading locus. Do not interpret Accept as permission to change Release
defaults.
```

## 7. Downstream doc edits authorized only after Architecture Accept

| Document | Edit type |
|---|---|
| ADR 0025 | Status + acceptance authority + residual pointers |
| ADR 0004 | Cross-link note that threading locus is revised **for gate-on path** by 0025 (not full supersession) |
| `docs/ENGINEERING_DASHBOARD.md` | State sync only |
| Parent Assignment `t9-responsive-rime-pipeline-001.md` | Lifecycle: ADR Accept recorded; Product Gate still not claimed |
| `docs/KNOWLEDGE_INDEX.md` | Navigation note if status changed |
| Optional later (not required for Accept record): `swift6-migration.md`, `input-pipeline-and-marked-text.md` | Follow-up #9–10 — may remain post-Accept implementation hygiene |

## 8. Stop / escalate matrix for reviewers

| Finding | Action |
|---|---|
| P0 dual-entry or isolation bypass under gate-on | **Fail** — Block Accept; new implementation Assignment |
| Decision text contradicts frozen Product non-goals | **Fail** — Product revalidation |
| Evidence over-claims Product Gate / default-on | **Fail Quality** — rewrite dossier; no Accept |
| Only process residuals (R-01…R-04 style) | May **Conditional Accept** |
| Desire for default-on | **Out of scope** — separate Product Decision |

## 9. Executor checklist before independent review handoff

- [x] PD + Assignment published
- [x] Clause inventory drafted
- [x] Residual table drafted
- [x] Explicit non-claims stated
- [x] Independent Architecture review — Conditional Accept (0/2/5/3)
- [x] Independent Quality evidence-stack review — Pass with conditions (0/0/0/4)
- [x] Architecture conclusion recorded
- [x] Status flip earned and applied (ADR 0025 → Accepted; §6/§8/Follow-up + ADR 0004 cross-link)

## 10. Requested independent reviews

1. **Architecture:** Does Conditional Accept of ADR 0025 as a binding Decision
   (gate-off default retained) honestly match §§1–9 and §6 vs ADR 0004?
2. **Quality:** Is the evidence stack citation accurate enough to support that
   Conditional Accept without inventing new device claims?
