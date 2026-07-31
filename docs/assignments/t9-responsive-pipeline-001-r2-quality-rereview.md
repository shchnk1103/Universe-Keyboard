# Quality Re-review: T9-RESPONSIVE-PIPELINE-001 R2 P1 remediation

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（independent re-reviewer） |
| Date | 2026-07-30 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Prior Quality review | [`t9-responsive-pipeline-001-r2-quality-review.md`](t9-responsive-pipeline-001-r2-quality-review.md) |
| Executor addendum | 同文件 § Executor P1 remediation addendum；Assignment R2 P1 remediation 段 |
| Scope | R2 **P1 remediation only** — presentation bridge + dual-entry order wiring + 相关 R2 测试 |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 0**  
**P2: 4**  
**P3: 3**

---

## Commands re-run

Independent re-run on this machine (do **not** trust Executor counts alone):

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard/Packages/KeyboardCore" && swift test --filter ResponsiveRime
```

| Suite | Executed | Failures |
|---|---:|---:|
| `ResponsiveRimePipelineTests` (R1) | 23 | 0 |
| `ResponsiveRimeR2CoordinatorTests` (R2) | **10** | 0 |
| **Filter total** | **33** | **0** |

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard/Packages/KeyboardCore" && swift test
```

| Suite | Executed | Failures |
|---|---:|---:|
| `KeyboardCoreTests` / All tests | **811** | **0** |

Notes:

- Focused suite grew from prior Quality review’s **7 → 10** R2 cases（含 presentation bridge / bridge delete / shared publish handler / gate off restore 等补救测试）。
- Full suite **811/0**（先前 R2 Quality 为 808/0）；无 false green。
- 未跑 `xcodebuild` App/Extension target；未跑 Simulator / 真机 / 真实 librime。

---

## P1 disposition

### Quality P1 — presentation bridge：**Closed**

原 R2 Quality P1：gate-on 异步 publish 只改 Core state，**没有**回调 Extension `syncUI` / `KeyboardEffect`，因此即便 Core 更新，可见 composition / candidates / marked text 也可能不刷新。

补救后独立核对：

| 环节 | 证据 |
|---|---|
| Core 二次通知 API | `KeyboardController.onResponsivePresentationNeeded` |
| Snapshot 应用后发射 | `applyResponsivePublishedSnapshot` → `applyRimeOutput` 后强制带 `.compositionChanged`（T9 时再带 `.t9PinyinPathsChanged`），并调用 callback |
| Deferred drain 触发 publish | `scheduleProcessKey` + `scheduleResponsivePipelineDrain` → `setPublishHandler` → 上述 apply |
| Extension 接线 | `KeyboardViewController+Bootstrap.bootstrapKeyboard`：`onResponsivePresentationNeeded = { syncUI(with:) }` |
| Engine 安装后 rebuild | `activateRimeRuntimeAfterKeyboardPresentation` 调用 `rebuildResponsiveRimeCoordinatorIfNeeded()` |
| 单元测试 | `testControllerGateEnablesDeferredProcessKeyAndPresentationBridge`：gate on 时 `handle(.insertKey)` 在 engine 调用前返回，随后 expectation 收到含 `.compositionChanged` 的 presentation effect |

**判定：** 原 P1 合同（async publish → presentation re-entry 通道）在 **Core + Bootstrap 接线 + 包测** 层面 **Closed**。  
**非夸大：** 未自动化证明 Extension `syncUI` 真机刷新、marked-text 宿主投影、或 T9 Path 栏在 gate-on 下与 gate-off 语义完全等价（见下方 P2 residual）。

### 与 dual-entry / order 相关的补救（原 Quality 条件项，非新的 P1）

Executor / Architecture addendum 中的 dual-entry 与 multi-accept 补救，本 re-review 一并验收：

| 项 | 状态 | 证据 |
|---|---|---|
| `ResponsiveRimeEngineBridge` 作为 gate-on `rimeEngine` | **Met（unit）** | rebuild 安装 bridge；`testGateOffAfterOnRestoresUnderlyingEngine` |
| `performOrderedNow` / `flushPending` 全队列 drain | **Met** | `SerialRimeSession.swift`；Delete 不得越过 pending keys |
| key 后 Delete 顺序 | **Met（bridge 层）** | `testDeleteThroughBridgeWaitsForPendingProcessKey`：schedule `n`/`i` 后 `rimeEngine.deleteBackward()` → composition `"n"` |
| 多 accept 共享 publish handler | **Met** | `setPublishHandler` + `testOrderedKeysShareSinglePublishHandler`（修原 P2-1 死回调） |
| Bridge select 绑定 lastPublished | **Met** | `testBridgeSelectBindsToLastPublished` |
| default-off 仍成立 | **Met** | 源码 `= false`；生产无 `= true`；仅测试显式开启 |

原 Quality Conditions 中 “Delete/Path/candidate 共享同一 ordered owner” 在 **gate-on + bridge 安装后** 的 *session API 入口* 上已大幅收口（经 `RimeEngine` 协议的路径走 bridge）。**仍不**等于：T9 Path 语义、auto-anchor 后处理、或全 `handle` 多手势矩阵已齐（P2）。

---

## Findings

### P0 — none

- 无 Release default-on。
- 无 App / Keyboard Extension force-enable `isResponsiveRimePipelineEnabled`（grep 仅测试赋值 `true`）。
- 无 `@unchecked Sendable` 绕过。
- 聚焦 33/0、全量 811/0，无 false green。
- 未引入 raw input / candidate / host text 隐私日志面。

### P1 — none remaining (Quality)

- Presentation bridge P1 **Closed**（见上）。
- 不把 Architecture 的 off-MainActor residual（原 Arch P1-3）重新升为 Quality P1：该 residual 已诚实记录，且 **不**在 default-off 下影响 Release。

### P2 — remaining test / confidence gaps

1. **Controller `handle` 级多动作矩阵仍偏薄。**  
   现有顺序证明主要在 **coordinator / bridge 直接 API**（`scheduleProcessKey` + `rimeEngine?.deleteBackward()`）。缺少 gate-on 下 `handle(.insertKey)` → `handle(.deleteBackward)` / candidate select / Path action 的端到端 controller 测试。`handleDeleteBackward` 虽走 `engine.deleteBackward()`（gate-on 时即 bridge），但 **未被独立断言**。

2. **Presentation bridge 的 Extension 侧无包测。**  
   Core 断言 callback 含 `.compositionChanged`；Bootstrap → `syncUI` 为薄接线，**未**在本 Quality 命令集中用 UI/Extension 测试验证。对 “可选 Debug 实验” 可接受，但不得写成端到端 UI 合同已绿。

3. **异步 publish 后 T9 Path / auto-anchor 后处理仍不等价于 sync 路径。**  
   `applyResponsivePublishedSnapshot` 会打 `.t9PinyinPathsChanged` 标记，但未见与 sync 热路径同等的 Path 重算 / auto-anchor 推进 / reject-after-key 等。gate-on 下九宫格 Path 栏与 auto-anchor 行为仍可能漂移（R3 范围 residual；**阻塞“宽面 Debug 打字实验”信心**）。

4. **符号页 `replaceInput` 仍同步 `performOrderedNow`（阻塞 `handle`）。**  
   注释已更诚实（“may wait”），但 gate-on 子集仍非 deferred。可接受为 R2 有意 trade-off；测试未单独覆盖该分支。

### P3

1. **`completedPublishCount` 语义仍易误解**（含非 UI 成功路径的 `processNext` 计数倾向；命名 residual）。  
2. **真实 librime / 设备主观不卡 / 长句尖峰** 未测；MainActor deferred drain 仍可能在 drain turn 占用 UI 线程（Architecture residual，非本 re-review 关闭项）。  
3. **R1 sleep-clock / soft budget** 模式仍在个别 defer 用例中；注意 suite 预算，非阻塞。

---

## Default-off / production isolation

| Check | Result |
|---|---|
| Default `isResponsiveRimePipelineEnabled` | **`false`**（`KeyboardController` 属性初始化） |
| Production / Extension / App force-on | **无**（全仓 swift 仅测试置 `true`） |
| Gate-off path | 默认仍 ADR 0004 同步 `rimeEngine`；`testGateDefaultIsOffAndControllerStaysSynchronous` |
| Gate on→off 恢复 underlying | `testGateOffAfterOnRestoresUnderlyingEngine` |
| `@unchecked Sendable` | **无** |
| Off-main librime 声称？ | **否** — residual 仍 MainActor single-consumer + deferred drain |
| **Shipping / 实验建议** | **Keep gate default off。** 本 re-review **不**授权 Release 开启，**不**把 P1 Closed 解读为可默认启用。 |

---

## Multi-action gate-on：是否 confidence-safe（仅可选 Debug 实验）

| 维度 | 结论 |
|---|---|
| Composition key deferred + presentation re-entry | **单元级可信心**（presentation bridge Closed） |
| Pending keys 后 Delete（bridge 入口） | **单元级可信心**（`testDeleteThroughBridgeWaitsForPendingProcessKey`） |
| Bridge select fail-closed / lastPublished 绑定 | **单元级部分可信心** |
| `handle` 级 key→delete / Path / candidate 交错 | **不足** |
| T9 Path 原子刷新 / auto-anchor 等价 | **不足** |
| Extension 真机 `syncUI` / 真实 librime | **未证** |
| 非卡顿产品目标 | **未证**（MainActor drain residual） |

**综合：** multi-action gate-on **尚不足以** 称为 “宽面可选 Debug 打字实验 confidence-safe”。  
仅在 **窄范围、知情 residual** 的内部 Debug 探测（例如：验证 deferred key + presentation callback + bridge Delete 顺序）上，比补救前 **更可做**；仍须 **默认关闭**，且 **不得**当作 Human/设备 A/B 或 Product 启用依据。

---

## Explicit non-claims

- **Not** Architecture Pass（不重判 ADR 0025 Accept / off-MainActor residual）。
- **Not** Product Gate。
- **Not** 授权 Release 或用户面构建 default-on。
- **Not** 声明 gate-on 九宫格 Path / partial-commit / auto-anchor 与 sync 路径行为等价。
- **Not** 声明真实 UIKit + librime 下按键主观不卡。
- **Not** R3+ 授权。
- **Not** 用本文件替代独立 Architecture re-review（若 Product 要求）。

---

## Recommended next steps (quality view)

1. **Keep `isResponsiveRimePipelineEnabled` default off**（Release 与一切用户面配置）。  
2. **Quality P1 presentation bridge 记为 Closed**；后续变更若拆除 Bootstrap 接线或静默吞掉 callback，应回归本测试。  
3. 若 Product 仅想做 **可选 Debug 实验**：  
   - 仅限窄场景 + 显式 force-on 开关（仿 auto-anchor preflight 隔离方式更佳）；  
   - 先补 **handle 级** key→delete 与 candidate 顺序测试；  
   - 明确 **不做** 宽面 T9 Path/长句结论。  
4. R3 质量门槛建议：Path 在 publish 后重算或诚实关闭 gate-on Path 承诺；auto-anchor 后处理策略；visibility 与 pending drain 交错测试。  
5. 全量 / 聚焦命令保持为 R2 回归底线；任何再接线后应再跑 `swift test --filter ResponsiveRime` 与 `swift test`。

---

## Verdict rationale (summary)

R2 P1 remediation 在 **独立复跑绿测 + 源码接线核对** 下，关闭了原 Quality **P1 presentation bridge**，并显著收紧了 gate-on dual-entry / multi-accept / Delete-after-pending 的可测合同。Release **default-off 隔离仍成立**。  
Verdict 为 **Pass with conditions**：条件是 **继续默认关闭**、不把单元级 bridge 顺序证明夸大为宽面 Debug/设备启用信心，并保留 P2/P3 residual 直至 R3 或明确收窄实验范围。
