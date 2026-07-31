# Quality Review: R5-Preflight (Debug dual-gate arm + content-free logs)

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（**independent** reviewer） |
| Date | 2026-07-31 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Design freeze | [`t9-responsive-pipeline-001-r5-preflight-design.md`](t9-responsive-pipeline-001-r5-preflight-design.md) |
| Product authority | [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) § R5-Preflight |
| Executor evidence | [`../evidence/t9-responsive-pipeline-r5-preflight-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-preflight-2026-07-31.md) |
| Predecessor | R4-Wire tip `be4c4ac`；R4-Wire Quality [`t9-responsive-pipeline-001-r4-wire-quality-review.md`](t9-responsive-pipeline-001-r4-wire-quality-review.md) |
| Scope | R5-Preflight only：Debug/compile-flag dual-gate arm、content-free `T9RESP` markers、unit arm-resolution、Release 不因 UserDefaults 单独 arm |
| Worktree tip at review | parent tip `be4c4ac`（R4-Wire）；R5-Preflight 产物 **dirty / uncommitted**（见 § Worktree honesty） |
| Verdict | **Pass with conditions** |
| Device path addendum (2026-07-31) | **Accepted** for optional design §3 only — see evidence physical matrix; **not** formal R5 |

**P0: 0**  
**P1: 0**  
**P2: 1**（immutable SHA 未绑定；语义变更会使本 Pass 失效 — 实现 tip 现记为 `87d3e7c`）  
**P3: 3**（evidence gitignore；DEBUG key=false 单测缺口；sync PATH 在 Release 也打点）

---

## Scope

Independent Quality review of Executor R5-Preflight delivery against:

1. Design freeze D1–D4 + evidence bullets  
2. Product R5-Preflight authorization boundary（Debug dual-gate arm + content-free logs；**not** formal R5 A/B）  
3. Playbook evidence honesty（re-run, not trust Executor counts alone）  
4. Explicit non-claims（no formal R5 Pass / ADR Accept / Product Gate / Release default-on / subjective non-stutter）

This review **re-ran** KeyboardCore focused and full suites. It did **not** accept Executor green as sole authority.

**Not in scope for this review:** device/Simulator arm exercise, Human log export, formal R5 A/B matrix, Architecture re-review of wire isolation (inherits R4-Wire).

---

## Commands re-run (authoritative for this review)

Environment:

| Item | Value |
|---|---|
| Host | macOS 27.0 (Build 26A5388g), arm64 |
| Swift | Apple Swift 6.4 (`swift-driver` 1.168.5) |
| Module cache | `SWIFTPM_MODULECACHE_OVERRIDE` / `CLANG_MODULE_CACHE_PATH` under `/private/tmp/universe-spike-*` |
| Wall clock | 2026-07-31 ~12:34 CST |
| Parent tip | `be4c4ac43743dbabc3046aff7860de61fc577473` |

### 1) KeyboardCore focused (`ResponsiveRimePreflightTests`)

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard"
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-spike-swift-module-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-spike-clang-module-cache \
swift test --package-path Packages/KeyboardCore --filter ResponsiveRimePreflightTests
```

| Suite | Executed | Failures | Notes |
|---|---:|---:|---|
| `ResponsiveRimePreflightTests` | **5** | **0** | Release never arms; Debug key; compile flag; content-free PATH/PUBLISH |

### 2) KeyboardCore full package

```bash
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-spike-swift-module-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-spike-clang-module-cache \
swift test --package-path Packages/KeyboardCore
```

| Suite | Executed | Failures |
|---|---:|---:|
| `KeyboardCoreTests` / All tests | **836** | **0** |

Matches Executor arithmetic（5 focused / 836 full）。**Evidence honesty: confirmed.**  
（R4-Wire full was 830；+6 含本 Preflight 5 与其间其它增量，以本机 836 为准。）

---

## Evidence matrix vs design

| Case | Requirement | Independent result |
|---|---|---|
| **D1 Release + UserDefaults** | Release 永不因 App Group key 单独 arm dual-gate | **Held** — `shouldArmDualGate(isDebugBuild: false, compileFlagEnabled: false)` 在 key=`true` 时返回 `false`；`testReleaseNeverArmsFromUserDefaultsAlone` |
| **D1 DEBUG + key** | DEBUG 且 `uk.t9resp.preflight.dualGate=true` → request arm | **Held** — `testDebugArmsWhenAppGroupKeyTrue` |
| **D1 compile flag** | `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` 可 arm（含无 key） | **Held** — `testCompileFlagArmsEvenWithoutKey`（`isDebugBuild: false` 仍 arm，与 auto-anchor internal B arm 模型一致） |
| **D1 missing runtime** | dualGate requested 但 runtime dirs 空 → FALLBACK，保留 ADR 0004 安装路径 | **Held structurally** — `installResponsiveDualGatePreflightIfArmed` 在 empty dirs 时 log `missing-runtime` 并 `return false`，不置 gate；调用方继续 MainActor `RimeEngineImpl` |
| **D1 rebuild inactive** | bootstrap/rebuild 失败 → fail-closed 清 flags | **Held structurally** — 清 `isThreadAffineRimeOwnerEnabled` / `isResponsiveRimePipelineEnabled` / bootstrap，`return false` |
| **D2 no dual live session** | arm 成功时不在 MainActor 安装 live `RimeEngineImpl` | **Held** — 仅设 bootstrap + dual gates + rebuild；`active` 要求 `ThreadAffineRimeEngineBridge`；无 `controller.rimeEngine = RimeEngineImpl(...)` |
| **D2 typo residual** | preflight 用 non-session typo adapter | **Held** — `CandidateProviderTypoCorrectionQuery`；Executor/Product residual 明示 live typo 不 claim |
| **D3 content-free markers** | PATH / PUBLISH / FALLBACK 无 raw key / pinyin / candidates / host text | **Held** — pure helpers + tests 拒绝 `你好`/`nihao`；PUBLISH 仅 epoch/rev；call site reason tokens 为 `missing-runtime` / `rebuild-inactive` |
| **D4 operator prep** | App Group key + optional compile flag；非 project default | **Held** — evidence 文档含 `defaults write`；`project.pbxproj` / shared schemes / xcconfig：**0** 处 `T9_RESPONSIVE_DEVICE_PREFLIGHT` |
| **Gate property defaults** | controller dual-gate 默认 off | **Held** — `isResponsiveRimePipelineEnabled = false`；`isThreadAffineRimeOwnerEnabled = false` |
| **Production force-enable** | 无 settings UI / Release default-on | **Held** — gates 仅在 `installResponsiveDualGatePreflightIfArmed` 成功路径置 `true`；生产 Swift 无其它 force `= true`（测试除外） |
| **Publish marker wire** | thread-affine publish 打 content-free 点 | **Held** — `applyResponsivePublishedSnapshot` 在 `isThreadAffineRimeOwnerEnabled` 时 `Logger.shared.performance(publishMarkerLine…)` |
| **Full suite green** | KeyboardCore all tests | **Held** — **836 / 0** |
| **No `@unchecked Sendable`** | isolation without bypass | **Held** — Preflight 源/测/Bootstrap 增量：**0** |

---

## Isolation / arm-surface scans

### `@unchecked Sendable` / `nonisolated(unsafe)`

| Surface | Hits |
|---|---|
| `ResponsiveRimePreflight.swift` | **0** |
| `ResponsiveRimePreflightTests.swift` | **0** |
| `KeyboardViewController+Bootstrap.swift` R5 增量 | **0** |
| `KeyboardController.swift` publish marker 增量 | **0** |

### Compile flag / project defaults

| Surface | Observation |
|---|---|
| `Universe Keyboard.xcodeproj/project.pbxproj` | **0** `T9_RESPONSIVE_DEVICE_PREFLIGHT*` |
| Shared schemes / xcconfig（repo 扫描） | **0** |
| Bootstrap `#if T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` | 存在；默认 `#else → false` |

### Gate defaults (production)

| Flag | Default | Production force-enable outside preflight arm |
|---|---|---|
| `isResponsiveRimePipelineEnabled` | `false` | **Only** when dual-gate preflight arm succeeds |
| `isThreadAffineRimeOwnerEnabled` | `false` | **Only** when dual-gate preflight arm succeeds |
| `threadAffineEngineBootstrap` | `nil` | **Only** on successful arm path |

### Release arm honesty（关键结论）

| Scenario | Arms dual-gate? |
|---|---|
| Release + App Group key `true` + compile flag off | **No**（单测证明；纯函数 fail-closed） |
| Release + key 任意 + compile flag off | **No** |
| Release / any + compile flag **on**（internal inject） | **Yes**（设计允许的 internal B-arm；**非** project default） |
| DEBUG + key `true` | **Yes**（request；仍依赖 runtime dirs + rebuild 成功才 active） |
| DEBUG + key false + flag off | **No**（代码路径；缺专用单测 → P3） |

**Quality 对「Release never arms」的 endorse 范围：**  
endorse **「Release 永不因 UserDefaults/App Group key 单独 arm」**。  
**不** endorse「任何带 `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` 的内部二进制也永不 arm」——那是显式内部 arm，与 auto-anchor B 一致，且当前 **不在** project defaults。

---

## Artifacts reviewed

| Artifact | Path |
|---|---|
| Arm resolution + markers | `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimePreflight.swift` |
| Unit tests | `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimePreflightTests.swift` |
| Extension install arm | `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` |
| Publish marker | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` |
| Design | `docs/assignments/t9-responsive-pipeline-001-r5-preflight-design.md` |
| Executor evidence | `docs/evidence/t9-responsive-pipeline-r5-preflight-2026-07-31.md` |
| Product | `docs/product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md` § R5-Preflight |

---

## Residuals

### P2 — Worktree honesty（no immutable R5-Preflight SHA）

At review time:

- Parent tip: `be4c4ac`（**R4-Wire** feat commit；非 R5-Preflight 实现冻结）  
- R5-Preflight 实现 **dirty / untracked**：
  - `M` `KeyboardViewController+Bootstrap.swift`、`KeyboardController.swift`、Assignment/plan/PD 状态行  
  - `??` `ResponsiveRimePreflight.swift`、`ResponsiveRimePreflightTests.swift`、`r5-preflight-design.md`  
- 本地 evidence 文件存在，但根 `.gitignore` 的 `evidence/` 规则会使 **新建** `docs/evidence/...` 默认被忽略（既有 tracked evidence 不受影响）。提交时需 `git add -f` 或调整 ignore 策略。

**Condition:** Product / Executor 必须创建 **clean immutable R5-Preflight checkpoint SHA**，并将 Arch+Quality 绑定到该 SHA 后，才可将 R5-Preflight 视为可交接关闭。若树在本 review 后改变 D1–D4 / arm 语义，本 Pass **作废** 并需 re-review。

### P3 — DEBUG + key false 缺显式单测

`shouldArmDualGate` 在 `isDebugBuild: true, key absent/false, compileFlagEnabled: false` 时返回 false 可由纯函数阅读确认，但 suite 未直接 assert。不阻塞 Pass；可选补测。

### P3 — 普通 sync 安装也会打 PATH marker（含 Release）

`activateRimeRuntimeAfterKeyboardPresentation` 在 MainActor 同步安装成功后 **总是** log `path=sync|mainActor-responsive dualGateRequested=0 dualGateActive=0`。内容仍 content-free，不构成 arm，但比 design 表「Release logs: none for this feature」略宽。可选：仅 DEBUG 或仅 `dualGateRequested` 时打点。

### P3 — READY / FALLBACK reason 非类型化

READY 行内联拼接（content-free）；`fallbackMarkerLine(reason:)` 接受自由字符串。当前 call site 仅 enum-like tokens。覆盖诚实 residual，非已证明泄漏。

### Carry-forward（不作为 R5-Preflight fail 重开）

- R4-Wire / R4-B：**QoS** residual；device non-stutter **未** claim  
- D2 typo adapter residual：live librime typo sidecar under dual-gate **未** claim  
- ADR 0025 仍为 **Proposed**  
- Formal R5 Human A/B **未授权 / 未 claim**

---

## Explicit non-claims（Quality will not endorse）

This review **does not** claim, authorize, or partially satisfy:

1. Formal R5 Human A/B Pass 或 subjective non-stutter  
2. ADR 0025 **Accept**  
3. Product Gate / Release default-on / user-facing dual-gate settings  
4. R6 shipping decision  
5. 将 App Group key 设为 true 后的真机/模拟器行为已验证  
6. Live typo librime sidecar parity under dual-gate  
7. jetsam / mailbox-depth / delivery backpressure product SLOs  
8. R4-B owner QoS 已 closed  
9. Full auto-anchor / Path engine-mutating parity under thread-affine  
10. Dirty-tree review 等于 immutable SHA-bound close  
11. 任何「用户默认路径已是 dual-gate」的表述  

R5-Preflight 仅证明：**arm 解析纯函数 + 单测绿**、**Release 不因 UserDefaults 单独 arm**、**project 无 compile-flag default**、**Extension 可选 arm 路径存在且 fail-closed**、**content-free T9RESP 语法**、**KeyboardCore 836/0**。

---

## Verdict

### **Pass with conditions**

R5-Preflight authorized intent is **met** on independently re-run evidence:

- Focused Preflight: **5/0**  
- KeyboardCore full: **836/0**  
- Design D1 arm matrix held（Release+key → off；DEBUG+key → on；compile flag → on；missing-runtime / rebuild-inactive fail-closed structurally）  
- D2 no MainActor live session when armed  
- D3 content-free markers held by pure helpers + tests  
- Compile flag **not** in project defaults  
- No `@unchecked Sendable`  

### Conditions (must hold for this Pass to remain valid)

1. **No over-claim:** 本 Pass **不得** 被用作 formal R5 A/B、ADR Accept、Product Gate、Release default-on 或 subjective non-stutter 证据。  
2. **Immutable SHA bind:** Executor/Product 应提交 R5-Preflight knife 并绑定 Arch+Quality 到 clean SHA；提交后语义变更需 re-review。  
3. **Gates remain default-off** 于普通 DEBUG/Release 工程配置，直至新的 Product knife。  
4. **Compile flag never lands in project defaults / shared schemes** without a new Product knife.  
5. **Device logs optional:** Human 导出 content-free 日志属于 operator prep，**不是**本 Pass 的通过条件，也 **不能** 单独升级为 formal R5。

### Stop / escalate if

- Release 默认或 user-facing settings 打开 dual-gate  
- `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` 进入 project.pbxproj / shared scheme 默认  
- Swift 6 isolation 用 `@unchecked Sendable` / `nonisolated(unsafe)`「修好」  
- dual-gate arm 成功时同时存在 MainActor live `RimeEngineImpl` session 与 owner session  
- `T9RESP` 日志出现 raw key / pinyin / candidates / host text  
- dirty-tree 语义在 re-review 前被当作已关闭的正式 R5  

---

## Handoff

| To | Payload |
|---|---|
| 🧭 Product | Verdict **Pass with conditions**；R5-Preflight 工具面 held；formal R5 A/B / ADR Accept / default-on 仍 closed |
| 🏛️ Architecture | D1–D4 实现与 freeze 对齐；marker 语法较 design 示例略丰富但仍 content-free；ADR 0025 仍 Proposed |
| 🔧 Executor | 创建 immutable R5-Preflight SHA；`git add -f` evidence（若需入库）；可选 P3 单测与 Release PATH 日志收窄 |
| 🧪 (self) | Review artifact: this file |

---

## Appendix — machine lines (independent)

```text
# Focused
Test Suite 'ResponsiveRimePreflightTests' passed
Executed 5 tests, with 0 failures (0 unexpected)

# Full
Test Suite 'KeyboardCoreTests.xctest' passed
Executed 836 tests, with 0 failures (0 unexpected)
Test Suite 'All tests' passed
Executed 836 tests, with 0 failures (0 unexpected)
```

## Appendix — pure arm table (code-backed)

| `isDebugBuild` | `compileFlagEnabled` | key true? | `shouldArmDualGate` |
|---|---|---|---|
| false | false | true | **false** ← Release never arms from key alone |
| false | false | false | **false** |
| false | true | * | **true** ← internal compile arm only |
| true | false | true | **true** |
| true | false | false | **false**（代码；缺专用单测） |
| true | true | * | **true** |
