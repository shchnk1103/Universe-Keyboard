# 独立 Architecture 复审：P2-PERF-03 复现与反向顺序真机证据

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立、只读） |
| 复审日期 | 2026-08-03（Asia/Shanghai） |
| 复审对象 | [`P2-PERF-03 Assignment`](t9-responsive-pipeline-001-p2-perf-03-replicated-ab-proposal.md)、[`P2-PERF-03 evidence`](../evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-2026-08-03.md)、[`summary JSON`](../evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-summary-2026-08-03.json)、[`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)、[`P2-PERF-02 evidence contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)、[`T9ResponsiveEvidenceValidator`](../../Packages/KeyboardCore/Sources/KeyboardCore/T9ResponsiveEvidenceValidator.swift) |
| Matrix | `P2P03-REPLICATED-AB-20260803-001`（AB 与 BA 两个顺序 pair） |
| Architecture verdict | **Pass with conditions（bounded replicated evidence-only observation）** |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 2** |
| 治理边界 | ADR 0025 继续 `Proposed`；不宣布 Product Gate、Release、默认开启或生产接线通过 |

## 1. 复审范围与总判断

本复审只检查四臂 evidence-only 运行是否足以支持受限的方向性判断：

1. `A→B` 与 `B→A` 是否都显示 B 的即时输入路径更顺畅，因而降低固定顺序的解释风险；
2. 每个有效 arm 是否有独立 token、连续 39-action、路径、session 与 geometry 证据；
3. B 的 `ACCEPT/PUBLISH` 是否完整，以及 `PAINT` 缺失是否被正确留在 presentation Partial；
4. invalid A1、Full Access、restore 与 default gate 是否被诚实分类。

结论是：两种顺序的 B 方向一致，且同步 A 的长 RIME 尖峰重复出现；这比单一 A→B pair 更有
资格进入“是否值得另行授权内部 production-shaped canary”的讨论。但它仍不是因果证明、
用户 SLO、真实 Release、生产 off-main 接线或 Product Gate。

## 2. Evidence basis

| 层次 | 观察 | 可支持的边界 |
|---|---|---|
| 运行身份 | 四个有效 run 均有新 token；同一 iPhone 13 Pro、iOS 27、source HEAD/toolchain、canonical fixture；无效 A1 单独记录 | 当前 token 子集可归属于各自 arm；不同历史 token 出现在 B2/A2 原始附件中，但解析时只取当前 token，不能把原始附件当作单 token export |
| A sync | A1 `total 14.4/242.3 ms`、RIME `241.0 ms`；A2 `15.8/246.5 ms`、RIME `245.1 ms`；UI max 7.5/8.4 ms | 同步 RIME/processKey 长尾在反向顺序仍复现；不创建性能预算 |
| B thread-affine | B1/B2 `T9SEG total max=0.8/0.7 ms`；均有 PATH、READY、39 ACCEPT、39 epoch-bound PUBLISH；VISIBLE 42（35 engine+7 provisional）、PAINT 35 | 即时 accept/UI 路径与异步 engine 结果分离；owner completion 39/39 在两臂均有证据 |
| 顺序 | AB：A1 2.5/4 → B1 1.0/4；BA：B2 1.0/4 → A2 3.0/4；B−A = −1.5、−2.0 | B 的较低 stall score 在两种顺序方向一致；仍只有每种顺序一对样本 |
| Geometry | 每臂 prepared/execution tokenized digest 相同；相同 tokenless shape digest `114c78…` 为事后派生 | 支持形状方向性一致；不等于运行前冻结的 normalized geometry contract 已完成 |
| Restore/gate | 普通 Release、无 preflight 条件，install sequence 3800；Human 确认键盘出现并保持；无生产改动 | 诊断包已恢复到普通 gate-off；一键 smoke 不等于完整生命周期或 Release 认证 |

## 3. P0–P3 findings

### P0：0

没有发现隐私泄漏、数据破坏、错误设备、错误 token 导致的 P0 问题。原始输入、候选、宿主
文本、截图和 UI hierarchy 未进入仓库；invalid A1 没有混入有效统计。

### P1：0

没有发现会阻断本次 bounded evidence-only 归档的生产安全或并发架构缺陷。B 两臂的
`ACCEPT 1…39 → PUBLISH 1…39`、session valid/stable 与 PATH/READY 证据足以形成受限
owner-completion 观察；这不是生产接线验收。

### P2：4

#### ARCH-P2-PERF-03-P2-01：顺序效应得到方向复现，但仍不是因果隔离

A→B 中 B 比 A 低 `1.5` 分，B→A 中 B 比 A 低 `2.0` 分；A 两臂都出现约 `241–245 ms`
RIME 尖峰，B 两臂即时 `T9SEG` 均低于 `1 ms`。这降低了“只因 A→B 顺序造成改善”的解释
风险，但每种顺序仍只有一对运行，同一 Human、固定 fixture、没有随机化/反序重复或统计
区间；学习、疲劳和主观评分仍可能影响分差。

**处置：** 只使用“两个顺序下方向一致的 bounded observation”措辞；不得宣称统计显著、
普遍用户收益或唯一因果。若要做更强结论，应另行授权重复/交叉设计，而不是复用本次分数。

#### ARCH-P2-PERF-03-P2-02：Full Access 与 host opaque provenance 未观察

四臂明确将 Full Access 保持为 `unavailable/unknown`，host 只记为同一提醒事项 disposable
list protocol，没有可复核的 opaque list ID。故可确认“声明使用同一 host envelope”，不能
确认权限/宿主身份在四臂间完全相同，也不能把 AB/BA 结果升级为完整 A/B contract。

**处置：** 保留 `unavailable`，不得从历史运行补值；下一次 pair 在首臂前冻结 Full Access
observed 状态与 disposable host ID，或明确将缺失列为 Pair Partial。

#### ARCH-P2-PERF-03-P2-03：normalized geometry digest 仍为 post-hoc derived

四臂 tokenized digest 在各自 prepared/execution 内匹配；去除 token 后得到相同的
`114c78…` shape digest。但该 digest 是事后派生值，不是运行前写入的 normalized tokenless
geometry marker，Assignment 要求的“运行前冻结”仍未闭合。含 token 的 per-arm digest 不应
跨臂直接比较，也不能把事后相同 hash 当作运行时 geometry identity。

**处置：** 本次几何结论保持 bounded；下一次 canary/新 pair 必须在输入前生成并绑定
normalized tokenless digest，同时保留每臂 tokenized digest 与运行时 prepared/execution 校验。

#### ARCH-P2-PERF-03-P2-04：B 的 owner completion 完整，但 presentation coalescing 未闭合

B1/B2 均有 `ACCEPT=39`、`PUBLISH=39`、epoch 1 且有序；这满足 owner completion 证据。可是
两臂 `PAINT=35`，四个 revision 没有 PAINT；已有的 35 条都记录 `coalesced=0`，没有逐 revision
的缺失原因。ADR 0025 允许 PAINT latest-only，但“允许少画”不等于已证明具体四次是合法
coalescing，而不是导出缺行。

**处置：** 将 B arm 的 core/path/owner 结果记为 validator `complete`，将 presentation
layer 继续记为 `Partial`；不得把 PAINT 缺失解释成输入丢失，也不得把它写成 UI contract
Complete。生产形状 canary 前应冻结 missing-PAINT reason/coalesced receipt 语义。

### P3：2

#### ARCH-P2-PERF-03-P3-01：有效 run 与 invalid A1 的聚合身份需更清晰

有效 arm 使用 `P2P03-AB-*` 与 `P2P03-BA-*` run ID；summary 顶层 ID 为
`P2P03-REPLICATED-AB-20260803-001`，但没有显式的 `pairs` 映射字段。每个 arm 的 `order`
字段足以人工推断 AB/BA，但长期复核容易把 aggregate ID 误读成只含 AB pair。
第一次 A1 的未准备 token 已正确标记为 `invalid-run-token` 并排除，不能改写成有效 A1。

**处置：** 归档时增加 content-free 的 `matrixID → {AB, BA} → arm runID/token` 映射；保留
invalid attempt 作为 excluded evidence，不删除或并入统计。

#### ARCH-P2-PERF-03-P3-02：restore smoke 与 raw attachment 的范围仍有限

普通包恢复、序号 3800 和一键键盘冒烟已记录，但 smoke 没有输入长句，也没有证明进程重载、
schema/readiness、jetsam/memory 或完整生命周期。原始附件留在受控 attachment 目录，仓库只
保存 current-token marker 子集摘要/hash；这符合隐私边界，但不是永久 raw archive。

**处置：** 保留 restore 为“普通包替换 + bounded smoke”；完整生命周期/长期性能需新授权，
不得用 restore smoke 或 marker-only hash 补齐。

## 4. Token、invalid attempt 与隐私边界

- 每个有效 arm 都使用新 canonical `S6A-` token，且 validator 对当前 token 子集报告
  `complete`；B2/A2 原始导出含历史 token 是不清空日志的预期，不能把它们当作当前 arm 事件。
- 首次 A1 没有准备 token，附件只有 `run=invalid`；Assignment、evidence、summary 均明确
  标记 `invalid-run-token` 并排除后续有效 A1 的计数、分数和时延。这是正确的 fail-closed
  处理，不是一次失败运行可以被重试覆盖的证明。
- `SLOW RIME ... candidates=12` 的旧 deny-list 误报没有被改写成隐私事故；仓库只保留
  content-free 当前 token 子集并注明原始附件不声称完整 allow-list 通过。

## 5. ADR、default gate、restore 与生产边界

| 边界 | 复审结论 |
|---|---|
| ADR 0004 | A sync 仍对应现行 MainActor/主线程串行路径；没有改动 |
| ADR 0025 | B 是显式 `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` 内部诊断；`Proposed` 仍未接受 |
| 默认 gate | 没有任何 auto-anchor `*_ENABLED` 条件；项目 defaults 仍 false |
| Release | 普通 Release restore 与 Release diagnostic build 均不等于 shipping Release/RC |
| Restore | sequence 3800、无 preflight ordinary package、一键 smoke 已通过；不扩大为 lifecycle/SLO |
| Product Gate | 未授权、未执行、未声明 |

## 6. 已证实与未证实

### 已证实（bounded）

1. 四个有效 arm 均为合法 token-bound 39-action 人工运行，输入完整性、session 稳定性和
   prepared/execution geometry（各臂内部）成立；invalid A1 没有混入统计。
2. A→B 与 B→A 两种顺序中，B 的 Human stall score 都低于对应 A；A 两臂同步 RIME 长尾
   约 241–245 ms，B 两臂即时 T9SEG 热路径均低于 1 ms。
3. B1/B2 各自有 PATH/READY、39 ACCEPT、39 ordered epoch-bound PUBLISH；这支持“即时
   accept 不等待慢 RIME owner completion”的方向性证据。
4. 每臂 tokenized geometry digest 在 prepared/execution 内一致；相同 tokenless shape
   只作为 post-hoc derived metadata 保存。
5. 诊断包已恢复为无 preflight 条件的普通 Release，install sequence 3800，Human 一键
   keyboard-switch smoke 通过。

### 未证实

1. B 的 4 个缺失 PAINT 是否全部是合法 coalescing，以及 presentation layer 是否满足完整
   UI contract。
2. Full Access、host opaque identity、运行前 normalized geometry freeze 和其它不可观察
   环境字段的真实同等性。
3. RIME/processKey 本身是否更快、所有设备/输入节奏是否主观不卡顿、是否满足任何 SLO。
4. 真实 librime 长期队列、内存/jetsam、iOS 26.0 Release RC、App Store、生产接线或 ADR
   0025/Product Gate。

## 7. 是否值得另行授权 production-shaped canary（仅建议）

**建议：值得提出一个独立、明确 gate、默认关闭的 production-shaped canary 设计授权；当前
不建议直接授权生产默认接线或 Release 用户实验。** 理由是：

- 两种顺序下方向一致，且同步 A 的 RIME 长尾和 B 的亚毫秒即时路径重复出现；
- B1/B2 的 PATH/READY、39/39 ACCEPT/PUBLISH、session 稳定和 token 处理已达到可讨论下一步
  的 evidence threshold；
- invalid A1、restore 与 privacy 边界没有被改写成成功运行或默认 gate。

建议该 canary 另建 Product Assignment，至少先满足：

1. 明确 Full Access/host provenance 的 observed 或接受 Partial 的风险；
2. 在输入前冻结 normalized tokenless geometry digest；
3. 为缺失 PAINT revision 提供 content-free reason/coalesced receipt，或明确 canary 的 UI
   presentation acceptance；
4. 保持 `ADR 0004` 可回退路径、单一 RIME owner、无 `@unchecked Sendable`、默认 gate off、
   显式 kill-switch，并由独立 Architecture/Quality 复审后再决定是否进入更高阶段。

这里的“值得授权”只是风险/价值建议，不是 Architecture acceptance、Product approval 或
生产 wiring authorization。

## 8. 停止声明

独立 Architecture 复审已完成。本文件未修改生产逻辑、validator、设备、原始附件、默认 gate、
Assignment 或 ADR；未接受 ADR 0025，未宣布 Product Gate、Release 或生产 canary 已获批准。
后续由 Product Lead 决定是否建立新的 canary Assignment，再交独立 Quality/Architecture
审查；本角色到此停止。
