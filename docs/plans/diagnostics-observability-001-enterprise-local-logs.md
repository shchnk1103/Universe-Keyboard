# DIAGNOSTICS-OBSERVABILITY-001 实施计划

> **Lifecycle:** Archived
>
> **Closure:** `2026-08-09 Asia/Shanghai` — P0 已由 PR #57 合并并通过 CI。本计划不再是当前开发指引；人类 Product Gate 仍待完成，P1 follow-up 见 [TD-013](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化)。
>
> **Current source of truth:** `docs/assignments/diagnostics-observability-001.md`；持久化与跨目标边界由 ADR 0027 决定。本文保留为已完成 P0 的阶段历史。

## Goal

把诊断从 500 条 App Group `UserDefaults` 文本升级为本地、可检索、可保留、内容无关且不阻塞键盘的事件 journal；首要用途是让一次短暂的键盘视觉异常可以被归因，而不是收集用户输入。

## Phase 0 — Contract and Architecture Review（completed）

- [x] 冻结事件字段白名单、目录 layout、writer identity、clear generation、segment seal/lease、保留和 query snapshot 语义；明确 UTC/单调时间和 `appearanceID + actionSequence + revision` 的关联协议。
- [x] 冻结 `control.json` 的 Main-App 单写者、writer 独占段、lease 到期恢复、generation 可见性切换以及 Extension suspend 后在下次恢复补报 drop 的语义。
- 审计完整 YAML、第三方 RIME 原始日志和任意字符串调用点；它们只能转换为受控摘要，不能进入长期 journal、搜索或复制。
- [x] 已优先移除第三方 RIME 原始日志、完整 YAML、Lua smoke 样本和已识别 `localizedDescription` 的旧日志落盘；其余自由文本 producer 不桥接到 v1，按 cohort 审计/迁移。
- [x] 独立审查 ADR 0003/0007 与 ADR 0027，确认 Extension 只写 runtime-owned bounded diagnostics，main App 拥有迁移、查询、清理和导出。
- 停止：任何方案要求 Extension 共享 append 文件、同步等待 I/O、记录内容或上传。

## Phase 1 — Core Journal and Migration

- [x] 建立 `Diagnostics/v1` typed event、Main-App control generation 与每 process 独占 JSONL 段的基础实现；清空先换 generation，旧段不会进入新 generation。
- [x] 建立最多 256 条的 typed bounded ingress；热路径只做 `Mutex` 入队，分类开关、root 解析和 writer 调用均在 utility 阶段执行，且同一时刻只允许一个写入批次。
- [~] stable identity lock、短 lease fence、writer seal、Extension suspend 的未开始尾批丢弃及 Main-App reclaim coordinator 已实现并有定向测试；已具备 suspend-resume health event，尚未实现其他 failure/drop 原因或完整键盘因果链。
- [x] `DiagnosticsJournalRuntime` 已接入 Keyboard presentation、suspend-resume health、Debug-only 30 分钟高保真窗口、owner publish → MainActor UI apply 因果链与真实候选 cell display/end-display terminal；仅在可见性边界解析开关/root，且 legacy `Logger(String)` 不会写入 v1。
- 设计旧 `rime_diag_log` 的一次只读 migration 和后续移除路径；迁移失败必须保留 legacy 数据且不影响输入。
- 测试：编码/解码、partial tail、轮转、writer overload、generation clear、App Group/memory/disk failure。

## Phase 2 — Main App Repository and UI

- [x] 提供仅查询当前 generation、受 5 MiB / 10,000 条查询水位限制的 Core 尾读和 immutable snapshot；尾部部分 JSONL 行被忽略。该水位不限制文件保留。
- [x] Main App 通过 Core reader actor 在后台读取当前 generation；诊断页可见期间以约一秒 cadence 刷新 immutable snapshot，并提供大小写无关搜索。
- [x] 复制使用当前筛选结果，设 5 MiB 或 10,000 条上限；超限提示用户缩小筛选范围。迁移期间 v1 为空时只读回退 legacy，legacy 不会进入 v1。
- [ ] 以 segment+offset watermark 支持连续分页；设置页只读取后台摘要而不读取全文。
- 测试：筛选、搜索、分页、刷新、复制快照、清空竞争、legacy evidence/preflight 查询迁移。

## Phase 3 — Keyboard Visual Provenance

- 在 Debug-only 高保真窗口中为每个 presentation 分配关联 ID。
- 捕获首秒显示帧、按键高亮计数、Core/缓存/可见 cell 数、候选渲染来源和内容无关触摸终端。
- 以 `appearanceID + actionSequence + revision` 关联 touch、owner publish、MainActor apply、candidate `willDisplay`/`didEndDisplaying` 与清理。
- 测试：窗口自动失效、无输入内容字段、异常帧可由 lifecycle/renderer/touch 关联；普通模式不产生逐帧事件。

## Phase 4 — Retention, Review and Device Evidence

- [x] 主 App 启动后的 utility task 执行 7 天或 100 MiB 的异步保留；活动 open 段不得被删除，过期 lease 须经同 identity lock/tombstone/recovered-seal 围栏后才可转为删除候选。
- [ ] 将 journal unavailable、锁忙、I/O 失败和有界 ingress 满载接入受控 health/drop 事件；容量紧张时以受控 drop 降级。
- 更新共享容器、调试、隐私、性能、发布资料和 Release checklist。
- 验证：完整本地 CI；独立 Architecture/Quality review；声明设备上的日志关闭、普通模式、高保真模式的冷启动、首键、连续输入、内存和 host/lifecycle 场景。

## Non-goals

- 不建立网络上传、远程支持通道、SQLite 全文索引或无限导出。
- 不以日志替代 Instruments、真实设备证据或用户的 Product Gate。
