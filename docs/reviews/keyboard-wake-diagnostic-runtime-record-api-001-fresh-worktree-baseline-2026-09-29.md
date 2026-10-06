# KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001 — Fresh Worktree Baseline

状态：**Executor-recorded，只读基线身份核对**。本记录把实现授权绑定到新建的隔离 worktree 与精确源码/测试输入；不表示实现、测试或 Gate 已完成。

## Worktree and authority

- Date: 2026-09-29 Asia/Shanghai.
- Worktree: `/Users/doubleshy0n/.codex/worktrees/runtime-record-api-impl/Universe Keyboard`.
- Managed worktree artifact: `01a0ebb2-8eef-71e0-858a-7c8bd64446ee`, attached to the current task.
- Base `HEAD`: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`.
- Runtime Record API Assignment: SHA-256 `f55fe7526b112b9d25fa90e1ce248ba97d31d403d681d3490b375958ffd73016`.
- ADR 0036: SHA-256 `f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c`.
- Product implementation authorization: SHA-256 `7f2e472552efd7c7016770f6182aafcf4c54b834222a441d62245503952643e7`.
- Implementation authority is recorded in [Product Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001-implementation-authorization.md).

The old `keyboard-wake-diagnostics` worktree was treated as read-only. Only the five exact Reader dependency files and the KOS/ADR evidence needed for this Assignment were copied into the newly created worktree. No Main App, Keyboard Extension, or other task's source files were copied.

## Nine-file KeyboardCore source/test identity

Each hash is SHA-256 of the current file bytes. The manifest sorts paths and hashes newline-terminated rows of `path\0current-SHA256\0worktree-state\0HEAD-SHA256-or-UNTRACKED`; state values are `Clean`, `Modified`, and `Untracked`.

| File | State | `HEAD` SHA-256 | Current SHA-256 |
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

Nine-file manifest SHA-256: `3e7338898e88d5732d98da210d31df915bfe4b8880a9704273c96d38b6240f2c`.

The five-file Reader candidate copied into this worktree recomputes to `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`, matching its reviewed implementation evidence. `DiagnosticEventTests.swift` and `DiagnosticsJournalTests.swift` remain protected; new writer coverage must use a separate test file.

## Writer isolation and limits

The new managed worktree was created for this task after the prior worktree's exclusive writer status could not be established. It is attached to the current task and is distinct from the older worktree. This establishes ownership within the managed task worktrees; it does not assert ownership over the user's entire machine. The active task inventory does not identify this newly created path as another task's checkout.

`git ls-remote origin refs/heads/main` could not reach GitHub because network access is unavailable. The candidate therefore remains pinned to the exact reviewed `HEAD` above; this receipt makes no latest-main claim. No source implementation, test, build, Simulator, installation, v4 event emission, commit, push, or review Gate occurred while capturing this baseline.
