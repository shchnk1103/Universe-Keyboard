# KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001 — Quality Implementation Review

状态：**PASS WITH CONDITIONS — exact-candidate handoff review**。本 receipt 只审查当前十文件 KeyboardCore 实现候选的身份、Assignment Exit Criteria、隐私/边界和已记录验证；不表示全局 Quality Gate、Product Gate、Release、生产 v4 发射、配对构建或父 Assignment 关闭。

本轮以 corrected candidate 为唯一对象。早先无条件选择 v4 ingress 的候选 `647894b0…` 已被 supersede，本 review 不复用其结论。

## 1. 精确身份绑定

| 对象 | SHA-256 / identity | 核对结果 |
|---|---|---|
| Worktree | `/Users/doubleshy0n/.codex/worktrees/runtime-record-api-impl/Universe Keyboard`；base `HEAD` `9eb83158e49218c1e8f75dbe7dd9e0390db81409` | 与 implementation evidence 一致 |
| Runtime Record API Assignment | `f0cb705adee5201a739e140a7950bfbd26622ae634558674f754341ba857385a` | 当前文件 bytes 一致；Lifecycle `Completed` |
| ADR 0036 | `f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c` | `Accepted (Conditional)` |
| ADR acceptance decision | `3926918c0ae5f7aa0704f1696d75bbd32dfc1b32fd0895225bc49bcd9dc5035d` | 当前文件 bytes 一致 |
| Implementation authorization | `7f2e472552efd7c7016770f6182aafcf4c54b834222a441d62245503952643e7` | 单独授权；未扩展到发布或配对 rollout |
| Fresh baseline receipt | `58fc930762e8adac11bdc78afab1c2ff63bc5038f9f013114b44732eb7cc12b0` | 受管 worktree 与保护文件边界已记录 |
| Writer-isolation recheck | `4981748919c417752daa43c71ada9dacaec71b4913f757a07f5962c33486d759` | 支持实现开始前的 managed-worktree ownership 窗口；不作整机未来独占保证 |
| Canonical ten-file manifest | `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c` | 完整 JSON bytes、排序与 LF 结尾均核对一致 |
| Implementation evidence | `fb492c41bfd047eb766b7f1dfbfafaa28a71c4851eefd63809bc9c93d1eb6c0f` | 当前候选摘要和验证记录一致 |
| Parent Assignment | `ccb250d86ae5ee73044d9a8729afa925c4062c70dfb587f773c65caba099431c` | Parent 仍 `Active`；child 已记录 `Completed` |
| `docs/ACTIVE_WORK.md` | `46be08402d851bcc6beb26b8a51dc6788fcc7c32f6042861f179790e90e0a2c6` | corrected candidate 与 child `Completed` 镜像一致 |

Canonical JSON 的十行按相对路径排序，采用 compact UTF-8 JSON、排序 keys、末尾 LF。逐文件 current SHA 均与 JSON 中的 `currentSHA256` 相等：

| 文件 | 状态 | 当前 SHA-256 |
|---|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` | Modified | `3cac989b191becb73f8f943c963a8745c98322f4e0bcc06bf975671257727700` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift` | Untracked；沿用 Reader 候选 | `554f06386f845e938b25926c6f62f81f5e75b488765a1367ab7f45ca591e8442` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` | Modified | `b866691b1ab329836b7908000b8abeab6b33d2e1cf80d6c9e6133ea788e49bf4` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalIngress.swift` | Modified | `8997a15734a1d2bf7e2c8f7e5304b32b19454979a44aaaecdbe8d505e4ffd556` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift` | Modified | `95f6b93718d12fd19fae90545e6f57e21c055d1b0e5fbfa5d0c8b2647f20089d` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` | Modified；基线保护文件，未由本候选编辑 | `9ce72314f26fc308e92c459ee51672873490b73aa86d29296dddd8320ddebfb8` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalIngressTests.swift` | Clean | `d2bcf72ea11831becbdc282975aaab66ec1b19df0fea7620f7d91d68aa2c49d6` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalRuntimeTests.swift` | Clean | `ce92f25fd0d0666582217c78cd233615e18c78c65f3036fe78d77ccdf66459f0` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` | Modified；基线保护文件，未由本候选编辑 | `5e34af66516746a04c2e3dd560a404240a90a427c8c14656252457bff25cf947` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalV4WriterTests.swift` | Untracked；本 Assignment 新增 | `ea9c139317bbec128d6dce187e4cf886d3865db038a18c85796a02189d9a3525` |

## 2. Entry Criteria、授权和边界

- Assignment 已记录 Domain Owner、Executor、Architecture Reviewer、Quality Reviewer 和 Product Approver；ADR 0036 已由 Human Architecture Authority + Product Lead **Accepted (Conditional)**。
- Implementation authorization 单独允许 `Packages/KeyboardCore` 的三种 typed v4 submission、最小 writer-version/encoding/append 支持和隔离临时目录测试；没有授权 Extension call site、生产 v4、Simulator/device、commit/push/PR/merge、Gate、Release 或 parent closure。
- Fresh baseline 与 writer-isolation receipt 保护既有 dirty `DiagnosticEventTests.swift` / `DiagnosticsJournalTests.swift`；当前十文件 manifest 中这两个文件 SHA 与 baseline 一致，独立新增覆盖位于 `DiagnosticsJournalV4WriterTests.swift`。
- `DiagnosticsJournalIngress.swift` 的改动仅用于传递显式 `writerVersion`，默认值仍为 v3；源码中的生产 Runtime/Ingress call site 没有传入 `.v4`，`.v4` 仅出现在隔离测试和版本约束代码中。该连接点属于让显式 opt-in 可落盘所需的最小 ingress wiring，没有观察到新的生产 producer。

## 3. Exit Criteria 审查

### 3.1 v3 默认和显式 v4 opt-in

**通过。** `DiagnosticsJournalRuntime`、`DiagnosticsJournalIngress`、`DiagnosticsJournalWriter` 默认使用 v3。只有显式传入 `.v4` 的 Runtime 才接受三个 typed API；默认 Runtime 的测试验证三个 typed submission 返回 false，同时既有 `presentationAppeared` 仍以 schema v3 写入。显式 v4 测试验证三个 typed API 加既有 code 通过 bounded ingress 落盘为 schema v4。

### 3.2 Envelope、身份、序列和隐私

**通过。** 独立测试验证 code、level/category、appearance/action identity、单一 process identity、连续 local sequence、schemaVersion 4、空 `fields`、允许的 envelope keys 和 Reader completeness。payload 只使用受控 enum、UUID 与数值字段；没有文本、候选内容、host text、自由字符串或同步持久化。

### 3.3 phase/failure pairing 和 writer invariant

**通过。** 正向测试包含合法非 failed resume 和 `failed + sessionCreationFailed`；负向测试拒绝非 failed phase 携带 failure，并拒绝非 Extension origin。现有 protected Reader/`DiagnosticEvent` tests 继续覆盖 v4 typed decoding、v3 label、invalid pairing、privacy key 和 read-only v4 encoding。独立 writer tests 还验证：

- v4 writer 对既有 code 生成 v4，同时 retained v3 bytes 保持原样；
- 默认/v3 writer 生成 v3；
- v3 writer 在写入前拒绝 v4-only event，不产生 journal record。

### 3.4 bounded hot path

**通过（代码审查）。** Runtime 热路径只构造有限 typed value 并调用 `DiagnosticsJournalIngress.record`；JSON 编码、App Group/root 访问、lock-bound append 和文件 I/O 留在 utility flush/writer actor。没有新增 preferences 访问、同步等待或文本捕获。该结论是静态边界审查，不是 latency benchmark 或 Simulator 运行结论。

### 3.5 验证和目标

**通过，结果为 Executor-recorded。** 当前 implementation evidence 记录：

- strict `swift-format lint --strict --configuration .swift-format`：四个候选生产 Swift 文件和新增独立测试文件通过；沿用的 Reader validator 与两份 protected dirty tests 未被本候选修改；
- KeyboardCore host package 全量 suite：**1137 tests / 0 failures**，使用独立 `/private/tmp` SwiftPM/cache/module-cache 路径并带 `--disable-sandbox`；
- `git diff --check`：通过。

未重跑测试、格式检查或构建；本 review 核对的是上述精确候选和已记录结果。最终输出有一条未变更文件 `T9PinyinPathTests.swift:1429` 的 optional interpolation warning；它不改变 1137/0 结果，但后续若变更该文件应单独处理。

## 4. 非阻塞条件和剩余覆盖

1. 本候选满足 Assignment 的最小覆盖，但没有穷举所有 lifecycle phase、所有 text-proxy operation/phase、所有 RIME failure enum、queue-full/backpressure、writer I/O failure 和 lifecycle suspend race 的新组合。它们属于后续 paired-build/运行时验证覆盖，不构成当前 KeyboardCore candidate 的 P0/P1 blocker。
2. `DiagnosticEventWireValidator` 保留 Reader 候选已记录的 JSON parser 对重复 object-key occurrences 的限制；Reader 路径先做 raw-key validation，再进行 `Codable` decode。未来 paired-build 必须继续绑定 validator-first、unknown/incomplete/fallback 语义；本 review 不把该 Reader residual 升格为当前 writer Gate。
3. 当前 writer isolation receipt 只证明实现开始前受管 worktree 的 ownership 观察窗口，不证明整机未来不会出现新的写入者。后续若 source/test identity、ownership、ADR、Assignment 或 explicit-v4 boundary 漂移，必须重新冻结并 rebind。
4. `swift test` 的 evidence 表以 `swift test` 简写记录，但结果绑定的是 `Packages/KeyboardCore` host package；不要将 1137/0 延伸为 iOS Simulator、App/Keyboard、RimeBridge、设备或生产 v4 emission 证据。

## 5. Disposition

**Quality disposition：PASS WITH CONDITIONS。** 当前 exact candidate 没有发现阻塞 Assignment handoff 的 P0/P1 质量问题，可以交 Architecture/Quality 后续生命周期审阅；上述条件必须随候选身份和边界一并保留。该 disposition 只针对十文件 KeyboardCore implementation candidate，不是全局 Quality Gate、Product Gate、Release、生产 v4 enablement、paired-build readiness 或 parent closure。
