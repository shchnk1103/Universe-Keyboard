# Active Work Summary

> **KOS 2.1 ops · M-05**
> Cap: **≤ 10** items.
> **Lifecycle Source of Truth = Assignment Record** (not this file, not Dashboard).
> This page only **links** and restates **Current Status** fields.

Status snapshot (existing rows): `2026-09-03 Asia/Shanghai` — KOS-UPGRADE-UK-003 Closed（PR #96 merged `41c0dc5`，Adopted `v0.6.0` advisory）。产品 Active Work 为 `5/10`。

| # | Work Item | Lifecycle (from Assignment) | Phase / next | Assignment |
|---|---|---|---|---|
| 1 | RELEASE-2026-08-01 | Active | Human 已创建 Build 7 内部组并邀请两名 tester；Task11 F-01/F-02 仍 Pending。F-03 工程片已随 #83 合入 `main`，TestFlight tester 仍在 Build 7（不含该修复）。04/TD-003/004/005 仍需不同/稳定采集环境 | [`assignment`](assignments/release-2026-08-01.md) · [`Task11`](assignments/release-2026-08-01-11-internal-testflight-feedback.md) · [`feedback`](evidence/release-2026-08-01-11-internal-testflight-feedback-2026-08-25.md) · [`04 Assignment`](assignments/release-2026-08-01-04-device-performance.md) |
| 2 | RIME-BUILTIN-LUNA-QUALITY-001 | Active | PR [#98](https://github.com/shchnk1103/Universe-Keyboard/pull/98) merged `f352f50`。本片收工；Executor 无下一动作。无 Exit / TestFlight / Release | [`assignment`](assignments/rime-builtin-luna-quality-001.md) · [`Gate-98`](product-decisions/RIME-BUILTIN-LUNA-QUALITY-001-product-gate-98.md) |
| 3 | TYPING-INTELLIGENCE-001 | Active | 自动化验证完成；真机 / 无障碍 / 外观门未关 | [`assignments/typing-intelligence-001.md`](assignments/typing-intelligence-001.md) |
| 4 | TYPO-CORRECTION-002 | Active | Contextual recovery；指定 Simulator 场景 pending | [`assignments/typo-correction-002.md`](assignments/typo-correction-002.md) |
| 5 | RIME-SYNC-001 | Active | Run 02 单事务完成；正式 `INVALID` 审计结果保留，Human Product Owner 接受工程结论并决定暂不重测。仅在复发或路径实质变更时重开；旧轮次精确错误、`TD-002` pending | [`assignment`](assignments/rime-sync-001.md) · [`diagnostics`](assignments/rime-sync-diagnostics-v1-001.md) · [`Product Review`](product-decisions/RIME-SYNC-DIAGNOSTICS-V1-001-product-gate.md) · [`Run 01`](evidence/rime-background-sync-natural-device-run-2026-08-31.md) · [`Run 02`](evidence/rime-background-sync-natural-device-run-2026-09-01-r2.md) |

历史工作从 [Assignment 目录](assignments/) 查找；债务从 [TECH_DEBT](TECH_DEBT.md) 查找。
这里只保留 Ready / Active 工作，上限十项；Assignment 是生命周期事实来源，冲突时修正本镜像。
