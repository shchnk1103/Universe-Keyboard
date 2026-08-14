# Product Decision: RESPONSIVE-ALL-LAYOUTS-001 — 全中文布局响应式 RIME（default-off）

**Decision ID:** `PD-RESPONSIVE-ALL-LAYOUTS-001`  
**Lifecycle status:** `Recorded — Phase Completed 2026-08-06 (L0 universal locked + automated non-T9 suite; Product Gate / default-on not authorized)`  
**Date / timezone:** `2026-08-06 Asia/Shanghai`  
**Parent:** [`PD-T9-RESPONSIVE-PIPELINE-001`](T9-RESPONSIVE-PIPELINE-001-authorization.md)  
**Architecture:** [`ADR 0025 Accepted`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)  
**Assignment:** [`RESPONSIVE-ALL-LAYOUTS-001`](../assignments/responsive-all-layouts-001.md)

## Authority

- **Product Approver:** Human Product Owner / Product Lead  
- **Decision source / date:** In-session authorization 2026-08-06 Asia/Shanghai:
  “认可，按全中文布局 default-off 推广做”

## Product problem

ADR 0025 的 serial-owner 设计布局无关，但产品授权与证据主叙事在九宫格；
26 键（`rime_ice`）尚未作为一等公民完成 default-off 可用性证明与合约锁定。
用户目标是让**所有中文 RIME 布局**都能享受按键不阻塞 RIME 的加强，而不是
仅九宫格。

## Bound Product Decision

### 1. Scope — 全中文 RIME 布局（default-off）

Authorize extending the responsive serial RIME pipeline as a **layout-universal
capability** for Chinese RIME input:

| In scope | Out of scope (this Decision) |
|---|---|
| 中文 26 键（`rime_ice` / non-T9 semantics） | 英文 / 符号 / emoji 非 RIME 重路径 |
| 中文九宫格（`t9`）— 保持已有方向证据 | Release default-on / Product Gate |
| 同一 `isResponsiveRimePipelineEnabled` gate | 自动 anchor 扩展 |
| 布局切换时 session/epoch 安全 | 性能 SLO 锁定 |
| T9-only L1 `·` 展示保持 T9 专属 | 多设备 canary 重开（除非另开） |

### 2. Layering

1. **L0 通用核（必须）**  
   单串行 owner、有序入队、epoch/revision、原子 publish、stale fail-closed —  
   **26 键与九宫格共用**。
2. **L1 可选展示（布局相关）**  
   九宫格 dual-gate 的 provisional `·` **不得**硬套 26 键。  
   26 键 gate-on 允许「无 L1 点、结果稍后到」；若未来要 26 键专属 L1，另开 Decision。
3. **默认**  
   Release 仍 **default-off**（ADR 0004 同步路径）直到未来 Product Gate。

### 3. Relationship to parent T9 work

> **Superseded for current status:** parent `T9-RESPONSIVE-PIPELINE-001` is
> `Reviewed` and not Active as of `2026-08-14`. Text below is historical
> authorization narrative.

- Parent `T9-RESPONSIVE-PIPELINE-001` remains Active; this Decision **extends**
  product scope rather than replacing T9 evidence.
- Parent non-claim “26-key unchanged unless separately authorized” is **amended**
  by this Decision: 26-key may use the responsive path when the gate is **on**,
  still without Release default-on.
- CANARY-001 Stop/Retain and Formal R5 FAIL history remain.

### 4. Explicit non-authorization

- Product Gate / shipping / App Store claims  
- Release dual-gate default-on  
- Performance SLO  
- English-layout claims  
- Forcing T9 L1 UX onto 26-key  

## Implementation follow-through

| Action | Authorized? |
|---|---|
| PD/Assignment + ADR amendment note | **Yes** |
| KeyboardCore tests proving 26-key gate-on L0 + no T9 L1 | **Yes** |
| Code fixes if inventory finds 26-key holes under gate-on | **Yes** (default-off only) |
| Doc / Dashboard / Index sync | **Yes** |
| default-on / Product Gate | **No** |

## Explicit non-claims

- Not Product Gate  
- Not default-on  
- Not SLO  
- Not “all keyboard modes including English”  
