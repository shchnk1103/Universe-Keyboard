# M0 当前43d85d候选恢复方案（Prepared，不执行）

当前完整备份 /private/tmp/ukey-wake-m0-20261003/backup（0700），包括main-data、app-group、installed-app；候选43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50，不是I0旧C7。精确原设备405D994F-28CB-4F89-BB22-B64AD81C05A2。三次源库存一致、容器稳定；副本字节／结构／mode／uid/gid／原xattrs一致，新provenance另列。ditto带ACL复制但未逐项读取ACL／时间戳校验，不声称所有元数据完全相等。备份main/appex strict签名通过，78 payload完全匹配H1。

原两diagnostic键均ABSENT，不以false覆盖absence；rime_deployed=true、rime_needs_deploy=false、rime_is_deploying ABSENT。备份系统完全访问／键盘启用、Keychain与Maps数据的能力不存在；这些保持不改。Group当前51文件、15目录、2内部链接，按实际完整快照保留，不拿历史53／52条库存覆盖或据数量判损坏。备份位置private tmp不是长期存储，不自动迁移用户数据。

如未来需要恢复：

1. 先重新核原设备／独占／进程与当前容器，保全after三组快照及库存；不得覆盖本before备份。
2. 将after与本M0逐路径内容／存在性／metadata差异列成清单，区分系统容器metadata、合法新UUID与应用内容；明确恢复会丢失哪些之后的数据。未经具体批准，不停止新进程、重装或覆盖文件。
3. 若需重装，只申请M0 installed-app中的精确43d85d配对包；如需旧C7，须另有Product决定并沿保留I0快照，不能混用身份。数据恢复仅经批准路径，内部链接限定Group，恢复原偏好存在性和值，不移除清单之外文件。
4. 读回双签名／78payload／库存与原偏好／部署状态；必要人工输入健康另授权验证。机器字节相等不代运行健康；恢复失败交付Hold，不自动重试／重新部署。

M0只建立保护及方案，未执行恢复、重装或部署。I0与I1保全留着；四组历史T快照的清理提案与本恢复权限分开。
