# Architecture 最终处置：F-02 有界 Pass

**Reviewer:** 独立 Architecture & Knowledge Steward（非实现 Executor、非对账收据作者）
**Date / timezone:** `2026-09-19 Asia/Shanghai`
**Authorization (consumed by this review):** [`AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-ARCHITECTURE-001.md)
**Input receipt:** [`typo-correction-002-testability-accessibility-f02-reconciliation.md`](../evidence/typo-correction-002-testability-accessibility-f02-reconciliation.md)
**Reconcile Assignment:** [`TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001`](../assignments/typo-correction-002-testability-accessibility-f02-reconcile-001.md) — `Reviewed`，**未 Closed**

本文件是 Architecture 对 `F-02` 的最终有界处置。它不是 Product Gate、不是 consolidated Quality verdict、不是 child/parent Close、不是 publication。

本轮 **未** 新开 Simulator、**未** 再点键盘、**未** 改 `.swift`。

## Verdict

**有界 Pass。** 先前 Architecture / Quality 的 **Pass with conditions** 中，条件项 `F-02` / `QR-01`（同一可见键面坐标、Debug overlay 关/开不得改命中、不得成为第二条命中路径）在下列边界内 **已收口**。

有界 Pass **不等于** 无条件 Pass。边界外一律 `UNKNOWN` 或 **not claimed**，不得上提。

## Bound（写死）

本 Verdict **仅** 覆盖同时满足的全部条件：

| 维度 | 允许的事实 |
|---|---|
| 布局 | **26 键**（`realizedLayout=twenty_six_key`，非九键） |
| Host | **Messages** `com.apple.MobileSMS` |
| 键 | 可见 **q** 键面 |
| 坐标 | AX 框 `{{7.0, 675.0}, {37.3, 45.0}}` 中心 **(25.65, 697.5)**，440×956 应用空间 |
| Overlay | Debug KEY-TOUCH-FILL overlay **OFF**（`TOUCHPROBE ov=0`）与 **ON**（`ov=1`） |
| 设备 | **iPhone 17 Pro Max** / **iOS 27** Simulator / UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| 路径 | `KBDVIS` `role=character` `began` → `endedInside` → 既有 `insertKey` |

超出上表的任何坐标、键、布局、host、真机或 overlay 机制，**不得**引用本 Verdict。

## Independent verification

抽查路径：`/tmp/uk-f02-reval/QR-F02-REVAL-20260919T071659Z-FC1AEA63/` 与 `...113A0BDB/`。哈希与收据一致。

### 同一 q 坐标

Arm A AX 附件 `95B58F65-46CD-4D42-A667-E9CBD1DCC0D7.txt` SHA-256 `c27040e16aa4b435995904e1e59d4d3722b22bbc3b8314f3f05185cc063bba5f`：

```
Key, … {{7.0, 675.0}, {37.3, 45.0}}, identifier: 'q', label: 'q'
```

中心：`7.0 + 37.3/2 = 25.65`，`675.0 + 45.0/2 = 697.5`。

Arm B runner `/tmp/uk-f02-reval/...113A0BDB/runner/F02TapUITests/TapQAtArmACoordinateTests.swift` 使用 `CGVector(dx: 25.65, dy: 697.5)`，`activate()` 已可见 Messages，**无** `launch()`。xcresult activity：`Tap Application 'com.apple.MobileSMS'[0.00, 0.00] -> (25.6, 697.5)`。Architecture 将 `(25.6, 697.5)` 视为 XCUI 一位小数显示，**不是** 第二个点。

### Arm A — overlay OFF

| 项 | 独立复核 |
|---|---|
| Run | `QR-F02-REVAL-20260919T071659Z-FC1AEA63` |
| `defaults` | `overlay-off/defaults-read.txt` = `0` |
| `TOUCHPROBE` | `[15:23:42.662] … ov=0 k=32 face=13 fill=19 maxVH=45 maxTH=54` |
| 动作 | `[15:23:56.557] KBDVIS began role=character` → `[15:23:56.588] endedInside` → `insertKey enter after keyDown (27.4ms)` |
| xcresult | `overlay-off/test.xcresult`（源 `Test-UniverseKeyboardUITests-2026.09.19_15-22-25-+0800.xcresult`） |

同一 Run 的 `overlay-on/` 为 **Skipped**（`passedTests=0 skippedTests=1`），**不是** overlay-on 证据。overlay-on 以 Arm B 为准。

### Arm B — overlay ON

| 项 | 独立复核 |
|---|---|
| Run | `QR-F02-REVAL-20260919T073732Z-113A0BDB` |
| Device | xcresult `Devices.identifier` = `06C5BC3E-7599-4761-A1A2-71DAEA991474`，iOS 27.0 (24A434) |
| `TOUCHPROBE` | `[15:35:08.888] … ov=1 k=32 face=13 fill=19 maxVH=45 maxTH=54`（与 Arm A 稳定探针同 `k/face/fill/maxVH/maxTH`） |
| 橙色 overlay 截图 | `immediately-before-tap.png` SHA-256 `ccf7caf31e1d24a2ed5cbeacc8ad00b0a56f452ae8288af6d0f3929b6c06f4f6` |
| 动作 | `[15:43:22.029] KBDVIS began role=character` → `endedInside` → `insertKey enter after keyDown (28.0ms)`；`log-delta-around-tap.txt` SHA-256 `ad72ead65309fa4856cbdc9fb10195b508650f32b1fd22bc9453206bae55abcf` |
| 结果 | `immediately-after-tap.png` SHA-256 `3fc2a1ba90a35dcca7214cb6f2329d1db7abfee73459ace0306bf30083572ef6` — composer 显示 `q`，overlay chrome 仍 ON |
| xcresult | `overlay-on/test.xcresult`（源 `Test-F02TapUITests-2026.09.19_15-42-57-+0800.xcresult`）`Success` |

日志记 `keyLength` 不记字形；字形由 after 截图绑定。Arm B 含 `SLOW RIME` 行，**忽略**，不作性能结论。

两臂均无本切片声称的 `typeText` / pasteboard / `setMarkedText` / `documentContext`。Quality runner 在 `/tmp/.../runner/`，不在产品树。

### KEY-TOUCH-FILL：overlay 只绘制

对照 [`PD-KEY-TOUCH-FILL-001`](../product-decisions/KEY-TOUCH-FILL-001-authorization.md)：overlay **只绘制** 同一 hit-test 快照；`isUserInteractionEnabled = false`，不得成为第二条命中路径。

只读核对 `Keyboard/Views/DebugKeyTouchRangeOverlayView.swift`（未改文件）：

- `DebugKeyTouchRangeOverlayView` / `DebugKeyTouchRangeOverlayCanvas` / `probeLabel` 均 `isUserInteractionEnabled = false`
- overlay **没有** `hitTest` override；命中仍走既有 `KeyboardInputHitAreaStackView`

两臂同一 `character began/endedInside` + `insertKey` 路径，与「paint-only、非第二条业务路径」一致。本结论 **不** 把 KEY-TOUCH-FILL 的缝区/九键/真机 Gate 重新打开或复用。

## Residual disposition

| ID | Owner | Disposition | Bound / pointer |
|---|---|---|---|
| **F-02** | Architecture | **Pass (bounded)** | 上表 Bound。条件已在该边界内解除。 |
| **QR-01** | Quality | **Pass (bounded)**（Architecture 接受对账收据；consolidated Quality verdict 仍另授） | 同 Bound。证据收据。 |
| 缝区同坐标 tap | Quality | **UNKNOWN** | 未行使 |
| 九键 overlay 关/开 | Quality | **UNKNOWN** | 未行使 |
| 真机 VoiceOver | Quality / Human | **UNKNOWN** | Simulator only |
| INT-003 | Input Intelligence | **not claimed** | parent `TYPO-CORRECTION-002` |
| QA-001 | Quality | **not claimed** | parent |
| 性能 / SLOW RIME | Quality | **not claimed** | Arm B 日志噪声 |
| Sidecar observability | Input Intelligence | **not claimed** | parent 继续 |
| Globe / 功能键 identifier 发布 | Keyboard UI | **accept / out of this residual** | 关闭 F-02 不需要 |

KOS 2.1：`F-02` 不再以「缺 overlay 同点证据」作为 **Pass with conditions** 的开放条件。边界外的 `UNKNOWN` **不是** 本 residual 的未处置条件，**也不是** 关闭 child/parent 的许可。

## Explicit non-conclusions

- **不得**用于 INT-003、QA-001、性能、Product Gate、Release、TestFlight、publication。
- **不**关闭 child `TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001`。
- **不**关闭 parent `TYPO-CORRECTION-002`。
- **不**关闭 sidecar F-02 revalidation Assignment；其 AUTH 仅因采集已用尽而 **consumed**，生命周期仍 **未 Closed**。
- 本文件 **不是** consolidated Quality verdict。Quality 总评需另授 AUTH。
- 本文件 **不是** 实现切片可提交/可合并的证明。

## Auth consumption

| AUTH | Result |
|---|---|
| Child `AUTH-…-F02-ARCHITECTURE-001` | **consumed**（本审查） |
| Child `AUTH-…-F02-RECONCILE-001` | 已 consumed（对账切片）；本轮不复用 |
| Sidecar `AUTH-…-F02-REVALIDATION-001` | **consumed**（采集授权已用尽；证据绑定 child 收据） |

## Handoff

- Architecture `F-02`：**有界 Pass**，边界见上。
- Next（另授）：consolidated Quality verdict；publication；child/parent Close；INT-003 / QA-001 / 性能。
- Revalidation：overlay / hit-routing 源码变更、Arm A/B 工件移动或哈希失效、或试图把本 Pass 扩到缝区/九键/真机/其它坐标。
