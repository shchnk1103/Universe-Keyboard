# T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02 Canonical A/B
# 独立 Quality / Performance 只读复审

状态：`Completed — bounded canonical A/B + restore observation; Pair remains Partial`

复审日期：2026-08-03

复审角色：独立 Quality / Performance reviewer（只读）

## 1. 范围与停止边界

本次复审检查：

- `docs/assignments/t9-responsive-pipeline-001-p2-perf-02-canonical-ab-20260803.md`
- `docs/evidence/t9-responsive-pipeline-p2-perf-02-canonical-ab-2026-08-03.md`
- `docs/evidence/t9-responsive-pipeline-p2-perf-02-canonical-ab-summary-2026-08-03.json`
- `docs/assignments/t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md`
- Assignment/summary 所引用的 A、B content-free 临时导出及普通恢复记录是否存在

本次没有修改生产逻辑、没有改变默认 gate、没有开启 Release default-on、没有做设备操作，
没有将该观察升级为 ADR 0025 Accepted、Product Gate 或 Release 结论。

## 2. Verdict

**Verdict：条件通过（bounded canonical A/B runtime observation）；Pair 仍为 `Partial`。**

这批材料足以支持一个受限的方向性观察：在同一 iPhone 13 Pro、同一源码/工具链声明、同一
手工协议下，A 同步臂的 `T9SEG` immediate path 出现约 181.8 ms 长尾，而 B 的 immediate
`T9SEG` path 最大约 0.7 ms；B 另记录了 39/39 owner `PUBLISH` 和最多 160 ms 的异步
`VISIBLE`/`PAINT` lag。Human 评分也从 A 的 `2/4` 变为 B 的 `0.5/4`，但仍报告了极轻微
可感停顿。

这不是完整 P2 evidence contract Pair：普通包恢复现已有 bounded pass，但完整 restoreRef/cleanup
记录尚未形成仓库内的 Pair manifest；Full Access/host opaque ID/时间与若干 run-header 字段不可得，
Human fixture 的实际序列不能由 content-free 日志重建，且 B 的 37 条 `PAINT` 对缺失 revision
的 coalescing 证据不够明确。

严重度计数（本复审发现的残余）：

| P0 | P1 | P2 | P3 |
|---:|---:|---:|---:|
| 0 | 0 | 3 | 3 |

这些残余是证据完整性、生命周期和可比较性边界，不是已发现的生产数据破坏或隐私泄漏。

## 3. 已确认的正向证据

### 3.1 A/B 身份与手工边界

- Pair ID、A/B 独立 Run ID 和独立 canonical token 已记录；token 格式正确且不复用。
- 两臂使用同一 source HEAD、tracked diff fingerprint、设备/OS、Xcode/SDK/Swift、bundle
  identity 和预运行 dirty-worktree 名称 fingerprint；App/Keyboard.appex hash 按臂分别记录。
- A 只注入 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`，实际 `path=sync`、`dualGateRequested=0`、
  `dualGateActive=0`。
- B 额外注入 `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`，实际 `path=thread-affine`、
  `dualGateRequested=1`、`dualGateActive=1`，并有 `READY bootstrap=config-only session=owner-thread`。
- 两臂均未把 auto-anchor `*_ENABLED` 产品行为作为比较变量；B 是显式内部诊断臂。
- Assignment 明确要求 Human 使用 software keyboard 的中文九宫格手动输入，不使用数字键、
  Path/candidate/space/commit/Delete 或坐标自动化；证据没有复制原始输入或宿主文本。

### 3.2 A 的 39/39 与 session

- `T9SEG` 为 39 条，action/event 均为连续 `1…39`，全部 `committed=false`。
- native session identity `5686340504` 在 39 条中有效且稳定。
- `T9ARM` 是旧 checkpoint，不覆盖 P2 的 39-action 计数；summary 使用 `T9SEG` 计算 retained count。
- Geometry prepared/execution 存在且同臂 digest 匹配。
- Human 报告 missing/duplicate/candidate disappearance/keyboard exit 全部为 `no`，ordered
  completion 为 `reported-complete`，stall score 为 `2/4`。

### 3.3 B 的 39/39、owner completion 与 session

- `T9SEG` 为 39 条，action/event `1…39`，全部 `committed=false`。
- native session identity `4381352920` 在 39 条中有效且稳定；Geometry prepared/execution
  digest 匹配，且 tokenless screen/keyboard/slot shape 与 A 一致。
- `ACCEPT` revisions `1…39`、epoch `1`；`PUBLISH` revisions `1…39`、epoch-bound、ordered，
  owner completion coverage **39/39**。
- `VISIBLE` 共 42 条：37 条 engine snapshot + 5 条 provisional shadow feedback；该数量不等于
  输入事件数量，不能据此判断漏键。
- Human 报告四项 integrity 全部 `no`，ordered completion 为 `reported-complete`，stall
  score **`0.5/4`**，保留了“仍有很小可感停顿”的不确定性。

### 3.4 Privacy allow-list 与 artifact 摘要

- A/B source attachment、filtered subset 的 bytes/SHA-256、line count/path 均记录。
- A/B filtered subset 声明通过 content-free allow-list，只保留 `T9DEVICE`、`T9GEOM`、
  `T9RESP`、`T9SEG`、`T9ARM`、`SLOW RIME` 这类 marker/数值摘要；未将 raw pinyin、候选文本、
  Reminders 文本、截图或 UI hierarchy 写入仓库。
- `cands=12` 等字段是数量摘要，不是候选文本；在本证据包中没有看到隐私违规标记。

## 4. A/B 统计的正确解释边界

| 指标 | A sync | B thread-affine | Quality 解读 |
|---|---:|---:|---|
| `T9SEG total` max | 181.8 ms | 0.7 ms | 支持 B immediate accept/UI path 没有同步等待长 RIME 调用；不是全局 UI paint SLO。 |
| RIME/owner-observable max | RIME 180.4 ms | engine `VISIBLE` lag 160.0 ms | 两者不是同一 stage；不能把 160 ms 称为 B 已无延迟。 |
| Human stall score | 2/4 | 0.5/4 | 同一次人工 A→B 方向性改善，仍是单人单次主观评分；B 仍有轻微停顿。 |
| B owner PUBLISH | 不要求 | 39/39 | 证明 accepted revision 已由 owner 完成交付，不承诺每个 revision 都单独 paint。 |
| B PAINT | 不要求 | 37/39 | 允许 latest-only coalescing，但缺失 revision 的可见性需要额外语义证据。 |

因此最安全的结论是：**本次 B 的 immediate acceptance path 明显短于 A，并与方向二假设
一致；异步 engine/可见结果仍有长尾，用户可见体验并非零延迟。**

## 5. P0–P3 findings

### P0：0

没有发现输入数据破坏、隐私泄漏、设备不可恢复或默认 gate 被打开的证据。

### P1：0

两臂核心 runtime path、39/39 输入计数、session、B 的 39/39 owner completion 均有一致的
bounded 记录；没有发现需要把这次诊断观察标为 Blocked 的错误设备或错误 token。

### Closed（原 P2-CAN-01）：普通 gate-off restore bounded pass

Assignment 的退出规则要求 B 后恢复同源普通 Release 包，记录 App/appex hash、cleanup 状态和
一次键盘 smoke。独立 restore addendum（见第 8 节）现已记录：同源普通 Release、无 T9 条件、
安装成功、database sequence `3768`、App hash `fde674…654f1`、Keyboard hash `612b4e…7845`，
以及 Human 一键生效、键盘保持可见且未退出。因此“恢复尚未执行”的 pending 状态已关闭。

但 canonical evidence/summary 仍没有 durable `restore.json` 或 Pair Manifest，未记录完整的
restore command/time、cleanup/no-wipe 声明与同源 restore source/build binding。这些归入
P3-CAN-05 的 manifest residual；它们不再是“restore pending”，但仍使 Pair 的完整合同状态
保持 `Partial`。

处置建议（不在本次执行）：把已有 restore 安装 JSON、hash、sequence 和 Human smoke 以
content-free `restoreRef`/manifest 形式绑定到 Pair；不要重复设备操作，也不要把该 smoke 当成长句
SLO。该项的“pending”状态已关闭。

### P2-CAN-02：Full Access、opaque host identity 与时间/run-header 字段不完整

Assignment 明确把 Full Access 标成 `unavailable`；evidence 只有“同一 opaque empty Reminders
list protocol”，没有每臂可比对的 opaque list ID，也没有 A/B 独立 start/end/timezone/log window。
P2 contract 将 host、Full Access、time window、artifact/run-header 作为必填字段，缺失时不得从
另一臂继承或猜测。

因此两臂可做有限的同设备/同协议方向观察，但不能写成 contract Complete 或无条件 A/B Pass。

### P2-CAN-03：canonical human fixture 的实际手工遵循不能由 runtime 独立证明

Canonical human fixture ID/digest 与 runtime marker ID 已在协议中声明映射，39-action 数量和顺序
与两臂 runtime 一致；但 raw sequence 按隐私规则不进入日志，summary 明确写的是
`protocol-declared-runtime-39-actions-no-raw-reconstruction`。Human report 也没有单独字段确认
每臂均未点数字页、Path/candidate、space、commit 或 Delete。

因此可以报告“按 protocol 声明的手工 fixture 完成，runtime 观察到 39 个 ordered actions”，
不能报告“Quality 已从日志密码学地确认每一个实际触点就是 canonical raw sequence”。这会让
Pair 保持 bounded/Partial，而不是阻止本次方向性观察。

处置建议：下一次 human report 增加 content-free `protocolAdherence` 枚举（包括 prohibited
actions 与是否 pasted），不记录原始输入；若无法观察，写 `unavailable`。

### P2-CAN-04：B 的 37 PAINT 缺失 revision 与 `coalesced=0` 语义未充分闭合

39/39 `PUBLISH` 是积极证据：owner 并未丢弃或合并用户事件。37 条 `PAINT` 在契约上可以由
latest-only UI coalescing 解释，且证据明确列出缺失 revision `16`、`33`，所以它本身不是
P0/P1 漏键问题。

但 B content-free subset 中这 37 条 PAINT 的 `coalesced` 字段均为 `0`；summary 也写
`paintCoalescedFieldObserved=0`，却没有一条 `coalesced=1`、`coalescedRevision` 或独立
`latest-only` reason 把 revision 16/33 的缺失绑定起来。因而 Quality 只能确认 owner completion
39/39，不能确认 UI presentation 的缺失是已记录的 coalescing，而不是诊断漏行或另一种应用
路径。

处置建议：保持 PUBLISH 与 PAINT 分层；下一次在 coalesced latest-only 发生时记录 content-free
`coalesced=1`/被吸收 revision 区间或明确 terminal reason，并让 validator 对该不变量 fail-closed。

### P3-CAN-05：Dirty source 与完整 Pair Manifest 的可重建性仍有限

两臂共享 source HEAD、tracked diff 和 untracked-name fingerprint，足以支持“同一预运行工作区
声明”的有限判断；但没有 untracked-content fingerprint，也没有仓库内的 `pair-manifest.json`、
独立 A/B `run-header.json` 或可重开的 build/restore manifest。restore 安装 JSON 已在受控临时
目录出现，但尚未由 canonical evidence 通过 `restoreRef` 持久绑定。

这不是本次 runtime 的错误，但降低了后续 reviewer 对同源构建、安装身份和时间顺序的可重建性。
新 run 应在构建前生成 content-free manifest；历史未捕获字段继续标记 `unavailable`。

### P3-CAN-06：Privacy allow-list 的摘要可审阅，但 validator provenance 仍不完整

filtered subset 的 bytes/SHA 与 allow-list `pass` 已记录，且原始/过滤文件在受控临时位置仍可
定位；这足以支持本次 content-free 的有界判断。当前 summary 没有记录 allow-list/validator
实现版本、source SHA、完整 reasons 或独立 `privacy-scan.txt`，仓库也不保存可长期复算的过滤
日志副本。

因此不能把 `privacyAllowList=pass` 扩大为所有未来导出均无泄漏，也不能把本次 A/B 变成长期
不可变隐私审计。建议后续 summary 记录 validator schema/source digest 与 allow-list version，
继续不复制原始用户内容。

### P3-CAN-07：单 Pair、A→B 顺序与主观评分不构成用户 SLO

本次每臂只有一个 39-action run，且按 A 后 B 的固定顺序执行；没有重复样本、顺序反转、帧率/
主线程 paint trace、置信区间或长时间压力/内存数据。B 的 `0.5/4` 仍包含 Human 的不确定性，
不能写成“完全不卡顿”，A 的 `2/4` 也不能单独确定唯一根因。

方向性结论可以保留为“B immediate path 更短、主观卡顿减轻”，但必须保留 engine VISIBLE/
PAINT lag、host/UI 外部成本、真实 librime/Extension jetsam 与 Release/Product Gate 未验证的
限制。

## 6. Evidence contract 对照

| Contract layer | 结论 | 说明 |
|---|---|---|
| Runtime facts | `bounded pass` | A/B path、39/39 `T9SEG`、session、geometry；B ACCEPT/PUBLISH 39/39。 |
| B owner completion | `bounded pass` | epoch 1、ordered、39/39 PUBLISH；不等于 39/39 PAINT。 |
| UI presentation | `Partial` | 37 PAINT 的 missing revisions 与 coalescing reason 未充分绑定。 |
| Human result | `Partial` | 四项 integrity 与 2/0.5 评分齐全，但 prohibited-action adherence 未单独记录。 |
| Privacy/content-free | `bounded pass` | allow-list/hash/filtered subsets 存在；validator provenance 与长期复算仍有限。 |
| Runtime identity/comparability | `Partial` | Full Access、host opaque ID、time window、完整 manifest/dirty content 不足。 |
| Lifecycle restore | `bounded pass; manifest Partial` | 普通恢复包安装序号/包 hash 与 Human smoke 已观察；cleanup、时间、restoreRef/source binding 仍未持久绑定。 |
| Product/ADR/Release | `not-authorized` | JSON 明确如此；本复审不改变它。 |

**最终分类：`Partial — canonical A/B runtime observed; B owner PUBLISH 39/39; PAINT 37 with
coalescing evidence residual; ordinary restore bounded passed; restore manifest residual`。**

## 7. 下一步建议与停止点

1. 将已完成的普通 gate-off restore 以 `restoreRef`、App/appex hash、install sequence、cleanup
   声明和最小 smoke 的 content-free manifest 形式补入 Pair handoff；不需要重复设备操作。
2. 在任何产品比较宣称前，补齐 Full Access/host opaque ID/time window/manifest 字段，并为
   fixture mapping 与 Human prohibited-action adherence 记录 content-free 状态。
3. 修正或明确 PAINT latest-only coalescing marker 语义，使 missing revision 16/33 有可审计的
   content-free reason；不要用 PUBLISH 39/39 冒充 UI paint 39/39。
4. 保留本次方向性事实：B immediate T9SEG max 0.7 ms、owner PUBLISH 39/39、engine/PAINT
   lag max 160 ms、Human 2→0.5；不得改写为“无卡顿”或“已证明唯一根因”。
5. 本复审完成后停止：不开启 Release default-on、不接受 ADR 0025、不宣布 Product Gate/Release，
   后续如需再次测试须由 Product Lead 新授权并生成新的 Pair/Run ID。

## 8. 独立 Restore Addendum（2026-08-03）

本节只记录当前任务收到的普通恢复证据，不改变生产逻辑或 A/B 统计：

| 字段 | 观察 |
|---|---|
| Restore arm | 同源普通 Release；未注入 T9 diagnostic conditions |
| Install result | `success`；device install database sequence `3768` |
| Device | 与 Pair 相同的 iPhone 13 Pro / CoreDevice `DE65EBE1-463E-5EB4-9694-F6DCBFC04028` |
| Restore App executable SHA-256 | `fde6743792f4441f58130ff689b255a547d21eb9b1e3b1d9b238a20f835654f1` |
| Restore Keyboard executable SHA-256 | `612b4e0792ce4245ddb074c59148ec1a20c8ad10a1cee465fab3034db4c67845` |
| Restore Human smoke | 单键生效；键盘保持可见；未退出 |

该 addendum **关闭原 P2-CAN-01 的“restore pending”状态**，并把 Lifecycle restore 从
`NotRun/pending` 提升为 `bounded pass`。它没有凭空补写未提供的 cleanup、restore 时间、
完整命令输出、source/build manifest 或 Full Access；这些仍由 P2-CAN-02/P3-CAN-05 等残余覆盖，
所以最终 Pair 仍为 `Partial`。本节不是 Product Gate、ADR 0025 或 Release 认证。

本独立 Quality/Performance 复审及 Restore addendum 到此停止。
