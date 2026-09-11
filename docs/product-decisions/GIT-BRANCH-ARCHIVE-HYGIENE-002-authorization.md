# Product Decision: GIT-BRANCH-ARCHIVE-HYGIENE-002 — Group B 只打 archive tag

## Current Status

| Field | Value |
|---|---|
| Status | Accepted — Group B annotated tags only |
| Decision | Push annotated archive tags for the three Group B local-only tips so unique commits are reachable on `origin` without deleting the branch names. |
| Non-claims | No branch delete; no merge of unique commits onto `main`; no #101/#102; no Scheme Platform; no Product Gate / TestFlight / Release; no Swift |
| Next | Executor tags + evidence + independent document reviews + docs-only PR; Human separately authorizes merge of that PR and any later delete |

---

**Product Approver:** Human Product Owner / Product Lead

**Decision source / date:** Current Grok session `2026-09-11 Asia/Shanghai`, after “批准合并 #118，然后继续按照KOS设定完成 Group B 的相关工作吧。”

**Assignment:** [GIT-BRANCH-ARCHIVE-HYGIENE-002](../assignments/git-branch-archive-hygiene-002.md)
**Authorization:** [AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-002](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-002.md)

This is the successor slice named by
[`GIT-BRANCH-ARCHIVE-HYGIENE-001`](../assignments/git-branch-archive-hygiene-001.md)
A-01 (“new bounded Assignment”). It implements the plan’s Group B rule:
**tag only; do not delete until a later Human decision.**
