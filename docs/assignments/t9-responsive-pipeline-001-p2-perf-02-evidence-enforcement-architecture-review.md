# 独立 Architecture 复审：T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02 Evidence Enforcement

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立、只读） |
| 复审日期 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | [`P2-PERF-02 Evidence Enforcement`](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement.md) |
| 复审基线 | 当前 worktree tip `3585a54`；工作树含其他任务的 ambient 改动，本复审不归因、不覆盖 |
| 关联合同 | [`P2-PERF-02 Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)；[`P2-PERF-02 Release-like Assignment`](t9-responsive-pipeline-001-p2-perf-02-release-like.md) |
| 复审范围 | 最新 Evidence Enforcement 子 Assignment 的 allow-list、validator、owner session snapshot、geometry retry 和默认 gate/ADR 边界；**不采用历史 B Architecture review 作为最新结论** |
| 独立运行 | `git diff --check` 通过；本次尝试的 `swift test --package-path Packages/KeyboardCore --filter T9ResponsiveEvidenceValidatorTests` 被本机 SwiftPM manifest 的 clang module-cache / sandbox 权限阻断。9/0、8/0、10/0、871/0 为 Executor 已提交的冻结结果，不冒充本次独立重跑 |
| Architecture 结论 | **Bounded Pass with conditions**：诊断取证基础设施的隔离形状与 gate 边界可交给 Quality；P2-PERF-02 证据仍不得标为 `Complete` |
| P0 / P1 / P2 / P3 | **0 / 0 / 6 / 1** |
| 治理结论 | ADR 0025 仍为 `Proposed`；不形成 Product Gate、R6、Release 性能通过或默认开启结论 |

## 1. 复审边界与方法

本次只读审查以下最新材料与代码：

1. [`Evidence Enforcement Assignment`](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement.md)；
2. [`Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)；
3. `T9DevicePreflightEvidenceLineFilter`、`T9ResponsiveEvidenceValidator`；
4. `ThreadAffineRimeSpike` / `ThreadAffineRimeSession` 的 owner 与 Sendable session snapshot；
5. `KeyboardViewController+DevicePreflight` 的 geometry retry、App Diagnostics 的过滤接线；
6. [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) 的 Proposed/default-off 约束。

我没有修改生产逻辑、测试、RIME/Lua、项目默认 flag 或现有历史 B evidence。当前工作树是混合状态，故本复审把“代码结构已检查”“Executor 的测试快照”“真实安装/设备运行”分为三种不同证据层。

## 2. 已证明的架构部分

### 2.1 诊断导出 allow-list 已包含目标 marker

`T9DevicePreflightEvidenceLineFilter.retains` 统一保留 `T9DEVICE`、`T9GEOM`、`T9SEG`、`T9ARM`、`T9RESP` 与 `SLOW RIME`；App Diagnostics view 通过该同一函数过滤持久化日志，避免旧的 App-local allow-list 把 engine-category 的 `PATH/READY` 丢掉。对应回归覆盖了 `T9RESP marker=READY`、`SLOW RIME`、`T9SEG` 与普通文本排除。

这证明“过滤规则的源代码与 KeyboardCore 回归测试已经同源”，但不自动证明设备本次运行实际写入并持久化了这些行（见 P2-EV-02 与 P2-EV-01）。

### 2.2 thread-affine owner 的 session snapshot 隔离形状正确

静态检查得到的安全链条如下：

- `ThreadAffineRimeEngineBootstrap` 只跨隔离域传递 `Sendable` 配置 recipe；
- `RimeEngine` 在 `runOwnerLoop` 的专用 `Thread` 闭包中创建、调用并释放；
- owner 在同一线程读取 `RimeSessionDiagnosticSnapshot`，再将 `UInt64/bool` 组成的值快照写入 `Mutex` 状态和 `Sendable` result；
- MainActor 通过 `coordinator.diagnosticSessionSnapshot` 读取值，不通过 snapshot API 触碰 live engine；
- 在复审对象与其 bootstrap 中未发现 `@unchecked Sendable`。

因此，这个子 Assignment 的 isolation proof 形状与 ADR 0025 §7 / §10.4 一致。Executor 报告的 `ThreadAffineRimeWireTests 8/0` 与 `ThreadAffineRimeSpikeTests 10/0` 也覆盖了非零 fake session snapshot、150ms+ owner 阻塞时仍可 enqueue、顺序和 epoch 丢弃；但本次无法因本地测试环境权限问题独立重跑这些结果。

### 2.3 geometry retry 的意图符合 fail-closed 方向

`recordDevicePreflightExecutionGeometryBeforeFirstT9Key` 只有在 `makeDevicePreflightGeometry()` 成功后才把 `devicePreflightDidRecordExecutionGeometry` 置为 `true`；失败时写出 `status=unavailable` 并保留下一次 layout/key 的重试机会。geometry digest 包含 canonical token、portrait screen-space、keyboard envelope 和八个 T9 slot，且不会把 `run=invalid` 直接当作 digest。

这比“首个过早 layout 永久冻结失败”更符合合同的 reload/fail-closed 设计；但 validator 对多次 digest 和 transient unavailable 的最终判定仍有缺口，见 P2-EV-03/P2-EV-05。

### 2.4 gate 与 ADR 边界没有被本子 Assignment 偷换

当前 Evidence Enforcement 文档明确：

- 不修改用户输入语义、RIME/Lua、auto-anchor 次数或 Release 默认 flag；
- thread-affine owner 仍是诊断/Spike 形态，不能被写成真实 librime 生产接线完成；
- 普通 gate-off 路径、历史 B `Partial` 结论、真实设备/内存/jetsam/Release RC 未验证项均保留。

本次静态检查没有发现把 `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` 或 auto-anchor `*_ENABLED` 写入项目默认配置的证据。故没有 P0/P1 治理越界。

## 3. 未证明的部分与架构残余

### P2-EV-01 — 最终 hardening tip 没有 runtime/artifact 闭环

Assignment 的验证快照说明：最后一次 validator run-binding hardening 后只完成 KeyboardCore 编译/测试覆盖，没有重新生成包含该最后微调的 App/Extension artifact；本子 Assignment 也没有新 iPhone 13 Pro 安装、运行或导出。此前的 Release generic compile 与字符串扫描只能证明条件编译代码存在，不能证明：

- 已安装二进制真的产生 `T9RESP PATH/READY`；
- owner session snapshot 在真实 RIME session 上为非零且稳定；
- geometry retry 在 UIKit reload 时序中能得到同 token/digest；
- allow-list 与日志持久化在扩展进程边界上没有丢行。

这是证据缺口，不是要求本次修改生产逻辑的 P1；在新 artifact/设备运行前，P2-PERF-02 只能是 `Partial`/未完成交接。

### P2-EV-02 — PATH/READY 并非和 T9DEVICE 一样的 mandatory persistence

`Logger.devicePreflightPerformance` 通过 `bypassCategoryFilter: true` 写 mandatory content-free marker；但 `KeyboardViewController+Bootstrap` 的 `T9RESP PATH` 和 `READY` 仍调用普通 `Logger.shared.info(..., category: .engine)`。`LoggerWriter` 在 `logging_enabled` 或 engine category 关闭时会丢弃普通记录，App 侧 allow-list 只能过滤已经持久化的行，不能把丢失的 PATH/READY 补回来。

因此，Acceptance “internal content-free export 必须含 PATH/READY”目前依赖运行前打开 logging/category，而不是由 Evidence Enforcement 自身强制保证。Quality 应要求一个明确策略：要么 PATH/READY 也走受控 preflight mandatory channel，要么 Run Header/导出步骤明确并验证 logging/category enabled；否则不能把“allow-list 保留”扩大成“设备导出必有”。

### P2-EV-03 — geometry reload/retry 的最终合同仍不严格

validator 将所有 `prepared` digest 放入 Set，将所有成功的 `execution` digest 放入另一 Set，再以集合相等判定匹配。这会允许同一 run 在多次 UI reload 后出现多个 digest，只要 prepared/execution 两边最终集合相同就报告 `geometryDigestMatches=true`；它没有证明首键使用的 geometry 与唯一 prepared context 相同。

此外，执行 geometry 过早失败时会留下 `phase=execution status=unavailable`；即使后续 retry 成功，validator 仍把 `execution-geometry-unavailable` 留在 reasons 并给出 `Partial`。这符合“不把不可用写成有效”的保守方向，却没有表达“transient retry 后已恢复”的终态，容易把可重试的边界误判为永久缺口。

Quality 应增加多 digest、`unavailable → success`、reload 后新 token/旧 token 的负样本，并冻结终态规则（例如单一 digest、明确 retry 事件与最终 status），再决定 Complete/Partial 的含义。

### P2-EV-04 — `T9RESP` readiness/path 与运行身份绑定不足

validator 对 `T9RESP` 只检查 `marker=PATH` 的 `path` 值和是否见到任意 `marker=READY`；没有校验 fixture、`dualGateRequested/dualGateActive`、READY 的 `bootstrap=config-only session=owner-thread` 字段，也没有把这些 marker 与 expected run token 绑定。实际 `PATH/READY` 文本当前没有 run 字段，这意味着一个旧 run 或错误 gate 状态的 engine marker 可能与当前 run 的 39 条 `T9SEG` 混合后仍满足 PATH/READY 布尔条件。

这不是当前生产隐私泄漏，但会削弱“导出属于本轮 B arm 且 owner ready”的证据强度。应将 fixture/gate/readiness 作为 expectation 或严格的 marker schema，并在历史日志混入测试中 fail closed。

### P2-EV-05 — geometry digest/schema 校验允许 malformed positive

当前 parser 只要看到 `phase=prepared/execution` 与 `digest=` 就加入集合；空 digest、非 SHA-256 形状或任意 ASCII digest 都可能在两边相同时使 `geometryDigestMatches` 为真。合同要求的是同 token/digest 的可验证 geometry，不是“两个未校验字符串相等”。

同一类 schema 缺口存在于 marker 的字段完整性：部分 `T9SEG` 数值字段只在 action/event/session 上做最小解析，validator 没有为全部 content-free timing/integrity 字段定义版本化 schema。对本子 Assignment 的主目标，至少应拒绝空/非法 digest，并对缺少必要 geometry phase 字段保持明确 `Partial`。

### P2-EV-06 — owner readiness timeout 被忽略，READY 可能早于 owner ready

`ThreadAffineRimeSessionCoordinator.startOwner()` 调用 `waitUntilReady(timeout:)`，但忽略了返回值；bootstrap 随后只依据 coordinator/bridge 对象是否存在就记录 `T9RESP READY`。若真实 RIME engine 初始化超过两秒或构造失败，日志仍可能先宣称 READY，而 session snapshot 尚未可读或 owner 已终止。

这不会把 live engine 跨线程，但会破坏 readiness marker 的语义。应让 readiness 结果成为 PATH/READY 的显式状态，或在超时/构造失败时输出 fail-closed marker，并由 validator 将其判为 `Partial/Blocked`。

### P3-EV-07 — allow-list 是 substring 规则，防伪边界主要依赖后置 validator

`T9DevicePreflightEvidenceLineFilter` 使用 `line.contains("T9SEG ")` 等 substring，而不是版本化 marker 的起始/字段解析；它因此适合轻量导出，但不能单独保证“只保留合法 marker”。当前设计已明确 privacy validation 是独立步骤，且 validator 会扫描已保留行，所以这不是 P1；建议补 marker-shape/ASCII 负样本，避免未来把 filter 输出误当成已验证证据。

## 4. Quality 交接判定

**可以交给独立 Quality 复审，但交接范围必须写成 bounded implementation review。** 原因是本次没有 P0/P1：

- owner 只在专用线程创建/调用/释放 engine 的形状清晰；
- snapshot 是 Sendable value，未使用 `@unchecked Sendable`；
- default gate/Release/ADR/Product 边界没有越权；
- allow-list、validator、geometry retry 都有可读实现与回归入口。

Quality 不应据此宣布 Evidence Enforcement 或 P2-PERF-02 `Complete`。Quality 复审至少需要：

1. 在可写的 Swift/Xcode 环境重跑 validator、ThreadAffine wire/spike 与 KeyboardCore 全量，并记录与 tip `3585a54` 的绑定；
2. 为 P2-EV-02–P2-EV-06 增加或明确拒绝条件的 focused regression；
3. 复核真实导出时 logging/category、PATH/READY、session snapshot、geometry 和 run identity 是否闭合；
4. 保持历史 B evidence 为 `Partial`，不要以 validator 能判定为设备已满足；
5. 将真实 librime、iPhone 13 Pro、Extension jetsam/memory、iOS 26.0 Release RC 与 Product Gate 留在未验证清单。

如果 Quality 选择先做纯代码/测试复审，可以给出“Pass with conditions”；若要给出 P2-PERF-02 的 Complete 或 off-main 产品收益结论，必须另行获得真实 artifact/device 授权与证据。

## 5. ADR 0025、默认 gate 与停止点

本复审不接受 ADR 0025，也不修改 ADR 0004 的生产约束。ADR 0025 仍为 `Proposed`：

- Release 默认仍是 gate-off、ADR 0004 等价路径；
- thread-affine owner 与 `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` 仍只属于显式内部诊断/Spike arm；
- 不能把本子 Assignment 的 fake/diagnostic tests 或字符串扫描写成真实 librime 生产迁移完成；
- 不授权 R4-B 生产接线、R5 真机 A/B、R6、Product Gate、Release default-on 或发布声明。

本 Architecture 角色到此停止，等待 Quality 的独立判断；不在本 review 中修复上述 P2/P3，也不改写历史 B evidence。

