# INT003-P2-MEMORY-QUALITY-EVIDENCE-ADMISSION — R5 独立静态收尾

## 范围与身份

本轮只核对冻结 packet 指定的五个输入：`After.swift`、`Before.swift`、`approved-helper.patch`、`final-source-manifest.json`、`review-r4.md`。Packet SHA-256 与指定值 `5b2f03fdfea43e3f8d2c4750b5fce50ea06bff76c023c0f06e294851b9457960` 匹配。未运行测试、构建、格式化、设备或网络操作。

**调用流程有一处偏差：**第 1 次调用把 `After.swift` 路径误拼成含 `Evidence/` 的路径，未打印源码或写检查点；第 2 次调用读取了正确路径，并输出完整 315 行源码、差异及其余固定输入。本轮总计 2 次 `exec_command`，失败 1 次；没有超出预算，也没有额外读文件。首调用检查点未按时写出，已如实记录，不影响下列控制流证据的直接核对。

## E2 — attach 调用与计时顺序

helper 在 [After.swift:58-73] 中编码为 `Data`，按环境变量可在第 64-67 行写入 raw 文件，再创建 XCTest attachment。以下五个调用都位于对应计时区间结束之后：

| 调用点 | 控制流与计时证据 | 判定 |
|---|---|---|
| 第 97、98 行 | 测试先完成全部 30 组（第 77-95 行），每个 `competingUnit` 同步返回后才记录结果（第 81-84 行）。`competingUnit` 在第 142 行捕获 elapsed 终点，在第 148-155 行完成独立 freeze 计时，并于第 172-179 行返回。两次 `attach` 均在这些返回之后。 | 通过 |
| 第 188 行 | 测试先收齐全部 90 个 `orderedFreeze` 返回值（第 182-185 行），再 attach。R 的计时区间在 `freeze()` 内由第 197-200 行结束；`orderedFreeze` 完成后续断言并在第 241-244 行返回。 | 通过 |
| 第 309 行 | 每个 hook 的计时由第 259 行开始、第 264 行结束；30 组、每组两个 offset 全部完成后才到第 309 行。 | 通过 |
| 第 311 行 | 每个 freeze cohort 的计时由第 295 行开始、第 298 行结束；断言和结果收集完成后，全部 group/cohort 循环在第 307 行结束，再执行第 311 行 attach。 | 通过 |

因此五个调用点的 helper 写入和 XCTest attachment 创建均在对应测量结束后。`R4-E2-CALLSITE-001` 的静态缺口已闭合；owner：Quality / performance-test owner。

## 变更与 manifest 计数

`Before.swift` 与 `After.swift` 的差异仅是 helper 中新增编码结果复用、可选 raw 写入及对应 attachment 数据传递；与批准的 patch 一致。manifest 列出 22 个 `source_files`，且 `changed_paths` 只有 `QueryCostMemoryProbePerformanceTests.swift`。因此“20 个未变”的旧报告计数应更正为其余 21 个。manifest 中 `unaffected_source_count: 20` 与这两个列表的算术关系不一致；本轮只按固定输入核对列表和单文件差异，没有读取 predecessor manifest 或其他源码文件。

## E1–E4 范围结论

- **E1 — Covered（复用 R4 固定数据结论）：**30 项 skips 中 1 项 Keychain case 有独立 signed lane 通过；其他 29 项仍未验证。它们不计为通过，也不构成风险接受。
- **E2 — Covered：**本轮直接证明全部五个 attach 调用都在测量区间之后。
- **E3 — Covered（复用 R4 同候选、同数据结论）：**R4 对固定 raw 的身份、schema、计数和统计完成独立核对。此轮没有重跑 raw 统计。
- **E4 — Covered（限方法边界，复用 R4 结论）：**证据仍是 synthetic macOS Debug opt-in run；不能据此声称实际 iOS latency、生产 observer 或锁竞争结论。

## Findings 与 disposition

- **R4-E2-CALLSITE-001 — Closed。** 五个 attach 调用点的实际控制流均位于各自计时区间之后；证据见上表及 [After.swift]。
- **QEA-R1-SKIPS-029 — Open。** 29 项仍未验证。本轮未要求跨 scope 重跑，也未接受风险。
- **QEA-R1-PERF-RAW-001 — Closed，仅限 raw evidence 的可用性与完整性。** 不外推为 iOS 或产品性能通过。
- **QEA-R1-P2-ADMISSION-001 — E3 数据阻塞已解除；正式 Capture / RunReady 未评估。** 本轮不改变该边界。

## Scoped decision

**Scoped Pass — 仅限 raw retention / synthetic methodology 的静态收尾。** E1、E2、E3 与限定范围内的 E4 均已覆盖；不代表 Product、iOS observer、Capture、RunReady、Gate、Release 或风险接受通过。29 项 skips 仍开放。

## 未执行的未来验证

未来的真实 iOS observer、性能采集、Product / RunReady、Gate 与 Release 验证均未执行；它们不是本轮静态覆盖结论，也不能据此宣称已通过。

## 用量与时间

- 工具 UTC 起始：`2026-10-09T03:08:08.668006Z`
- 工具 UTC 结束：`2026-10-09T03:08:35Z`（结束戳为秒精度）
- 按记录戳计算：约 **26.332 秒**
- `exec_command`：2 次；失败：1 次。wrapper：2 次。
- 未写本地报告文件；由 Coordinator 按本消息代录并计算输出哈希。
