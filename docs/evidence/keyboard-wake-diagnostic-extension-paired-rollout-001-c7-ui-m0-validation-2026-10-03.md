# M0 当前保护交付 — 2026-10-03

本轮M0限定范围完成。[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-entry-2026-10-03.md)、[备份回执](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-artifacts/backup-receipt.json)、[原件归档](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-artifacts/preservation.json)、[恢复方案](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-recovery-plan-2026-10-03.md)齐备。原设备／installed78文件／双签名匹配43d85d…，主App与Maps进程缺席，精确旧appex88188经复核仅一次SIGTERM退出。三次源库存稳定、容器一致，副本bytes/structure/mode/owner/原xattrs匹配；新增provenance为main865、Group9、app9，未声称所有metadataexact。

完整private backup：main827文件／42目录，Group51文件／15目录／2内部symlink，installed78文件／9目录；127.63MiB。源与备份双签名及payload已核验。源Group历史53而本轮51是库存差异，仅按当前完整基线记录，不判数据损坏或历史恢复。两diagnostic键仍ABSENT/off，部署标志正常；未读取用户词条/宿主内容到repo，完整raw库存保留private。备份不覆盖系统键盘设置／Keychain／Maps；当前完全访问、输入健康未做人工复验，M1仍须fresh确认。

[旧备份清理提案](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-old-backup-cleanup-prepared-2026-10-03.md)列4组已收尾T快照约499.83MiB，当前保护已替代其运行回退用途；仅待精确删除授权，所有证据parent／报告／库存／xcresult保留。I0/I1/M0暂留，无删除／迁移。未安装、恢复、部署、启动Maps/新实例、LLDB、arm或输入，不构建／测试／源码／Git发布。M1/M2未获授权；父子Active，Maps根因未确认。
