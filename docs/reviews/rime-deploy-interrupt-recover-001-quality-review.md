# RIME-DEPLOY-INTERRUPT-RECOVER-001 独立质量、性能与发布复审

**复审日期：** 2026-09-11（Asia/Shanghai）  
**复审 lane：** KOS Quality, Performance & Release  
**复审范围：** 隔离工作树 `/Users/doubleshy0n/Dev/uk-rime-deploy-recover`，实现基线 PR [#115](https://github.com/shchnk1103/Universe-Keyboard/pull/115) head `805f6ce`（完整 `805f6ceed42c3dc8abacb683015cb15ec01d1db8`）  
**基线：** `origin/main` `fe2655152cbbefc61734afe519ef7b16e722aaa4`  
**Assignment：** [RIME-DEPLOY-INTERRUPT-RECOVER-001](../assignments/rime-deploy-interrupt-recover-001.md)

本复审只读核对 `805f6ce` 相对 `origin/main` 的生产/测试差异、中断/取消/重试不变量、CS-05 是否被碰到、隐私、hosted CI 与 Human-attested 覆盖安装记录。本 lane **没有** 修改产品 Swift、测试、`CHANGELOG` 行为或 Assignment Current Status；本文件是唯一新增产物。Architecture Reviewer 按 Assignment 为 `Not Applicable`，本文件 **不** 给出 Architecture 结论。

本地未推送的 Assignment 补录 `e547192` **不** 纳入实现裁决。

## Verdict

**Pass with conditions。** 无开放 P0/P1。切片在 `805f6ce` 上证明：孤儿 `rime_deploying` 恢复为可重试 `.failed` 且抑制自动重试；进行中部署可在不阻塞 UI 的情况下取消；失败态「取消」仍回到 `.idle`；取消/过期结果不得靠 UI generation 与 deployment ID 覆盖后续重试。CS-05 卸载路由文件未改。hosted CI 全绿是机器证据，**不是** Quality Pass 本身。Human 覆盖安装是 Human-attested，不是 Device-attested，也不是 Product Gate。

本结论 **不** 关闭 Assignment，**不** 授权 merge / TestFlight / Product Gate / Release。Human merge 仍未授权。

| 严重级别 | 数量 |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 2（均已 disposition，见残差表） |
| P3 | 0 |

### 条件

退出本 Quality 片仍要求残差表中的 disposition 保持有效；后续 Human merge 另需 **同一 head** `805f6ce` 的 hosted CI 全绿（本审查已观察到）以及新的 Human 授权。不得把 TD-018 或 leftover librime 编译当成本片已实现。

## 已通过的证据

| 领域 | 当前证据 | 结论 |
|---|---|---|
| 孤儿 `rime_deploying`、无 live task | `testLoadTreatsOrphanedDeployingFlagAsFailedWithoutAutoRetry`（`UniverseKeyboardTests/RimeSettingsStoreTests.swift` L555–L593）：`load()` 后 `.failed`、`rime_deploying=false`、`rime_needs_deploy=true`、`rime_deploy_auto_retry_suppressed=true`、`triggerPendingDeploymentIfNeeded` 请求数 0；随后手动 `triggerDeployment` 请求数 1 且 `.deployed` | **通过**（单元路径）。源码：`refreshDeploymentState` 先 `reconcileOrphanedInProgressDeploymentIfNeeded`（`RimeSettingsStore.swift` L745–L757、L930–L946） |
| 活部署取消、不等待完成、无自动重试 | `testCancelLiveDeploymentReleasesRetryWithoutWaitingForCompletion`（同文件 L595–L642）：进入 `.deploying` 且 `rime_deploying=true` 后 `cancelDeployment()` 立即 `.failed`、清闩锁、置 suppress；`await deployTask` 后仍 `.failed`；`triggerPendingDeploymentIfNeeded` 不增加请求；手动重试请求 2 且 `.deployed` | **通过**（协作式测试替身）。产品路径：`cancelDeployment` 先 bump `deploymentUIGeneration` 再 `cancelActiveRimeDeployment()`（L727–L734）；`performRimeDeployment` 在 librime 返回后用 ID 丢弃写回（`SchemaManager+Deployment.swift` L130） |
| 失败态取消仍 idle | `testCancelFailedDeploymentStillResetsToIdle`（L644–L653） | **通过**（仅内存 UI）。与进行中取消的 persist 路径分离，符合既有「取消=关掉失败条」 |
| CS-05 / 卸载路由 | `git diff --name-only origin/main...805f6ce` 仅 7 文件；`SchemaManager+Installation.swift`、`RimeRuntimeRouteReconciliation.swift`、`SchemaManagerTests` **无 diff**。`uninstallSchema` 仍只 `requestDeploy()`，不在卸载 Task 后 `triggerPendingDeploymentIfNeeded()` | **未误改**。万象保持 active、无 Luna fallback 不在本 diff 内 |
| Hosted CI（同一 SHA） | GitHub check-runs on `805f6ceed42c3dc8abacb683015cb15ec01d1db8`：Swift 6 Quality run `34604935033` — `classify-change` success、`lightweight-checks` success、`build-and-test` success、`final-quality-gate` success；GitGuardian success。分类脚本本地：`full` / `requires_full=true` | **机器证据通过**。不能单独构成 Quality Pass 或 merge 许可 |
| Human-attested 覆盖安装 2026-09-11 | Assignment History、`docs/DEBUGGING.md` L96–L102、`TD-018` 记录：首次打开为部署失败且可重试；之后万象 active 时卸雾凇，前台未自动部署，手动部署成功 | **Human-attested**。不是 Device-attested，无冻结 payload manifest / UUID / journal 附件；不升级为 Product Gate |
| 隐私 | 本 SHA 未新增 `Logger` 行；部署 UI 日志为固定中文状态句；既有 `deployRimeConfig:` 行不含 host 文本或文件系统路径 | **源码审计通过** |
| ADR 0001 跟进 | 主 App 部署状态在孤儿闩锁与取消后保持可操作（失败+手动重试），符合 Accepted ADR 0001 follow-up「Keep deployment status actionable」 | **范围内成立**。不是 Architecture 复审 |

## Findings

无 P0/P1。

### P2-01：UI 取消不能中止 blocking librime；取消后立即重试可能与残留编译重叠

`RimeDeploymentService` 是 actor，`deploy` 内 `deployOperation` 为同步 librime（`Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift` L62、L112–L153）。`cancelActiveRimeDeployment()` 只把 `activeRimeDeploymentID` / `activeRimeDeploymentTask` 置空并 `task.cancel()`（`SchemaManager+Deployment.swift` L42–L48）。协作检查点在 `await deploy(...)` **之后**（L130、L182–L184），因此：

- UI 可在 librime 进行期间恢复（`deploy` 不占用 MainActor），这是本片要的可操作性；
- 取消不会停止已经进入 actor 的编译；
- `hasLiveRimeDeployment` 在 handle 被清空后为 false，另一次 `deployRimeConfig` 可以开工。overlay / `deploymentDirectories()` 写在 actor 调用之前（L79–L118），可能与残留编译重叠。ID / `deploymentUIGeneration` 仍阻止过期 **标志** 覆盖后续重试。

单元替身 `StoreDeploymentService` 在 `Task.isCancelled` 时退出 hang（`RimeSettingsStoreTests.swift` L1344–L1349），**没有** 模拟非协作 librime，也没有在残留编译仍运行时启动第二次 overlay。这不否定切片合同（取消结果不得覆盖后续重试），但是发布时不得声称「取消即停止编译」。

Disposition：`accept`（见 `RDIR-01`）。

### P2-02：非活动卸载后前台不自动部署（TD-018）

`ContentView` 仅在 `scenePhase` 进入 `.inactive`/`.background` 或冷启动 `.task` 调用 `triggerPendingDeploymentIfNeeded()`（`Universe Keyboard/App/ContentView.swift` L218–L244）。`RimeSettingsStore.uninstallSchema` 仍只转发 `schemaManager.uninstallSchema`（`RimeSettingsStore.swift` L594–L595）。Human-attested 已观察到该行为。这不是 CS-05 路由错误，也不是本片回归。

Disposition：`tech_debt:TD-018`（见 `RDIR-02`）。

## 状态机与竞态（源码核对）

| 键 / 字段 | 孤儿恢复 | 进行中取消 | 手动重试 |
|---|---|---|---|
| `rime_deploying` | `markCurrentDeploymentInterrupted` 写 false（Store L937–L943 与 SchemaManager L34–L39 双写） | 同上 | `persistDeploymentInProgress` 在 `await deployRimeConfig` 前写 true（L688、L921–L926） |
| `rime_needs_deploy` | true | true | 成功路径由 `performRimeDeployment` 清 false；失败保持 true |
| `rime_deploy_auto_retry_suppressed` | true；`triggerPendingDeploymentIfNeeded` 见 suppress 则 return（L706–L710） | true | 手动成功清 false（L693–L695）；`requestDeploy()` 作为新意图也会清 false（`SchemaManager+Deployment.swift` L13–L15） |
| `deploymentUIGeneration` | 取消时 bump，使仍在 `await` 的 `triggerDeployment` 在 L691 丢弃 UI 写回 | 同上 | 新 `attemptID` |
| `activeRimeDeploymentID` | 无 live task | `cancel` 置 nil，后置 checkpoint 拒绝写成功/失败标志 | 新 UUID，且 **在** 创建 Task 之前赋值（L58–L64），避免空窗 |

生产默认 Store persistence 与 `SchemaManager` settings 是两个 App Group 包装；调和与中断路径对 `rime_deploying` **两边都读/写**，避免单边孤儿。测试用同一 `StoreSharedSettingsStore` 注入两边，不覆盖包装分叉，但不构成 P1。

`seedFirstLaunchBuiltinDeploymentIntentIfNeeded` 在 `rime_deploying` 为 true 时不种子（L790–L796），随后 `load()` → `refreshDeploymentState()` 走孤儿失败，避免把中断当成首次安装自动部署。

## CS-05 / Architecture N/A

本审查 **不争议** Architecture `Not Applicable`。diff 未改 inactive uninstall routing、Luna fallback 或 ADR 0034。本片是 ADR 0001 已接受决策的跟进（部署状态保持可操作），不是新的架构边界。若未来把 TD-018 做成卸载后前台自动 `triggerPendingDeploymentIfNeeded()`，那是 **另一 Assignment**，不得混进 #115。

## Human-attested 覆盖安装（诚实分级）

记录来源：Human Product Owner 2026-09-11；写入 Assignment History、`DEBUGGING.md`、`TD-018`。声称：

1. 覆盖安装后首次打开：部署失败且可重试（取消/重置可见）——与孤儿闩锁恢复一致；
2. 之后万象为 active 时卸载雾凇：前台 **没有** 自动开始部署；手动部署成功——与 TD-018 一致，并侧面说明 CS-05 路由未被改成 Luna。

**Grade：Human-attested。** 本 Quality 未操作设备，未见二进制 UUID/SHA、App Group 快照或 journal 附件。按 [`universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md) **不是** Device-attested，也 **不是** Quality-reverified 真机。它足以支撑「闩锁恢复在一次覆盖安装上可操作」的工程叙述，不足以关闭 Product Gate。

## 隐私

`805f6ce` 未新增 Logger 调用。`deploymentLog` 使用固定中文句（「上次部署被中断…」「已取消部署…」），无 host 文本、无路径、无输入内容。既有 `deployRimeConfig:` 信息行含 schema 能力计数等，属既有部署日志，本 SHA 未扩大。

## M-03 残差

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `RDIR-01` | Main App RIME 部署编排 | `accept` | P2-01：取消恢复 UI，不中止 librime；ID/generation 防标志覆盖。`SchemaManager+Deployment.swift` L42–L48、L116–L130；`RimeDeploymentService.swift` L112–L153 |
| `RDIR-02` | `RIME-DEPLOY-INTERRUPT-RECOVER-001` 范围外；主 App uninstall orchestration | `tech_debt:TD-018` | [`TD-018`](../TECH_DEBT.md#td-018-foreground-auto-deploy-after-inactive-scheme-uninstall)；`ContentView.swift` L218–L244 |
| `RDIR-03` | Human Device Operator / 后续正式真机 Assignment（若产品要求） | `accept` | 覆盖安装证据保持 Human-attested；本片未要求 Device-attested |

## 明确跳过的检查

本审查 **没有** 重跑完整 `xcodebuild` / `swift test`。机器测试证据引用 hosted Swift 6 Quality run `34604935033` on **同一** `805f6ce`（`build-and-test` 含 App + Keyboard，因此含 `RimeSettingsStoreTests`）。本地仅做：

```text
git diff --name-only origin/main...805f6ceed42c3dc8abacb683015cb15ec01d1db8
git diff --check origin/main...805f6ceed42c3dc8abacb683015cb15ec01d1db8
python3 scripts/ci/classify_changes.py --base origin/main --head 805f6ceed42c3dc8abacb683015cb15ec01d1db8
# classification=full; requires_full=true; 7 files
gh api .../commits/805f6ceed42c3dc8abacb683015cb15ec01d1db8/check-runs
```

未执行：本机 Simulator 全套、RimeBridgeTests 单独重跑、Debug/Release 本地 build、真机 overlay 复测、journal 读取、Product Gate、merge。Executor 自检与聊天记录不构成本裁决。

## 交接结论

`805f6ce` / PR #115 满足本切片的质量条件通过（Pass with conditions）：孤儿闩锁可恢复、进行中可取消、取消不自动重试、失败取消仍 idle、CS-05 未改。接受 `RDIR-01` leftover compile；TD-018 保持债务。下一步若 Human 授权 merge，必须仍钉在 **同一** head，且不得把本文件当作 merge、TestFlight 或 Product Gate 许可。
