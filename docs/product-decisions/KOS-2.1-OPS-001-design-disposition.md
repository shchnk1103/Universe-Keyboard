# Product Disposition: KOS-2.1-OPS-001 Design Package

**Decision ID:** `PD-KOS-2.1-OPS-001-DISPOSITION`  
**Date / timezone:** `2026-08-06 Asia/Shanghai`  
**Parent:** [`PD-KOS-2.1-OPS-001`](KOS-2.1-OPS-001-authorization.md)  
**Architecture input:** [`kos-2.1-ops-001-architecture-review.md`](../assignments/kos-2.1-ops-001-architecture-review.md)  
**Lifecycle status:** `Recorded — Design Accepted (Must path)`

## Authority

- **Product Approver:** Human Product Owner / Product Lead  
- **Decision source:** In-session authorization 2026-08-06 Asia/Shanghai:
  “根据你自主的判断继续下去吧，安排好任务的优先级…” — Product delegates
  continuation under Architecture’s recommended disposition.

## Disposition

**Accept design → implement Must (M-01…M-05) only**, with Architecture
conditions bound into implementation:

| Bound condition | Rule |
|---|---|
| A-P1-02 | Residual disposition hard close: `fix` / `accept` / `tech_debt:<id>` |
| A-P2-01 | Active Work Summary links + Current Status fields only; Assignment is SoT |
| A-P2-02 | IMPL declares Contract vs Documentation/State per file |
| A-P2-03 | No frozen 2.0 principle-file version bump; ops package under 2.0 track |
| A-P1-01 | **S-01 deferred** (no lightweight dual-review skip in this IMPL) |

**Also authorized in this IMPL (low risk Should):** S-02 stacked PR convention,
S-03 supersession banner convention.

**Not authorized:** S-01; Migration; Knowledge OS 3.0; treating 2.1 as frozen-track
replacement of 2.0.

## Follow-on

- Implementation Assignment: [`KOS-2.1-OPS-IMPL-001`](../assignments/kos-2.1-ops-impl-001.md)  
- Product Decision for IMPL: [`PD-KOS-2.1-OPS-IMPL-001`](KOS-2.1-OPS-IMPL-001-authorization.md)  
