# C7 Owner 空值 Debug 观测 — 本地实施切片

授权来源：Human 当前线程在候选栏并排独立入口、正常有候选隐藏、arm后停手2秒显示旧候选仍在、点击只冻结导出的最终方案之后说“可以按这个方案继续”（2026-10-02）。此阶段仅本地探针实现及隔离Core验证；不是恢复修复。原角色保持：Keyboard Experience Maintainer primary，KeyboardCore Maintainer secondary；root Current Codex Executor/唯一writer，Luna仅scratch Core实现助手。未来Architecture/Quality独立review沿原角色，需新exact packet/预算；本阶段不产生review verdict。

基线：selected paired-rollout-preflight工作树，codex/keyboard-wake-v3-compatibility-gate，84b9c19227330b0fe6ff391be001ee398010fd6a；完整520 dirty和2610非忽略文件已留hash基线。9源码/Core测试allowlist见entry。UI Playbook/Product/UI freeze例外仅本次明确编入 KEYBOARD_WAKE_OWNER_PROBE 的Debug诊断构建；Release/普通Debug没有按钮，无工程/配置修改。

产品合同：独立44pt诊断按钮在右侧原56pt展开按钮左邻，仅显示时减少候选列表可视宽度，展开按钮始终保留。候选栏高度和key metrics不变。未arm且有候选隐藏；arm后无活跃触摸并停手2秒显示，即使旧候选存在；记录独立于UI/Logger/journal暂停。观测点击arm单轮10min，取证点击freeze并通过纯Swift借用导出函数提供有限内存读取点；不提交/清空/切换/dismiss/owner恢复。未提供新的自动runtime recovery。

有限模型：固定128条、overflow/expiry不完整终态、默认关闭、一个实例单轮不rearm；run/process UUID、monotonic sequence/time、appearance/coordinator/同步attempt ordinal、stage、ownerPresent/receiptPresent、有限teardown outcome及已有epoch/revision。append内无编码/I/O/owner等待；Mutex短临界区，不宣称绝对无锁零开销。freeze锁内复制值后锁外编码，borrow期内Debug noinline出口，debugger只能有限memory read，不EvaluateExpression/全进程dump。Core owner字段观察沿现有MainActor调用合同，不改引擎或隔离、不unchecked Sendable。

阶段依赖修订仅C7-A：本地当前scopeACK和root writer/inputs先于编辑；Corehost测试+format/parse属于A。UIKit actual target tests、paired compile、独立精确candidate评审属于C7-B；安装/现场debugger出口/单次直接AppSwitcher复现属于C7-C，另授权且fresh exclusive Entry。未来依赖owner为Current Codex Environment Executor/对应review角色/Human。不以此阶段跳过最终UI target检查；本阶段UI未构建/未运行，禁止宣称可安装/验收。

不得改App reader、journal wire、engine/deploy/RimeBridge、工程、其他路径；不得使用旧30skip接受作为新阶段通过。代码变更前重新读新Entry/Core ACK；输入语义需要改变、并发/测试需要越scope、诊断捕获任何内容则停止。
