# 独立 Architecture 复审：T9-RESPONSIVE-PIPELINE-001 / P2-PERF-01

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立、只读） |
| 复审日期 | 2026-08-01（Asia/Shanghai） |
| 复审对象 | `T9-RESPONSIVE-PIPELINE-001 / P2-PERF-01` |
| 主要材料 | [`Assignment`](t9-responsive-pipeline-001-p2-perf-01.md)、[`canonical partial evidence`](../evidence/t9-responsive-pipeline-p2-perf-01-canonical-partial-2026-08-01.md)、[`partial 前置证据`](../evidence/t9-responsive-pipeline-p2-perf-01-partial-2026-08-01.md) |
| 当前证据状态 | 真机 Debug 人工诊断；规范序列报告但导出仅保留 action/event 6–39 的 34 条 `T9SEG` |
| Architecture 结论 | **Pass with conditions（仅限 bounded engine-attribution observation）**；P2-PERF-01 仍为 `In Progress`，不是完整退出或产品结论 |
| P0 / P1 / P2 / P3 | **0 / 0 / 3 / 1** |
| 治理结论 | ADR 0025 仍 `Proposed`；不形成 Product Gate、R6、Release 性能通过或默认开启结论 |

## 1. 复审范围与证据边界

本复审只读检查：

1. `T9SEG`、`SLOW RIME` 以及 `processKey api` / `collect` / UI 字段是否足以支持
   “本轮真机卡顿由 RIME API 主导”的有限归因；
2. action 1–5 缺失、一次 Debug A1/one-anchor 事件、无 `T9RESP marker=PATH/READY`
   的记录是否诚实；
3. ordinary gate-off Release replacement restore、default gate、ADR、Product Gate
   与发布边界是否被正确保留；
4. 完整 Assignment exit criteria 与后续未验证项是否被如实区分。

没有修改生产代码、测试、RIME/Lua 或 gate；没有把真机 Debug 诊断转换为 Release、
ADR 0025 或 Product Gate 证据。当前工作树有其他任务的未提交改动，canonical 证据
中的 executable hash 与 source HEAD 可作为该次运行的记录，但不能自动证明当前脏工作树
与已安装二进制一一对应。

## 2. processKey 主导卡顿的归因审查

### 2.1 字段支持的结论

**结论：字段充分支持“本次保留样本中的同步热路径由 RIME bridge/processKey API
主导，而不是 Path/Candidate UI 主导”这一 bounded attribution。** 支持链如下：

| 观察 | 证据 | Architecture 解释 |
|---|---|---|
| 多个独立 slow event | 4 条 retained rows：total 175.3、165.3、205.6、189.6 ms | 不是单个偶发 UI 刷新即可解释的孤立样本 |
| `rime` 与 `processKey api` 同步增长 | rime 173.0/163.0/203.2/187.3 ms；api 172.7/162.7/203.0/187.1 ms | API span 几乎覆盖 `rime` bucket |
| collect 很小 | 0.2、0.1、0.1、0.1 ms | 不是 output collection/context copy 主导 |
| Path/Candidate UI 很小 | UI 约 1.0–1.1 ms；pathUI/candUI 的 p95 仅 5.9/0.8 ms | 当前保留 slow rows 不支持 UI reload 是首要杠杆 |
| 会话/完整性没有同步坏掉 | 34 条 retained rows 均 `committed=false`、session `4455878104` 有效且稳定、12 candidates | 归因样本未伴随可见 commit/session reset；但只覆盖保留行 |

该链条与仓库的测量定义一致：`T9SEG.rime` 记录 bridge `processKey`/collect，
`RimeProcessKeyBridgeTiming` 将 raw timing 拆为 `processKeyLibrimeDurationMs` 与
`processKeyCollectDurationMs`，`pathLocal`、`preedit`、`pathUI`、`candUI` 独立
计时。当前 gate-off 源码中 `KeyboardController` 是 `@MainActor`，同步分支在
`handleInsertKey` 内调用 `engine.processKey`；因此样本与“主线程等待 RIME 再返回”
的现象相容。

### 2.2 不能由这些字段推出的结论

以上不是 Lua 或某一个 RIME schema/table 函数的根因证明，也不是 off-main 迁移证明：

- `processKey api` 只定位到 bridge/librime API wall time；没有 stack trace、symbolicated
  profile、Lua/table 分解或受控 schema knob 对照，不能说“已经证明是某个 Lua 问题”；
- 没有线程/队列采样或 `T9RESP PATH/READY` marker，不能由这份导出证明
  thread-affine owner active、MainActor 阻塞的精确线程时间线或 off-main 修复效果；
- `rime` 在可触发自动锚定的 action 中可能包括额外 `replaceInput`/恢复调用，因此
  只能把表述限定为“观测到的 RIME bridge/processKey API-dominated span”，不能假设
  每一条 `rime` 都只包含一次 processKey；四条 slow row 的并列 `processKey api` 字段
  仍支持其 API span 主导的有限结论；
- 34 条记录不是完整 39-key 分布，不能外推到所有 raw length、设备、Release 或
  产品性能 SLO。

## 3. 规范性、完整性与 provenance

### 3.1 已诚实记录的部分

- canonical evidence 明确是“partial content-free export”，保留 `T9SEG` action/event
  6–39（34 条），没有把它写成完整 39 条曲线；Assignment 也明确第一轮非规范、第二轮
  前五条附件缺失。
- retained slow rows 的 `committed=false`、有效稳定 session、候选数量与人类报告的
  无漏键/重复/候选消失/键盘退出，被作为 bounded integrity observation，而不是产品
  成功标准。
- evidence 明确一次 `T9AUTO status=accepted`（event 18，`anchorSyllables=2`、
  `anchorSlots=7`、`applyMs≈2.35`），并明确后续 slow rows **不是 A/B efficacy result**。
- evidence 明确没有 `T9RESP marker=PATH/READY`，所以不声称 off-main thread-affine
  owner 已活动；这正是对缺失 marker 的正确处理。
- ordinary gate-off Release replacement 的首次失败（未安装）与第二次成功、bundle
  / executable hashes、`devicectl` install 成功和 database sequence 3600 均有记录。
  这足以支持“诊断臂之后恢复设备普通 gate-off 安装状态”的部署记录，但不等同于
  Release 功能/性能测试。

### 3.2 尚未满足的 Assignment exit criteria

以下不是 P0/P1 生产缺陷，但使 Assignment 继续保持 `In Progress` 合理且必要：

1. **action 1–5 缺失：**不能形成完整的 1–39 raw-length/event 曲线，也不能证明附件
   覆盖了整个连续输入；当前慢事件的局部归因仍可用。
2. **run header 不完整：**canonical 表格有 device/OS/host/build/source/executable
   hash，但未明确写出 schema/readiness、Full Access 观察值，也没有 worktree dirty
   diff fingerprint；这与 Assignment §Exit criteria 1 的完整 provenance 要求不完全
   一致。
3. **Human 评分缺项：**报告了“仍偶尔感到卡顿”和输入完整性结果，但没有记录 Assignment
   要求的 0–4 subjective stall score。它不能被默认为 0，也不能由 `T9SEG` 数字替代。
4. **Integrity 只覆盖 retained rows：**前五条缺失时，`committed=false`/session
   stable 不能被外推到未保留的五条。

这些缺口已被文档的大体状态（`Canonical partial`、Assignment `In Progress`）部分承认，
但应在后续 addendum 或完整导出中补齐，不能仅因为后续 slow rows 可归因就把 exit criteria
标为全部完成。

## 4. A1 one-anchor、T9RESP marker 与因果边界

### 4.1 A1 one-anchor：观察，不是效果结论

event 18 的 `T9AUTO status=accepted` 与 raw length 17→20 的变化相互一致，且记录声明
这是 Debug diagnostic arm、不是 host commit。随后 raw lengths 27、35、37 仍出现
RIME API slow rows，支持“本轮后续仍观察到残余 stall”。但因为：

- 没有同一输入/同一构建的 gate-off no-anchor control；
- 只有一次 one-anchor 事务，不是固定次数或完整 A/B；
- action 1–5 缺失，无法重建 anchor 前后的完整曲线；

所以最严谨的叙述应是“在一次带 one-anchor 诊断臂的运行中，后续仍观察到 slow rows”，
而不是“one-anchor 已证明不能消除该失败类”。canonical 当前已写明“不是 A/B efficacy
result”；建议继续保持这一窄表述。

### 4.2 无 `T9RESP marker=PATH/READY`

这不是当前 gate-off 诊断的失败条件：本轮目的是观察真实设备上现有同步热路径的延迟，
并非证明 thread-affine 修复成功。但它明确留下一个边界：

- 不能判断这次运行是否 arm 了 MainActor-responsive 或 thread-affine path；
- 不能比较 gate-on 与 gate-off 的主观 key feel、publish lag、队列/内存/jetsam；
- 不能把本次 `processKey api` slow rows 解释为 off-main owner 的表现或失败。

canonical 对该边界的记录是诚实的，且没有把 P2-PERF-01 偷换成 R4/R5/R6 证据。

## 5. Gate、ADR、Release 与 Product 边界检查

| 边界 | 复审结论 |
|---|---|
| 生产逻辑 / RIME bridge / Lua | **未修改、未授权**；文档明确只做诊断与日志导出 |
| responsive / thread-affine gate | **未改变**；没有 `T9RESP PATH/READY`，也没有宣称 gate-on |
| A1 / auto-anchor | 仅一次 Debug one-anchor 观察；未扩展次数、未宣称成功或默认开启 |
| ADR 0025 | **仍 Proposed**；证据没有 Accept 语句 |
| Release | 只记录诊断后的普通 gate-off replacement restore；没有 Release 性能、SLO、jetsam 或 shipping 结论 |
| Product Gate / R6 | Assignment 与 canonical 都明确排除；没有越界声明 |
| 用户内容隐私 | retained evidence 只保留长度、耗时、session/integrity/count 字段，没有 host text、候选文本、拼音载荷或用户词典内容 |

当前未发现 P0/P1 的治理越界或生产安全问题。特别是“恢复 Release gate-off 安装状态”
不应被误读为“Release build 已通过本性能矩阵”。

## 6. Findings 严重度

### P2（3 项）

1. **P2-PERF-01-E1 — Exit/provenance 不完整：**action 1–5、schema/readiness、Full
   Access、worktree fingerprint 与 0–4 Human score 未完整落在 canonical run header/附件；
   因此不能关闭完整 Assignment exit criteria 或形成完整长度曲线。
2. **P2-PERF-01-E2 — 因果/迁移证据缺失：**one-anchor 没有 control arm，且没有
   `T9RESP PATH/READY`；当前证据能定位 gate-off API-dominated stalls，但不能评价
   auto-anchor efficacy、off-main owner 或任何修复后的 A/B 方向。
3. **P2-PERF-01-E3 — API 归因不是内部根因：**processKey/collect split 足以排除本轮
   Path/Candidate UI 为首要成本，但不足以区分 librime table/Lua/translator/bridge
   或其他内部层；后续根因 spike 仍需独立 stack/config/controlled evidence。

### P3（1 项）

- **P2-PERF-01-E4 — 文案范围需继续收窄：**“one-anchor 不消除失败类”与“无 further
  Human input required”均应附带 partial/export 与无 control 限定；更准确的是“后续仍
  观测到 slow rows，完整曲线与主观评分仍未收齐”。这不会改变已记录的 bounded diagnosis。

## 7. 已证明与未证明

### 已证明（限定于这次保留的 Debug 真机样本）

- iPhone 13 Pro / iOS 27 / Reminders / software keyboard / Universe Chinese nine-key
  的人工运行产生了可解析、内容脱敏的 `T9SEG` 诊断记录。
- 在 action/event 6–39 的四条 slow rows 中，`processKey api` 与 `rime` 约占总耗时
  99%，collect 与 Path/Candidate UI 明显较小；这是当前“主观卡顿首先查 RIME API”方向的
  有力观测证据。
- retained rows 没有记录 commit、session invalidation 或数字泄漏；Human 也报告没有
  漏键/重复/候选消失/键盘退出。
- 诊断后 ordinary gate-off Release replacement 安装记录已保存；未把它宣称为 Release
  性能验证。

### 未证明

- 完整 39-action 曲线、action 1–5 的 timing/integrity、完整 run header 与 0–4 主观评分；
- Lua、词典、translator、table 查询或 bridge 内部的具体根因；
- thread-affine owner 是否 active、off-main 是否改善主观 key feel、R5/R6 或任何 A/B；
- Release SLO、jetsam、队列/内存、TestFlight/App Store 或 Product Gate；
- ADR 0025 Accepted、dual-gate default-on、auto-anchor 扩展或用户设置改变。

## 8. 最终判断与停止点

本 Architecture 结论为 **Pass with conditions（diagnostic attribution only）**：

1. 可把这份证据交给 Quality/Performance 角色，支持“当前保留样本的卡顿主要落在
   RIME processKey API，而非 Path/Candidate UI”的有限诊断；
2. P2-PERF-01 仍保持 `In Progress`，不关闭完整 Assignment exit criteria；
3. 若下一步要主张 Lua/内部表根因、auto-anchor 方向、off-main 迁移收益或 Release
   性能，必须新建对应受授权的诊断/对照矩阵；
4. 保持普通 Release gate-off、ADR 0025 Proposed、Product Gate/R6 未授权。

本复审不修改生产逻辑，不把真机 Debug partial 运行写成产品不卡顿，也不授权任何默认
开启、Release 发布或 ADR 接受动作。
