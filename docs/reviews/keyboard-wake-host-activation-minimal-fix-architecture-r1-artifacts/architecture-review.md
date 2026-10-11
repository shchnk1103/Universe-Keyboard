# HOST-ACTIVATION-FIX-DESIGN-ARCHITECTURE — R1

**Verdict: Partial（Proposed 设计审查，不是实施批准）。** D1 是合理的通知修复假设；D2 缺可执行状态合同，且 canary 恢复路径与当前通用 resume 调用顺序存在未解决冲突；D3 五文件范围和 `KeyboardTests` 状态模型路线合理，但跨 target 源码接线必须明确。

冻结包 SHA-256 `0ac5cd80d70cf8649a78d1c1434b9e101c0b30bb5004360c9ddbe7757bef05b8` 匹配。branch `codex/keyboard-wake-v3-compatibility-gate`、HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a` 均匹配包内身份；13/13 allowed targets 哈希匹配。

| Claim | Coverage | 结论 |
|---|---|---|
| D1 通知对称/owner 边界 | Covered as Proposed hypothesis | `KeyboardViewController+Bootstrap.swift:814-835` 现有 resign 通知挂起 runtime；新增 host-active 对称观察与已证局部 owner 边界相符。平台语义不证明 Maps 故障窗口投递或本次因果，方案对此保留 non-claim。 |
| D2 可见性、pending 幂等、首帧、ADR 0002、canary fence | Partial | ADR 0002 清楚要求 visibility 放弃 composition，不恢复旧输入；方案也列出隐藏实例、pending 一次、首帧重 arm 等目标。但 presentation/通知交错状态及 owner resume 前置合同不完整；canary 路径有静态冲突。 |
| D3 五文件/测试 target 能力 | Covered with implementation constraints | `KeyboardTests` 是独立 XCTest target；可测 UIKit/Core 无关 gate 模型。跨目录 gate 源必须显式加入 KeyboardTests Sources。此测试不证明 appex 控制器接线、通知投递或 runtime 效果。 |

## 关键 findings

1. **Blocker — canary fence 未守在通用 resume 调用前。** `KeyboardViewController.swift:412-439` 先运行 `beginVisibilityResume()`，随后无条件调用 `controller.resumeRimeAfterVisibilityChange()`，之后才判断 canary readiness。`ThreadAffineRimeSession.swift:566-579` 在 owner 为空时会 `startOwner()`。共享 active 入口必须在调用前证明恢复状态允许；fenced、kill、failed teardown 或未获 positive terminal 时不得创建 owner/授予 baseline。该静态路径暴露设计缺口，不表示已观察到运行时越界。
2. **Major — gate 转移合同不足。** `viewWillAppear`、`viewDidAppear`、`viewWillDisappear` 与 host active 的先后关系、当前 presentation 身份、pending 失效/单次消费，以及“first-frame 未激活只重 arm”与“已激活 owner 恢复”的分支尚未形成完整事件—状态—副作用表。不得用历史 `hasViewAppeared` 充当当前可见性。参照 `KeyboardViewController.swift:275-289,381-515`、`KeyboardViewController+Bootstrap.swift:302-353`。
3. **Constraint — XCTest 能力仅限 gate 模型。** `project.pbxproj:250-272,322-344,528-542` 显示 appex 和 `KeyboardTests` 是分开的同步组/target，KeyboardTests Sources 有显式跨目录源。将同一无 UIKit/Core gate 源显式编入两个 target；用 `KeyboardTests` 测状态表。`CandidatePrefetchUIContractTests.swift:5-11` 只证 extension test bundle 可加载，不能测试 appex symbols。

**最小下一步：** 在 Proposed 文档补齐 presentation generation、matching context、通知/视图事件交错、pending 单次消费、first-frame 分支和 canary allowed/denied 的转移表及测试映射，再作独立设计复审。之后仍须单独冻结正式实施 Assignment、精确路径/dirty ownership/依赖/预算，并取得实施授权。本轮不声称通知必达、修复有效或可实施。

只读完成：未修改仓库，未运行 build/test/simulator/LLDB/network；不复审父 Completed 或旧 Quality 交付。
