# Authorization: AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-STATUS-SYNC-MERGE-002 — merge PR #166 and bounded follow-up

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Assignment | [`SCHEME-LICENSE-DOWNLOAD-CTA-STATUS-SYNC-MERGE-002`](../assignments/scheme-license-download-cta-status-sync-merge-002.md) |
| Issuer | Human Product Owner |
| Decision source | Current session instruction: “授权合并#166，并将后续工作处理好。” |
| Consumer | Current Codex task |
| Action | Mark PR #166 ready, squash-merge the bound head, verify provenance, safely remove its old branch, and publish one docs-only M-02 status PR |
| Issued at | `2026-09-24T12:00:48+08:00` |
| Boundary | The post-merge status PR may be opened as Draft; marking it Ready or merging it is excluded. |
| Consumed at | `2026-09-24T12:08:43+08:00` |
| Consumption result | PR #166 squash-merged as `29241ea19ea49c227faa589176a3e18cd7685e22`, verified reachable from `origin/main`; local and remote `codex/scheme-license-download-cta-status-sync-merge` were safely deleted after exact tree-equivalence verification. Docs-only Draft PR #167 opened. Its Ready/merge is not authorized. No TestFlight or Release action was taken. |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-STATUS-SYNC-MERGE-002",
  "record_type": "authorization",
  "title": "Merge PR 166 and publish bounded CTA status synchronization",
  "status": "consumed",
  "updated_at": "2026-09-24T12:08:43+08:00",
  "revalidation_triggers": ["pr_head_changed", "pr_base_changed", "ci_not_green", "merge_state_changed", "authority_revoked"],
  "authorization": {
    "action": "squash_merge_pr_and_post_merge_status_sync",
    "target": "SCHEME-LICENSE-DOWNLOAD-CTA-STATUS-SYNC-002",
    "artifact_bindings": [
      {"kind": "file", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/166"},
      {"kind": "commit", "identity": "f175b3a39cf95450f1b0cf58f35aaa512840b049"},
      {"kind": "commit", "identity": "99a7ef8825265936c536a4801dfafa93a6b9abb3"},
      {"kind": "file", "identity": "refs/heads/codex/scheme-license-download-cta-status-sync-merge"},
      {"kind": "file", "identity": "https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35949384805 (bound head; required docs-only checks, final gate and GitGuardian succeeded)"}
    ],
    "scope": "Mark PR #166 ready and squash-merge it only if a fresh preflight confirms OPEN state, exact head f175b3a39cf95450f1b0cf58f35aaa512840b049, unchanged base 99a7ef8825265936c536a4801dfafa93a6b9abb3, all required hosted checks successful on that same head, and MERGEABLE/CLEAN. Then fetch origin/main, verify PR #166 is merged and its squash merge commit is reachable from origin/main, safely delete local and remote codex/scheme-license-download-cta-status-sync-merge without force, perform the named CTA lifecycle M-02 status synchronization, and open one docs-only Draft PR targeting main. Do not mark the status PR ready or merge it under this Authorization.",
    "exclusions": ["merge_post_merge_status_pr", "direct_push_to_main", "force_delete", "rebase", "source_or_test_change", "testflight", "app_store_connect", "release", "branch_protection_change"],
    "issuer_role": "Human Product Owner",
    "decision_source": "Current session instruction: 授权合并#166，并将后续工作处理好",
    "issued_at": "2026-09-24T12:00:48+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  },
  "extensions": {
    "universe_keyboard": {
      "assignment_ref": "SCHEME-LICENSE-DOWNLOAD-CTA-STATUS-SYNC-MERGE-002",
      "follow_up_merge_excluded": true,
      "consumed_at": "2026-09-24T12:08:43+08:00",
      "consumed_by": "PR #166 squash merge 29241ea19ea49c227faa589176a3e18cd7685e22; docs-only Draft PR #167",
      "consumption_record": "Fresh preflight confirmed PR #166 OPEN at exact head f175b3a39cf95450f1b0cf58f35aaa512840b049, unchanged base 99a7ef8825265936c536a4801dfafa93a6b9abb3, all required hosted checks successful on run 35949384805, and MERGEABLE/CLEAN. Local lightweight checks passed on the exact candidate. Marked Ready and squash-merged at 2026-09-24T04:02:35Z as 29241ea19ea49c227faa589176a3e18cd7685e22; fetched origin/main and verified merge-commit reachability. Verified the PR head tree exactly matched the squash-merge tree, then deleted the local branch with an expected-old-SHA conditional ref deletion and deleted the remote branch without force. Updated the CTA M-02 lifecycle mirrors and opened docs-only Draft PR #167. PR #167 is not authorized to be marked Ready or merged. No TestFlight or Release action was taken."
    }
  }
}
```

This Authorization does not grant direct push to `main`, TestFlight, App Store Connect, Release, or merge of the post-merge status PR.
