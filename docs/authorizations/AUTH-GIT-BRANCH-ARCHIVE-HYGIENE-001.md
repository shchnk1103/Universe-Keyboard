# Authorization: AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001 — Group A 归档卫生

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | Consumed by Closed `GIT-BRANCH-ARCHIVE-HYGIENE-001`. Not reusable for Group B, #101/#102, or Release |

---

Human Product Owner, current session `2026-09-11 Asia/Shanghai`: **“请严格按照KOS要求继续你所建议的关于group A的相关工作吧。”**

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001",
  "record_type": "authorization",
  "title": "Execute Group A parked-branch archive tag-then-delete",
  "status": "consumed",
  "updated_at": "2026-09-11T23:35:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "review_finding", "open_pr_on_target_head"],
  "authorization": {
    "action": "execute_group_a_parked_branch_archive",
    "target": "GIT-BRANCH-ARCHIVE-HYGIENE-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/plans/parked-branch-archive-hygiene-2026-09-11.md"},
      {"kind": "ref", "identity": "codex/kos-v080-upgrade-review"},
      {"kind": "ref", "identity": "codex/td016-docs-only-fixture"},
      {"kind": "ref", "identity": "docs/t9-single-key-mixed-candidates-discussion"}
    ],
    "scope": "Create the bounded Assignment and matching records; revalidate Group A tips; create and push annotated archive tags for those three tips; delete the three local and origin branch names only after each matching tag is on origin and points at the tip; record evidence; independent Architecture/Quality document review; commit and push the docs-only feature branch; open a docs-only PR. Do not merge that PR.",
    "exclusions": ["group_b_tag", "group_b_delete", "scheme_platform_001", "pull_request_101", "pull_request_102", "merge", "release", "testflight", "product_gate", "adr_accept", "swift_change", "sug_08", "force_delete_untagged_unique_tip"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-11 Asia/Shanghai instruction: 请严格按照KOS要求继续你所建议的关于group A的相关工作吧。",
    "issued_at": "2026-09-11T23:11:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

> **Consumed:** [GIT-BRANCH-ARCHIVE-HYGIENE-001](../assignments/git-branch-archive-hygiene-001.md) Closed after PR #118 merge.
> Merge used [AUTH-…-MERGE](AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001-MERGE.md). Group B tags are Assignment 002.
