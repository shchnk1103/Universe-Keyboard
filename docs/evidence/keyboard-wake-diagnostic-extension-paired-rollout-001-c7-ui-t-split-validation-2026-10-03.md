# C7 UI T split 独立验收交付

## Scope / Decision

Human 批准 S/P 各 GPT6 Luna low、6 leaf calls /900s。两位审查者均报告用完6次，未生成规定 review.md 或 usage.json。正式验收 **Partial / incomplete，Overall T Hold**；不自动续预算。root 只归档消息衍生停止记录，未补造独立报告或用量。真实审查结束时刻/elapsed UNKNOWN；观察耗时上界明确不是审查者实际elapsed。

## Evidence Matrix

| Lane | 消息报告的核查 | 必需交付缺口 |
|---|---|---|
| S | packet双digest、36内容和1201 hash-only匹配；T2实际85/0/20、421/0/10、1/0/0；T3 Core204最终文件集匹配、1194 host结果 | T1候选编译输入/argv/toolchain严格绑定未闭合；最后一次调用路径索引错误；正式report/usage缺失 |
| P | 55内容hash匹配；首次恢复应用数据库存零差异和Snapshot SHA multiset相等；两次基线区分、第二次仅3文件；人工健康/旧C7归因正确 | xattrs分类未独立闭合；用完调用未写正式report/usage |

Covered 仅为审查者消息中的局部观点，不提升整体独立覆盖状态。所有 frozen allowed 内容 hash 在归档前再核无差异。

## Root 定点澄清（不替代独立验收）

P 将备份副本与恢复库存的 xattrs 差异列为缺口。root 对 fresh before→backup 核查：额外 com.apple.provenance 为 main865/group8/app9，既有attr hash变化0、删除0；fresh before→final main/group既有attr变化0。此结果说明不能把副本新增属性直接解释为应用数据恢复损坏。installed-app仍有2项attr hash变化，未在本轮新增分析或宣称全部元数据精确匹配。完整分类与独立验证仍开放。详见root-xattr-clarification.json。

## Skipped / Owner Handoffs

30 raw skip记录不变；其中同一Keychain identity另轮signed1pass，剩29未验证内容。本阶段Product residual disposition尚未批准；不沿用旧v5/StageB/C7接受。无需为计数重跑。未进行构建、测试、设备、安装、恢复、LLDB、源码变更、暂存或发布。

下一步需先预检确定性reader及输出写出路径，再提出明确的最小补审范围/预算；未经Human再次授权不得启动新审查轮。协调者负责准备缺陷，Human保留Product决定。
