# Product Decision: GIT-BRANCH-ARCHIVE-HYGIENE-001 — 执行 Group A 归档卫生

## Current Status

| Field | Value |
|---|---|
| Status | Accepted — Group A complete; Assignment Closed after PR #118 |
| Decision | Execute the Group A slice of [`parked-branch-archive-hygiene-2026-09-11.md`](../plans/parked-branch-archive-hygiene-2026-09-11.md): annotated archive tags, push those tags, then delete the three named local and remote branches. Unique commits remain reachable via tags, not via `main`. |
| Non-claims | This PD still does not authorize Group B delete, #101/#102, Product Gate, TestFlight, Release, or Swift. Merge of #118 was a later Human authorization. |
| Next | Assignment Closed after PR #118 merge. Group B tags are [`GIT-BRANCH-ARCHIVE-HYGIENE-002`](../assignments/git-branch-archive-hygiene-002.md) |

---

**Product Approver:** Human Product Owner / Product Lead

**Decision source / date:** Current Grok session `2026-09-11 Asia/Shanghai`, “请严格按照KOS要求继续你所建议的关于group A的相关工作吧。”

**Assignment:** [GIT-BRANCH-ARCHIVE-HYGIENE-001](../assignments/git-branch-archive-hygiene-001.md)
**Authorization:** [AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001.md)

This decision promotes only the Group A slice of the SUG-05 Proposed packet into
implementation. It does not make the remainder of that plan current development
guidance. Reachability for the deleted branch names is the pushed archive tag,
which is an explicit, bounded exception to the default AGENTS.md rule that a
feature branch may be deleted only when its tip is an ancestor of `origin/main`.
