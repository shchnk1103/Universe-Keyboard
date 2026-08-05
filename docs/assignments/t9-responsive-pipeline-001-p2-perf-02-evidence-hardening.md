# Assignment: T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02 Evidence Hardening

Policy version: 1.0.0
Lifecycle status: **Reviewed — Pass with conditions; runtime evidence open**
Date: 2026-08-02 Asia/Shanghai

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner authorization in the active Codex task,
  “按推荐方案执行 Evidence Hardening”，2026-08-02 Asia/Shanghai
- Product Approver: Human Product Owner / Product Lead
- Parent Assignment: [`P2-PERF-02 Evidence Enforcement`](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement.md)
- Evidence Contract: [`P2-PERF-02 Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)
- Architecture Boundary: [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md),
  remains `Proposed`

## Boundary

### Scope

诊断/证据层 hardening，仅覆盖 Architecture 与 Quality 复审共同提出的 P2-EE-01 至
P2-EE-06 条件：

1. 让显式 preflight 的 PATH/READY 进入 mandatory content-free persistence，普通
   gate-off 路径保持原行为；
2. 为 PATH/READY 建立 `schema=v1`、带 run identity 的 marker schema，校验 fixture、gate
   状态、bootstrap 和 owner readiness；
3. 收紧 geometry digest/schema 和 reload retry 的最终状态判定；
4. 让 owner readiness timeout 产生显式 fail-closed 状态，不再忽略 timeout 返回值；
5. 补纯 validator 的负样本和专项回归；
6. 在最终 hardening tip 上重新生成 unsigned generic app/extension artifact，记录
   source/build/hash 证据。

### Non-goals

- 不修改输入语义、候选排序、RIME/Lua、事件保序合同或默认 gate。
- 不把真实 `RimeEngineImpl` 接入 Release 默认路径，不接受 ADR 0025。
- 不进行 iPhone 13 Pro 安装、人工输入、日志导出、A/B、jetsam/内存或 Product Gate。
- 不修改历史 B evidence 的 `Partial` 判定，不补造缺失的 Human/device evidence。
- 不使用 `@unchecked Sendable`、unsafe actor escape、坐标自动化或破坏性清理。

## Frozen Product decisions

Product Lead 已确认以下推荐方案；这些决定只适用于显式诊断/preflight，不改变普通路径：

1. **PATH/READY persistence**：仅在显式 preflight 编译/运行条件下使用
   `devicePreflightPerformance` mandatory channel，普通路径继续使用普通
   engine logger。
2. **run-bound marker schema**：PATH/READY 携带本轮 run token，并强制
   `schema=v1`、`fixture=T9RESP-R5P`、requested/active gate、
   `bootstrap=config-only`、`session=owner-thread`。
3. **geometry retry terminal state**：采用“同一 run 只接受最终唯一的有效
   prepared/execution digest；此前 `unavailable` 在后续成功后不再单独造成 Partial；
   最终没有有效 execution 则 Partial”。
4. **owner readiness failure**：timeout/owner failure 输出明确的
   `NOT_READY`/fallback marker，validator 判为 Partial，不伪造 READY。

本 Assignment 已完成 bounded 实现与独立复审；仍受以下 Scope、Stop Conditions 和未执行
运行证据边界约束。

## Assignment

- Domain Owner: 🧪 Quality, Performance & Release Maintainer
- Executor: Current Codex task（仅诊断/证据代码、测试和 artifact 记录）
- Environment Executor: Not Applicable（本子 Assignment 不进行设备安装/运行；generic
  build 仅在本地 Xcode 可用时执行）
- Human Dependency: Human Product Owner / Product Lead，已确认上面的四项合同选择
- Architecture Reviewer: Independent Architecture & Knowledge Steward
- Quality Reviewer: Independent Quality, Performance & Release Maintainer

## Required inputs

- [Evidence Enforcement Architecture review](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement-architecture-review.md)
- [Evidence Enforcement Quality review](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement-quality-review.md)
- [Evidence Enforcement Assignment](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement.md)
- [Evidence Contract](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)
- [ADR 0025 Proposed](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)

## Entry criteria

- Product Lead 已确认四项合同选择，Decision Source/Date 已补入本 Assignment。
- 当前历史 B evidence、ambient worktree 状态和默认 gate 边界已冻结为输入，不覆盖或
  重写其他任务改动。
- Architecture/Quality reviewer 的独立性保持；实现完成后必须重新复审。

## Exit criteria

1. PATH/READY 在显式 preflight 中具备可验证 persistence 与 run-bound schema；普通路径
   没有新增诊断副作用。
2. geometry validator 能拒绝空/非法/多值 digest，且 retry 终态与合同一致。
3. owner readiness timeout 不再伪造 READY；failure 状态可被 validator 分类。
4. 新增 focused regression 覆盖 P2-EE-01 至 P2-EE-05；KeyboardCore 全量通过。
5. 最终 hardening tip 的 unsigned generic app/extension artifact、hash、flags 和
   marker scan 已记录。
6. 独立 Architecture 与 Quality 复审完成；历史 B 仍保持 `Partial`，不形成 Product
   Gate、ADR Accept 或 Release 结论。

## Stop conditions

- 需要修改默认 gate、输入语义、RIME/Lua 或生产 off-main 接线。
- 无法在安全 Swift 6 隔离下运输值型 evidence，或需要 `@unchecked Sendable`。
- 任何测试需要真实用户文本、坐标输入、设备清理或覆盖 ambient 改动。
- Product decision 未确认，或 PATH/READY schema 与 Evidence Contract 发生未记录的
  语义冲突。

## Verification snapshot — implementation handoff

本快照记录的是当前 hardening tip 的可复核证据；它不改变历史 B evidence 的
`Partial` 判定，也不构成 Product Gate、ADR Accept 或 Release 结论。

- `T9ResponsiveEvidenceValidatorTests`：**20 / 0**；覆盖 run-bound PATH/READY、
  malformed geometry digest、`unavailable → success` retry、NOT_READY、字段完整性、
  action/event mismatch、ACCEPT/VISIBLE/PUBLISH schema、epoch-bound publish、geometry
  payload 和 markerless privacy block。
- `ResponsiveRimePreflightTests`：**6 / 0**；覆盖带 run token 的 PATH 与 READY/NOT_READY
  marker 格式。
- `ThreadAffineRimeWireTests`：**9 / 0**；包含 owner readiness timeout 不得伪造 READY
  的回归。
- `ResponsiveRimeFeltMetricsTests`：**3 / 0**；锁定 `schema=v1` 的 felt marker 输出。
- explicit preflight 的 ACCEPT → VISIBLE/PUBLISH/BURST 与 epoch-bound publish 现在沿
  同一 revision 传递 canonical `run=`；validator 对这些 T9RESP marker 执行 run-bound
  fail-closed 检查。
- KeyboardCore 全量：**884 / 0**（schema/validator 收紧后的最终回归）。
- Release generic iOS build：**BUILD SUCCEEDED**；`CODE_SIGNING_ALLOWED=NO`，仅命令行
  注入 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` 与
  `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`，构建输出位于
  `/private/tmp/universe-keyboard-p2-evidence-hardening-final-v4-derived`。
- artifact executable fingerprint：app
  `34a05bf0af5fdefa965928d4bac20b035be8e2711c1e1dc4f7ef05062b90b04e`；Keyboard.appex
  `f354bb7a4a67e40c8015e4c2ce0c12a8ec55498400a87e35a920842ed2b654ce`。
- marker scan：Keyboard.appex 静态字符串命中
  `T9ResponsiveEvidenceValidator`、`T9DEVICE schema=v1`、`T9DEVICE_DISABLED`、
  `T9GEOM schema=v1 phase=execution`、
  `T9RESP marker=PATH schema=v1`、`T9RESP marker=READY schema=v1`、
  `T9RESP marker=NOT_READY schema=`、`T9RESP marker=FALLBACK schema=v1`，以及
  `T9RESP` felt `VISIBLE/PUBLISH schema=v1`。
  `NOT_READY schema=` 是 Swift 插值造成的静态字符串片段；运行时 formatter 回归确认实际
  输出为 `schema=v1`。
- `git diff --check` 与相关 Markdown link check：**通过**；未执行真实
  librime、iPhone 13 Pro 安装/人工输入、日志导出、jetsam/内存、iOS 26.0 Release RC
  或 Product Gate。

### Implementation changed-file allowlist

本轮 hardening 仅允许以下文件；工作树中的其他改动属于既有 ambient work，不在本子
Assignment 的交付范围内：

- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`
- `Keyboard/Controllers/KeyboardViewController+DevicePreflight.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimePreflight.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimeFeltMetrics.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSpike.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/T9ResponsiveEvidenceValidator.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimePreflightTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimeFeltMetricsTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeWireTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9ResponsiveEvidenceValidatorTests.swift`
- 本 Assignment 与相关 parent/contract 的状态、链接和验证快照。

## Independent review reconciliation

- [Architecture post-fix review](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening-architecture-review.md)：
  **Bounded Pass with conditions**，最终 P0/P1/P2/P3 = **0/0/1/2**。
  P2-EE-05 与 felt run binding 在代码/schema/focused/artifact 边界内 bounded closed；
  唯一 P2 是未执行的设备、真实 librime、persistence、Extension 压力、签名 Release、
  iOS 26 RC 与 Product Gate 证据。
- [Quality post-fix review](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening-quality-review.md)：
  **Pass with conditions**，最终 P0/P1/P2/P3 = **0/0/1/2**；独立 focused inventory
  38/0，独立核对 final-v4 hash、flags、schema marker 和默认 gate-off。
- 两份复审都确认：历史 B evidence 继续为 `Partial`；ADR 0025 继续 `Proposed`；本子
  Assignment 不能升级为 Product Gate、Release-ready、默认开启或真实 off-main 收益证明。
- 后续若要闭合唯一 P2 环境证据，必须由 Product Lead 另行授权真机/真实 librime/runtime
  persistence/jetsam/reload/签名 Release 矩阵；本次授权不包含该工作。

## Handoff

- Handoff Target: Independent Architecture reviewer, then independent Quality reviewer
- Required Handoff Content: decision source/date、changed-file allowlist、validator
  fixtures、test output、artifact fingerprint、未执行设备/Release/Product Gate 清单
- Revalidation Trigger: evidence schema、logging channel、geometry retry semantics、
  owner lifecycle、build flags、device/OS 或 ADR 状态变化
