# TD-013 — Diagnostics v1 P1 实施计划

> **Lifecycle:** Active
>
> **Current status:** Product Lead 已指定任务责任并授权实现；对应 Assignment 处于 `Active`。Phase A 已实现并通过 KeyboardCore 定向证据；Phase B cadence、Phase C 有限 failure family，以及 Phase D inventory/P0-style 摘要收敛已实现。完整 failure-injection matrix 与广泛 legacy cohort migration 不在本次完成主张中。
>
> **Current source of truth:** [`TD-013-DIAGNOSTICS-V1-P1 Assignment`](../assignments/td-013-diagnostics-v1-p1.md)。持久化、隐私与跨目标边界由 [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md)、[ADR 0003](../architecture/decisions/0003-shared-container-ownership.md) 和 [ADR 0007](../architecture/decisions/0007-full-access-and-privacy-boundary.md) 决定。

## Goal

把 P0 已有的本地、typed、bounded journal 补强为在长期运行和并发 lifecycle 下仍可解释的诊断能力：查询不会因段顺序而漏排或乱序，cursor 失效可见，retention 有受控触发与竞争证据，failure/drop 不会静默，legacy 日志收敛有可审计路径。

这不是功能遥测、全文日志系统或输入问题的替代品。基本输入与 RIME 行为始终优先于日志完整性。

## 已验证基线（2026-08-11，规划审计）

| Area | 已实现 | P1 缺口 |
|---|---|---|
| 查询 | `DiagnosticsJournalReader` 冻结 generation 后读完整 segments，在有限读取预算内按 ADR 0027 事件总序排序；cursor 有 `hasMore` / completed / invalidated / unavailable / budget 状态，UI 展示受控提示。 | 5 MiB 快照预算外不会返回假装严格排序的部分结果；它需要另立 Product 决策，不能改为无界读取。 |
| 生命周期 / retention | Main App 启动、进入 active 和诊断页刷新经 15 分钟合并 scheduler 触发现有 coordinator；Extension 不引用 scheduler。 | coordinator 的详细 report 尚未成为 UI 状态；本 P1 不因可见状态扩张而新增自由文本。 |
| health / drop | ingress 保持 256 条上限/suspend 摘要；writer 将明确 ENOSPC 映射为 `disk_full`，其它写入失败收敛为 `io_failure`。 | 未建立通用 FileSystem/lock fault-injection abstraction；现有 writer/reclaim 竞争测试仍是该边界的主要证据。 |
| legacy | v1 优先；`rime_diag_log` 只读回退不写入 v1；已建立 205 调用点 inventory，并收敛 P0-style 原文摘要。 | 其余 cohort 未迁移，旧回退不能直接删或自动迁入 v1。 |

上述事实以当前代码为准；技术债仅描述目标，不能替代每个 phase 开始前的复核。

## 不变量

1. Extension 热路径只构造有限 value-type event 并进入有界 ingress；不得读取设置、访问目录、编码 JSON、获取锁或等待 writer。
2. v1 永远只持久化允许的 `DiagnosticEvent.Code`、受控 metric/flag/reason 与既有固定身份/时间字段；没有 `String` payload、输入内容、候选正文或路径。
3. Main App 是 `Diagnostics/v1` 根目录、control generation、retention、migration 与删除的唯一 owner；Extension 不枚举、回收或删除共享目录。
4. 所有 active/open writer 的 append、lease 续约与 reclaim 继续共用同一 stable identity lock；没有锁就不 append、不回收，也不等待。
5. clear 的语义仍是“旧 generation 立即不可见”，不是等待每个 Extension writer 停止或物理删除其打开文件。
6. 诊断不可用只能损失可观测性；不得丢键、改变 composition、阻塞 UI 或触发 RIME 部署/修复。

## Phase A — 严格、可解释的查询

### Design

- 用冻结时的 `(generation, segment identity, byte watermark)` 构建 query snapshot；在 5 MiB 受控预算内只接受每段完整 JSONL 行。若任一完整 segment 会超预算，明确拒绝本次查询，不能返回部分排序结果。
- 对该有界完整快照按 ADR 0027 已定义的稳定事件总序（UTC 时间、单调时间、process instance、local sequence）排序，确保每页和跨页都是全局 newest-first，而不是“按文件逐段最新优先”。本次不引入更复杂的 streaming k-way merge；它会在以后 Product 需要超过 5 MiB 查询时才单独设计。
- cursor 必须有受控结果：`hasMore`、正常结束、generation 已推进、快照段已不可用/被 reclaim。UI 对后两者显示“日志已清空或已回收，请刷新”，不得把它们误作空结果。
- 仍保持每次 read 的事件数/字节上限；不把全量段或自由文本路径暴露给 UI，不将 cursor 持久化或跨 process 传递。

### Required automated evidence

- 两个 writer、相同 hour、多段交错时间的全局排序与无重复/无遗漏页。
- 边界相同时间的确定性 tie-break；partial tail 不进入结果。
- 分页期间 append 不混入冻结 query；clear / reclaim 后 cursor 的显式 invalidation。
- 5 MiB / 10,000 条复制快照仍只复制当前筛选结果，且不能绕过页水位。

## Phase B — Main-App-only retention cadence 与竞争

### Design

- 将 coordinator 触发点限制在 Main App utility context；采用可合并、可限频的 cadence（启动、进入可用的前台主 App 时以及诊断页显式刷新），不创建 Extension background work，也不在 UI 主线程等待完成。
- 每轮持续执行现有 “expired lease → 同 identity nonblocking lock → 锁内复核 → tombstone → recovered seal → revoke lease” 围栏；普通 retention 只删除 sealed/recovered 段，活动 open 段可使目录短暂超过容量上限。
- 为成功、busy、active、deferred I/O/retry 保留受控 report，供 Main App 诊断状态消费；report 不携带文件名、路径或任意 error 文本。

### Required automated evidence

- cadence 合并与限频，不因反复进入页面启动并发 reclaim。
- admission → suspend → append、reclaim 读 lease → writer 续约、busy lock、tombstone 后旧 writer、generation clear 等竞争均保守完成或跳过。
- 7 天和 100 MiB 策略按最旧 sealed 段处理；open/active 段不会因容量或过期观察被误删。
- 每个 tombstone、move、lease 删除和目录 I/O 失败都可重试且不导致活段消失。

## Phase C — 受控 health/drop 与故障注入

### Design

- 先定义有限 error family 到 `DiagnosticEvent.Reason` 的映射；若无法安全区分，使用受控的 unknown/unavailable family，绝不写 `NSError` domain、localized description 或路径。
- 把 ingress full、suspend、lock busy、writer reclaimed、App Group/root unavailable、directory/I/O/space 等情况统一到可合并的 health/drop 摘要。无法写 journal 时只在内存累计有限计数，下一次可写时先尽力报告；进程终止前的 tail 仍是明确 best-effort 损失。
- 故障注入 seam 覆盖 clock、file/atomic replace、lock、lease/control decode 与 writer admission；不以 sleep 或真实磁盘满作为唯一测试手段。

### Required automated evidence

- 每个允许 reason 的 renderer/编码/解码与“无自由文本字段”断言。
- ingress queue 满载、suspend、writer reclaim 后重建 identity、lock busy、root/control/lease/写入失败的受控行为。
- 不可用期间不会递归产生无界 health event、不会同步阻塞 record，也不会丢失/改变键盘业务 event。
- 恢复后只能看到受控计数/原因，不能从 event、导出或 UI 推导用户文本。

## Phase D — Legacy producer cohort 审计与受控迁移

### Design

1. 先以调用点为单位建立 inventory：producer、当前 payload 类型、可能隐私类别、归属 domain、替代的 typed code/field、测试和移除条件。
2. P0 已确认的 content-free lifecycle/首屏/KBDVIS/RIME owner/performance 路径保持在 v1；其余 producer 不因“兼容”而桥接到 v1。
3. 仅迁移已通过 allowlist/privacy review 的 cohort；自由文本改为固定 event code + enum/count/duration/flag，或保持 legacy/read-only 并列为明确 debt。
4. 只有 inventory 全部关闭、迁移证据完成、Product 明确接受 legacy 删除后，才可另立任务移除 `rime_diag_log` 回退。

### Required automated / review evidence

- inventory 逐项可追溯到当前调用点，不用全局 sanitizer 替代审查。
- 每个迁移 cohort 有新旧行为、隐私字段、测试 target 和 migration stop condition。
- 静态/行为检查证明 v1 API 不接受 `String` payload；导出与搜索不读取 legacy 原文作为 v1 数据。

## 执行顺序与门禁

1. **实现前置已满足：** Product Lead 已指定 primary Domain Owner、独立 Architecture/Quality Reviewer 并授权写代码；Architecture reviewer 仍须在交接时确认 Phase A 的 cursor result 与 Phase B cadence 不改变 ADR 0027 contract，或要求 ADR amendment。
2. **A → C：** 先确保 query semantics 和 health failures 有可测的 typed contract，再接 UI；每 phase 通过受影响 target 的定向测试。
3. **B：** 使用 A/C 的 contract 做 retention/reclaim 竞争证明；Main App 侧 UI 只消费受控摘要。
4. **D：** 先 audit，再逐 cohort 迁移；不得与“删除 legacy”混在同一变更。
5. **每个可合并变更：** 按 `AGENTS.md` 跑 Swift format、KeyboardCore、RimeBridge、App/Keyboard 测试、Debug/Release build；Architecture 和 Quality 独立复核后才请求 Product Gate。

## Documentation Impact Review

| Document | P1 实现时的动作 |
|---|---|
| ADR 0027 | 每 phase 复核；只有 durable contract 改变时作 amendment/新 ADR，不能悄改已接受决定。 |
| `shared-container-and-rime-lifecycle.md` | 若 cadence、lease/reclaim 或 suspend 可观察语义改变则更新。 |
| `DEBUGGING.md` | 更新 cursor invalidation、health/drop 与恢复时的安全诊断步骤。 |
| `PRIVACY_POLICY.md` / `RELEASE_CHECKLIST.md` | 复核 no-upload、内容无关、保留/清理和导出边界；若用户承诺改变才更新权威表述。 |
| `PERFORMANCE_BASELINE.md` | 记录诊断开关条件和任何可测 hot-path evidence；Debug 观察不作为 Release 结论。 |
| `TECH_DEBT.md` / Assignment / plan | 每 phase 更新现状、残余与 handoff；P1 完成后再决定 TD-013 是否关闭或拆分。 |

## Explicit non-goals

- SQLite、全文索引、无限历史、远程支持上传或自动分享。
- 为诊断迁就键盘输入正确性、RIME session 生命周期或 Main App/Extension 所有权。
- 将任意 legacy 字符串 “sanitize” 后写入 v1。
- 将当前计划或 P0 历史证据表述为已完成 P1。
