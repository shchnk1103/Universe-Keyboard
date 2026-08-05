# Product Decision: T9-RESPONSIVE-PIPELINE-001 / CANARY-001 — Stop/Retain Disposition

**Decision ID:** `PD-T9-RESPONSIVE-PIPELINE-001-CANARY-001-STOP-RETAIN`
**Lifecycle status:** `Recorded — Stop/Retain`
**Date / timezone:** `2026-08-05 Asia/Shanghai`
**Parent:** [`PD-T9-RESPONSIVE-PIPELINE-001`](T9-RESPONSIVE-PIPELINE-001-authorization.md)
**Assignments:** [`CANARY-001`](../assignments/t9-responsive-pipeline-001-production-shaped-canary-001.md) · [`CANARY-001/DEVICE-001`](../assignments/t9-responsive-pipeline-001-canary-001-device-001.md)
**Evidence:** [`DEVICE-001 evidence`](../evidence/t9-responsive-pipeline-canary-001-device-001-2026-08-04.md) · [`summary`](../evidence/t9-responsive-pipeline-canary-001-device-001-summary-2026-08-04.json) · [`Architecture review`](../assignments/t9-responsive-pipeline-001-canary-001-architecture-review.md) · [`Quality review`](../assignments/t9-responsive-pipeline-001-canary-001-quality-review.md)

## Authority

- **Product Approver / Decision maker:** Human Product Owner / Product Lead, in-session decision 2026-08-05: **Stop/Retain** (认可方向证据，保持 default-off 归档).
- **Scope of decision:** disposition of CANARY-001 device evidence only. It does not change ADR 0025 status, default gate, release plan, or any production wiring.

## Inputs accepted

| Input | Disposition |
|---|---|
| DEVICE-001 pair-002 four-arm (A/B/K/O) device execution on iPhone 13 Pro | **Complete**; A sync stallScore 2.5 vs B R5P stallScore 0 at same slow-RIME positions (208–242ms); K kill-switch assert `decision=kill` + extension fail-closed to baseline; O ordinary Release restored with matching hashes + clean Human smoke |
| Independent Architecture review | **Pass with conditions** (`0/0/1/0`); sole P2-01 K kill/expiry confound disclosed, not a code defect |
| Independent Quality review | **Pass with conditions** (`0/0/5/3`); aggregates cross-checked against raw receipts with zero drift; privacy barrier intact; K confound honestly disclosed across all three evidence layers |
| Quality residual remediation | P2-01/02/05 + P3-03 closed in evidence doc / summary; P2-03 closed with O binary-scan quarantine receipt; P2-04 / P3-01 / P3-02 remain open with honest attestation |

## Bound Product Decision

### 1. Disposition → **Stop/Retain**

Product Lead **accepts the CANARY-001 device evidence as a directional result** and **retains it in archive under default-off**, without opening any further device evidence phase.

> **Stop/Retain** — 认可 B（R5P）方向证据与 P2-PERF-03 一致；保持 dual-gate default-off；不再追加多设备 / Full Access OFF / 未过期 K 臂重放等设备测试；归档设备证据供未来 ADR 0025 评审参考。

This **does**:

- Recognize the consistent directional result (thread-affine provisional path keeps UI responsive during slow RIME) across P2-PERF-03 and CANARY-001.
- Preserve all evidence, reviews, and quarantine receipts as durable reference for any future ADR 0025 / Product Gate decision.

This **does not**:

- Accept ADR 0025 (still **Proposed**).
- Open a Product Gate, change the default gate, or authorize production wiring / Release default-on.
- Claim that single-pair A/B (n=1, Human cadence confound) constitutes a benchmark or performance SLO.
- Close the CANARY-001 assignment as "Accepted"; its lifecycle remains `Active` pending future Product Lead reopening, with device layer marked `execution complete`.

### 2. Open residuals (kept visible, not resolved by this decision)

| Item | Status |
|---|---|
| P2-04: Full Access per-arm re-confirm lacks an independent attestation row | Open (process gap) |
| P3-01: K `decision=kill` marker is Human-mediated (physical-device limit) | Open (documented) |
| P3-02: powerThermal is operator observation, not sensor record | Open (documented) |
| run004 automated/Simulator layer: 20 `NotObserved` fixture/provenance behaviors | Not claimed by device layer |
| ADR 0025 acceptance, Product Gate, default-on, production wiring | **Closed to any claim** |

### 3. Future reopening triggers

Any of: new Product Assignment; ADR 0025 acceptance review; unexpired-configuration K replay; multi-device / Full Access OFF evidence; Release default-on decision. Reopening requires fresh Product authorization and a new immutable run identity.

## Implementation / Executor follow-through (authorized)

| Action | Authorized? |
|---|---|
| Update Dashboard / plan Discussion log to Stop/Retain disposition | **Yes** |
| Local commit + push to `main` (docs) | **Yes** |
| New feature code | **No** |
| Change default gate / production wiring / ADR status | **No** |

## Explicit non-claims

- Not ADR 0025 Accept.
- Not Product Gate / Release approval / default-on.
- Not benchmark or performance SLO.
- Not erasure of the Formal R5 FAIL history.
- Not closure of CANARY-001 assignment as Accepted (remains `Active`, device layer complete).

## Human Product Owner

- In-session selection **Stop/Retain** (2026-08-05) is recorded as the product act for this disposition.
- Override window: same calendar day if Owner rejects the disposition language.
