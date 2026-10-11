# 测试 authored / not-run

文件：`KeyboardTests/KeyboardHostLifecycleRecoveryGateTests.swift`

覆盖（gate 真实状态/action 与执行计数，不证明通知/控制器/runtime）：

- visible resign→active 恰一次 resume
- 重复 active/resign 幂等
- appear/active 两种顺序与已完成 pending 不二次消费
- missing/foreign context 不改状态
- hidden / no-window / 预创建不 resume
- 首帧取消后 rearm 一次且无即时 owner
- late tick 在 disappear 后不激活
- first-frame 到期消费 pending 且仅一次
- canary 否决表（fence/ending/unavailable/starting/active/baselineRecovery/visibilitySuspended false）
- visibilitySuspended granted 一次 resume
- fence 阻止 rearm 与 first-frame
- canaryStarting 允许原始 first-frame、拒绝 host-active resume
- 新展示使旧 pending 失效
- host-active 先于 window，由可见窗口接管
- 许可在消费 pending 之前判定
- 重复 active 不再次 resume（不会清新 composition）

**未执行：** 任何 XCTest、xcodebuild、swift test、swiftc、simctl。原因：F1 授权明确禁止运行测试/编译器。F2 另授权。
