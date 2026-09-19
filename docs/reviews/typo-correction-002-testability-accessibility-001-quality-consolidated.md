# Quality consolidated verdict：TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001

**Reviewer:** 独立 Quality, Performance & Release Maintainer（非实现 Executor、非 F-02 对账收据作者、非 Architecture 最终处置作者）
**Date / timezone:** `2026-09-19 Asia/Shanghai`
**Authorization:** Human Product Owner 当前会话第 3 步 — 对 testability child 输出 consolidated Quality verdict。**无** publication Authorization。本轮 **不** 复用已 consumed 的 [`AUTH-…-F02-RECONCILE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001.md) 或 [`AUTH-…-F02-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-ARCHITECTURE-001.md)。
**Scope:** child 整包（F-01 AX + F-02/QR-01 有界 Pass + 先前 contract/format 输入），不是只 F-02。
**Implementation identity (frozen, uncommitted):** worktree `/private/tmp/universe-keyboard-typo-correction-002-testability-accessibility-001` · branch `codex/typo-correction-002-testability-accessibility-001` · HEAD `9eb83158e49218c1e8f75dbe7dd9e0390db81409` + 下列 diff 哈希与 F-02 freeze 一致：

| Path | SHA-256 |
|---|---|
| `Keyboard/Controllers/KeyboardInputHitAreaStackView.swift` | `51ee23b1639993a8b6e074277f5f76a58af4c1e1a068c7b72375cc7295b3bd3c` |
| `Keyboard/Controllers/KeyboardViewController+KeyAccessibility.swift` | `55815f17fc31a42e9328b5db1bdf8fe2e75f415484d8c4bfc99544b455ab0afe` |
| `KeyboardTests/KeyAccessibilityContractTests.swift` | `198c69d650db3202e01675ea530eb012b886c534202c45dbbabc31cfc3916fd7` |
| `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift` | `b83b08c66ce293ed8a8af07d7a31b884704b3a5cddf746d488dbad3991af1f69` |

本轮 **未** 新开 Simulator、**未** 再点键盘、**未** 改 `.swift` / 测试、**未** 重跑 `xcodebuild` / `swift-format`、**未** commit / push / PR。

Sidecar 实现 Assignment / AUTH 只读链接：

- `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar/docs/assignments/typo-correction-002-testability-accessibility-001.md`
- `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar/docs/authorizations/AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001.md`

本文件 **不是** Product Gate、**不是** child/parent Close、**不是** publication。

## Verdict

**Pass with conditions。**

Child 范围内：F-01 独立键 AX 可发现且字母/删除走 UIKit tap（无宿主注入）；F-02/QR-01 与 Architecture 最终处置对齐为 **有界 Pass**。整包 **不是** 无条件 Pass：UNKNOWN 残余仍在，child / parent / F-02 revalidation / F-02 reconcile Assignment **均未 Closed**，且本轮未重跑 contract tests / format。

| 严重级别 | 数量 |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| 开放条件 | 见下「条件」与残差表；均为 UNKNOWN / not claimed / 生命周期未关闭，不是实现相对 child scope 的失败 |

Child scope **已满足有界工程结论**。不满足「无残余即可 Close」。

### 条件

1. 残差表中 **UNKNOWN**（缝区同坐标 tap、九键 overlay 关/开、真机 VoiceOver）保持开放；**不得**用本 Verdict 关闭 child 或 parent。
2. F-02/QR-01 仅在 Architecture 写死 Bound 内成立（26 键 Messages、可见 **q** 键面中心 `(25.65, 697.5)`、overlay OFF/ON、iPhone 17 Pro Max / iOS 27 Simulator / UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`）。
3. Globe / `nextKeyboard` 本切片为 `exists=false hidden-or-unneeded`，**不是** 功能键 identifier 发布结论，也 **不是** 真机 VoiceOver。
4. INT-003、QA-001、性能、Product Gate、Release、TestFlight、publication **not claimed**。F-02 证据 **不得** 上提为上述任一项。
5. `KeyAccessibilityContractTests` 与 Swift 格式仅为 **先前 Quality-reverified 输入**；本轮未重跑，不得写成当前重验绿。
6. 结论钉在上表未提交 diff 哈希。实现或 overlay/hit-routing 再改、Arm A/B 或 F-01 工件移动/哈希失效，必须重验。

## F-01 AX（独立键 + UIKit tap，无宿主注入）

**有界 Pass**（26 键 Messages Simulator；独立 Quality AX 工件，本轮只读抽查）。

Harness：`NativeExperienceKeyboardAutomationFeasibilityTests.testUniverseKeyboardIndependentKeyTargets()`（`TYPO_AX_HARNESS=1`）。查询独立 `Key`：`q` / 删除 / 空格 / 回车 / 键盘页面 / 输入语言。字母与删除随后 `letter.tap()` / `delete.tap()`。测试正文声明且源码路径 **无** `typeText` / pasteboard / `setMarkedText` / `documentContext`。

### 抽查工件（本轮未重跑）

| 项 | Pointer |
|---|---|
| Quality AX 附件 | `/tmp/uk-quality-ax-001-artifact/EF288BF9-9412-4F92-A45E-80A55A65762F.txt` SHA-256 `5a51ce527dbf35dec1ee6dc76f0bb4131a8ea05deb33c774e7c373d52b4eab1a` |
| Screenshot | `/tmp/uk-quality-ax-001-artifact/5BF58579-2B50-4111-862C-F838A7560A1A.png` SHA-256 `2c2588c479dddbd3d1f7782061659e033a266fe73d6ad86e30bcb5f21f11ae62` |
| Manifest | `/tmp/uk-quality-ax-001-artifact/manifest.json` SHA-256 `f57c20f86ed955ba82323afe64fcfa87193d17eed1737284475d25ca43fdda4d` · device `iPhone 17 Pro Max` / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Activities | `/tmp/uk-quality-ax-001-activities.json` SHA-256 `5cb96ecbccd494d1b16b7a6693770d36ceba817182e6f47fff8829d49ae99553` |
| Correlated log（同设备、overlay OFF 热路径） | `/tmp/uk-f02-reval/QR-F02-REVAL-20260919T071659Z-FC1AEA63/overlay-off/correlated-log-tail.txt` |

附件摘要（抽查原文）：

```
role=letter query=q exists=true hittable=true label=q identifier=q type=20
role=Delete query=delete|删除 exists=true hittable=true label=删除 identifier= type=20
role=Space query=space|空格 exists=true hittable=true label=空格 identifier= type=20
role=Return query=return|回车 exists=true hittable=true label=回车 identifier= type=20
role=page switcher query=键盘页面 exists=true hittable=true label=键盘页面 identifier= type=20
role=language switcher query=输入语言 exists=true hittable=true label=输入语言 identifier= type=20
role=globe query=nextKeyboard|切换键盘 exists=false hidden-or-unneeded
```

Failure boundary：`Letter, Delete, Space, Return, page-switcher and language-switcher keys were independently addressable.`
Limitation：`AX key discovery and UIKit tap path observed; no host insertText, pasteboard or marked-text injection was used.`

Activities（同一 run）：`Tap "q" Key` → `Tap "删除" Key`；device iOS 27.0 (24A434)。对应日志（`13:20:49` / `13:20:50`）：`KBDVIS began role=character` → `endedInside` → `insertKey enter after keyDown`，随后 `began role=function` → `endedInside`。这是既有 `insertKey` / 功能键 UIKit 路径，不是宿主注入。

F-02 Arm A overlay-off 稍后再次跑同一 harness（`15:23:56`），AX 附件 `95B58F65-46CD-4D42-A667-E9CBD1DCC0D7.txt` SHA-256 `c27040e16aa4b435995904e1e59d4d3722b22bbc3b8314f3f05185cc063bba5f` 含相同六键 `hittable=true` 与独立 `Key, … identifier: 'q'`。该 run **同时** 服务 F-01 复现与 F-02 overlay-off；**不得** 把 15:23 臂当作 INT-003 / QA-001。

实现只读核对（未改文件）：`KeyboardTouchRoutingCanvas` 不再 `accessibilityElementsHidden = true`；`accessibilityFrame` 为 `.null`；canvas 不 vend AX children。键按钮 `isAccessibilityElement = true` 且 `.keyboardKey`。这与独立 `XCUIElementTypeKey` 发现一致。

功能键 XCUI `identifier` 在 probe 摘要中为空（匹配靠 label）。源码 contract 仍钉 `delete` / `space` / `return` / `nextKeyboard`。这 **不是** F-01 hittable 失败；见残差 `QA-TA-01`。

## F-02 / QR-01（与 Architecture 最终处置对齐）

**有界 Pass。** Quality 接受 Architecture [`最终处置`](typo-correction-002-testability-accessibility-f02-architecture-final.md) 与 [`对账收据`](../evidence/typo-correction-002-testability-accessibility-f02-reconciliation.md)。本轮只抽查哈希与 xcresult 摘要，不重新解释 Bound 外事实。

| Arm | Overlay | Run ID | 抽查 |
|---|---|---|---|
| A | OFF `TOUCHPROBE ov=0` | `QR-F02-REVAL-20260919T071659Z-FC1AEA63` | `overlay-off/test.xcresult` `Passed` `passedTests=1`；AX `q` `{{7.0, 675.0}, {37.3, 45.0}}` 中心 **(25.65, 697.5)**；`KBDVIS` character `began` → `endedInside` → `insertKey` @ `15:23:56`（27.4ms） |
| B | ON `TOUCHPROBE ov=1` | `QR-F02-REVAL-20260919T073732Z-113A0BDB` | `overlay-on/test.xcresult` `Passed` `passedTests=1`（`Test - F02TapUITests`）；coordinate tap `(25.6, 697.5)` 视为 XCUI 一位小数显示，**不是** 第二点；`immediately-before-tap.png` SHA-256 `ccf7caf31e1d24a2ed5cbeacc8ad00b0a56f452ae8288af6d0f3929b6c06f4f6`；after SHA-256 `3fc2a1ba90a35dcca7214cb6f2329d1db7abfee73459ace0306bf30083572ef6`；`log-delta-around-tap.txt` SHA-256 `ad72ead65309fa4856cbdc9fb10195b508650f32b1fd22bc9453206bae55abcf`；character `began` → `endedInside` → `insertKey` @ `15:43:22`（28.0ms） |

Arm A 同一次采集的 `overlay-on/` 为 **Skipped**，**不是** overlay-on 证据。overlay-on 以 Arm B 为准。

只读核对 `Keyboard/Views/DebugKeyTouchRangeOverlayView.swift`：`DebugKeyTouchRangeOverlayView` / canvas / `probeLabel` 均 `isUserInteractionEnabled = false`。两臂同一 `character` 路径，与 KEY-TOUCH-FILL「只绘制、非第二条命中路径」一致。Arm B `SLOW RIME` **忽略**，不作性能结论。

Quality 将 Architecture 表中 **QR-01 = Pass (bounded)** 收为本 consolidated 包的 F-02 条件项 **已在 Bound 内解除**。边界外仍 UNKNOWN / not claimed。

## Contract tests / format（先前 Quality-reverified，本轮未重跑）

| 输入 | 本轮处置 |
|---|---|
| `KeyboardTests/KeyAccessibilityContractTests.swift`（独立 AX 元素、canvas 不占 AX 空间、无宿主注入字符串、UIKit target-action） | **引用先前 Quality-reverified**。本轮只读源码：断言仍钉 `isAccessibilityElement = true`、`.keyboardKey`、`accessibilityElementsHidden = false`、`get { .null }`、禁止 `insertText(` / `UIPasteboard` / `setMarkedText` / `documentContext`。**未** 再跑 KeyboardTests。 |
| 实现 `.swift` 的 `swift-format lint --strict` | **引用先前 Quality-reverified**（实现切片交付时）。本轮 **未** 再跑 format。 |

不得把「本文件存在」写成「本轮测试绿」。后续 publication 若含 `.swift`，须按 `AGENTS.md` 重新满足格式硬门槛与受影响 target。

## Residual table

| ID | Owner | Disposition | Pointer |
|---|---|---|---|
| **F-01** | Quality | **Pass (bounded)** | 26 键 Messages Simulator；独立 Key `q`/删除/空格/回车/键盘页面/输入语言 `hittable=true`；字母+删除 UIKit tap；无宿主注入。Quality AX 附件 + activities。 |
| **F-02 / QR-01** | Architecture / Quality | **Pass (bounded)** | Architecture 最终处置 Bound；Arm A/B Run IDs；overlay 只绘制。 |
| **QA-TA-01** 功能键 XCUI identifier 空 | Keyboard UI | **accept** | Probe 靠 label 命中；源码 contract 仍钉 identifier。关闭 F-01 不要求 XCUI identifier 非空。 |
| **QA-TA-02** Globe / `nextKeyboard` hidden | Keyboard UI | **UNKNOWN** | `exists=false hidden-or-unneeded`；未证明 `needsInputModeSwitchKey` 为真时的 hittable globe。 |
| 缝区同坐标 tap | Quality | **UNKNOWN** | 未行使 |
| 九键 overlay 关/开 | Quality | **UNKNOWN** | 未行使；F-02 Bound 排除九键 |
| 真机 VoiceOver | Quality / Human | **UNKNOWN** | Simulator only |
| INT-003 | Input Intelligence | **not claimed** | parent `TYPO-CORRECTION-002` |
| QA-001 | Quality | **not claimed** | parent |
| 性能 / SLOW RIME | Quality | **not claimed** | Arm B 日志噪声 |
| Sidecar observability | Input Intelligence | **not claimed** | parent 继续 |
| Product Gate / publication / child Close / parent Close | Product Lead | **not claimed** | 无对应 Authorization |

KOS 2.1：UNKNOWN 与 not claimed **不是** Close 许可。`accept` 仅适用于 QA-TA-01（本 Quality 包内）。

## Explicit non-conclusions

- **不得**用于缝区 tap、九键、真机 VoiceOver、globe hidden 可用性。
- **不得**用于 INT-003、QA-001、性能、Product Gate、Release、TestFlight、publication。
- **不**关闭 child `TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001`。
- **不**关闭 parent `TYPO-CORRECTION-002`。
- **不**关闭 sidecar F-02 revalidation Assignment，也 **不** 关闭 child reconcile Assignment `TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001`（仍 `Reviewed`）。
- 本文件 **不是** 实现切片可提交/可合并的证明。
- F-02 有界 Pass **不等于** overlay/hit-routing 的全布局证明。

## Auth / Assignment consumption

| Record | Result |
|---|---|
| Human 第 3 步（本 consolidated Quality） | **consumed by this review**；不可再用于采集、代码或 publication |
| Child `AUTH-…-F02-RECONCILE-001` | 已 consumed；本轮不复用 |
| Child `AUTH-…-F02-ARCHITECTURE-001` | 已 consumed；本轮不复用 |
| Sidecar `AUTH-…-F02-REVALIDATION-001` | 已 consumed（采集用尽） |
| Sidecar implementation AUTH / Assignment | 只读链接；**未 Closed** |
| Parent `TYPO-CORRECTION-002` | **Active**，**未 Closed** |

## Handoff

- Consolidated Quality：**Pass with conditions**。
- Next（另授）：publication Authorization；child/parent Close；INT-003 / QA-001 / 性能；缝区/九键/真机 VoiceOver / globe-visible 若产品要求。
- Revalidation：实现 diff 哈希变化、overlay/hit-routing 源码变更、F-01/F-02 工件移动或哈希失效、或试图把本 Verdict 扩到 Bound 外。
