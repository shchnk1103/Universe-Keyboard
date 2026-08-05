# Evidence Contract: T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02

| 字段 | 值 |
|---|---|
| Contract ID | `T9-RESPONSIVE-PIPELINE-001/P2-PERF-02/EVIDENCE-01` |
| Status | **Proposed — Product-authorized diagnostic contract** |
| Date | 2026-08-01（Asia/Shanghai） |
| Parent Assignment | [`P2-PERF-02`](t9-responsive-pipeline-001-p2-perf-02-release-like.md) |
| Related ADR | [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)，仍为 `Proposed` |
| Review gate | 独立 Architecture 与 Quality 复审；本文件不自行批准任何 gate |

## 1. 目的与第一性原理

本合同回答一个可复核的问题：在同一来源、同一设备和同一人工输入条件下，
显式 thread-affine B 臂是否确实先接受输入并提供 provisional 反馈，同时没有
丢键、重复、乱序、意外 commit 或键盘退出。

取证必须把四件事分开：

1. **运行时事实**：扩展实际走了哪条路径、每个事件何时被接受、RIME/UI 各阶段耗时；
2. **运行身份**：这组日志属于哪个源码、构建、设备、schema、权限和 run；
3. **人工结果**：用户是否观察到漏键、重复、候选消失、退出和主观卡顿；
4. **生命周期恢复**：测试后是否回到普通 gate-off 包，且恢复身份可复核。

缺少任一必需层时，结果只能是 `Partial`；不得用 `0`、`false`、旧 run 或推测
替代缺失值。身份不匹配、隐私泄漏或无法确认 gate 时，结果为 `Blocked`。

## 2. 范围与硬边界

### 2.1 本合同覆盖

- `Release` 优化配置下的内部诊断 A/B；
- A：`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`，responsive gate off；
- B：`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` +
  `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`，显式 thread-affine；
- iPhone 13 Pro 上由 Human 使用 software keyboard 手动输入 39 个九宫格字母键；
- 只保留 content-free runtime markers、外部 Run Header、Pair Manifest 和人工报告。

### 2.2 本合同不授权

- 修改默认 gate、RIME/Lua、用户设置或生产输入语义；
- 接受 ADR 0025、宣布 Spike/Product Gate/R6/Release 通过或开启 Release default-on；
- 使用坐标自动化、Computer Use、Path/candidate/numeric-page 点击或合成输入；
- 丢弃、合并、重排用户事件；
- 以本合同替代真实 Release、多设备、jetsam、App Store 或 Product Gate 验证。

本次合同只补齐取证判定，不改变产品路径。任何为满足合同而需要的运行时诊断接线，
必须另行授权并保持默认关闭。

## 3. 固定测试对象

| 项目 | 合同值 |
|---|---|
| Fixture ID | `T9-RESP-PERF-39-V1` |
| Fixture digest | `772b4bb30cb831d04550e8311a2f64e66aad4ab55c4597544f0cc9364f9d7286` |
| Action count | `39` |
| 输入方式 | Human 手动点击可见九宫格字母组；不显示或点击数字键 |
| 选择行为 | 不点击 Path、候选、空格、commit、Delete 或数字页 |
| 运行单位 | 每个 arm 一个新 `runID`、一个 opaque `runToken`；A/B 组成一个 `pairID` |

fixture 的原始拼音只存在于 Human 操作说明和受控测试记录中；runtime log、导出、
summary、截图和 UI hierarchy 不得重复原文或候选/宿主文本。

## 4. 证据包结构

每个 `pairID` 必须产生以下内容；文件名和 digest 写入 Pair Manifest：

```text
pair-manifest.json
A/run-header.json
A/runtime-content-free.log
A/runtime-content-free.sha256
A/validator-summary.json
B/run-header.json
B/runtime-content-free.log
B/runtime-content-free.sha256
B/validator-summary.json
human-report.json
restore.json
privacy-scan.txt
```

原始 `.xcresult`、设备诊断压缩包、截图、UI hierarchy 或包含用户文本的附件可以
留在受控临时目录供隐私检查，但不得复制进仓库 evidence；仓库只保留 content-free
子集及其 digest。导出必须使用 **all-category evidence export**，不能只导出
`[PERF]`，否则会漏掉 engine-category 的 `T9RESP PATH/READY`。

## 5. Run Header 合同

`A/run-header.json` 和 `B/run-header.json` 各自必须包含以下字段。值不可得时写
`unavailable` 并给出原因；不得伪造或从另一个 arm 继承。

| 字段 | 必填内容 | 取证来源/判定 |
|---|---|---|
| `contractID` / `contractVersion` | 本合同 ID 与版本 | 必须精确匹配；版本变更需新 Pair |
| `pairID` / `runID` / `arm` | A 或 B、opaque ID | token 只允许 ASCII canonical 形式；A/B 不得共用 runID |
| `source` | commit、worktree fingerprint、dirty-state | 同一 pair 必须一致；未记录则 Pair `Partial` |
| `build` | configuration、SDK、deployment target、Xcode/toolchain、签名身份 | 由构建产物/命令回读，不凭口述 |
| `flags` | 全量注入条件与默认值扫描 | A 不得含 responsive enabled；B 必须明确显式 flag；两臂均不得含任何 auto-anchor `*_ENABLED` |
| `bundle` | App/Extension bundle ID、版本、App SHA-256、Extension SHA-256 | 安装前产物 hash 与设备上安装身份都要能对应 |
| `device` | model、UDID、OS product/build、连接/解锁状态 | 同一 pair 必须同一设备与 OS；minor/build 不得只写“iOS 27” |
| `host` | opaque disposable-list ID、空编辑器、portrait、software keyboard、中文九宫格 | 不记录提醒事项文本或宿主内容 |
| `runtime` | schema/runtime fingerprint、部署 readiness、Full Access | 用 observed/unavailable/contradicted 三态；不得把未观察写成 ready |
| `fixture` | Fixture ID、digest、39 actions、cadence/人工节奏说明 | 只写 digest 与 case ID 到 runtime；原始输入不进日志 |
| `time` | start/end、timezone、日志窗口 | A/B 每臂独立，不能把附件时间当作运行时间猜测 |
| `artifacts` | 日志路径、字节数、SHA-256、privacy scan 结果 | reviewer 可对 digest 重算 |
| `humanReportRef` | 对应 `human-report.json` | 不把定性“流畅”转换为数字 |
| `restoreRef` | 对应 `restore.json` | 必须记录普通 gate-off 安装身份与 cleanup 结果 |

### 5.1 Build flag 与路径期望

| Arm | 编译条件 | 运行时期望 | 解释 |
|---|---|---|---|
| A | `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` | gate-off measurement marker；若 Release 没有 DEBUG-only sync PATH，须以静态扫描 + 负 flag 证明路径 | `T9DEVICE gate=off` 只指 auto-anchor measurement gate |
| B | A 的全部条件 + `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` | 必须有 `T9RESP marker=PATH path=thread-affine` 与 `T9RESP marker=READY` | 仅表示显式内部 arm，不是生产默认 |

`T9DEVICE gate=off`、responsive B gate 和 auto-anchor enabled gate 是三个不同概念，
Pair Manifest 必须分别列出，不能合并成一个 `gate` 字段。

## 6. Runtime content-free 合同

### 6.1 必须保留的 marker

| Marker | 必填字段/不变量 | 缺失时 |
|---|---|---|
| `T9DEVICE` | `schema=v1`、run token、measurement、auto-anchor gate identity | arm 身份不成立，`Partial` 或 `Blocked` |
| `T9RESP PATH` | `schema=v1`、run、path、fixture、dualGateRequested/Active | B 缺失或 schema 不匹配为 `Partial`；A 可由静态扫描补 path，但必须显式标 `runtimePathMarker=unavailable` |
| `T9RESP READY` | `schema=v1`、run、fixture、`bootstrap=config-only`、`session=owner-thread` | B 缺失或 schema 不匹配为 `Partial` |
| `T9RESP FALLBACK` | 仅在回退发生时；reason 只能是 enum-like token | 出现时按实际 path 分类，不得继续写 B active |
| `T9GEOM prepared/execution` | `schema=v1`、同一 run token、同一 digest、portrait screen-space、orientation、screen/keyboard envelope 与 8 个 slot；不保留 raw text | execution `invalid/unavailable` 为 `Partial` |
| `T9SEG` | action/event、长度/计数、commit、stage timings、session snapshot、同一 token | 缺行、重复、乱序或 token 不同为 `Partial`；不得补零 |
| `SLOW RIME` | 仅 API/collect 等时长与 content-free ordinal | 只作慢调用观察，不推导用户 SLO |
| `T9RESP ACCEPT` | `schema=v1`、epoch/revision/action、pending、fixture | MainActor 已接受/入队该 revision；必须早于相同 revision 的 owner completion；accepted revision 必须形成声明区间 |
| `T9RESP PUBLISH` | `schema=v1`、epoch/revision、fixture | **Owner completion**：串行 owner 已完成并交付该 revision；thread-affine 每个 accepted revision 都要有 epoch-bound publish；它不承诺 UI 已逐 revision 绘制 |
| `T9RESP VISIBLE` | `schema=v1`、source、revision、lag、fixture | MainActor 实际应用可见 composition snapshot；provisional 可早于 owner publish，engine VISIBLE 可因 coalescing 只出现最新结果 |
| `T9RESP PAINT` | `schema=v1`、revision、lag、pendingAfter、coalesced、fixture | 补充 UI 展示耗时；允许 latest-only coalescing；不能替代 owner-completion PUBLISH |

### 6.2 `T9ARM` 语义冻结

当前 `T9ARM actions=38` 是旧 S6-A `HotPathSegmentTiming` 的第 38 个 action checkpoint，
不是 P2 的 39-action final summary。P2 validator：

- 不把 `T9ARM actions=38` 当作 P2 完成证明；
- 不把它改写成 `actions=39`；
- 以 `T9SEG event/action=1…39` 计算 P2 retained count；
- 最终闭合结果写入外部 `validator-summary.json`，不在按键热路径中新增阻塞式 summary。

这样既保留历史 S6-A 兼容性，也避免让旧 marker 与新 39-key 手动 fixture 发生语义冲突。

### 6.3 Session 合同

`T9SEG.sessionBefore/After` 必须来自 native RIME session snapshot：

- `identity != 0`；
- `valid=true`；
- 同一 arm 内跨 39 个 action 保持稳定；
- `sessionEpoch` 不能替代 native session identity；
- MainActor 不得同步访问 owner-thread engine；snapshot 必须由 owner 线程捕获后以
  Sendable value 传回。

当前 B 证据的 `session=0/valid=false` 必须保持为 `unavailable/invalid`，不能写成通过。

### 6.4 Geometry 合同

Geometry 是键盘 UI envelope 的内容无关证明，不是允许自动化点击的授权。prepared 与
execution 必须：

- 使用同一 run token；
- digest 相同；
- 记录 portrait screen-space、scale、keyboard envelope 和 8 个 letter-group slot；
- 不包含截图、文字、候选或宿主内容。

手动输入仍然只能由 Human 完成。若 extension UI reload 使 execution geometry 丢失，
validator 输出 `geometry=unavailable`，结果为 `Partial`。

## 7. 顺序、完整性与隐私不变量

Validator 必须逐 arm 执行下列检查：

1. 只接受一个 canonical run token；所有同 arm marker 绑定同一 token；
2. `T9SEG` 的 `event` 形成连续闭区间 `1…39`，action/event 关系按记录解释，不能静默修正；
3. `committed=false` 且外部 human report 没有意外 commit；出现 commit 立即标记；
4. `ACCEPT →（可选 provisional VISIBLE）→ owner PUBLISH →（可选 engine VISIBLE/PAINT）` 顺序成立，epoch/revision 单调；
5. session、geometry、PATH/READY 任何必填项缺失都显式出现在 summary；
6. 日志扫描拒绝 raw pinyin、candidate、host text、user dictionary、截图和 UI hierarchy；
7. 人工输入报告与日志 action count 不一致时，按较严格结果判 `Partial`，不猜测漏在哪一键；
8. A/B 只有在 source/device/OS/schema/Full Access/host/fixture 一致且各自 arm 完整时，
   才能作“方向性比较”；任何一臂 `Partial` 都只能报告“观察到的方向”，不能写 A/B Pass。

### 7.1 P2-D1 契约决策（2026-08-02）

Human Product Owner 已授权并冻结本次诊断契约的最小语义拆分：

```text
ACCEPT  → owner 完成并交付 → PUBLISH → MainActor 应用 → VISIBLE
                                      └→ PAINT（展示耗时，可 coalesce）
```

- `PUBLISH` 是 owner completion，不再承载 `lagMs/pendingAfter/coalesced` UI 字段；
- `VISIBLE` 是 MainActor 的可见 composition snapshot 应用；latest-only 允许中间 revision
  没有单独的 VISIBLE；
- `PAINT` 只记录 UI 展示耗时和 coalescing，不可替代 PUBLISH；
- `sync` arm 的 validator 只校验 gate-off 的 T9SEG/session/geometry/path 事实，不要求
  responsive `ACCEPT/PUBLISH`；
- `candidates=<非负整数>` 是 content-free 数量摘要，候选文本和 malformed value 继续
  fail-closed。

该段是 P2-D1 的 Proposed evidence/architecture amendment；不接受 ADR 0025，不改变默认
gate 或生产输入路径。执行记录见 [`P2-D1 Marker Contract`](t9-responsive-pipeline-001-p2-d1-marker-contract.md)。

## 8. Human Report 合同

`human-report.json` 只记录以下内容：

| 字段 | 要求 |
|---|---|
| `pairID` / `arm` | 与 Run Header 一致 |
| `inputMethod` | `manual-software-keyboard` |
| `integrity` | `missingKeys`、`duplicateKeys`、`candidateDisappeared`、`keyboardExited`，每项 `yes/no/unknown` |
| `stallScore` | 0–4；必须由 Human 明确给出，不能由“流畅/卡顿”自动映射 |
| `stallNotes` | 只写主观位置/阶段，不写宿主文本或候选内容 |
| `orderedOutcome` | 是否按声明顺序完成，或停止原因 enum |

没有数值评分时写 `unavailable`，不默认为 0。人工报告不能覆盖 runtime 的 session、
geometry 或 path 缺口。

## 9. Restore 合同

`restore.json` 必须包含：

- B 包替换回普通 gate-off 包的时间、命令结果摘要和 App/Extension hash；
- preflight envelope 的 cleanup 状态（只清理本次 token）；
- 未执行 uninstall、container wipe、RIME/userdb reset 或提醒事项数据删除的声明；
- 恢复后 keyboard-switch smoke check 的 observed/unavailable 状态。

恢复身份缺失不把测试臂判为失败，但会使整个 Pair 保持 `Partial`，直到身份可复核。

## 10. 判定枚举

| 结果 | 允许的结论 |
|---|---|
| `Complete` | 该 arm 的合同字段、runtime 不变量、隐私扫描和 Human 报告全部齐全；Pair 仍需 A/B 同源后才能比较 |
| `Partial` | 有可用 bounded runtime 观察，但至少一项必填证据缺失/无效；只能报告已观察事实 |
| `Blocked` | wrong device/build/flag/token、隐私泄漏、无法确认路径，或需要越权/破坏性操作 |
| `NotRun` | 没有开始输入或没有可审计 runtime 记录 |

不得将 `Partial` 自动升级为 `Complete`，也不得把 `Complete` 自动升级为 ADR、Product
Gate、Release 或默认开启。

## 11. 当前 B 证据套用结果（基线）

当前 [`P2-PERF-02 B evidence`](../evidence/t9-responsive-pipeline-p2-perf-02-b-2026-08-01.md)
按本合同的结果仍是 **Partial**，原因全部保留，不做补值：

- 正向：39 条 `T9SEG` 声明、合法 token、B thread-affine-only publish 旁证、5 条
  `SLOW RIME`、Human 未见漏键/重复/候选消失/键盘退出；
- 缺口：B 的 PATH/READY 未进入导出、session=0/invalid、execution geometry invalid、
  A 臂缺失、source/worktree/schema/Full Access/restore identity 不完整、Human 0–4 分缺失；
- `T9ARM actions=38` 按本合同解释为历史 checkpoint，不作为 39-action summary。

因此本合同不会把现有记录改写成“通过”，也不会改变 ADR、gate 或 Release 边界。

## 12. 后续实现与复审边界

若要让未来运行达到 `Complete`，需要另行授权的诊断接线/测试至少包括：

1. all-category evidence export 纳入 `T9RESP PATH/READY`；
2. owner 线程捕获 native session snapshot，并以 Sendable 快照返回；禁止
   `@unchecked Sendable` 或从 MainActor 触碰 engine；
3. 让 prepared/execution geometry context 在 extension UI reload 后仍可验证，或明确
   输出 `unavailable`；
4. 新增纯函数 validator 与回归测试，覆盖 token、39 行连续性、旧 `T9ARM` checkpoint、
   path/readiness、session、geometry、顺序、隐私扫描、Partial/Blocked 分类；
5. 补齐 A arm、同源 Pair Manifest、Human 0–4 score 和 restore identity。

其中前四项已在独立的 Evidence Enforcement 子 Assignment 中落地为诊断基础设施与纯
函数回归测试，但这只证明“代码和测试具备合同检查能力”，不把任何历史真机证据补成
`Complete`。第 5 项以及真实设备重跑仍未完成，所有结果必须重新交给独立 Architecture
与 Quality 复审。本合同自身不接受 ADR 0025，不创建 Product Gate，也不授权生产接线。

## 13. Evidence Enforcement 实现快照

实现子 Assignment：[`P2-PERF-02 Evidence Enforcement`](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement.md)。

- 导出 allow-list 已保留 `T9RESP PATH/READY` 与 `SLOW RIME`，并由 KeyboardCore
  回归测试锁定；隐私扫描仍由 validator 独立执行。
- thread-affine owner 在 owner thread 捕获 `RimeSessionDiagnosticSnapshot`，只以
  `Sendable` value snapshot 返回；MainActor 不接触 live engine。
- execution geometry 在首个完整可见 T9 layout 后才记录；不可用时保持明确的
  `unavailable`，不会把 `run=invalid` 当成有效 digest。
- validator 输出 `Complete` / `Partial` / `Blocked` / `NotRun`，不会修改现有
  B evidence，也不会在按键热路径同步生成 summary。
- Evidence Enforcement 阶段的历史基线仍保留为 validator 9/0、ThreadAffine wire 8/0、
  Spike 10/0、KeyboardCore 全量 871/0；后续 hardening 的独立结果记录在
  [`Evidence Hardening`](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening.md)
  的 implementation handoff 中，不覆盖这条历史记录。
- 未验证：真实 librime 长句、真机重跑、jetsam/内存、iOS 26.0 RC、Product Gate；
  因此当前合同状态仍是 Proposed，历史 B 仍是 Partial。

## 14. Handoff

本合同的下一交接材料：

- 合同文件与 parent Assignment 的链接；
- 当前 B partial evidence 与两份独立 review；
- 一份明确列出 `Complete/Partial/Blocked` 字段的 validator 设计/测试结果；
- 未执行的真实 librime、jetsam、iOS 26.0 Release RC、跨设备和 Product Gate 检查。

## 15. Independent review reconciliation

本合同已完成独立 Architecture 与 Quality bounded review：

- [`Evidence Enforcement Architecture review`](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement-architecture-review.md)：
  P0/P1/P2/P3 = **0/0/6/1**；Bounded Pass with conditions。
- [`Evidence Enforcement Quality review`](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement-quality-review.md)：
  P0/P1/P2/P3 = **0/0/6/1**；Pass with conditions。

两份复审都确认本合同仍为 `Proposed`，历史 B 仍为 `Partial`。Product Lead 已建立并
授权 [`Evidence Hardening`](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening.md)，
其中冻结了 mandatory PATH/READY persistence、run-bound schema、geometry retry 终态和
owner readiness 语义；Hardening 的独立 Architecture / Quality 复审已完成，但这些
bounded 代码证据不改变合同的 `Proposed` 状态，也不能替代设备/Release 运行证据。

已复审的下一 Assignment：[`P2-PERF-02 Evidence Hardening`](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening.md)。

### P2-D1 marker contract reconciliation (2026-08-02)

子件 [`P2-D1 Marker Contract`](t9-responsive-pipeline-001-p2-d1-marker-contract.md)
已冻结 `ACCEPT → PUBLISH → VISIBLE/PAINT` 的职责边界，并完成独立 Architecture 与
Quality 复审；两份复审均为 **Pass with conditions**。当前证据为：validator **28/0**、
felt metrics **5/0**、KeyboardCore 全量 **894/0**，另有普通与 preflight 宏条件下的
Swift 6 全源 type-check 通过。

该子件关闭了 duplicate owner publish、engine-before-publish、epoch rollback validator
和 epoch 变化后的 revision reuse 回归；真实 runtime reset/recover/late-result、真实
librime、真机、Release、jetsam 与 App Group persistence 仍未执行。它只完善诊断合同，
不把历史 B evidence 从 `Partial` 改写为 `Complete`，也不改变本合同 `Proposed`、ADR 0025、
默认 gate 或 Product Gate 状态。

后续证据层由 [`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md)
单独管理；其 Core、target、real-RIME、physical/persistence/jetsam 行必须分层判定，不能
用 KeyboardCore XCTest 代替 Extension 或真机运行证据。

合同字段、runtime schema 或判定语义任何变化，都必须生成新版本并重新复审，不能覆盖
既有 evidence。
