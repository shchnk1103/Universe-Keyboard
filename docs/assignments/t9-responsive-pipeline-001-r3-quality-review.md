# Quality Review: T9-RESPONSIVE-PIPELINE-001 R3

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（independent） |
| Date | 2026-07-30 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Product Decision | [`../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) |
| Executor evidence | [`../evidence/t9-responsive-pipeline-r3-2026-07-30.md`](../evidence/t9-responsive-pipeline-r3-2026-07-30.md) |
| Prior Quality | R2 [`t9-responsive-pipeline-001-r2-quality-review.md`](t9-responsive-pipeline-001-r2-quality-review.md)；R2 P1 re-review [`t9-responsive-pipeline-001-r2-quality-rereview.md`](t9-responsive-pipeline-001-r2-quality-rereview.md) |
| Scope | R3 default-off behavior parity：Path/auto-anchor post-publish context、`handle` key→delete 顺序、`underlyingRimeEngine` chrome unwrap、相关测试 |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 1**  
**P2: 4**  
**P3: 3**

---

## Commands re-run

Independent re-run on this machine（**不**信任 Executor counts alone）：

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard/Packages/KeyboardCore" && swift test --filter ResponsiveRime
```

| Suite | Executed | Failures |
|---|---:|---:|
| `ResponsiveRimePipelineTests` (R1) | 23 | 0 |
| `ResponsiveRimeR2CoordinatorTests` (R2+R3) | **12** | 0 |
| **Filter total** | **35** | **0** |

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard/Packages/KeyboardCore" && swift test
```

| Suite | Executed | Failures |
|---|---:|---:|
| `KeyboardCoreTests` / All tests | **813** | **0** |

Notes:

- Focused suite：**35/0**（R2 re-review 时为 33；R3 新增至少 `testHandleKeyThenDeleteThroughBridgePreservesOrder`、`testResponsiveApplyRunsPathRefreshContext` 等）。
- Full suite：**813/0**（R2 re-review 为 811/0）；无 false green。
- 未跑 `xcodebuild` App/Extension；未跑 Simulator / 真机 / 真实 librime。

---

## Exit criteria coverage

R3 authorized intent（PD + Assignment + evidence）：default-off only；gate-on **behavior parity** for Path / auto-anchor after deferred publish；`handle`-level multi-action order tests；Extension chrome via `underlyingRimeEngine`；无 Release default-on；无 off-main librime；无 `@unchecked Sendable`。

| Criterion | Status | Independent evidence |
|---|---|---|
| `isResponsiveRimePipelineEnabled` **default false** | **Met** | `KeyboardController.swift` 属性初始化 `= false`。全仓 production sources 无 `= true`；仅 `ResponsiveRimeR2CoordinatorTests` 显式开启。 |
| 无 App / Extension / settings force-on | **Met** | Grep：flag 仅出现在 `KeyboardController` / `+RimeRecovery` 与测试；无 UserDefaults / settings 接线。 |
| Path / auto-anchor post-processing after deferred publish | **Partial** | `ResponsiveKeyApplyContext` + `enqueueResponsiveKeyApplyContext` + `applyResponsivePublishedSnapshot` 在有 ctx 时调用 `rejectUnusable…` / `retainFocusedT9Segment…` / `advanceAcceptedT9AutoAnchorDigit` / `attemptReversibleT9AutoAnchorIfNeeded` / `refreshT9PinyinPathState`。**单测只断言** `.t9PinyinPathsChanged` 与 contexts 清空，**未**断言 path 内容或 auto-anchor 等价于 gate-off。 |
| `handle` key→delete order | **Met（unit, weak settle）** | `testHandleKeyThenDeleteThroughBridgePreservesOrder`：`handle(.insertKey)`×2 → `handle(.deleteBackward)` → composition `"n"`。仍依赖 main-async + 可选 `flushPending` settle。 |
| Bridge Delete-after-pending（R2 保留） | **Met** | `testDeleteThroughBridgeWaitsForPendingProcessKey` 仍绿。 |
| `underlyingRimeEngine` chrome unwrap | **Met（source）** | `KeyboardController.underlyingRimeEngine`；Extension `KeyboardViewController.swift` / `+Feedback.swift` 改用 `underlyingRimeEngine as? RimeEngineImpl`。测试：`testGateOffAfterOnRestoresUnderlyingEngine` 断言 bridge 下 underlying 身份。 |
| Presentation bridge（R2 P1）仍在 | **Met** | Bootstrap `onResponsivePresentationNeeded → syncUI`；`testControllerGateEnablesDeferredProcessKeyAndPresentationBridge` 仍绿。 |
| 强制 everyResult 以对齐 context FIFO | **Implemented（trade-off）** | `rebuildResponsiveRimeCoordinatorIfNeeded` 将 `.latestOnly` 强制为 `.everyResult`（1:1 context）。见 P3。 |
| Epoch / abandon 与 context 队列一致 | **Gap** | `abandonCompositionForVisibilityChange` 调用 `bumpSessionEpoch` **未** `responsiveKeyApplyContexts.removeAll()`。见 P1。 |
| Candidate / Path select gate-on handle 矩阵 | **Not complete** | 无 handle 级 candidate-after-pending / Path select 交错测试；Path select 经 bridge 会触发 publishHandler 二次 apply。见 P2。 |
| No `@unchecked Sendable` | **Met** | Sources 仅注释 forbid；无 attribute 使用。 |
| Focused + full KeyboardCore green | **Met** | 35/0 与 813/0 独立复跑。 |
| Architecture Pass / Product Gate | **Not this review** | Explicit non-claims below. |

---

## Findings

### P0 — none

- 无 Release default-on。
- 无 App / Keyboard Extension / settings force-enable `isResponsiveRimePipelineEnabled`。
- 无 `@unchecked Sendable` isolation bypass。
- 聚焦 35/0、全量 813/0，无 false green。
- 未在 R3 热路径新增 raw input / candidate / host text 隐私日志面。

### P1

1. **`responsiveKeyApplyContexts` 在 sessionEpoch bump / visibility abandon 时未清空。**  
   R3 用 FIFO context 把 deferred `processKey` 与 publish 后 Path/auto-anchor 后处理 1:1 绑定。`rebuildResponsiveRimeCoordinatorIfNeeded` 会 `removeAll()`，但 `abandonCompositionForVisibilityChange` 仅 `coordinator.bumpSessionEpoch(resetEngineSession: true)`（pipeline pending 清空），**不**清 `responsiveKeyApplyContexts`。  
   **复现形态（gate-on）：** accept 键并 enqueue context → 在 drain 前 abandon/visibility → 再输入新键 → 后续 publish 可能 `removeFirst()` 到 **过期 context**（错误 `rimeKey` / `previousT9PathState` / raw trace），污染 Path retain 与 auto-anchor 决策。  
   **Severity vs R3 auth：** 不破坏 default-off Release；直接削弱 R3 “post-publish parity” 合同，**阻塞**任何宽面 gate-on 实验信心。  
   **Fix 方向（非本审查实施）：** 凡 bump/clear pending 的入口同步 `responsiveKeyApplyContexts.removeAll()`；补 abandon→retype 回归测试。

### P2

1. **Path / auto-anchor “parity” 测试过弱。**  
   `testResponsiveApplyRunsPathRefreshContext` 仅断言：`sessionComposition == "6"`、`pathEffects >= 1`、contexts empty。未与 gate-off 对照 path catalog / focused segment / auto-anchor ledger；未覆盖 reject-after-key 或 multi-digit retain。代码路径存在 ≠ 行为等价已证。

2. **非 key 的 `performOrderedNow` 仍经共享 `publishHandler` 走 `applyResponsivePublishedSnapshot`。**  
   Delete / Path `replaceInput` / select 在 bridge 内 flush 时会：先 publishHandler（`applyRimeOutput` + 无 ctx 时 `refreshT9PinyinPathState` + presentation），再由 controller 既有 handler 二次 `applyRimeOutput*` 与 Path/Delete 专用后处理。  
   **影响：** gate-on 下 T9 Path select / Delete 可能短暂双重刷新或中间态 path 被 generic refresh 打乱，再由后续逻辑“救回”。R3 加强了无 ctx 分支的 Path refresh，使该 dual-apply 比 R2 更敏感。缺 handle 级 Path select / Delete-with-focus 回归。

3. **`handle` 级 multi-action 矩阵仍偏窄。**  
   R3 补了 key→delete composition 顺序，但未覆盖：pending keys 后 candidate select；key→Path select；key→visibility abandon→key；符号页 `replaceInput` + 后续 delete。R2 Quality re-review 的 multi-action residual **仅部分关闭**。

4. **Settle 仍偏 flaky 模式。**  
   `testHandleKeyThenDelete…` / `testResponsiveApply…` 使用 `DispatchQueue.main.async` / `asyncAfter(0.05)` + 可选 `flushPending`，而非绑定 publish expectation / 可注入 drain。当前绿；CI 负载下仍有 flake 风险（延续 R2 P2 风格）。

### P3

1. **gate-on 强制 `.everyResult`**（即使调用方传 `.latestOnly`）以保证 context 1:1——合理 trade-off，但偏离 R1 “latest-only UI skip intermediate” 口吻；文档/注释应诚实，避免读者以为 latestOnly 仍生效。  
2. **MainActor deferred drain residual**（Arch P1-3）未变：长 `process_key` 仍占 UI 线程 drain turn；本 Quality 不关闭。  
3. **R1 sleep-clock / soft budget** 用例仍在；注意 suite 预算，非阻塞。

---

## Default-off check

| Check | Result |
|---|---|
| Default `isResponsiveRimePipelineEnabled` | **`false`**（`KeyboardController`） |
| Production / Extension / App force-on | **无**（仅测试 `= true`） |
| Gate-off path | 默认仍 ADR 0004 同步 `rimeEngine`；`testGateDefaultIsOffAndControllerStaysSynchronous` |
| Gate on→off 恢复 underlying | `testGateOffAfterOnRestoresUnderlyingEngine`（bridge 卸下，`underlyingRimeEngine` 恒等于真实 engine） |
| Extension chrome unwrap | `underlyingRimeEngine`；**不**改变 gate 默认 |
| `@unchecked Sendable` | **无** |
| Off-main librime 声称？ | **否** |
| **Shipping / 实验建议** | **Keep gate default off。** 本审查 **不**授权 Release 开启，**不**把 R3 unit 绿解读为可默认启用或宽面 Debug 打字实验。 |

---

## Prior Quality re-review conditions — still relevant?

| Prior condition (R2 re-review) | R3 disposition |
|---|---|
| Keep gate default off | **仍成立 / 强制保留** |
| Presentation bridge Closed | **仍 Closed**（Bootstrap + 测试保留） |
| 勿宽面 Debug/device force-on | **仍成立**（P1 context + Path dual-apply + 弱 parity 测） |
| 补 handle 级 key→delete | **部分关闭**（有测；settle 弱；无 abandon 交错） |
| Path 在 publish 后重算 / auto-anchor 策略 | **代码部分落地；测试与 epoch 一致性未关** |
| Extension `syncUI` 无包测 | **仍成立**（薄接线，未自动化 UI） |
| 符号页 replace 仍 sync ordered | **仍成立**（有意 trade-off） |
| Isolation residual MainActor | **仍开放（Arch）** |

---

## Explicit non-claims

- **Not** Architecture Pass（不重判 ADR 0025 Accept / off-MainActor residual）。
- **Not** Product Gate。
- **Not** 授权 Release 或用户面构建 default-on。
- **Not** 声明 gate-on 九宫格 Path / partial-commit / auto-anchor 与 sync 路径行为完全等价。
- **Not** 声明真实 UIKit + librime 下按键主观不卡。
- **Not** R4+ / 设备 A/B / Human Reminders 授权。
- **Not** 用本文件替代独立 Architecture review of R3。

---

## Recommended next (quality)

1. **Keep `isResponsiveRimePipelineEnabled` default off**（Release 与一切用户面配置）。  
2. **修 P1：** epoch bump / abandon / suspend 等清空 pending 的路径同步 `responsiveKeyApplyContexts.removeAll()`；加 abandon→retype 单测。  
3. **收紧 Path parity 测：** gate-on vs gate-off 对照 compact paths / focused segment；至少一条 auto-anchor eligible 场景或显式 notEligible 断言。  
4. **补 multi-action：** handle 级 candidate-after-pending；Path select 后 composition/path 不因 publishHandler 中间 refresh 漂移。  
5. **Settle 硬化：** 用 presentation / publish expectation 替代裸 `asyncAfter`。  
6. 回归底线：任何再接线后重跑  
   `swift test --filter ResponsiveRime` 与 `swift test`。  
7. **不**因本 Pass with conditions 开启宽面 gate-on Debug 实验；窄探测须知情 residual（P1 未修前尤忌 visibility 交错）。

---

## Verdict rationale (summary)

R3 在 **独立复跑绿测 + 源码核对** 下交付了授权范围内的主要骨架：deferred publish 的 Path/auto-anchor **context 钩子**、`handle` key→delete 顺序单测、`underlyingRimeEngine` chrome unwrap，且 **Release default-off 隔离仍成立**。  
Verdict 为 **Pass with conditions**：条件是继续默认关闭；先修 **context FIFO 与 epoch 不同步（P1）** 并补强 Path/auto-anchor 与 multi-action 证据，再谈任何 gate-on 实验信心。本文件 **不**声称 Architecture Pass 或 Product Gate。

---

## Executor P1 remediation addendum (2026-07-30)

Quality P1 (context/epoch) + Arch reentrancy remediated: abandon clears contexts; `pk-*` only consumes FIFO; underlying post-process + publish suppress; new tests. Not an independent Quality re-Pass. Keep gate default off.
