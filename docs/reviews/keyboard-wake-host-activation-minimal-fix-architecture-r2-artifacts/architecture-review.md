# HOST-ACTIVATION-FIX-DESIGN-ARCHITECTURE — R2

**Verdict: Pass with conditions，限 Proposed 设计。** 本轮仅复审 S1/S2/S3 补充稿；R1 Partial 原结论不改，父 Completed 不重开。补充稿把 R1 的两个 D2 缺口补成明确状态/副作用合同，并保留五文件范围及测试边界。此结论不批准实施，也不证明系统通知投递或 runtime 效果。

冻结包 SHA-256 `1cc40e09defa9aad3f6a2df0141ccdbc3d3cd9c87775dcabcf04bf5b0069e0178` 匹配；branch `codex/keyboard-wake-v3-compatibility-gate`、HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a` 匹配；15/15 allowed targets 哈希匹配。

| Claim | 覆盖 | 独立判定 |
|---|---|---|
| S1：身份、幂等、首帧、事件顺序、ADR 0002 | Covered | supplement 第 7–26 行定义 MainActor generation/context、hidden/appearing/visible、pending 与重臂身份、通知/appearance 交错、window 未就绪等待 viewDidAppear、disappearance 失效和重复事件无副作用。first-frame 仅重臂；owner 已启动才走恢复。第 23 行已承诺不回放旧输入。与现有首帧 gate、ADR 0002 清理语义兼容。 |
| S2：canary 权限与 Core owner-start 协议 | Covered | 第 28–41 行在任何 owner-starting 调用前判权限，且不把 ready 当创建许可。Core 中 `visibilitySuspended` 只能来自正向 visibility teardown；`beginVisibilityResume()` 仅从此态返回 true 并转为 `canaryStarting`。随后才能调用通用 resume；该 resume 在 owner nil 时创建 owner，ready/`markCanaryReady` 是后续阶段。fence/failed 状态拒绝；`baselineRecoveryPermitted` 不由 host-active 消费。 |
| S3：五文件范围与测试能力 | Covered | supplement 第 43–49 行保留原五文件，明确同一 gate 源加入 appex 与 `KeyboardTests` Sources；测试只验证状态/action及调用计数，不冒称通知投递或 runtime 证据。既有 `project.pbxproj` 的跨目录 Sources 接线模式支持此方案。 |

## 条件与实施边界

1. 实施必须逐项保持 supplement 表格的状态和副作用。尤其 `beginVisibilityResume()==true` 是 canary owner-start 的前置许可；不得先调用 `resumeRimeAfterVisibilityChange()` 再检查状态，也不得把 `isOwnerReady` 当作创建许可。`ThreadAffineRimeSession.swift:252-287,566-606` 显示 coordinator 初始化会启动 owner、可见性 resume 在 owner nil 时也会启动 owner；因此 first-frame 的首次启动必须始终经现有 gate/配置入口，host-active 的重建须经补充表许可。
2. notification object/context 身份如在真实运行中不匹配，按补充稿停止并报告，不放宽过滤。后续独立授权的 runtime 验证仍需确认通知投递、候选/宿主结果和 owner/receipt；本 Architecture review 不作这些断言。
3. `KeyboardTests` 只承载 gate 状态模型；保持 UIKit/Core/RIME 解耦，并在 `project.pbxproj` 显式添加 gate 源到 KeyboardTests Sources。extension test bundle 的加载测试不能替代它，也不能验证控制器接线。

未发现 S1/S2/S3 仍缺少的必要设计输入或不可实现的五文件接线。**最小下一步**是由方案作者将此补充稿与原 Proposed 作为同一冻结候选交正式实施 Assignment 流程；Assignment、Human 实施授权和后续 runtime 验证仍各自独立。本轮只读，无仓库修改或 build/test/simulator/LLDB/network。R1 和父状态维持原样。
