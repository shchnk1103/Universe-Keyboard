# R2 设计条件 → 实现位置

| 条件 | 位置 |
|---|---|
| MainActor generation/context/phase hidden-appearing-visible | `KeyboardHostLifecycleRecoveryGate` 状态字段与 `noteViewWillAppear` / `noteViewDidAppear` / `noteViewWillDisappear` |
| pending 单次消费 | `consumePendingAndRearm`；重复 active 因 pending/rearm 已消费返回 none |
| 通知对称 context 过滤 | `hostNotificationMatchesCurrentExtensionContext`；两通知同一匹配；缺失/foreign 不决策；不回退 UIApplication |
| 首帧未激活仅 rearm | `activatedAtSuspend == false` → `rearmFirstFrameGate`；`handleFirstFrameElapsed` 才 `completeFirstFrameActivation` |
| 已激活才共享 resume | `activatedAtSuspend == true` → `performSharedResume` |
| canary 许可在 owner 创建前 | controller 先 `preview*` 再 `resolveHostRecoveryCanaryPermission`，再 `handle*`；deny 则 `blockPending` |
| visibilitySuspended 仅 beginVisibilityResume()==true | `resolveHostRecoveryCanaryPermission(grantVisibilityResume:)` |
| fence/failed 不授 baseline | `.fenceIssued` / `.fencedUnavailable` / `.visibilityEnding` / `.baselineRecoveryPermitted` 拒绝 generic resume |
| 重复 active 不清新 composition | host-active 不调用 `cleanupTransientKeyboardState`；重复 active 无 resume |
| 真实 visibility 弃旧 composition | disappear/suspend 仍走既有 `abandonsComposition: true`；新 viewWillAppear 为新 generation |
| 不重放输入 | 共享 resume 只 `resumeRimeAfterVisibilityChange` + heartbeat/journal/selection |
| gate 无 UIKit/Core/I/O | 新 gate 文件仅 Swift/stdlib |
| 两 target Sources | Keyboard 同步组纳入 `Keyboard/Services/...`；pbx 明确加入 KeyboardTests Sources |
| 测试只证 gate | KeyboardHostLifecycleRecoveryGateTests 只计数 action |
