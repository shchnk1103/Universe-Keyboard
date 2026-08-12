# DIAGNOSTICS-DAY-BROWSER-001 Execution Evidence

- Evidence grade: `Executor-recorded`
- Date / timezone: `2026-08-12 Asia/Shanghai`
- Baseline: `origin/main` at `9a177aba23f2443eb837313174ef27b32af7b4d3`
- Branch / worktree: `codex/diagnostics-v1-read-recovery` / isolated `/private/tmp` worktree
- Toolchain: Xcode `27.0 (27A5237l)`, Swift 6 strict concurrency
- Simulator: `iPhone 17 Pro`, iOS `26.5`, UDID `900FB396-39BF-4A84-9E75-FF813C155FA7`
- Physical device: not used

## Scope Evidence

The implementation is limited to KeyboardCore diagnostics reading, Main App diagnostics source/store/view, their tests, and KOS/changelog records. It does not modify RimeBridge source, Keyboard Extension candidate/input code, the Wanxiang G2 work, writer format, retention, generation clear, privacy fields, or device evidence. Existing ignored RIME Vendor artifacts were used only for local linking.

## Validation

| Grade | Check | Result |
|---|---|---|
| `Executor-recorded` | `swift-format lint --strict` on all changed Swift files | Pass |
| `Executor-recorded` | `git diff --check` | Pass |
| `Executor-recorded` | Targeted `DiagnosticsJournalTests` | Pass, 22 tests / 0 failures |
| `Executor-recorded` | Full `KeyboardCore` suite | Pass, 976 tests / 0 failures |
| `Executor-recorded` | Targeted `DiagnosticsLogSourceTests` + `DiagnosticsStoreTests` | Pass, 12 tests / 0 failures |
| `Executor-recorded` | Full `Universe Keyboard` scheme test | Pass, Main App 157 + Keyboard 6 / 0 failures |
| `Executor-recorded` | `RimeBridgeTests` | Pass, 57 tests / 0 failures / 20 environment-gated skips |
| `Executor-recorded` | Debug Simulator build, Swift 6 strict concurrency, warnings-as-errors | Pass |
| `Executor-recorded` | Release Simulator build, Swift 6 strict concurrency, warnings-as-errors | Pass |

## Independent Review Remediation

首轮独立 Architecture / Quality 均为 `Fail` 后，Human Product Lead 授权最小非-writer 修复。本轮补充以下证据：

- 部分预览只读取冻结 manifest 的 `byteWatermark`，并在返回前复核 generation 与 segment identity；并发追加不会混入已冻结窗口。
- 日期发现返回 typed `available / empty / unavailable`，目录读取失败不再退化为无范围查询或 legacy 混入。
- Store、Composite source 与 v1 source 使用请求 revision 废弃迟到的 root/page 结果；清空、日期切换和旧分页不再互相覆盖。
- 实时跟随最新日期时每次 tick 重新发现日期，因此午夜后首条记录延迟到达仍会自动前进；历史日期与已展开旧页保持稳定。
- 部分窗口即使没有完整 JSONL 可解码，也显示专用“不完整窗口”空态，不再宣称“暂无诊断日志”。

Remediation validation (`2026-08-12 Asia/Shanghai`):

| Grade | Check | Result |
|---|---|---|
| `Executor-recorded` | `swift-format lint --strict` on all changed Swift files + `git diff --check` | Pass |
| `Executor-recorded` | Full `KeyboardCore` suite | Pass, 977 tests / 0 failures |
| `Executor-recorded` | Targeted `DiagnosticsLogSourceTests` + `DiagnosticsStoreTests` | Pass, 18 tests / 0 failures |
| `Executor-recorded` | Real >5 MiB journal fixture through `V1DiagnosticsLogSource` | Pass, bounded non-empty partial preview |
| `Executor-recorded` | Full `Universe Keyboard` scheme test | Pass, Main App 164 + Keyboard 6 / 0 failures |
| `Executor-recorded` | `RimeBridgeTests` | Pass, 57 tests / 0 failures / 20 environment-gated skips |
| `Executor-recorded` | Debug + Release Simulator build, Swift 6 strict concurrency, warnings-as-errors | Pass |

Remediation result bundles:

- Targeted Main App: `/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-emxsvllcocrspwdtwulsntweaomy/Logs/Test/Test-Universe Keyboard-2026.08.12_14-02-05-+0800.xcresult`
- Full scheme: `/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-emxsvllcocrspwdtwulsntweaomy/Logs/Test/Test-Universe Keyboard-2026.08.12_14-04-35-+0800.xcresult`
- RimeBridge: `/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-emxsvllcocrspwdtwulsntweaomy/Logs/Test/Test-RimeBridgeTests-2026.08.12_14-04-04-+0800.xcresult`

Architecture re-review 对提交 `2c2654c` 判定 `Fail`：冻结 watermark、typed 日期失败、跨午夜跟随与 partial 空态已闭合，但 live tick 未推进 Store revision 或占用 root-query 状态，仍可与随后启动的 load-more 交叠。该结论触发同一最小授权内的后续修复与新确定性测试；上述门禁不得被解释为 Architecture Pass。

后续最小修复让 live tick 在任何 source await 前推进 Store revision 并设置 `isRefreshing`，从而同时废弃旧 Store 结果并阻止新 load-more。受控 catalog continuation 回归用例验证 root refresh 在途时 load-more 不会启动；完整 `DiagnosticsStoreTests` 定向运行通过。

最终 delta 验证：`DiagnosticsStoreTests` 14 项通过；完整 scheme Main App 164 项 + Keyboard 6 项通过；Debug 与 Release build 均以 exit `0` 完成。最终 full-scheme result bundle：`/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-emxsvllcocrspwdtwulsntweaomy/Logs/Test/Test-Universe Keyboard-2026.08.12_14-14-18-+0800.xcresult`。

Architecture 对 `fbc0ddf` 给出 `Pass`。Quality 随后在组合运行中稳定复现 >5 MiB 用例偶发 `journalUnavailable`：`V1DiagnosticsLogSource` 先启动 detached retention，随后立即申请 reader 的非阻塞 exclusive snapshot fence，可能与自己触发的 reclaimer 争锁。本轮将 retention ownership 收回既有 Main App lifecycle，source refresh 不再重复投递 reclaim；该结论触发再次门禁与 Quality re-review。

Retention/read 修复后，19 项 `DiagnosticsLogSourceTests + DiagnosticsStoreTests` 的有效独立运行均为 19/19 通过（重复验证期间另有一个与独立审查并发造成的损坏 xcresult，不计为通过证据）；Debug 与 Release build 均以 exit `0` 完成。Quality 必须基于最终冻结提交独立复核，Executor 不据此自授 Quality Pass。

无并发审查进程后的最终组合结果包为 `/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-emxsvllcocrspwdtwulsntweaomy/Logs/Test/Test-Universe Keyboard-2026.08.12_14-23-25-+0800.xcresult`，`xcresulttool` 摘要为 `Passed`、19/19、0 failures。

最终冻结提交 `e708d2852e001143b1008b355e6b035c25cd03f4` 获独立 Architecture `Pass` 与 Quality `Pass`。Quality 使用全新 DerivedData 连续三轮运行 Source + Store 组合套件，均为 19/19、0 failures，并独立运行 retention scheduler 2/2 通过。完整结论与 result bundle 见[独立复核记录](../assignments/diagnostics-day-browser-001-independent-review.md)。该结论不授予 ADR Acceptance、Product Gate、真机或 Release 状态。

Targeted Main App result bundle:
`/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-emxsvllcocrspwdtwulsntweaomy/Logs/Test/Test-Universe Keyboard-2026.08.12_13-16-43-+0800.xcresult`

Full scheme result bundle:
`/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-emxsvllcocrspwdtwulsntweaomy/Logs/Test/Test-Universe Keyboard-2026.08.12_13-22-37-+0800.xcresult`

RimeBridge result bundle:
`/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-emxsvllcocrspwdtwulsntweaomy/Logs/Test/Test-RimeBridgeTests-2026.08.12_13-18-41-+0800.xcresult`

## Non-claims And Remaining Handoff

- This evidence was not independently re-run by Architecture or Quality and does not accept ADR 0028.
- No physical-device installation, App Group observation, UI screenshot review, timezone-change interaction, candidate-bar test, G2 validation, merge, or Release claim was performed.
- The partial recent window is intentionally incomplete and has no older-page cursor. Complete deep pagination for arbitrarily large single-day history remains a future disk-index/external-merge design.
- A future combined branch containing G2 changes must run its own merge-base and integrated validation; this isolated evidence does not validate or alter G2.
- 同一 writer batch 跨 UTC 小时仍可能只按首事件小时命名；修复该问题会改变 writer 分段，已按 Assignment Stop Condition 留待重新授权。
- legacy `UserDefaults` writer 与清空的线性化屏障不在本次非-writer 最小授权内，仍需后续单独设计与验证。
