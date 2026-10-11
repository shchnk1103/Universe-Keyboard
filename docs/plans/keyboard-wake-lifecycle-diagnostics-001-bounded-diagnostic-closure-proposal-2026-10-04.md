# 父诊断任务有界收尾提案 — 2026-10-04

**Proposed / 未生效。** 适用仅KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001当前父诊断交付，不修改全局KOS、不自动关闭paired-rollout子任务或批准修复/Release。

## Product需要决定的具体结果

建议批准父任务以“已证明的schedule owner缺失边界及领域交接”完成诊断交付，而不要求当前诊断继续补成系统全路径或修复验收。它是本父任务完成标准的明确范围修订，不是原严格Exit已满足的声明。

证据核心固定：candidate43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50；原iPhone18Pro/iOS27.0 UDID405D994F-28CB-4F89-BB22-B64AD81C05A2；PID55759同历史窗口，snapshot SHA11bafebea4e558360a155d5ac3f7739161f2e4177456fd84f7322bef1b5e631e，1056bytes/11rows，正常attempt1 schedule owner/receipt=1/1，挂起teardown后attempt2=0/0。两独立审查的这些局部claims Covered、overall Partial保留。

## 仅本父任务的Exit修订与残项处置

| ID | Proposed Product disposition / scope |
|---|---|
| PEXIT-R1 source contract | 仅本次owner边界判定接受已核验KWOPROBE固定数值快照为有效取证源，替代本次同轮JSONL来源要求；9月27/C5/C6仅历史背景，不冒充当前source。原JSONL段SHA/writer-health/build历史链缺口保留为未验证；不称原第4条通过，不追补无法重建历史。 |
| PEXIT-R2 coverage | 接受当前正常/失败attempt配对和可观测owner/schedule边界达到诊断交接目的；完整恢复、缺resume原因、engine/publication/UI/host以及realized schema验证留待另行授权的领域修复/回归任务。仅本父诊断非阻塞未验证残项，不外推修复/Release。 |
| PEXIT-R3 audit/delivery | 接受native poll序号5请求/响应落盘缺口、Quality指定文件未写出/原文转录及总wall time未独立核验为本父交付的非阻塞流程残项；Partial、缺口和历史原件不改写，不声称所有审查流程严格合规。 |

其余privacy、精确当前产物、固定数值工件SHA、Debug Investigator报告、独立局部结论和明确领域交接要求保留。不能把localcomplete当系统coverage、receipt当engine完成、UI空栏当输入恢复、或者把owner缺失推广为所有Maps问题。

## 批准后的最小动作（仍需实际Product批准）

root记录精确Product决定和本父Exit addendum、将父诊断标为有界Completed并链接交接/残项，定点同步镜像；未达到的旧严格条款及双Partial继续在历史记录中可见。paired-rollout子任务及任何后续修复独立管理，不随父自动关闭。此批准不授权源码/build/test/安装/采集/模拟器/删除备份/Git/新线程消息/Release。

若不批准本范围修订，保留父Active及原严格Exit，未来实际补采/独立验收另定精确Entry；今晚期限不自动豁免。

依据：[历史证据对照](../evidence/keyboard-wake-lifecycle-diagnostics-001-historical-exit-map-2026-10-04.md)、[双独立验收与领域交接](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-m2r2-reexport-review-validation-2026-10-04.md)。
