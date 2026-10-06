# v6 reader Stage A Entry

日期：2026-09-30 Asia/Shanghai。结论：Stage A scoped Entry satisfied；不是整个 paired rollout Ready/Exit 或 Gate。

[Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v6-reader-stage-a-authorization-2026-09-30.md) 登记本次Human授权与sequencing。HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`，branch `codex/keyboard-wake-v3-compatibility-gate`；worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`。231 dirty（10 tracked modified/221 untracked），porcelain-z SHA-256 `41cf5fba172c36fc254bda40f00f9b4d7291441501b1adcc9cd62bc83892e127`。已冻结2330既有文件hash与五文件/Assignment原字节到同名private/tmp决策目录；根Executor为唯一worktree writer，子代理仅写private/tmp草稿。

当前任务 `01a0f254-ec9a-7832-b022-f80e22d73fec` 接手；前驱任务 `01a0ce6f-2cab-7790-a362-358e801ebc63` 查询为idle，未发现另一个active仓库任务；这是时点ownership证据，不代表排除一切外部编辑。identity非授权漂移时停止。

Core scope ACK：`/root/core_stage_a` GPT6 Luna，绑定冻结packet SHA，确认四个Core文件足够，不需改Journal/Runtime/Ingress。App scope ACK：`/root/app_stage_a` GPT6 Luna，绑定同一packet，确认App测试query path且生产源无需改。两者是领域协作ACK，不替代独立Architecture/Quality评审，不Reassign永久领域owner。Executor ACK：根Codex任务确认exact input、边界、host环境执行及停止规则。Environment Executor本阶段仅host；Human Dependency本阶段无人工动作，未来Maps保持待精确候选重绑。独立评审责任继续归原角色，Stage B才新派；旧SHA ACK不重标为当前证据。

## Five-file input

- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` — `346efd59225cdf71fc61917fcb26bc72f3b1cf84aea19d873b3f238e791b492b`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift` — `965667328c2db1cba4c4f99e21a82ee13ae3890ff18bf510b9967c5396273534`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` — `7da854233e4454ccd44c587acca5cf8b4d4b89b15c726277748fa172da1e7c53`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` — `8760b930ff9f1045f8689f73c2dddb33bf199b86d7246cc6dd6e50feb2af1ba5`
- `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift` — `ad24cef7d5512b621a53724b3b1043b29a5b1863ef163aa8de0e25b6e2fa855c`

七个readonly dependencies全部匹配preparation-snapshot；包括Journal、Runtime、Ingress、App production consumer及三个Extension文件。生产 writer=5、marker off，v6仅原始JSON临时fixture。

Simulator窗口未预约，Stage A不需要且不执行Simulator；旧API/父patch原始字节仍未恢复，Stage C前置；不借历史摘要恢复实现。既有架构/产品合同保持，strict各版本allowlist，duplicate JSON members检测未实现。

Entry仅授权开始Stage A source work，后续exact候选manifest、host日志、App authored/not-run记录为Exit evidence，尚未生成。全局Assignment及parent保持Active。
