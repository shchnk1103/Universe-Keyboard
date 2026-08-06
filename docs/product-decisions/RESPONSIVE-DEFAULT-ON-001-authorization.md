# Product Decision: RESPONSIVE-DEFAULT-ON-001 — Product Gate / Release dual-gate default-on

**Decision ID:** `PD-RESPONSIVE-DEFAULT-ON-001`  
**Lifecycle status:** `Recorded — Product Gate implemented 2026-08-06; Arch/Quality Pass with conditions; dual-gate Release request default-on`  
**Date / timezone:** `2026-08-06 Asia/Shanghai`  
**Parent:** [`PD-T9-RESPONSIVE-PIPELINE-001`](T9-RESPONSIVE-PIPELINE-001-authorization.md)  
**Related:** [`PD-RESPONSIVE-ALL-LAYOUTS-001`](RESPONSIVE-ALL-LAYOUTS-001-authorization.md) ·
[`ADR 0025 Accepted`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)  
**Assignment:** [`RESPONSIVE-DEFAULT-ON-001`](../assignments/responsive-default-on-001.md)

## Authority

- **Product Approver:** Human Product Owner / Product Lead  
- **Decision source / date:** In-session authorization 2026-08-06 Asia/Shanghai:
  认定既有证据已足够将响应式路径作为默认，并要求在内部启用策略的证据基础上执行
  **Product Gate / default-on**，严格遵守 KOS 2.0。

## Product problem

Responsive serial RIME (ADR 0025) is Accepted as design SoT; Chinese 26-key + T9
L0 is layout-universal under ALL-LAYOUTS-001; canary and PERF evidence show the
thread-affine dual-gate direction keeps UI responsive during slow `process_key`.
Continuing default-off leaves ordinary users on the blocking ADR 0004 path.

## Bound Product Decision

### 1. Product Gate — **Pass with residuals**

Product Lead **accepts** the responsive dual-gate path as the **ordinary
Release default** for Chinese RIME keyboard sessions when shared runtime data
is available.

### 2. What “default-on” means

| Item | Decision |
|---|---|
| Ordinary Extension presentation path | Request **dual-gate** (responsive + thread-affine serial owner) by default |
| Layouts | Chinese **26-key + T9** (L0 universal); T9-only L1 provisional remains T9-scoped |
| Install failure | **Fail closed** to ADR 0004 MainActor-synchronous session path |
| User-facing toggle | **Not required** for this Gate (no new settings UI mandated) |
| Numeric SLO | **Not locked** (directional evidence only) |
| Canary internal artifact | Remains a separate compile path; not the ordinary Release default mechanism |

### 3. Evidence accepted as Gate inputs (not re-run)

- ADR 0025 Accepted + POST-ACCEPT hygiene + ALL-LAYOUTS-001  
- P2-PERF-02/03 directional A/B  
- CANARY-001 A/B/K/O Stop/Retain + Arch/Quality Pass with conditions  
- Rem-3 / dual-gate device direction PASSes  
- Formal R5 FAIL retained as history (not rewritten)

### 4. Residuals kept visible (do not block Gate)

- Single-pair / small-n directional samples (not statistical SLO)  
- CANARY process residuals (FA attestation, Human-mediated kill marker, thermal observation)  
- P2 UIKit host-history / prefetch debts  
- P3-D1 host accessibility hold  

### 5. Explicit non-claims

- Not a performance SLO or App Store performance marketing claim  
- Not erasure of Formal R5 FAIL  
- Not English-layout coverage  
- Not auto-anchor reopening  

## Implementation follow-through

| Action | Authorized? |
|---|---|
| Change ordinary arming so Release requests dual-gate by default | **Yes** |
| Fail-closed fallback to sync path | **Yes** (required) |
| ADR §8 / 0004 cross-link / Dashboard / Index updates | **Yes** |
| Automated Preflight + Core tests for new default | **Yes** |
| Independent Architecture + Quality review of this Gate package | **Yes** |
| New multi-device campaign | **Not required** for this Gate (Product accepts existing stack) |

## Human Product Owner

- In-session Product Gate authorization (2026-08-06) is the product act for
  default-on.
