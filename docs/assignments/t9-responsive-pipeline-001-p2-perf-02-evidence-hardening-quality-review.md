# 独立 Quality / Performance 复审：P2-PERF-02 Evidence Hardening

| 字段 | 结论 |
|---|---|
| 复审角色 | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| 复审日期 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | [`P2-PERF-02 Evidence Hardening`](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening.md) |
| 复审基线 | 当前 worktree `HEAD=3585a540`；工作树含其他任务的 ambient 改动，本复审不归因、不覆盖、不提交 |
| 关联合同 | [`P2-PERF-02 Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)；[`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)（仍为 `Proposed`） |
| 复审范围 | Hardening child assignment、allow-list、PATH/READY persistence/schema、geometry retry、owner readiness、validator fail-closed、默认 gate、隐私和 artifact/test 证据 |
| Quality 结论 | **Pass with conditions（bounded hardening review）**；本子 Assignment 可交 Architecture 做条件式复审，但不能标为 Product/Release 完成 |
| P0 / P1 / P2 / P3 | **0 / 0 / 3 / 2** |
| 治理结论 | 不形成 Product Gate、Release、ADR Accept、真实 librime off-main 或默认开启结论 |

## 1. 复审方法与证据层级

本次只读检查了 Hardening Assignment、前序 Architecture/Quality review、当前源码/测试、
allow-list、诊断接线和现有 generic artifact。没有改动生产逻辑、测试、Assignment、ADR
或历史 B evidence。

证据严格分层：

1. **独立重跑**：本次在隔离的 `/private/tmp` SwiftPM scratch/cache 中重跑了三个 focused
   suite；
2. **独立复核**：读取并重新计算已有 unsigned artifact 的 SHA-256，重新执行 marker
   `strings` 扫描，检查工程默认 flags 和 test-list 数量；
3. **Executor 提供但未独立重跑**：KeyboardCore 全量 `879/0` 与 generic build 的完整
   编译过程；本次没有为节省时间再执行 10 分钟级全量。

测试通过、静态 artifact 和真实设备运行不是同一证据层，不能相互替代。

## 2. 测试与 artifact 证据

### 2.1 focused tests：独立重跑

| Suite | 本次独立结果 | 备注 |
|---|---:|---|
| `T9ResponsiveEvidenceValidatorTests` | **15 / 0** | run-bound PATH/READY、非法 geometry、retry、NOT_READY、字段缺失、action/event mismatch、epoch publish、markerless privacy |
| `ResponsiveRimePreflightTests` | **6 / 0** | PATH run token、READY/NOT_READY、content-free、Release 不从 UserDefaults 单独 arm |
| `ThreadAffineRimeWireTests` | **9 / 0** | owner snapshot、timeout 不报告 ready、默认 gate-off、队列/可见性边界 |

三组 focused suite 合计 **30 / 0**。构建时仍出现已有的 optional interpolation warning
（`T9PinyinPathTests.swift:1429`），没有失败或 warnings-as-errors 结论。

### 2.2 全量与 test inventory

- Hardening Assignment 提供的 KeyboardCore 全量结果为 **879 / 0**；本次没有重新执行全量，
  因而不把它冒充成独立全量运行。
- 本次用 `swift test list` 独立统计当前测试清单为 **879 个**，证明数量与 handoff 相符，
  但清单数量本身不证明 879 个测试全部通过。

### 2.3 generic unsigned Release artifact：独立复核 hash/marker

Executor handoff 指定的产物目录存在：

`/private/tmp/universe-keyboard-p2-evidence-hardening-derived/Build/Products/Release-iphoneos/`

本次重新计算得到的二进制 SHA-256 与 handoff 完全一致：

| Binary | SHA-256 |
|---|---|
| `Universe Keyboard.app/Universe Keyboard` | `02c9ee5d6adbf7fa7da12fe11a1bbbdf1c28e1751619eb2171df9dd56ea16716` |
| `Keyboard.appex/Keyboard` | `29aa5217b8033cc81f689667169f01dc9258e0eee8d0a9e55a87dcaa167af881` |

`strings` 对 app/extension 的独立扫描命中：

- `T9ResponsiveEvidenceValidator`；
- `T9DEVICE_DISABLED`；
- `T9GEOM phase=execution`；
- `T9RESP marker=PATH`、`READY`、`NOT_READY`。

artifact 还原信息显示 `DTSDKName=iphoneos27.0`、`MinimumOSVersion=26.4`，
`codesign` 报告二进制未签名。工程默认设置只看到 `SWIFT_ACTIVE_COMPILATION_CONDITIONS =
"DEBUG $(inherited)"`；preflight flags 没有写入 project 默认值。Executor 记录的 build
参数（`Release`、generic iOS、`CODE_SIGNING_ALLOWED=NO`、命令行注入两个 preflight flags）
与静态 marker 结果一致。

这证明当前 handoff artifact 的 fingerprint 与内容存在，但不证明它已安装、启动或在扩展
进程中实际写出日志。当前评审尝试重新解析 Xcode build settings 时仍受到本机 SwiftPM/
clang cache 权限影响，故不把一次新的 generic rebuild 记为独立证据。

### 2.4 其他只读检查

- `git diff --check`：通过；未暂存、未覆盖 ambient worktree。
- `bash scripts/ensure_rime_vendor.sh verify`：此前结构校验通过；不是本次真实 librime
  长句运行证据。
- Xcode 为 `27.0 (27A5228h)`，iPhoneOS SDK 为 `27.0`；这些是本机工具链信息，不是
  iOS 26.0 Release RC 证明。

## 3. bounded 通过项

### 3.1 PATH/READY persistence 与 diagnostics channel

Hardening 后，显式编译的 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` 路径通过
`Logger.devicePreflightPerformance(..., bypassCategoryFilter: true)` 记录 PATH/READY，
并请求 flush；普通 Debug 继续使用原 engine-category logger。App diagnostics view 与
KeyboardCore 测试共用 `T9DevicePreflightEvidenceLineFilter`，不会主动过滤 `T9RESP`。

这在代码层关闭了“engine category 被关闭导致 PATH/READY 被普通 logger 丢弃”的前一条件。
不过 logger 的写入仍是异步、且生命周期 suspend 会丢弃 pending records；没有真机日志导出，
所以“设备本次实际持久化了 PATH/READY”仍未验证（见 P2-H-03）。

### 3.2 run-bound PATH/READY

当前显式 preflight marker 携带 `run=<S6A-...>`，PATH 校验 fixture、path、
`dualGateRequested=1`、`dualGateActive=1`；READY 校验 fixture、`bootstrap=config-only`、
`session=owner-thread` 和 run token。validator 也会拒绝混合 run token；focused 正样本和
缺失 T9SEG run binding 负样本均通过。

因此，旧的“任意 PATH/READY 布尔旁证即可通过”问题已明显收紧，但 marker schema 仍有条件项，
见 P2-H-01。

### 3.3 geometry digest/retry

validator 现在拒绝非 64 位小写 hex digest、空 digest 和多个不同 digest；
`execution unavailable → 后续有效 execution` 会按最终有效 digest 判定，不再把 transient
失败永久留在 reasons。focused 15/0 已独立覆盖非法 digest 和 retry 正样本。

geometry 采集端仍只在完整 geometry 可得时记录 execution，并保留下一轮 layout retry；这与
fail-closed 方向一致。digest 合同已经比前一轮严格，但几何 payload schema 仍有残余，见
P2-H-02。

### 3.4 owner timeout 与隔离边界

`ThreadAffineRimeSessionCoordinator` 现在保存 `isOwnerReady`，实际消费
`waitUntilReady` 返回值；超时会记录 `NOT_READY`，不会伪造 READY，并清除 dual-gate 标志
回到同步安装路径。owner engine 仍仅在 dedicated thread 创建/使用/释放，MainActor 读取值型
diagnostic snapshot；未发现 `@unchecked Sendable` 或 unsafe actor escape。

独立 9/0 wire tests 覆盖 timeout、snapshot 和 gate-off，但真实 `RimeEngineImpl` 初始化失败、
jetsam 和键盘重载时序仍未验证。

### 3.5 default-off、可读性与隐私目标

- 工程默认没有 preflight compilation condition；代码中的 explicit flags 仅由命令行注入。
- `devicePreflightPerformance` 的注释清楚说明 mandatory channel 只属于显式诊断，
  `recordResponsivePreflightMarker` 将普通 Debug 与 preflight 行为分开，意图可读。
- marker generators 当前调用点只传 enum-like path/reason 和 content-free 字段；validator
  拒绝已知的 raw input/candidate/marked text/host text/pinyin/user dictionary 字段以及
  非 ASCII 内容。

这些是 bounded 代码与测试结论，不是对 Release 用户路径或隐私运行时的全面审计。

## 4. Quality findings

### P2-H-01 — PATH/READY “版本化、run-bound、fail-closed”仍未完全冻结

当前 marker 有 `fixture=T9RESP-R5P`，但没有独立的 `schema=v1`/版本字段；fixture 更像
运行场景 ID，不能明确表达字段协议版本。`pathMarkerLine` 的 `runToken` 仍是可选参数，
而 validator 对缺失/错误 PATH/READY schema 主要记录 `marker-schema-invalid` 并给出
`Partial`；只有其它 run token 混入时才必然 `Blocked`。此外，`NOT_READY` 的 reason 没有
枚举化校验，`FALLBACK` 也不是完整的 run-bound schema 分支。

这不会让正样本误报 Complete，但会降低坏 PATH/READY 证据的 fail-closed 强度。建议冻结
显式 schema version、必填 run token/字段和 failure status 规则，并补“PATH 缺 run、PATH
错 run、READY 缺 bootstrap、NOT_READY 错 run、旧 schema 混入”的负样本。

### P2-H-02 — geometry digest 已收紧，但 geometry payload 合同仍可被截短

validator 目前验证 phase、run binding、digest 形状和集合唯一性，却没有要求
`space=portrait-screen-points`、`orientation=portrait`、`screen`、`scale`、`keyboard`、
八个 slot 等必要字段。一个只含合法 digest 的截短 `T9GEOM phase=prepared/execution`
行仍可能进入匹配逻辑。生成器当前会写完整字段，因此这是证据解析器的 fail-closed 缺口，
不是已观察到的生产泄漏。

建议为 geometry marker 冻结最小版本化字段 schema，并增加截短、错误 orientation/space、
缺 slot、跨 run digest 的负样本。

### P2-H-03 — artifact fingerprint 已闭合，真实 persistence/runtime 仍未闭合

本次独立复核确认了 handoff binary hash、SDK/min OS、未签名状态和 marker strings；但没有
重新生成 artifact，也没有 iPhone 13 Pro 安装、启动、输入长序列、导出 `rime_diag_log` 或
用 validator 解析真实导出。因此仍无法证明：

- mandatory channel 在 Extension 生命周期中实际持久化 PATH/READY；
- owner timeout/NOT_READY 与真实 librime 失败一致；
- geometry retry 在 UIKit reload 后得到同 token/唯一 digest；
- 真机 session identity、队列深度和 presentation 顺序满足合同。

这是 P2 证据层残余，不是要求本子 Assignment 当前立刻扩大到真机的授权。历史 B evidence
继续保持 `Partial`。

### P3-H-04 — allow-list 仍是 substring，且不是独立 schema/privacy sanitizer

`T9DevicePreflightEvidenceLineFilter` 仍使用 `line.contains("T9RESP ")`、`T9SEG` 等规则；
伪造前缀或带未知 ASCII 字段的 marker 可以被保留，最终安全性依赖后置 validator。validator
的 privacy deny-list 也主要匹配已知字段名，不能单独证明任意未知 ASCII 值不是用户内容。

当前调用链有后置验证且生成器 content-free，所以没有 P0/P1；建议补 marker 起始/版本化
shape 检查、未知字段策略和 ASCII 用户文本负样本。

### P3-H-05 — owner timeout 的集成覆盖仍窄于纯组件覆盖

focused tests 证明 coordinator 的 timeout 返回 `false`，也证明 marker formatter 能生成
NOT_READY；但没有 App/Extension target 的测试直接断言
`installResponsiveDualGatePreflightIfArmed` 在 timeout 时同时写 PATH + NOT_READY、清除两个
gate 并随后恢复同步 RIME。该路径由源码静态检查支持，尚未由 target-level test 或设备运行闭合。

## 5. 验证边界与未执行项目

明确未执行、不能由本次 review 代替的项目：

- iPhone 13 Pro 安装、解锁后键盘运行、真实长句输入、A/B、content-free 日志导出；
- 真实 `RimeEngineImpl` 的 owner 初始化、session identity、PATH/READY persistence、
  geometry reload/retry 和失败回退；
- Extension jetsam、内存峰值、队列深度、长时间输入、多次键盘重载；
- iOS 26.0 Release RC、签名 archive/dSYM、TestFlight/App Store；
- Product Gate、ADR 0025 Accept、Release default-on、用户体验 SLO 或 off-main 产品收益。

## 6. 结论与交接

**Quality verdict：Pass with conditions。** 当前 hardening 已实质关闭 mandatory channel、
geometry retry、owner timeout 和主要 validator 负样本问题；focused 15/0 + 6/0 + 9/0、
artifact hash/marker scan 和默认 gate 检查可复核。剩余 P2-H-01 至 P2-H-03 是证据合同/运行
闭环条件，P3-H-04 至 P3-H-05 是边界强化项。

可以把本 review 交给独立 Architecture 做 bounded reconciliation；不能宣布本子 Assignment
Complete、P2-PERF-02 Complete、ADR 0025 Accepted、Product Gate 或 Release 通过。

建议下一步（需单独授权）：

1. 冻结 marker schema version、PATH/READY/NOT_READY 的必填字段和严格 failure status；
2. 为 geometry payload、allow-list shape、未知字段隐私和 App target timeout 回退补 focused
   regression；
3. 若 Product Lead 另行授权，再用当前 hash/flags 绑定的 artifact 做一次真机日志导出，
   以 validator 判定真实 persistence/session/geometry；
4. 保持普通 gate-off、历史 B `Partial`、ADR `Proposed` 和所有 Release/Product Gate 边界。

本角色在此停止；本文件是独立只读 Quality/Performance 复审记录，不修改生产逻辑或治理状态。

---

## 7. Post-fix Quality/Performance 复审（schema-v1 / P2-EE-05 / geometry payload）

| 字段 | 结论 |
|---|---|
| 复审时间 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | 同一 Hardening child Assignment 的最新 post-fix tip；加入 schema-v1、ACCEPT/VISIBLE/PUBLISH validator 收紧和 geometry payload 校验后的实现 |
| 独立复核范围 | focused tests、test inventory、工程默认 flags、final-v2 artifact hash/strings、隐私与 gate-off 边界 |
| Quality 结论 | **Pass with conditions（bounded post-fix review）**；schema-v1/geometry payload 的代码层条件可关闭，P2-EE-05 的完整 run-bound 发布合同和真实 runtime 仍开放 |
| P0 / P1 / P2 / P3 | **0 / 0 / 2 / 2** |
| 治理边界 | 不宣布 Product Gate、Release、ADR 0025 Accepted、真实 librime 生产接线或默认开启 |

### 7.1 最新证据矩阵

#### 独立重跑

本次用隔离的 `/private/tmp` SwiftPM scratch/cache 独立执行一次正则 focused suite：

| Suite | 结果 |
|---|---:|
| `T9ResponsiveEvidenceValidatorTests` | **20 / 0** |
| `ResponsiveRimePreflightTests` | **6 / 0** |
| `ResponsiveRimeFeltMetricsTests` | **3 / 0** |
| `ThreadAffineRimeWireTests` | **9 / 0** |
| 合计 | **38 / 0** |

构建仍显示既有 `T9PinyinPathTests.swift:1429` optional interpolation warning；没有测试失败。
KeyboardCore 全量 handoff 为 **884 / 0**，本次未重复运行全量，不把 executor 结果冒充独立
全量证据。独立 `swift test list` 统计当前清单为 **884 个**，只证明测试数量与 handoff
一致，不证明 884 个均通过。

#### 独立复核 final-v2 generic artifact

handoff 指定的 unsigned artifact 目录存在：

`/private/tmp/universe-keyboard-p2-evidence-hardening-final-v2-derived/Build/Products/Release-iphoneos/`

本次重新计算 SHA-256，与 handoff 完全一致：

| Binary | SHA-256 |
|---|---|
| `Universe Keyboard.app/Universe Keyboard` | `dec3b1f830e0432d43d15e17da50b4eeb5698f98c3fdb7320e1178320b07cda4` |
| `Keyboard.appex/Keyboard` | `c7ec16f00d13f03355da95137e0cf22109eaa8870812be905cd45f74f06ba73d` |

`strings` 对 app/extension 的独立扫描命中：

- `T9ResponsiveEvidenceValidator`、`T9DEVICE_DISABLED`、`T9GEOM phase=execution`；
- `T9RESP marker=PATH schema=v1`、`READY schema=v1`、`FALLBACK schema=v1`；
- `T9RESP marker=VISIBLE schema=v1`、`PUBLISH schema=v1`；
- `T9RESP marker=NOT_READY schema=`（静态字符串因插值被拆开，源码和 6/0 formatter test
  明确输出 `schema=v1`）。

artifact plist 显示 `DTSDKName=iphoneos27.0`、`MinimumOSVersion=26.4`，`codesign` 报告
未签名。工程默认 compilation conditions 仍只包含 `DEBUG $(inherited)`；两个 preflight
flags 仅存在于 handoff 的命令行 build 参数，未写入 project 默认配置。`git diff --check`
通过，复审文档引用的三个相关路径均存在。

上述 hash/strings 是对既有 artifact 的独立复核；没有在本次复审中重新生成 artifact，因而
不把它写成独立 generic build 过程证明。

### 7.2 post-fix 已证明的部分

- `ResponsiveRimePreflight.markerSchemaVersion` 固定为 `v1`；PATH/READY/FALLBACK/PUBLISH
  和 felt ACCEPT/VISIBLE/PUBLISH/BURST marker 生成器都携带 schema 字段。`ResponsiveRimePreflightTests`
  与 `ResponsiveRimeFeltMetricsTests` 独立 9/0 锁定了格式和 content-free 目标。
- Validator 对 ACCEPT 要求 schema/fixture/action/positive revision+epoch/non-negative
  pending，并拒绝重复 revision；对 VISIBLE 要求 schema/fixture/source/lag/accepted
  revision，并拒绝 regression 与同源重复；对 PUBLISH 要求 schema/fixture/positive revision、
  合法 lag/pending/coalesced 或 epoch-bound 形态，并要求 thread-affine 每个 accepted
  revision 都有 epoch-bound publish。独立 20/0 覆盖这些负样本和 39-action 正样本。
- Geometry validator 现在强制 portrait screen-space、positive scale、screen/keyboard
  rect 和 `s0…s7` 八个 slot，同时保留 64 位小写 digest、单一 digest 和
  `unavailable → success` 最终态规则；非法 orientation/payload 的回归已通过。
- owner timeout 仍由 coordinator 消费 `waitUntilReady` 返回值，失败不生成 READY；9/0
  Wire 回归和 20/0 `NOT_READY` validator 回归均通过。engine 线程亲和与 Sendable snapshot
  形状未出现 `@unchecked Sendable` 或 unsafe escape。
- default gate 仍 off，普通路径没有被 schema marker 改写；诊断 marker generators 的调用
  点继续只产生 content-free 字段，已知 raw input/candidate/host text/user dictionary 和
  非 ASCII 违规仍会被 validator 拒绝。

### 7.3 仍开放的 Quality findings

#### P2-POST-01 — 完整 Evidence Contract 要求的 T9RESP felt marker run binding 尚未落地

schema-v1 已加入，但 `ResponsiveRimeFeltMetrics` 的 ACCEPT/VISIBLE/PUBLISH/BURST 生成器和
`ResponsiveRimePreflight.publishMarkerLine` 没有 `run=` 参数；validator 的
`requiresRunBinding` 也只覆盖 `T9DEVICE/T9GEOM/T9SEG/T9ARM`，不覆盖这些 `T9RESP` felt
marker。这样，旧 run 的 felt marker 仍可能与当前 run 的 T9SEG/PATH/READY 混合，只靠
fixture/schema/revision 检查通过。

Evidence Contract §7 的不变量是同一 arm 的所有 marker 使用一个 canonical run token；当前
post-fix 仅把 schema 和 revision/epoch 收紧，尚未满足这项完整 run-bound 合同。`NOT_READY`
与 `FALLBACK` 也没有独立的严格 run/schema 分支判定。应由后续授权决定是否把 felt marker
纳入 run token（或在合同中明确它们是 non-run-scoped derived markers），并补跨 run 负样本。

#### P2-POST-02 — 真实 persistence/runtime 与最终 Release 证据仍未执行

final-v2 hash、flags 说明和 strings 只能证明静态 unsigned artifact；没有 iPhone 13 Pro 安装、
真实 librime、`rime_diag_log` 导出、validator 对真实日志的判定、Extension jetsam/memory、
reload/retry 长时序或最终签名 Release。Hardening Assignment 把这些列为 non-goals，因此
这是总体证据的开放边界，不是本次擅自扩大授权的理由。历史 B evidence 仍为 `Partial`。

#### P3-POST-03 — allow-list 与未知 ASCII 隐私边界仍依赖后置 validator

`T9DevicePreflightEvidenceLineFilter` 仍按 marker substring 保留行，validator 的隐私 deny-list
主要覆盖已知字段。生成器调用点目前 content-free，因此没有观察到隐私泄漏；但 filter 不能
独立证明 marker shape 或任意未知 ASCII 值不是用户内容。后续可补 shape/unknown-field 负样本。

#### P3-POST-04 — owner timeout 缺少 App/Extension target-level 集成回归

纯组件测试证明 timeout=false、NOT_READY formatter 和 gate-off；尚没有 target-level test
直接断言 `installResponsiveDualGatePreflightIfArmed` 在真实 timeout 时同时写 PATH + NOT_READY、
清除 dual gate 并完成同步 RIME 回退。真实生命周期仍应放到另行授权的 runtime 验证。

### 7.4 未执行验证与停止点

以下仍明确未执行：真机安装/长句人工输入/A-B、真实 librime owner 初始化和 session identity、
mandatory log export persistence、Extension jetsam/memory/queue、UIKit reload/retry 运行时、
iOS 26.0 Release RC、签名 archive/TestFlight/App Store、Product Gate、ADR 0025 Accept 和
Release default-on。

**post-fix Quality 结论仍为 Pass with conditions。** schema-v1、geometry payload、validator
字段/epoch 收紧和 owner timeout 的 bounded code/test/artifact 证据可交 Architecture 做条件式
reconciliation；P2-POST-01/P2-POST-02 未关闭前，不得把 Hardening 或 P2-PERF-02 写为
`Complete`，也不得宣布任何 Release/Product Gate 结论。

本附录仍是独立只读复审记录，不修改生产逻辑、测试、Assignment、ADR 或历史证据。

---

## 8. Final post-fix Quality/Performance 复审（run-bound felt marker tip / final-v4）

| 字段 | 结论 |
|---|---|
| 复审时间 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | 最终 run-bound felt marker tip；explicit preflight token 从 `HotPathSegmentTiming` 进入 ACCEPT，并沿 revision 传递至 VISIBLE/PUBLISH/BURST 与 epoch-bound PUBLISH |
| 独立复核范围 | run-token 传递、validator canonical binding、focused tests、final-v4 artifact/hash/marker scan、默认 flags、隐私和 gate-off 边界 |
| Quality 结论 | **Pass with conditions（bounded final post-fix review）** |
| P0 / P1 / P2 / P3 | **0 / 0 / 1 / 2** |
| 治理边界 | 不宣布 Product Gate、Release、ADR 0025 Accepted、真实 librime 生产接线或 Release default-on |

### 8.1 P2-POST-01 关闭判定

本次独立源码核对确认：

1. `ResponsiveRimeFeltMetricsTracker.recordAccept` 在显式
   `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` arm 中从 `HotPathSegmentTiming.devicePreflightContext`
   取得本轮 token，并把它存入 revision 对应的 `AcceptRecord`；
2. `recordVisible`、`recordPublish` 和 BURST 生成均从该 `AcceptRecord` 取 token，避免
   用当前全局 context 覆盖旧 revision；
3. `KeyboardController` 的 epoch-bound `ResponsiveRimePreflight.publishMarkerLine` 使用
   `recordPublish` 返回的同一 token；
4. `T9ResponsiveEvidenceValidator.requiresRunBinding` 已覆盖
   `T9DEVICE`、`T9GEOM`、`T9SEG`、`T9ARM` 以及 T9RESP 的
   `PATH/READY/NOT_READY/FALLBACK/ACCEPT/VISIBLE/PUBLISH/BURST`。显式 preflight 中缺失或
   错误 token 会进入 `marker-run-token-missing-or-wrong`/`Blocked`，混合 token 也会阻断；
5. felt marker generators 和 preflight marker generators 均输出 `schema=v1`，并保留
   fixture、revision/epoch 等 content-free 字段。

因此，前一附录中的 **P2-POST-01（felt marker 未 run-bound）现正式关闭**。这只表示代码层
的 canonical run binding 与负向 fail-closed 检查已存在，不表示真实设备日志一定包含完整
marker 序列。`NOT_READY` 仍按失败状态处理；`FALLBACK`/BURST 的运行时语义需由真实导出
确认，但不再是 run identity 缺失问题。

### 8.2 独立 focused 回归

在独立的 `/private/tmp` SwiftPM scratch/cache 中重跑：

| Suite | 结果 |
|---|---:|
| `T9ResponsiveEvidenceValidatorTests` | **20 / 0** |
| `ResponsiveRimePreflightTests` | **6 / 0** |
| `ResponsiveRimeFeltMetricsTests` | **3 / 0** |
| `ThreadAffineRimeWireTests` | **9 / 0** |
| 合计 | **38 / 0** |

构建仍有既有 `T9PinyinPathTests.swift:1429` optional interpolation warning，无测试失败。
KeyboardCore 全量 **884 / 0** 来自最新 executor handoff；本次独立复核只统计当前 test
inventory 为 884，未将 handoff 冒充为本次独立全量运行。

### 8.3 final-v4 artifact 与静态 marker 复核

artifact 目录：

`/private/tmp/universe-keyboard-p2-evidence-hardening-final-v4-derived/Build/Products/Release-iphoneos/`

独立重算 hash：

| Binary | SHA-256 |
|---|---|
| `Universe Keyboard.app/Universe Keyboard` | `34a05bf0af5fdefa965928d4bac20b035be8e2711c1e1dc4f7ef05062b90b04e` |
| `Keyboard.appex/Keyboard` | `f354bb7a4a67e40c8015e4c2ce0c12a8ec55498400a87e35a920842ed2b654ce` |

app/extension `strings` 独立扫描命中 `T9ResponsiveEvidenceValidator`、`T9DEVICE_DISABLED`、
`T9GEOM`、`T9RESP marker=PATH schema=v1`、`READY schema=v1`、`FALLBACK schema=v1`、
`NOT_READY schema=`、`VISIBLE schema=v1` 和 `PUBLISH schema=v1`。由于 Swift 字符串插值，
ACCEPT/BURST 的静态片段分别呈现为 `T9RESP marker=ACCEPT schema=` 与
`T9RESP marker=BURST schema=`；源码生成器、focused formatter tests 和 validator fixture
共同确认实际运行格式为 `schema=v1`，不是 marker 缺失。

artifact plist 为 `DTSDKName=iphoneos27.0`、`MinimumOSVersion=26.4`；`codesign` 报告
未签名。工程默认 compilation conditions 未发现
`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` 或 `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`；两者只在
显式 handoff build 命令行注入。`git diff --check` 通过，未修改或暂存 ambient worktree。

### 8.4 最终残余与未验证边界

**P2-POST-02（仍开放）**：final-v4 仍是 unsigned generic artifact。以下真实环境证据
没有执行，不能由 focused 测试、源码或 hash 推导：

- iPhone 13 Pro 安装、键盘启动和 39-key 长句人工输入；
- 真实 `RimeEngineImpl` owner 初始化、session identity、PATH/READY/felt marker 日志导出
  persistence 与 validator 对真实导出的判定；
- Extension jetsam、内存峰值、队列深度、长时输入、键盘 reload/geometry retry；
- iOS 26.0 Release RC、签名 archive/dSYM、TestFlight/App Store 或最终 Release 包；
- Product Gate、ADR 0025 Accept、Release default-on 和用户体验 SLO。

**P3-POST-03（仍开放）**：evidence line filter 仍以 substring allow-list 为主，未知 ASCII
字段的隐私边界依赖后置 validator；当前生成器保持 content-free，未观察到泄漏。

**P3-POST-04（仍开放）**：没有 App/Extension target-level 测试直接覆盖真实 timeout →
PATH + NOT_READY → gate 清除 → 同步回退的生命周期；组件级 9/0 wire tests 和 validator
回归已通过。

### 8.5 最终结论与停止点

最终 Quality/Performance 结论为 **Pass with conditions**，P0/P1/P2/P3 = **0/0/1/2**。
P2-POST-01 已关闭；唯一 P2 是真实设备/日志 persistence/运行时与最终 Release 证据缺口，
另保留两个 P3 边界强化项。当前结果可交独立 Architecture 做最终 bounded reconciliation，
但不得把 hardening 或 P2-PERF-02 写为 Product/Release Complete。

本角色在此停止；本附录只记录独立 Quality/Performance 复审，不修改生产逻辑、测试、ADR、
Assignment 状态或 Product Gate。
