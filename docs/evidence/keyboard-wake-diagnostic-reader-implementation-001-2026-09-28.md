# KEYBOARD-WAKE-DIAGNOSTIC-READER-IMPLEMENTATION-001 — 本地实现证据

状态：本地命令结果为 **Executor-recorded**；独立 Quality 对当前候选 `c752ffe9…` 的 review 为 **Pass with conditions**。本记录不构成 Quality Gate、Product Gate、合并或 Release 结论。

## 候选身份

- 采集时间：2026-09-28 Asia/Shanghai。
- 基线 `HEAD`：`9eb83158e49218c1e8f75dbe7dd9e0390db81409`。
- Proposal 0.4 已接受的设计内容 SHA-256：`d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`。
- 五个范围内 Swift 文件的按文件 SHA-256 清单如下；对这些 `shasum -a 256` 输出再次求 SHA-256 得到当前候选摘要 `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`。

| 文件 | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` | `331f57ad6a55c6ceb041d30cf325a6a8bcd94b54dcf23553b22e67a99e90ce2b` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift` | `554f06386f845e938b25926c6f62f81f5e75b488765a1367ab7f45ca591e8442` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` | `c5a050217c6e02ba720d90e5a6298eadb7ab76f814c177be4049a4a5631402f0` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` | `9ce72314f26fc308e92c459ee51672873490b73aa86d29296dddd8320ddebfb8` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` | `5e34af66516746a04c2e3dd560a404240a90a427c8c14656252457bff25cf947` |

该摘要只覆盖本 Assignment 的五个 Swift 文件。共享 worktree 中其他 Extension/KOS 改动没有纳入或改写。

## 实现与覆盖范围

- 保留 v3 新建及写入；reader 可解码 Proposal 0.4 v4 类型。解码的 v4 event 不能由 v3 encoder 编码，也会在 writer 边界被拒绝。
- v4 raw-wire validator 对顶层、payload、field keys 和有限枚举值做 allowlist 验证；只记录有限、无内容的 rejection reason。
- `latest`、`beginPage`、`recentPreview`、`nextPage` 均携带 completeness。有效记录与被拒记录并存时仍返回有效记录并标记 incomplete；仅有被拒记录时根读路径不会返回“完整空日志”。`nextPage` 仅适用于带有效 cursor 的混合历史，并保留冻结查询的不完整状态。
- 回归矩阵对 unsupported schema/code、v3 标记的 v4-only code/payload（含 null payload key）、未知顶层/payload/field key、未知枚举值、缺失/错误 payload、错误配对及多个 wrapper，逐项走四类适用 reader API，并检查混合与 rejected-only 历史。隐私排除用例覆盖顶层 `documentContext` 与 `textProxyPayload.inputText`。
- 有效的历史 RIME Sync、Scheme Delivery、Runtime Route composite v4 records 通过四类 reader API；新增 Keyboard Lifecycle、RIME Resume 与 Text Proxy v4 types 有直接 decoder / wire validation 覆盖。
- Runtime Route 的 `elapsedMilliseconds` 在 wire 层沿用既有 model 的 `0...600_000` 边界；`-1` 与 `600_001` 作为 malformed payload 覆盖四类适用 reader API。
- 四个 public read API 的文档明确非正预算是调用方参数错误；对应空返回不读取日志，不代表日志为空，`nextPage` 也不会消费 cursor。
- 已知限制：Foundation `JSONSerialization` / `JSONDecoder` 当前路径不能报告同一 JSON object 中重复成员的原始出现次数。本实现不声称检测、拒绝或因重复成员而报告 incomplete；此限制已由 Architecture 在 Assignment Ready 前接受。
- raw-key allowlist 保证位于 `DiagnosticsJournalReader` 入口。直接对公开 `DiagnosticEvent` 调用 `JSONDecoder` 不能严格拒绝所有未知 raw keys；下游消费者必须使用 Journal reader 或为其他入口另建严格解码 Assignment。

## 本地验证

工具链：Apple Swift 6.4（`swift-driver 1.168.6`，compiler target triple `arm64-apple-macos27.0.0`），Xcode 27.0（`27A266a`）。完整测试日志中的 Testing Library 报告 target platform `arm64e-apple-macos14.0`；这是 host-side Swift Package test，不是 Simulator destination。

五个范围内 Swift 文件均通过以下格式化与严格 lint；随后 `git diff --check` 通过：

```sh
xcrun swift-format format --in-place --configuration .swift-format \
  Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift

xcrun swift-format lint --strict --configuration .swift-format \
  Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift

git diff --check
```

完整命令在隔离环境中为：

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/uk-wake-diagnostic-reader-module-cache swift test --package-path Packages/KeyboardCore --scratch-path /private/tmp/uk-wake-diagnostic-reader-scratch --cache-path /private/tmp/uk-wake-diagnostic-reader-cache --config-path /private/tmp/uk-wake-diagnostic-reader-config --security-path /private/tmp/uk-wake-diagnostic-reader-security --manifest-cache none --disable-dependency-cache --disable-build-manifest-caching --disable-sandbox --quiet
```

结果：**1132 tests，0 failures**（17.678 秒）。`--disable-sandbox` 仅绕过此受限执行环境中 SwiftPM 内部 `sandbox-exec` 无法启动的问题；该 package 使用本地 targets，无外部依赖 package 或 build plugin。完整输出：[keyboardcore-package-tests-2026-09-28.log](keyboard-wake-diagnostic-reader-implementation-001-tests-2026-09-28.log)，SHA-256 `b84559ca3e7ac98a23f9dd36224f2e3e4fca979dcb787dd357f20ea3b918f256`。

这是 host-side Swift Package 测试，没有 Simulator destination，因此不作任何 Simulator、App/Extension 运行、键盘唤醒复现或根因结论。没有修改 Main App、Keyboard Extension、RimeBridge、运行时行为或 v4 producer；当前静态 writer 仍为 v3。

## 后续交接

同一独立 Quality Reviewer 对当前 `c752ffe9…` 候选重算五文件摘要及测试日志摘要，确认均与本记录一致，并给出 **Pass with conditions**；此前 Runtime Route 数值边界与非正预算调用约定均确认处置。剩余 raw-key 入口责任与 duplicate-member parser limitation 的 owner/disposition 见 [`Quality review`](../reviews/keyboard-wake-diagnostic-reader-implementation-001-quality-review-2026-09-28.md)。本地验证与 review 均不构成 Quality Gate、Product Gate 或 Release；Assignment 已进入 **Reviewed**，未 Close。
