# ADR 0014: RIME Standard Sync Automatic Scheduling

## Status

Accepted; implementation in progress

## Context

用户不应每天打开 Universe Keyboard 执行一次手动同步，但 RIME 标准同步会维护用户词典快照和设备备份。直接把 `sync_user_data` 放进启动、前台或键盘按键路径，会与键盘扩展的 RIME session 并发，也会把 iOS 后台调度误表述为可靠定时器。

## Decision

- 首次标准同步仍必须由用户在主 App 明确确认；成功后只解锁自动同步资格，不自动开启任何开关。用户明确打开总开关时，“RIME 标准同步”和“Universe 设置同步”两个子开关默认开启；用户可独立关闭任一子项，并可选择每天或每 7 天的共享冷却时间；
- 关闭最后一个子项时同时关闭总开关并取消后台调度。再次打开总开关时，若没有保留任何同步范围则恢复两项默认开启；若仍保留一项则保持原选择；
- 子开关只约束自动路径：RIME 子开关控制 `BGProcessingTask` 标准同步，Universe 子开关控制前台私密设置维护及标准后台同步后的私密设置维护。手动 `立即同步` 始终完整执行目的地支持的两层；成功后重置共享冷却起点，但不覆盖用户明确关闭的自动开关；
- 自动同步仅由包含 App 的 `BGProcessingTask` 执行。`earliestBeginDate` 只表达最早时间，系统决定是否以及何时运行；
- 开始前必须确认共享目录配置有效、首次同步已成功、冷却时间已到且 App Group 中键盘活动心跳已失效；任一条件不满足即跳过本轮；
- 自动同步继续调用 librime 的 `sync_user_data`，禁止复制、替换或删除运行中的 `*.userdb*`，也不自动导入其他设备的 YAML；
- 主 App 启动和回到前台时只允许自动更新 Universe 私密设置，并服从同一个每天或每 7 天冷却时间；以尝试时间节流，成功、失败和取消都不会导致下一次启动立即重试；
- 用户可在全 App 通知设置或 RIME 页面开启同一个 RIME 通知类别；获权后通知手动与自动同步的开始、完成和失败/取消，并准确标明本次实际运行的同步范围，不包含词典、目录、恢复码或输入内容。通知不属于自动同步开关，断开同步目录也不重置通知偏好；
- 自动同步、通知、网络和文件维护全部留在主 App；Keyboard Extension 只在可见生命周期写入无内容的活动心跳，绝不在按键热路径读写同步状态。

## Alternatives Considered

- **始终手动同步**：安全但要求用户反复打开 App，不能满足普通用户的持续使用体验。
- **把同步放到键盘扩展或按键路径**：会引入用户词典并发写入、输入延迟和 Full Access 边界风险，因此拒绝。
- **按固定本地定时器执行**：iOS 不保证 App 在后台存活，且会误导用户以为同步可实时完成，因此拒绝。

## Consequences

- 自动同步便利性提升，但每次执行的时间由 iOS 决定，用户界面和文案不得承诺固定时刻。
- 键盘活动时会跳过一次后台机会；这是一项宁可延后、不可并发维护用户数据的安全取舍。
- 自动任务失败后会保留本地数据和自动设置，在下个用户选择的周期再试；目录访问失效时则暂停同步并要求重新选择。前台私密设置维护采用同一冷却语义，不会因失败而在每次启动时反复弹出状态。
- 已有用户未保存两个子开关时将子项迁移为两项开启，但不得因此改变总开关状态；显式保存的范围选择不得被启动、前台刷新或后续手动同步覆盖。总开关开启但两个子项都关闭的状态必须立即收敛为总开关关闭。

## Risks

- 活动心跳是避免并发的保守信号，不能取代真实设备上的扩展/后台并发验证。
- `BGProcessingTask` 可能被系统延后或取消，后台通知也依赖用户授予权限。
- 第三方 RIME 前端对快照文件的处理仍需逐个平台做真实互操作验证。

## Follow-up Work

- 在真机上验证后台任务注册、系统延后、取消、键盘可见跳过、通知拒绝/允许和第二设备合并。
- 在 macOS、Windows、Linux、Android 兼容前端上验证相同 `sync_dir` 的快照合并行为。
- 若未来需要自动导入 YAML 或更严格的跨进程锁，另行提出 Product、Architecture 和 Quality Gate。

## Related Documents

- [`RIME_SYNC.md`](../../RIME_SYNC.md)
- [ADR 0013](0013-rime-standard-sync-interoperability.md)
- [ADR 0005](0005-user-dictionary-restore-safety.md)
- [`shared-container-and-rime-lifecycle.md`](../shared-container-and-rime-lifecycle.md)
- [ADR 0019](0019-app-notification-and-toast-settings.md)
