# Architecture Review: GIT-BRANCH-ARCHIVE-HYGIENE-001

## 审查身份、基线与范围

| Field | Value |
|---|---|
| Reviewer | independent Architecture & Knowledge Steward runtime, lane `GIT-BRANCH-ARCHIVE-HYGIENE-001/document-architecture` |
| Review date / timezone | `2026-09-11 Asia/Shanghai` |
| Worktree / branch | `/private/tmp/universe-keyboard-group-a-hygiene` / `docs/git-branch-archive-hygiene-001` |
| Baseline HEAD | `234d180f0f6abccc171fc2898e40b09aa128a2f1` (`origin/main` `6b24c37dcf8b5c7bed0a995739c054ae20fd7c04`) |
| Review tree | HEAD plus uncommitted working-tree docs for this Assignment (Assignment / plan Status / Active Work / Dashboard) and untracked Group A evidence; this review file is the only write |
| Review mode | Read-only document-architecture review of the Group A docs packet; no commit, push, tag, delete, merge, or Scheme Platform checkout |
| Independence basis | This runtime did not author the Assignment, Authorization, Product Decision, plan edits, or evidence; it only inspected them and writes this review record |

审查对象是 Group A 归档卫生的权威链与文档包，不是 Quality 复验、不是 merge、不是 Product Gate：

- [`GIT-BRANCH-ARCHIVE-HYGIENE-001` Assignment](../assignments/git-branch-archive-hygiene-001.md)
- [`AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001`](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001.md)
- [Accepted Product Decision](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-001-authorization.md)
- [`parked-branch-archive-hygiene-2026-09-11.md`](../plans/parked-branch-archive-hygiene-2026-09-11.md)
- [Group A evidence](../evidence/git-branch-archive-hygiene-001-group-a-2026-09-11.md)
- [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) 与 [`ENGINEERING_DASHBOARD.md`](../ENGINEERING_DASHBOARD.md) 镜像
- [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) 必填字段 / lifecycle / `UNKNOWN`
- [`AGENTS.md`](../../AGENTS.md) 默认分支清理规则，对照 Product Decision 中的 Group A tag-reachability 例外

检查边界是：权威链是否只绑定 Group A tag-then-delete、文档包、docs-only PR（禁止 merge）；唯一提交是否被正确表述为 annotated tag 归档而不是合入 `main`；AGENTS.md 例外是否显式、有界、未泛化；Group B / #101 / #102 / Scheme Platform / Product Gate / Swift / SUG-08 是否被排除；计划从 `Proposed` 到 `Active` 是否故意并带 S-03；是否存在 Source-of-Truth 冲突、必填 `UNKNOWN` 或范围泄漏。

本 review 不作 Product Decision，不关闭 Assignment，不替代 Quality 结论，不授权 merge、Group B、Release 或任何后续 ref 变更。

## 冻结输入

工作树当前字节的 SHA-256（含未提交的 Assignment / plan / 镜像更新，以及未跟踪证据）：

| Input | SHA-256 |
|---|---|
| [`GIT-BRANCH-ARCHIVE-HYGIENE-001` Assignment](../assignments/git-branch-archive-hygiene-001.md) | `b68601ca9c738548339a75dee9cb2839d98655c460b528dcf750c77a8ff3828c` |
| [`AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001`](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001.md) | `9c2fec562a71b833e275a5a56062a3164c736622aa712b634ac80c9f0161f5b2` |
| [Product Decision](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-001-authorization.md) | `cef8a17becce583503b41aac621a6255f2eabf38bce145d91ec51d60b4f571f2` |
| [parked-branch plan](../plans/parked-branch-archive-hygiene-2026-09-11.md) | `508c33f700adb5077093bb04a0ada38cf03b97b2d0c32b9d4b4a9677ac86a3ea` |
| [Group A evidence](../evidence/git-branch-archive-hygiene-001-group-a-2026-09-11.md) | `3d638b9a7fb0cacc3f5ecd673bc94a020bbdefe2e008d870effa3981c0b2ee3f` |
| [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) | `ff946121f251e696d694ecea4c62ae0d91fa06d6b9c28047517d3c7fbaec0bef` |
| [`ENGINEERING_DASHBOARD.md`](../ENGINEERING_DASHBOARD.md) | `fd07b0f25765be75ed15078fa59dd835d0dd4714354f8f5e5d3ce9cf88e4b80a` |
| [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) | `59fc94f12b61ee303c4dda644c41eeae3b3fc3c63d9ea5b033e766ccc3b9fc5d` |
| [`AGENTS.md`](../../AGENTS.md) | `c0c196de4e8c0dce1087ab1840f512e5d7ecfd67ac846290decd699373495f67` |
| [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md)（计划 lifecycle / S-03 对照） | `d13c15217037571c8df9a43257ecae6e5d8c90556e4512116cae8568999651af` |

`git diff --check` 通过（工作树与 index）。未运行代码、CI、设备、数据读取；未 mutate 任何 git ref。只读确认：`git ls-remote --tags origin` 与 `git ls-remote --heads origin`（见下节）。

## 通过项与兼容性判断

### 1. 权威链只绑定 Group A + 文档包 + docs-only PR（无 merge）

Assignment [`git-branch-archive-hygiene-001.md#L7-L81`](../assignments/git-branch-archive-hygiene-001.md#L7) 的 Current Status / Scope / Non-goals 将授权动作限制为三个 Group A 分支的 annotated tag、在 tag 已在 `origin` 且 peel 等于 tip 之后删除对应本地与 `origin` 分支名、写证据、独立 Architecture/Quality 文档审查、提交并推送 `docs/git-branch-archive-hygiene-001`、开 docs-only PR。Merge、Group B、#101/#102、Scheme Platform、Product Gate / TestFlight / Release、ADR Accept、Swift、SUG-08 均为 non-goal。

AUTH [`AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001.md#L14-L41`](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001.md#L14) 的 `action` 为 `execute_group_a_parked_branch_archive`；`artifact_bindings` 绑定计划文件与三个 Group A 分支名；`scope` 明确 “Do not merge that PR”；`exclusions` 列出 `group_b_tag`、`group_b_delete`、`scheme_platform_001`、`pull_request_101`、`pull_request_102`、`merge`、`release`、`testflight`、`product_gate`、`adr_accept`、`swift_change`、`sug_08`、`force_delete_untagged_unique_tip`。

Accepted PD [`GIT-BRANCH-ARCHIVE-HYGIENE-001-authorization.md#L7-L25`](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-001-authorization.md#L7) 只提升 SUG-05 包的 **Group A slice**，并写明其余部分不是当前开发指导。A-01/B-01 frontier 将当前片标为 `In progress`（审查与 docs PR 仍在 AUTH 范围内），将 docs PR merge 与 Group B 标为 `Not authorized`。P-01 表在 docs commit 尚未存在时保持 `unknown` / `none`，符合 Policy 对未知身份的诚实要求，不是 Assignment 必填字段 `UNKNOWN`。

`ACTIVE_WORK.md` 第 8 行与 Dashboard `GIT-BRANCH-ARCHIVE-HYGIENE-001` 段只镜像 Assignment：Active、Group A 已 tag/delete、等待独立审查与 docs PR、无 Group B / merge。它们不是授权源。

### 2. Group A 唯一提交按归档处理，未声称合入 `main`

证据、Assignment Non-claims、PD Decision 均写：可达性来自 pushed annotated archive tag，而不是 `main`。本审查只读复核（不改变 refs）：

| Deleted branch name | Tip / peeled commit | Annotated tag object on `origin` | Ancestor of `origin/main`? | `origin` heads after delete |
|---|---|---|---|---|
| `codex/kos-v080-upgrade-review` | `7e090bd4a31d79a19cfa5e8d3b58ccfe60d92f34` | `6a12c2d6bae019186a45f746700c2dc6430d5e59` (`archive/codex-kos-v080-upgrade-review/20260911`) | `NOT_ON_MAIN` | empty |
| `codex/td016-docs-only-fixture` | `bd4b6eb14c6e4b25c60d66807ceb1e0b67cc8ac4` | `19853f87c86b0b51f9d99fb13e95f04cf1c9851d` | `NOT_ON_MAIN` | empty |
| `docs/t9-single-key-mixed-candidates-discussion` | `270f45b954d1a3f49f623059cf9e0b874c640061` | `64c77be251e796fc859ca1d579e0f0891416fa10` | `NOT_ON_MAIN` | empty |

本地 `git cat-file -t <tag>` 为 `tag`（annotated）；`git rev-parse <tag>^{commit}` 等于记录的 tip。证据将自身标为 `Executor-recorded`，不冒充 Quality-reverified。恢复配方不要求把这些提交 cherry-pick 到 `main`。

### 3. AGENTS.md 例外显式、有界、未泛化

[`AGENTS.md#L52-L62`](../../AGENTS.md#L52) 的默认规则未改（相对 `origin/main` diff 为 0 字节）：功能分支清理仍要求 tip 可从 `origin` 默认分支到达，禁止用强制删除掩盖未合并状态。

PD [`GIT-BRANCH-ARCHIVE-HYGIENE-001-authorization.md#L21-L25`](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-001-authorization.md#L21) 把例外写在 Product Decision 里：被删分支名的可达性是 **已推送的 archive tag**，且仅适用于本 Assignment 的三个 Group A 名字。没有把该例外写回 `AGENTS.md`，没有推广到 Group B、开放 PR head、或任意 unmerged tip。AUTH 另禁 `force_delete_untagged_unique_tip`。这是有界例外，不是规则泛化。

### 4. 排除项在权威链、证据与现场 refs 上一致

只读 `gh pr list --state open` 仍只有 draft #101（`docs/adr-0034-architecture-accept-checklist`）与 draft #102（`codex/scheme-platform-001`）。`origin` 上这两个 head 仍为证据记录的 `889bb4e7…` 与 `d8e8299d…`。本地 Group B 三分支仍在（`e83e635` / `d3680c3` / `3444826`）。`origin` 上不存在 `archive/codex-wanxiang-p4-closure-001/*`、`archive/codex-release-2026-0801-kaomoji/*`、`archive/codex-release-2026-08-01-coordination-next/*`。工作副本不是 `codex/scheme-platform-001`。Swift / SUG-08 / Product Gate 未进入 Scope。

### 5. 计划 lifecycle：Proposed → Active 是故意的，S-03 卸下 Proposed header 的 Group A 权威

[`DOCUMENTATION_GOVERNANCE.md#L249-L253`](../DOCUMENTATION_GOVERNANCE.md#L249) 要求计划变成实现指导时链接 Assignment 并故意改 lifecycle。本计划顶栏为 `Lifecycle: Active`，并链接 Group A Assignment。S-03 banner（[`parked-branch-archive-hygiene-2026-09-11.md#L6`](../plans/parked-branch-archive-hygiene-2026-09-11.md#L6)）明确：下方 SUG-05 `Proposed` header 是历史记录上下文，**不**授权 Group A（权威是 Assignment / AUTH / PD），也 **不**授权 Group B。这满足“Proposed header 不是当前 Group A 权威”。HEAD `234d180` 已带 Active + S-03；工作树只把 Status 更新为 Group A **executed**。转变是故意的，不是从 review 或 validator 推断出来的。

### 6. Assignment 完整性与 `UNKNOWN`

对照 [`ASSIGNMENT_POLICY.md#L137-L161`](../ASSIGNMENT_POLICY.md#L137)：Task ID、Assignment Authority、Decision Source/Date、Scope、Non-goals、单一 Domain Owner（Architecture & Knowledge Steward）、Executor、Environment Executor（本会话 GitHub：三个 archive tag 与三个 Group A `origin --delete`、以及 docs-only 功能分支）、Human Dependency（`Not Applicable`，理由：本会话已是 Product 授权且禁止未 tag 的 force-delete）、独立 Architecture/Quality reviewer lanes、Product Approver、Required Inputs、Entry/Exit/Stop、Handoff Target、Lifecycle `Active`、Revalidation Trigger 均已填写。没有必填责任字段为 `UNKNOWN`。P-01 的 `unknown` 是发布身份占位，不是 Policy 意义上的责任 `UNKNOWN`。Active Work 计数 8/10。AUTH `consumption_state` 在 Assignment 仍开放时保持 `unconsumed`，并声明不可复用于 Group B / merge / Release，与 Dashboard 一致。

## Findings

| ID | Severity | Finding / exact boundary | Required residual / disposition |
|---|---|---|---|
| `A-GB-HYG-P2-01` | P2 | 计划已是单一 `Active` lifecycle（[`parked-branch-archive-hygiene-2026-09-11.md#L3-L6`](../plans/parked-branch-archive-hygiene-2026-09-11.md#L3)），S-03 只降权 **Proposed header**。PD 写明其余部分不是当前开发指导，但 `## Execution (for the future Assignment only)` 的 §1（[`#L76-L99`](../plans/parked-branch-archive-hygiene-2026-09-11.md#L76)）仍是可复制的 `git tag -a` / `git push origin`，一次推送六个 tag，含 Group B（`wanxiang-p4-closure-001`、`release-2026-0801-kaomoji`、`release-2026-08-01-coordination-next`）。顶栏 Status 与 AUTH exclusions 并未授权这些命令；现场也确认 Group B tag 不存在。零上下文读者若把 Active 计划正文当成本片当前指导，会把 Group B tag-push 误读为仍在本 Assignment 内。这是计划正文的 Source-of-Truth 卫生缺口，不是已发生的范围执行。 | **`fix`。** 在同一 docs-only 包内给 Execution §1 的 Group B 命令加 S-03 / “out of this Active slice” 标记，或把可执行块收窄为已执行的三个 Group A tag。不要在本 Assignment 下创建或推送 Group B tag。 |

没有发现 P0、P1 或 P3 finding。权威链本身没有把 Group B / #101 / #102 / Scheme Platform / merge / Product Gate / Swift / SUG-08 纳入当前切片；`A-GB-HYG-P2-01` 不改变 AUTH 排除项，也不把唯一 Group A 提交表述为已合入 `main`。

计划文末 Handoff（“create Assignment + Authorization to execute Group A”）已过时，但落在 S-03 所覆盖的 SUG-05 Proposed 包叙述里，且顶栏 Status 已指向已执行的 Group A Assignment；不单列 finding。

## 结论与计数

**Architecture verdict: Pass with conditions.** 不是 HOLD。Assignment → AUTH → Accepted PD 只绑定 Group A tag-then-delete、证据、独立文档审查、以及禁止 merge 的 docs-only PR。三个唯一 tip 经 annotated tag 归档且 `NOT_ON_MAIN`。AGENTS.md 默认清理规则未被改写。必填责任字段无 `UNKNOWN`。`A-GB-HYG-P2-01` 要求在同一 docs-only 包内修正 Active 计划里仍可执行的 Group B tag 配方，以免 `Active` 正文与 PD“其余部分不是当前指导”冲突。

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 1 |
| P3 | 0 |

## Residual 与非结论

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `A-GB-HYG-P2-01` | Executor / Domain Owner（本 docs-only 包） | `fix` | [`parked-branch-archive-hygiene-2026-09-11.md#L76-L99`](../plans/parked-branch-archive-hygiene-2026-09-11.md#L76) |

- 不需要新增 `TECH_DEBT`：可在本 Assignment 的 docs-only 范围内修复。
- Assignment 仍需独立 Quality document review；本 Architecture 结论不代替 Quality，不关闭 Assignment，不授权 docs PR merge。
- P-01 在 docs commit / push / PR 之后才应填写真实 SHA 与 `pr_state`；当前 `unknown`/`none` 是诚实占位。
- 本审查不把 archive tag 当成 merge，不把 Dashboard / Active Work 当成授权源，不把 Proposed header 当成当前 Group A 或 Group B 权威，也不授权 Group B、#101、#102、Scheme Platform、Product Gate、TestFlight、Release、Swift 或 SUG-08。

## Final delta review

审查日期：`2026-09-11 Asia/Shanghai`。本次只复核 Executor 对 `A-GB-HYG-P2-01` 的计划 Execution 修正，并以当前工作树中的 Assignment、AUTH、Accepted Product Decision 作为范围交叉检查；未修改任何被审查 owner 文件，未 commit / push / tag / delete。

### Final delta 基线

| Input | Current SHA-256 |
|---|---|
| [parked-branch plan](../plans/parked-branch-archive-hygiene-2026-09-11.md) | `56c657e6d27ddca6fb7957e2facad70205ff256eb8e6bde2ce1bd22b544abbb0` |
| [`GIT-BRANCH-ARCHIVE-HYGIENE-001` Assignment](../assignments/git-branch-archive-hygiene-001.md) | `b68601ca9c738548339a75dee9cb2839d98655c460b528dcf750c77a8ff3828c`（相对初审未变） |
| [Group A evidence](../evidence/git-branch-archive-hygiene-001-group-a-2026-09-11.md) | `3d638b9a7fb0cacc3f5ecd673bc94a020bbdefe2e008d870effa3981c0b2ee3f`（相对初审未变） |

`git diff --check` 通过。本 delta 未再跑 `ls-remote`；初审的 origin tag / empty Group A heads / Group B 未 tag 结论仍适用。

### Delta 复核

1. **`A-GB-HYG-P2-01` 已关闭（resolved）。** Execution 不再标题为 “for the future Assignment only”，并声明当前 Active slice 仅为 Group A、其余正文不是现在要跑的命令（[`parked-branch-archive-hygiene-2026-09-11.md#L55-L61`](../plans/parked-branch-archive-hygiene-2026-09-11.md#L55)）。§1 只记录三个已执行 Group A tag 映射（`text` 块，无 `git tag` / `git push`）（[`#L68-L78`](../plans/parked-branch-archive-hygiene-2026-09-11.md#L68)）。Group B 原 Proposed tag 名仅出现在 S-03 / out-of-slice 说明中，明确禁止在本 Assignment 下 `git tag` 或 `git push`（[`#L80-L84`](../plans/parked-branch-archive-hygiene-2026-09-11.md#L80)）。§3 为 “Stop. Do not tag. Do not delete.”（[`#L92-L94`](../plans/parked-branch-archive-hygiene-2026-09-11.md#L92)）。Handoff 已指向本 Assignment 与独立的 docs-PR merge / 未来 Group B Assignment（[`#L108-L112`](../plans/parked-branch-archive-hygiene-2026-09-11.md#L108)）。可复制的六 tag `git tag -a` / `git push origin` 块已不存在。

2. 未发现新架构 finding。权威链、归档-非-merge 表述、AGENTS.md 未泛化例外、排除项与无必填 `UNKNOWN` 的初审结论不变。

### Final 结论与计数

**Architecture verdict: Pass**（conditions cleared）。`A-GB-HYG-P2-01` 已 resolved；本 final delta 不扩大授权链或审查边界。

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 0 |
| P3 | 0 |

### Residual（final）

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `A-GB-HYG-P2-01` | Executor / Domain Owner（本 docs-only 包） | `resolved` | [`parked-branch-archive-hygiene-2026-09-11.md#L55-L94`](../plans/parked-branch-archive-hygiene-2026-09-11.md#L55) |

Quality review 仍是独立后续 gate。本 Architecture Pass 不代替 Quality 结论，不关闭 Assignment，不授权 docs PR merge、Group B、#101/#102、Scheme Platform、Product Gate、TestFlight、Release、Swift 或 SUG-08。
