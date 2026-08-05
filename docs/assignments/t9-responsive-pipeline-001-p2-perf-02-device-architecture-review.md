# 独立 Architecture 复审：P2-H-06 真机运行证据

| 字段 | 结论 |
|---|---|
| 复审状态 | **Proposed — 独立、只读 Architecture review** |
| 复审日期 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | [`P2-H-06 真机运行证据`](../evidence/t9-responsive-pipeline-p2-perf-02-device-2026-08-02.md) |
| 关联合同 | [`P2-PERF-02 Release-like Assignment`](t9-responsive-pipeline-001-p2-perf-02-release-like.md)、[`Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md) |
| 代码边界 | `T9ResponsiveEvidenceValidator`、`ResponsiveRimeFeltMetrics`、`ResponsiveRimePreflight`、`HotPathSegmentTiming`、`KeyboardController`、`Logger/LoggerWriter`；不改生产逻辑、不改测试、不接受 ADR/Product Gate |
| Architecture 结论 | **Pass with conditions（runtime evidence 仍为 Partial）**：真实设备观察有价值，但 A validator 合同、B revision publish 合同和隐私导出判定尚未闭合 |
| P0 / P1 / P2 / P3 | **0 / 0 / 3 / 2** |
| 治理结论 | ADR 0025 仍为 `Proposed`；不宣布 P2-PERF-02 Complete、Release、Product Gate 或默认开启 |

## 1. 复审范围与证据层级

本次只读检查了：

1. P2-H-06 iPhone 13 Pro A/B 证据、A/B/Restore 指纹、run token、App Group 日志来源、
   Human report、validator 输出、cleanup/restore 叙述；
2. Release-like Assignment 的 A/B 期望、退出条件、停止条件和恢复合同；
3. Evidence Contract 中的 `T9DEVICE`、PATH/READY、T9GEOM、T9SEG、ACCEPT/VISIBLE/PUBLISH、
   session、privacy、restore 与 `Complete/Partial/Blocked` 判定；
4. hardening Architecture/Quality review 对 schema-v1、owner timeout、run-bound marker、
   default gate-off 和 final-v4 bounded 结论；
5. 当前 validator/metrics/logger 源码，以区分真实运行观察、静态代码事实和未提供的原始
   导出文件。

本复审没有重新安装、重新输入、读取宿主内容、修改 App Group、清理设备或重跑生产逻辑。
证据文件只提供 A/B 日志 SHA-256 与摘要，没有把原始 App Group 日志作为可供本次重新计算的
workspace artifact，因此日志 hash/privacy 结论按“Executor 记录的运行证据”处理，不冒充本次
独立重算。

## 2. 真机运行事实与边界

### 2.1 bounded 正向事实

证据记录的 iPhone 13 Pro（`iPhone14,2`、iOS 27.0）上，A/B 使用同一 39-key 手动九宫格
fixture、同一 Reminders 空列表标题位置和 software keyboard；没有坐标输入、Path/candidate
点击或数字页输入。A/B 均观察到：

- `T9SEG` action/event `1…39` 连续，`committed=false`；Human 未见漏键、重键、候选消失或键盘退出；
- native session identity 非零、39 条 `validBefore/After=true` 且各臂内稳定；
- prepared/execution geometry 各自使用同一 digest；
- A 有 `path=sync`；B 有 `path=thread-affine`、`dualGateRequested=1`、`dualGateActive=1` 和
  `READY bootstrap=config-only session=owner-thread`；
- A/B 的真实运行摘要均观察到 `SLOW RIME`，B 的 T9 接受热路径中位约 `0.3 ms`、A 的
  同类总耗时中位约 `15.8 ms`；Human 主观评分为 A `3/4`、B `4/4`。

这支持一个**方向性观察**：在这一次开发签名、Release-optimized、同设备手动运行中，B 的
接受路径主观上更顺畅。它不是用户 SLO，也不是证明每个 revision 都已完成 engine/UI publish。

### 2.2 身份与恢复

证据包含 source HEAD、dirty worktree 声明、A/B/Restore App 与 Keyboard.appex SHA-256、设备
UDID/OS、各自 run token 和 App Group `rime_diag_log` 来源。它还记录两个 envelope 按 token cleanup、
matrix registry finalize、`rime_diag_log` 保留、没有删除提醒事项/RIME userdb/container 或卸载，
以及普通 gate-off Release 替换安装成功。

这些内容与 Contract 的“只清理本次 token、不得破坏宿主数据、恢复普通 gate-off”方向相符；但没有
单独的 `restore.json`、明确的 start/end 时间、设备上已安装 bundle identity 回读或恢复后的
keyboard-switch smoke 结果。因此 restore 只能算 bounded evidence，不能把缺失字段默认为通过。

## 3. P2 findings

### P2-DV-01：A sync arm 的 validator 无条件要求 ACCEPT/PUBLISH

**结论：真实 A 运行路径本身没有这个缺口；当前 validator 的 expectation/判定合同有缺口。**

`T9ResponsiveEvidenceExpectation` 将 `requirePathMarker`、`requireReadyMarker` 和
`requireRunBoundMarkers` 按 arm 区分，sync arm 默认不要求 responsive PATH/READY；但是
`T9ResponsiveEvidenceValidator.validate` 后段对所有 arm 无条件执行：

- 没有任何有效 PUBLISH 就追加 `publish-marker-missing`；
- `acceptedRevisions` 不是 `1…actionCount` 就追加 `accept-revisions-not-complete`；
- 只有 thread-affine 才额外要求 epoch-bound publish，但 sync 的前置 ACCEPT/PUBLISH 要求
  已经使它不能成为 Complete。

当前 gate-off A 路径不会调用 `recordResponsiveAcceptMetrics`，也不会产生 responsive
ACCEPT/PUBLISH；因此设备证据的 A marker-only 结果稳定地为 `Partial`，不是 A 运行失败。
这会让合法 sync arm 永远无法满足其应有的“39 T9SEG + session + geometry + sync path”
合同，属于 P2 证据架构缺口，不是 P0/P1 用户输入问题。

建议在后续授权中把“响应式 felt marker 合同”显式设为 thread-affine-only（例如 expectation
增加 `requireResponsiveFeltMarkers`，或对 `.threadAffine` 才检查 publish/revision），同时
增加 sync 完整正样本和 B 严格负样本；不要通过把 A 的缺失字段伪造为零或空列表来修复。

### P2-DV-02：B rev16/25/33 缺 epoch-bound publish，是 coalescing 语义与证据合同的真实不一致

证据显示 B 有 39 个 ACCEPT、42 个 VISIBLE（6 provisional、36 engine），但 rev16、25、33
只有 provisional visible，没有对应 epoch-bound PUBLISH；validator 因
`epochPublishRevisions != acceptedRevisions` 输出 `epoch-bound-publish-incomplete`，所以 B
保持 `Partial`。

源码解释了为什么这不应直接写成“漏键”：

- `KeyboardController.applyResponsivePublishedSnapshot` 在 owner backlog 达到
  `presentationCoalescePendingThreshold` 时，把 snapshot 暂存为 latest-only，后续只调用一次
  `performResponsivePresentationApply`；
- epoch-bound `ResponsiveRimePreflight.publishMarkerLine` 只在
  `performResponsivePresentationApply` 中记录；被 coalesce 的中间 revision 不会产生该 marker；
- B 的 39 条 T9SEG、稳定 native session 和 Human integrity 观察并未显示输入事件被丢弃。

因此当前是一个**真实的 Architecture/Contract mismatch**：合同把“每个 accepted revision
必须有 epoch-bound publish”定义为 engine/owner 完成证据，而实现把 marker 绑定在“实际 UI
presentation apply”上。两者不能悄悄择一：

1. 若 PUBLISH 代表 owner/engine 完成，应在 owner 每个 revision 的 Sendable completion 上
   记录独立 content-free epoch marker，UI coalescing 另记 `coalesced`；或
2. 若 PUBLISH 代表可见 UI apply，应修改合同为“每个 presented revision”，并增加明确的
   coalescing coverage/receipt，证明被跳过的 revision 仍在 engine FIFO 中完成。

在 Product/Architecture 决策前，不应把 validator 放宽为只要求任意一个 epoch publish，
也不应把 rev16/25/33 补写成已发布。该问题是 P2 证据闭环，不是本次真机运行可以自行扩大
的生产语义授权。

### P2-DV-03：App Group 导出被 privacy deny-list 误阻断，且原始日志 artifact 不可独立复核

证据报告原始日志 validator 为 `Blocked`，原因是 `privacy-sensitive-content`；但触发内容是
`SLOW RIME ... candidates=12` 这种数值计数摘要，而不是候选文本。源代码
`T9ResponsiveEvidenceValidator.containsPrivacySensitiveContent` 将完整 substring
`candidates=` 列入 forbidden fields，因而会把合法 content-free count 误认为敏感内容。把这些
行排除后，marker-only 对照只剩 A 的合同 mismatch 或 B 的 epoch publish 缺口；这证明当前
阻断主要是规则误识别，不是观察到隐私泄漏。

同时，App Group `rime_diag_log` 的来源在 Logger/LoggerWriter 中是异步 UserDefaults writer，
显式 preflight marker 可绕过 category filter 并请求 flush；普通 felt `performance` 行仍受
category/filter 和生命周期影响，writer 还有 500 行上限，suspend 时会丢弃 pending records。
设备证据给出了原始日志 SHA-256，但 workspace 没有对应原始/清洗后文件、字节数、privacy scan
输出或可重算 manifest；本次无法独立证明 hash、筛选边界和“未出现非 ASCII/用户内容”。

建议后续将 privacy 检查做成 marker-aware schema：对已知 `SLOW RIME` 允许严格的数值
`candidates=<digits>`，仍拒绝 candidate text/unknown value；同时为每个导出保存 content-free
artifact 的字节数、SHA-256 和 scan summary。该缺口阻止 evidence `Complete`，但没有 P0/P1
泄漏证据。

## 4. P3 findings

### P3-DV-04：restore 证据缺少合同要求的独立 manifest 字段

恢复动作本身符合安全边界：没有 uninstall、container wipe、RIME/userdb reset 或提醒事项
删除，普通 gate-off 包已替换安装，envelope/registry 按 token 清理。剩余问题是报告形态：没有
单独 `restore.json` 路径、命令/时间摘要、设备安装 bundle identity 回读、cleanup digest 或
keyboard-switch smoke check 的 observed/unavailable 状态。建议未来把这些字段写入不可变
restore manifest；当前属于证据完整性边界，不是破坏性操作或生产逻辑 blocker。

### P3-DV-05：App Group evidence filter 仍是 substring allow-list

`T9DevicePreflightEvidenceLineFilter` 以 `contains("T9RESP ")`、`contains("T9GEOM ")` 等规则
保留行，合法性和隐私主要由后置 validator 负责。它能帮助 App Diagnostics surface 导出目标
marker，但不能独立证明未知 ASCII 字段不是用户内容或 marker 一定从行首开始。建议补
marker-shape/unknown-field 负样本，并保持 filter 与 validator 职责分离。

## 5. Run-bound PATH/READY/geometry/session 复核

### 已证明（bounded）

- B 的 PATH/READY 在证据摘要中带 thread-affine、dual gate、`bootstrap=config-only`、
  `session=owner-thread`；hardening validator 对 run/fixture/schema 缺失或混 run fail-closed；
- A/B 的 T9DEVICE、T9SEG 和 T9GEOM 有各臂 token；geometry prepared/execution digest 各臂内
  相同；T9SEG session identity 非零、有效并稳定；
- B 的 39 ACCEPT/42 VISIBLE 与 T9SEG 39 条形成真实运行序列；缺口是 publish 语义，不应被
  改写为漏键或重复；
- source-level owner isolation、default gate-off、schema-v1 和 final-v4 hardening 结论已在
  前置 Architecture/Quality review 中 bounded 复核。

### 未证明或只能作为 supplied evidence

- 本次没有原始 App Group log 文件可重算 A/B SHA-256，不能独立复核完整日志、字段顺序、
  privacy scan 或 marker-only 的筛选输入；
- 没有多轮、多设备、Extension jetsam/memory/queue、长时间 reload/retry 或 iOS 26.0
  Release RC/签名 archive；
- 本次真实 iPhone 13 Pro/真实 librime 观察支持 bounded runtime fact，但不能外推为签名
  Release、默认 gate 或所有设备行为；
- A/B 方向性主观分数不能转换为用户可见 SLO 或 Product Gate。

## 6. 总结、建议与停止点

### 6.1 最终判定

Architecture verdict 为 **Pass with conditions，P0/P1/P2/P3 = 0/0/3/2**：

- P2-DV-01：sync arm validator 必须跳过不适用的 ACCEPT/PUBLISH 要求；
- P2-DV-02：B 的 per-accepted-revision epoch publish 与 latest-only UI coalescing 语义未
  对齐；
- P2-DV-03：App Group privacy false-positive 与不可独立复核的日志 artifact 阻止 Complete；
- P3-DV-04/05：restore manifest 细节和 substring filter shape 可后续强化。

没有发现 P0/P1，也没有证据支持把 A/B 声称为 Product/Release Pass。B 的真实输入完整性、
session/geometry 和主观流畅度可作为方向性观察；合同状态仍应是 `Partial`。

### 6.2 推荐下一步（仅建议，不执行）

1. 由 Architecture/Product 决策 A sync 的 validator expectation 分支，并补 sync positive
   regression；
2. 明确 PUBLISH 是 owner completion 还是 UI presentation，选择“每 revision owner marker”
   或“presented revision + coalescing receipt”，再重新跑 B；
3. 只读修复/回归 privacy schema，避免把数值 `candidates=<digits>` 当作用户候选内容；
4. 未来真机复测前，输出 content-free log artifact、字节数、SHA-256、privacy scan 与
   restore manifest；保持普通 gate-off 恢复；
5. 继续保持 ADR 0025 `Proposed`、默认 gate-off、历史/当前 B `Partial`，不把本 review 升级
   为 Product Gate 或签名 Release 结论。

本 Architecture 角色到此停止；本文件不修改生产逻辑、测试、Assignment、ADR、设备数据或
Product Gate 状态。

