# App Notifications And Operation Prompts

> **Status:** Product Contract accepted; implementation active
>
> **Assignment:** [`APP-NOTIFICATIONS-001`](assignments/app-notifications-001.md)
>
> **Architecture decision:** [ADR 0017](architecture/decisions/0017-app-notification-and-toast-settings.md)

## Product Goal

让普通用户在一个页面管理 Universe Keyboard 主 App 现在和未来的通知，同时清楚区分两种反馈：系统通知可以在 App 不在前台时提醒用户；操作状态提示只在主 App 内展示进度和结果。两者不是同一个开关，也不互相替代。

## Settings Contract

- 设置首页的“App 设置”分组包含“外观”“通知与提醒”“隐私与数据”；“词库与工具”只保留词典和工具类入口。
- “允许 App 通知”是所有本地通知的总开关，新用户默认关闭。只有用户主动开启时才请求 iOS 的提醒和声音权限。
- 总开关开启且没有选择任何类别时，默认选择“RIME 云同步”。关闭最后一个类别时，总开关必须同时关闭。
- 关闭总开关时保留类别选择；重新开启后继续使用原选择。系统权限被外部关闭时，总开关收敛为关闭，类别选择仍保留。
- 系统拒绝权限时，界面解释原因并提供“前往系统设置”；系统之后重新允许权限也不会悄悄打开 App 内总开关。
- RIME 云同步页面与全局页面使用同一个 RIME 通知类别状态。它覆盖手动和自动同步，不属于自动同步总开关。
- “操作状态提示”独立于系统通知，默认开启。关闭后立即隐藏当前全局 Toast，并抑制同步、下载、部署和用户词典后续的进度、成功与失败 Toast；功能详情页仍保留完整状态。重新开启不重放旧事件。

## Delivery Contract

- V1 只使用设备本地通知，不包含远程推送、角标、通知操作、关键通知或时效性通知。
- 通知内容只描述操作类别和开始、完成或失败状态，不包含输入内容、目录、文件名、词典内容、恢复码、账号或诊断日志。
- RIME 同步事件无条件交给统一通知服务；服务在发送前重新检查 App 总开关、RIME 类别开关和当前 iOS 授权状态。
- App 在前台且“操作状态提示”开启时，同一 RIME 事件的系统通知只进入通知中心列表，不弹横幅、不播放声音；Toast 关闭时才显示前台横幅、列表和声音。
- 前台优先策略依赖通知事件自身的明确元数据。未来没有对应 Toast 的类别不能被默认静音。
- App 进入前台或通知设置页出现时刷新系统授权状态，因为用户可以随时从系统设置改变权限。

## Persistence And Migration

- 总开关：`app_notifications_enabled`。
- 操作提示：`app_operation_toasts_enabled`，缺失时按开启处理。
- RIME 类别继续使用 `rime_standard_sync_notifications_enabled`，兼容旧版本设置。
- 若总开关键缺失，只有旧 RIME 类别已开启且系统当前允许通知时，才迁移为总开关开启；其他情况写入关闭且不自动弹出权限请求。
- 断开或重选 RIME 同步目录不得清除全局通知、RIME 类别或 Toast 偏好。

## Ownership And Safety

- 状态、持久化、权限和发送编排都属于包含 App。
- Keyboard Extension 不请求权限、不发送通知、不读取通知设置，按键热路径没有新增文件或系统调用。
- SwiftUI 页面只绑定根级可观察模型；系统通知中心通过可注入客户端隔离，便于覆盖授权、拒绝和发送测试。

## Acceptance

- 新用户默认、旧设置迁移、总/子开关不变量、权限拒绝和外部权限变化有自动化测试。
- 两个 RIME 入口始终呈现相同的实际开关结果。
- 通知发送门禁和前台 Toast 优先策略有自动化测试。
- 浅色/深色、Dynamic Type、VoiceOver 和窄屏布局通过主 App 设置页检查。
- 真机验证允许/拒绝、通知中心、前台横幅/声音和后台同步通知；iOS 后台执行时机仍由系统决定，不能承诺定时到达。
