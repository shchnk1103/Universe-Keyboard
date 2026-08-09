# Assignment: DIAGNOSTICS-OBSERVABILITY-001 — 企业级本地诊断日志

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | P0 实现冻结：v1 journal、查询/分页 UI、安全回收、Extension lifecycle health、Debug 高保真时窗与默认关闭的到期提醒已交付；本轮进入本地质量门与 PR |
| **Non-claims** | 不宣称 P1 的严格全局分页、周期性 retention、完整失败矩阵或 legacy producer 完整迁移；不宣称 Release 性能、全部真机异常已捕获或 Product Gate 已通过 |
| **Next** | 完成本地 CI 等价质量门、独立复核与 PR；P1 仅在新授权下按 [TD-013](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化) 处理 |
| **Residuals** | P1 技术债：[TD-013](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化)；本轮真机仅为 Device-attested P0 行为证据，不构成 Release/Product Gate |

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner 认可“按小时分段、7 天或 100 MiB、普通日志默认关闭、高保真首屏诊断 30 分钟自动关闭”的产品合同，并授权按 KOS 2.1 自主推进，`2026-08-09 Asia/Shanghai`。
- Product Approver: Human Product Owner / Product Lead

## Boundary

- Scope:
  1. 以 App Group 的本地、版本化分段日志替代 `rime_diag_log` 的 500 条 `UserDefaults` 环形文本；主 App 与 Keyboard Extension 不得竞争写入同一段文件。
  2. 提供主 App 的增量预览、大小写无关全文搜索、分类/严重级别/时间筛选、当前查询快照复制和安全清空。
  3. 增加 Debug-only、手动开启、30 分钟自动关闭的首屏高保真诊断，记录一次唤起前 1 秒内的内容无关视觉状态、候选来源和触摸终端；用户可默认关闭地选择在到期时接收一条不含日志内容的本地提醒，诊断页与全局通知页共用该选择。
  4. 实施 7 天或 100 MiB 的目录级保留策略、可观测的有界队列丢弃、代际清空与故障降级。
  5. 迁移现有真机证据导出路径，并更新唯一权威的架构、调试、隐私、性能与发布资料。
- Non-goals:
  - 不上传、同步、自动分享或分析诊断日志。
  - 不记录键值、raw/preedit、候选文字、宿主文字、词典、宿主 App 身份、YAML 内容、第三方 RIME 原始日志或任何可识别输入内容。
  - 不改变 KeyboardCore 输入语义、RIME 方案、部署所有权或普通键盘视觉行为。
  - 不承诺日志百分之百耐久；Extension 终止时未刷新的 best-effort 尾批可以丢失。
  - 不把无限保留、同步磁盘写入或全量内存加载作为实现手段。
- Required Inputs: `docs/architecture/decisions/0003-shared-container-ownership.md`、ADR 0007、ADR 0027（Accepted; P0 implementation frozen）、`DEBUGGING.md`、`PERFORMANCE_BASELINE.md`、`RELEASE_CHECKLIST.md`、`PRIVACY_POLICY.md`、共享容器生命周期文档，以及 `KEYBOARD-STARTUP-PERF-001` 的内容无关真机日志。

## Assignment

- Domain Owner: 📱 App & Data Operations Maintainer
- Executor: Current Codex agent
- Participating Owner: ⌨️ Keyboard Experience Maintainer（Extension 事件生产与首屏高保真诊断）
- Architecture Reviewer: 🏛️ Architecture & Knowledge Steward（独立于实现的 review）
- Quality Reviewer: 🧪 Quality, Performance & Release Maintainer（独立于实现的 review）
- Environment Executor: Current Codex agent（单元/Simulator）；Human Product Owner（后续真机验收）
- Human Dependency: 人类只执行已声明的真机场景和 Product Gate，不承担日志内容审查或实现决策。

## Gates

### Entry Criteria

- [x] 产品保留、默认开关和本地-only 边界已明确。
- [x] 现有 writer/UI/证据导出路径和跨进程丢失风险已完成只读审计。
- [x] 已确认这是 App Group 文件所有权、隐私和 Extension 热路径的跨目标变更，需 ADR。
- [x] 已为该工作项留出 Active Work 容量，未扩大已 Completed 的启动性能任务。
- [x] ADR 0027 的 `Diagnostics/v1` 目录 owner、clear generation/lease 协议与 Extension suspend 语义已通过独立 Architecture review（2026-08-09；复审确认 process-instance fencing、stable lock 与 tombstone 回收顺序）。

### Exit Criteria

- [ ] 任何键盘热路径都不读取 `UserDefaults`、枚举目录、JSON 编码、格式化日期、写磁盘、等待 actor 或等待 file coordination。
- [ ] 每个 writer 只追加自己拥有的小时/体积分段；读取、保留、清空和迁移不会使两个目标的记录静默互相覆盖。
- [ ] 主 App 在诊断页可见时在定义的实时窗口内增量显示；搜索、过滤与复制共享同一查询水位，复制不会混入之后产生的新日志。
- [ ] 目录总量按 7 天或 100 MiB 清理最旧可安全删除分段；容量/权限/部分行/进程终止都会降级为内容无关可诊断状态，不阻塞输入。
- [ ] 清空先推进 generation；旧 Extension writer 不能让已清空的记录重新进入视图或导出。
- [ ] 首屏高保真模式以 `appearanceID + actionSequence + revision` 将触摸、输入动作、owner 发布、MainActor apply、候选真实显示/消失、缓存与生命周期清理关联起来，但不含输入内容。
- [ ] 退出/挂起不能同步刷盘；若 best-effort 尾批被舍弃，必须出现可查询的内容无关 suspended/drop 健康结果，不能静默消失。
- [ ] 旧自由文本日志进入新 journal 前完成 allowlist 审查；完整 YAML 与第三方 RIME 原始日志只能产生受控状态/大小/计数摘要。
- [ ] 复制使用同一查询水位且有 5 MiB 或 10,000 条上限；超限必须要求缩小查询或走显式导出，不能使主 App 全量加载。
- [ ] 迁移、并发 writer、部分写入、保留、清空竞争、搜索/复制快照、队列过载、App Group 不可用和旧 evidence 查询均有自动化覆盖。
- [ ] 完成本地 CI、独立 Architecture/Quality review，以及声明条件的真机三档（关闭/普通/高保真）性能与功能证据。

### Stop Conditions

- 任何字段、导出、迁移或错误路径可能记录或离开设备的内容级键盘数据。
- 需要在 Extension 按键热路径执行同步 I/O、目录扫描、跨进程锁等待，或通过不安全 Swift 并发隔离绕过限制。
- ADR 0003 的共享文件所有权、ADR 0007 的 Full Access/隐私边界或现有 RIME deployment/session 边界发生冲突。
- 不能证明清空不会被旧 writer 恢复，或保留任务可能删除活动段。

## Handoff

- Handoff Target: 独立 Architecture review → App/Data 与 Keyboard UI 分区实现 → 独立 Quality review → Human Product Gate。
- Required Handoff Content: 事件字段白名单、目录/代际协议、热路径成本、查询水位语义、失败/丢弃计数、自动化证据、真机环境与未验证风险。
- Revalidation Trigger: 新增日志字段、改变保留阈值/默认开关、引入新 App Group 文件、改变 Full Access 降级、改变复制/导出或任何 off-device 数据路径。

## History

- 2026-08-09: 初次独立 Architecture review 关闭目录 owner 与 suspend/degrade P0，要求补齐 generation/lease 的可判定回收围栏。
- 2026-08-09: 复审确认不可复用 `processInstanceID`、稳定 `.lock`、锁内 append/reclaim 复核及 tombstone 顺序能够阻止慢恢复 writer 重写旧段；仅通过 Architecture Entry Gate，不构成实现、Quality、真机或 Product Gate 结论。
- 2026-08-09: 隐私审计确认现有 206 个自由文本 producer 不能桥接到 v1；已先移除第三方 RIME 原始日志、完整 YAML、Lua smoke 样本和若干 `localizedDescription` 的落盘路径。v1 仅接收 typed allowlist，legacy 迁移按 cohort 进行。
- 2026-08-09: `KeyboardCore` 已有 `DiagnosticsJournalWriter` 的 control generation/独占 JSONL 基础及自动化覆盖；未接入热路径或 retention，不应视为可用的用户诊断功能。
- 2026-08-09: 增加当前 generation 的 512 KiB 有界 JSONL 尾读；它忽略尾部半行并提供 immutable snapshot，尚未接入 SwiftUI 或 legacy migration。
- 2026-08-09: Main App 已通过 v1 adapter 每秒刷新 immutable snapshot，提供大小写无关搜索和 10,000 条/5 MiB 复制上限；v1 空时仅只读回退 legacy，legacy 不会迁入 v1。
- 2026-08-09: `DiagnosticsJournalIngress` 以 `Mutex` 管理最多 256 个 typed event，并通过单一 utility 批次转交 journal；它尚未进入 `Logger`，以避免在 suspend/drop health 合同未完成前改变 Extension 生命周期。
- 2026-08-09: writer 为每个 batch 在稳定 identity lock 内重读 generation、续约带单调 fence 的短 lease，并拒绝当前 generation 的 reclaim tombstone；Extension root 缺失时 append fail-closed，不会创建共享 root。ingress suspend 会取消尚未开始的 delayed tail 并计数，恢复 health event 尚未接入，故仍不满足 Exit 条件。
- 2026-08-09: 新增独立 `DiagnosticsJournalRuntime`，不接受自由文本。Keyboard Extension 仅在可见/消失边界写入内容无关 presentation 事件；suspend 尾批的计数会在同一 process 恢复后以 `.journalResumed + dropped_event_count + suspended` 尽力补报。Main App 在 utility task 创建 journal root；设置页不再为显示 legacy 条数而在主线程读取全文。
- 2026-08-09: Debug 设置新增“首屏高保真诊断”短时采样；它以 App Group 绝对过期时间限定 30 分钟，Keyboard 只在可见性边界读取并在内存自动失效。高保真记录 content-free touch terminal、按键高亮/候选/可见 cell 数、revision、session epoch 和 appearance ID，不记录键值或文本。
- 2026-08-09: 响应式 RIME owner 回调在 `syncUI` 前写入 `rime.owner.published`，MainActor 应用后写入 `ui.applied`；两者共享当前 appearance ID，并只包含 revision、owner epoch、候选和可见 cell 的结构计数。
- 2026-08-09: 候选 collection 的 `willDisplay` / `didEndDisplaying` 记录内容无关的候选总数、可见 cell 数、revision 与可见状态，不保存 index 或文字；它为“候选闪现/消失”提供 UIKit 真实显示终端。
- 2026-08-09: v1 Main-App 默认查询水位从 500 条 / 512 KiB 提升为与复制安全上限一致的 10,000 条 / 5 MiB；这不限制文件保留，超出水位的历史记录等待 offset pagination 实现后按页读取。
- 2026-08-09: writer 在跨小时、容量或 clear generation 的批次边界封存自己的关闭段。仅 Main App 的 utility coordinator 会枚举目录：它对过期 lease 取得同一 identity 的非阻塞 lock，锁内复核 control、generation、lease/fence 与 tombstone 后，按 tombstone → recovered/sealed → revoke lease 顺序回收；普通 retention 只删除 sealed 段，执行最先触发的 7 天或 100 MiB 策略。锁忙、格式异常和任何 I/O 失败都会保守跳过并计入 report。自动化覆盖过期回收、旧 writer 拒绝、时间/容量保留及锁忙跳过；尚未完成完整竞争/故障矩阵或 Quality Gate。
- 2026-08-09: Product Owner 追加授权默认关闭的 Debug-only 高保真到期提醒。它属于主 App 统一通知模型，采用固定 pending identifier 与绝对过期时间；诊断页、通知与提醒页、采样窗口关闭和全局通知关闭均同步安排或取消，不将通知职责带入 Keyboard Extension。
- 2026-08-09: Product Owner 决定在 P0 实现范围收口；严格全局分页、周期性 retention、完整 health/竞争矩阵与 legacy producer 迁移不再作为本轮实施范围，统一移入 [TD-013](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化)。Assignment 保持 Active，直至质量、发布和人类 Product Gate 完成。
