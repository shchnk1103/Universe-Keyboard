# GIT-BRANCH-ARCHIVE-HYGIENE-001 — Quality Review

## 基线与范围

- **Reviewer:** 独立 Quality runtime，lane
  `GIT-BRANCH-ARCHIVE-HYGIENE-001/document-quality`。本审查未撰写
  Assignment / AUTH / Product Decision / evidence，也未执行 tag 或
  `git push origin --delete`。
- **Worktree:** `/private/tmp/universe-keyboard-group-a-hygiene`，分支
  `docs/git-branch-archive-hygiene-001`。
- **Git 基线：** `HEAD`
  `234d180f0f6abccc171fc2898e40b09aa128a2f1`；`origin/main`
  `6b24c37dcf8b5c7bed0a995739c054ae20fd7c04`（PR #117）。审查对象包含该
  HEAD 上已提交的 AUTH / PD，以及工作区未提交的 Assignment、plan、
  `ACTIVE_WORK`、Dashboard 更新和未跟踪 evidence。
- **审查范围：**
  `docs/evidence/git-branch-archive-hygiene-001-group-a-2026-09-11.md`、
  `docs/assignments/git-branch-archive-hygiene-001.md`、
  `docs/authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001.md`、
  `docs/product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-001-authorization.md`、
  `docs/plans/parked-branch-archive-hygiene-2026-09-11.md`、
  `docs/ACTIVE_WORK.md`、`docs/ENGINEERING_DASHBOARD.md`；并对 Group A
  archive tags、三个已删分支名、#101/#102 heads、Group B 本地 tip 做只读
  `git rev-parse` / `git ls-remote` 复核。
- **排除：** Swift / Xcode、hosted CI、D-01 final-documentation receipt、
  Product Gate / TestFlight / Release、docs PR 的 push/open/merge、Group B
  tag 或 delete、对 `codex/scheme-platform-001` 或 #101/#102 的任何变更、
  把 unique Group A commits 合入 `main`。

## 结论与 Finding 统计

**Pass**

| 严重级别 | 数量 |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 0 |
| P3 | 0 |

## 审查结果

- Evidence 各观测行的 Grade 均为 `Executor-recorded`（KOS 2.1 M-04 三值之一）。
  未使用第四种等级，也未把 Executor 结果写成 Quality-verified /
  Quality-reverified 或 Device-attested。Non-claims 明确本包在独立 Quality
  复核之前不是 Quality-reverified
  （`docs/evidence/git-branch-archive-hygiene-001-group-a-2026-09-11.md:16-62,75-81`）。
  本审查对 git refs 的只读重跑只记录在本文件，未改 evidence。
- Open-PR abort check 已记录：执行时 `gh pr list --state open` 仅 #102
  （`codex/scheme-platform-001`，draft）与 #101
  （`docs/adr-0034-architecture-accept-checklist`，draft），均不在 Group A
  allowlist。关闭确认 #103 / #88 / #46 CLOSED
  （evidence `:22-31`）。本审查重跑 `gh pr list --state open` 仍仅 #101 /
  #102；`gh pr view` 确认 #103 / #88 / #46 为 CLOSED 且 `mergedAt` 为空。
- Group A 三个 annotated tag 名、tag object SHA、peeled `^{}` commit 与
  “branch gone” 声明内部一致；unique commits 仍 `NOT_ON_MAIN`。复核表见下节。
- Group B 三个本地 tip 仍在，且没有
  `archive/codex-wanxiang…` / `archive/codex-release-2026-0801-kaomoji…` /
  `archive/codex-release-2026-08-01-coordination-next…` 本地或 `origin` tag。
- AUTH `kos-record` JSON 可解析。`action` =
  `execute_group_a_parked_branch_archive`，`target` =
  `GIT-BRANCH-ARCHIVE-HYGIENE-001`，`exclusions` 覆盖 Group B tag/delete、
  #101/#102、Scheme Platform、merge、Release、TestFlight、Product Gate、
  ADR Accept、Swift、SUG-08、未打 tag 的 unique tip 强删，与 Assignment
  Non-goals / frontier 一致。`status` / envelope 为 `active`，
  `consumption_state` = `unconsumed`（docs 包与独立审查尚未收口）。
- `ACTIVE_WORK` 第 8 行 Lifecycle = `Active`，阶段为 Group A tags 已上
  `origin`、三个分支名已删、等待独立审查与 docs PR、无 Group B / merge；
  Dashboard 同名条目 Lifecycle `Active`、Next 为独立文档审查且 merge 另闸。
  与 Assignment Current Status（`Active`；Phase = tags pushed and branch
  names deleted; awaiting independent Architecture/Quality document
  reviews, then docs-only PR）一致。本表仍 ≤10。
- Assignment 将 E-01 / D-01 标为 Not applicable，P-01 在 docs commit 之前
  保持 unknown / none；本审查不把 markdown link check 升级为 D-01。

## Quality-reverified git-ref 复核（本审查，只读）

Grade：`Quality-reverified`。命令未改写任何 ref。

| 检查 | 结果 |
|---|---|
| `git rev-parse archive/codex-kos-v080-upgrade-review/20260911` | `6a12c2d6bae019186a45f746700c2dc6430d5e59`（annotated tag object；`git cat-file -t` = `tag`） |
| `git rev-parse archive/codex-kos-v080-upgrade-review/20260911^{commit}` | `7e090bd4a31d79a19cfa5e8d3b58ccfe60d92f34` |
| `git rev-parse archive/codex-td016-docs-only-fixture/20260911` | `19853f87c86b0b51f9d99fb13e95f04cf1c9851d`（`tag`） |
| `git rev-parse archive/codex-td016-docs-only-fixture/20260911^{commit}` | `bd4b6eb14c6e4b25c60d66807ceb1e0b67cc8ac4` |
| `git rev-parse archive/docs-t9-single-key-mixed-candidates-discussion/20260911` | `64c77be251e796fc859ca1d579e0f0891416fa10`（`tag`） |
| `git rev-parse archive/docs-t9-single-key-mixed-candidates-discussion/20260911^{commit}` | `270f45b954d1a3f49f623059cf9e0b874c640061` |
| `git ls-remote --tags origin` 上述三枚 | 每枚同时给出 tag object 与 `^{}` peel，SHA 与上表一致 |
| `git ls-remote --heads origin` `codex/kos-v080-upgrade-review` / `codex/td016-docs-only-fixture` / `docs/t9-single-key-mixed-candidates-discussion` | 空（branch gone） |
| 本地 `git show-ref --heads` 上述三名 | 无匹配 |
| `git ls-remote --heads origin` `codex/scheme-platform-001` | 仍存在 `d8e8299dcb608cdb8e976604add7b6d744012757` |
| `git ls-remote --heads origin` `docs/adr-0034-architecture-accept-checklist` | 仍存在 `889bb4e7e4b6be4e784ecf7c10f53ead41ddcb43` |
| 本地 Group B tips | `codex/wanxiang-p4-closure-001` = `e83e6358de8621e24522294542539d029c91b080`；`codex/release-2026-0801-kaomoji` = `d3680c347181d65703327b324951b6d931d637aa`；`codex/release-2026-08-01-coordination-next` = `3444826983bb7b4e49ef96f9eb165964880ca8b9` |
| Group B archive tags | 本地 `git tag -l` 与 `git ls-remote --tags origin 'archive/codex-wanxiang-p4-closure-001/*'` 等均为空 |
| `git merge-base --is-ancestor <tip> origin/main` | 三个 Group A tip 均为 `NOT_ON_MAIN` |

Evidence 表中 peeled 列使用 `7e090bd4…` 形式，同表 Tip commit 列为完整 SHA；
前缀与本审查剥出的完整 `^{commit}` 一致。`git rev-parse <tag>`（无 `^{commit}`）
返回 tag object 而非 tip，与 annotated tag 语义一致；evidence 已分列 tag
object 与 peeled commit。

## 验证

- `git diff --check origin/main` 与工作区 `git diff --check`：通过。
- Authorization `kos-record` JSON：`json.loads` 通过；`record_id`、
  `status=active`、`action`、`target`、`exclusions`、
  `consumption_state=unconsumed` 与 Assignment 当前切片一致。
- `python3 scripts/ci/check_markdown_links.py --base origin/main --head HEAD`：
  `PASS changed Markdown links (6 files)`。
- 复用同一脚本的本地目标解析，对工作区七个范围文件（含未跟踪 evidence）：
  通过，未发现缺失的 repository-local link target。
- 只读 git / `gh` 复核：通过（见上表）。未运行 Swift/Xcode、完整 KOS Kit、
  hosted CI 或 publication。这些未运行项没有被记为 pass，也不被本 review
  当作 D-01、Product、Architecture、merge 或 Release 证据。

## Findings

无。

## Residual

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| GBAH-Q-R01 | Architecture Reviewer | `accept` | Assignment Exit 仍要求独立 Architecture document review；本 Quality 输入不替代该审查。 |
| GBAH-Q-R02 | Executor / Human Product Owner | `accept` | Docs-only feature branch 尚未 push、PR 尚未打开；merge 未授权，且不是本审查出口。 |
| GBAH-Q-R03 | Executor | `accept` | Evidence 与 Assignment / ACTIVE_WORK / Dashboard / plan 的 Group A 收口文字仍在工作区（evidence 未跟踪）；提交后 P-01 `local_candidate` 才可填写。不把当前 HEAD `234d180` 写成已含 evidence 的 published head。 |

本审查不关闭 Assignment，不消费 AUTH，不授权 Group B、#101/#102、merge 或
Release。

## 未运行

- 任何 Swift / `xcodebuild` / KeyboardCore 测试。
- D-01 final-documentation receipt（Assignment 明确 Not applicable）。
- hosted CI、docs PR open/undraft/merge、tag 新建、分支删除、force-push。
- Group B 归档或删除。
- Product Gate / TestFlight / Release / ADR Accept / SUG-08。

## Plan-only delta — Architecture residual A-GB-HYG-P2-01

本 delta 只复核工作区 plan 修复，未重跑 origin `ls-remote`，也未改 git refs。
先前 Quality-reverified 的 tag object / `^{commit}` / branch-gone / Group B
未打 tag 结果仍然有效，不因文档改写而变化。

Active `## Execution`（至 Recovering 之前）已无 `git tag -a`、无
`git push origin`、无 Group B archive 命令块；§1 仅为已执行 Group A tag 名
的 `text` 清单，§3 为 Stop / do not tag / do not delete。文中出现的
`git tag` / `git push` 仅是否定禁令（S-03），不是可执行命令。

`git diff --check origin/main` 与工作区 `git diff --check`：通过。
`python3 scripts/ci/check_markdown_links.py --base origin/main --head HEAD`
仍为 `PASS changed Markdown links (6 files)`；该脚本只看已提交 HEAD，看不到
未提交 plan。对工作区
`docs/plans/parked-branch-archive-hygiene-2026-09-11.md` 复用同一本地目标解析：
通过。本检查不是 D-01。

无新增 P0/P1/P2/P3。最终结论仍为 **Pass**，P0/P1/P2/P3 = **0/0/0/0**。
GBAH-Q-R01 仍 `accept`：本 Quality delta 不关闭 Architecture 审查本身。
