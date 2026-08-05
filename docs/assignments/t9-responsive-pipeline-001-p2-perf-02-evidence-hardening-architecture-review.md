# 独立 Architecture 复审：T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02 Evidence Hardening（pre-fix 基线 + post-fix 复审）

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立、只读） |
| 复审日期 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | [`P2-PERF-02 Evidence Hardening`](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening.md) 及其 implementation allow-list |
| 复审基线 | 当前 worktree tip `3585a54`；工作树含其他任务的 ambient 改动，本复审不归因、不覆盖 |
| 复审方法 | 代码/测试/Assignment 静态检查；独立复核 release-like generic artifact 的 hash 与 marker strings；不修改生产逻辑、不接受 ADR、不形成 Product Gate |
| Architecture 结论 | **Bounded Pass with conditions**：P2-EE-01～04 在 bounded code/artifact 层面可关闭；P2-EE-05～06 仍开放，Evidence Hardening 不得标为 `Complete` |
| P0 / P1 / P2 / P3 | **0 / 0 / 2 / 2** |
| 治理结论 | ADR 0025 仍为 `Proposed`；默认 gate-off；未授权真实 librime 生产接线、真机/R5、Release/Product Gate |
| **最新 post-fix Architecture 结论** | **Bounded Pass with conditions**：P2-EE-05 已在 validator/schema 与专项回归的 bounded 范围内关闭；P2-EE-06 仍开放，不能据此宣布 Evidence Hardening、ADR 或 Product Gate 完成 |
| **最新 P0 / P1 / P2 / P3** | **0 / 0 / 1 / 3**（P2-H-06；P3-H-08～P3-H-10） |
| **最新 final-v4 Architecture 结论** | **Bounded Pass with conditions**：P2-POST-01（run-bound felt markers）已在显式 preflight 的代码/schema/test/artifact 范围内关闭；仍只保留真实运行环境 P2-H-06 与两个 P3 边界 |
| **最新 final-v4 P0 / P1 / P2 / P3** | **0 / 0 / 1 / 2**（P2-H-06；P3-H-08～P3-H-09；P3-H-10 的指定 felt marker 部分已关闭） |

> 本文 §1～§5 保留首次（pre-fix）独立复审的原始结论；以下 §6 为最新 tip 的 post-fix
> 独立复审，并在同一职责边界内 supersede P2-EE-05 的旧判定。没有任何生产逻辑、测试、
> ADR 或 Product Gate 状态因本复审自动改变。

## 1. 独立复审范围与证据边界

本次只读复审检查了：

1. [`Evidence Hardening Assignment`](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening.md) 的 frozen decisions、exit criteria、changed-file allow-list 与 non-goals；
2. `KeyboardViewController+Bootstrap` 的显式 preflight PATH/READY/fallback 接线；
3. `ResponsiveRimePreflight` 的 run/fixture/gate/bootstrap/session marker schema；
4. `ThreadAffineRimeSession` / `ThreadAffineRimeSpike` 的 owner readiness timeout、engine 线程亲和与 Sendable snapshot；
5. `T9ResponsiveEvidenceValidator` 及其 focused tests 的 run binding、geometry、revision/epoch、字段完整性和 fail-closed 规则；
6. `ADR 0025` 的 Proposed/default-off 边界，以及 hardening allow-list 外的 ambient changes 是否被错误归因。

作为提供的验证快照，复核者记录了：KeyboardCore `879/0`、validator `15/0`、ResponsiveRimePreflight `6/0`、ThreadAffine wire `9/0`。本次没有冒充重新执行这些测试；它们是 Executor 绑定到该 tip 的结果。`git diff --check` 通过，Assignment 中列出的相关文档链接存在。

独立复核的 generic unsigned Release artifact 为：

- app executable SHA-256：`02c9ee5d6adbf7fa7da12fe11a1bbbdf1c28e1751619eb2171df9dd56ea16716`；
- `Keyboard.appex` SHA-256：`29aa5217b8033cc81f689667169f01dc9258e0eee8d0a9e55a87dcaa167af881`；
- `strings` 命中 `T9ResponsiveEvidenceValidator`、`T9DEVICE_DISABLED`、`T9GEOM phase=execution`、`T9RESP marker=PATH`、`READY`、`NOT_READY`。

上述 artifact 只证明条件编译代码进入了该 generic unsigned build；它不证明已安装、真实 librime、设备日志持久化或 Release 签名/RC 行为。

## 2. P2-EE-01～06 接受矩阵

| 项目 | Architecture 判定 | 已检查到的实现/证据 | 仍未闭合的边界 |
|---|---|---|---|
| P2-EE-01 mandatory PATH/READY 与普通路径无副作用 | **Bounded Closed** | 显式 preflight 通过 `devicePreflightPerformance`/flush 持久化 content-free marker；普通 Debug/Release 仍走原有 engine logger，Release 默认不编译该路径 | 未在真实扩展运行中证明 logger、flush 与导出不会丢行；`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` 与 responsive diagnostic flag 的配对关系应继续保持显式 |
| P2-EE-02 run-bound fixture/gate/bootstrap/owner schema | **Bounded Closed** | PATH/READY 带 run token、`T9RESP-R5P`、dual-gate 状态及 `config-only`/`owner-thread`；validator 对 expected run/fixture/schema 做 fail-closed 检查；现有 focused tests 覆盖缺失/混 run | 当前 ACCEPT/VISIBLE/PUBLISH marker 尚未完全按同一 run-bound schema 检查，见 P2-EE-05 |
| P2-EE-03 geometry digest 唯一性与 unavailable→success 终态 | **Bounded Closed** | digest 需 64 位小写 hex；prepared/execution 成功 digest 比对；同一 phase 多 digest、非法 digest 会失败；没有有效 execution 时才报告 unavailable，后续成功可恢复为 Complete | `space`/`orientation`/status-digest 一致性尚未完全验证，见 P3-H-07；设备 reload/retry 时序仍未实证 |
| P2-EE-04 owner readiness timeout fail-closed | **Bounded Closed** | owner readiness 有明确 timeout；超时不报 READY，输出 `NOT_READY`/fallback；coordinator 暴露 `isOwnerReady`；focused wire test 覆盖超时 | 真实 librime 初始化超时、扩展生命周期与 jetsam 未验证，见 P2-EE-06 |
| P2-EE-05 epoch/revision/字段完整性 validator | **Open — P2-H-05** | validator 已拒绝部分 malformed revision/epoch、revision 回退、action/event mismatch，并要求至少一个 epoch-bound publish | VISIBLE marker 被完全忽略；后续 PUBLISH 可缺 epoch；只要求“任一”PUBLISH 带 epoch；ACCEPT/PUBLISH 的 fixture/action/pending/source 等字段、正数与重复/覆盖关系未完整校验，见 §3.1 |
| P2-EE-06 默认 gate-off/Swift 6 隔离及最终运行证据 | **Open — P2-H-06** | gate 默认 off；engine 只在 owner 线程创建/调用/释放；跨隔离域为值 snapshot，未发现 `@unchecked Sendable`；generic unsigned artifact/hash/strings 已复核 | 没有真机安装/运行、真实 librime、设备诊断日志导出、Extension jetsam/memory、最终签名 Release/iOS 26.0 RC 证据；不能由 generic build 宣布实际 off-main 收益或 Product Gate |

因此，P2-EE-01～04 的“Closed”仅表示实现与静态/专项证据边界内闭合，不等同于设备验收；P2-EE-05～06 必须保持 Open。

## 3. Architecture 残余

### 3.1 P2-H-05：validator 没有把完整的发布链合同变成强约束

当前 `T9ResponsiveEvidenceValidator` 对 ACCEPT/PUBLISH 做了有价值的最小检查：revision 可解析且不回退，epoch 若出现则必须与已接受 epoch 一致，且 thread-affine 期望至少看到一次 epoch-bound publish。但这不足以证明每个 revision 的发布链是完整、同 run、同 epoch 的：

- `VISIBLE` marker 没有被解析或计入任何完整性判定；
- 只要存在一个带 epoch 的 PUBLISH，后续 PUBLISH 缺 epoch 仍可能通过；
- ACCEPT 没有验证生产 marker 中的 `fixture`、`action`、`pending` 等字段；
- PUBLISH 没有验证 `fixture`、`source` 等字段，也没有统一要求 epoch；
- 没有正数/范围、重复 revision、revision 覆盖连续性和“每个接受 revision 都有合规 publish”的强约束；
- focused `completeLines()` 本身省略了生产 marker 的部分字段，因而没有把字段完整性锁成回归合同。

这不是 P0/P1 安全越界，但它会使一份缺字段、缺 epoch 或跨 revision 的证据被误判为 Complete。建议后续仅针对 P2-EE-05 补充版本化 schema、每 revision 的 epoch/source/fixture 约束及 focused negative tests；在该修复独立复审前，不得提升 Evidence Hardening 状态。

### 3.2 P2-H-06：运行时与最终 Release 证据仍未形成闭环

线程亲和形状在静态上是合理的：`RimeEngine` 留在 owner loop，MainActor 只接收 Sendable 值快照；超时路径不制造 READY；没有用 `@unchecked Sendable` 把 live engine 假装跨隔离传递。可是 generic unsigned build、hash 和 strings 扫描不能回答以下问题：

- iPhone 13 Pro 或其他授权设备是否真实安装并运行该 tip；
- 真实 librime session 是否成功在 owner 线程初始化、长期保持亲和；
- mandatory PATH/READY/NOT_READY 是否真的写入并可导出，是否与同 run 的 T9SEG/T9GEOM 配对；
- Extension 生命周期压力、jetsam、memory/队列深度、reload/retry 时序是否保持 fail-closed；
- 最终签名 Release、iOS 26.0 RC 与 Product Gate 是否满足各自证据要求。

这些是未执行验证，不是本次 Architecture 角色可以自行扩大的工作范围。

### 3.3 P3-H-07：geometry 辅助 schema 仍可加强

validator 已对 digest 形状、phase、多 digest 和 unavailable→success 终态做了硬化，但目前没有完整拒绝 `space`/`orientation` 缺失或错误，也没有完全约束 `status=unavailable` 与 digest 是否互相一致。建议补充 schema negative tests，并保持没有有效 execution 时才为 Partial 的终态规则。

### 3.4 P3-H-08：allow-list 的 substring 形状边界

诊断 line filter 仍以 marker substring 作为轻量保留规则，合法性主要由后置 validator 负责。它适合 content-free 导出，但不能单独宣称“只剩合法 marker”。建议补充 malformed ASCII/marker-shape 负样本，并在文档中继续明确 filter 与 validator 的职责分离。当前不足不构成 P1，因为 privacy/marker validator 仍是独立的 fail-closed 步骤。

## 4. 已证明与未证明

### 已证明（bounded）

- 显式 preflight 的 PATH/READY/NOT_READY 走受控 mandatory persistence；普通路径未被硬化逻辑同步阻塞或改写；
- PATH/READY schema 具备 run、fixture、gate、bootstrap、owner-thread 绑定；
- geometry digest 的非法、多值及 transient unavailable→success 处理符合 frozen decision 的主要方向；
- owner timeout 会 fail-closed，不制造虚假 READY；
- engine 的专用 owner 线程与值 snapshot 隔离形状符合 Swift 6 约束，未使用 `@unchecked Sendable`；
- default gate 仍 off，ADR 0025 仍 Proposed；generic unsigned artifact/hash/strings 与 Assignment 快照一致。

### 未证明（必须保留在后续清单）

- 真机/扩展运行、真实 librime、真实 PATH/READY 日志持久化与导出；
- Extension jetsam、memory、队列深度、reload/retry 与生命周期压力；
- 最终签名 Release、iOS 26.0 RC、R5 人工 A/B 与 Product Gate；
- P2-EE-05 所需的完整 ACCEPT→VISIBLE→PUBLISH 字段、epoch/revision 合同。

## 5. Quality 交接与停止点

可以交给独立 Quality 做 bounded review，但不能把本复审写成 Evidence Hardening `Complete` 或 off-main 生产收益证明。Quality 应优先复核 P2-H-05 的 validator/schema 修复及 focused regression，再决定是否重新检查 artifact；真实设备、真实 librime、jetsam/memory 与最终 Release 证据需另行授权和单独矩阵。

本 Architecture 角色在此停止：不修改生产逻辑、测试或 ADR，不接受 ADR 0025，不开启任何 Release 默认 flag，不形成 Product Gate/R5 结论。

## 6. Post-fix Architecture 独立复审（最新 tip）

### 6.1 复审输入与独立核对

本节针对 P2-EE-05 修复后的最新 hardening tip 重新检查，且不依赖本文件 §2～§5 的旧
pre-fix 结论：

- 重新读取最新 [`Evidence Hardening Assignment`](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening.md)、allow-list 及其变更文件；
- 静态检查 `T9ResponsiveEvidenceValidator`、`ResponsiveRimePreflight`、
  `ResponsiveRimeFeltMetrics`、owner/session isolation 与 focused tests；
- Executor 提供的最新回归快照：validator `20/0`、preflight `6/0`、felt `3/0`、
  ThreadAffine wire `9/0`，合计 `38/0`；KeyboardCore 全量 `884/0`。这些数字绑定
  最新 tip，但本次不冒充重新执行全量测试；
- 独立重算 generic unsigned Release-like artifact：app
  `dec3b1f830e0432d43d15e17da50b4eeb5698f98c3fdb7320e1178320b07cda4`，
  `Keyboard.appex`
  `c7ec16f00d13f03355da95137e0cf22109eaa8870812be905cd45f74f06ba73d`；
- 独立 `strings` 扫描命中 `schema=v1`、`T9RESP marker=PATH/READY/NOT_READY/FALLBACK`、
  felt `VISIBLE/PUBLISH`、`T9DEVICE_DISABLED`、`T9GEOM phase=execution` 与
  `T9ResponsiveEvidenceValidator`；`git diff --check` 通过，相关 Assignment/ADR 链接存在。

artifact 位于 `/private/tmp/universe-keyboard-p2-evidence-hardening-final-v2-derived`，
仍是 `CODE_SIGNING_ALLOWED=NO` 的 generic iOS 构建。hash 与 marker 字符串只能证明该
条件编译内容进入构建产物，不能证明设备安装、真实 librime 或日志持久化。

### 6.2 最新 P2-EE-01～06 判定

| 项目 | post-fix Architecture 判定 | 核对结果 |
|---|---|---|
| P2-EE-01 mandatory PATH/READY 与普通路径无副作用 | **Bounded Closed** | 显式 preflight 仍通过 mandatory `devicePreflightPerformance`/flush；普通 Debug/Release 路径未被改写，默认配置没有注入 preflight flag |
| P2-EE-02 run-bound fixture/gate/bootstrap/owner schema | **Bounded Closed** | PATH/READY 现在具有 `schema=v1`、run、fixture、gate、`config-only` 与 `owner-thread`，validator 对缺失/错误 schema 维持 fail-closed；范围仍是显式 PATH/READY 证据 |
| P2-EE-03 geometry digest 唯一性与 unavailable→success 终态 | **Bounded Closed** | digest 形状、多 digest、payload（portrait screen-space、scale、screen、keyboard、s0…s7）和 retry 终态均有 parser/negative coverage；transient unavailable 后的有效 execution 不再残留永久 Partial reason |
| P2-EE-04 owner readiness timeout fail-closed | **Bounded Closed** | timeout 返回值实际决定 `READY` vs `NOT_READY`/fallback；wire `9/0` 保持超时不报 READY；没有 unsafe engine 跨隔离传递 |
| P2-EE-05 epoch/revision/字段完整性 validator | **Bounded Closed（仅 bounded code/test 层）** | ACCEPT 要求 `schema=v1/action=k/fixture/rev>0/epoch>0/pending>=0`；VISIBLE 校验 schema/fixture/source/lag/rev 且必须对应 accepted revision；PUBLISH 支持两种明确 schema、校验 fixture/lag/epoch，并要求 thread-affine 每一个 accepted revision 都有 epoch-bound publish；focused 负样本已覆盖这些拒绝条件 |
| P2-EE-06 默认 gate-off/Swift 6 隔离及最终运行证据 | **Open — P2-H-06** | 默认 gate 仍 off，engine 仍只在 owner 线程创建/使用/释放，跨隔离域仍是值 snapshot；但没有真机/真实 librime/设备导出/Extension 压力/签名 Release 证据 |

因此，P2-EE-05 可以从 Open 提升为 **bounded Closed**；这不是对真实运行时的 Complete
判定。最新 hardening 的唯一 P2 blocker 是 P2-H-06 的环境/运行证据闭环。

### 6.3 P2-H-06：仍需环境授权的运行闭环

generic unsigned artifact、hash、strings 和 `884/0` handoff 不能替代以下证据：

- iPhone 13 Pro 或其他指定设备安装、启动、切换 software keyboard 并导出本轮
  content-free 日志；
- 真实 `RimeEngineImpl`/librime session 在 owner thread 初始化、保持亲和并返回 native
  session snapshot；
- mandatory PATH/READY/NOT_READY、同 run 的 T9SEG/T9GEOM、geometry retry 在扩展生命周期
  中真正持久化且可由 validator 解析；
- Extension jetsam、memory/queue depth、UIKit reload 与 timeout/fallback 的设备行为；
- 最终签名 Release、iOS 26.0 RC、Product Gate 或用户体验 SLO。

这些只需 Product Lead 另行授予真机/环境与最终 Release 证据权限，不应通过 Architecture
复审自行扩大为生产接线或 Gate 接受。

### 6.4 仍存在的 P3 边界

#### P3-H-08：diagnostic allow-list 仍是 substring 规则

`T9DevicePreflightEvidenceLineFilter` 仍通过 `contains("T9RESP ")` 等轻量规则保留行，
而不是先验证 marker 起始位置、版本和字段形状。后置 validator 仍是 privacy/schema
边界，因此这不会把当前合法样本提升为错误通过，但未来不能把 filter 输出本身当成已验证
证据。建议另行补 marker-shape/未知字段负样本；不影响本轮 P2-EE-05 bounded 结论。

#### P3-H-09：owner timeout 的 target-level 集成覆盖仍较窄

`ThreadAffineRimeWireTests` 和 formatter tests 已证明组件级超时与 `NOT_READY` 语义；但
没有 App/Extension target-level regression 直接断言
`installResponsiveDualGatePreflightIfArmed` 在真实 bootstrap timeout 时同时持久化 PATH、
NOT_READY/fallback、清除两个 gate，再安装同步 RIME。该缺口应在环境可用时补，当前不构成
生产默认路径 blocker。

#### P3-H-10：felt/未知 `T9RESP` marker 的 run 绑定与 fallback 终态策略尚未完全冻结

最新 schema 已覆盖 validator 处理的 ACCEPT/VISIBLE/PUBLISH 与 preflight PATH/READY；但
felt marker 生成器目前没有显式 run 字段，`requiresRunBinding` 也只把 T9DEVICE/T9GEOM/
T9SEG/T9ARM 作为强制 run-bound marker。`FALLBACK`、`BURST` 和 L1 辅助 marker 的未知字段/
终态策略也没有全部变成 validator reason。当前 frozen hardening 只要求 PATH/READY run
bound，因此这属于后续合同收紧选择，而不是重新打开 P2-EE-05；若 Product 将“所有
T9RESP marker 必须绑定 run”作为新硬要求，应另建版本化 Assignment 后再审。

### 6.5 最新已证明、未证明与治理停止点

**已证明（bounded）**：P2-EE-05 的 schema、字段、正数/非负约束、accepted revision
覆盖、epoch-bound publish 覆盖和 focused negative regressions；geometry payload/schema；
owner timeout fail-closed；gate 默认关闭；Swift 6 owner isolation 无
`@unchecked Sendable`；generic unsigned artifact fingerprint 与 marker scan。

**未证明**：任何真实设备/librime/persistence/Extension jetsam/memory/签名 Release/
iOS 26.0 RC/Product Gate 结论。历史 B evidence 继续是 `Partial`，不能由本次 validator
正样本改写。

**停止点**：本 post-fix Architecture 复审到此结束。它只把 P2-EE-05 标为 bounded Closed，
不接受 ADR 0025、不宣布 Evidence Hardening 或 Product Gate Complete、不接线 Release 默认
path，也不授权 R5 真机 A/B。下一步若要继续，只能由 Product Lead 授权 P2-H-06 的设备/环境
证据，或另建 Assignment 处理 P3-H-08～P3-H-10。

## 7. Final-v4 Architecture 独立复审：P2-POST-01 run-bound felt markers

### 7.1 复审对象与方法

这是对 §6 之后最新 tip 的最后一次只读 Architecture 复审，目标只限于
**P2-POST-01：显式 preflight 下 felt marker 的 run-bound 闭合**。本次检查：

1. `ResponsiveRimeFeltMetricsTracker` 是否在同一 accept/revision 链中捕获、保存并传播
   canonical run token；
2. `ResponsiveRimePreflight.publishMarkerLine` 与 `KeyboardController` 的 epoch-bound
   publish 是否使用同一 token；
3. validator 的 `requiresRunBinding` 是否覆盖 PATH/READY/NOT_READY/FALLBACK、
   ACCEPT/VISIBLE/PUBLISH/BURST 以及 T9DEVICE/T9GEOM/T9SEG/T9ARM；
4. T9DEVICE/T9GEOM 是否有 `schema=v1`，并且 final-v4 unsigned artifact 的 hash/strings
   与 handoff 一致；
5. 默认 gate、Swift 6 owner 隔离、ADR/Product/设备边界是否仍未被越权改变。

Executor 提供的 final focused 结果保持 `38/0`（validator `20/0`、preflight `6/0`、felt
`3/0`、wire `9/0`），KeyboardCore 全量 `884/0`；本次不冒充重新执行这些 suite。
`git diff --check` 通过，hardening Assignment、contract 和 ADR 链接存在。

### 7.2 Final-v4 artifact 独立复核

在 `/private/tmp/universe-keyboard-p2-evidence-hardening-final-v4-derived` 中重新计算：

| Binary | SHA-256 |
|---|---|
| `Universe Keyboard.app/Universe Keyboard` | `34a05bf0af5fdefa965928d4bac20b035be8e2711c1e1dc4f7ef05062b90b04e` |
| `Keyboard.appex/Keyboard` | `f354bb7a4a67e40c8015e4c2ce0c12a8ec55498400a87e35a920842ed2b654ce` |

对 `Keyboard.appex/Keyboard` 的 `strings` 扫描命中 `T9ResponsiveEvidenceValidator`、
`T9DEVICE schema=v1`、`T9GEOM schema=v1 phase=execution`、`T9RESP marker=PATH/READY/
NOT_READY/FALLBACK` 及 felt `ACCEPT/VISIBLE/PUBLISH/BURST schema=v1` 的构造片段。由于
Swift 字符串插值会拆分 `run=` 片段，静态 strings 只作为 marker presence 证据；run 传播
本身以源码路径与 focused validator fixture 为主。该构建仍为 `CODE_SIGNING_ALLOWED=NO`
generic iOS artifact，不是签名 Release 或设备安装身份。

### 7.3 P2-POST-01 判定：Bounded Closed

本轮实现形成了完整的值传递链：

- explicit preflight 下，`recordAccept` 从 `HotPathSegmentTiming.devicePreflightContext`
  捕获本轮 token，并把 token 存入 revision 的 `AcceptRecord`；
- `recordVisible`、felt `recordPublish` 和 `BURST` 从相同 accept/revision 取回 token，
  生成 `run=` marker；
- thread-affine 的 epoch-bound `ResponsiveRimePreflight.publishMarkerLine` 接收
  `metrics.runToken`；
- validator 对缺失或错误 run token fail-closed，并将这些 T9RESP marker 纳入统一
  `runTokens`/mixed-run 检查；T9DEVICE/T9GEOM 也要求 `schema=v1`。

因此，P2-POST-01 在 **代码、schema、focused regression、generic artifact** 的边界内
可标记为 **Bounded Closed**。普通非-preflight 调用仍可使用可选 `runToken=nil` 的纯
formatter API；这不会把缺失 token 的 explicit preflight evidence 判成通过，因为
validator 对 run-scoped marker 会拒绝缺失绑定。

### 7.4 仍开放的 P2/P3 与授权边界

**P2-H-06（仍 Open）**：真实 iPhone/Extension 安装与导出、真实 librime session、
mandatory logger persistence、owner lifecycle、jetsam/memory/queue、UIKit reload/retry、
签名 Release、iOS 26.0 RC、Product Gate 和用户体验结论均未执行。它需要 Product Lead
另行授予设备/环境/最终 Release 证据权限；本次 Architecture 复审不能自行补齐。

**P3-H-08（仍 Open）**：诊断 allow-list 仍使用 substring 保留，后置 validator 才负责
schema/privacy；可另行补 marker 起始/未知字段负样本。

**P3-H-09（仍 Open）**：owner timeout 的 App/Extension target-level 回退接线仍没有专门
集成回归；组件级 wire/formatter 已通过，环境可用后再补即可。

此前 P3-H-10 中的“指定 felt marker 缺少 run”已由本轮关闭；L1 辅助 marker（如
`L1_SKIP`/`L1_FAIL_CLOSED`）不属于 P2-POST-01 的 validator-recognized felt/preflight
发布链，若未来要把它们纳入 evidence contract，应另起版本化 Assignment，不回溯改写本次
结论。

### 7.5 最终 Architecture 停止点

最终 verdict：**Bounded Pass with conditions，P0/P1/P2/P3 = 0/0/1/2**。本 verdict 只
确认 P2-POST-01 的 run-bound felt marker 设计与证据边界闭合；不接受 ADR 0025、不宣布
Evidence Hardening/Responsive Pipeline Complete、不开启 Release 默认 gate、不形成真实
librime/off-main 性能或 Product Gate 结论。后续只能在明确的环境授权下处理 P2-H-06，或另行
建立 P3 Assignment。
