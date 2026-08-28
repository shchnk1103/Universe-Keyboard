# TD-016-CI-TIERING-001 — Independent Quality Review

## Review identity

| Field | Value |
|---|---|
| Reviewer | `td016_quality_review`（独立 Quality, Performance & Release reviewer） |
| Date / timezone | `2026-08-28 Asia/Shanghai` |
| Frozen head | `b000c91` on PR #87; base `6bf7017` from PR #86 |
| Independence | 只读核对现有测试与 hosted logs；未修改文件、提交、推送、PR 或 Gate |
| Hosted evidence | Runs [`33165797218`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33165797218) and [`33166502457`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33166502457) |

## Verdict

**Pass with conditions；当前 Claim 证据不完整。**

最小 allowlist、unknown/empty/rename fail-closed、Final Gate matrix、未削弱的 heavy suite，以及
当前 HEAD hosted full path 均通过。下列条件须修复或取得证据：

| ID | Severity | Disposition | Finding |
|---|---|---|---|
| Q-87-01 | P1 | `fix` | KOS validator 触发范围漏 `UPGRADE_STATUS.md` 与 `upgrade-records/**`，并缺回归 fixture。 |
| Q-87-02 | P2 | `fix` | invalid base/head/non-commit 行为虽手测 fail closed，但没有自动化 fixture。 |
| Q-87-03 | P2 | `tech_debt:TD-016` | 尚无真实 hosted docs-only → heavy skipped → final success 证据。 |
| Q-87-04 | P2 | `fix` | 当前 HEAD `b000c91` / run `33166502457` 与 Changelog 尚未同步。 |

## Evidence disposition

- 本地 Xcode 27 beta 模拟器崩溃记录诚实；hosted App/Keyboard suite 已通过，不把本地失败重写为 pass。
- 物理设备、TestFlight、签名和 Release 不属于本 Assignment。
- branch protection/required checks 未授权；当前绿色不是不可绕过的 merge policy。

## Revalidation

首次审查冻结于 `b000c91`；上表与 Verdict 保持不变。
`0623e7c` 与 hosted docs-only fixture 完成后的独立复核见
[Revalidation — 2026-08-28 (post-0623e7c)](#revalidation--2026-08-28-post-0623e7c)。
本文件不授权 Product Accept、merge 或 Release。

## Revalidation — 2026-08-28 (post-0623e7c)

| Field | Value |
|---|---|
| Reviewer | td016_quality_review |
| Frozen implementation | 0623e7c |
| Hosted full-path | 33168928860 |
| Docs-only fixture | PR #88 / 33169007898 (closed without merge) |
| Independence | 只读核对 hosted logs 与测试；仅追加本段 |

### Verdict

**Pass** — 四个原 Quality 条件均已关闭；本复核不授权 Product Accept、merge 或 Release。

### Condition disposition

| ID | 原 finding | Disposition | Evidence |
|---|---|---|---|
| Q-87-01 | KOS validator 触发范围漏 `UPGRADE_STATUS.md` 与 `upgrade-records/**`，并缺回归 fixture | `closed` | `scripts/ci/run_lightweight_checks.sh` 已把 `docs/kos/UPGRADE_STATUS.md` 与 `docs/kos/upgrade-records` 列入 `kos_governance_paths`；回归脚本 `scripts/ci/tests/test_kos_trigger_paths.sh` 由 lightweight runner 调用 |
| Q-87-02 | invalid base/head/non-commit 行为虽手测 fail closed，但没有自动化 fixture | `closed` | `ClassifyPathsTests.test_invalid_base_head_and_non_commit_references_fail_closed` 覆盖 missing-base、missing-head 与 blob/non-commit 四对；`classify_changes.py` 对非 commit 抛 `ValueError` 并以 exit 2 fail closed |
| Q-87-03 | 尚无真实 hosted docs-only → heavy skipped → final success 证据 | `closed` | 临时 Draft PR [#88](https://github.com/shchnk1103/Universe-Keyboard/pull/88) 精确 diff 仅 `docs/evidence/td-016-docs-only-hosted-fixture.md`；run [`33169007898`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33169007898) `classify-change` 4s success、`lightweight-checks` 6s success、`build-and-test` skipped、`final-quality-gate` 5s success。Classifier JSON：`{"classification": "docs_only", "requires_full": "false", "reason": "all_paths_in_lightweight_allowlist", "changed_count": "1", "base_sha": "0623e7c489679d42dbda2d8d612a5d16c19e88d1", "head_sha": "216267b3e886cb0e127b33e2869b06292d951b78", "full_required_paths": []}`。`merged_at=null`，关闭评论记录证据落在 #87。绿色 skip 不是 merge policy |
| Q-87-04 | 当前 HEAD `b000c91` / run `33166502457` 与 Changelog 尚未同步 | `closed` | 分支 tip `ef200bb` 的 `CHANGELOG.md` 已记录 `33165797218`、`33166502457`、修复提交 `0623e7c` / run `33168928860`，以及 fixture PR #88 / `33169007898` |

### Evidence notes

- 核对方式：本地 `.git/HEAD` = `codex/td016-ci-tiering` → `ef200bb`（`0623e7c` 的 docs-only 子提交）；GitHub Actions REST jobs API + 公开 run HTML。本 reviewer 沙箱不能执行 `gh run view`，也不能在未登录时读取 step log；分类 JSON 以 #88 公开 API 的 base/head/changed_files=1 与 jobs 结论交叉核对，full-path 以 heavy job 实际执行为准。
- Frozen implementation run [`33168928860`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33168928860)：`head_sha=0623e7c`，`conclusion=success`。Jobs：`classify-change` 5s success；`lightweight-checks` 6s success；`build-and-test` **10m22s success**（含 `Test app and keyboard contracts on iOS Simulator` success）；`final-quality-gate` 5s success。PR #87 在 `0623e7c` 为 28 files、tip `ef200bb` 为 29 files，且含 `.github/workflows/swift6-quality.yml` 与 `scripts/ci/**`，与 `full` / `requires_full=true` 一致。
- 本地 Xcode 27 beta App 崩溃仍按 Executor 记录为 environment-blocked，**不得改写为 pass**。决定性证据是 hosted `macos-26` 的 App/Keyboard 步骤。
- 当前 tip `ef200bb` 另有 run [`33169956232`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33169956232) 在复核时仍 `in_progress`（PR 对 #86 base 仍含 workflow/scripts，故走 full）。它不是冻结实现，也不替代 `33168928860`。
- branch protection / required checks 未授权。hosted 绿色、docs-only skip 与本 Pass 都不是不可绕过的 merge policy，也不许可 `CLAIM.CI.TIERING_FAIL_CLOSED`。
- Architecture 的 `A-P2-02`（PR-head 不是独立 trust root）仍是 TD-016 残余，不在本 Quality 四项内重开为 `fix`。
