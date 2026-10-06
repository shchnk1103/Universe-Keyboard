# 独立 T round1 停止交付（Partial / incomplete）

Human授权独立T验收；派发前冻结Quality lane round1，原14calls/1200s硬限，当前无活跃独立reviewer可复用，使用GPT6 Luna。原[报告](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-independent-r1-artifacts/review.md)及[usage](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-independent-r1-artifacts/usage.json)完整保留，不改写为通过。

本轮4个leaf calls，T1-T6全部Partial；审查者仅读取packet、计算文件摘要及落盘，未核验实际suite/Core/数据保护依赖。正式独立验收未完成。usage首次调用前未记录起点，actual elapsed及时间预算状态UNKNOWN；不以单个tool wall time之和冒充完整耗时。

root[定点事实核查](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-independent-r1-artifacts/root-digest-adjudication.json)：原JSON自载digest是移除`packet_digest_sha256`后的UTF8/ensure_ascii=false/sort_keys=true/separators(',',':') canonical JSON SHA256，重算与e4ea33…一致。审查者计算whole-file SHA256=9e9374…，两者不同算法，不能等同。原packet未显式规定算法，属于coordinator冻结/reader接口缺陷；不解释为源码/产物损坏，root也不替代独立验收。旧F-001停止报告保留。30skip本阶段Product处置仍缺失，且本轮尚未独立核真，不能因技术摘要修正自动accept。

已准备round2合同：同候选/同T1-T6/同allowlist，只澄清digest算法、加入先冻结的审查起点及用量规范；建议10calls/900s，硬限不自动续。不执行新round，不从本轮停止自动生成权限。待Human明确授权本Prepared round2后，按实际派发前时间冻结可执行packet并记录外部whole-file SHA256。无设备、源码、构建、测试、Git发布或Gate/Release变化。
