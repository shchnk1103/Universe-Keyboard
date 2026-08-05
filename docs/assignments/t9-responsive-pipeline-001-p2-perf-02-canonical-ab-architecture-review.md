# Architecture Review：P2-PERF-02 canonical A/B 真机证据

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立、只读） |
| 日期 | 2026-08-03（Asia/Shanghai） |
| 复审对象 | [`Canonical A/B Assignment`](t9-responsive-pipeline-001-p2-perf-02-canonical-ab-20260803.md)、[`Canonical A/B evidence`](../evidence/t9-responsive-pipeline-p2-perf-02-canonical-ab-2026-08-03.md)、[`summary JSON`](../evidence/t9-responsive-pipeline-p2-perf-02-canonical-ab-summary-2026-08-03.json) |
| Pair ID | `P2P02-CANONICAL-AB-20260803-001` |
| Architecture verdict | **Pass with conditions（bounded canonical A/B runtime evidence）** |
| A/B 状态 | **方向性观察成立；Assignment/设备收尾仍未 Complete** |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 2** |
| 治理边界 | ADR 0025 仍为 `Proposed`；不宣布 Product Gate、Release 或默认开启 |

## 1. 复审范围与结论口径

本次复审只读检查两臂是否在声明的同源、同设备、同一 39-action canonical fixture 协议下
形成可解释的 bounded 方向性证据，重点核对：

- A `sync` 的 `total max=181.8 ms` 与 RIME `max=180.4 ms`；
- B `ACCEPT 39/39`、epoch-bound `PUBLISH 39/39`、`VISIBLE/PAINT` 的 latest-only 语义；
- 含 run token 的几何 digest 和摘要中的 tokenless shape match；
- Human A `2/4`、B `0.5/4` 的主观结论边界；
- Full Access、restore、源码 dirty-state 等尚未闭合的证据层。

本复审不把一次 A/B 方向观察升级为因果证明、用户 SLO、真实 Release 或生产 off-main 迁移。

## 2. 第一性原理证据链

| 层次 | A sync arm | B thread-affine diagnostic arm | Architecture 判断 |
|---|---|---|---|
| 输入 | 39 个人工 `T9SEG`，action/event `1…39`，均 `committed=false` | 同样 39 个连续人工 `T9SEG`，均 `committed=false` | 两臂没有日志级漏键/重排/意外 commit；Human 两臂均报告无漏键、重键、候选消失、键盘退出 |
| 路径 | `T9DEVICE gate=off`（auto-anchor measurement）+ `T9RESP path=sync dualGate=0/0` | `T9DEVICE gate=off` + `T9RESP path=thread-affine dualGate=1/1` + `READY owner-thread` | 变量边界清楚；B 是显式内部 spike，不是默认路径 |
| 主路径时延 | `total max=181.8 ms`；RIME max `180.4 ms`；UI max `8.1 ms` | `T9SEG total max=0.7 ms`；engine VISIBLE lag max `160.0 ms`；PAINT lag max `160.0 ms` | 支持“B 将慢 engine 结果移出即时 accept/UI 样本”的方向；不表示 RIME 本身变快 |
| owner 完成 | 不要求 ACCEPT/PUBLISH | `ACCEPT 39/39`、`PUBLISH 39/39`、epoch 1、有序 | B 的 owner-completion 覆盖在本次摘要中闭合；仍不等于真实生产接线/所有生命周期已闭合 |
| UI 呈现 | 不适用 responsive markers | `VISIBLE=42`（engine 37 + provisional 5），`PAINT=37`；PAINT 缺 rev 16、33 | 符合 latest-only 允许 coalesce 的形状；缺失 PAINT 不能反向削弱 39/39 PUBLISH，但缺少明确 coalesced receipt |
| 几何 | prepared/execution digest `0fe727…`，同臂匹配 | prepared/execution digest `826fc9…`，同臂匹配；摘要称 tokenless shape match | digest 含各自 token，跨臂不应相等；tokenless match 是 bounded 摘要，不能当作可独立重算的跨臂 manifest |
| 人工体验 | `stallScore=2/4`，间歇性卡顿 | `stallScore=0.5/4`，仍有极小可感暂停 | 单设备、单 pair 的方向性改善；不能转换成 SLO、普遍用户结论或因果证明 |

Canonical fixture ID/digest 与 P2-PERF-02 contract 一致；raw sequence 保持不进入日志和仓库，
因此可复核的是协议身份与 39-action 运行事实，而不是从 content-free 日志重建原始文本。

## 3. P0–P3 findings

### P0：0

没有发现用户数据破坏、隐私泄漏、错误设备、错误 token 或不可恢复状态的 P0 问题。两臂
content-free allow-list/summary 均报告通过。

### P1：0

没有发现会阻断本次 bounded A/B runtime 归档的架构安全缺陷。B 的 `PUBLISH 39/39`、
session 有效稳定以及 A/B 各自 geometry prepared/execution 匹配，足以支持受限方向性审查。

### P2：4

#### ARCH-P2-CANONICAL-AB-P2-01：A/B 环境可比性仍是 bounded，不是完整闭合

两臂共享 pre-run source HEAD、设备/OS、toolchain、host 协议和 canonical fixture 声明，
但 Full Access 仍为 `unavailable`，host opaque list ID 没有落入 pair summary，worktree 只有
dirty count/tracked diff/untracked-name fingerprint，没有 untracked-content fingerprint。因而
不能排除权限或未绑定 dirty 内容对运行环境的影响，也不能把 `A=2/4 → B=0.5/4` 写成完全
控制变量后的因果效应。

**处置：** 保持“same declared envelope + directionally comparable”措辞；新的 A/B pair 在
生成 run header 前捕获 Full Access、opaque host ID 和完整 source/worktree manifest。

#### ARCH-P2-CANONICAL-AB-P2-02：几何 token 绑定正确，但 tokenless shape 仍不可独立重算

每臂 geometry digest 包含本臂 run token，因此 A/B digest 不同是设计结果，不是几何冲突；
摘要中的 `crossArmTokenlessShapeMatch=true` 支持屏幕/slot shape 相同。然而仓库没有保存
规范化 tokenless geometry bytes、digest 或 Pair Manifest，reviewer 不能只用长期仓库材料
重算该布尔结论。人工输入也不应被误写成坐标自动化几何证明。

**处置：** 保留 per-arm tokenized digest，并在下一次 pair 归档一个不含 token/用户内容的
  normalized-shape digest；本次只能将几何 parity 记为 bounded observation。

#### ARCH-P2-CANONICAL-AB-P2-03：PUBLISH 完整不等于 VISIBLE/PAINT 每 revision 完整

B 已有 39 个 ordered epoch-bound `PUBLISH`，这是 owner completion 合同的正面证据。`VISIBLE`
只出现 37 个 engine snapshot 加 5 个 provisional，`PAINT` 为 37 且 rev 16、33 没有单独
paint；该形状可由 ADR 0025 Proposed 的 latest-only presentation coalescing 解释，但 summary
的 `paintCoalescedFieldObserved=0` 没有记录一个明确的 coalescing receipt/reason。

**处置：** 不把缺少两个 PAINT 写成丢输入或缺少 PUBLISH；同时不把“允许 coalesce”写成
“已证明这两次确实被合并”。后续若要消费 UI latency，需保留明确的 coalesced/paint outcome；
owner-completion 仍以 39/39 PUBLISH 为准。

#### ARCH-P2-CANONICAL-AB-P2-04：A/B 运行完成但 Assignment exit 尚未完成

指定材料中 Assignment 状态仍是 `In progress — ... ordinary-package restore pending`，
没有独立 ordinary restore record 或 post-restore smoke artifact。A/B runtime 可以归档为
已完成观察，但设备恢复、cleanup 与 restore identity 尚未闭合，不能宣布 P2-PERF-02 Complete，
也不能把诊断包状态当成普通 Release 状态。

**处置：** 在独立 restore record、普通包 App/Extension identity 和最小 post-restore smoke
到位前，保持 Assignment 未完成；若恢复记录后来补入，应以新材料重新核对，不追写本审查。

### P3：2

#### ARCH-P2-CANONICAL-AB-P3-01：单 pair 的 Human score 受顺序/主观性影响

A=2/4、B=0.5/4 与 A sync max 181.8 ms、B T9SEG max 0.7 ms 的方向一致，但这是一次固定
A→B 顺序的人工 pair；没有重复样本、盲测、反序或统计区间。该结果适合作为下一步授权的
方向信号，不是用户普遍体验、因果证据或性能预算。

#### ARCH-P2-CANONICAL-AB-P3-02：长期复核依赖受控临时 raw attachment

仓库保存的是 content-free summary、过滤行数与 SHA；原始 499-line export 和提取文件仍在
`/private/tmp`，符合不把用户内容放入仓库的隐私边界，但仓库本身不能保证未来仍可重开这些
临时字节。当前 Architecture 结论依赖 summary 对 A/B 事实的诚实分层，不把临时附件的存在
误写成永久 immutable archive。

## 4. 已证实与未证实

### 已证实（bounded）

1. A/B 使用独立合法 token、相同声明的 canonical fixture（39 actions）和同一 iPhone 13 Pro
   / iOS 27 source/toolchain envelope；两臂均有连续 39-action 人工输入与无完整性缺陷报告。
2. A 真实观察到同步 RIME 长尾（RIME max 180.4 ms、total max 181.8 ms）；B 真实观察到
   `ACCEPT 39/39`、`PUBLISH 39/39`，且 T9SEG 即时路径最大 0.7 ms，同时 engine VISIBLE/PAINT
   仍有最高 160 ms 的异步滞后。
3. B 的 provisional/engine `VISIBLE` 和 latest-only `PAINT` 记录与“即时反馈和异步结果分离”
   的 proposed diagnostic contract 兼容；PUBLISH coverage 没有因 UI coalescing 减少。
4. 含 token 的 per-arm geometry digest 在各自 prepared/execution 内匹配；跨臂 tokenless
   shape match 目前只能采纳为摘要级 bounded observation。
5. Human 主观评分从 A=2/4 到 B=0.5/4，支持“本次 pair 的主观响应方向改善”，不超过该范围。

### 未证实

1. RIME/processKey 计算本身变快，或 B 在所有输入节奏/设备/OS 上满足“不卡顿” SLO。
2. Full Access、opaque host identity、dirty untracked content 对两臂完全一致且不影响结果。
3. PAINT 缺失 rev 16、33 的具体 coalescing 原因；只知道它不影响 39/39 owner PUBLISH。
4. 普通 Release restore、长生命周期、jetsam/memory、iOS 26.0 Release RC、App Store、ADR
   0025 Accepted 或 Product Gate。

## 5. ADR、默认 gate 与 Release 边界

- **ADR 0004：** A sync 路径仍是当前生产规则；本次没有改动。
- **ADR 0025：** B 只使用显式内部 `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`；`ADR 0025` 仍
  `Proposed`，`PUBLISH 39/39` 不是接受 ADR 的依据。
- **默认 gate：** 两臂都是诊断包；A/B 编译条件没有写入项目默认 flag，不能推导 Release
  default-on。
- **Release：** `Release` configuration 仅说明优化配置下的内部诊断构建，不是 shipping
  Release、App Store 或 Product Gate 证据。
- **A/B 与恢复：** A/B 方向性观察可交给 Quality；普通恢复 pending 必须单独闭合，不能由
  B 的 human score 或 PUBLISH 记录代替。

## 6. Verdict 与下一步授权建议

**Verdict：Pass with conditions（bounded canonical A/B runtime evidence）。**

本次材料足以支持以下受限表述：在同一声明的 iPhone 13 Pro canonical fixture pair 中，
同步 A 的即时路径出现约 181.8 ms 长尾；显式 B 的即时 `T9SEG` 路径保持亚毫秒级，所有
39 个 accepted revision 都有 ordered epoch-bound owner `PUBLISH`，而 engine/UI 结果可稍后
以 VISIBLE/PAINT 方式出现；Human 主观评分方向从 2/4 改善到 0.5/4。

这不是“RIME 变快”或“产品已不卡”的结论，而是“把长 RIME 调用移出即时 accept/UI 路径的
方向性证据”。在 Product Lead 另行决定前，保持默认 gate off、ADR 0025 Proposed、
Assignment/restore 未完成；后续任何生产接线或 Product Gate 都需要新的授权和独立复审。

## 7. 停止声明

独立 Architecture 复审已完成。本角色未修改生产逻辑、flag、设备、原始附件、Assignment
或 ADR；未接受 ADR 0025，未宣布 Product Gate/Release/默认开启。若普通 restore 记录后续补入，
应作为新证据触发针对 restore 的独立复核；本角色到此停止。
