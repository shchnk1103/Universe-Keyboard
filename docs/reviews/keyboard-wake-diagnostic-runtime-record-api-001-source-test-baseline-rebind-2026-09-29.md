# KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001 — Source/Test Identity Rebind

状态：**Executor-recorded，只读身份快照**。本记录补充最终文档候选后的源码/测试身份核对；不推进 Assignment 生命周期，也不授权实现。

## 候选身份

- 日期：2026-09-29 Asia/Shanghai。
- 隔离 worktree：`/Users/doubleshy0n/.codex/worktrees/keyboard-wake-diagnostics/Universe Keyboard`。
- `HEAD`：`9eb83158e49218c1e8f75dbe7dd9e0390db81409`。
- Runtime Record API Assignment SHA-256：`1c1acea3c45e2a5026b9d0ce7605634d3ce5e420b2273079dcd7575b64fa3a14`。
- ADR 0036 SHA-256：`f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c`。
- 文档评审重绑定收据：[Final Candidate Rebind](keyboard-wake-diagnostic-runtime-record-api-001-final-candidate-rebind-2026-09-29.md)。

## Runtime API 范围内的源码与测试身份

以下 `HEAD` / 当前 SHA-256 和状态均相对上方 worktree 与 `HEAD`。`—` 表示文件在 `HEAD` 中不存在。文件清单摘要按路径排序，将每行 `path\0current-SHA256\0state\0HEAD-SHA256-or-UNTRACKED` 以换行连接，并在末尾保留换行后计算 SHA-256；状态文本使用 `Clean`、`Modified`、`Untracked`。

| 文件 | 状态 | `HEAD` SHA-256 | 当前 SHA-256 |
|---|---|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` | Modified | `1bd22fde04849e6a5f85ebc2750e80b7888931a3dc9a9e59c1aef3376ead3613` | `331f57ad6a55c6ceb041d30cf325a6a8bcd94b54dcf23553b22e67a99e90ce2b` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift` | Untracked | — | `554f06386f845e938b25926c6f62f81f5e75b488765a1367ab7f45ca591e8442` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` | Modified | `9c999e18645573da1519d0f84be0f83152e800a41b109783b5730788f7a4f005` | `c5a050217c6e02ba720d90e5a6298eadb7ab76f814c177be4049a4a5631402f0` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalIngress.swift` | Clean | `22df98f25a44704763e4669d60787c2157477a97587645645e5b10af3437a696` | `22df98f25a44704763e4669d60787c2157477a97587645645e5b10af3437a696` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift` | Clean | `9720d22bb3ec5668b7a9f466ac84c34d77c7a7ed2969da01b5c6f2568c41b406` | `9720d22bb3ec5668b7a9f466ac84c34d77c7a7ed2969da01b5c6f2568c41b406` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` | Modified | `89e60f281385a447a2475e1866325cfcaa8ec3dd134356c159ff6b47cd4d6a30` | `9ce72314f26fc308e92c459ee51672873490b73aa86d29296dddd8320ddebfb8` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` | Modified | `a712ec5b004af538346b63deac2ffad4980bb4d80c35a4c9c91fdaba8095820d` | `5e34af66516746a04c2e3dd560a404240a90a427c8c14656252457bff25cf947` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalIngressTests.swift` | Clean | `d2bcf72ea11831becbdc282975aaab66ec1b19df0fea7620f7d91d68aa2c49d6` | `d2bcf72ea11831becbdc282975aaab66ec1b19df0fea7620f7d91d68aa2c49d6` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalRuntimeTests.swift` | Clean | `ce92f25fd0d0666582217c78cd233615e18c78c65f3036fe78d77ccdf66459f0` | `ce92f25fd0d0666582217c78cd233615e18c78c65f3036fe78d77ccdf66459f0` |

九文件身份清单摘要：`3e7338898e88d5732d98da210d31df915bfe4b8880a9704273c96d38b6240f2c`。

## 已有变更的来源对应

- 五个 KeyboardCore reader 文件及其 reader 测试仍精确匹配已记录的 Reader 候选 `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`；详见[Reader 实现证据](../evidence/keyboard-wake-diagnostic-reader-implementation-001-2026-09-28.md)。
- Main App 的 `DiagnosticsLogSource.swift` 与对应测试仍精确匹配 Main App 候选 `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a`；详见[Main App 实现证据](../evidence/keyboard-wake-diagnostic-main-app-consumer-001-implementation-2026-09-28.md)。
- 五个 Keyboard Extension controller 文件仍匹配父诊断证据中的补丁摘要 `c4998815078e790e1a14109ecefde8a3fb467f197c90eece5dbda20b4a7f7a8d`；详见[生命周期诊断证据](../evidence/keyboard-wake-lifecycle-diagnostics-2026-09-27.md)。

这些对应关系能把本快照中的已知源码改动关联到已有 Assignment/证据候选，但不能证明当前没有其他进程持有写入权。

## Runtime writer 只读状态

- `DiagnosticsJournalRuntime.swift` 仍匹配历史基线，且没有本 Assignment 计划新增的三个 typed v4 submission methods。
- `DiagnosticEvent.schemaVersion` 仍为 `3`；reader 可解码 v4，不代表 writer 已切换。`DiagnosticsJournal.append` 仍要求事件满足 `isWritableV3`。
- 因此此快照确认的是 reader 兼容路径；没有 v4 typed API 或 v4 持久化 writer 实现。
- `DiagnosticEventTests.swift` 与 `DiagnosticsJournalTests.swift` 当前仍是 Modified。按 Assignment，要么使用隔离测试文件，要么先取得明确 writer handoff；本次未修改或运行这些测试。

## Writer ownership 与生命周期

任务清单显示有其他活动任务，但其 `cwd` 字段是项目 source checkout；当前任务的 worktree artifact 也以该 source checkout 作为 `sourceCwd`。任务清单未提供其他任务的 worktree attachment 或本机编辑器/进程写入状态，因此不能据此确认独占 writer ownership，也不能把未知状态记作“无人写入”。本次没有联系其他线程或检查其工作内容。

| Entry Criterion | 结果 |
|---|---|
| 精确源码/测试身份已采集 | 满足；见九文件摘要与上表。 |
| 已知 Reader、Main App、父诊断改动可对应到先前候选证据 | 满足；摘要均匹配。 |
| 当前没有其他活跃 writer，且独占写入归属已确认 | **未确认**；任务清单不足以证明。 |
| 独立实现授权 | **未满足**；ADR 0036 的条件接受不构成实现授权。 |
| Runtime Record API Assignment | 继续保持 **Assigned / Not Ready / Not Active**。 |

本次只读取源码/状态并记录身份：没有改源码或测试，没有运行测试、构建、Simulator 或安装，没有产生 v4 event，也没有提交、推送或关闭父 Assignment。这个时间点快照不构成 Quality/Product Gate、Release 或根因结论。
