# ADR 0019: App Notification And Toast Settings

## Status

Accepted; implementation active

> **Identity note (DOC-HYGIENE-001):** This decision was previously published under a colliding ADR number `0017`. Under Knowledge OS hygiene it was renumbered to `0019`. ADR `0017` remains the Ephemeral Post-Commit Continuation decision.

## Context

RIME 同步原本在自己的 ViewModel 中保存“同步通知”布尔值，目录断开或重选会重置它；系统通知权限、RIME 类别和全局 Toast 也没有统一所有者。结果是自动同步、手动同步和前台反馈容易被用户理解为同一个功能，并可能出现 Toast 与系统横幅重复。

## Decision

- 包含 App 持有一个根级 `AppNotificationSettingsModel`，所有设置页面共享它；持久化由独立 store 管理，系统权限和发送由可注入 client/service 管理。
- 系统通知采用“总开关 + 类别开关 + 类别内通知子项”。V1 只有 RIME 云同步类别，包含“RIME 标准同步”和“Universe 设置同步”两个通知子项；RIME 页面和全局页面复用同一状态与控件。
- 通知子项只筛选提醒，不控制同步行为。两个子项都开启时，一次完整同步合并通知；只开启一项时，通知必须跟随该部分的真实阶段，并区分已完成、失败和尚未执行。
- RIME 同步模型只上报语义事件，不读取通知开关或请求权限；统一服务在发送时检查总开关、类别和实时系统授权。
- 操作 Toast 是独立的 App 内反馈通道，默认开启。关闭会立即隐藏当前 Toast 并抑制全部全局操作 Toast，不改变详情页状态。
- 带有 Toast 对应元数据的前台通知，在 Toast 开启时只进入通知中心列表；Toast 关闭时使用横幅、列表和声音。未知或未来类别不能继承静音行为。
- 保留旧 RIME 通知键做兼容迁移；新增总开关、两个 RIME 通知子项和 Toast 键。缺失的通知子项继承旧类别状态，迁移不得自动请求权限或改变自动同步设置。
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

## Risks

- iOS 系统权限、专注模式和后台调度都可能延迟或隐藏通知；App 只能准确请求和记录结果，不能承诺通知一定以横幅形式即时出现。
- 一次同步包含多个阶段；若事件没有携带已完成、当前失败和尚未执行的范围，分项通知可能错误暗示全部成功或把另一阶段的失败归因给用户订阅的部分。
- 新类别若绕过统一模型或自行保存开关，会重新引入两个设置入口状态分叉、静默请求权限或前台重复反馈。

## Follow-up Work

- 在物理 iPhone 上验证首次授权、拒绝后跳转系统设置、前台通知中心记录、后台横幅/声音，以及两种 RIME 通知子项的组合。
- 新增通知类别时，沿用统一父子状态、隐私文案、前台展示策略和注入式发送测试，不在 Keyboard Extension 中增加通知工作。
- 若未来引入远程推送、角标、通知操作、关键通知或时效性通知，必须重新进行 Product、Privacy、Architecture 和 Release 审查。

## Related Documents

- [`APP_NOTIFICATIONS.md`](../../APP_NOTIFICATIONS.md)
- [`RIME_SYNC.md`](../../RIME_SYNC.md)
- [ADR 0014](0014-rime-standard-sync-automatic-scheduling.md)
