# ADR 0027: 企业级本地诊断可观测性

## Status

Accepted; P0 implemented, P1 deferred to TD-013

## Context

当前 `LoggerWriter` 把整个诊断历史保存为一个 App Group `UserDefaults` 文本值。每次刷写都读取、拆分、追加、截断并写回全部文本；500 条上限掩盖了该模型的容量问题。主 App 与 Keyboard Extension 各自拥有 writer，却竞争同一读改写键，因而无法保证并发记录不互相覆盖。

主 App 目前全量加载字符串、主线程筛选/倒序和复制。它不支持持续预览、查询水位或大日志分页。短暂的“唤起后按键高亮/候选出现又消失”也可能发生在现有生命周期快照之间，无法归因给真实触摸、RIME 发布、UIKit 缓存或清理。

诊断仍必须完全本地、内容无关，并且不得把延迟、I/O 或无界内存增长带回 Extension 输入热路径。

## Decision

1. 在 App Group 引入 `Diagnostics/v1/` 版本化 journal。每个 App/Extension process 使用自己的 writer identity 和独占段文件；段按 UTC 小时和体积轮转。两个目标不得 append 同一个文件。
2. 每条记录是 versioned、`Sendable` 的结构化事件，包含 UTC 时间、单调时间、origin、process instance、`appearanceID`、本地序列、`actionSequence`、session epoch、revision、事件代码和字段白名单。展示文字由主 App 生成；新协议只接受事件代码和字段白名单。禁止把任意诊断 `String` 作为长期结构化协议或以清洗器替代调用点隐私审查。
3. Extension 热路径只读取缓存的开关并尝试投入有界的 value-type 队列。它不得执行日期格式化、JSON 编码、FileManager、UserDefaults、文件写入、跨进程协调或等待。utility writer 批量追加；被挂起/终止时未落盘的尾批是 best-effort。
4. 主 App 的 repository actor 负责增量 tail、后台搜索、分页、导出、旧 `UserDefaults` 迁移、目录级保留和旧 generation 清理。诊断页可见时“实时”定义为约一秒内可见，不是逐键同步耐久。
5. 保留上限为最先触发的 7 天或 100 MiB。因多 process 活动段可能存在短暂余量；容量不足时优先丢弃低优先级事件并记录内容无关 drop summary，而不阻塞输入。
6. 清空必须先推进共享的 clear generation。reader 仅查询当前 generation；旧 writer 发现变化后旋转，旧段由主 App 异步清理。保留只能删除已 sealed、可证明非活动的段；目录容量上限允许由有限活动段造成短暂余量。
7. Debug-only 首屏高保真模式由用户手动开启，30 分钟后自动关闭。每次 presentation 有关联编号，并在首秒记录显示帧状态、候选更新来源、粗粒度触摸角色和生命周期锚点。`touch → action → owner publish → MainActor apply → candidate visible/end-display` 必须共享关联字段；不记录内容。
8. 因挂起/过载舍弃的 best-effort 事件必须通过结构化 health/drop 摘要可见。复制基于 immutable query snapshot，并限制为 5 MiB 或 10,000 条；超过上限需要缩小查询或显式导出。

### Shared-container ownership and lifecycle

`Diagnostics/v1/` 的结构由主 App 创建、迁移、版本升级、保留和删除；Keyboard Extension 不创建根目录、不枚举其他 writer、也不清理任何段。其逻辑 layout 是：

| Object | Writer / owner | Reader | Lifecycle |
|---|---|---|---|
| `Diagnostics/v1/control.json` | Main App `DiagnosticsRepository` 唯一写者；以原子 replace 推进 generation | 两个 target 的后台 writer；main-App repository | writer 仅在启动、恢复、轮转或批次边界读取并缓存，绝不在键事件读取 |
| `g<generation>/open/<origin>-<processInstanceID>-<hour>-<part>.jsonl` | 对应 origin/process instance 的 writer 独占 create/append/seal | Main App 以 offset tail，容忍最后一条半行 | 小时或大小轮转时 writer seal；Extension 不触碰 App 段，App 不触碰 Extension 段 |
| `g<generation>/leases/<origin>-<processInstanceID>.json` | 对应 writer 在自己的 utility flush 更新 | Main App retention coordinator | lease 是活动声明；唯一 process instance、generation、fence 和 UTC 过期时刻均在其中。只有经过本节围栏确认的 expired lease 才可进入恢复/清理流程 |
| `Diagnostics/v1/locks/<origin>-<processInstanceID>.lock` | 对应 writer 创建；双方仅在 utility/repository 队列取得非阻塞的内核 advisory exclusive lock | 对应 writer、Main App retention coordinator | 稳定 lock 跨越 generation；不得以 replace lease JSON 的方式替换它。它是 append、reclaim 和删除的唯一互斥围栏，不进入键盘热路径 |
| `g<generation>/reclaimed/<origin>-<processInstanceID>.json` | Main App retention coordinator | 对应 writer、Main App repository | 不可变的 reclaim tombstone，含 fence 和原因；保留到关联段删除。writer 一旦观察到它，永远不得再打开旧段 |
| `g<generation>/sealed/` | writer 将自己已关闭段转入；Main App 可恢复被确认过期的旧 open 段 | Main App repository/export | 只有 sealed 或由过期 lease 恢复后 sealed 的段可以被 retention 删除 |

Main App 清空时先原子写入新的 `control.json` generation，再切换 reader 的 query generation。旧 writer 可以继续完成它当前批次到旧 generation；这些记录从新 generation 的视图与导出不可见。它在下一次后台批次边界读取 generation 后关闭旧 handle、更新 lease 并创建自己的新 generation 段。主 App 只异步清理旧 generation，不等待 Extension acknowledgement；因此“清空完成”表示旧 generation 不再可见，而不是已同步抹除每个活动 writer 的文件句柄。

#### Generation、lease 与回收围栏

每个启动的 writer 创建不可复用的 128-bit `processInstanceID`；它不是 PID，路径、lease、lock、段和 tombstone 都使用这个 identity。lease 至少包含 `generation`、`processInstanceID`、单调递增 `fence`、最后成功续约的 UTC 时间和明确的 UTC `expiresAt`。UTC 仅用于决定“可尝试回收”；时钟异常宁可延后清理，不得绕过下面的围栏。writer 从不复用上一个 process 的 identity 或已经 reclaimed 的段。

所有实际 append 与 lease 续约都必须遵循同一顺序，并且只在 utility writer 队列中执行：

1. 对自己的稳定 `.lock` 取得**非阻塞** exclusive advisory lock；不能立即取得时安排后台重试，绝不等待或让按键路径参与。
2. 持锁重读 `control.json`、自己的 lease 和 tombstone。generation 不一致、lease identity/fence 不匹配、lease 已被移除，或 tombstone 存在时，关闭旧 handle；不得对旧段再写。随后以当前 generation 创建新段/lease，或将有界待写批按 overload 规则降级。
3. 只有确认 lease 仍属于本 instance 且 generation 相同后，才在持锁期间更新 lease、append 一个有限批并释放锁。释放锁以后任何 fd 都不得继续 append；下一批必须重新取得锁并重新验证。

Main App 回收某个 open 段也必须先以**非阻塞**方式取得同一 `.lock`。持锁后它重新读取 `control.json` 和 lease，确认 `(generation, processInstanceID, fence)` 未变化且 `expiresAt` 已过，才按以下不可逆顺序执行：原子创建 reclaim tombstone → 将 open 段转为 recovered/sealed → 删除或标记 lease 为 revoked → 释放锁。任何一步失败都保留原段、延后重试，绝不猜测成功。tombstone 存在时，即使一个慢恢复的旧 writer 尚有内存队列或旧 fd，也会在下一次锁内重检时被 fence 拒绝，不能重新写入或使已清空记录重新可见。

因此，进程在 batch 中被 suspend 时会暂时持有短时 lock，retention 只能跳过该段并以后重试；进程终止时内核释放 lock，后续回收才可能进行。这个小窗口优先保证活动 writer 不被误删；容量策略允许有限活动段造成短暂超过 100 MiB 的余量。保留只处理 sealed 或已按上述围栏 recovered 的段，绝不删除任何未取得同一 lock 并完成复核的 open 段。容量压力时 writer 记录 drop 并停止接收低优先级事件，而不是争抢锁或阻塞输入。

### Extension suspension and unavailable capability

`viewWillDisappear` 仍以输入正确性和 suspend 安全优先：它不得等待文件刷写。writer 将未写入的 tail 计入内存中的 suspended/drop 计数、关闭自己的段/lease，并取消延迟任务。若同一 process 下次恢复，它首先尝试写入一个内容无关的 `diagnostics.resume` health event，报告此前被丢弃的类别计数；进程被终止前无法落盘的计数仍是明确允许的 best-effort 损失。

当 App Group、目录或空间不可用时，writer fail closed：基本键盘输入照常，后台 writer 停止/降级并在可写时报告受控错误代码。主 App 只显示各 origin 的最后观察时间和自身遇到的错误，绝不把“未看见 Extension 日志”伪装成对 Extension 实时 Full Access 状态的判断。

## Consequences

- 需要在 App/Data、Keyboard UI、测试和文档之间建立明确接口；这不是只替换一个持久化 API 的改动。
- 当前 `rime_diag_log` 和直接读取它的真机证据工具需要一次受测迁移。
- 完整 YAML、第三方 RIME 原始日志和其他自由文本在进入长期 journal 前必须改为受控摘要；搜索与导出不得成为内容泄露的旁路。
- 查询/复制使用 immutable query snapshot（水位），从而保证“复制当前结果”不掺入新日志。
- File protection、活动段 lease/删除协调、部分 JSONL 行、磁盘满和 App Group 不可用都是 first-class failure cases。
- 日志关闭与高保真模式是独立的性能证据条件，不能用一次 Debug 观察替代 Release/真机结论。

## Risks

- `Diagnostics/v1` 是新的 App Group 持久化面；跨进程写入、部分尾行、文件保护、磁盘满和时钟跳变都可能使诊断不完整。它们只能降低可观测性，绝不能改变输入或 RIME 运行语义。
- advisory lock 的正确性依赖所有 writer 和 retention 都遵守本 ADR 的同一锁内协议；实现必须用竞争时序测试证明“锁释放后的旧 fd 不可写”与“tombstone 后不得复活”。
- 结构化字段若退化为自由文本，会重新产生输入内容泄露风险；任何新增字段必须触发 allowlist review。
- 高保真模式会增加首屏期间的事件量；其自动超时、独立开关和有界队列必须接受性能验证，不能以诊断为由降低默认输入体验。

## Follow-up Work

1. 在 `KeyboardCore` 实现 allowlisted event envelope、有界 ingress、每 writer journal 和上述 lease fencing，并迁移 legacy `rime_diag_log`。
2. 在主 App 实现 repository actor、查询水位、分页/搜索/复制上限、clear generation 和保留任务。
3. 审计每个 legacy `Logger` 生产者以及 RIME/YAML 原始日志；先将其转换为已审阅事件代码或受控字段，再接入长期 journal。
4. 为 Keyboard UI 增加首屏因果链事件，并更新调试、隐私、性能和发布资料；完成自动化、独立 Quality 和声明条件的真机证据。

## Alternatives Considered

- 提高 `UserDefaults` 条数：拒绝。仍是全量复制和跨进程覆盖。
- 两进程共享一个 append 文件并用每条记录锁：拒绝。热路径锁竞争和 suspend/恢复语义不可接受。
- SQLite/WAL 全文索引：当前拒绝。会引入跨进程锁、恢复和 Extension 依赖复杂度；v1 先以主 App 流式查询实现。
- 无限保留或每条同步 fsync：拒绝。前者无数据生命周期，后者伤害输入体验。
- 上传诊断或自动分享：拒绝。违反 ADR 0007 和当前隐私合同。

## Required Validation Before Acceptance

- 并发 writer、部分行恢复、小时/体积轮转、generation clear、retention/active lease、磁盘满/App Group 不可用、bounded overload 的自动化证据。
- 搜索、分页、实时 tail 和 copy query snapshot 的主 App 测试。
- 关闭/普通/高保真三档的 Simulator 与声明条件真机性能、内存和生命周期证据。
- Privacy field allowlist review，确认 legacy YAML/任意字符串日志不进入新协议。

## Related Documents

- ADR 0003 — Shared Container Ownership
- ADR 0007 — Full Access And Privacy Boundary
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/DEBUGGING.md`
- `docs/PERFORMANCE_BASELINE.md`
- `docs/assignments/diagnostics-observability-001.md`
