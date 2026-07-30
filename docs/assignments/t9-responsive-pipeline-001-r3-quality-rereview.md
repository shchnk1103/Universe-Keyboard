# Quality Re-review: T9-RESPONSIVE-PIPELINE-001 R3 P1 remediation

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（independent re-reviewer） |
| Date | 2026-07-30 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Prior Quality | R3 [`t9-responsive-pipeline-001-r3-quality-review.md`](t9-responsive-pipeline-001-r3-quality-review.md)（含 Executor P1 addendum） |
| Prior Architecture | R3 [`t9-responsive-pipeline-001-r3-architecture-review.md`](t9-responsive-pipeline-001-r3-architecture-review.md)（P1-1 context/epoch；P1-2 reentrancy） |
| Scope | R3 P1 remediation：context FIFO ↔ epoch；`pk-*` only；underlying post-process + publish suppress；回归测试 |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 0**  
**P2: 3**  
**P3: 2**

---

## Commands re-run

Independent re-run on this machine（**不**信任 Executor counts alone）：

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard/Packages/KeyboardCore" && swift test --filter ResponsiveRime
```

| Suite | Executed | Failures |
|---|---:|---:|
| `ResponsiveRimePipelineTests` (R1) | 23 | 0 |
| `ResponsiveRimeR2CoordinatorTests` (R2+R3+P1 rem) | **15** | 0 |
| **Filter total** | **38** | **0** |

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard/Packages/KeyboardCore" && swift test
```

| Suite | Executed | Failures |
|---|---:|---:|
| `KeyboardCoreTests` / All tests | **816** | **0** |

Notes:

- 相对 R3 初审 focused **35/0** / full **813/0**：本 remediation 新增至少 3 个 R2 coordinator 用例（abandon clear / multi-key / ord-not-steal），focused **38/0**、full **816/0**。
- 无 false green；未跑 `xcodebuild` App/Extension；未跑 Simulator / 真机 / 真实 librime。

---

## P1 disposition

| ID | Source | Finding (prior) | Disposition | Evidence |
|---|---|---|---|---|
| **Quality P1** | R3 Quality | `abandon` / epoch bump 未清 `responsiveKeyApplyContexts`，后续 publish 可吃到过期 FIFO | **Closed** | 见下 §A |
| **Arch P1-1** | R3 Architecture | 同 Quality P1：context 与 epoch/pending 生命周期未绑定 | **Closed（Quality 视角）** | 与 Quality P1 同源修复；**不**代 Architecture Pass |
| **Arch P1-2** | R3 Architecture | publish 后处理经 Bridge 可重入、偷消费 context | **Closed（Quality 视角）** | 见下 §B；**不**代 Architecture Pass |
| **Arch P1-3** | 跨轮残留 | off-MainActor librime | **Still open** | 不在本 remediation 范围；default-off 下不构成 Release 回归 |

### A. Context / epoch（Quality P1 + Arch P1-1）

**源码核对：**

1. `ResponsiveKeyApplyContext` 增加 `sessionEpoch`（accept 时刻）。
2. `enqueueResponsiveKeyApplyContext` 写入 `responsiveRimeCoordinator?.diagnostics.sessionEpoch ?? 1`。
3. `abandonCompositionForVisibilityChange`：`bumpSessionEpoch` **后** `clearResponsiveKeyApplyContexts()`。
4. `resetRimeSessionForVisibilityChange`（gate-on ordered reset）后同样 `clearResponsiveKeyApplyContexts()`。
5. `rebuildResponsiveRimeCoordinatorIfNeeded` gate on/off 均 `removeAll()`。
6. `applyResponsivePublishedSnapshot`：先丢弃 `head.sessionEpoch != snapshot.sessionEpoch` 的 FIFO 头；再消费。

**回归测试：**

- `testAbandonClearsResponsiveKeyApplyContexts`：双键 enqueue 后 contexts 非空 → abandon → empty → 再键 `w` + flush → composition `"w"`（无 stale context 污染）。

**判定：** 原 Quality **P1 复现形态已关闭**。双重防护（显式 clear + apply 侧 epoch drop）足以支撑 “epoch barrier 不得保留 deferred apply context” 合同。仍依赖调用方在 bump 路径调用 clear；当前生产入口（abandon / reset-for-visibility / rebuild）已接线。`suspend`/`resume` 不 bump epoch 且 suspend 先 `flushPending`，不重开本 P1。

### B. Publish reentrancy（Arch P1-2）

**源码核对：**

1. **仅 `pk-*` actionID** 可 `removeFirst` context；`ord-*` 等 nested publish 不偷 FIFO。
2. 后处理引擎取 `underlyingRimeEngine ?? rimeEngine`。
3. apply 期间若当前是 Bridge，**临时**将 `rimeEngine` 换为 underlying，使 Path retain / auto-anchor / restore 走 raw session（同 MainActor single-consumer 栈，已 applied processKey 之后），避免 `performOrderedNow` 嵌套。
4. `coordinator.withPublishHandlerSuppressed` 作为安全网：即使仍误触 Bridge，也不再 fire `publishHandler`。

**回归测试：**

- `testOrdPublishDoesNotConsumeProcessKeyContext`：手动 enqueue 1 个 context → `performOrderedNow(.replaceInput…)` → contexts.count 仍为 1（**强证** ord 不偷 pk context）。
- `testMultiKeyDrainDoesNotStealContextsViaNestedReplace`：T9 双键 `6`/`4` flush → composition `"64"`、contexts empty、publish≥1。证明 multi-key FIFO 排空且不卡死；**未强制**触发 Path retain 的 nested `replaceInput`，对 “真嵌套 mutation” 证明力弱于设计 + ord 测试。

**判定：** Arch 描述的 **偷 context 失效模式** 在当前接线 + 测试下 **可视为 Closed（Quality 证据充分到可关闭原 P1 严重度）**。完整 “gate-on 后处理 ≡ gate-off” 仍 **非**本 re-review 声明（见 Findings P2）。

---

## Findings

### P0 — none

- 无 Release default-on / App·Extension·settings force-enable。
- 无 `@unchecked Sendable`。
- Focused **38/0**、full **816/0**，无 false green。

### P1 — none open in this re-review scope

目标 Quality P1 与 Arch reentrancy P1-2 均 **Closed**（见上）。Arch **P1-3**（off-main）仍开放，**不**升为 Quality P1：default-off 下不影响 Release 路径。

### P2（仍开放 / 未因本 remediation 关闭）

1. **Path / auto-anchor 行为 parity 测试仍弱。**  
   `testResponsiveApplyRunsPathRefreshContext` 仍只断言 composition + pathEffects≥1 + contexts empty；无 gate-off 对照 catalog / focused segment / auto-anchor ledger。代码路径可达 ≠ 等价已证。

2. **multi-action / Delete Path previous / symbol dual-apply 残留（R3 Arch P2 族）。**  
   handle 级仍偏 composition 顺序；Delete 前取样 Path previous 与 flush 时序、symbol `performOrderedNow` 后显式二次 apply 等 **未**在本 remediation 中收口。

3. **reentrancy 嵌套 retain 路径未强制注入。**  
   `testMultiKeyDrain…` 在 Fake 上未必触发 `retainFocusedT9Segment… → replaceInput`；依赖 underlying swap + suppress 的设计正确性。窄范围可接受；若再开 gate-on 实验前，宜补“强制 post-process mutation 后第二键仍有 ctx”的注入式断言。

### P3

1. **gate-on rebuild 仍强制 `.everyResult`**（context 1:1）— 合理 trade-off；文档诚实性残留。  
2. **settle 仍 `asyncAfter` / 可选 `flushPending`**（`testResponsiveApply…` 等）— flake 风险低但未硬化。

---

## Default-off check

| Check | Result |
|---|---|
| Default `isResponsiveRimePipelineEnabled` | **`false`**（`KeyboardController.swift` 属性初始化） |
| Production / App / Extension / settings `= true` | **无**（全仓仅 `ResponsiveRimeR2CoordinatorTests` 显式开启） |
| Gate-off 默认路径 | ADR 0004 同步 `rimeEngine`；`testGateDefaultIsOffAndControllerStaysSynchronous` |
| Gate on→off 卸 bridge | `testGateOffAfterOnRestoresUnderlyingEngine` |
| `@unchecked Sendable` | **无** |
| Off-main librime 声称？ | **否** |
| **Shipping / 实验建议** | **Keep gate default off。** 本 re-review **不**授权 Release 开启，**不**把 P1 Closed + unit 绿解读为可默认启用或宽面 Debug 打字实验。 |

---

## Explicit non-claims

- **Not** Architecture Pass（不重判 ADR 0025 Accept；不关闭 Arch P1-3；不替代独立 Architecture re-review）。
- **Not** Product Gate。
- **Not** 授权 Release / 用户面构建 default-on。
- **Not** 声明 gate-on 九宫格 Path / partial-commit / auto-anchor 与 sync 路径完全行为等价。
- **Not** 声明真实 UIKit + librime 下按键主观不卡。
- **Not** R4+ / 设备 A/B / Human Reminders 授权。
- **Not** 因本文件关闭 R3 Quality/Arch 全部 P2 矩阵。

---

## Recommended next steps

1. **Keep `isResponsiveRimePipelineEnabled` default off**（Release 与一切用户面配置）— **强制**。  
2. 可选：独立 Architecture re-review 确认 P1-1/P1-2 Closed 措辞（Quality 已关，Arch 文件状态由 Architecture 角色更新）。  
3. 若 Product 要窄 gate-on 探测：**先**补强 Path parity 与至少一条强制 nested post-process mutation 的 context 保留测；**仍**不得 Release default-on。  
4. 继续收紧 multi-action（candidate / Path select / Delete+Path focus）与 settle（publish expectation）。  
5. 回归底线：任何再接线后重跑  
   `swift test --filter ResponsiveRime` 与 `swift test`。  
6. **Arch P1-3 / R4+** 仅在另授权后推进；本文件不打开该门。

---

## Verdict rationale (summary)

R3 P1 remediation 在 **独立复跑绿测 + 源码接线核对** 下：

- **Quality P1（context/epoch）Closed** — abandon/reset/rebuild 清空；context 带 epoch；apply 侧丢弃过期头；有 abandon→retype 回归。  
- **Arch reentrancy（P1-2）Closed（Quality 证据）** — 仅 `pk-*` 消费 FIFO；underlying + 临时卸 Bridge + publish suppress；ord 不偷 context 有强测。  
- **Release default-off 隔离仍成立**。  
- Verdict **Pass with conditions**：条件是 **继续默认关闭**；P2 Path parity / multi-action / 嵌套 retain 强制注入仍不足支撑 gate-on 宽面信心。  

本文件 **不**声称 Architecture Pass 或 Product Gate。
