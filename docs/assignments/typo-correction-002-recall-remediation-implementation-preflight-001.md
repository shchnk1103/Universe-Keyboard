# Assignment: TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | 纯 KeyboardCore preflight 已完成；Architecture/Quality 均为 Pass with conditions，Product bounded Accept 已记录；生产接线仍未授权。 |
| **Non-claims** | 不代表生产接线、真实 RIME、设备 Run、180 ms、QA-001、INT-003、Product/Quality Gate 或 parent Close。 |
| **Next** | 另立 bounded residual-remediation Authorization，先处理三个 Architecture 条件；完成后再复核，暂不进入生产接线或 publication。 |
| **Residuals** | substitution-only fail-closed、group identity/accounting、batch/resolved-group/epoch coverage 仍需修复；Quality cache limitation 与 contextual 7/8 `UNKNOWN` 保留；F-01 与本 lane 分离。 |

---

## Authority

- **Assignment Authority:** Product Lead / Human Product Owner, current Codex task, `2026-09-20 Asia/Shanghai`。
- **Decision Source / Date:** [`bounded Product decision`](../product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-001-bounded-product-decision.md)，published at `a42858bf134fa51803b00460a7e3032db6b09ae0`。
- **Product Approver:** Human Product Owner / Product Lead。
- **Parent Assignment:** [`TYPO-CORRECTION-002-RECALL-REMEDIATION-001`](typo-correction-002-recall-remediation-001.md)。
- **Matching Authorization:** [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001.md)。

## Boundary

### Scope

1. 在精确的 source/package identity 下检查当前 `Packages/KeyboardCore` 路径和测试边界。
2. 仅在纯 KeyboardCore/preflight 层实现或调整最小的覆盖测量与契约测试；不得把 preflight 接入 Keyboard Extension 或生产 controller。
3. 测量 canonical case 与代表性邻近 benchmark 的 production frontier，以及触发第二阶段所需的最小有效扩展阈值。
4. 为 stage-level `maxQueryAttempts` 选择一个可解释的具体值，并分别验证 `N_generated`、`N_query_attempts`、`N_resolved_groups` 和 `N_candidates_returned`。
5. 验证取消时机、composition revision/epoch、过期 sidecar 结果丢弃和 publish fence；首个编辑操作切片只允许 substitution，双编辑结果只可 display-only。
6. 生成绑定精确 source/package、测试命令、结果和 non-claims 的 preflight evidence，随后交独立 Architecture 和 Quality review。

### Non-goals

- 不修改生产 12/8 默认预算，不把 preflight 60/64/8 接入生产。
- 不修改 `Keyboard/`、`RimeBridge`、Main App、Keyboard Extension controller 或 marked-text/host-text 路径。
- 不部署、查询或伪造 RIME；不使用 FakeCandidateProvider、旧 Ice 目录、host context、clipboard、网络或合成 RIME fixture 作为运行证据。
- 不引入本地或云端模型，不改 schema/vendor，不做设备或 Simulator capture，不创建新的 Run ID。
- 不宣称 QA-001、INT-003、paired-performance、180 ms、candidate quality、Product/Quality/Release Gate 或 parent Close。
- 不执行 commit、push、PR、merge、TestFlight、Release 或关闭其他 Assignment；这些动作需要独立授权。

## Assignment

- **Domain Owner:** Input Intelligence Maintainer。
- **Executor:** Current Codex task, limited to this preflight Authorization。
- **Environment Executor:** Current Codex task — local Swift/KeyboardCore toolchain only；不执行设备或部署操作。
- **Human Dependency:** Product Lead 已接受方向；若需要扩大到生产、RIME、设备或性能，必须重新取得明确决定。
- **Architecture Reviewer:** Independent Architecture & Knowledge Steward，未参与本切片实现的 reviewer。
- **Quality Reviewer:** Independent Quality, Performance & Release Maintainer，针对本切片的纯 Core 证据。

## Required Inputs

- [`bounded Product decision`](../product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-001-bounded-product-decision.md) at `a42858bf134fa51803b00460a7e3032db6b09ae0`。
- [`conditions Architecture re-review`](../reviews/typo-correction-002-recall-remediation-conditions-architecture-review-2026-09-20.md)。
- Source implementation freeze `fb27b24ff85c48302e85309e834dbbe9a777871e`。
- [`TYPO_BENCHMARK_REGISTRY_V2.md`](../TYPO_BENCHMARK_REGISTRY_V2.md)、[`TYPO_CORRECTION.md`](../TYPO_CORRECTION.md)、recall design note 与 coverage matrix。
- 当前 `Packages/KeyboardCore` source/test inventory，以及任何新建 preflight worktree 的精确 commit/tree identity。

## Gates

### Entry Criteria

- Product bounded Accept 已记录且未被新的 Product 决定撤销。
- 本 Authorization 保持 `active`，首次代码变更前消费并记录实际 source/package identity。
- 纯 `Packages/KeyboardCore` 与其测试 target 可独立运行；若必须触及 `Keyboard/`、RIME 或 host text，立即停止并回交 Product/Architecture。
- 执行使用独立、无脏变更的 preflight worktree；不得使用 parent/main 的未提交文件作为输入。
- 生产 12/8 与 preflight 60/64/8 仍保持只读基线，不能由测试结果自动改变。

### Exit Criteria

- 记录可复现的 frontier/最小扩展阈值和具体 stage-level `maxQueryAttempts`，并解释它们不等于性能结论。
- 四个计数器在证据和测试中保持可区分；取消、revision/epoch、stale-result discard 和 publish fence 有 focused contract tests。
- substitution-only 过滤、双编辑 display-only、预算上限和 contextual 7/8 `UNKNOWN` 均有明确测试/证据边界。
- `swift test --package-path Packages/KeyboardCore` 及本 Assignment 要求的 focused tests 通过；失败和未执行项完整记录。
- 变更路径、source/package identity、命令、测试结果和 non-claims 已形成 evidence receipt，并完成独立 Architecture/Quality review；任何 residual 都有 `fix`、`accept` 或 `tech_debt:<ID>` 处置。
- 没有生产 controller/RIME/设备接线；若要进入下一阶段，另立 production implementation Authorization。

### Stop Conditions

- 需要改变生产默认预算、搜索调度、RIME/schema/vendor、host text、隐私边界或 Keyboard Extension 热路径。
- 无法在纯 KeyboardCore 中确定 frontier、cap 或 stale publish 保护，或只能靠重新实现算法推导结果。
- 需要本地/云端模型、网络、FakeCandidateProvider、旧 Ice 目录或合成 fixture 才能“证明”召回。
- source/package identity、测试 target、Assignment scope 或 Product decision 发生变化。
- 任何测试失败、并发取消竞态、过期结果仍可发布，或出现未处置的 Architecture/Quality residual。

## Handoff

- **Handoff Target:** Independent Architecture review → Independent Quality review → Product Lead（仅在未来申请生产接线时）。
- **Required Handoff Content:** 精确 source/package commit/tree、变更文件、预算与 cap、四计数器定义、取消/epoch/publish 证据、测试命令与结果、未执行项、residual disposition、明确 non-claims。
- **Revalidation Trigger:** source/package 或 origin/main 变化、预算/算法/操作范围变化、触及 Keyboard/RIME/设备、需要新 Run ID、Product/Architecture/Quality scope 变化、Authorization 被撤销。

## History

- `2026-09-20 Asia/Shanghai`：依据 Product bounded Accept 建立独立 implementation-preflight Assignment。
- `2026-09-20 Asia/Shanghai`：在 `d0df9a6342d8209b5aa7f9826541d0b430b9da04` / tree `27ae44bec1b157e391ef1e0b859db3a068e21ba8` / `Package.swift` Git blob identity `1a06a522f12089f3dbb2ad774d13fe9f56193d04` 上消费 Authorization；实际 Package.swift SHA-256 为 `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764`；基线 KeyboardCore 测试 `1129/0`，开始纯 Core preflight。
- `2026-09-20 Asia/Shanghai`：完成纯 KeyboardCore preflight；focused contract tests `9/9`，完整 KeyboardCore `1138/1138`，frontier 观测为 `12/16 absent`、`24→rank54`、`32/40/48/60→rank55`；记录于 [`preflight evidence`](../evidence/typo-correction-002-recall-remediation-implementation-preflight-001.md)，等待独立复核。
- `2026-09-20 Asia/Shanghai`：Independent Architecture 与 Quality 均完成 `Pass with conditions`；Product bounded Accept 记录于 [`bounded decision`](../product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-BOUNDED-DECISION-2026-09-20.md)。三个 Architecture 条件及 Quality cache limitation 保留，下一步另立 residual-remediation Authorization。
