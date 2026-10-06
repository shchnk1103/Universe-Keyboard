# T1 单个签名 Keychain 继续验证：1通过，T2 恢复待授权

沿[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-continuation-entry-2026-10-03.md)与先冻结packet执行原未运行命令一次。xcresult实际唯一 `RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem()`，1total/1passed/0failed/0skipped，原UDID/iOS27.0/arm64，xcodebuild exit0、77.7328s。见[summary](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-continuation-artifacts/xcresult-summary.json)、[实际用例树](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-continuation-artifacts/xcresult-tests.json)及[执行argv](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-continuation-artifacts/execution.json)。原execution引用原冻结包digest，继续packet补充了新鲜基线；两者各自历史有效，不改写原freeze。仅此一个用例，没有重跑前两套。

[编译条件](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-continuation-artifacts/compiler-flags.json)18条Swift invocation核Swift语言6、DEBUG/probe与warnings-as-errors；请求complete build setting，Swift6实际driver未显式输出冗余strict旗标，不冒充字面出现。源571/Vendor630收尾仍匹配，无源修复。依赖核查最初错误地要求dependencies为空，实际为两个fileSystem本地package；修正准备工具条件后冻结，无远程依赖更新、无测试重跑。

[T2读回](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-continuation-artifacts/T2-readback.json)两次稳定且无目标进程：main827文件、group52文件+2链接、installed test-host111文件。AppGroup完整内容/元数据与本轮新鲜备份一致；main3项TipKit db/shm/wal变化，4个系统快照更名但SHA多重集相同；App安装包被test-host替换（新增51/变化7），不是standalone候选晋级。完整可访问after三容器保全 `/private/tmp/ukey-wake-ui-keychain-continuation-20261003/test-after-preservation`，复制后源稳定、副本文件/结构/模式owner/原属性匹配；已知新增provenance单列，不宣称全部metadata精确相同。原完整post-health备份和T0/test-after仍保留，raw不进repo。

准备[本轮最小恢复清单](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-continuation-artifacts/proposed-restoration.json)：单次安装精确旧C7备份78、恢复本轮备份中3个TipKit文件，AppGroup只核验不恢复；保留内容等价系统快照及新容器身份，不删main路径。安装后出现未列新差异就停。**尚未执行恢复，需Human对本轮具体新清单授权**，不能沿用上一轮不同清单。

当前三套实际记录：Rime85/0/20、AppKeyboard421/0/10、签名Keychain1/0/0；hostCore1194/0/0按已核复用。30skip仍未验证/不计通过，当前阶段Product处置与独立T验收尚未完成。历史T1数据保护Hold不倒写；本次单用例通过不等于整体T完成/环境健康/Quality Gate/新UI候选安装/Maps/Release。无Git暂存提交推送、无源码/CHANGELOG或架构合同变更。
