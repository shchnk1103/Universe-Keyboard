# KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001 — Implementation Evidence

状态：**Executor-completed candidate；Architecture / Quality Pass with conditions；等待 Product Approver decision**。本记录绑定当前 KeyboardCore 实现与测试候选，不代表 Product/Gate、Release、父 Assignment 完成或关闭。

## 候选身份

- 日期：2026-09-29 Asia/Shanghai。
- Worktree：`/Users/doubleshy0n/.codex/worktrees/runtime-record-api-impl/Universe Keyboard`，managed worktree artifact `01a0ebb2-8eef-71e0-858a-7c8bd64446ee`。
- Base `HEAD`：`9eb83158e49218c1e8f75dbe7dd9e0390db81409`。
- Fresh baseline manifest：`3e7338898e88d5732d98da210d31df915bfe4b8880a9704273c96d38b6240f2c`，见 [Fresh Worktree Baseline](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-fresh-worktree-baseline-2026-09-29.md)。
- 当前十文件源/测试 manifest：`abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c`，见 [canonical JSON 清单](keyboard-wake-diagnostic-runtime-record-api-001-source-test-manifest-2026-09-29.json)。摘要为该清单完整文件 bytes 的 SHA-256；清单按相对路径排序，记录 current SHA、状态和 HEAD SHA/null，以 UTF-8、排序 key、紧凑 JSON 和末尾 LF 序列化。

| 文件 | 当前 SHA-256 | 状态 |
|---|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` | `3cac989b191becb73f8f943c963a8745c98322f4e0bcc06bf975671257727700` | Modified |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift` | `554f06386f845e938b25926c6f62f81f5e75b488765a1367ab7f45ca591e8442` | Untracked；沿用 Reader 候选 |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` | `b866691b1ab329836b7908000b8abeab6b33d2e1cf80d6c9e6133ea788e49bf4` | Modified |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalIngress.swift` | `8997a15734a1d2bf7e2c8f7e5304b32b19454979a44aaaecdbe8d505e4ffd556` | Modified |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift` | `95f6b93718d12fd19fae90545e6f57e21c055d1b0e5fbfa5d0c8b2647f20089d` | Modified |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` | `9ce72314f26fc308e92c459ee51672873490b73aa86d29296dddd8320ddebfb8` | Modified；与基线一致，未编辑 |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` | `5e34af66516746a04c2e3dd560a404240a90a427c8c14656252457bff25cf947` | Modified；与基线一致，未编辑 |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalIngressTests.swift` | `d2bcf72ea11831becbdc282975aaab66ec1b19df0fea7620f7d91d68aa2c49d6` | Clean |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalRuntimeTests.swift` | `ce92f25fd0d0666582217c78cd233615e18c78c65f3036fe78d77ccdf66459f0` | Clean |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalV4WriterTests.swift` | `ea9c139317bbec128d6dce187e4cf886d3865db038a18c85796a02189d9a3525` | Untracked；本 Assignment 新增 |

## 实现摘要

- `DiagnosticEvent` 增加受控 v4 payload 与内部 v4 writer envelope 编码，同时保留 v3 public Codable writer 路径和 v3 schema decoding。事件码、payload、origin、level、category 与空 `fields` 的配对由类型构造/解码约束。
- `DiagnosticsJournalWriter` 接受明确 writer version：默认 direct writer 继续按 v3 写；v4 writer 将本批可写事件规范化为 v4 后追加，不改写已落盘的 v3 字节；v3 writer 在编码前拒绝 v4-only event。
- `DiagnosticsJournalIngress` 与 `DiagnosticsJournalRuntime` 都默认选择 v3，并只把显式指定的 writer version 传给懒创建的 writer。没有生产源文件传入 `.v4`；在当前代码中，只有隔离测试显式 opt in。
- `DiagnosticsJournalRuntime` 增加 `recordKeyboardLifecycle`、`recordRimeResume`、`recordTextProxyOperation`。方法固定诊断码、level/category；仅 `.v4` Runtime 可接收 typed v4 事件，RIME phase/failure 不匹配或非 Extension origin 会 fail closed。通用入口拒绝需要 typed payload 的 v4-only codes。
- 新增独立临时目录测试，覆盖默认 v3 与 typed v4 拒绝、显式 v4 下三个 typed API 经 ingress 落盘、writer envelope/reader 严格完整性、identity/sequence、v3 历史字节保持、v4 writer 对旧 code 的版本化，以及 v3 writer 拒绝 v4-only event。未改动两个已有 Modified 测试文件。

## 验证

验证环境：Apple Swift 6.4.0，`swift-driver` 1.168.6，SwiftPM 编译目标 `arm64-apple-macosx27.0.0`，SDK 27.0；`xcrun swift-format --version` 输出 `main`。

| 命令 | 结果 |
|---|---|
| `xcrun swift-format lint --strict --configuration .swift-format Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalIngress.swift Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalV4WriterTests.swift` | 通过，exit 0 |
| `swift test` | 最新候选通过，1137 tests / 0 failures，exit 0。为绕开主机用户缓存目录权限和 SwiftPM 子进程 sandbox 限制，使用 `/private/tmp` 下独立 scratch/cache/config/security/module-cache 路径并带 `--disable-sandbox`。 |
| `git diff --check` | 通过，exit 0 |

最终完整构建输出一条未变更文件 `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift:1429` 的 optional interpolation warning；测试仍为 1137 tests / 0 failures。第一次未重定向缓存的运行因 SwiftPM 缓存目录权限失败，随后隔离至临时路径后完成。

## 边界与待办

- 仅验证 KeyboardCore host package。未运行 iOS Simulator、RimeBridgeTests、App/Keyboard xcodebuild、设备安装或人工复现；这些不属于本 Assignment 的 Exit Criteria。
- 未新增 Keyboard Extension call site，未启用真实 v4 producer emission，未改变用户输入行为，也未验证崩溃/切换键盘根因。
- 未 commit、push、创建 PR、merge、发布或写入真实 App Group。
- 首个实现候选曾无条件选择 v4 ingress，已在独立 exact-candidate review 前由 Executor 自审发现并 supersede。当前候选默认保持 v3，只有显式 v4 opt-in 会写 v4；这不等于启用任何生产 producer。Architecture 与 Quality 对当前 manifest 的独立结论均为 **Pass with conditions**，分别记录在 [Architecture review](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-architecture-implementation-review-2026-09-29.md) 与 [Quality review](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-quality-implementation-review-2026-09-29.md)。Product Approver decision remains pending。
- 下一步交给 Keyboard Experience Maintainer，供未来另行授权的 paired-build rollout Assignment 使用；本次不创建该 Assignment。父生命周期诊断仍 Active，根因仍未确定。
