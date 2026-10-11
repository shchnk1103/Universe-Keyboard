# ADR draft：DEBUG查询快照本地保存与主App导出

2026-10-10：Deferred optional enhancement。Human 将存储协议、目录所有权、配额、保留策略和 UI 留待以后；本 draft 仍 Proposed，不是 Accepted ADR，也不是当前 P2 完成前置。当前采用[批准的最小合同](../../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LOCAL-EVIDENCE-REQUIREMENTS-001.md)，以下保留历史提案。

Status: Proposed；编号与Accepted决定待Architecture/Human，当前不是绑定架构合同。

## Context

既有query memory probe能生成有限完整性快照，当前导出依赖调试器；完整系统trace入口和导入存在预算/空间阻碍。希望开发者能用按钮保存并从App导出，不能引入热路径I/O、泄露输入或改变RIME部署。

## Proposed Decision

MainApp拥有独立 `QueryCostEvidence/v1/` root、reservation/control/quota/retention；Extension专用后台actor仅写自身已预留Run，freeze后写binary/manifest再发布completed marker。MainApp验证wire/identity/length/hash后才分享。完整性与保存状态独立；未完成写入不能作完整证据。Swift6使用Sendable immutable snapshot与明确actor，不用unchecked Sendable绕过隔离。

第一版只DEBUG/显式手动开启，维持生产probe一进程一次arm和30分钟TTL；现有journal及diagnostic preferences不变。共享写入需实际FullAccess和AppGroup能力核对；不增加权限请求或自动切换开关。

## Alternatives Considered

- 全量SystemTrace/Allocations：保留作未来专项观察，但不解决日常导出，文件/导入成本高且尚未成功读回。
- 把所有query写普通文本journal：已有丢失/密度/封存准入复杂度，而且会混合prefs与证据状态；不作为新默认。
- 继续LLDB pointer transport：可保留历史调试路径，不能作为第一版日常操作前置。
- 自动全天滚动日志或Release启用：涉及持久产品/隐私合同，本轮不实施。

## Consequences

新增受控AppGroup数据生命周期和跨target协议，必须独立Architecture/Quality审查、失败/并发/retention验证并获实施AUTH。限额和有限Run降低增长风险，但不保证进程被终止后能保存；synthetic微基准不证明真实UI/CPU/内存无干扰。

具体协议/参数/失败条件以 [Proposed设计](../../plans/typo-correction-002-int003-query-cost-p2-local-evidence-design-001.md)为审查输入；批准后再建立实现Source of Truth，ADR当前不Accepted、不改变既有ADR0010或RIME边界。
