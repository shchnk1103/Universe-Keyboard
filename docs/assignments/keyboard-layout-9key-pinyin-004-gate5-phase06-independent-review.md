# KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 Phase 0.6 — Independent Architecture + Quality Review

**Date:** 2026-07-23 Asia/Shanghai  
**Review roles (KOS 2.0):**  
- 🏛️ Architecture & Knowledge Steward  
- 🧪 Quality, Performance & Release Maintainer  

**Reviewed work:** Phase 0.6 alternative coverage / selection-delta Spike（Executor: Grok 4.5）  
**Evidence:** remediation evidence §16；`evidence/…/phase06/20260723-155717/`  
**Product path:** [`PD-…-004-GATE5-PATH`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-path-decision.md)  
**Predecessor:** Phase 0.5 independent review（`sel_*` = `UNRELIABLE_MENU_SCOPED_ONLY` Accepted）

### Independence statement

本复审为 KOS 2.0 角色切换后的独立审查，与 Phase 0.6 Executor 任务角色分离。强制手段：

1. 不采信聊天叙事；  
2. 独立重算 allowlist SHA-256；  
3. 独立重跑 Phase 0.6 + Phase 0.5 回归 Spike；  
4. 扫描 Partial/Path 是否接入新字段；  
5. 对抗性检查 verdict 是否观测驱动、是否误用禁止信号。  

---

## 1. Scope

| In scope | Out of scope |
|---|---|
| Phase 0.6 否定/肯定结论 | Phase 1 实现 |
| 新只读字段与 highlight API 边界 | Human Product Gate |
| allowlist / 禁止项遵守 | commit / push / PR |
| 对 Product Lead 的下一步建议 | 改 PD-004 / ADR 0023 |

---

## 2. Architecture Review

### 2.1 Coupling & boundary

| Check | Result |
|---|---|
| `T9CompositionIdentity.swift` | **ABSENT** |
| `caretPositionInRaw` / `commitPreviewLength` / `selection*` 在 Partial/T9Path | **None** |
| PD-004 / ADR 0023 / catalog / UIKit / 26-key | **未改** |
| 新生产表面 | 只读透传 + highlight 观测 API |

### 2.2 Re-validated empirical finding

独立复跑（`phase06-independent-review-rerun.log`）与 Executor 一致：

```text
verdict=UNRELIABLE_NO_ALLOWED_SLOT_MAP
singleRawDelta=0 singleCaretDelta=0 singleCompDelta=2
raw/caret/comp DeltaMapsSingle=false
singleRawUnchanged=true bBlockedByUnchangedRaw=true
legalCuts=4/7/10/13
```

架构解释（**Accept** Executor 否定结论）：

1. **`get_caret_pos` 在 B 形态下不是消费权威。** 选择前后 caret 均钉在 raw 末尾（24）；delta=0。  
2. **raw 差分在 B 为 0**；无法从 remaining raw 推断未消费后缀（与设备/0.5 一致）。  
3. **`composition.length` 差分 = 2**，不落在 pre-selection 合法槽切点 `{4,7,10,13}`。  
4. **highlight 会改变引擎状态**（compLen、sel、previewLen），证明 menu 内状态有 per-highlight 变化，但：  
   - `sel_*` 已在 0.5 判定为 menu-scoped，不可作槽位权威；  
   - previewLen 属汉字数字节长度类信号，**Product 禁止**作槽位映射；  
   - allowed 向量变化量 **不能** 映射到 T9 `sourceDigits` 唯一切点。  
5. **整句提交 / shortened remainder 清空 raw** 可与 B 区分，但给出的是“全消或全提交”，**不是** `qing→0..<4` 级消费证明。  
6. **Path α 在当前公开 librime 表面（本 pinned t9）已穷尽合理观测：** `sel_*`、caret、raw 差分、composition.length、highlight、commit preview 长度。无剩余 allowlist 内明显候选权威。

### 2.3 Architecture answers (§16.8)

| # | Question | Decision |
|---|---|---|
| 1 | 同意 `UNRELIABLE_NO_ALLOWED_SLOT_MAP`？ | **Yes — Accept** |
| 2 | 只读 caret / length / previewLen / highlight 可保留？ | **Yes — Accept with constraints**（§2.4） |
| 3 | Phase 1 仍 No？ | **Yes — Phase 1 No** |
| 4 | 建议 Product Lead？ | 见 §5 |

### 2.4 Read-only interface contract (Architecture Accept)

允许保留：

| API | Constraint |
|---|---|
| `selectionStart/End` | 0.5 约束不变 |
| `caretPositionInRaw` | **不得**作 T9 槽位消费权威 |
| `RimeComposition.length` | **不得**作槽位权威 |
| `commitPreviewLength` | **禁止**当汉字数→槽位 |
| `highlightCandidateOnCurrentPage(at:)` | 观测/测试可用；**不得**在未授权下改生产高亮策略并当 coverage |

**硬约束：** 在 Architecture 另行 Accept 新权威前，**禁止**将上述字段接入 Partial Commit / Path identity reducer。

### 2.5 Phase 1 gate

| Decision | Value |
|---|---|
| Enter Phase 1? | **No** |
| Reason | Path α 未找到 Product 允许的 per-candidate 槽位权威；coverage 仍 `UNKNOWN`；B 仍无法在不违反禁止项的前提下证明 `qing` 消费 |
| Note | shortened-remainder 严格后缀 + Path β fail-closed **可以**成为未来 **有限** Phase 1 范围，但须 **Product Lead 书面授权收窄范围**，且 **不得**宣称 Human Gate B 通过 |

### 2.6 Architecture disposition

**Architecture: Accept Phase 0.6 negative finding; Accept read-only observation fields with constraints; Phase 1 No.**

Path α 在当前授权边界内 **closed as negative**。

---

## 3. Quality Review

### 3.1 Evidence matrix

| Item | Result |
|---|---|
| Parser Phase 0.6 fields | **PASS**（独立复跑） |
| Phase 0.6 Spike | **PASS** 0.417s；verdict 一致 |
| Phase 0.5 regression | **PASS**；`UNRELIABLE_MENU_SCOPED_ONLY` 仍成立 |
| Hash vs §16.7 | **Match**（7/7） |
| Reducer 未接入 | **PASS** |
| Phase 1 未实现 | **PASS** |
| commit/push/PR | **未发生** |
| Human Gate claim | **未发生** |

### 3.2 Quality findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| Q1 | **Low** | 0.6 verdict 由 delta×legalCuts 推导，优于 0.5 硬编码布尔；`XCTAssertFalse(reliable)` 在可靠时会失败，方向正确。 | **Accept** |
| Q2 | **Low** | A 冷 fixture 仍为 textLen=7 整句，非「请喂饭到」。否定 B 槽位权威 **不依赖** 精确 A。 | **Accept / residual** |
| Q3 | **Info** | `legalSlotCuts` 来自 Path 账本，作**对照 oracle** 而非引擎信号；用于否定“差分是否碰巧等于合法切点”，方法正当。 | **Accept** |
| Q4 | **Info** | `textLen` 仅作 fixture 定位；未写入 allowedVector。 | **Accept** |
| Q5 | **Info** | 完整 Gate5 Core 红测矩阵未在本复审复跑；0.6 未改身份算法，可接受。 | **Accept** |

### 3.3 Quality disposition

**Quality: Pass on Phase 0.6 Spike evidence; Phase 1 = No.**

---

## 4. Combined Gate decision

| Gate | Status |
|---|---|
| Phase 0.6 Spike completeness | **Accept / Done** |
| Verdict `UNRELIABLE_NO_ALLOWED_SLOT_MAP` | **Architecture Accept** |
| Read-only observation surface | **Accept with constraints** |
| Path α (engine coverage hunt) | **Closed negative** within current librime public surface |
| Phase 1 | **Blocked — No** |
| Human Product Gate | **Still Failed / not re-entered** |
| commit / push / PR | **Not authorized** |

**Stakeholder line:**

> Phase 0.6 independent review: Architecture **No Phase 1** + Accept α negative; Quality **Pass**; coverage **UNKNOWN**; Path α exhausted on pinned t9 public API; **Product Lead must choose** β-limited work, B acceptance narrow, further research, or deprioritize.

---

## 5. Recommendations to Product Lead（非实现授权）

| Option | Meaning | Human Gate B? | Architecture note |
|---|---|---|---|
| **β-limited Phase 1** | shortened-remainder 严格后缀 + unchanged-raw **fail-closed**（禁止错误重基准）；可选 C identity | **仍 Fail B**（除非另收窄） | 可审，须新 allowlist；**不得**猜 qing 槽 |
| **Narrow B acceptance** | 书面改 B 契约（例如接受 fail-closed UI） | 可能过 Gate 若验收改写 | 产品决策，非技术伪装 |
| **Further research** | schema/vendor、非公开 API、其它引擎 | 未知 | **须新 PD allowlist**；当前 α 已穷尽公开面 |
| **γ deprioritize** | 暂停 Gate 5 | Fail 保留 | 产品优先级 |

本复审 **不**代 Product Lead 选择。

---

## 6. Explicit non-claims

- 不宣布 Human Product Gate 通过  
- 不授权 Phase 1 实现  
- 不授权 commit / push / PR  
- 不修改 PD-004 / ADR 0023  
- 不把 previewLen / 汉字数 / comment 洗白为权威  
