# Assignment: GIT-BRANCH-ARCHIVE-HYGIENE-004 — 合并后分支与 worktree 清理（第一批）

Policy version: `1.0.0`
record_id: GIT-BRANCH-ARCHIVE-HYGIENE-004

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Assigned` |
| **Phase** | 记录已登记；S1 / S2 未开始 |
| **Non-claims** | 本记录不执行删除；不改 GitHub 设置；不声称 Product Gate / TestFlight / Release |
| **Next** | 本记录进入 `origin/main` 后，由 Human 的阶段任务包分别授权 S1 与 S2 |
| **Residuals** | （执行时填） |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner，2026-10-26 Asia/Shanghai，对话决定 `1A 2A 3A 4A 5A 6A 7B`。背景原话：“我们这段时间都只是 merge，但是之后的分支、worktree 好像都没有安全清理，这应该要纳入我们的 KOS 之中，不能造成堆积才是”。
- **Product Approver:** Human Product Owner
- **Predecessor:** Closed [GIT-BRANCH-ARCHIVE-HYGIENE-001](git-branch-archive-hygiene-001.md)、[GIT-BRANCH-ARCHIVE-HYGIENE-002](git-branch-archive-hygiene-002.md)、[GIT-BRANCH-ARCHIVE-HYGIENE-003](git-branch-archive-hygiene-003.md)

## Boundary

### Objective

登记第一批合并后清理与只读比对，并在 `AGENTS.md` 写入合并后清理规则。本记录本身不执行删除。

### Scope

1. **S1** 执行第一批清理。对象名字如下（20 项，来自外置盘点 C 节；路径只在该外置清单）：
   - worktree 与分支：`BUILD167-D4-ASSIGNMENT-LANDING-001` / `docs/build167-d4-assignment-001`；`BUILD167-FEEDBACK-ASSIGNMENT-LANDING-001` / `docs/build167-feedback-assignment-001`；`BUILD167-FEEDBACK-FIX-LANDING-001` / `docs/build167-feedback-fix-assignment-001`；`KEYBOARD-UI2-PR217-CI-WHITESPACE-001` / `claude/ui2-pr217-ci-whitespace-001`；`KEYBOARD-VALUES-DOC-001` / `docs/keyboard-values-doc-001`；`LIFECYCLE-CLOSEOUT-BATCH-1C-001` / `docs/lifecycle-closeout-batch-1c-001`；`PF031-PREP-001` / `prep/pf031-001`；`PORTFOLIO-DIRECTORY-001` / `docs/portfolio-directory-001`；`PORTFOLIO-REFRESH-001` / `docs/portfolio-refresh-001`；`PORTFOLIO-REFRESH-002` / `docs/portfolio-refresh-002`；`PORTFOLIO-REFRESH-003` / `docs/portfolio-refresh-003`；`PORTFOLIO-REFRESH-004` / `docs/portfolio-refresh-004`；`PORTFOLIO-REFRESH-005A` / `docs/portfolio-refresh-005a`；`RELEASE-ASSIGNMENT-LANDING-001` / `docs/release-assignment-landing-001`；`RELEASE-CHECKLIST-REFRESH-001` / `docs/release-checklist-refresh-001`；`RELEASE-PREP-RECORD-001` / `docs/release-prep-record-001`；`UI3-FONT-001` / `feature/ui3-font-001`；`UI4-SPIKE-001-CLOSEOUT-001` / `docs/ui4-spike-001-closeout-001`
   - 仅分支：`docs/ui3-pd-landing-001`；`docs/ui4-pd-landing-001`
   - 方式：执行前拉取最新远端，并逐项复查已并入 `origin/main`、未提交改动为 0、不受保护；安全删除（`worktree remove` 不加 `--force`、`branch -d`、`push --delete`）。任何一项不满足就跳过该项。回执写到外置任务目录。
2. **S2** 4A 与 5A 的逐个只读比对：只出报告，删除另批。

### Non-goals

- 受保护对象：B-001 工作区与分支、`preserve/`、`local/`、`backup`、有未提交改动的、进行中任务的、其它工具目录。
- 强制删除。
- 改 GitHub 设置（6A 由 Human 操作）。
- 7B（`~/.codex`、`~/.grok`、`~/.lody` 下的 worktree 由 Human 手动处理）。
- 任何代码、产品或 RIME 改动。

### Required Inputs

| 输入（相对 `~/.kos-work/Universe-Keyboard/`） | SHA-256 |
|---|---|
| `GROK-BOT-TRIAL-026/reports/branch-worktree-inventory.md`（盘点，含 C 节第一批 20 项与 D 节流程草案） | `1c6ff10aa3802e8ab62893b381ff8e4c8bf374a3b338b92ce39dafdf4c712dbb` |
| `GROK-BOT-TRIAL-026/reports/quality-review.md`（Pass） | `52a3cd964e10c7041ffd90723b0e88f53295f1ef3014bf5ae3637a046f40fede` |

- Human 决定 `1A 2A 3A 4A 5A 6A 7B`（2026-10-26 Asia/Shanghai）。
- 先例：[GIT-BRANCH-ARCHIVE-HYGIENE-001](git-branch-archive-hygiene-001.md) 至 [GIT-BRANCH-ARCHIVE-HYGIENE-003](git-branch-archive-hygiene-003.md)。
- `AGENTS.md`「GitHub 发布与分支清理」。

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward（出处：[docs/VIRTUAL_ENGINEERING_TEAM.md](../VIRTUAL_ENGINEERING_TEAM.md) 长期角色表；与 [GIT-BRANCH-ARCHIVE-HYGIENE-003](git-branch-archive-hygiene-003.md) 相同写法）
- **Executor:** Codex（S1）；Grok bot（S2，只读）
- **Environment Executor:** Codex（本机 git 与 `gh`）
- **Human Dependency:** 每批授权；6A 与 7B 的操作
- **Architecture Reviewer:** Not Applicable — 只涉及 git 引用卫生，不涉及产品或架构
- **Quality Reviewer:** 独立 Quality，负责复核回执
- **Handoff Target:** Human Product Owner（阶段任务包授权）；独立 Quality（回执复核）

## Gates

### Entry Criteria

- 本记录合并进 main。
- 有 Human 的阶段任务包授权。

### Exit Criteria

- S1 回执经独立复核。
- S2 报告交付。
- 剩余对象逐项列出处置去向。

### Stop Conditions

- 任何安全删除被拒。
- 复查不满足。
- 需要 force。
- 对象受保护。
- 远端状态无法确认。

## Reports / Exit evidence

（执行时填）

## Closeout

由 Human 决定。

## Handoff

- **Required Handoff Content:** S1 回执路径与 SHA-256；S2 报告；跳过项与剩余对象处置去向。
- **Revalidation Trigger:** main 变化导致某项不再满足复查条件；有新任务开始使用清单中的对象。

## History

- `2026-10-26 Asia/Shanghai` — Human 决定 `1A 2A 3A 4A 5A 6A 7B`。本记录以 Lifecycle `Assigned` 登记；删除尚未执行。
