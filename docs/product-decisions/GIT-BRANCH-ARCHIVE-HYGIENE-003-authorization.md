# Product Decision: GIT-BRANCH-ARCHIVE-HYGIENE-003 — Group B 分支名全部保留

## Current Status

| Field | Value |
|---|---|
| Status | Accepted — keep all three Group B local branch names |
| Decision | Do **not** delete `codex/wanxiang-p4-closure-001`, `codex/release-2026-0801-kaomoji`, or `codex/release-2026-08-01-coordination-next`. Archive tags already on `origin` remain the recovery path. Unique commits stay off `main`. |
| Non-claims | No merge of unique commits onto `main`; no #101/#102; no Scheme Platform; no Product Gate / TestFlight / Release; no Swift |
| Next | Record the disposition, independent document reviews, docs-only PR; Human separately authorizes merge of that PR |

---

**Product Approver:** Human Product Owner / Product Lead delegated the keep/delete judgment to the Executor under KOS in the current session `2026-09-11 Asia/Shanghai`: “请你按照KOS设定来决定要不要删 Group B 分支吧.”

**Assignment:** [GIT-BRANCH-ARCHIVE-HYGIENE-003](../assignments/git-branch-archive-hygiene-003.md)
**Authorization:** [AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-003](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-003.md)

Fail-closed rule used: after tags exist, deleting a **name** is safe for commits, but it is not allowed when the tip is still a live pointer for a Paused or Active Assignment, or when unique unmerged product/test code has not been Product-rejected and the parent program is still Active.
