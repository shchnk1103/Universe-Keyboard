# Assignment: DIAG-FLUSH-WAIT-001 — 诊断日志确定等待测试接口

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Completed |
| Phase | 已合并（PR #252，合并提交 48471f2c2555b6ce7820375975bb215e64340e16，Human 合并，CI 10/10 通过）。 |
| Non-claims | 阶段 B 执行时：不证明 CI 会变绿，不证明设备、Quality、Human Gate 或 Release（合并后状态见 Phase 与 History）。偶发超时根因仍是 UNKNOWN。等待返回不是 fsync，也不表示读取可见。 |
| Next | Closed 由 Human 按 D7 另行决定；T-B 统一设计与 0xDEAD10CC 缓解（PF-057）尚未立项。 |
| Residuals | CI 偶发超时根因 UNKNOWN；两次“屏障返回后读到 0 条”与一次 513 的根因 UNKNOWN（见 PF-034）；probe-on 运行、真机、慢环境表现 UNKNOWN。 |

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

- 2026-10-27: R2 修复第二轮 Quality 的 FAIL；R3（含接手会话）修复第三轮 Quality 的 FAIL（超时后不等待 body、阶段信息、Release strings 证据）；R4 增加 DEBUG 观测并重复运行，未复现“读到 0 条”；R5 修复第四轮 Quality 的两项 P1（耗时采样点、放弃 body 后保留临时目录）。
- 2026-10-27: R4 增加 DEBUG 观测计数；R4 Architecture 复核 ACCEPT WITH CONDITIONS；第五轮 Quality PASS WITH CONDITIONS。
- 2026-10-27: 发布时把 6 个本地提交压成 1 个提交；PR #252 经 Human 合并（合并提交 48471f2c2555b6ce7820375975bb215e64340e16）。
- 2026-10-27: 本记录 Lifecycle 改为 Completed（非 Closed）。
- 2026-10-27: 上文 Decision Source 记录的是阶段 B 当时的授权范围（本地提交、不授权 push）；push 与 PR 由后续发布包授权，PR #252 由 Human 合并。

## Exit evidence

外置 `~/.kos-work/Universe-Keyboard/DIAG-FLUSH-WAIT-001/reports/`，不入库。

| 报告 | SHA-256 |
|---|---|
| `review-arch.md` | `f6d0cc2262a78e3e4cc063f07c8834e2dde22193cc4622d37d72a947b10571c4` |
| `review-arch-r4.md` | `1ca36129bde33f9226fb8b817e14c57b46eb46d2ce1813d9e46e70c463e760be` |
| `quality-b.md` | `308680e4ce30fb7b68d42376e4fc882f72ba1870e0c64fc699667c17d5f65d36` |
| `quality-b-r2.md` | `1ad65a3dbe36ea8f8b2e32f23f101c2124d189d0477138b128fc48d8b297b0da` |
| `quality-b-r3.md` | `72c6644ab9447cf5c8d2e21a17989659b4bbd8e87ff95b7518e67cff6812396f` |
| `quality-b-r4.md` | `f5aff7ab92c7a344c6b78319a41b878da860f550cb0acfbb6828118bffa6b288` |
| `quality-b-r5.md` | `ed6273335d6e57f817f6f71d918f4a4f4afadd4fbb45abc841329911749f54cd` |
| `executor-report-b-r5.md` | `089b699daa064ab9df52c12c01b6909aae1e280711df0c1c44eac4861baef705` |
| `executor-report-publish-1.md` | `1a4661748c17b81fb72bc55563b3ad8bedb64eafec4f71f87039d526d4e5bfb9` |
