# A-C4 Architecture 独立评审（round 1）

## 结论

**Architecture：Full（A1–A6 静态合同覆盖；未发现 Architecture blocker）。** 结论只适用于冻结的源候选和以下只读分析，不代表构建、测试、已安装 App/appex 配对、运行时发射、质量 Gate、Maps 复现、Release 或 Assignment/parent 关闭。

## 身份与边界

- 冻结 packet：`architecture-packet.md`，SHA-256 `18473e76335c59bc3c0109e3dd1deada015148a433dc6d76aa0a897cecd17`。
- Candidate manifest：`candidate-manifest.json`，SHA-256 `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9`。
- Root / branch / HEAD：`/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；`codex/keyboard-wake-v3-compatibility-gate`；`84b9c19227330b0fe6ff391be001ee398010fd6a`。
- 34 个 `review_target_files` 与 568 个 `source_and_build_inputs` 的 SHA-256 均与 manifest 一致；manifest `installed_proof=false`。
- 当前 owning Assignment 文件身份 SHA-256 `b597181c203d99eb9a59fcb8a498ddec45a948538af31459d088b0e2b9ae31c8`。其记录阶段仍是 C3；这是 Assignment 阶段记录，不改变冻结 C4 source identity。当前只读评审授权来自本轮冻结 packet 及 Coordinator 转交的 Human authorization。
- 评审者未参与候选实现。没有改源码，没有构建、测试、Simulator 或 Git 写操作；只写 packet 指定的两个 scratch 输出。

## A1–A6 覆盖

| 标准 | 结论 | 静态证据与边界 |
|---|---|---|
| A1 单一 writer version；兼容历史字节 | Covered | `DiagnosticEvent` 保持旧 writer/default-v5 路径与 v3/v4/v5 读支持；writer 对每条新事件统一按实例 `writerVersion` 归一化。生产构造器在 C3 五个 caller 中显式选 v6，测试默认仍覆盖 v5；v6 同时支持既有事件族与 `typo_recall`，marker 不能经一般旧事件构造器混入。Writer 在写前用 wire validator 复核编码记录。代码定位：`Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift`、`DiagnosticsJournal.swift`（writer 归一化和写前验证）、五个 C3 caller；C3 receipt 明确五个 production caller 均绑定 v6、Core public defaults 保留 v5。此次没有独立重跑历史字节测试。 |
| A2 v6 strict reader 与 App fallback | Covered | `DiagnosticEventWireValidator` 先检查 raw JSON key/version/code/payload 配对，再由 `DiagnosticsJournal.decodeEvent` 解析；marker payload 使用闭合键集及有限 enum，RIME failed/failure 一致性受检。App reader 将拒绝原因与分页状态合并为 incomplete；只有成功、完整的空 journal 才允许 legacy 回退，journal unavailable、拒绝行和有界/分页不完整都会保留 v1 视图并显示部分读取提示。duplicate JSON object members 无法由当前 `JSONSerialization` 暴露；validator 注释与 Assignment 明确写出此解析器限制，Stage B receipt 将其登记为未实现检测的限制，不声称已覆盖。 |
| A3 可观测生命周期 / RIME / proxy 边界 | Covered | Extension producer 限定四个已观测 lifecycle phase；不伪造 `hostDidBecomeActive`。RIME 只在 resume 调用前记 `started`；不从后续未观测状态推断 session/schema/ready/success/failure。proxy 只对现有 `insertText`、`setMarkedText`、`unmarkText` 调用记录 entered/returned；payload 为闭合操作/phase，不把 returned 描述为宿主接受结果。`UITextDocumentProxyAdapter.swift:144–180` 可见调用顺序；`KeyboardViewController+Bootstrap.swift:830–835` 记录真实 host resign 边界。 |
| A4 gate、热路径与隐私/所有权 | Covered | producer 仅在现有 Debug high-fidelity 内存 gate、有效 expiry 和既有类别门控下尝试提交；Release context disabled。proxy 文本仍只传给既有 UIKit 调用，不进入 marker；不加入文本、长度、hash、host/document/schema/path/url/free-form error 或新 action ID。marker 经既有有界异步 ingress，满队列/暂停可丢弃；事件记录只表示提交尝试，不证明持久化。Main App 仍拥有 journal root、retention/maintenance 与日志 clear，Extension 只通过 writer/runtime/ingress 追加；未发现同步热路径 I/O 或部署所有权转移。此项是静态代码合同结论，不是性能测量。 |
| A5 target/default/dependency 一致性 | Covered | target manifest 与 build input hashes 一致；`project.pbxproj` 为 `UITextDocumentProxyAdapter.swift` 增加 `KeyboardTests` 源成员，Core/App 文件仍落在其既有同步源码组。全体 production writer caller 在 C3 receipt 清点为三处 Runtime 加两处 Main-App Writer constructor，均显式传 `.v6`；Core API 默认仍 `.v5`。candidate manifest 明确没有 installed proof，因此这里只确认静态绑定，不声称 App/appex 是同一构建或实际安装。 |
| A6 Entry/authority/future dependencies | Covered | 冻结 packet 限定本轮 exact-candidate 静态 review；C3 receipt/Assignment 把 full paired CI、独立 exact-candidate reviews、编译 App+appex 身份、fresh Simulator reservation、单独 promotion/install/Maps Entry 作为后续依赖。Assignment 明示 parent Active、无 Gate/Release/关闭，Stage B 的 skip 接受仅当前 Stage B；v5 skip 接受仅 v5。当前记录中的 30 个 Stage B skips 未被视为 passed，也没有外推到 C4/Stage C/Release。 |

## Findings

无需要阻断本次静态 Architecture 合同的发现。`duplicate JSON object members` 是已书面登记的 parser 限制，不是检测已实现的声称；其处理仍需未来由产品/质量权限决定，不在本轮擅自扩展 parser 或产品合同。

## 评审材料

所有允许的附加文档 SHA-256、候选输入核验、工具预算/检查点、路径边界偏差及结束原因见同目录 `architecture-usage.json`。
