# Authorization: AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-STATUS-SYNC-MERGE-001 — merge PR #165 and bounded follow-up

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Assignment | [`SCHEME-LICENSE-DOWNLOAD-CTA-STATUS-SYNC-MERGE-001`](../assignments/scheme-license-download-cta-status-sync-merge-001.md) |
| Issuer | Human Product Owner |
| Decision source | Current session instruction: “授权 merge #165，并处理后续工作。” |
| Consumer | Current Codex task |
| Action | Mark PR #165 ready, squash-merge the bound head, verify provenance, safely remove its old remote branch, and publish one docs-only M-02 status PR |
| Issued at | `2026-09-24T10:45:13+08:00` |
| Boundary | The post-merge status PR may be opened as Draft; marking it Ready or merging it is excluded. The old local branch was retained because the explicitly excluded parent checkout contains its Git administration directory and the system rejected writes there. |
| Consumed at | `2026-09-24T10:49:14+08:00` |
| Consumption result | PR #165 squash-merged as `99a7ef8825265936c536a4801dfafa93a6b9abb3`, verified reachable from `origin/main`; old remote branch deleted without force; docs-only Draft PR #166 opened. Local old branch retained under the explicit filesystem boundary; no forced cleanup. |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-STATUS-SYNC-MERGE-001",
  "record_type": "authorization",
  "title": "Merge PR 165 and publish bounded CTA status synchronization",
  "status": "consumed",
  "updated_at": "2026-09-24T10:49:14+08:00",
  "revalidation_triggers": ["pr_head_changed", "pr_base_changed", "ci_not_green", "merge_state_changed", "authority_revoked"],
  "authorization": {
    "action": "squash_merge_pr_and_post_merge_status_sync",
    "target": "SCHEME-LICENSE-DOWNLOAD-CTA-STATUS-SYNC-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/165"},
      {"kind": "commit", "identity": "bbba20eb76a82f2e427669970874b00990f1d3b4"},
      {"kind": "commit", "identity": "204d0c2b3c3ec5253f31fad8e15cfa0501c83416"},
      {"kind": "file", "identity": "refs/heads/codex/scheme-license-download-cta-post-merge-sync"},
      {"kind": "file", "identity": "https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35948476581 (bound head; required docs-only checks, final gate and GitGuardian succeeded)"}
    ],
    "scope": "Mark PR #165 ready and squash-merge it only if a fresh preflight confirms OPEN state, exact head bbba20eb76a82f2e427669970874b00990f1d3b4, unchanged base 204d0c2b3c3ec5253f31fad8e15cfa0501c83416, all required hosted checks successful on that same head, and MERGEABLE/CLEAN. Then fetch origin/main, verify PR #165 is merged and its squash merge commit is reachable from origin/main, safely delete local and remote codex/scheme-license-download-cta-post-merge-sync without force, perform the named CTA lifecycle M-02 status synchronization, and open one docs-only Draft PR targeting main. Keep the current worktree for the follow-up. Do not mark the status PR ready or merge it under this Authorization.",
    "exclusions": ["merge_post_merge_status_pr", "direct_push_to_main", "force_delete", "rebase", "source_or_test_change", "testflight", "app_store_connect", "release", "branch_protection_change"],
    "issuer_role": "Human Product Owner",
    "decision_source": "Current session instruction: 授权 merge #165，并处理后续工作",
    "issued_at": "2026-09-24T10:45:13+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  },
  "extensions": {
    "universe_keyboard": {
      "assignment_ref": "SCHEME-LICENSE-DOWNLOAD-CTA-STATUS-SYNC-MERGE-001",
      "follow_up_merge_excluded": true,
      "consumed_at": "2026-09-24T10:49:14+08:00",
      "consumed_by": "PR #165 squash merge 99a7ef8825265936c536a4801dfafa93a6b9abb3; docs-only Draft PR #166",
      "consumption_record": "Fresh preflight confirmed PR #165 OPEN at exact head bbba20eb76a82f2e427669970874b00990f1d3b4, unchanged base 204d0c2b3c3ec5253f31fad8e15cfa0501c83416, all required hosted checks successful on run 35948476581, and MERGEABLE/CLEAN. Marked Ready, then squash-merged at 2026-09-24T02:49:14Z as 99a7ef8825265936c536a4801dfafa93a6b9abb3; fetched origin/main and verified merge-commit reachability. Deleted remote codex/scheme-license-download-cta-post-merge-sync without force. Opened docs-only Draft PR #166 for the lifecycle M-02 status sync. The local old branch remains because this worktree's Git administration directory is in the explicitly excluded /Users/doubleshy0n/Dev/Universe Keyboard checkout and the system rejected the needed metadata write; no force deletion or access escalation into that checkout was attempted. PR #166 is not authorized to be marked Ready or merged. No TestFlight or Release action was taken."
    }
  }
}
```

This Authorization does not grant direct push to `main`, TestFlight, App Store Connect, Release, or merge of the post-merge status PR.
