# 独立 Quality / Performance 复审：T9-RESPONSIVE-PIPELINE-001 / P3-D1-T01

| 字段 | 结论 |
|---|---|
| 复审角色 | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| 复审日期 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | [`P3-D1-T01 Test Harness Repair`](t9-responsive-pipeline-001-p3-d1-t01-test-harness-repair.md) |
| 关联矩阵 | [`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md) |
| 复审基线 | `HEAD=3585a54`；worktree 仍含其他任务的 ambient 改动，本复审不归因、不覆盖、不暂存 |
| Quality verdict | **Pass with conditions（bounded harness repair）**；P3-D1-T01 为 **Partial (bounded)**，不能升级为 T02/T03、真实 RIME、真机或 Release 通过 |
| P0 / P1 / P2 / P3 | **0 / 0 / 0 / 1** |
| 治理边界 | 不改生产逻辑、ADR 0025、Product Gate、默认 gate、真实 librime 接线或物理设备流程 |

## 1. 复审范围与 Assignment 边界

本次只读核对了 T01 Repair Assignment、更新后的 P3-D1 matrix、
`KeyboardExtensionTests/CandidatePrefetchUIContractTests.swift`、
`ResponsiveProvisionalCompositionTests.swift` 的 repair delta、XCTest 结果摘要、RimeBridge
skip 语义以及 P3-D1 的 privacy/Run ID/手动输入/停止条件。

Repair Assignment 的授权范围是明确且最小的：

- 移除 Swift 6 `XCTestCase` initializer 与 class-level `@MainActor` 的 target compile 冲突；
- 让 Extension test target 保持 `Keyboard` module/appex target compile dependency，但不从
  XCTest bundle 链接不可链接的 `KeyboardViewController` appex symbol；
- 将 `testCoalesceBacklogStillPaintsL1` 中一个固定 35ms 的 MainActor timing sleep 替换成有
  2 秒上限的异步 polling；
- 不改生产 source、RIME/Lua、输入行为、默认 gate、Xcode 产品设置、ADR、设备数据或 Product Gate。

这符合 Assignment allow-list。`KeyboardExtensionTests` 仍是 target probe，不被描述为完整
Extension lifecycle harness。

## 2. 测试与证据结果

| 检查 | 结果 | Quality 解释 |
|---|---:|---|
| `KeyboardExtensionTests/CandidatePrefetchUIContractTests` focused | **1 / 0** | bundle-load probe 通过；appex target 作为 dependency 构建 |
| `KeyboardExtensionTests` full target | **1 / 0** | 当前 target 只有该 probe；没有 lifecycle test body |
| `RimeBridgeTests`（同一 iOS 27.0 iPhone 17 Pro Max Simulator） | **54 / 0，20 skipped，exit 0** | bridge/test-target 证据；skip 是环境 gated real-runtime cases，不是 Pass |
| `ResponsiveProvisionalCompositionTests` focused flaky regression | **1 / 0** | `testCoalesceBacklogStillPaintsL1` 修复后通过 |
| `Packages/KeyboardCore` full | **894 / 0** | repair 后 full suite 通过；既有 optional-interpolation warning 不属于新失败 |
| `git diff --check` | **通过** | 文档/工作树格式检查；不代表 runtime 通过 |

### 2.1 Extension probe 的真实覆盖

当前测试类为 `nonisolated final class CandidatePrefetchUIContractTests: XCTestCase`，只做：

```swift
XCTAssertNotNil(Bundle(for: Self.self).bundleIdentifier)
```

它保留 `@testable import Keyboard` 以使 Extension target 参与编译，但不引用
`KeyboardViewController` 或任何 appex symbol。这个设计正确地修复了 XCTest initializer/link
边界，并证明：

1. `Keyboard.appex` 可作为测试 target dependency 构建；
2. `KeyboardExtensionTests` bundle 能加载并执行一个 XCTest probe。

它没有证明 Extension process 的 `viewDidLoad/viewDidAppear`、RIME session、marked text、
visibility abandon/return、keyboard reload、PATH/READY、App Group writer 或 owner lifecycle。
因此 T01 只能是 **Partial (bounded)**，T02/T03 仍然 NotRun。

### 2.2 RimeBridge 54/0 + 20 skipped 的边界

54 个通过项是 RimeBridge 的 contract/bridge/test-target 证据；20 个 skip 由缺少 isolated
RIME/T9 runtime directories 或对应 fixture variables 触发，属于环境不可用/未执行 real-runtime
分支。它们没有被转写成失败，也没有被转写成真实 `RimeEngineImpl`、Lua、PATH/READY 或物理
设备 Pass。该结果不能闭合 P3-D1-R01/R02，也不能替代 Extension target lifecycle。

结果 bundle 路径、Simulator UDID、scheme/build 和 skip 状态均由 Repair Assignment 记录，足以
支持此次 target-level bounded review；但没有物理设备 Run Header、Pair Manifest 或 durable
diagnostic export。

## 3. Flaky timing 修复复核

首轮 KeyboardCore full run 发现 `testCoalesceBacklogStillPaintsL1` 使用固定 35ms sleep，
在完整 suite 的 MainActor 调度压力下可能在视觉任务真正执行前断言。修复后的测试：

- 每 10ms 让出异步执行，最多等待 2 秒；
- 仍要求 `controller.state.insertedPreeditText == "·····"` 的精确可见状态；
- 超过 deadline 仍会失败，不是 `skip`、放宽断言或吞掉错误；
- 释放 owner 后仍保留 bounded settle wait，并检查最终 provisional state 清理；
- 本次 repair 不重新归因其它 ambient L1 测试调整；其中 `currentComposition` →
  `insertedPreeditText` 的断言变化属于前置 ambient 测试改动，不计入本 repair delta。

因此该修复是可接受的 test-only scheduler stabilization，而不是把 35ms 变成产品 latency
预算，也不掩盖真实 owner stall。`1/0` focused 与后续 `894/0` full 结果支持修复有效；单次
通过仍不构成长期 CI timing-stress 统计，未来若再次出现压力波动应独立记录，而不是继续无限
放大 timeout。

修复同时保留了现有 content-free 与 stale-action 断言；新增/调整的测试 fixture 文本只存在
于测试源和 XCTest，不进入生产日志、App Group 或运行时 evidence。

### 3.1 事实更正 Addendum

为保持 changed-file provenance 精确：本次 T01 Repair 的 scheduler-stability delta 仅为
`testCoalesceBacklogStillPaintsL1` 的固定 35ms sleep → bounded async polling。文件中其它
L1 fixture、host-visible assertion 或 stale-action 变化属于此前已存在的 ambient 测试改动，
本复审不把它们归因于 T01 Repair，也不以它们扩大 T01 的证据范围。

## 4. Privacy、Run ID 与证据分层

T01 的 bundle probe 不接收用户输入、不生成 RIME 内容、不写 host text，也不产生物理输入
截图或 UI hierarchy。RimeBridge skip 结果只说明 fixture 未提供，不能伪造 schema/readiness。

P3-D1 的 Run Contract 仍适用：任何 target/real/device run 需要 source/build/flags、bundle
hash、Simulator/device/OS、schema/readiness、Full Access、Run ID、artifact hash 和 teardown
状态。此次 T01 的 result bundle 与 Simulator provenance 可审计，但它不是 physical A/B pair，
不需要也没有声称完整 Human report/restore proof。

当前分层保持如下：

| 层 | 结论 |
|---|---|
| Core/Fake | `KeyboardCore 894/0`；只能证明 deterministic bounded contracts |
| Extension target | `KeyboardExtensionTests 1/0`；只证明 target build + bundle probe，T01 Partial |
| RimeBridge | `54/0 + 20 skipped`；bridge/contract only，real-runtime cases remain unavailable |
| Real RIME / physical device | **NotRun**；无 PATH/READY/session persistence、Human input、memory/jetsam 或 Release 证据 |

没有任何低层结果被提升为真实 runtime 或产品结论。手动物理输入规则也没有被 T01 改写：
未来设备阶段仍只能由 Human 使用 software keyboard 和 Universe 中文九宫格；禁止坐标驱动
XCTest、Computer Use typing、猜坐标、Path/candidate/numeric-page 自动点击。T01 不产生 geometry
成功证明，也不授权自动化第三方键盘 UI。

## 5. Quality finding

### P3-D1-T01-Q1 — Probe 已恢复，但 target lifecycle 仍未覆盖（P3 residual）

修复解决了明确的 test harness compile/link blocker，并提供 1/0 bundle-load evidence；没有
发现生产逻辑、默认 gate、隐私边界或 RIME owner 语义被改变。残余是有意保留的边界：

- probe 不加载/驱动 `Keyboard.appex` 的生命周期；
- 不验证 visibility abandon/return、keyboard reload、marked text、session/epoch cleanup；
- 不验证 real `RimeEngineImpl`、PATH/READY、App Group persistence、jetsam、物理输入或 Release。

这是 P3 级“证据尚未覆盖”，不是 P0/P1/P2 行为问题；因此本复审唯一 finding 为 P3，整体为
**Pass with conditions**，T01 状态为 **Partial (bounded)**。

## 6. 已证明、未证明与下一步建议

### 已证明

- Swift 6 XCTest initializer isolation/link blocker 已在 test-only 范围内修复；
- Extension appex target dependency 可构建，test bundle probe 1/0；
- RimeBridge 54/0 的通过项与 20 个环境 skip 被正确分离，没有把 skip 当成 real-RIME Pass；
- MainActor flaky wait 采用有界、可失败的异步 polling，未修改生产延迟或引入 SLO；
- KeyboardCore full 894/0 通过，default gate、ADR 0025、Product Gate 和物理输入边界未改变；
- P3-D1 matrix 已将 T01 标为 `Partial (bounded)`，T02/T03 与 R01–R06 仍为 `NotRun`。

### 未证明

- T02 controlled Fake/Spike owner target harness；
- T03 visibility/reload lifecycle harness；
- real `RimeEngineImpl`/librime/Lua、PATH/READY、session identity、reset/recover late-result；
- App Group async persistence/suspend、真机 Human A/B、memory/jetsam、Release/iOS 26 RC；
- Product Gate、ADR 0025 Accept、Release default-on 或主观不卡顿。

### 后续授权建议

下一项应另行授权 P3-D1-T02/T03 target-level lifecycle harness，使用 controlled Fake/Spike 与
显式 diagnostic flags；必须继续保持 no-coordinate/no-Computer-Use input、content-free logs、
default gate-off 和独立 Run provenance。T01 结果交给独立 Architecture/Coordinator 汇总后，
再由 Product Lead 决定 real-RIME/device phase；不得把本次 harness repair 当作 runtime 或
Product Gate 完成。

## 7. 最终交接

**Quality disposition：Pass with conditions（bounded harness repair）；P3-D1-T01 Partial (bounded)。**

本复审到此停止。未修改生产逻辑、测试、ADR、Product Gate、默认开关、设备状态或真实运行时
证据；后续 target lifecycle、real RIME 与物理设备均需新的授权和独立证据复审。
