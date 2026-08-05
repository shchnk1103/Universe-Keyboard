# Architecture Review: T9-RESPONSIVE-PIPELINE-001 / R5-Rem-3-Polish

| Field | Value |
|---|---|
| Reviewer role | 🏛️ Architecture & Knowledge Steward（独立、只读增量复审） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md) |
| Code tip under review | `80ef54b`（当前文档 tip `3585a54`） |
| Previous implementation review | `9b9bbeb` + P1 remediation `8169f64` |
| Verdict | **Pass with conditions** |
| P0 / P1 / P2 / P3 | **0 / 1 / 3 / 1** |

## Scope

本次只读复审覆盖 Polish-1/Polish-2 相对既有 Rem-3 implementation review 的
增量：L1 延迟绘制、host-preedit-only、候选/Path chrome 稳定、generation/epoch
取消、gate-off 和 ADR 0025 边界。未修改文件、未提交、未运行测试；Quality 的
独立测试结果见配套 Quality review。

## P1-Polish-2-D2 — provisionalAhead 下 stale chrome 的契约漂移

Rem-3 D2 将 provisionalAhead 时的 Candidate/Path affordance 定义为
“disabled 或 cleared”。Polish-2 的 `applyProvisionalL1Visual` 只更新
`·×N` host preedit，不清空 chrome，也不触发 Extension `syncUI`。这解决了设备
上的闪烁，但 Candidate/Path 仍可能可见且看起来可交互；Core 入口会 fail-closed，
因此安全性尚在，但 UI 合同已改变。

需要 Product + Architecture 明确选择以下之一：

1. 实现真正 disabled/cleared 的 affordance，并保持无闪烁；或
2. 通过正式 Amendment 接受“provisionalAhead 期间稳定显示旧 chrome，所有相关
   Core 操作 fail-closed”的新合同，并同步设计、Product Decision、Assignment
   与证据文档。

在选择完成前，不能把 Polish-2 称为无条件 engineering/architecture closed，
也不能据此开启 Product Gate、ADR 0025 Accept 或 default-on。

## P2 / P3

- 未形成完整的 marked-text history、Candidate/Path 快照稳定性和 L2 后迟到 L1
  paint chronology 测试；`testFastEngineSkipsDeferredL1VisualPaint` 的
  `paints` 变量未形成有效断言。
- 未有 Polish 专门的 stale Candidate/Path、Space、Partial Commit tap 回归；
  既有 Core guard 提供安全性，但不足以证明当前 UI 合同。
- 48 ms 是 Debug 实验参数，不是产品 SLO；需要 fast/slow/zero-delay 边界与
  cancellation/epoch 测试后再作性能结论。
- `provisionalChromeStabilized` 当前仅赋值未读取，属于死状态/误导性状态。

既有 R4 owner mailbox/backpressure、L1_SKIP 可观测性等残余仍在，但不是本次
Polish 新增 P1。

## 已证明与未证明

已证明：Polish-2 避免每次 L1 触发 Extension chrome 重绘；L1 仍保持
structure-only host preedit；默认 gate 仍关闭；没有 ADR 0025 Accept 或
Product Gate 偷渡。

未证明：D2 affordance 合同在当前实现下仍成立；真实 Release/iOS 26.0、
多设备/多轮稳定性、jetsam、Product Gate 或主观 SLO。

## Handoff

当前建议：保持 dual-gate 默认关闭；先完成 P1-D2 的 Product/Architecture
契约决定，再补对应实现或 Amendment 与回归测试，之后才重新评估 R6 readiness。
