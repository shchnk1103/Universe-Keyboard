# Architecture Review：P3-D1-R03 iPhone 13 Pro gate-off baseline

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立、只读） |
| 日期 | 2026-08-03（Asia/Shanghai） |
| 复审对象 | [`P3-D1-R03 device baseline`](t9-responsive-pipeline-001-p3-d1-r03-device-baseline.md)、[`R03 device evidence`](../evidence/t9-responsive-pipeline-p3-d1-r03-device-2026-08-03.md) |
| 本次 Run ID | `P3D1-R03-OFF-20260803-001` |
| Architecture verdict | **Pass with conditions（仅 gate-off 真机证据层，bounded）** |
| 父矩阵状态 | **保持 `Partial — gate-off baseline captured`** |
| 治理边界 | 不接受 ADR 0025，不打开 B，不形成 Release、Product Gate 或用户 SLO 结论 |

## 1. 复审范围与权威边界

本次只读复审回答一个问题：R03 的真机 gate-off 证据是否足以支持一个受限的架构判断——
同步 `processKey`/RIME 热路径的慢峰与人工观察到的卡顿在时间上同向，且这批证据没有把
gate-off、隐私或恢复边界越权为 off-main 或 Release 结论。

当前生产路径仍由已接受的 [ADR 0004](../architecture/decisions/0004-rime-runtime-session-model.md)
约束：Extension 的 process-local RIME session 在 MainActor/主线程串行执行。
[ADR 0025](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) 仍为
`Proposed`；其 off-main serial owner 只可通过另行授权和独立验证进入后续阶段。

本复审不修改生产代码、build flag、测试环境、设备状态或矩阵结论。

## 2. 第一性原理证据链

| 层次 | 本次观察 | 架构含义 | 边界 |
|---|---|---|---|
| 输入 | Human 在 Reminders 中手动完成冻结的 39-key synthetic fixture；`T9SEG` 为 1…39 连续；无坐标驱动、无数字键、无候选/Path 自动点击 | 刺激确实来自真实第三方键盘触摸路径，且没有自动化注入替代用户输入 | 只覆盖一个人工 fixture 和一次 gate-off run |
| 状态/路径 | `T9DEVICE gate=off`；`T9RESP path=sync dualGateRequested=0 dualGateActive=0`；未启用 responsive/thread-affine flag；session 39/39 `validBefore/validAfter=true` | 可把该 run 归入 ADR 0004 的同步 A 路径；session/geometry 记录连续且没有明显生命周期破坏 | `T9DEVICE` 本身不是 B gate 证明；未观察真实 owner PATH/READY 或 off-main session |
| 输出完整性 | Human 报告无漏键、重复、候选消失或键盘退出；全部 39 个事件 `committed=false` | 没有证据表明本次卡顿由输入事件丢失、重复、session 失效或键盘退出造成 | 没有候选文本/宿主文本，因此不能做内容级语义判断 |
| 时间 | total median/max = 14.2/187.8 ms；RIME median/max = 7.7/186.6 ms；UI segment max = 7.7 ms；6 个慢 RIME 事件，action 33 的 `processKey` 约 186.6 ms | 慢峰主要落在同步 RIME/processKey 段，和 Human 报告的主观卡顿方向一致；支持“优先调查同步 RIME 热路径”的架构方向 | 这是同一 run 内的时间相关性，不是隔离变量后的因果证明；未完成 A/B 或 B 路径对照 |
| 恢复 | 已安装不含 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` 的同源普通 Release 包；记录 install DB sequence `3744` 与恢复包 hash | 诊断包没有被留作当前设备默认包，恢复动作可追溯 | 未报告恢复包安装后的再次打开键盘/输入冒烟 |

因此，本次证据可以支持“**同步 RIME/processKey 热路径与主观卡顿同向，值得进入下一阶段的
受控 off-main 可证伪验证**”，但不能写成“已证明唯一根因”或“off-main 已改善”。

## 3. P0–P3 findings

### P0：0

没有发现会造成数据破坏、隐私泄露、不可恢复设备状态或错误 Release 宣称的 P0 问题。

### P1：0

在 R03 的限定范围内，没有发现必须阻断该 gate-off 证据归档的架构缺陷。R03 不是 B 实现
验收，也不承担 ADR 0025 的生产接线证明。

### P2：2

#### ARCH-R03-P2-01：时间对齐不是因果隔离

`processKey` 的 186.6 ms 慢峰几乎占据 total 的 187.8 ms，且 UI segment 最大值为 7.7 ms，
这对“同步 RIME 热路径是优先怀疑对象”提供了很强的方向性证据。但当前导出没有受控的
替代路径、同序列 A/B、host text proxy/系统绘制的独立时间线，也没有真实 thread-affine
owner 结果。因此不能排除未记录的宿主或呈现成本，也不能把相关性升级为唯一根因。

**处置：** 保留“directionally aligned / 方向性支持”措辞；后续如要声称改善，必须另行授权
同源 A/B 或可证伪的 B spike，并绑定 owner completion、epoch/revision 与 UI apply 证据。

#### ARCH-R03-P2-02：诊断注入构建不是 Release/RC 证明

本 run 使用 Release configuration，但仅注入了 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`；
`T9_AUTO_ANCHOR_*_ENABLED`、responsive 与 thread-affine flags 均未启用。该组合足以证明
“本次诊断运行观察到 gate-off sync path”，但不等于普通 Release RC、App Store build 或
Product Gate 的发布证据。

**处置：** 归档时必须同时保留 injected flags、App/Keyboard.appex hash 与 restore package
hash；任何后续报告不得把该 run 简写成“Release 已通过”或“B 已关闭/已开启”。

### P3：2

#### ARCH-R03-P3-01：外部诊断附件未在本复审中重新执行完整 validator

仓库只保存外部诊断文本的内容无关摘要与 SHA-256；ASCII 扫描通过，但当前附件未由
`T9ResponsiveEvidenceValidator` 重新执行。历史说明指出 `candidates=12` 这类计数字段可能
触发 deny-list 的误报，不能把它误判为候选文本泄露，也不能把本复审写成完整 validator
Pass。

**处置：** 后续若把该附件作为正式不可变证据消费，应在受控副本上重新做 schema/privacy
扫描，并记录 `allow/deny/blocked` 结果；在此之前，本次隐私结论仅为 bounded。

#### ARCH-R03-P3-02：恢复证明未覆盖恢复后的用户可见冒烟

恢复包的安装序列和 hash 已记录，且没有做破坏性清理；这证明了“诊断包被替换回普通包”。
但材料没有报告恢复后再次打开 Reminders/键盘并完成最小输入的可见冒烟，因此不能把恢复
动作扩大为“设备用户体验已完全恢复”。

**处置：** 若继续使用同一设备开展后续授权工作，在不清除用户数据的前提下补一条最小
`open → keyboard visible → one benign key → close` 人工观察；若不再使用该设备，保留当前
恢复安装证据并明确该残余未验证即可。

## 4. 隐私、恢复与治理检查

- **隐私：** 当前文档、Run ID、marker 摘要和附件 hash 没有原始拼音、候选词、Reminders 文本、
  user dictionary、凭据或截图；这符合 ADR 0010 与 P3-D1 content-free contract。由于附件
  validator 未重跑，结论是 bounded privacy closure，而不是完整附件合规证明。
- **设备恢复：** 普通同源包已安装，未执行 App Group wipe、RIME/userdb reset、卸载或提醒事项
  清理；恢复行为符合本 assignment 的非破坏边界。
- **架构边界：** `T9RESP path=sync` 与 ADR 0004 一致；没有真实 RIME off-main 接线、
  `@unchecked Sendable`、默认 gate 变更或并发 session。ADR 0025 继续 `Proposed`。
- **矩阵边界：** R03 只可留在 `Partial — gate-off baseline captured`；不能升级为 R01/R02、
  T02/T03、R04–R06，也不能从一次真机观察推导 Product Gate、Release、jetsam 或用户 SLO。

## 5. 已证实与未证实

### 已证实（bounded）

1. iPhone 13 Pro 真机、指定 iOS 27.0、指定 Run ID 和构建/设备 provenance 可追溯。
2. 本次 run 走的是 gate-off 的同步路径，39 个人工事件连续，session/geometry marker 稳定。
3. Human 没有报告漏键、重复、候选消失或键盘退出，但报告了主观卡顿。
4. RIME/processKey 慢峰与 total 慢峰同向，足以确定下一阶段优先验证同步 RIME 热路径。
5. 诊断包已恢复为不含 preflight 注入的同源普通包，且没有越界清理用户数据。

### 未证实

1. off-main/thread-affine owner 能否在真实 librime、Keyboard Extension 和同一设备上降低主观卡顿。
2. A/B 同源对照、queue depth/epoch/revision 的 target runtime 语义，以及真实 publish/apply 顺序。
3. 该现象是否完全由 RIME 引起；尤其是 host text proxy、系统绘制、内存压力和 jetsam。
4. iOS 26.0、Release RC、App Store、Product Gate 或任何用户可见性能 SLO。

## 6. 下一步授权建议（不自动执行）

建议 Product Lead 仅在接受上述 P2/P3 条件后，另行授权 **P3-D1-R01/R02 或
T9-RESPONSIVE-PIPELINE-001 / Spike-P1-3 的真实 RIME 可证伪验证**：先以 gate-off 同源 A 为
基线，再以显式 Debug/内部 B 运行 controlled Fake 或受 Architecture 审查的真实 owner，要求
MainActor accept 在人为 150 ms+ owner 阻塞期间仍可返回，并用 Sendable 快照、sessionEpoch 与
revision 做 fail-closed apply。该授权不应包含 Release default-on、ADR 0025 Accept、Product
Gate 或 R5 真机 A/B。

在获得新授权前，保留当前同步路径和 `Partial` 状态，不修改生产逻辑。

## 7. 停止声明

独立 Architecture 复审已完成；本文件是 evidence-layer review，不是 Product 决策、Quality
复审或 Release 认证。后续由独立 Quality 复审及 Product Lead 决定是否开启下一步验证；本角色
到此停止。
