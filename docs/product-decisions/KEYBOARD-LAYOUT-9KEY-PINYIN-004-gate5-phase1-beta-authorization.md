# Product Decision: KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 — Phase 1 β-Limited Authorization

**Decision ID:** `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-004-GATE5-PHASE1-BETA`  
**Lifecycle status:** `Recorded`  
**Date / timezone:** `2026-07-23 Asia/Shanghai`  
**Parent:** [`PD-…-004`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md)  
**Prior Gate5 path:** [`PD-…-004-GATE5-PATH`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-path-decision.md)  
**Assignment:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-004`](../assignments/keyboard-layout-9key-pinyin-004.md)  
**Inputs:** Phase 0.5 + 0.6 Spikes and independent Architecture/Quality reviews  

## Authority

- **Product Approver:** Product Lead（本会话 Human Product Owner 已授权 Product Lead 路径裁决；需要真人真机时见 §6）
- **Does not replace:** Architecture 对 reducer 边界复审；Quality 对测试证据；Human Product Owner 对 Human Gate 填表

## Context

| Item | Status |
|---|---|
| A 真机精确部分候选 | Pass（保留） |
| B 真机单字「请」 | Fail；raw unchanged；coverage **UNKNOWN** |
| C 真机误触 Delete | Fail |
| Path α（0.5 `sel_*` + 0.6 caret/raw/compLen/highlight） | **Closed negative**（Architecture Accept） |
| 完整 B 契约（消费 `qing` 后保留 `wei/fan/dao` 并聚焦 `wo`） | **本决策不收窄、不宣称可交付** |

## Bound Product Decisions

### 1. Path α closed

1. 在当前 pinned t9 + 公开 librime 观测面上，**不再**授权新的 coverage Spike，除非另文扩大调研边界（schema/vendor/非公开 API）。  
2. `sel_*` / caret / raw 差分 / composition.length / previewLen **不得**被实现者重新解释为 B 的槽位消费权威。

### 2. Authorize Phase 1 β-limited only

授权实现**有限** identity 修复：

| 子目标 | 产品期望 | 是否宣称 Human Gate B 可过 |
|---|---|---|
| **C** Append/Delete 身份 | 误触→Delete 可逆；继续输入不复制音节、不回错误首焦点 | 修复后应可挑战 C 真机 |
| **A-class / shortened remainder** | RIME **明确缩短** remaining 且可严格唯一后缀编码到 `sourceDigits` 时，Path 正确重基准 | 与已 Pass 的 A 相容；自动化锁死 |
| **B / unchanged-raw** | **Fail-closed only**：无 coverage 时 **禁止猜测**消费前缀；**禁止**错误 Path 重基准（保持上一一致态或显式清空 composition/Path，由 Architecture 在实现复审中二选一并 fail-closed 测试） | **否** — B 完整契约仍 Fail 直至另决策 |

**统一手段（推荐）：** 内部纯值 `T9CompositionIdentity`（或等价）只处理**允许分支**；未知形态 fail-closed。

### 3. Explicit non-authorization

本决策 **不**授权：

1. 用汉字数、comment、preedit 显示、候选排名、`sel_*`、caret、previewLen 推断 B 消费槽位；  
2. 宣称 B Human 契约已满足或 Human Product Gate 通过；  
3. 修改 PD-004 主体、ADR 0023、catalog、26 键、UIKit（除既有 Gate5 诊断若 Architecture 允许删除/收敛）；  
4. commit / push / PR（须后续单独授权）；  
5. 为修 B 而引入热路径 RIME probe 笛卡尔积或第二候选引擎；  
6. 扩大 schema/vendor 调研（须新 PD）。

### 4. B 验收立场

1. **不收窄** Assignment/plan 中 B 的完整契约文案。  
2. 诚实记录：β-limited 交付后 B **仍预期** Human Fail 或仅“不更错”。  
3. 完整关闭 Gate 5 仍依赖未来之一：新调研找到权威、产品收窄 B、或 Human Product Owner 另决策。

### 5. γ deprioritize

**仍拒绝**将整个 Gate 5 降为非 Active：C 与 shortened 分支仍值得修，且阻塞 004 体验。

## Implementation gates

1. Executor 仅在 Assignment **Phase 1 β-limited allowlist** 内实现。  
2. 必须有定向自动化：C 红测转绿；shortened remainder；unchanged-raw **fail-closed**（不得错误重基准）；26 键隔离。  
3. 独立 Architecture + Quality 复审通过后，才可请求 Human 真机。  
4. Human 复测矩阵须**分项**记录 A/B/C；Executor **不得**代填。

## Human Product Owner — when we need you

| 何时 | 需要什么 |
|---|---|
| **现在** | 无需操作（除非否决本 β-limited 方向） |
| **β-limited 自动化 + 独立复审通过后** | iPhone 13 Pro · 备忘录 · 复测 **A / B / C**（及可选完整 1–8）；**诚实填 B**（预期仍可能 Fail） |
| **若希望完整修 B 再关 Gate 5** | 另开会话做产品决策：收窄 B、或授权超公开 API 调研 |
| **若希望暂停 Gate 5** | 明示 γ，Product Lead 再记一笔 |

## Success definition (this decision only)

| Done | Not done |
|---|---|
| C 自动化 +（复测后）真机挑战 | 完整 Human Product Gate Pass |
| shortened remainder 契约锁死 | B 完整契约 Pass |
| unchanged-raw fail-closed 锁死 | 用禁止信号“修好” B |
| 独立 Architecture + Quality 对 β-limited 范围 Accept/Pass | commit/push/PR 默认发生 |

## Links

- Phase 0.5 review: [`../assignments/keyboard-layout-9key-pinyin-004-gate5-phase05-independent-review.md`](../assignments/keyboard-layout-9key-pinyin-004-gate5-phase05-independent-review.md)  
- Phase 0.6 review: [`../assignments/keyboard-layout-9key-pinyin-004-gate5-phase06-independent-review.md`](../assignments/keyboard-layout-9key-pinyin-004-gate5-phase06-independent-review.md)  
- Gate5 plan: [`../plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md`](../plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md)  
