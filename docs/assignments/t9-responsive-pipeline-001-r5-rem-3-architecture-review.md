# Architecture Review: T9-RESPONSIVE-PIPELINE-001 / R5-Rem-3 design freeze

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent；对抗性 **design-only** 审查）  
**Date:** `2026-07-31 Asia/Shanghai`  
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Phase:** R5-Rem-3 — provisional **L1** composition **design freeze only**  
**Product authority:** Human Product Owner authorized **Rem-3 design only**  
  （见 [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) § R5-Rem-3）  
**Design under review:**  
  [`t9-responsive-pipeline-001-r5-rem-3-design.md`](t9-responsive-pipeline-001-r5-rem-3-design.md)  
**Parent design (O3):**  
  [`t9-responsive-pipeline-001-r5-remediation-design.md`](t9-responsive-pipeline-001-r5-remediation-design.md)  
**Predecessor evidence (context; not re-litigated as Fail):**  
  [`../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md)  
  — Rem-Device **direction PASS** (key-feel); residual VISIBLE lag spikes  
**ADR:** [`0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) — **Status remains `Proposed`（本审查不 Accept）**  
**Tip to bind:** `617773e` — `docs: align R5-Rem publication hygiene and freeze Rem-3 design`

| Field | Value |
|---|---|
| **Verdict** | **Pass with conditions** |
| **P0** | **0** |
| **P1** | **4**（阻断 **implementation authorization recommendation**） |
| **P2** | **4** |
| **P3** | **3** |

> **判定原则：** 本审查只审 Rem-3 **设计冻结** D1–D8 是否对 dual-gate 下 provisional L1 形成 **连贯、可实现、隔离安全** 的结构；**不**审实现代码（尚无 Rem-3 实现授权）；**不**把 Rem-Device PASS / Formal R5 FAIL 历史重开为本刀 Fail；**不**声称 Quality Pass、Product Gate、ADR 0025 Accept、Release default-on、implementation authorization。  
> **强制声明：** 本审查 **不** 授权 implementation、**不** Accept ADR 0025、**不** 开启 Product Gate、**不** 将 dual-gate 置 default-on。

---

## 1. Scope of this review

### In scope

| 面 | 检查目标 |
|---|---|
| **D1–D8 连贯性** | L0/L1/L2 权属、何时可 paint、Delete、选择、metrics、placement、tests、与 Rem-Device PASS 关系 |
| **ADR 0025 Proposed 对齐** | 有序输入、禁止第二 live session、UI coalesce 不 skip engine apply、原子 L2 publish、fail-closed selection |
| **Digit / host safety** | 永不向 host 暴露内部 T9 digits；skip-if-unsafe |
| **Isolation** | MainActor pure / Core pure only for L1；无 librime；无 `@unchecked Sendable` |
| **Gate-off 不变** | L1 仅 dual-gate；gate-off = L0+L2 sync（今日 ADR 0004） |
| **Non-claims** | design 本身是否自我约束 Gate / default-on / ADR Accept / 历史改写 |
| **结构洞** | pure builder 输入、Delete mirror、presentation generation / epoch / revision 竞态、L1 vs Path/Partial Commit |

### Out of scope / 禁止借本 Pass 偷渡

- Rem-3 **implementation** authorization 或任何生产代码改动
- Rem-Device PASS 改写为 Product Gate；Formal R5 FAIL 改写为成功
- ADR 0025 Accept / R6 / Release dual-gate default-on
- 数值 product SLO 锁定
- 重开已关闭 Rem-1/2 P1-1（presentation generation）为 Fail，除非 Rem-3 design 放大为新阻断
- R4-Wire residual `performOrderedNow` 全量重审 — 仅在与 L1 Delete 合同冲突时记条件

---

## 2. Sources reviewed

| Artifact | Role |
|---|---|
| `docs/assignments/t9-responsive-pipeline-001-r5-rem-3-design.md` | **Primary** — D1–D8 freeze |
| `docs/assignments/t9-responsive-pipeline-001-r5-remediation-design.md` | Parent O3 / L0–L2 分层 / D3 metrics 文法 |
| `docs/evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md` | Residual VISIBLE lag；O2 coalesce 未充分；L1 缺失语境 |
| `docs/architecture/decisions/0025-responsive-rime-serial-input-pipeline.md` | Proposed：ordered input、coalesce、atomic L2、fail-closed、isolation |
| `docs/product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md` | Rem-3 design-only；implementation closed |
| `docs/assignments/t9-responsive-pipeline-001-r5-rem-1-2-architecture-review.md` | Prior style；P1-1 presentation generation closed；`VisibleSource.provisional` 预留 |
| `docs/assignments/t9-responsive-pipeline-001-r5-preflight-architecture-review.md` | Prior design-phase review style sample |
| Working-tree read-only context（**非** Rem-3 实现审查） | `T9PreeditResolver`、`ResponsiveRimeFeltMetrics`、`isLivePresentationSnapshot`、`ThreadAffineRimeEngineBridge.deleteBackward` → `performOrderedNow`、Delete/`handleDeleteBackward` 路径 |

**Tip honesty:** 本审查绑定 tip **`617773e`** 的 design 文档内容；工作树既有 Rem-1/2 结构仅作 **冲突/可行性** 对照，**不**构成 Rem-3 已实现或 Arch Pass on code。

---

## 3. Executive structural judgment

| Dimension | Judgment |
|---|---|
| 问题陈述与 Rem-Device residual 对齐 | **Held** — L1 针对 “owner 落后时无 progressive composition authority”，非重写 key-feel PASS |
| L0 / L1 / L2 分层意图 | **Sound** — L2 权威、L1 覆盖、L1 不上屏、选择绑 L2、gate-off 无 L1 |
| 隔离与 dual-session 禁令 | **Held in freeze text** — pure MainActor / Core；禁 librime on L1 paint |
| Digit-safety 意图 | **Held as policy** — skip rather than paint digits |
| Selection fail-closed 意图 | **Mostly held** — D4 表清晰；**mixed L1-ahead + stale L2 chrome** 见 P1-4 |
| 与 ADR 0025 Proposed | **大体兼容**；L1 局部 composition paint 相对 §5 原子快照需 **显式例外**（P2-2） |
| 可实现性（implementation-ready） | **Not yet** — 4× P1 必须先补 design 补丁再推荐实现授权 |
| Non-claims / 授权边界 | **Held** — design 明确 design-only；本审查亦不授权实现 |

**结论一句话：** D1–D8 作为 **产品/架构方向** 与 parent O3 一致且 isolation/digit/fail-closed **意图正确**，但作为 **可执行 freeze** 在 pure builder 状态机、revision 水印、纯数字 T9 主机可见 chrome 算法、以及 L1-ahead 时旧 L2 候选/Path 交互上 **仍有结构性洞**。  
**Verdict = Pass with conditions**（条件 = 关闭 P1 的 design 补丁；**关闭前不推荐** Product 发 implementation authorization）。

---

## 4. Design freeze D1–D8 disposition

### 4.1 Layer model（§3 + parent D1）— **Pass（概念）**

| Layer | Freeze | Arch |
|---|---|---|
| L0 Accept | enqueue；不阻塞 librime | 与 dual-gate 已证方向一致 |
| L1 Provisional composition | digit-safe 可见 preedit；无 librime | 正确填补 Rem-Device residual |
| L2 Engine snapshot | composition + Path + candidates 权威 | 与 ADR 0025 §5 一致 |

Rules 1–5（L2 wins、atomic overwrite、L1 不 commit、选择绑 L2、gate-off 无 L1）**概念关闭**。

---

### 4.2 D1 — When L1 may paint — **Pass with P1-1**

| Check | 结构评价 |
|---|---|
| Dual-gate only | **Yes** — 与 PD / gate-off 不变一致 |
| T9 nine-key composition only | **Yes** — 收窄 26-key 范围正确 |
| Action class = processKey / ordered delete 同类 | **Yes** 意图；Delete 实际 dual-gate 路径见 **P2-1** |
| Epoch tagging | **Partial** — 仅写 epoch；**revision / presentation watermark** 相对 L2 不足 → **P1-1** |

**P1 冲突句（D1 Epoch 行）：**

> “L2 with matching epoch **always replaces**”

相对既有 Rem-2/P1-1 实现（`isLivePresentationSnapshot`：同 epoch 下 **拒绝** `revision ≤ lastPresentedRevision`），“always replaces” 若被字面实现，允许 **旧 revision L2 覆盖较新 L1**（owner 乱序交付 / coalesce 缓冲 / late delivery）。  
**必须**改为：同 epoch 下 L2 仅当 `revision ≥` 当前 presentation / provisional watermark（并匹配 live epoch / generation）才可原子覆盖 L1。

---

### 4.3 D2 — What L1 may show — **Pass policy; P1-2 + P1-3 implementability**

**Allowed / Forbidden 列表：** 方向正确（禁猜中文、禁假 Path、禁 librime、禁 Partial Commit ledger、禁 host commit；skip 优于 digit flash）。

**结构洞：**

1. **Builder 签名过薄（P1-2）**  
   D6：`(lastL2Snapshot?, acceptedRawDelta) -> ProvisionalPresentation?`  
   在 owner stall 下 **连续 N 次 accept 且尚无 L2** 时，单次 delta + optional lastL2 **不足以** 表达累积 raw identity。需要 **MainActor 侧 provisional raw / slot ledger**（按 epoch 生命周期；accept 追加 / delete 缩短；L2 对齐或覆盖），而非一次性 `acceptedRawDelta`。

2. **纯数字 T9 的 host-safe progressive 算法未冻结（P1-3）**  
   现有 pure 基线 `T9PreeditResolver.visiblePreedit` 在 **无 comment / 无 Path letter** 时对纯 digit raw **过滤后为空**（正确：不向 host 泄 digit）。  
   Design 称 “group-letter or comment-safe placeholders **already used elsewhere**”，但仓内 **没有** 已批准的 “按 T9 键位长度向 host 画 progressive 组字且非 digit” 的 pure 产品算法：
   - 复用 group 首字母（`2→a`）= **猜拼写**，与 “不猜中文/不发明 Path” 精神冲突，且易与后续 L2 闪烁冲突；
   - 仅依赖 last L2 comment 投影 = **首键 / 冷启动 stall 无 L1**；
   - 非字母占位（`·` 等）= **新产品 chrome**，未冻结。  
   在算法未冻结时，实现者只能 **大量 L1_SKIP**（design 允许）→ Rem-3 **可能几乎不关闭** Rem-Device residual blank lag。  
   **在推荐 “provisional 组字” 实现授权前，必须冻结 v1 纯算法 + 明确 skip 占比可接受性。**

3. **“Optional pending engine chrome”** 未规定 UI 合同（P3）— 不阻断，但 selection fail-closed 依赖它时需与 P1-4 一起写清。

---

### 4.4 D3 — Delete / backspace — **Pass intent; P1-2 + P2-1**

| Rule | 评价 |
|---|---|
| Delete 仍 FIFO 入 owner | **意图正确**（ADR 0025 §3） |
| L1 mirror accepted raw length | **需要 provisional ledger**（P1-2）；“raw length” vs “host visible length” 未拆 |
| Unsafe → clear to last L2 or empty | **Fail-closed display** 正确 |

**现实路径张力（P2-1，非本刀 Fail 历史）：** dual-gate `ThreadAffineRimeEngineBridge.deleteBackward` 走 `performOrderedNow`，MainActor 会 **等待** owner 排空含 backlog 的 delete（R4-Wire residual）。Design 文案写 “enqueues … in order” 更接近 async accept 模型。  
**Rem-3 freeze 应二选一写死：**

- **A（v1 推荐）：** Delete 保持 `performOrderedNow` → L1 delete mirror **非主路径**（L2 同步返回）；D3 降为 “若未来 async delete 再启用 mirror”；或  
- **B：** Rem-3 范围 **显式包含** async ordered delete + L1 mirror（扩大授权面，需 Product 知情）。

未写清则实现者可能同时做 “L1 delete mirror” 与 “同步 performOrderedNow”，产生双重缩短 / 闪烁。

---

### 4.5 D4 — Selection and Partial Commit — **Pass with P1-4**

表内 **L1-only → fail closed** 正确，且符合 ADR 0025 §4 / PD fail-closed。

**洞（P1-4）：** 连续输入时常见状态是 **L1-ahead-of-published**，而 **上一 revision 的 L2 候选 / Path chrome 仍留在屏上**：

| 用户动作 | 若仅按 “L1-only composition” 字面 |
|---|---|
| Candidate tap 绑 **旧 L2** `sessionEpoch+revision` | 可能 **通过** 既有 bound-revision 校验，但相对 **当前 provisional 长度/raw** 语义错误 |
| Space / 选定 | 同上 |

**必须冻结：** 当 MainActor `provisionalAhead`（或 L1 active flag / provisional watermark > last L2 published revision）时：

1. **所有** 候选 / Path / 选定 / Partial Commit **fail closed**（即使仍有旧 L2 identity），**或**  
2. L1 paint **同时** 清空/禁用候选与 Path 选择 affordance（D2 optional chrome 升级为 **v1 必选**），且 selection 仍绑最新 **published L2** 且要求 `publishedRevision == provisionalAcceptedRevision`（无 ahead）。

“L1-only” 一词不足以覆盖 **mixed stale-L2 + newer L1**。

Partial Commit “fail closed or require L2” — **可接受**；实现应选 **require L2 published identity matching current composition authority**，避免半句提交。

命名冲突（P2-3）：仓内 “provisional Path”（ADR 0023）≠ Rem-3 L1 provisional composition。Freeze 应规定实现命名（如 `ResponsiveProvisionalComposition` / `l1ProvisionalPreedit`），禁止复用 Path `provisionalPathID` API 承载 L1。

---

### 4.6 D5 — Metrics — **Pass（content-free 意图）；P2-4 / P3**

| Marker | 评价 |
|---|---|
| `source=provisional` / `engine` | 与 parent D3 + 既有 `VisibleSource` enum **对齐** |
| `source=replace` optional | enum **尚未**有 `replace` — 可选则 OK（P3）；若要做须扩 enum 与 “first visible” 语义 |
| `L1_SKIP reason=…` | 新文法 — content-free reason token 需冻结集合（P3） |

**诚实性：** Rem-1 tracker 的 `recordVisible` 是 **first visible per revision watermark**；L1 后 L2 replace 是否再打 VISIBLE 需冻结（design optional `replace`）。不阻断 design Pass。

---

### 4.7 D6 — Implementation placement — **Pass guidance; depends on P1-2**

| Rule | 评价 |
|---|---|
| Pure KeyboardCore builder + 单测 | **Yes** |
| Accept 后 MainActor 应用 L1 + VISIBLE provisional | **Yes** |
| L2 apply 清 L1 + atomic L2 + P1-1 gates | **Yes**；须并入 **provisional watermark**（P1-1） |
| 无 dual session / 无 `@unchecked Sendable` | **Yes** |

---

### 4.8 D7 — Test minimum — **Pass as matrix shape**

覆盖 Fake stall、L2 replace digit、selection fail-closed、gate-off、delete、epoch abandon、26-key 无 L1 — **形态充分**。  
**应补进 freeze（条件级，可并入 P1 关闭）：**

- multi-accept before any L2：provisional raw ledger 单调；
- stale L2 revision 不得覆盖更新 L1；
- L1-ahead 时旧候选选择 fail-closed；
- pure-digit 算法用例（一旦 D2 算法冻结）。

---

### 4.9 D8 — Relationship to Rem-Device PASS — **Pass**

不改写 PASS/FAIL 历史；L1 optional leverage；Product 可 Hold — **与 PD 一致**。

---

### 4.10 Risks / Non-claims / Handoff — **Pass**

| Item | 评价 |
|---|---|
| Risks 表 | 覆盖 flicker / digit / selection / scope / coalesce / Gate 误读 |
| Explicit non-claims | **完整** — 无 implementation / Gate / ADR Accept / default-on / SLO |
| Product template | 正确收窄；**本审查不视为已授权** |

---

## 5. ADR 0025 Proposed — conflict check

| ADR 条款 | Rem-3 freeze | 冲突？ |
|---|---|---|
| §1 单 serial owner；无第二 session | L1 无 librime；无 MainActor live session | **No** |
| §2 MainActor UI / marked text | L1 在 MainActor 写 presentation | **No**（职责内） |
| §3 有序输入；禁止 drop/merge/reorder | 引擎仍 FIFO；L1 仅 presentation | **No** |
| §3 UI coalesce | L1 每键 progressive + L2 latest-only 可共存 | **No**；需 revision 水印（P1-1） |
| §4 epoch/revision；selection fail-closed | D4 意图对齐 | **Partial** — mixed chrome（P1-4） |
| §5 **Atomic** composition+Path+candidates | L1 可能只改 composition / 清空候选 | **需显式例外**（P2-2）：L1 不是 L2 publish；L2 到达时仍原子 |
| §7 禁 `@unchecked Sendable` | D6 明示 | **No** |
| §8 feature gate | dual-gate only；default-off | **No** |
| §9 content-free diagnostics | D5 | **No** |

**结论：** 与 **Proposed** ADR 0025 **无硬冲突**；实现时不得借 L1 Accept ADR。

---

## 6. Findings

### P0

*无。*

（无隔离绕过授权、无 default-on、无第二 librime session、无 “实现已授权” 越权文本。）

### P1 — 阻断 implementation authorization recommendation

| ID | Finding | 影响 | 关闭条件（design 补丁） |
|---|---|---|---|
| **P1-1** | D1 写 “matching epoch L2 **always replaces**”，未冻结 **revision / presentation generation / provisional watermark** 相对 L1 的偏序。与既有 `lastPresentedRevision` 门控不一致。 | 晚到的旧 L2 可 **回滚** 已前进的 L1 组字；coalesce / late delivery 下可见倒退。 | 冻结：L1 accept 推进 `provisionalAcceptedRevision`（或等价）；L2 apply 仅当 `epoch` 匹配 **且** `revision ≥ max(lastPresented, provisional watermark)`（或 design 规定 L1 写入同一 presentation watermark）；abandon 清 L1 + generation（与 P1-1 Rem-2 一致）。 |
| **P1-2** | Pure builder 输入 `(lastL2?, acceptedRawDelta)` **欠定**；缺 MainActor **累积** provisional raw/slot ledger（含 multi-key stall、delete 缩短、L2 对齐）。 | 实现无法在 “无 L2 的连续 accept” 下正确 mirror；Delete D3 与 D6 签名不一致。 | 冻结状态机：`ProvisionalCompositionMirror`（epoch, acceptedRevision, rawOrSlotCount, hostSafePreedit?, l1Active）；accept/delete/L2/abandon 转移表；builder 读 mirror 而非单 delta。 |
| **P1-3** | **纯数字 T9** host-safe progressive 显示算法未冻结；“已有 group-letter placeholders” 在 Core 中 **无** 对应产品级 pure 路径；skip 默认可能使 L1 **无效**。 | 无法诚实声称 Rem-3 关闭 blank-lag residual；或实现者发明不安全/猜写算法。 | 在 design 中 **二选一写死 v1**：**(A)** 具体 pure 算法（输入/输出/digit proof/禁止项）+ 单测矩阵；**(B)** 明确 v1 L1 **仅** 在 lastL2 scaffolding 可安全延长时启用，冷启动 pure-digit **允许** skip，并降低 Product 期望。 |
| **P1-4** | “L1-only” 未覆盖 **L1-ahead + stale L2 候选/Path**；选择可能绑旧 L2 而 composition 已 provisional 前进。 | 错选 / 错上屏风险；违背 PD fail-closed 精神。 | 冻结 `provisionalAhead` 时 selection/Partial Commit **一律 fail closed**，并规定 L1 paint 时候选/Path 选择 affordance 的必选行为（清空或 disabled）。 |

### P2

| ID | Finding | 建议 |
|---|---|---|
| **P2-1** | Delete 文案 “enqueue FIFO” 与 dual-gate **`performOrderedNow` 同步 delete** 现实不一致。 | 在 D3 写死 A（L1 delete 非主路径）或 B（扩大 async delete 范围）。 |
| **P2-2** | ADR 0025 §5 原子三元组 vs L1 局部 composition 更新未写 **显式例外**。 | 增加一句：L1 是 pre-L2 presentation aid；**不**声称 L2 原子 publish；L2 到达仍原子覆盖 composition+Path+candidates 并清 L1。 |
| **P2-3** | “provisional” 与 ADR 0023 provisional Path **命名碰撞**。 | 规定 L1 类型/flag 命名空间；禁复用 Path provisional API。 |
| **P2-4** | optional `source=replace` 与现有 `VisibleSource` 二元 enum 张力；`L1_SKIP` 未接入 FeltMetrics 文法注册表。 | 实现前扩 enum 或删 optional replace；`L1_SKIP` reason 枚举写入 design。 |

### P3

| ID | Finding |
|---|---|
| **P3-1** | Optional “pending engine” chrome 无 UI 状态字段表（empty list vs stale list）。 |
| **P3-2** | Device scoring “share of provisional” 在 skip-heavy（P1-3-B）下可能长期接近 0 — 评分解释需预告。 |
| **P3-3** | D7 未显式列 multi-accept-before-L2 / stale-L2-vs-newer-L1 用例（关闭 P1 时可并入）。 |

---

## 7. Boundary / non-claims held by this review

| Claim | 本审查 |
|---|---|
| Rem-3 **implementation authorized** | **否** |
| ADR 0025 **Accepted** | **否** — 仍 **Proposed** |
| Product Gate / Release default-on | **否** |
| Rem-Device PASS → Gate | **否** |
| Formal R5 FAIL 推翻 | **否**（不重开为 Fail，亦不改写） |
| Quality Pass | **否**（无实现可测） |
| 数值 SLO | **否** |

**Explicit：**  
**This review does NOT authorize implementation, ADR Accept, Product Gate, or default-on.**

---

## 8. Conditions for upgrading toward implementation-ready freeze

在 **不** 把本文件读成 implementation auth 的前提下，Architecture 建议 Product **仅在** 下列条件满足后，再考虑签发 Rem-3 实现授权（授权文本仍须 Human Product Owner 显式发出）：

1. **关闭 P1-1 … P1-4** 的 design 补丁（或 Architecture re-review 同等关闭）。  
2. 保持 non-claims：default-off、ADR Proposed、无 Gate、无 auto-anchor 扩展。  
3. 实现授权范围与 P1-3 选项 **A 或 B** 字面一致（避免 “组字” 话术与 skip-only 实现落差）。  
4. Delete 范围按 P2-1 A/B 与授权模板同步。

**若 Product 选择 Hold L1：** 本 freeze 仍可作为 **方向记录**；Rem-Device PASS caveats 继续有效；**无需** 为实现关闭 P1。

---

## 9. Verdict rationale

| Dimension | Judgment |
|---|---|
| 方向与 parent O3 / Rem-Device residual | **对齐** |
| Isolation / digit / gate-off / non-claims | **Freeze 文本守住** |
| 与 ADR 0025 Proposed | **可兼容**（§5 需例外说明） |
| 可执行完备性 | **不足** — 4× P1 |
| P0 | **0** |
| 是否推荐立即 implementation auth | **否**（待 P1 design 补丁） |

### **Verdict: Pass with conditions**

- **Pass：** 分层、安全边界、dual-gate-only、L2 权威、metrics/test 骨架、non-claims 可作为 **设计方向** 接受。  
- **Conditions：** P1-1…P1-4 必须在 **任何** implementation authorization recommendation 之前以 design 补丁关闭；P2 建议在同一补丁或实现 kickoff 前澄清。

---

## 10. Handoff

**To:** 🧭 Human Product Owner / Product Lead  

**Suggested next moves（择一；本文件不授权）：**

1. **Design patch** — Architecture 关闭 P1-1…P1-4（+ 建议 P2-1/2）→ 可选 Arch re-review → 再议实现授权。  
2. **Hold L1** — 保持 dual-gate default-off；Rem-Device key-feel PASS 作为当前方向证据上限。  
3. **Priority switch** — RELEASE-2026-0801 / 9KEY-PINYIN-002 等（与 Rem-3 无关）。

**Not handed off as authorized work:** Rem-3 implementation、Rem-3-Device knife、ADR Accept、Product Gate。

---

## 11. Checklist disposition

| Item | Disposition |
|---|---|
| D1–D8 coherent direction | **Pass with conditions** |
| ADR 0025 Proposed conflicts | **No hard conflict**; §5 exception needed (P2-2) |
| Digit-safety policy | **Pass** intent; algorithm freeze **P1-3** |
| No second librime session | **Pass** in freeze |
| Fail-closed selection | **Pass with P1-4** |
| Gate-off unchanged | **Pass** |
| Non-claims | **Pass** |
| Pure builder implementability | **P1-2** |
| Delete mirror vs raw identity | **P1-2 + P2-1** |
| Race vs presentation generation / epoch / revision | **P1-1** |
| L1 vs Path / Partial Commit | **P1-4 + P2-3** |
| Implementation / Gate / ADR / default-on authorized by this review | **No** |

---

*End of Rem-3 design-freeze architecture review — tip `617773e`.*

---

## Addendum A — Design Amendment A disposition (same day, post-review)

**Date:** `2026-07-31 Asia/Shanghai`  
**Role:** Architecture Steward recording Executor design patch against this review  
**Patched design:** [`t9-responsive-pipeline-001-r5-rem-3-design.md`](t9-responsive-pipeline-001-r5-rem-3-design.md) **D9 Amendment A**  
**Note:** This addendum is **not** a second independent re-review. Product may treat
Amendment A as sufficient close of P1 for implement-auth **decision**, or request a
formal Arch re-review of the amended freeze.

| Finding | Amendment A close | Status for implement-auth recommendation |
|---|---|---|
| **P1-1** | D1 watermark + Rule 1: L2 needs live gates **and** `revision ≥` floor | **Closed in design text** |
| **P1-2** | D6 provisional raw ledger + builder on ledger | **Closed in design text** |
| **P1-3** | D2 v1 = `·`×N structure-only; forbid letter-guess / Chinese | **Closed in design text** |
| **P1-4** | D4 provisionalAhead fail-closed all selection; required chrome disable | **Closed in design text** |
| **P2-1** | D3 Delete path **A** (performOrderedNow; L1 delete non-primary) | **Closed in design text** |
| **P2-2** ADR §5 exception | Non-claims + L1 presentation exception documented | **Acknowledged** |
| **P2-3** naming | ResponsiveProvisionalComposition / no Path provisional API reuse | **Closed in design text** |

**Updated Arch stance after Amendment A (documentation-level):** P1 blockers from
this review are **addressed on paper**. Independent Arch **code** review remains
mandatory after any implementation. This addendum still **does not** authorize
implementation, ADR Accept, Product Gate, or default-on.
