# ADR 0028: 诊断日历查询与有界最近窗口

## Status

Proposed; first independent Architecture review failed, remediation ready for re-review

## Context

ADR 0027 的 v1 writer 已按 UTC 小时与 1 MiB 体积轮转，并保持每 process 独占段，因此底层不存在必须改成“每日共享文件”才能分日的问题。当前 P1 reader 为了严格 generation-wide newest-first，在开始分页前解码完整水位；当前 generation 超过 5 MiB 或 10,000 事件时 fail-closed，导致磁盘仍有日志但 UI 无法浏览。

用户需要按自然日理解日志，并希望容量超过单次查询预算后仍能看到最近记录。系统仍必须明确区分“完整严格快照”与“不完整最近窗口”，不得为了可见性伪造完整性。

## Decision

1. 保留 `Diagnostics/v1` writer、UTC 小时/体积分段和所有 ADR 0027 围栏，不创建跨进程共享日文件。
2. `DiagnosticsJournalReader` 在 Main App 内根据段名 UTC 小时推导候选本地日期；查询使用半开日期范围 `[start, end)`，解码后再次按事件 UTC 时间过滤。
3. 日期范围内总水位不超过 5 MiB / 10,000 事件时，继续使用完整冻结 manifest、严格全局 newest-first 与既有 cursor invalidation。
4. 日期范围超预算时，可从范围内每个段的尾部在总预算内进行有界采样，合并后按既有 comparator 排序并返回显式 `partialRecentWindow`。它提供恢复与观察价值，但不宣称完整、不提供更早 cursor。
5. UI 默认选择含日志的最新本地日期，日期切换创建新查询。部分窗口必须使用持久可见的完整性提示；复制仅复制当前可见窗口并保留现有导出上限。
6. “任意大单日历史的完整严格深分页”需要段级索引或 Main-App disk-backed external merge；在该设计完成前保留为显式 residual。

## Alternatives Considered

- **每天由 App 与 Extension 共写一个文件：拒绝。** 会重新引入跨进程 append/锁竞争，并破坏 Extension hot-path 边界。
- **简单提高 5 MiB：拒绝。** 只延后同一失败点并增加主 App 内存/I/O 峰值。
- **超预算继续空白：拒绝。** 完整性安全但缺少基本观察价值，且与用户对日志工具的合理预期冲突。
- **立即迁移 `Diagnostics/v2`：暂缓。** v1 已有更细的物理分段；当前产品价值可以在 reader/UI 层获得，迁移成本和风险不成比例。

## Consequences

- 日期是查询与展示 facet，不是新的 writer ownership 边界。
- 在预算内的日期仍有严格完整性；超预算日期明确降级为最近窗口。
- 跨时区时，同一 UTC 段会映射到当前时区下的本地日期；事件以 UTC 保存，文件无需移动。
- 最近窗口读取量和内存继续有硬上限，但可能遗漏较旧或未落入各段尾部窗口的事件。

## Risks

- 段数量极多时，每段公平预算可能不足以解码完整 JSONL 行；UI 必须允许出现“部分窗口无可解码记录”的受控状态。
- 当前时区变化会改变日期 facet；这是展示变化，不是数据迁移。
- 用户可能把复制结果误认为完整历史；部分窗口提示必须在日志内容上方持续可见。

## Follow-up Work

- 独立复核冻结 watermark、查询 revision、typed 日期失败、跨午夜跟随、partial 空态及新增回归证据。
- writer 同 batch 跨 UTC 小时可能使段名日期索引遗漏；修改 writer 前必须重新通过 Assignment Stop Condition。
- 设计段级时间/offset 索引或 disk-backed external merge，实现超预算日期的完整深分页。
- 独立 Architecture / Quality 复核后决定本 ADR 是否 `Accepted`。
- 真机验证时覆盖时区边界、跨午夜刷新、light/dark、Dynamic Type 与 VoiceOver。

## Related Documents

- [ADR 0027](0027-enterprise-local-diagnostic-observability.md)
- [`DIAGNOSTICS-DAY-BROWSER-001`](../../assignments/diagnostics-day-browser-001.md)
- [`DEBUGGING.md`](../../DEBUGGING.md)
