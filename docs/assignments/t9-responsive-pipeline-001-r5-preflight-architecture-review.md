# Architecture Review: T9-RESPONSIVE-PIPELINE-001 / R5-Preflight

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent；对抗性结构审查）  
**Date:** `2026-07-31 Asia/Shanghai`  
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Phase:** R5-Preflight — Debug/internal dual-gate arm + content-free 设备预飞诊断  
**Product authority:** [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) § R5-Preflight  
**Design freeze:** [`t9-responsive-pipeline-001-r5-preflight-design.md`](t9-responsive-pipeline-001-r5-preflight-design.md)  
**Predecessor:** R4-Wire `be4c4ac`  
**ADR:** [`0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) — **Status remains `Proposed`（本审查不 Accept）**  
**Sources reviewed (working tree at review time):**

| Artifact | Role |
|---|---|
| `docs/assignments/t9-responsive-pipeline-001-r5-preflight-design.md` | Design freeze D1–D4 + non-claims |
| `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimePreflight.swift` | 纯 arm 解析 + content-free 标记文法 |
| `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` | `installResponsiveDualGatePreflightIfArmed` 接线 |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` | gate 默认、rebuild、publish marker |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimePreflightTests.swift` | 可证伪形态（绿条归 Quality） |
| PD R5-Preflight 授权段 | Allowed / Forbidden |
| ADR 0025 | Status 仍 **Proposed** |

**Verdict:** **Pass with conditions**

| Severity | Count |
|---|---|
| P0 | 0 |
| P1 | 0 |
| P2 | 1（Release 默认激活路径无条件打 PATH marker，与 boundary 表 “Release = none” 轻微偏离） |
| P3 | 3（fixture 标签不一致、fallback reason 非枚举类型、realized-selection chrome 未在 dual arm 成功路径显式挂钩） |

> **判定原则：** 只根据源码结构是否兑现 R5-Preflight design freeze 的 D1–D4 与 PD 边界；不以测试绿条或设备日志代替结构审查；Quality 拥有执行与诚实证据；本文件 **不** 声称 ADR Accept、正式 R5 A/B / Product Gate、Release default-on、主观 non-stutter、jetsam SLO。

### 必确认结论（本刀）

| 断言 | 结构结论 |
|---|---|
| **Release 仅凭 defaults 永不 arm dual-gate** | **成立** — `shouldArmDualGate(isDebugBuild: false, compileFlagEnabled: false)` 在 App Group key=`true` 时仍返回 `false`；Extension 接线把 `#if DEBUG` 与 compile flag 分离；Release 归档忽略 key |
| **T9RESP 日志 content-free** | **成立** — PATH / PUBLISH / FALLBACK / READY 仅含 path token、fixture、epoch/rev、enum-like reason；未见 raw keys / pinyin / candidate / host text |
| **ADR 0025 Accept** | **未发生** — 本审查不 Accept；源码与 design 亦无 Accept 副作用 |

---

## 1. Scope of this review

**In scope**

- **D1 Arm resolution（fail closed）：** Release 不读 key arm；DEBUG / 显式 compile flag 才可 arm
- **D2 No dual live MainActor session：** arm 成功时不装 `RimeEngineImpl` 为 MainActor session；仅 bootstrap → owner
- **D3 Content-free log grammar：** PATH / PUBLISH / FALLBACK 标记形态
- **D4 Operator prep：** App Group key / compile flag 文档边界（不审 UI）
- 生产默认：两 gate 仍 default-off；`T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` 不在工程默认 scheme/pbxproj
- Extension 在 arm 时安装 `ThreadAffineRimeEngineImplBootstrap`（来自 pending runtime dirs）

**Out of scope（不得借本 Pass 偷渡）**

- 正式 R5 Human A/B 结论 / Product Gate
- ADR 0025 Accept / Release default-on
- Main App settings UI
- 主观 non-stutter / jetsam SLO
- Typo sidecar 真 session（design D2 明确 residual）
- 本机 `swift test` / 设备 log 导出绿条（**Quality**）
- 重开 R4-Wire P1（`performOrderedNow` vs delivery）— 非 R5-Preflight 授权关闭项

---

## 2. Residual disposition (from R4-Wire / prior)

| Residual | R5-Preflight 目标 | 源码结论 |
|---|---|---|
| Extension 安装真实 bootstrap | arm 时安装 config-only bootstrap | **Closed for preflight arm path** — `installResponsiveDualGatePreflightIfArmed` 写入 `ThreadAffineRimeEngineImplBootstrap`；**非** Release 默认安装 |
| dual-gate 设备可观测 path/publish | content-free markers | **Mostly closed** — 见 §3.3；Release 默认 PATH 见 P2 |
| Typo 真 session sidecar | 不在本刀 | **Explicit residual（D2）** — `CandidateProviderTypoCorrectionQuery` |
| R4-Wire P1 performOrderedNow | 不在本刀 | **Still open**（不重开本审查 Fail） |
| Delivery 无界背压 | 不在本刀 | **Still open** |

---

## 3. Design freeze structural judgment

### 3.1 D1 — Arm resolution (fail closed) — **Closed**

**Freeze：**

```text
Release build → never arm dual-gate from UserDefaults
DEBUG or T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED:
  dualGate = AppGroup.bool(uk.t9resp.preflight.dualGate) OR compile flag
  if dualGate && runtimeDirs known → install dual-gate + rebuild + PATH
  else if dualGate && no dirs → FALLBACK missing-runtime; keep ADR 0004 path
  else → existing MainActor / sync path
```

**纯函数（`ResponsiveRimePreflight.shouldArmDualGate`）：**

```text
if compileFlagEnabled { return true }          // 显式 internal arm（含非 DEBUG 内部包）
guard isDebugBuild else { return false }      // Release：忽略 UserDefaults key
return defaults?.bool(forKey: dualGateKey) == true
```

| 检查项 | 结果 |
|---|---|
| Release + key=true + flag=false → **不 arm** | **Yes**（函数 + 测试形态 `testReleaseNeverArmsFromUserDefaultsAlone`） |
| DEBUG + key=true → arm request | **Yes** |
| compile flag alone（defaults nil / 非 DEBUG）→ arm request | **Yes**（与 design「OR compile flag」及 auto-anchor B 模式一致） |
| Bootstrap 接线使用 `sharedDefaults`（App Group suite） | **Yes**（`group.com.DoubleShy0N.Universe-Keyboard`） |
| `#if DEBUG` / `#if T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` 分离 | **Yes** |
| `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` 出现在 `*.pbxproj` 默认 | **No**（全仓 pbxproj 无匹配；仅 Bootstrap 条件编译位点） |
| 生产路径把两 gate 置 true 的唯一站点 | **Yes** — 仅 `installResponsiveDualGatePreflightIfArmed`（测试除外） |
| Gate 源码默认 `false` | **Yes**（`KeyboardController`） |
| missing-runtime：log FALLBACK，return false，不留 dual 标志 | **Yes** |
| rebuild-inactive：清 flags + bootstrap，return false，外层走 `RimeEngineImpl` | **Yes**（fail closed） |

**结论：** D1 结构关闭。**Release 永不单独因 UserDefaults arm** 得到源码与测试形态双重支持。Compile flag 可在非 DEBUG 内部构建 arm，属 design 明示 internal arm，**不是** “defaults alone”。

---

### 3.2 D2 — No dual live MainActor session when armed — **Closed（引擎隔离）**

**Freeze：** arm 成功时 **不** 安装 `RimeEngineImpl` 为 `controller.rimeEngine`；session 仅经 bootstrap 在 owner 线程；typo 用 non-session adapter（residual）。

**成功 arm 路径（`installResponsiveDualGatePreflightIfArmed`）：**

```text
isResponsiveRimePipelineEnabled = true
isThreadAffineRimeOwnerEnabled = true
threadAffineEngineBootstrap = Any(ThreadAffineRimeEngineImplBootstrap(dirs…))
typoCorrectionCandidateQuery = CandidateProviderTypoCorrectionQuery(...)
rebuildResponsiveRimeCoordinatorIfNeeded()
active ⇔ threadAffineRimeCoordinator != nil
         && rimeEngine is ThreadAffineRimeEngineBridge
if active → hasActivatedVisibleRimeRuntime = true; return true
            // 外层不再执行 RimeEngineImpl 安装
```

| 检查项 | 结果 |
|---|---|
| 成功 arm 跳过 MainActor `RimeEngineImpl(...)` | **Yes**（early return before sync install） |
| dual rebuild 使用 bootstrap-only coordinator + `ThreadAffineRimeEngineBridge` | **Yes**（R4-Wire rebuild 分支） |
| dual 路径 `underlyingRimeEngine` 对 ThreadAffine bridge 为 nil | **Yes**（既有 R4-Wire 结构） |
| 同时持有 live MainActor session + owner session 服务同一 session | **No（结构上避免）** |
| typo 明确 non-session adapter | **Yes** + 注释 residual |
| arm 失败后恢复 sync 安装 `RimeEngineImpl` + rebuild teardown owner | **Yes** |

**结论：** D2 引擎隔离结构关闭。Typo sidecar 真 session **不在本刀 claim 面**（design / PD 一致）。

---

### 3.3 D3 — Content-free log grammar — **Closed（语义）；P2 边界范围**

**允许形态（实现）：**

| Marker | 生成点 | 载荷 |
|---|---|---|
| PATH | Bootstrap 默认路径 + dual arm 结果 | `path=` token、`fixture=T9RESP-R5P`、`dualGateRequested/Active` 0/1 |
| PUBLISH | `applyResponsivePublishedSnapshot` 且 `isThreadAffineRimeOwnerEnabled` | `epoch` / `rev` 数值 only |
| FALLBACK | missing-runtime / rebuild-inactive | `reason=` token + dualGate=requested |
| READY | dual arm active | `bootstrap=config-only session=owner-thread` |

| 检查项 | 结果 |
|---|---|
| 标记字符串不含 raw input / pinyin / candidates / host text | **Yes**（静态构造 + 测试形态） |
| PUBLISH 仅 epoch/revision | **Yes** |
| PUBLISH 仅 thread-affine owner 开启时 | **Yes**（不会在默认 sync 路径刷屏 publish） |
| FALLBACK reason 调用点为 enum-like token | **Yes**（`missing-runtime` / `rebuild-inactive`） |
| 测试断言 content-free（路径标记 + publish 精确串） | **Present** |

**与 boundary 表的张力（P2）：**

Design §1 表：

| Logs | Release: **none for this feature** | DEBUG/arm: content-free T9RESP |

实现中，**未 arm 的默认激活路径**仍无条件：

```text
Logger.shared.info(ResponsiveRimePreflight.pathMarkerLine(path: sync|mainActorResponsive, dualGate=0/0))
```

该日志 **content-free**，且 **不 arm**，故不破坏安全 arm 边界；但相对 “Release = none for this feature” 属于可观测面扩大。  
**建议（非阻断）：** 将默认 PATH 包在 `#if DEBUG` 或 `dualGateRequested || compileFlag` 之后，使正式 Release 归档默认零 T9RESP。

**结论：** content-free **语义关闭**；Release 默认 PATH 发射记 **P2 condition**（不构成 Fail）。

---

### 3.4 D4 — Operator prep — **Closed（文档边界）**

| 检查项 | 结果 |
|---|---|
| App Group key 名与 suite 与代码一致 | **Yes**（`uk.t9resp.preflight.dualGate` / `group.com.DoubleShy0N.Universe-Keyboard`） |
| Main App settings UI 未新增 dual-gate 开关 | **Yes**（未见生产 UI 写 key） |
| Disarm / Release ignore key | **文档 + 源码一致** |

---

## 4. Publish marker（KeyboardController）

```text
applyResponsivePublishedSnapshot:
  guard responsive enabled && snapshot != nil
  if isThreadAffineRimeOwnerEnabled:
    Logger.performance(publishMarkerLine(epoch, revision))
  // 随后 FIFO context / presentation — 既有 R3/R4 结构
```

| 检查项 | 结果 |
|---|---|
| 仅 dual-gate thread-affine 时打 PUBLISH | **Yes** |
| 载荷无 composition / candidate 文本 | **Yes** |
| 不改变 publish 选择策略 / 不引入第二 session | **Yes**（纯诊断旁路） |

---

## 5. Findings

### P2

| ID | Finding | 影响 | 建议 |
|---|---|---|---|
| **P2-1** | 默认（未 arm）键盘激活路径在 **所有配置** 发射 `T9RESP marker=PATH … dualGate=off` | 与 design boundary「Release = none for this feature」轻微偏离；无 arm 风险 | 条件编译或仅在 DEBUG / arm 请求时发射 PATH |

### P3

| ID | Finding | 备注 |
|---|---|---|
| **P3-1** | Coordinator `fixtureID` 仍为 `T9RESP-R4W`，预飞标记为 `T9RESP-R5P` | 不破坏 content-free；设备对照时可混淆 |
| **P3-2** | `fallbackMarkerLine(reason: String)` 非封闭枚举 | 当前调用点安全；未来误传用户文本有理论风险 |
| **P3-3** | dual arm 成功 early-return **未** 设置 `onRuntimeSelectionChanged` / 立即 `applyRealizedRuntimeSelection` | 预飞诊断仍可 PATH/PUBLISH；chrome/schema 对齐依赖既有 presentation / 后续 publish 路径 — 记为 preflight residual，非 D1/D2 Fail |

### Explicit residuals（by design / PD）

- Typo：`CandidateProviderTypoCorrectionQuery`（非 live librime session）
- 正式 R5 A/B、Product Gate、ADR Accept、Release default-on：**禁止 claim**
- R4-Wire P1 / delivery 背压：**仍 open**，本刀不关闭

---

## 6. Non-claims（强制）

本审查 **不** 声称：

1. ADR 0025 **Accept**（保持 **Proposed**）
2. 正式 R5 Product Gate / Human A/B Pass
3. Release dual-gate **default-on**
4. 设备主观 non-stutter 或 jetsam SLO
5. Typo sidecar 生产完备
6. Quality 绿条或 Human 设备 log 导出已完成

---

## 7. Verdict rationale

| Dimension | Judgment |
|---|---|
| PD R5-Preflight Allowed 面 | 结构覆盖：DEBUG/flag arm、bootstrap 安装、content-free markers、单元测试形态 |
| PD Forbidden 面 | 未见 Release default-on、未见 ADR Accept 副作用、未见 settings UI |
| D1 Release never arms from defaults alone | **Confirmed** |
| D2 no dual MainActor live session | **Confirmed** |
| D3 content-free | **Confirmed**（P2 仅范围，非内容泄漏） |
| 阻断性结构缺陷 | **无 P0/P1** |

**Verdict: Pass with conditions**

Conditions 关闭建议（可由 Executor 小刀或并入后续 preflight 硬化；**不**要求本审查改口为 Fail）：

1. **P2-1：** Release 默认路径不发射 T9RESP（DEBUG/arm-only）。
2. 可选 P3：统一 fixture 标签；`FallbackReason` 枚举化。
3. 保持 typo residual 与 formal R5 未授权状态的诚实文档。

**下一步（建议）：** Quality 独立审查 arm 解析测试 + 可选 Human DEBUG 设备 content-free log 导出；**不得**将本 Arch Pass 读成 R5 Product Gate 或 ADR Accept。
