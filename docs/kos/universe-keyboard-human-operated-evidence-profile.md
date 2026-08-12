# Universe Keyboard 人工真机证据运行 Profile

> **Status:** Active project operational profile
> **Authority:** Human Product Lead，当前会话 `2026-08-12 Asia/Shanghai`
> **Applies to:** 需要 Human Device Operator 的 iPhone / iPad 功能、性能、内存、Jetsam、A/B 或发布证据
> **General source:** KOS Agent Kit [H-01 draft PR #2](https://github.com/shchnk1103/kos-agent-kit/pull/2)；本文件只记录 Universe Keyboard 特有规则

## Purpose

把决定证据是否可用的机器检查放在第一次人工操作之前。目标不是减少质量门，而是避免在二进制、
安装状态、App Group 或测量环境已经不可比时继续消耗用户时间。

本 Profile 不授权新的设备操作、模型暂存、发布、Product Gate 或 Release Gate。每次正式运行仍需有效
Assignment；Assignment 可以收紧规则，但不得静默放宽。

## Human-cost Gate

- 每个正式 run 的人工轮次默认上限为 `1`。
- 首次人工动作前必须列出会使证据失效的命令和状态变化。
- 机器前置条件失败、证据作废或人工预算耗尽时默认 `Hold`。
- 只有 Assignment 指定的 Human Product Lead / Product Approver 可以增加人工轮次。
- Executor 不得以“只差最后一次”或“接近成功”为理由自动请求重测。

这里的“一轮”是完成同一 manifest 下书面序列所需的一组连续人工动作；工具故障、重新安装或重新构建
导致 manifest 改变时，该轮已经失效，不能继续复用。

## Immutable Run Manifest

正式 baseline 前至少固定：

| Boundary | Required identity |
|---|---|
| Source | commit、tree、dirty-state disposition |
| Main App | 已安装 executable 的 UUID、SHA-256、size |
| Keyboard Extension | 已安装 extension stub/executable 的 UUID、SHA-256、size |
| Debug payload | `Keyboard.debug.dylib` 等实际承载业务代码的动态载荷 UUID、SHA-256、size（若存在） |
| Embedded runtime | 会影响归因的 framework/dylib/vendor artifact 身份与摘要 |
| Build | Debug/Release、优化级别、SDK、deployment target、Swift flags、签名身份 |
| Runtime | device、OS、schema/config fingerprint、Full Access、host 与输入字段类型 |
| Treatment | fixture、模型或配置的不可变 ID、size、SHA-256 |

commit、scheme 名、外层 App/Extension UUID 或一次绿测都不能单独证明两臂使用相同实际载荷。比较型证据
必须对所有可能承载差异的 payload 逐字节匹配。

## Command Side-effect Ledger

Runbook 中每条命令必须标注一种或多种副作用：

| Operation | Default classification |
|---|---|
| `xcodebuild build` / `build-for-testing` | `build` |
| 物理设备 `xcodebuild test` | `build + install + execute + possible App Group mutation` |
| `test-without-building` | **UNKNOWN until dry-run**；仍可能安装 test host/App，不得按名称视为 read-only |
| `devicectl device install app` | `install` |
| 向 App Group copy/move/delete | `mutate` / `cleanup` |
| `xctrace record`、已安装二进制身份读取、日志清单 | 对设备载荷 `read-only`；本地会生成 evidence artifact |
| 恢复普通 App/Keyboard | `install`；会终止当前 frozen run |

Manifest 冻结后，任何未列入 allowlist 的命令以及任何 `build` / `install` 默认禁止。若必须执行，立即作废
当前 run，不能把重新生成的载荷继续当作同一 A/B。

## Canonical State Machine

```text
machine preflight
  → build once
  → install once
  → freeze installed-payload manifest
  → independent readiness review
  → baseline arm
  → treatment/stage without build or install
  → re-read installed-payload manifest
  → treatment arm
  → cleanup
  → ordinary-input smoke
  → handoff
```

具体 Assignment 可以省略不适用的 treatment arm，但不能调整为可回跳状态机。所有 helper 必须在人工前
通过无人工 dry run 证明：路径语义正确、不会隐式 build/install、失败关闭、清理可恢复。

## Readiness Review

向 Device Operator 发第一条指令前，Architecture/Quality reviewer 按 Assignment 分工只复核一页：

- manifest 覆盖真实 App、Extension 和 Debug 动态载荷；
- 所有命令已分类，冻结后 allowlist 不含 build/install；
- treatment/stage 不依赖会覆盖安装 App 的测试流程；
- baseline 与 treatment 之前都能重新读取关键 SHA；
- crash/Jetsam 时间窗、目标进程和普通生命周期退出分类已定义；
- 输入、候选、host 文本和其他用户内容不会进入日志或 receipt；
- cleanup 的身份校验、零残留查询与失败路径已验证；
- 人工轮次上限和重新授权人明确。

源码 review、CI 全绿和历史真机结果不能替代 readiness review。

## Content-free Receipt

成功路径只向对话和 reviewer 提供小型结构化摘要，至少包含：

```json
{
  "runId": "TODO",
  "installedPayloadMatch": false,
  "deviceAndOSMatch": false,
  "schemaAndConfigMatch": false,
  "treatmentPinMatch": false,
  "humanRoundsUsed": 0,
  "newKeyboardCrash": false,
  "keyboardJetsamVictim": false,
  "cleanupZeroResidue": false,
  "rawArtifactPointers": []
}
```

Instruments trace、sysmon XML、xcresult 和 crash/Jetsam 原文保存在受控 evidence 位置，只在异常字段需要
复核时定向展开。receipt 是索引，不替代原始 artifact；关键统计必须可由原始文件独立重算。

## Invalidation And Cleanup

发现失效后立即记录：

`arm / reason / discovered-at / excluded-artifacts / cleanup / next-authority`

作废 arm 可保留为明确标记的诊断观察，但不能参与 A/B 归因、通过率、Quality-reverified、Product Gate
或 Release Gate。模型、fixture 或临时配置的清理必须先验证固定身份；无法确认身份时停止破坏性操作，
保留可恢复检查点并交回 owner。

## Token And Operator Efficiency

- XCTest 先读 summary，失败时才展开具体用例日志。
- xctrace 先产出 TOC 与指标 JSON，原始 XML 不整段进入对话。
- crash/Jetsam 先按时间窗、进程和 victim 筛选，再打开单个候选。
- 成功命令只报告 exit code、计数、artifact 路径和 SHA。
- 给 Device Operator 的每条消息只包含当前状态、一个动作和完成回执。

这些规则只改变信息展开顺序，不允许跳过测试、原始证据、独立复核或人类 Gate。

## Provenance

本 Profile 源于
[`TD-012 G2 execution retrospective`](../evidence/td-012-lmdg-model-g2-execution-retrospective-2026-08-12.md)：
baseline 后运行物理设备 stage test 重新链接并安装了不同 `Keyboard.debug.dylib`，而 decisive SHA check
直到人工输入结束后才执行。该历史说明为什么必须把实际载荷校验和命令副作用审计前移；它不自动重开
已经 `Closed / Product Hold` 的 TD-012 G2。
