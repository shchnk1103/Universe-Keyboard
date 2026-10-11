# F2 before最小恢复方案 — 已执行（机器读回） — 2026-10-04

执行回执：[restore-delivery](../evidence/keyboard-wake-host-activation-fix-001-f2-restore-artifacts/restore-delivery.md)、[restore-receipt](../evidence/keyboard-wake-host-activation-fix-001-f2-restore-artifacts/restore-receipt.json)。下文为原 Prepared 清单，保留为授权范围原文。

F2测试已结束，after主App/Group容器UUID均不同，安装包为本次签名测试构建；AppGroup当前4文件/724bytes、待部署，before为51文件/37,749,287bytes且已部署。test runner环境副作用已授权，但恢复未授权。仅恢复F2开始前环境，不用M0跨窗口，也不影响五文件源码/测试证据。

精确UDID405D994F-28CB-4F89-BB22-B64AD81C05A2。唯一来源 `/private/tmp/ukey-host-activation-fix-f2-backup-20261004` 的 `installed-app`、`main-data`、`app-group`；这组备份三次源读取一致、字节/结构/已核metadata、签名已验证，约128M。[before回执](../evidence/keyboard-wake-host-activation-fix-001-f2-execution-artifacts/backup-receipt.json)。

具体恢复授权提案：

1. 先只读重核UDID/独占、当前无App/appex进程、before库存/hash/签名未漂移，完整保存当前after三组到新的私有after保护目录并核字节。不覆盖本before或历史备份。若进程重现，正常终止另精确批准，不自动signal。
2. `simctl install`仅安装本before的精确`installed-app`，不卸载/erase或换设备；再发现系统新分配的Data/Group路径。安装允许系统容器UUID变化，不拿旧UUID路径覆盖新身份。
3. 仅在这两个重新核实且归属本bundle/group的容器中恢复before应用内容与原存在性；保留系统当前 `.com.apple.mobile_container_manager.metadata.plist` 等容器管理身份，不把旧UUID metadata拷进新容器。先列出所有要替换/移除的应用内容精确清单；清单外路径、系统metadata及Keychain/键盘设置/Maps不改。内部symlink必须仍限在正确AppGroup。若发现其他系统身份文件或无法保持归属，停止。
4. 按before读回payload字节/结构、签名、允许例外的容器metadata与UUID另记录；logging/high-fidelity原ABSENT仍恢复ABSENT，rime_deployed原true、needs_deploy原false。机器恢复不等于实际输入健康；不自动启动/重新部署，后续Human健康确认另明确范围。
5. 保留after、before和F2原始日志/xcresult，交付恢复结果；失败Hold不自动重试、不擦掉故障证据。当前模拟器独占不得释放给其他任务，待Human决定。

这是具体Prepared清单，不是已恢复。源数据含用户内容，仅私有字节副本，不写仓库或输出用户词条/宿主文字。此恢复会舍弃本次测试造成的App/Group内容变化，保留after以可恢复；不声称Keychain和系统键盘设置可回滚。
