# Product Decision: KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 — Path After Phase 0.5

**Decision ID:** `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-004-GATE5-PATH`  
**Lifecycle status:** `Superseded in part by PD-…-GATE5-PHASE1-BETA`（α closed；β-limited Phase 1 authorized）  
**Date / timezone:** `2026-07-23 Asia/Shanghai`  
**Parent Decision:** [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-004`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md)  
**Follow-on:** [`PD-…-004-GATE5-PHASE1-BETA`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md)  
**Assignment:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-004`](../assignments/keyboard-layout-9key-pinyin-004.md)  
**Inputs:** Phase 0.5 Spike + independent Architecture/Quality review  

## Authority

- **Product Approver / Decision maker:** Product Lead（本会话 Human Product Owner 已授权角色切换执行 Product Lead 工作）
- **Does not replace:** Architecture 对 SoT/Phase 1 的否决权；Quality 对证据硬度的否决权；Human Product Owner 对真机 Product Gate 的最终验收权

## Context (product, not chat)

Gate 5 第 5 步 Human Fail 仍在：

- **A**（精确部分候选）本轮真机 **Pass**
- **B**（单字「请」）真机 **Fail**；Bridge/设备均证 raw **不缩短**
- **C**（误触 Delete 后续输）真机 **Fail**

Phase 0.5 独立复审已 **Accept** 否定结论：librime `sel_start/sel_end` **不能**作 per-candidate T9 槽位消费权威。只读透传可保留，但不得接入 reducer。Phase 1 在 coverage 仍为 `UNKNOWN` 时 **Architecture No**。

## Bound Product Decisions

### 1. Phase 0.5 产品关闭

1. Product Lead **接受**独立复审对 Phase 0.5 的结论与约束。  
2. 不将 `sel_*` 记入产品可依赖的消费权威。  
3. **不**因 Phase 0.5 否定结论而宣布 Human Product Gate 通过或失败被“技术关闭”。  
4. 历史 A/B/C Fail/Pass 记录 **保留**，不得改写。

### 2. 路径选择（主路径）

| Path | 含义 | Product 裁决 |
|---|---|---|
| **α** 替代 engine-native / 选择差分 Spike | 继续寻找**非** `sel_*`、且不依赖 comment/汉字数/排名的权威或可证伪信号 | **Primary — 授权执行 Phase 0.6** |
| **β** 无 coverage 时 fail-closed | unchanged-raw 且无法确定消费切点时，**禁止错误 Path 重基准** | **Mandatory safety floor**（见 §3），**不是** Human Gate 的完整解决方案 |
| **γ** 降低 Gate 5 优先级 | 暂停修复 | **Reject（本决策时点）** — Gate 5 仍阻塞 004 Product Gate，保持 Active |

**理由（第一性原理）：**

- 产品验收要求 B 在单字 Partial 后 **保留未消费 Path 身份并聚焦剩余音节**，不是“Path 为空也算修完”。  
- 纯 Path β 只能避免错乱，**不能满足** Assignment/plan 中 B 的契约结果，故不能单独作为关闭 Gate 5 的产品策略。  
- 纯 Path γ 等于接受 004 在 Gate 5 上长期 Human Fail，本时点不接受。  
- 因此必须先做 **Path α**；同时把 **Path β** 钉为任何后续身份实现的安全底线。

### 3. Path β 安全底线（产品强制，先于完整 B 修复）

在获得 Architecture 批准的可靠消费权威之前：

1. **禁止**用候选汉字数、comment、preedit 显示文本、候选排名推断消费槽位（维持复审与 plan 禁止项）。  
2. 若仅有 shortened remainder 且可严格唯一后缀对齐，产品允许该分支修复 Path（与 A 类已 Pass 证据相容）。  
3. 若 raw **不变**且无可靠 coverage：**不得**猜测消费前缀去重基准 Path；必须 fail-closed（保持上一一致态或明确清空 composition/Path，二者择一须在实现前由 Architecture 固定，且 **不得**产生错位 Path / 重复音节）。  
4. Path β **单独实现不得宣称** Gate 5 Human 可过；B 契约仍待 α 成功或未来产品改验收。

### 4. Phase 0.6 授权（Path α）

**工作名称：** Gate 5 Phase 0.6 — Alternative candidate-coverage / selection-delta Spike  

**目标问题（必须回答其一或否定）：**

> 在 A/B 真实选择前后，是否存在 **非 `sel_*`** 的 engine-native 信号，或 **仅由引擎状态差分**（raw / commit / composition 结构 / menu 元数据）构成的、不可由显示文本伪造的消费边界，并能唯一映射到 pre-selection `sourceDigits` 槽位？

**必须覆盖：**

- B：unchanged raw + 单字类候选  
- A：部分多音节候选（尽量复现「请喂饭到」；冷词典失败须记录，不得用完整句冒充 A）  
- shortened remainder 对照  
- 扩展窗口 / 翻页入口  
- 负例：信号缺失、冲突、非音节边界 → fail-closed  

**禁止（与 0.5 相同并加强）：**

- 开始完整 Phase 1 / 生产接入 `T9CompositionIdentity`（除非 α 产出 Architecture Accept 的权威，并另批 Phase 1 allowlist）  
- 用汉字数、comment、preedit 显示、排名猜范围  
- 改 PD-004 主体、ADR 0023、catalog、26 键、UIKit  
- commit / push / PR（除非后续单独授权）  
- 宣布 Human Product Gate 通过  
- 把 `sel_*` 重新解释为 coverage  

**Executor：** 默认由当前线程执行者在 Assignment 再指派后执行；未指派前不得静默开写。  
**完成后：** 独立 Architecture + Quality 复审 → 再回 Product Lead 决定是否开 Phase 1。

### 5. Phase 1 与 Human Gate

1. **Phase 1 仍 blocked**，直到：  
   - α 证明可靠权威并经 Architecture Accept；**或**  
   - Product Lead **另行**书面收窄 B 验收（本决策 **不**收窄）。  
2. Human Product Gate **不重开**，直到实现 + 自动化 + 独立复审允许进入真机复测。  
3. Automation 不得替代 Human 矩阵。

## Non-goals

- 不修改 PD-004 的 catalog / 原子呈现 / 26 键冻结决策正文（本文件是 Gate 5 补丁路径，不 supersede 004 主体）  
- 不授权 schema/vendor 升级  
- 不授权为修 B 而引入第二候选引擎或热路径 RIME probe 笛卡尔积  

## Change Policy

若 α 失败且产品仍要求 B 通过，必须新的 Product Lead 决策（可能含验收收窄或更大架构投入），不得由 Executor 自行降级标准。

## Links

- Independent review: [`../assignments/keyboard-layout-9key-pinyin-004-gate5-phase05-independent-review.md`](../assignments/keyboard-layout-9key-pinyin-004-gate5-phase05-independent-review.md)  
- Remediation evidence: [`../assignments/keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md`](../assignments/keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md)  
- Gate plan: [`../plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md`](../plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md)  
