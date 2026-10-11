# PR139 固定候选发布方案

Status: Human-authorized execution。独立复核已完成；Human“接受，并继续吧”授权本轮commit/push/更新现有draft139，由独立发布AUTH执行；不授merge。

## 目标与范围

保留现有PR139及旧head `e20e7c8a3a48822e2e712d36453e2cf574088e87` 的祖先关系，整合固定main `a44f850d638204aa5c992ac13fb71f5f5424734c`，交付已通过本地CI的五源候选。旧分支 `codex/typo-correction-002-f01-remediation-001`；推送应是正常fast-forward，不默认force-push。不随后续main更新不断rebase或重试。

## 精确后续动作（须Human发布授权）

1. 发布权限生效后，以旧139 head建立干净专用发布writer，执行一次与固定a44的 `--no-commit --no-ff` 合并准备。源码冲突只选择已验证五源字节；其余产品源保留a44，不重做修复。
2. 文档冲突保留a44的当前导航，并加有限F01状态及本次review/CI证据；旧F01原始记录保留其历史身份和Closed工程范围，不冒称已经上main。仅本轮Assignment/AUTH/计划/小型证据、必要旧F01文档与导航、CHANGELOG事实条目进入精确清单，禁止stage全部治理writer。
3. 确认source5与已验证manifest逐一相同、其他产品源与a44相同；运行最终文档轻量门和KOS结构检查。commit前与push前各运行 `swift-format format --in-place` 和strict lint5，hash变化或失败立即停止。
4. 单次正常merge commit同时保留旧139 head与a44 ancestry；只push旧139功能分支。推送前再核对远端旧head没有被别人更新，若变化停止，不force、不pull-retry。更新现有PR139正文为当前身份、实际本地CI及独立复核边界，保持draft，不创建重复PR。
5. 推送后记录实际head/hosted run和PR身份。hosted成功不授ready/merge；后续Human明确合并后才执行。新增main变化仅做有限影响核对，不自发重跑完整CI。

## 完成证据与不包含项

同源manifest及独立复核、两次严格格式检查、精确docs清单/轻量检查、实际commit/远端branch/PR139/head/hosted状态。全套CI只复用同源、同基线和适用环境的既有成功结果；若发布源码身份或必要build输入不同，停止并另议，不能静默复用。

不修改query/部署所有权，不恢复RimeRuntimeProvenance，不采集P2/新性能，不合并PR139、不父Gate/Close、ADR Accept、TestFlight或Release，不清理未合并分支或唯一证据。
