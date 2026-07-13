# ADR 0013: RIME Standard Sync Interoperability

## Status

Accepted; automatic scheduling amendment recorded in ADR 0014

## Context

ADR 0012 的加密设置包适合 Universe Keyboard 自己的字段级设置，却不是其他 RIME 前端可识别的资料布局。产品目标需要允许用户在 Universe Keyboard、鼠须管、小狼毫、IBus-Rime 和兼容 Android 前端之间验证同一套 RIME 用户资料。

librime 的官方同步模型以 `installation.yaml` 中的 `sync_dir` 和设备 `installation_id` 为基础：用户词典以文本快照合并，YAML/TXT 则按设备目录备份。它不是云传输协议，也不保证将另一设备的配置自动覆盖回来。

## Decision

- 用户选定的本地/文件提供器目录是 RIME 标准同步主路径；主 App 把该路径写入本机 `installation.yaml`，并在用户明确确认后调用 librime `sync_user_data`；
- 首次标准同步只能由主 App 在用户确认后发起。后续自动调度的安全条件由 ADR 0014 定义；任何自动路径仍不可进入启动、前台、Keyboard Extension 或按键热路径；
- 标准同步只使用 librime 的快照合并，禁止复制、替换或删除运行中的 `*.userdb*`；
- Universe 端到端加密设置包保留为辅助层。它保存本 App 私有字段并可使用 WebDAV，但不得宣称会被其他 RIME 前端读取；
- 标准层明文兼容数据与私密层加密数据分目录存在。删除私密包不得删除标准同步目录；
- 输入方案以 `schema_id`、来源/版本清单和用户 `.custom.yaml` 表达；不得复制完整方案安装包、编译产物或平台专属运行资产。

## Consequences

- 用户可以让多个 RIME 前端指向同一共享目录，并使用各端已有的标准同步能力验证用户词典与配置备份。
- RIME 标准资料不具备 Universe 的端到端加密；UI 和隐私政策必须在每次操作前明确该边界。
- YAML/TXT 的官方单向备份不等于安全配置导入。跨设备自动应用配置仍需后续 staging、差异预览、路径 allowlist、恢复点和部署验证。
- Android 与第三方前端的兼容性必须逐个实测，不能从“使用 RIME”推导为完全兼容。

## Related Documents

- [`RIME_SYNC.md`](../../RIME_SYNC.md)
- [ADR 0012](0012-rime-portable-sync-and-transport-boundary.md)
- [ADR 0005](0005-user-dictionary-restore-safety.md)
- [`RIME_USER_DICTIONARY.md`](../../RIME_USER_DICTIONARY.md)
- [ADR 0014](0014-rime-standard-sync-automatic-scheduling.md)
