# Authorization: AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-MERGE — squash-merge PR #190

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | PR #190 已 squash-merge 为 `944a76bd049d717dd1048a6b4eb5bc7fd9124347`；远端功能分支已删。不授权 TestFlight / Release；不授权 `CBID-CORNER` |

Human Product Owner, current session 2026-09-28 Asia/Shanghai: 「授权 merge，以及后续收尾工作，比如分支、worktree」

Fresh recheck before consume:

| Binding | Value |
|---|---|
| PR | [#190](https://github.com/shchnk1103/Universe-Keyboard/pull/190) OPEN, not draft |
| Head | `c3c6102610103953f04d39036b4f4726f6bf86c7` = local HEAD = `origin/grok/candidate-bar-idle-dismiss-001` |
| Merge state | `MERGEABLE` / `CLEAN` |
| Hosted CI | Swift 6 Quality run [36434767922](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/36434767922) `headSha` `c3c6102…` `success` same-head |
| `origin/main` at recheck | `fbb4eb3bbbc2926ff6e248db9dcdfdf6a331f821` |
| Squash | `944a76bd049d717dd1048a6b4eb5bc7fd9124347` on `origin/main`; `CandidateBarView.swift` SHA-256 still `606b5553…` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-MERGE",
  "record_type": "authorization",
  "title": "Squash-merge PR 190 CANDIDATE-BAR-IDLE-DISMISS-001",
  "status": "consumed",
  "updated_at": "2026-09-28T22:31:45+08:00",
  "revalidation_triggers": ["head_changed", "ci_mismatch", "merge_state_changed", "authority_revoked"],
  "authorization": {
    "action": "squash_merge_pr_190_candidate_bar_idle_dismiss",
    "target": "CANDIDATE-BAR-IDLE-DISMISS-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "c3c6102610103953f04d39036b4f4726f6bf86c7"},
      {"kind": "commit", "identity": "944a76bd049d717dd1048a6b4eb5bc7fd9124347"},
      {"kind": "github_pr", "identity": "190"}
    ],
    "scope": "Squash-merge GitHub PR 190 into origin/main at the rechecked head c3c6102 with same-head hosted CI green and CLEAN merge state. Then fetch origin/main, confirm the merged content is reachable, record the squash SHA via docs-only M-02, and safely delete the local and remote feature branch grok/candidate-bar-idle-dismiss-001 plus the isolated worktree. Do not force-delete. Do not TestFlight or Release. Do not start CBID-CORNER.",
    "exclusions": ["testflight_upload", "app_store_connect", "release_pass", "force_delete", "default_branch_direct_commit", "keyboard_corner_bleed_fix"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-28 Asia/Shanghai instruction: 授权 merge，以及后续收尾工作，比如分支、worktree",
    "issued_at": "2026-09-28T22:31:07+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

This Authorization does not grant TestFlight or Release.
