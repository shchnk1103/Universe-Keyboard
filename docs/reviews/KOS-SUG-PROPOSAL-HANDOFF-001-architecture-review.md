# Architecture Review: KOS-SUG-PROPOSAL-HANDOFF-001

## 审查身份、基线与范围

| Field | Value |
|---|---|
| Reviewer | `/root/kos_suggestions_arch_review` — independent Architecture reviewer |
| Review date / timezone | `2026-09-10 Asia/Shanghai` |
| Worktree / branch | `/private/tmp/universe-keyboard-kos-v080-upgrade-review` / `codex/kos-v080-upgrade-review` |
| Baseline HEAD | `0757f47c934bba420b5cc47033b563e40c0cb8e9` |
| Review mode | Read-only document-architecture review; only this reviewer file may be written |
| Independence basis | This runtime did not author the Proposed-plan policy, pilot, Assignment, Authorization or Product Decision; it only inspected them and writes this review record |

审查对象是最终 docs-only 差异：

- [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) 的 `Proposed`
  plan lifecycle 和 Proposed work-package handoff header；
- [`kos-sug-05-proposed-work-package-pilot.md`](../plans/kos-sug-05-proposed-work-package-pilot.md)；
- [`KOS-SUG-PROPOSAL-HANDOFF-001` Assignment](../assignments/kos-sug-proposal-handoff-001.md)、
  [`AUTH-KOS-SUG-PROPOSAL-HANDOFF-001`](../authorizations/AUTH-KOS-SUG-PROPOSAL-HANDOFF-001.md)、
  Product Decision 及 [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) 镜像。

检查边界是 Proposed 是否仍为非当前实现指导、非授权源，并且是否保留
`UNKNOWN`、不迁移历史/Active 记录、不过界到 SUG-01–04/06–09、KOS
2.0/2.1、`required`、CI、代码、真机、数据或发布。该 review 不作 Product
Decision，不关闭 Assignment，不产生任何后续实现或外部操作授权。

## 冻结输入

| Input | SHA-256 |
|---|---|
| [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) | `09e6c5ca8cb93f7eb0735c2de725d94046e5f892a889f02bc7b273d3c0bc8336` |
| [`SUG-05 Proposed pilot`](../plans/kos-sug-05-proposed-work-package-pilot.md) | `235be01ef0ccbaccc4a1318d140af8006cd3de1a75f10f3ddfae223041284a52` |
| [`KOS-SUG-PROPOSAL-HANDOFF-001` Assignment](../assignments/kos-sug-proposal-handoff-001.md) | `b223f7d352ef6e3a1ffc1aec7d979cfc9cb5586624966736380cd99d855f4389` |
| [`AUTH-KOS-SUG-PROPOSAL-HANDOFF-001`](../authorizations/AUTH-KOS-SUG-PROPOSAL-HANDOFF-001.md) | `d73c9bb8049c64f306b6a1f91c96df73408ebfa1603cfee25d44feb19fd7235b` |
| [`KOS-SUG-PROPOSAL-HANDOFF-001` Product Decision](../product-decisions/KOS-SUG-PROPOSAL-HANDOFF-001-authorization.md) | `9063abc491483799379d40b0682cc5fab84d223e38ed5bc5100851fda8d60973` |
| [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) | `9df42903bf9a1d494c2158e8480bbdeaf376342d51f4e27e916e4577e98995dc` |
| [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) | `50527220e0e9c96dadff1162f57730827c2d712e12de79a76f45a103a326ebe1` |
| [`UPGRADE_STATUS.md`](../kos/UPGRADE_STATUS.md) | `6666e9be6dbd7e0208dc3b0d5f776f9f04f2660e7793e122ab6bf8d189d8f634` |
| Current SUG disposition ledger | `4ce7f60a1e2c8b2f887b41e2eb1a7ca53a11ee83d793ac083e232df6f4b2168a` |

`git diff --check` 通过。未运行代码、CI、设备、数据读取、上游或发布操作。

## 通过项与兼容性判断

`DOCUMENTATION_GOVERNANCE.md:189-220` 将 `Proposed` 定义为规划/交接工件，明确
它不是当前开发指导，不授权实现、决策、设备/数据、发布或生命周期转变；header
字段覆盖 triggering evidence、frozen facts/unknowns、decision、seam、verification、
stop/non-goals 和 authorization/reviewers。它还明确 header 不能替代未来
Assignment、Authorization 或 Accepted Product Decision，生命周期转变不能从
review、mirror、chat 或 validator 推断。

试点计划的 `Lifecycle: Proposed` 和 `Status: not implementation-authorized`
与该规则一致（[`pilot:1-5`](../plans/kos-sug-05-proposed-work-package-pilot.md#L1)）。
它将未选择的实现目标、环境、用户数据需要和交付候选保留为 `UNKNOWN`，并明确
计划不成为 Assignment、Authorization、Accepted Product Decision、Gate、Quality
evidence、设备权限、发布事实或当前架构（[`pilot:7-15`](../plans/kos-sug-05-proposed-work-package-pilot.md#L7)）。

Assignment/Authorization/Product Decision 的当前链条只授权 SUG-05 的
governance convention 和一个 Proposed pilot；其余建议、KOS 规则、`required`、
迁移、CI、隐私/诊断、设备、代码和发布均排除（[`Assignment:24-65`](../assignments/kos-sug-proposal-handoff-001.md#L24)，
[`Authorization:23-37`](../authorizations/AUTH-KOS-SUG-PROPOSAL-HANDOFF-001.md#L23)，
[`Product Decision:7-22`](../product-decisions/KOS-SUG-PROPOSAL-HANDOFF-001-authorization.md#L7)）。
reviewer lanes 已具名绑定，`ACTIVE_WORK.md:38` 只镜像该 Assignment 的 Active
状态并等待独立审查，没有制造授权。

## Findings

| ID | Severity | Finding / exact boundary | Required residual / disposition |
|---|---|---|---|
| `A-SUG-PROP-P1-01` | P1 | `DOCUMENTATION_GOVERNANCE.md:191-202` 写成“Every file under `docs/plans/` must declare exactly one lifecycle state”。当时的树中至少有多份既有计划没有这五个允许状态的显式 lifecycle marker，包括历史审查时存在、但不属于本候选的 `scheme-platform-execution-kos-2026-09-09.md` 与 `scheme-platform-ice-reference-target-2026-09-09.md`。本 Assignment/Authorization 明确禁止迁移历史或既有 Active records（[`Assignment:58-65`](../assignments/kos-sug-proposal-handoff-001.md#L58)；[`Authorization:30-31`](../authorizations/AUTH-KOS-SUG-PROPOSAL-HANDOFF-001.md#L30)）。因此当前规则要么制造未授权的全量计划迁移，要么留下 Source-of-Truth/适用范围冲突，超出 SUG-05 的单个 pilot。 | **HOLD / `fix`。** 将规则收窄为新建或实质修改的 plan，或另建独立的历史计划迁移 Assignment；本任务不得回填、重命名或迁移现有计划。修复后重新检查规则与 pilot 的适用范围。 |
| `A-SUG-PROP-P2-01` | P2 | Proposed header 本身正确地说不能替代 Assignment、Authorization 或 Accepted Product Decision，但 pilot `Required authorization and reviewers` 末尾又写 “This pilot's current implementation authority is [Assignment] only”（[`pilot:15`](../plans/kos-sug-05-proposed-work-package-pilot.md#L15)）。同时 lifecycle transition 规则只说创建/链接 required Assignment 并改变 lifecycle（[`DOCUMENTATION_GOVERNANCE.md:216-220`](../DOCUMENTATION_GOVERNANCE.md#L216)），没有在该处重申 matching Authorization 和 Accepted Product Decision。它没有直接授予实现权，因为其他段落明确 non-authorizing，但零上下文读者可能把 Assignment 单独当成 authority。 | **`fix` residual。** 改为明确的完整链条：当前 docs-only pilot 由 Assignment + matching Authorization + Accepted Product Decision 共同约束；未来 plan 变为 implementation guidance 前必须取得同样的独立三件套。保留 Proposed 自身不产生任何 authority 的声明。 |

没有发现 P0 或 P3 finding。上述 P1 是全局 lifecycle 规则与 no-migration 边界的冲突，
P2 是 authority chain 表述缺口；没有发现 SUG-01–04/06–09、KOS 2.0/2.1、
`required`、CI、代码、真机、数据或发布被实际纳入。

## 结论与计数

**Architecture verdict: HOLD.** E-01 未被选用，A-01/B-01 只用于当前 SUG-05
docs-only Assignment 的边界展示；试点本身仍保持 `Proposed`、`UNKNOWN` 和
非当前实现指导。由于 `A-SUG-PROP-P1-01` 让新增的“每个计划必须有状态”规则
超出本任务且与禁止迁移冲突，当前不能把该 docs-only 包视为合规完成；
`A-SUG-PROP-P2-01` 也需一并修正以避免单独 Assignment 的 authority 误读。

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 1 |
| P2 | 1 |
| P3 | 0 |

## Residual 与非结论

- `fix` residuals：`A-SUG-PROP-P1-01`、`A-SUG-PROP-P2-01`；不需要新增
  `TECH_DEBT`，因为它们可以在同一 docs-only scope 内修复。
- Assignment 仍需独立 Quality review 和普通 docs-only validation 后，才可进入
  后续 Close；本 Architecture review 不代替 Quality 结论。
- 本审查不把 Proposed plan 变成 Assignment、Authorization、Accepted Product
  Decision、Gate、设备/数据权限、当前架构或实现指导，也不改变任何 Product
  Decision、KOS 规则、Active Work 生命周期或外部状态。

## Final delta review

审查日期：`2026-09-10 Asia/Shanghai`。本次只复核两项 final delta，并以当前
工作树中的对应 Assignment、Authorization、Accepted Product Decision 和
`ACTIVE_WORK.md` 作为范围与权威链交叉检查；未修改任何被审查文件。

### Final delta 基线

| Input | Current SHA-256 |
|---|---|
| [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) | `c622bd58f4be4b100cdcd35aa0f46d36ecf41de1ea9dd03327cabc13112eaaa1` |
| [`SUG-05 Proposed pilot`](../plans/kos-sug-05-proposed-work-package-pilot.md) | `3912d8dd472bfcc4bd57ce4367dc254e4b7f32c4eb58b150c7f9551b9285ab3d` |
| [`KOS-SUG-PROPOSAL-HANDOFF-001` Assignment](../assignments/kos-sug-proposal-handoff-001.md) | `b223f7d352ef6e3a1ffc1aec7d979cfc9cb5586624966736380cd99d855f4389` |
| [`AUTH-KOS-SUG-PROPOSAL-HANDOFF-001`](../authorizations/AUTH-KOS-SUG-PROPOSAL-HANDOFF-001.md) | `d73c9bb8049c64f306b6a1f91c96df73408ebfa1603cfee25d44feb19fd7235b` |
| [`KOS-SUG-PROPOSAL-HANDOFF-001` Product Decision](../product-decisions/KOS-SUG-PROPOSAL-HANDOFF-001-authorization.md) | `9063abc491483799379d40b0682cc5fab84d223e38ed5bc5100851fda8d60973` |
| [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) | `9df42903bf9a1d494c2158e8480bbdeaf376342d51f4e27e916e4577e98995dc` |

### Delta 复核

1. **`A-SUG-PROP-P1-01` 已关闭。** `DOCUMENTATION_GOVERNANCE.md:191-193`
   将 lifecycle 要求限定为 **new or materially changed** 的 `docs/plans/`
   文件，并明确不要求 historical 或 existing Active plans 批量回填、迁移。
   这与 Assignment 的 `:58-65`、Authorization 的 `:30-31` 中禁止
   `active_assignment_migration` / 历史或 Active 迁移的边界一致；现有计划的
   自定义状态不会被本 SUG-05 pilot 重新解释或改写。

2. **`A-SUG-PROP-P2-01` 已关闭。** pilot `:15` 现在明确：当前 docs-only
   pilot 受完整的 `Assignment → Authorization → Accepted Product Decision`
   链共同约束，并明确不授予 implementation authority；未来 implementation
   也必须取得独立的 Product-selected Assignment、matching Authorization 和
   Accepted Product Decision。该表述与 Assignment `:29-38` 的 A-01/B-01
   frontier、Authorization `:24-31` 的 artifact/scope/exclusions，以及
   Product Decision `:19-22` 的 non-binding Proposed boundary 一致。

3. 未发现新架构 finding。`Proposed` 仍被限定为非当前开发指导、非实现/决策/
   设备数据/发布授权；`UNKNOWN` 仍被保留；`ACTIVE_WORK.md:38` 仅镜像 SUG-05
   Active 状态并等待独立 Architecture/Quality review。范围仍未延伸到
   SUG-01–04/06–09、KOS 2.0/2.1、`required`、CI、代码、真机、数据或发布。

`git diff --check` 通过；本次未运行代码、CI、设备、数据读取、上游或发布操作。

### Final 结论与计数

**Architecture verdict: Pass。** `A-SUG-PROP-P1-01` 与
`A-SUG-PROP-P2-01` 均已关闭；本 final delta 不扩大授权链或审查边界。

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 0 |
| P3 | 0 |

Quality review 仍是独立的后续 gate，本 Architecture Pass 不代替 Quality
结论，也不关闭 Assignment 或产生 implementation、device/data、commit、
publication 或 release 授权。
