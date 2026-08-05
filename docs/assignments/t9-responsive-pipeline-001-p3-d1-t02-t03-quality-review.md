# 独立 Quality / Performance 复审：T9-RESPONSIVE-PIPELINE-001 / P3-D1-T02/T03

| 字段 | 结论 |
|---|---|
| 复审角色 | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| 复审日期 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | [`P3-D1-T02/T03 Lifecycle Harness`](t9-responsive-pipeline-001-p3-d1-t02-t03-lifecycle-harness.md) |
| 关联矩阵 | [`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md) |
| 复审基线 | `HEAD=3585a54`；当前 worktree 含其他任务的 ambient 改动，本复审不归因、不覆盖、不暂存 |
| Quality disposition | **Pass with conditions（bounded harness implementation）；T02/T03 runtime evidence 不接受为 Pass** |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 1** |
| 治理边界 | 不改生产逻辑、默认 gate、ADR 0025 状态、Product Gate、Release 或真机结论 |

本复审只判断 T02/T03 的 target-level controlled Fake/Spike harness、证据合同和测试归因。
它不把编译成功、KeyboardCore 测试或 host UI surface 观察升级为真实
`RimeEngineImpl`、librime/Lua、真机、持久化、jetsam、Release 或产品性能结论。

## 1. 复审范围与方法

已读并交叉核对：

- T02/T03 Assignment 的 authority、target boundary、privacy contract、stop/exit 条件和
  execution record；
- 同一工作项的独立 [`Architecture review`](t9-responsive-pipeline-001-p3-d1-t02-t03-architecture-review.md)，
  仅用于交叉核对生命周期屏障风险，不替代本 Quality 判定；
- 更新后的 P3-D1 matrix 中 T02/T03 状态（`Blocked (host accessibility)`）以及 T01、C01–C07
  的分层状态；
- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`、
  `Keyboard/Controllers/KeyboardViewController.swift` 中 `DEBUG &&
  T9_P3_D1_LIFECYCLE_HARNESS` 保护的 seam；
- `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift` 中
  T02/T03 的 host-driven XCTest；
- `ThreadAffineRimeWireTests` 的既有 bridge/owner 回归，以及默认 gate-off 条件；
- P2-D1 marker/evidence contract、Assignment Policy、Test/Release playbook 和文档治理规则。

本轮未修改生产代码、测试、Xcode 工程、ADR、默认设置或设备。执行器已经记录的构建和测试
数字按 bounded executor evidence 使用；本复审没有把它们写成新的重跑。当前 worktree 中
`git diff --check` 由本复审独立检查通过。

## 2. Evidence Matrix

执行记录的 Run ID 为 `P3D1-T02-T03-SIM-20260802-232552`，Simulator 为 iOS 27.0 /
iPhone 17 Pro Max / `06C5BC3E-7599-4761-A1A2-71DAEA991474`。执行器记录的条件与结果如下：

| 检查 | 记录结果 | Quality 解释 |
|---|---:|---|
| Keyboard Extension harness-on compile | **Passed** | `Debug` + `T9_P3_D1_LIFECYCLE_HARNESS` 的 target build 可完成；不等于 Extension lifecycle 已执行 |
| Keyboard Extension gate-off compile | **Passed** | 单独的 `Debug`、不带 harness flag 的 build 可完成；支持默认 gate-off 回归边界 |
| T02 host-driven UI invocation | **Blocked / Skipped** | Messages 有键盘 surface，但 XCTest 未获得可点击的 Apple system keyboard switcher |
| T03 host-driven UI invocation | **Blocked / Skipped** | 同一 host accessibility boundary；没有 lifecycle marker sequence |
| `ThreadAffineRimeWireTests` | **9 / 0** | Core/bridge 的 owner readiness、非等待 accept、gate-off 及 abandon/coalesce 回归；不是 target runtime 证明 |
| `Packages/KeyboardCore` full | **894 / 0** | 组件层 full regression；不能替代 target lifecycle 或真实 RIME |
| `git diff --check` | **通过** | 文本 diff hygiene；不证明 marker provenance 或 UI runtime |

记录中的 build log 和 result bundle 路径为：

- harness-on build：`/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T15-23-02-408Z_pid40269_2183099d.log`；
- gate-off build：`/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T15-27-40-359Z_pid40269_822d41a5.log`；
- T02/T03 result bundle：`/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-08-02T15-25-52-631Z_pid40269_da5268a7.xcresult`。

上述 XcodeBuildMCP 路径在本复审工作环境中不可重新打开，因此这些数字仍标记为“执行器
记录的快照”，而不是本轮新鲜重跑。它们可以支持 bounded disposition，但不足以单独闭合
T02/T03。

## 3. 已证明的正向边界

### 3.1 Harness 的隔离与默认开关

- Fake owner、生命周期 marker 和安装 seam 都位于实际 `Keyboard` Extension source root，
  没有复制一份 controller 到 XCTest target。
- seam 由 `#if DEBUG && T9_P3_D1_LIFECYCLE_HARNESS` 保护；工程默认
  `SWIFT_ACTIVE_COMPILATION_CONDITIONS` 只含 `DEBUG`，没有把 harness flag 写入 project/archive
  默认设置。
- `ThreadAffineRimeEngineBootstrap` 只传递配置值；engine 在 owner thread 创建、调用和释放，
  本次 seam 未使用 `@unchecked Sendable` 或把 live engine 假装成可跨隔离值。
- Fake 丢弃 key 参数，只保留 slot count 并返回 `·` placeholder-shaped value snapshot；marker
  不包含 pinyin、candidate、marked text、committed text、user dictionary 或 screenshot 内容。

### 3.2 生命周期边界修正

当前代码中：

- `APPEAR_BEGIN` 在 `resumePersistenceForExtensionLifecycle()` 之后记录；
- `SUSPEND_RELEASE` 在 `suspendPersistenceForExtensionLifecycle()` 之前记录；
- 已存在 coordinator 时会读取 `isOwnerReady`，不再把仅有 coordinator 实例误报为 ready。

这三点是合理的边界记录顺序，但它们仍是静态代码判断；本次 host 运行被阻断，未观察到
实际 target marker sequence。

### 3.3 Host blocker 的归因

T02/T03 在没有 hittable Apple system keyboard switcher 时走 `XCTSkip`，并明确写入
“Messages/iOS keyboard-switcher boundary; no product conclusion”。这项处理正确：

- `Skipped`/`Blocked` 不被转写为 Universe Keyboard 产品失败；
- 没有使用 coordinate-driven typing、Computer Use typing、数字页或候选/Path 点击替代；
- 不会因 host accessibility 缺失而伪造 owner-delay 或 visibility-return 通过。

因此，当前 T02/T03 状态应继续保持 **Blocked (host accessibility)**，而不是 Failed 或 Passed。

## 4. Quality Findings

### P2-T02/T03-Q1：P3LIFE marker 没有绑定唯一 Run ID，且不满足声明的字段合同

代码中的 `OWNER_READY`、`OWNER_BEGIN`、`OWNER_END` 和生命周期 marker 都硬编码
`run=P3D1-T02-T03`。这不是本次执行记录的 opaque Run ID，也没有从
`P3_D1_T02_T03_RUN` 或另一个显式 token 读取。因此多次执行不能按一个 marker stream 唯一
绑定到 source/build/device/run。

同时，Assignment 声明的 content-free contract 需要区分 accepted/applied revision，并保留
pending/coalesced/discarded、owner terminal、stale-result-rejected 等状态；当前
`p3d1RecordLifecycleMarker` 只有一个 `rev`、`pending`、`ownerReady` 和 `cleared`，没有
accepted/applied 双水位或 stale/discard/terminal 字段，也没有 P3LIFE validator。

这不是 raw-content 泄漏（当前 marker 仍然是 content-free），而是证据身份和完整性不足。
在修复前，任何后续 marker 都只能是观察日志，不能作为 T02/T03 Complete/Pass 的审计证据。

**必须修复：**由外部运行器为每次 arm 注入 canonical opaque run token；所有 P3LIFE marker
必须回显同一 token，并用一个 fail-closed validator 校验 schema、顺序、epoch/revision、
stale/clear 和终止状态。token 不得包含用户文本。

### P2-T02/T03-Q2：UI XCTest 的通过条件没有验证 harness 或生命周期合同

T02 的测试在激活后只检查三个 product-owned key 可点击、surface 仍存在和 host 进程在前台；
T03 只点击一个 key、离开/重进 Messages，再检查 surface 和前台状态。测试没有读取或断言：

- fake owner 的 150ms delay、`OWNER_BEGIN/END`、accept 顺序和无丢失/重复；
- `sessionEpoch`/`revision` 的 stale-result 拒绝；
- `DISAPPEAR` → `SUSPEND_RELEASE` → `RETURN_CLEAN` 的实际 marker 顺序和 cleared 值；
- controlled reload/fixture teardown 后的新 epoch 与旧 snapshot 丢弃。

另外，两个测试在 `prepareMessagesConversationForKeyboard` 没有观察到初始 keyboard surface 时
使用 `XCTFail`，而不是把“宿主没有提供键盘 surface”的条件归类为 `XCTSkip`/`Blocked`。当前
执行碰到的是 switcher 不可点击，因此走到了正确的 skip 分支；但另一种 host accessibility
缺失仍可能被 XCTest 报成红色产品失败。

因此，即使将来 host switcher 可用，若编译时忘了 harness flag，或生命周期清理未发生，这两
个 UI test 仍可能仅凭“surface 没消失”而表面通过。当前 run 被 `XCTSkip` 拦截，所以尚未
发生误报；但在修复前不能把 UI test 的 `Passed` 解释为 T02/T03 contract 通过。

**必须修复：**让测试或外部 content-free export 绑定并验证 P3LIFE marker sequence；T02 至少
验证 owner delay/accept/order/terminal，T03 至少验证 clear、epoch、stale rejection 和
controlled reload；初始 surface、switcher、selection 等宿主前置缺失都必须保持
`Skipped`/`Blocked`，不能 `XCTFail` 为产品失败。若 host 仍不可驱动，则继续 `Blocked`，不要
放宽断言。

### P2-T02/T03-Q3：执行快照与当前 source provenance 不一致

Assignment 中记录的 source fingerprints 是 harness-on/off 执行时的快照；当前工作树重新
计算得到：

| 文件 | Assignment 记录 | 当前 worktree |
|---|---|---|
| `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` | `42affb5627dfcf3529645cc4d9c2082c54b11163e59fa37d26d81c9f5b06ccd0` | `1a6fd734a544fdeced8c60c6c659f4894374196eb90b5f5ffe40d5ec5c62d5b3` |
| `Keyboard/Controllers/KeyboardViewController.swift` | `049159d1f62dce14dabdad2eb51a5da69f171aeb81bcc8aad31cf18b5f0b70c6` | `d6a5fa45901bcb0658fdc0ce13ad22c469e3e40c0cf4d89f59ebb761e40327bc` |
| `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift` | `f6d89b65f6066c788d84c214275d41f016df576e570f6d2998b446c20d2d3f66` | `f6d89b65f6066c788d84c214275d41f016df576e570f6d2998b446c20d2d3f66` |

这与随后补入生命周期记录顺序/owner readiness 边界修正一致。结果不是代码失败，但意味着
当前 Run ID 的 build/skip 证据不能直接绑定最终 source。若不重新构建，复审只能针对“旧快照”；
不能把它作为当前 tip 的最终 evidence。

**必须修复：**在下一次 host 可用的 rerun 中重新生成 harness-on、gate-off、T02/T03 bundle
和 source/build hashes；把旧 Run ID 标为 superseded snapshot，或明确把修正后的源码重新绑定
到新的 Run ID。不得用旧结果补齐新代码的证明。

### P2-T02/T03-Q4：suspend 后重建 owner 可能复用 epoch，缺少生命周期 generation barrier

当前 Extension 路径先执行 `suspendRimeForVisibilityChange()`（flush/stop owner、置空 owner），
再在 `abandonCompositionForVisibilityChange()` 中调用 `affine.bumpSessionEpoch()`。此时 owner
已经不存在，`advanceSessionEpoch()` 可能返回 `nil`；visibility return 随后新建一个从 epoch 1
开始的 owner。owner 停止不会撤回已经排入 MainActor 的 NotificationCenter snapshot，
`sink.clearLastPublished()` 也不会取消已排队通知。如果旧 epoch 1 的通知在新 owner 建立前后
交付，当前 live presentation check 可能把它看成新 epoch 1 的快照。

这是一个从静态生命周期顺序得到的 fail-closed 风险，本次 host 阻断没有把它观察成实际回归；
它不改变 gate-off ADR 0004 的同步路径，但会阻止 T03 的旧 snapshot 不泄漏合同通过。

**必须修复/证明：**在停止 owner 前后建立不可复用的 lifecycle generation/session identity，或
让排队 delivery 携带 generation 并在新生命周期拒绝；至少补一个 owner 被 150ms 阻塞、随后
hide/return、延迟旧 result 的 negative regression。此修复不得打开默认 gate、改变 ADR 0004
同步路径或使用 unsafe isolation。

## 5. Gate-off、隐私与测试分层判定

| 层 | Quality 判定 |
|---|---|
| Gate-off / ADR 0004 | **Bounded positive**：工程未加入 harness 默认 flag，`ThreadAffineRimeWireTests` 的 gate-off 回归为 9/0；仍需以当前 tip 重新构建绑定后才可关闭 provenance 条件 |
| Harness-on compile | **Bounded positive**：记录显示 target 可编译；没有 target lifecycle runtime 事实 |
| Content-free privacy | **Static positive**：当前 seam 不写 raw key/candidate/host text；仍需在真实 marker export 上跑 privacy scan |
| T02 owner responsiveness | **Blocked / Not proven**：没有 host activation，未观察 delay/accept/order marker sequence |
| T03 visibility/reload | **Blocked / Not proven**：没有 disappearance/return marker sequence，也未执行 controlled reload proof |
| Real RIME / Lua / schema | **NotRun** |
| Physical device / persistence / jetsam / Release / Product Gate | **NotRun** |

`ThreadAffineRimeWireTests 9/0` 与 `KeyboardCore 894/0` 证明的是 Core/bridge bounded behavior：
它们不能替代实际 Extension process，也不能把 skipped host run 改成 runtime Pass。

## 6. 必须修复条件与下一步

在 T02/T03 可以进入 `Passed` 或交付 Product Lead 进行阶段决策前，至少需要：

1. 让每次运行拥有唯一、opaque、可复核的 P3LIFE run token，并补 fail-closed marker validator；
2. 让 T02/T03 断言 owner/lifecycle marker，而不只断言 host surface；T03 增加 controlled
   reload/fixture teardown 的旧 epoch/snapshot 拒绝证据；
3. 针对当前最终 source 重新执行 harness-on 与 gate-off build，重跑 `ThreadAffineRimeWireTests`
   和 KeyboardCore full，并更新 source/build/result-bundle hashes；
4. 明确记录 UI test 的完整命令、scheme、destination、env gate 和 result bundle，且把旧
   `P3D1-T02-T03-SIM-20260802-232552` 标记为旧快照或重新绑定；
5. 继续保持 `#if DEBUG && T9_P3_D1_LIFECYCLE_HARNESS`、responsive/default gate-off、ADR
   0025 Proposed、无 `@unchecked Sendable`、无 raw-content export 和 no-coordinate 输入边界。

若 host switcher 仍不可访问，应保留 `Blocked (host accessibility)`，另行提供经授权的
target driver；不得把失败改写为产品失败，也不得用纯 Core fake 替代实际 target boundary。

## 7. Release / Product Decision

当前建议为：**可以继续交付 bounded harness 到修复、重新取证和独立复审；不建议当前交付为
T02/T03 runtime Pass、ADR 0025 Accept、Release default-on、Product Gate 或真实 off-main
RIME 完成。**

本复审没有发现 P0/P1 的生产行为问题；但四个 P2 证据/生命周期条件使 T02/T03 不能关闭。P3-D1 parent
matrix 应继续保持 `Active`，T02/T03 保持 `Blocked (host accessibility)`，R01–R06、真实
RIME、设备与 Release 继续 `NotRun`。

## 8. Handoff 与停止点

### 已证明

- harness seam 在实际 Extension target，且由显式 DEBUG + harness flag 保护；工程默认没有把
  flag 写入 Release/project 设置；
- owner engine 不跨隔离传递 live handle，本次实现没有 `@unchecked Sendable`；Fake 与 marker
  内容静态上符合 no-raw-content 方向；
- APPEAR_BEGIN、SUSPEND_RELEASE 和 owner readiness 的顺序修正已存在于当前代码；
- host switcher 缺失被正确分类为 `XCTSkip`/environment boundary；
- 执行器记录的 harness-on/off build、Wire 9/0、Core 894/0 和 `git diff --check` 可作为
  bounded snapshot。

### 未证明

- 当前 source 对应 Run ID 的实际 target lifecycle；
- P3LIFE token/marker schema 的唯一绑定、validator 完整性和导出 privacy scan；
- T02 MainActor accept 在 owner 延迟期间的实际 target 观察、T03 visibility/reload 的 epoch
  清理与 stale rejection；
- real `RimeEngineImpl`/librime/Lua/schema、App Group durability、physical Human input、
  jetsam、Release signing、Product Gate 或任何主观不卡顿 SLO。

**Quality disposition：Pass with conditions（bounded implementation）；T02/T03 runtime
evidence blocked and not accepted.** 本复审到此停止，交由实现者修复上述 P2 provenance/marker/
assertion 条件后，再由独立 Architecture 与 Quality 复审；没有自行宣布 Spike/ADR/Product
Gate/Release 通过。
