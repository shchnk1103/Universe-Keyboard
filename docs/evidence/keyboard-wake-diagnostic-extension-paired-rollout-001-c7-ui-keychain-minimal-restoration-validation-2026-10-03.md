# Keychain 测后最小恢复交付（机器读回通过）

Human明确授权“重装精确旧C7，并恢复这3个文件”，沿[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-minimal-restoration-entry-2026-10-03.md)及[本轮具体清单](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-continuation-artifacts/proposed-restoration.json)，root执行。只使用人工正常输入后的新鲜backup，不覆盖原T0/上一轮数据。

执行前完整before备份、after保全及current内容/结构/模式owner/原属性一致，无目标进程；source571/Vendor630/branch/HEAD匹配。[单次安装](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-minimal-restoration-artifacts/install-receipt.json)精确旧C7 private副本78文件及双签名先核有效，指定原UDID simctl install exit0。未uninstall、构建、重新部署或启动。安装后重新发现容器，未出现清单外应用数据变化；系统根/metadata与快照另列保留。

[实际3项动作](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-minimal-restoration-artifacts/restoration-actions.json)仅覆盖main的TipKit db/shm/wal。本轮**AppGroup写入0、删除0**，系统快照更名保留。App安装自身是授权动作，不把“AppGroup未写入”扩大成全轮设备零副作用。

[最终机器读回](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-minimal-restoration-artifacts/restore-verification.json)两次稳定：main827文件/42目录，group52文件/15目录/2链接，旧app78文件/9目录。main应用内容/结构/模式owner/原属性匹配本轮post-health备份，Group始终一致；系统身份与postinstall相同，系统快照SHA多重集与before一致。旧C7完整78字节匹配、App/appex双签名有效；诊断两键均原不存在、默认关闭，deployed=true/needs=false/deploying=false。已知附加provenance 0项分类，不声明全部metadata精确相同。

raw完整before、test-after及恢复读回仍在private `/private/tmp/ukey-wake-ui-keychain-continuation-20261003`；repo仅内容无关receipt，不归档用户数据。恢复后的运行健康未重新测试，旧健康证据发生在这次Keychain及恢复之前，不冒充最新runtime验证。

当前实际三套Rime85/0/20、AppKeyboard421/0/10、Keychain1/0/0；hostCore1194/0/0按冻结条件复用。原历史T1 Hold不改写，当前机器恢复缺口已解除，但30skip未验证/当前阶段Product处置及独立T验收仍开放。新UI候选43d85d…未安装，Maps/观测/LLDB/Release均未执行。下一依赖为必要运行健康与独立T验收，不预填整体Gate。无源码、暂存、提交推送、CHANGELOG或架构合同变化。

## 后续健康补证

上述交付时的运行健康待核状态已由Human另行授权并于本轮补齐，见[最新健康交付](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-minimal-restoration-health-validation-2026-10-03.md)；原时间点不倒写，独立T验收和30skip处置仍开放。
