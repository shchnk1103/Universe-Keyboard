# Architecture Implementation Review: KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001

## Disposition

**ACKNOWLEDGED — Pass with conditions。**

这是 Architecture & Knowledge Steward 对当前实现候选的独立、只读 Architecture review。当前候选满足 ADR 0036 / Proposal 0.4 的 writer-version、typed payload、历史兼容和 bounded ingress 合同；未发现阻塞当前限定实现范围的 Architecture blocker。

本 disposition 不等于 Human Architecture Authority 对 ADR 0036 的 formal acceptance，也不等于 Quality review、Product/Gate、Release、paired-build rollout 或父 Assignment closure。

## Exact candidate identity

| 对象 | SHA-256 / 身份 |
|---|---|
| Runtime Record API Assignment | `f0cb705adee5201a739e140a7950bfbd26622ae634558674f754341ba857385a` |
| Parent Assignment | `ccb250d86ae5ee73044d9a8729afa925c4062c70dfb587f773c65caba099431c` |
| `docs/ACTIVE_WORK.md` | `46be08402d851bcc6beb26b8a51dc6788fcc7c32f6042861f179790e90e0a2c6` |
| Implementation evidence | `fb492c41bfd047eb766b7f1dfbfafaa28a71c4851eefd63809bc9c93d1eb6c0f` |
| Canonical ten-file source/test manifest | `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c` |
| ADR 0036 | `f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c` |
| ADR 0036 acceptance decision | `3926918c0ae5f7aa0704f1696d75bbd32dfc1b32fd0895225bc49bcd9dc5035d` |
| Proposal 0.4 | `e501a4075c24a79de560e7381ae361708c1a085250470e69840e23c930b53c06` |
| Runtime implementation authorization | `7f2e472552efd7c7016770f6182aafcf4c54b834222a441d62245503952643e7` |
| Product writer-scope decision | `1ee751d4d87396ae5fad13e669b95daa3c46f1db648783fc99fe6f2c137ae206` |

Canonical manifest 核验为当前文件完整 bytes 的 SHA-256；其中关键实现文件为：

| 文件 | 当前 SHA-256 | 复核边界 |
|---|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` | `3cac989b191becb73f8f943c963a8745c98322f4e0bcc06bf975671257727700` | v4 payload、构造/解码配对、writer normalization |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` | `b866691b1ab329836b7908000b8abeab6b33d2e1cf80d6c9e6133ea788e49bf4` | writer version 与 append 边界；既有 Reader 改动按基线保护 |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalIngress.swift` | `8997a15734a1d2bf7e2c8f7e5304b32b19454979a44aaaecdbe8d505e4ffd556` | 默认 v3 与显式 writer-version 传递 |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift` | `95f6b93718d12fd19fae90545e6f57e21c055d1b0e5fbfa5d0c8b2647f20089d` | typed API、fail-closed、热路径提交 |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift` | `554f06386f845e938b25926c6f62f81f5e75b488765a1367ab7f45ca591e8442` | 沿用 Reader 候选的 v3/v4 raw-key/payload 校验 |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalV4WriterTests.swift` | `ea9c139317bbec128d6dce187e4cf886d3865db038a18c85796a02189d9a3525` | 当前 Assignment 的隔离 focused tests |

`DiagnosticEventTests.swift` (`9ce72314f26fc308e92c459ee51672873490b73aa86d29296dddd8320ddebfb8`) 与 `DiagnosticsJournalTests.swift` (`5e34af66516746a04c2e3dd560a404240a90a427c8c14656252457bff25cf947`) 在 manifest 中仍是受保护的既有 dirty 输入；本 review 不把它们的改动归因于本 Assignment。

## Architecture findings

### 1. ADR 0036 / Proposal 0.4 合同保持完整

- v3 writer 新写事件使用 schema 3；v4 writer 将该 build 新写的事件（包括既有 code）规范化为 schema 4。
- 已持久化的 v3 bytes 不被原地改写；v3 writer 在 append 前拒绝 v4-only code/payload。
- v4-only 三个 typed event family 与 payload 保持闭合枚举、固定 code/category/level、空 `fields` 和 content-free 边界。
- `RimeResumePayload` 的 `phase == failed` 与 `failure != nil` 配对在 API、构造/解码和 raw validator 层均为 fail-closed 约束。

对应实现位置包括 `DiagnosticEvent.swift:901-970, 1013-1074` 与 `DiagnosticsJournal.swift:284-345`。

### 2. Runtime / Ingress 默认 v3，v4 是显式 opt-in

- `DiagnosticsJournalIngress` 的 `writerVersion` 默认 `.v3`，并只把构造时的版本传给懒创建的 writer（`DiagnosticsJournalIngress.swift:41-59, 159-169`）。
- `DiagnosticsJournalRuntime` 同样默认 `.v3`，health event、通用 event 和 typed event 都使用该实例绑定的版本（`DiagnosticsJournalRuntime.swift:27-67, 226-260`）。
- 三个 typed API 仅在 `origin == .keyboardExtension && writerVersion == .v4` 时接收；RIME 还要求 payload 配对有效；非 v4 或非 Extension 均返回 `false`，不会进入 ingress（`DiagnosticsJournalRuntime.swift:142-199`）。
- 当前生产 `KeyboardViewController` 只构造默认 Runtime，没有传入 `.v4`（`Keyboard/Controllers/KeyboardViewController.swift:55-66`）。对 Swift 生产源码检索未发现 `.v4` writer 配置调用点；显式 `.v4` 只出现在隔离测试中。

因此，现有 Extension 的 `presentationAppeared`、health 和其它通用事件仍从默认 v3 路径写入；本候选没有打开生产 v4 emission，也没有加入 Extension typed call site。

### 3. Writer compatibility 与历史边界符合合同

- `DiagnosticsJournalWriter` 默认 `.v3`，通过 `canBeWritten(by:)` 在编码前阻止 v3 writer 接收 v4-only event。
- v4 writer 对可写旧 event 执行 writer-owned normalization，将新写 bytes 标为 v4；已存在的 v3 segment/bytes 由 append 过程保留。
- `DiagnosticEventWireValidator` 按 schema 分流：v3 拒绝 v4-only code/payload，v4 检查 envelope allowlist、必需 key、enum、payload wrapper、typed envelope 和 failure pairing。重复 JSON member 的 parser 限制已在其所属 Reader/Assignment 文档中明确，不在本 review 中扩大为未有证据的能力声明。

这满足 ADR 0036 要求的 v3/v4 writer invariant；Reader 的完整 Product/Main App fallback 行为仍属于独立 Assignment，本 receipt 不替代其 review。

### 4. Hot-path 与范围边界保持

- Runtime 只构造有限 value event 并提交到既有 bounded asynchronous ingress；JSON 编码、文件/App Group 访问和 append 保持在 utility writer/actor 路径。
- 没有加入自由文本、输入内容、schema 名称、路径或错误文本；typed methods 只接受 reviewed enum/value payload 和已有 identity 参数。
- 本候选未加入 RimeBridge、Keyboard UI 行为修复、Simulator/device、安装、手动复现、Main App query/fallback、Extension v4 emission 或 paired rollout。

## Conditions for this disposition

1. **保持显式 opt-in 边界。** 后续改动必须继续保持 Runtime/Ingress 默认 v3；任何生产 `.v4` 配置、Extension typed call site 或 paired-build emission 都必须进入另行授权的 successor Assignment，并绑定同一 Main App + Keyboard Extension build。
2. **保留 writer/reader compatibility gate。** v4 生产 rollout 仍须有逐记录版本校验、strict code/payload/raw-key handling、controlled incomplete/unsupported status 和 legacy-fallback suppression 的同候选证据；当前 Runtime review 不宣称该 Gate 已通过。
3. **保持精确候选身份。** 若修改 manifest 中任一生产/测试文件，必须重新冻结 canonical manifest，并重新进行 Architecture/Quality exact-candidate review；受保护的既有 dirty 测试不能被混入或覆盖。
4. **完成独立 Quality review。** 本 receipt 只提供 Architecture disposition；Assignment 的 Completed 写回、Quality acceptance、Product/Gate/Release 和父任务生命周期仍按各自权限与证据处理。

## Validation evidence and limitations

- 已独立核对上述文档、manifest 和关键源/测试 SHA；本 review 期间未修改源码、测试、Assignment、`ACTIVE_WORK.md` 或 implementation evidence。
- Executor evidence `fb492c…` 记录 Swift 6.4 环境、严格 swift-format 通过、`swift test --package-path Packages/KeyboardCore` 为 1137 tests / 0 failures，以及 `git diff --check` 通过。本 review 未重新运行测试、构建、Simulator、设备安装或运行时复现；这些记录被作为候选证据读取，不被重述为本 review 的独立测试执行。

## Non-claims

本记录不代表 ADR 0036 的 formal acceptance，不代表实现已通过 Quality/Gate，不代表生产 v4 已启用，不代表 Extension paired rollout、行为修复、根因确定、Release 或父 Assignment closure。
