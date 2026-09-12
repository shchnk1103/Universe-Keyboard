# Evidence: GIT-BRANCH-ARCHIVE-HYGIENE-003 Group B keep

**Run date / timezone:** `2026-09-11 Asia/Shanghai`
**Executor:** Current Grok session
**Working copy:** `/private/tmp/universe-keyboard-group-b-keep` (`docs/git-branch-archive-hygiene-003`)
**Baseline:** `origin/main` `bf0e6ec501dacb31044384719b7b3e7941e9eccd` (PR #119)
**Authority:** [`Assignment`](../assignments/git-branch-archive-hygiene-003.md) · [`AUTH`](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-003.md) · [`PD`](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-003-authorization.md)

No ref mutation. Unique commits were not merged to `main`. Branch names were not deleted.

## #119 merge (predecessor)

| Field | Value | Grade |
|---|---|---|
| PR | [#119](https://github.com/shchnk1103/Universe-Keyboard/pull/119) MERGED | `Executor-recorded` |
| Head | `e372268f3ce15c467e4abbf166dd6bfdda902249` | `Executor-recorded` |
| Merge | `bf0e6ec501dacb31044384719b7b3e7941e9eccd` | `Executor-recorded` |
| Hosted CI on head | classify / lightweight / final-quality-gate / GitGuardian SUCCESS; build-and-test SKIPPED | `Executor-recorded` |
| Ancestor | `e372268` is ancestor of `origin/main` | `Executor-recorded` |
| Feature branch | remote deleted; local worktree and branch removed after reachability | `Executor-recorded` |

## Open PRs after merge

Only draft [#101](https://github.com/shchnk1103/Universe-Keyboard/pull/101) and [#102](https://github.com/shchnk1103/Universe-Keyboard/pull/102).

## Keep checks

| Branch | Local tip | Tag peel | `origin` head | Ancestor of `main`? | Unique vs `main` (three-dot) | Live owner | Disposition | Grade |
|---|---|---|---|---|---|---|---|---|
| `codex/wanxiang-p4-closure-001` | `e83e635` | `archive/codex-wanxiang-p4-closure-001/20260911` → `e83e6358…` | empty | NOT_ON_MAIN | checklist/gaps **absent** on `main`; present on Platform branch | Paused Wanxiang P4 Assignment frozen tip | **keep** | `Executor-recorded` |
| `codex/release-2026-0801-kaomoji` | `d3680c3` | `archive/codex-release-2026-0801-kaomoji/20260911` → `d3680c34…` | empty | NOT_ON_MAIN | `KaomojiDataSource.swift`, regression tests, UI contract script **absent** on `main` | `RELEASE-2026-08-01` Active; Task 08 Closed | **keep** | `Executor-recorded` |
| `codex/release-2026-08-01-coordination-next` | `3444826` | `archive/codex-release-2026-08-01-coordination-next/20260911` → `34448269…` | empty | NOT_ON_MAIN | HomeTab no longer links to 输入洞察; Settings hides 智能纠错/输入洞察; typo refresh `#if DEBUG` | Task 06 polish still Active | **keep** | `Executor-recorded` |

Local `git rev-parse` after the decision still returns `e83e635` / `d3680c3` / `3444826`. No `git branch -D`. No `git push origin --delete`.

## Why not Group A-style name delete

Group A required Closed/superseded PRs. These three:

- Wanxiang: **Paused ≠ Closed**; Assignment still cites the branch.
- Kaomoji extra tests: never Product-rejected; parent Release still Active.
- Coordination: unshipped Swift against an Active polish task.

Archive tags already make commits recoverable. Keeping names preserves the live pointer.

## Non-claims

- Unique diffs were not cherry-picked to `main`.
- Not a performance, Product Gate, or Quality pass of those unique diffs.
- Evidence is `Executor-recorded` until independent Quality review.
