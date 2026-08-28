# TD-016-CI-TIERING-001 — Independent Architecture Review

## Review identity

| Field | Value |
|---|---|
| Reviewer | `td016_arch_review`（独立 Architecture & Knowledge Steward reviewer） |
| Date / timezone | `2026-08-28 Asia/Shanghai` |
| Frozen head | `b000c91` on PR #87; base `6bf7017` from PR #86 |
| Independence | 只读核对；未修改文件、提交、推送、PR、Gate 或 GitHub 设置 |
| Scope | 分类权威、ADR/Source of Truth、job 依赖、KOS advisory 边界、stack 与 required-check 残余 |

## Verdict

**Pass with conditions；当前不可进入 Reviewed 或 merge-ready。**

核心 fail-closed 架构、权限和 PR/push job 依赖成立；两次 hosted full-path 运行通过。
以下条件必须修复并由独立 reviewer 复核：

| ID | Severity | Disposition | Finding |
|---|---|---|---|
| A-P1-01 | P1 | `fix` | Evidence 结果表使用 KOS M-04 未允许的 `CI-recorded` Grade。 |
| A-P1-02 | P1 | `fix` | Evidence/Changelog 未完整同步 `b000c91` 与 run `33166502457`，且保留已完成事项为 Pending。 |
| A-P1-03 | P1 | `fix` | 新 Product Decision 的 Current Status 缺阶段、非主张、下一决策和残余。 |
| A-P1-04 | P1 | `fix` | `workflow_dispatch` 缺精确 base 时退回 `HEAD^`，可能漏掉多提交分支中的敏感改动。 |
| A-P2-01 | P2 | `fix` | KOS validator 触发路径未覆盖 `docs/kos/upgrade-records/**`。 |
| A-P2-02 | P2 | `tech_debt:TD-016` | Workflow/classifier/final Gate 来自 PR head，不是未来 required-check 的独立 trust root。 |
| A-P2-03 | P2 | `fix` | PR #87 正文缺 KOS S-02 的显式 Stack metadata。 |

## Required evidence

1. 修复所有 `fix` 项并取得当前修复 commit 的 hosted full-path 结果。
2. 建立 hosted docs-only fixture，证明 heavy job 为 `skipped` 且 final Gate 成功。
3. 独立 Architecture 与 Quality revalidation。
4. Human 单独决定 retarget/merge；本 Review 不授权 merge、required checks 或 ADR Accepted。

## Revalidation

首次只读结论冻结于上文 Verdict，不覆盖。复核见下方
[`## Revalidation — 2026-08-28 (post-0623e7c)`](#revalidation--2026-08-28-post-0623e7c)。

## Revalidation — 2026-08-28 (post-0623e7c)

| Field | Value |
|---|---|
| Reviewer | `td016_arch_review` |
| Frozen implementation | `0623e7c` |
| Hosted full-path | [`33168928860`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33168928860) |
| Docs-only fixture | PR [#88](https://github.com/shchnk1103/Universe-Keyboard/pull/88) / [`33169007898`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33169007898) (closed without merge) |
| Independence | 只读核对；仅改本文件的原 Revalidation 指针并追加本段 |

### Verdict

**Pass with conditions** — 首次全部 `fix` 项已关闭；A-P2-02 仍为 `tech_debt:TD-016`。本复核不授权 merge、required checks、ADR Accepted 或 Product Accept。

### Condition disposition

| ID | previous | current | evidence |
|---|---|---|---|
| A-P1-01 | `fix` | `closed` | [`docs/evidence/td-016-ci-tiering-001-implementation-2026-08-28.md`](../evidence/td-016-ci-tiering-001-implementation-2026-08-28.md) 与 [`docs/evidence/td-016-docs-only-hosted-fixture-2026-08-28.md`](../evidence/td-016-docs-only-hosted-fixture-2026-08-28.md) 结果表 Grade 均为 KOS M-04 允许的 `Executor-recorded`；`td-016*` 路径已无 `CI-recorded`。 |
| A-P1-02 | `fix` | `closed` | `0623e7c` 已把 `b000c91` / run [`33166502457`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33166502457) 写入 Evidence；卫生提交 `ef200bb` 再同步 `0623e7c`、[`33168928860`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33168928860)、#88 / [`33169007898`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33169007898)。[`CHANGELOG.md`](../../CHANGELOG.md) 现列出上述三次 full-path 与 docs-only skip；Pending 仅余独立复核、Human merge 与未授权 required-check。 |
| A-P1-03 | `fix` | `closed` | [`docs/product-decisions/TD-016-CI-TIERING-001-authorization.md`](../product-decisions/TD-016-CI-TIERING-001-authorization.md) Current Status 含 Current phase、Material non-claims、Next decision、Residuals；`0623e7c` 已引入该表。 |
| A-P1-04 | `fix` | `closed` | `0623e7c` 对 [`.github/workflows/swift6-quality.yml`](../../.github/workflows/swift6-quality.yml)：`workflow_dispatch.inputs.base_sha` 为 `required`；空/全零 SHA 与非 PR/push/dispatch 事件 `exit 2`；删除 classify 与 Swift format 的 `HEAD^` 回退。[`docs/CI_CHANGE_CLASSIFICATION.md`](../CI_CHANGE_CLASSIFICATION.md) 写明不得用 `HEAD^` 推断分支范围。Hosted full-path [`33168928860`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33168928860) 在 `0623e7c` 上 success（`head_sha=0623e7c`；Evidence 记 merge-ref `5ac87db`）。 |
| A-P2-01 | `fix` | `closed` | [`scripts/ci/run_lightweight_checks.sh`](../../scripts/ci/run_lightweight_checks.sh) 的 `kos_governance_paths` 含 `docs/kos/UPGRADE_STATUS.md` 与 `docs/kos/upgrade-records`；[`scripts/ci/tests/test_kos_trigger_paths.sh`](../../scripts/ci/tests/test_kos_trigger_paths.sh) 断言这三项。目录 [`docs/kos/upgrade-records/`](../kos/upgrade-records/) 存在。 |
| A-P2-02 | `tech_debt:TD-016` | `tech_debt:TD-016` | 仓库仍无 CODEOWNERS、无 `.github` reusable workflow、无 baseline-owned 校验器。`classify-change` / `lightweight-checks` / `final-quality-gate` 均 `actions/checkout@v4` 后执行 PR head 脚本。[`docs/CI_CHANGE_CLASSIFICATION.md`](../CI_CHANGE_CLASSIFICATION.md) 与 [`docs/TECH_DEBT.md`](../TECH_DEBT.md) TD-016 residual 仍声明此点。当前绿色不能当 required-check trust root。 |
| A-P2-03 | `fix` | `closed` | PR [#87](https://github.com/shchnk1103/Universe-Keyboard/pull/87) 正文现含 KOS S-02 所需 `Stack: base=codex/td016-ci-classification-note tip=codex/td016-ci-tiering` 与 `Prefix PR: #86`；base SHA 为 `6bf7017`。 |

### Remaining residuals

- **A-P2-02 / TD-016：** 未来若把 `final-quality-gate` 设为 required，必须另行授权并增加独立 trust root（CODEOWNERS/强制审查、受保护 reusable workflow 或等价 baseline-owned guard）。
- **KOS Kit：** 远端完整 validator 仍因私有 Kit、无 PAT 而未接入；CI 仅 JSON/链接/显式 NOTE。此残余原 ADR 已声明，不是新 `fix`。
- **ADR 0031：** 仍为 Proposed；本复核不把它升为 Accepted。
- **权限边界：** 不授权 merge、branch protection、required checks、Product Accept 或把 #87 并入 #86。#88 已 close without merge（`merged_at=null`），只作 docs-only 证据。
- **本 Architecture 复核范围外：** Quality revalidation 仍待同一独立 Quality reviewer；本文件不关闭 Quality 条件。
