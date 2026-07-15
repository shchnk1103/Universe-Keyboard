# ADR 0017: App Notification And Toast Settings

## Status

Accepted; implementation active

## Context

RIME 同步原本在自己的 ViewModel 中保存“同步通知”布尔值，目录断开或重选会重置它；系统通知权限、RIME 类别和全局 Toast 也没有统一所有者。结果是自动同步、手动同步和前台反馈容易被用户理解为同一个功能，并可能出现 Toast 与系统横幅重复。

## Decision

- 包含 App 持有一个根级 `AppNotificationSettingsModel`，所有设置页面共享它；持久化由独立 store 管理，系统权限和发送由可注入 client/service 管理。
- 系统通知采用“总开关 + 类别开关”。V1 只有 RIME 云同步类别；RIME 页面和全局页面不复制状态。
- RIME 同步模型只上报语义事件，不读取通知开关或请求权限；统一服务在发送时检查总开关、类别和实时系统授权。
- 操作 Toast 是独立的 App 内反馈通道，默认开启。关闭会立即隐藏当前 Toast 并抑制全部全局操作 Toast，不改变详情页状态。
- 带有 Toast 对应元数据的前台通知，在 Toast 开启时只进入通知中心列表；Toast 关闭时使用横幅、列表和声音。未知或未来类别不能继承静音行为。
- 保留旧 RIME 通知键做兼容迁移；新增总开关和 Toast 键。迁移不得自动请求权限。
- 所有权只在主 App；Keyboard Extension 与输入热路径保持不变。

## Alternatives Considered

- **继续由各功能保存自己的通知开关**：实现简单，但会复制授权、总开关和前台策略，无法保证入口一致。
- **把 Toast 作为系统通知总开关的子项**：两者作用场景不同，用户可能希望关闭系统通知但保留 App 内进度，因此拒绝。
- **前台同时显示 Toast 和通知横幅**：信息重复且会重复播放声音，因此只保留通知中心记录。
- **应用启动时主动请求权限**：缺少用户上下文且违背明确选择原则，因此拒绝。

## Consequences

- 新通知类别必须接入统一 store、设置页面、隐私文案和测试，而不能新增散落布尔值。
- 系统权限和 App 总开关是两层状态；系统重新授权后，用户仍需主动打开 App 总开关。
- 本地通知可在后台同步执行后展示，但是否获得后台执行机会仍由 iOS 决定。

## Related Documents

- [`APP_NOTIFICATIONS.md`](../../APP_NOTIFICATIONS.md)
- [`RIME_SYNC.md`](../../RIME_SYNC.md)
- [ADR 0014](0014-rime-standard-sync-automatic-scheduling.md)
