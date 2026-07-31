# Architecture Review: T9-RESPONSIVE-PIPELINE-001 / R5-Rem-1 + R5-Rem-2

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent；对抗性结构审查）  
**Date:** `2026-07-31 Asia/Shanghai`  
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Phase:** R5-Rem-1（O1 felt metrics）+ R5-Rem-2（O2 dual-gate / MainActor presentation coalesce + R3 context→applied head）  
**Product authority:** Human Product Owner authorized **Rem-1 + Rem-2 only**  
  （不实施 Rem-3 provisional L1；不 default-on；不 Accept ADR；不 Product Gate）  
**Design freeze:** [`t9-responsive-pipeline-001-r5-remediation-design.md`](t9-responsive-pipeline-001-r5-remediation-design.md)  
**Executor evidence:** [`../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md)  
**Predecessor FAIL:** [`../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md) — Formal R5 direction **FAIL**（freeze-then-burst）  
**Implementation tip baseline (evidence):** `87d3e7c`  
**ADR:** [`0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) — **Status remains `Proposed`（本审查不 Accept）**  
**Tip / worktree honesty:** 本审查依据 **working tree 源码结构** 与上述 design/evidence 文档；**不**将 Executor 的 `swift test` 绿条或设备 log 采信为 Arch Pass 证据。若工作树相对 `87d3e7c` 另有未记录 diff，以实际读到的源码为准。

| Field | Value |
|---|---|
| **Verdict** | **Pass with conditions** → **P1-1 Closed 2026-07-31** (presentation generation + epoch gate + abandon test); residual P2/P3 unchanged; **not** Quality re-review claim / Product Gate |
| **P0** | 0 |
| **P1** | 0 (was 1; **P1-1 Closed**) |
| **P2** | 2 |
| **P3** | 3 |

> **判定原则：** 只根据源码结构是否兑现 R5-Remediation design 的 **Rem-1 / Rem-2 授权面**（O1 可观测 + O2 presentation coalesce + R3 context 解耦）与 non-claims；不以测试绿条或 Formal R5 失败倒放为成功；**不**声称 Quality Pass、Product Gate、ADR 0025 Accept、Release default-on、Rem-3 L1、设备 re-pair 方向 Pass。

---

## 1. Scope of this review

### In scope（Product 已授权）

| Knife | 结构检查面 |
|---|---|
| **Rem-1** | content-free `ACCEPT` / `VISIBLE` / `PUBLISH lag` / `BURST` 文法；accept→lag 计算；pending / coalesce 字段；单元测试形态（可证伪性，绿条归 Quality） |
| **Rem-2** | MainActor R2 真 `.latestOnly`（移除 force-`everyResult`）；dual-gate UI latest-only 呈现（pending 阈值 2）；R3 context 绑定 **applied head（last matching pk context）** 而非 every intermediate paint；引擎仍 FIFO 全量执行 |

### Out of scope / 禁止借本 Pass 偷渡

- **Rem-3** provisional L1 composition
- Device re-pair / Formal R5 FAIL 改写为成功
- ADR 0025 Accept / Product Gate / Release dual-gate default-on
- 数值 product SLO 锁定
- 主观 non-stutter 证明
- R4-Wire open residuals（`performOrderedNow` vs delivery 等）**不**因本刀重开为 Fail，除非 Rem-2 放大为新阻断

---

## 2. Sources reviewed

| Artifact | Role |
|---|---|
| `docs/assignments/t9-responsive-pipeline-001-r5-remediation-design.md` | D1–D6、O1/O2/O3、non-claims |
| `docs/evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md` | Executor 交付叙述（**不**采信为 Arch Pass） |
| `docs/evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md` | Formal R5 FAIL 上下文 |
| ADR 0025 §3 ordered input / optional publish coalesce | 引擎 FIFO + UI coalesce 边界 |
| `ResponsiveRimeFeltMetrics.swift` | Rem-1 文法 / tracker / threshold |
| `KeyboardController.swift` | rebuild / dual-gate coalesce / presentation apply / abandon clear |
| `KeyboardController+RimeRecovery.swift` | accept 路径 metrics 接线 |
| `ResponsiveRimePipeline.swift` | latestOnly 引擎侧 publish 策略 |
| `ThreadAffineRimeSession.swift` / `ThreadAffineRimeSpike.swift` | dual-gate delivery 与 epoch 行为 |
| Tests: `ResponsiveRimeFeltMetricsTests`, `ThreadAffineRimeWireTests`, `ResponsiveRimeR2CoordinatorTests` | 结构可证伪形态 |

---

## 3. Boundary held

| Boundary | 结构结论 |
|---|---|
| Formal R5 FAIL **未被**本刀 overturn | **Held** — evidence 与 design non-claims 一致；无设备 A/B 成功 claim |
| Rem-3 provisional L1 **未**实施 | **Held** — 无 dual-gate L1 preedit 路径；`VisibleSource.provisional` 仅 enum 预留；paint 路径固定 `source=.engine` |
| 两 gate 仍 default-off | **Held** — `isResponsiveRimePipelineEnabled` / `isThreadAffineRimeOwnerEnabled` 默认 `false` |
| 引擎 FIFO 不 drop/reorder | **Held** — dual-gate owner 仍对每个 accept 执行 session work；MainActor pipeline 仍 drain 每一项；仅 **UI paint** 可跳过 |
| 无 `@unchecked Sendable` 绕过 | **Held** — Rem-1/2 增量未见；既有注释仅说明禁令 |
| 无 dual live MainActor+owner session | **Held** — dual-gate 仍 `underlyingRimeEngine == nil`；bootstrap-only owner session |
| ADR 0025 Accept | **未发生** |
| Product Gate / Release default-on | **未发生** |

---

## 4. Design freeze structural judgment

### 4.1 D1 — L0 / L1 / L2 分层 — **Rem-2 不声称 L1（Closed for authorized scope）**

| Layer | Rem-1+2 状态 |
|---|---|
| L0 Immediate feedback | 既有：accept 不阻塞 librime（dual-gate / deferred R2） |
| **L1 provisional** | **未实现**（Rem-3 未授权） |
| L2 engine snapshot | 仍为 composition / Path / candidates 权威；atomic apply 路径保留 |

**结论：** Rem-2 仅做 **presentation coalesce**，与 design「今天 dual-gate 有 L0+L2 only；freeze-then-burst = L1 missing + L2 publish storm」一致。  
**残余：** 长 owner stall 下用户仍可能看到 **空白直到首个 L2 paint**（evidence residual #3）。这是 **Rem-3 / Rem-Device** 问题，**不是** Rem-2 Fail。

---

### 4.2 D2 — 引擎 every action vs UI skip paints — **Closed**

| Concern | 源码 |
|---|---|
| Engine apply | Thread-affine owner loop 对每个 envelope `processKey`；MainActor `ResponsiveRimePipeline` 仍 ordered drain |
| UI presentation under lag | dual-gate：`pendingDepth ≥ presentationCoalescePendingThreshold(2)` 或已有 pending buffer → 只保留 latest snapshot，延后一次 `performResponsivePresentationApply(..., coalesced: true)` |
| MainActor R2 publish policy | `rebuildResponsiveRimeCoordinatorIfNeeded` **不再** force `.everyResult`；默认 / 参数化 **`.latestOnly`** |
| Forbidden drop session actions | **未见** 为“追进度”丢弃 mailbox work 的路径 |

**结论：** 与 ADR 0025 §3 对齐：*“UI may coalesce… Coalesce is never a license to skip applying engine state.”*

---

### 4.3 Rem-2 dual-gate coalesce 正确性 — **Mostly closed；见 P1**

实现要点（`applyResponsivePublishedSnapshot` / `scheduleDualGateCoalescedPresentation`）：

```text
if dual-gate && !coalesced:
  if pendingDepth ≥ 2 OR coalesceScheduled OR pendingSnapshot != nil:
    buffer latest snapshot
    schedule MainActor Task (≤64 yield 等待 backlog 收缩)
    return
  else:
    immediate paint (coalesced=false)

Task 结束时:
  take latest buffer
  if pendingDepth still ≥ 2 → re-buffer + reschedule
  else → performResponsivePresentationApply(latest, coalesced=true)
```

| 检查项 | 结果 |
|---|---|
| 阈值命名常量 = 2，非 SLO claim | **Yes**（`ResponsiveRimeFeltMetrics.presentationCoalescePendingThreshold`） |
| 连续 delivery 折叠为 latest buffer | **Yes**（覆盖写入 `dualGatePendingPresentationSnapshot`） |
| 已 scheduled 时不重复并发 Task | **Yes**（`dualGatePresentationCoalesceScheduled` guard） |
| backlog 未降到阈值以下时继续 defer | **Yes**（re-buffer + reschedule） |
| visibility abandon 清 buffer | **Partial** — `clearResponsiveKeyApplyContexts` 清 pending / scheduled；**但** 已取出 snapshot 的 in-flight Task 缺少 epoch gate → **P1** |
| 测试形态 | `testDualGateCoalescesPresentationUnderOwnerBacklog`（paint ≪ keys） |

**残余（by design）：** dual-gate **delivery** 仍可能对每个 engine 结果发 MainActor 通知；coalesce 降的是 **full presentation** 次数，不是 delivery 入队次数。符合 O2「UI paint coalesce」，不是 owner-side publish policy rewrite。

---

### 4.4 Force-everyResult 移除与 R3 Path / auto-anchor — **Closed as intentional residual**

| 路径 | 行为 |
|---|---|
| MainActor R2 | `.latestOnly`：中间键可 engine-apply 而不 UI-publish；paint 时 drain **同 epoch 全部 pk context，保留 last** |
| dual-gate | 无 MainActor live engine → presentation-only（`applyRimeOutput` + Path refresh）；auto-anchor 深度 post-process **本就受限**（R4-Wire residual） |
| gate-off | 不变 |

Design D2：**“Contexts bind to applied revision, not every intermediate UI paint.”**  
Evidence residual #4 与代码注释一致。

**可接受残差：** 多键 burst 下 Path/auto-anchor **只看 last context** — 不作为 Rem-2 Fail；若后续设备/回归显示 Path 语义回退，另开刀或补 parity 测试（Quality / Rem-Device）。

---

### 4.5 Rem-1 content-free felt metrics — **Closed（语义）；见 P2 文法张力**

| Marker | 载荷（静态） | content-free |
|---|---|---|
| `ACCEPT` | action=k, rev, pending, epoch, fixture | **Yes** |
| `VISIBLE` | lagMs, rev, source=engine\|provisional, fixture | **Yes** |
| `PUBLISH`（felt） | lagMs, rev, pendingAfter, coalesced, fixture | **Yes** |
| `BURST` | count, windowMs, fixture | **Yes** |

| 检查项 | 结果 |
|---|---|
| 无 raw keys / pinyin / candidates / host text | **Yes**（纯函数构造 + 测试形态） |
| accept 接线在 dual-gate / R2 insert accept 后 | **Yes**（`recordResponsiveAcceptMetrics`） |
| VISIBLE / PUBLISH lag / BURST 在 presentation apply | **Yes** |
| threshold / window 为命名常量 | **Yes** |
| 与 preflight epoch-rev `PUBLISH` 并存 | **是** — 见 **P2-1** |

**计量诚实残差（P2-2）：** coalesce 只 paint 最新 rev 时，`VISIBLE lagMs` / `PUBLISH lagMs` 相对 **该 painted rev 的 accept**（或 nearest ≤ rev），**不能**单独代表「从首次未呈现键起的空白时长」。Formal R5 式 freeze 评分仍需结合 `ACCEPT.pending`、idle 间隙、`BURST`、以及（若补）oldest-unpainted lag。Evidence non-claims 已排除主观 non-stutter；本审查要求 **不要** 用 painted-rev lagMs 单独宣称「freeze 已消失」。

---

### 4.6 Isolation — **Closed for this knife**

| 检查项 | 结果 |
|---|---|
| 新 `@unchecked Sendable` | **No** |
| dual-gate 安装 MainActor live librime session | **No** |
| tracker / buffer 放在 MainActor 控制器状态 | **Yes**（`@MainActor` tracker；controller 私有 buffer） |

---

## 5. Findings

### P0

*无。*

### P1

| ID | Finding | 影响 | 建议 remediation |
|---|---|---|---|
| **P1-1** | dual-gate coalesce **defer Task** 在 `performResponsivePresentationApply` 前 **不校验** snapshot `sessionEpoch` / 当前 presentation authority。`abandonCompositionForVisibilityChange` → `bumpSessionEpoch` + `clearResponsiveKeyApplyContexts` 可清 buffer，但 **已 take 出 latest 的 Task** 仍可能在 abandon 之后把 **旧 epoch L2** 写回 composition / candidates。 | 可见性切换 / hide 键盘后可能 **闪回废弃组字**；Rem-2 拉长 yield 窗口，放大既有 dual-gate delivery→apply 无 gate 的风险。既有 `ThreadAffineRimeSpikeApplyGate` 有正确模型但 **未** 接入 controller presentation。 | 在 `performResponsivePresentationApply`（或 dual-gate flush）入口：丢弃 `snapshot.sessionEpoch != live epoch` 或 `revision ≤ lastAppliedPresentationRevision`；abandon/reset 时递增 presentation generation 使 in-flight Task fail closed。补单元测试：backlog + abandon + flush 不得恢复旧 composition。 |

**P1-1 Closed (2026-07-31 Executor remediation):**

- `responsivePresentationGeneration` 在 `clearResponsiveKeyApplyContexts`（abandon/rebuild 路径）递增。
- Coalesce Task 捕获 generation；mismatch 时 fail closed。
- `isLivePresentationSnapshot`：generation + live `sessionEpoch`（MainActor diagnostics / dual-gate owner diagnostics）+ same-epoch 不降 revision。
- `ThreadAffineRimeOwnerDiagnostics.sessionEpoch` 暴露 live epoch。
- 测试：`testDualGateAbandonDropsDeferredCoalescedPresentation`。
- Arch 条件 **P1-1 关闭**；**不**声称 Quality re-review / Rem-Device / Product Gate。

### P2

| ID | Finding | 影响 | 建议 |
|---|---|---|---|
| **P2-1** | 双份 `marker=PUBLISH`：preflight `PUBLISH fixture epoch rev` 与 felt `PUBLISH lagMs … coalesced` 同名不同形；dual-gate paint 会打 **两行**。 | 设备 log 计数 / Formal 式 publish 风暴统计易 **双计或解析歧义**。 | 重命名 felt 行为 `PUBLISH_LAG`（或保留 design D3 名并废弃/改名 preflight 身份行）；文档写清 parser 规则。 |
| **P2-2** | coalesce 下 `VISIBLE`/`PUBLISH` lag 锚定 **painted revision accept**，非 oldest pending accept→first visible。 | 单独看 lagMs 可能 **低估** 空白 freeze；与 Formal R5 教训「不要被 KEY END 骗」同类。 | Rem-Device 评分：用 `ACCEPT.pending` + 首 VISIBLE 相对 **burst 起点** / 可选 `maxPendingLagMs`；禁止 “lagMs 小 ⇒ 不卡” 单指标 claim。 |

### P3

| ID | Finding | 备注 |
|---|---|---|
| **P3-1** | dual-gate coordinator `fixtureID` 仍 `T9RESP-R4W`，felt/preflight 标记 `T9RESP-R5P` | 不破 content-free；对照时混淆（preflight 既有 P3 延续） |
| **P3-2** | `ResponsiveRimeFeltMetricsTracker.shared` 进程级单例 | 生产单键盘可接受；测试交叉污染风险，应用 per-controller 或 reset 纪律 |
| **P3-3** | dual-gate delivery 仍 every engine result 通知 MainActor | O2 允许；若 MainActor 入队仍尖刺，属后续 owner-side publish coalesce / 背压，非本刀强制关闭 |

### Explicit residuals（by design / prior）

1. **Rem-3 L1** 未做 → 长 stall 空白可能仍在（coalesce 修 storm，不修 “无 progressive authority”）。
2. **Formal R5 FAIL** 仍有效；无新 Human A/B。
3. **Path/auto-anchor last-context-only** under latestOnly / coalesce（intentional）。
4. dual-gate **无** MainActor live engine 的深度 Path/auto-anchor post-process（R4-Wire residual）。
5. ADR 0025 **Proposed**；default-off；无 Product Gate。
6. R4-Wire **P1** `performOrderedNow` vs delivery 等 **仍 open**（不重开为本 Fail）。

---

## 6. Checklist disposition

| Checklist item | Disposition |
|---|---|
| D1 L0/L1/L2：Rem-2 不声称 L1 | **Pass** — 仅 presentation coalesce |
| D2 引擎 FIFO + UI 可 skip paints | **Pass** |
| Dual-gate coalesce 正确性（threshold 2 / race / abandon） | **Pass with P1-1** on abandon/in-flight |
| Force-everyResult 移除对 R3 Path/auto-anchor | **Acceptable residual**（last context） |
| Content-free log honesty | **Pass** 语义；**P2** 双 PUBLISH + lag 解释边界 |
| Boundary vs Formal R5 FAIL | **Held** — 未 overturn |
| Isolation | **Pass** |
| P0/P1/P2/P3 | 0 / 1 / 2 / 3 |

---

## 7. Non-claims（强制）

本审查 **不** 声称：

1. **Quality Pass**（测试执行与诚实证据归 Quality）
2. **Product Gate** / Human 设备 re-pair 方向 Pass
3. **ADR 0025 Accept**（保持 **Proposed**）
4. **Release dual-gate default-on**
5. Formal R5 FAIL 被推翻或“已修复到可日用”
6. Rem-3 provisional L1 已交付
7. 数值 product SLO 已锁定
8. 主观 non-stutter / 空白 freeze 已消失
9. dual-gate delivery 风暴或 owner librime 变快

---

## 8. Verdict rationale

| Dimension | Judgment |
|---|---|
| Rem-1 O1 可观测结构 | **兑现** — 文法、接线、阈值常量、测试形态齐备 |
| Rem-2 O2 presentation coalesce | **大体兑现** — latestOnly + dual-gate buffer；引擎 FIFO 保持 |
| R3 context → applied head | **兑现** — last matching pk context；与 everyResult 解耦 |
| 授权边界 | **守住** — 无 L1 / 无 default-on / 无 ADR Accept / 无 FAIL 改写 |
| 阻断性缺陷 | **无 P0**；**P1-1** 为条件关闭项（可见性 abandon 与 deferred paint 竞态） |

**Verdict: Pass with conditions**

### Conditions（关闭建议）

1. **必须（P1-1）：** presentation apply fail-closed on epoch/revision（或 generation）后再宣称 dual-gate 生命周期安全；建议在 Rem-Device 前由小刀关闭。  
2. **应当（P2-1 / P2-2）：** 澄清 PUBLISH 双文法；Rem-Device 评分协议不用 painted-rev lagMs 单独否认 freeze。  
3. **可选（P3）：** fixture 统一、tracker 实例化、delivery 侧后续 coalesce。

**下一步（建议，非本文件授权）：**

1. Quality 独立审查 Rem-1/2 测试诚实性与 evidence。  
2. Executor 或后续小刀关闭 **P1-1**。  
3. Product 再授权 **Rem-Device**（及必要时 **Rem-3**）前，Arch/Quality 条件关闭；**不得**将本 Pass with conditions 读成 dual-gate 可 default-on 或 Formal R5 翻案。

---

## 9. Required remediations before unconditional Arch Pass

| Priority | Item |
|---|---|
| **Block unconditional Pass** | **P1-1** presentation epoch/revision fail-closed for deferred dual-gate paint |
| Does **not** block this conditional Pass | P2/P3、Rem-3、device re-pair、ADR Accept |

---

## 10. Handoff

**To:** 🧪 Quality（并行独立审查） / 🧭 Product Lead（条件关闭后的下一步授权）  
**Not to:** Release train / ADR Accept owner（无 Accept 触发）

**One-line summary for Program:**  
R5-Rem-1+2 **结构上兑现 O1 可观测 + O2 UI coalesce**，边界守住；**Pass with conditions**（**0 P0 / 1 P1** abandon 竞态）；Formal R5 FAIL **仍有效**，Rem-3 / Device 另授。
