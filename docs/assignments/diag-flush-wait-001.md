# Assignment: DIAG-FLUSH-WAIT-001 — 诊断日志确定等待测试接口

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Phase | 阶段 B 本地实现与验证。记录与实现按 Human 加急放在同一候选里。 |
| Non-claims | 不证明 CI 会变绿，不证明设备、Quality、Human Gate 或 Release。偶发超时根因仍是 UNKNOWN。等待返回不是 fsync，也不表示读取可见。 |
| Next | 独立 Quality。push、PR、merge 都还没有授权。 |
| Residuals | CI、设备、慢环境下更早上界失败的表现，均为 UNKNOWN。 |

正常完成的测试屏障仅表示调用前已接受事件终结；取消返回不证明终结，且终结不保证 reader 可见。前后累计快照非原子，既非该次屏障的精确上界也非逐 ticket 对账，不能凭 accepted 等于各结果之和推断覆盖。计数按首个终结原因归类，dropped 合并多种原因，不是物理 I/O 审计。历史屏障返回后读到零条与此合同相容，但违反原测试数量断言，其根因仍为 UNKNOWN。

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human 于 2026-10-27（Asia/Shanghai）选定先做 T-C，并授权阶段 B 任务包 `task-package-stage-b.md`（SHA-256 `1c1a51c85c136840128529be0cf26b8de8100cf5cfe6e9710a527107d380c1d2`）。Human 要求把 Assignment 记录和实现放进同一个 PR。这是加急做法，先例是 `LIQUID-GLASS-DEBUG-ONLY-001`。本记录随该实现一起本地提交，不授权 push。
- Product Approver: Human Product Owner

## KOS v0.8.0 optional-contract selection

本 Assignment 不选择 E-01、A-01/B-01、P-01 或 D-01。未列出的合同不在范围内。

## Boundary

- Scope: KeyboardCore 诊断日志 Ingress/Runtime 的 DEBUG 测试等待，以及已经在轮询日志目录或 reader 的指定测试。包括本 Assignment 记录。
- Non-goals: 放宽超时或断言；改变 `requestFlush` 或 `suspendForExtensionLifecycle` 的生产语义；改变按键热路径行为；0xDEAD10CC 缓解；RIME；push、PR、merge；签名与设备；改 Human 主检出。
- Required Inputs: 阶段 A 设计 `dc40c4d0ff4437c72874abcf77d9f48b2625b019825ace0f6fcb67a86e370e90`；独立 Architecture 复核 `f6d0cc2262a78e3e4cc063f07c8834e2dde22193cc4622d37d72a947b10571c4`；阶段 A 任务包 `2afe811f1b096cc364e5f80a443dc181dd24dccb578285a50187d8058c10077f`；基线 `ac0bbeec791ec541c2014036771ad57aec2ece45`。

## Assignment

- Domain Owner: Input Intelligence Maintainer
- Executor: 获授权的执行会话（角色：Input Intelligence Maintainer）
- Environment Executor: 获授权的执行会话（角色：模拟器编译与测试执行者）；真机 Not Applicable
- Human Dependency: Not Applicable。本阶段不需要 Human 操作设备或提供新的产品决定。
- Architecture Reviewer: Architecture & Knowledge Steward。阶段 A 复核已经完成；实现本身不再次充当 Architecture。
- Quality Reviewer: Quality, Performance & Release Maintainer。本阶段不代替 Quality。

## Gates

- Entry Criteria: 阶段 B 包哈希相符，`origin/main` 仍是基线，目标文件没有被别的提交改过，`@testable` 路线没有被编译否定。
- Exit Criteria: DEBUG 测试等待落地，指定测试迁到有界屏障，本地验证命令和退出码写入执行报告。退出不包含 CI、设备或 Quality。
- Stop Conditions: `@testable` 被编译否定；需要放宽断言或超时；需要改变生产 `requestFlush` 或 suspend 语义；基线上的目标文件被其他提交修改且无法安全处理；需要 push、签名或设备。

## Handoff

- Handoff Target: Quality, Performance & Release Maintainer
- Required Handoff Content: 本地提交、执行报告、测试与构建命令的退出码，以及明确的非声明（CI、设备、根因）。
- Revalidation Trigger: Ingress/Runtime 完成语义、ticket 规则、测试预算或基线改变。

## History

- 2026-10-27: 阶段 B 按冻结包把记录和实现放在同一本地提交。push 未做。
- 2026-10-27: 阶段 B-R1 按修订包补有限退出、确定性测试和具名执行角色。仍不 push。
