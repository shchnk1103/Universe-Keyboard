# A2-4 增量 Architecture 复审

结论：**Uncovered**。本报告只裁定 A2-4 编译/诊断证据；不重审 A2-1/2/3，不扩大到通知投递、Maps、F4 或 Release。

冻结包 SHA-256：`aeb308daec65f3525172aa020f2436a3d7ead5f2439f6cbfa4f899c7f1544822`；11 个精确输入逐项 hash 均匹配。

| 检查 | 结果 | 依据 |
|---|---|---|
| 四个修改 Swift 文件的原始 `SwiftCompile` 记录 | Covered | `four-swift-actual-compile.json` 与 4 个原始日志；识别到 4 个 Swift 源文件。 |
| 三个编译 job 成功结束 | Uncovered | RimeBridge、App+Keyboard、Release 原始日志的 Build Succeeded 标记。 |
| 原 7 actor 基线可核 | Uncovered | 受限 diagnostics/compile artifact 与 root 审计；匹配到 actor 数组 []，7 actor 明确引用=False。 |
| 新 Swift warning/error 为 0，AppIntents 工具 warning 单列 | Covered | 四个原始日志；Swift warning=0、Swift error=0、AppIntents/tool warning=11。 |

本轮判定事实：
- 4 个源文件标识：KeyboardHostLifecycleRecoveryGate.swift, KeyboardHostLifecycleRecoveryGateTests.swift, KeyboardViewController+Bootstrap.swift, KeyboardViewController.swift。
- `KeyboardHostLifecycleRecoveryGate.swift`：A2-V-3-app-keyboard.log (4 record(s)), A2-V-4-release-build.log (1 record(s)), A2-V-5-keychain.log (2 record(s))
- `KeyboardHostLifecycleRecoveryGateTests.swift`：A2-V-3-app-keyboard.log (2 record(s))
- `KeyboardViewController+Bootstrap.swift`：A2-V-3-app-keyboard.log (2 record(s)), A2-V-4-release-build.log (1 record(s)), A2-V-5-keychain.log (2 record(s))
- `KeyboardViewController.swift`：A2-V-3-app-keyboard.log (2 record(s)), A2-V-4-release-build.log (1 record(s)), A2-V-5-keychain.log (2 record(s))
- 原始日志中发现 warning 记录 11 条，其中 AppIntents/tool warning 11 条；新 Swift warning/error 计数分别为 0/0。原始编译 job 成功标记=False。
- R2 原报告 A2-4 曾标为 Uncovered：True；本轮只依据本冻结包的原日志及 bounded artifacts 复核该项。

**未覆盖缺口：** 至少一个编译 job 缺少成功结束标记；受限证据未证明原 7 actor 基线。此结果不改变 R2 其他三项状态。

证据边界：未读取源码；未运行 build/test/simulator；未验证真实通知投递、Maps 行为或部署状态。
