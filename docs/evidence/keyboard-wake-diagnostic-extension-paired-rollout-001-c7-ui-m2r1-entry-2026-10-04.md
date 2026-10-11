# M2R1 新鲜 Maps 配对取证 Entry — 2026-10-04

Human授权一轮新的完整配对取证并确认原设备独占；随后确认两App关闭、未重装或部署。root接受本轮Coordinator/Executor/Environment Executor，Human为Product Authority/人工操作员；Domain Owner沿Assignment为Keyboard Experience Maintainer。后续独立验收另冻结范围/预算，不续旧lane。

## 当前核验与依赖

原worktree、branch codex/keyboard-wake-v3-compatibility-gate、HEAD84b9c19227330b0fe6ff391be001ee398010fd6a；完整dirty私有保全777项、暂存区0，源输入1279一致。原iPhone18Pro/iOS27.0、UDID405D994F-28CB-4F89-BB22-B64AD81C05A2 Booted，候选43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50安装78文件一致，两诊断ABSENT/off、部署正常。旧8491仍在，精确路径/SHA匹配；仅本轮新实例所需的一次正常SIGTERM，若退出不发，身份变化/失败停止，不强杀。

静止数据库存与完整恢复保护、新实例loaded UUID/唯一出口断点0hit、完全访问/26键布局/空候选与观测可见必须现场通过才Ready；此时仍Pending，不冒充已满足。保护按最新库存逐路径核验：既有完整副本若与当前一致可明确复用，不一致的root新增完整副本。原备份不删除。恢复方案只准备、不执行；不覆盖Keychain、系统设置或Maps数据。

## 本轮冻结操作与停止

沿[原M合同](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m-prepared-2026-10-03.md)及[操作卡](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m-operation-cards-2026-10-03.md)，逐卡下发：一次arm、一次n正常基线、仅AppSwitcher直接回Maps、一次n返回后输入、一次freeze及一次有界导出。两attempt仅同run/同process绑定，不接旧M2或M2-A armed实例。600秒TTL，任何额外按键、基线失败、键盘关闭重开、PID改变、标题/断点/TTL异常均停止，零自动retry。

精确PID attach后所有命令显式session，不改共享defaults；loaded原UDID路径与UUID核验，raw profile标签冲突保留。arm回报后一次常规断点状态检查确认窗口未冻结；旧孤立提前hit1继续仅记录，不开展独立专项追查。只在授权freeze停点核frame/caller最多8帧/static address与byteCount，176..11352字节、8对齐、真实同步borrow、一次binary read；不expression/写内存/用户内容。工具每次<=30秒，首次观测停点工作预算120秒，真实pause开始未知留UNKNOWN。账本在每次调用前后落盘；异常优先自身断点删除/list/必要continue/detach，进程已running则不多发continue。

Exit只视觉确认；安装/源/prefs与进程机器复核，离线decoder和全部行完整性/attempt配对后才描述owner记录点。缺schedule不判owner为空。无新增源码/构建测试/安装/恢复/Git发布或Release；历史skips不记通过，不为计数重跑。父子Active，旧M2仍Incomplete，M2-A人工视觉Exit未回报留缺口，本轮Human关闭App不是旧视觉补证。

私有工作目录 /private/tmp/ukey-wake-m2r1-20261004；[授权/只读准备](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r1-artifacts/authority.json)。此文档仅Entry准备；现场项通过后增量记录，不改写历史。


## 静止保护增量（新实例现场项仍Pending）

旧8491一次SIGTERM正常退出，无respawn。当前源三次库存相等；完整827 main文件/51 Group文件/78 App文件（956）字节/结构/mode/uid/gid/原xattr核验通过，双签名通过。main-data与installed-app采用本轮完整核验后的M0 retained副本；Group有变化，新增完整副本约36.1MiB。原源数据未修改，无安装/部署/恢复。

初次核验 retained main-data 副本缺17个空目录，现存文件无缺失；该失败库存保留。纠正实际发生在复用M0 main-data私有副本：按静止源补齐17个空目录及其metadata，已有文件没有改动；不写成只修改“新副本”或旧副本从未修改。第一次纠正因Python无os.listxattr停止，改系统xattr后全量重核通过；工具故障与结构缺口不删除。没有删除任何旧备份。完整metadata不宣称全匹配（ACL/时间戳未逐项核验）。原M2-A视觉Exit缺口保留。

[恢复方案](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r1-recovery-plan-2026-10-04.md)仅Prepared；本轮保护位置与复用依赖见backup-receipt。下一Human打开Maps空搜索框/叫Keyboard，核完全访问和初始空候选、26键布局、观测可见，再核新PID/loaded UUID/断点；不能未核Entry先输入。


## 新实例pre-arm现场通过

Human“观测已出现”；新41635、Maps41622；78payload/双签名/6MachO/1279source/956保护文件无漂移。原UDID真实loaded path与两个UUID匹配，session27ecbb96…，出口断点1唯一resolved、0hit；continue确认running。raw profile另UDID与current banner差异保留，所有调用显式session。仅下发一次arm卡，尚未输入/切换/freeze/read；真实pause开始UNKNOWN。
