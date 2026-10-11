# 父任务性能范围收窄建议

Status: **Human-approved scoped parent performance amendment**。Decision owner: Human Product Lead。

> 当前有效决定见末节“2026-10-11：Human明确批准”；下方原提案保留过程，不再表示待批准。

## 原提案：最小收尾方式

本任务目标是交付安全、有界、可回归的纠错能力。建议最终验收以真实候选恢复/交互证据、查询有界与失败安全、固定候选完整回归门禁，以及已接受P2计数/elapsed完整性为基础。

**建议撤去本任务新增有效BASELINE/TREATMENT配对采集的必需条件**，把native CPU、整体UI延迟、内存及v2总体observer开销保留为明确未验证范围。只有未来具体性能问题需要判断时再考虑独立工作，不现在新增必做Assignment、存储/UI或性能阈值。这会改变父原性能证据要求，须Human明确批准后才写入父合同；当前原条件保持有效。

现有Run不能证明“整体性能无退化”：61个provider调用/zero候选和max6µs只支持该Run数值；旧配对跨进程仍inconclusive，旧synthetic只限原环境。风险接受不写成性能Pass。新默认完整CI中若出现卡死、失败、安全不变式失效或明确回归，仍须停止，不能用本收窄决定忽略。

这项选择可结束本任务的额外性能采集负担，同时保留事实边界。默认安全、隐私、sidecar/live隔离、真实候选恢复、回归门禁均不降级。也不恢复手动<180ms通过条件或RimeRuntimeProvenance。

## Human可选决定

1. **建议：批准上述父性能范围收窄**。不再新增本任务配对采集；未来性能调查按具体问题另决。
2. 保留原配对比较要求。必须先明确哪项指标会影响产品决定，再制定一种有限采集方案；不自动恢复大型trace或重复P2。

批准范围收窄仍不等于父Gate/Close、merge、Release或ADR Accept。固定候选完整CI/文档交付及最终Gate/Close材料仍需按各自权限完成。

## 2026-10-11：Human明确批准

Human对本页方案明确答“批准收窄，不再新增配对采集”。即日起本任务不再以新增有效BASELINE/TREATMENT配对性能采集作为必需退出项；以本页功能/回归/有界查询及已接受P2完整性证据收尾，整体CPU/UI/内存及v2总体observer未知原样保留，不声称性能Pass。该决定不豁免明确功能/安全回归，也不自动授予父Gate/Close、merge或Release。历史配对inconclusive保持。
