# Authorization: AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-MERGE-001 — squash-merge PR #164 and bounded follow-up

## Current Status

| Field | Value |
|---|---|
| Status | `active` |
| Assignment | [`SCHEME-LICENSE-DOWNLOAD-CTA-MERGE-001`](../assignments/scheme-license-download-cta-merge-001.md) |
| Issuer | Human Product Owner |
| Decision source | Current session: “GitHub CI 已全绿，授权 merge，并处理后续工作。” |
| Consumer | Current Codex task |
| Action | Mark PR #164 ready, squash-merge the bound head, verify merge provenance, safely remove the old feature branch, and prepare one docs-only post-merge M-02 status-sync PR |
| Issued at | `2026-09-24T10:11:38+08:00` |
| Boundary | No direct push to `main`; the status-sync PR may be opened but not merged under this Authorization |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-MERGE-001",
  "record_type": "authorization",
  "title": "Squash-merge PR 164 and complete bounded post-merge follow-up",
  "status": "active",
  "updated_at": "2026-09-24T10:11:38+08:00",
  "revalidation_triggers": ["pr_head_changed", "pr_base_changed", "ci_not_green", "merge_state_changed", "authority_revoked"],
  "authorization": {
    "action": "squash_merge_pr_and_post_merge_status_sync",
    "target": "SCHEME-LICENSE-DOWNLOAD-CTA-001",
    "parent_assignment": "SCHEME-LICENSE-DOWNLOAD-CTA-MERGE-001",
    "artifact_bindings": [
      {"kind": "github_pr", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/164"},
      {"kind": "git_branch", "identity": "grok/scheme-license-download-cta-001"},
      {"kind": "pr_head", "identity": "f20d4026d4ecf5ed3bf3ae5be4a1200ad9526ec3"},
      {"kind": "origin_main", "identity": "a9b82a58cac0c28e8a5d8a957d464d803d6d92d1"},
      {"kind": "merge_state", "identity": "MERGEABLE/CLEAN"},
      {"kind": "hosted_quality_run", "identity": "35940361938; head f20d4026d4ecf5ed3bf3ae5be4a1200ad9526ec3; all required jobs and final-quality-gate success"},
      {"kind": "product_gate_decision", "identity": "docs/product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate-revalidation-002.md"},
      {"kind": "quality_package_sha256", "identity": "6146c454c0f0305f0f6055bbe141db8e1473fc6c99657c525f11bb3b3ef6fe39"}
    ],
    "scope": "Mark GitHub PR #164 ready and squash-merge it into main only if a fresh preflight confirms OPEN state, exact head f20d4026d4ecf5ed3bf3ae5be4a1200ad9526ec3, unchanged base a9b82a58cac0c28e8a5d8a957d464d803d6d92d1, all required hosted checks successful on that same head, and MERGEABLE/CLEAN. Then fetch origin/main, verify PR #164 is merged and its GitHub squash merge commit is reachable from origin/main; safely delete local and remote grok/scheme-license-download-cta-001 without force; perform the named KOS M-02 lifecycle status synchronization in a new docs-only branch and open one follow-up PR targeting main. Repurpose the current worktree for that follow-up rather than deleting it. The follow-up status PR may be opened but must not be marked ready or merged under this Authorization.",
    "exclusions": ["merge_followup_status_pr", "direct_push_to_main", "force_delete", "rebase", "source_or_test_change", "testflight", "app_store_connect", "release", "branch_protection_change"],
    "issuer_role": "Human Product Owner",
    "decision_source": "Current session instruction: GitHub CI 已全绿，授权 merge，并处理后续工作",
    "issued_at": "2026-09-24T10:11:38+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "active",
    "consumed_at": null,
    "consumed_by": null,
    "consumption_record": null
  }
}
```

This Authorization does not permit a direct default-branch push or merge of the post-merge status-sync PR. It grants no TestFlight or Release authority.
