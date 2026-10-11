# Authorization: AUTH-APP-ABOUT-001-MERGE — squash-merge PR #188

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | PR #188 已 squash-merge 为 `a46a6abe66be065039557897a1e3adef29cc7d32`；远端功能分支已删。不授权 TestFlight / Release |

Human Product Owner, current session 2026-09-28 Asia/Shanghai: 「GitHub CI 已全绿，授权 merge 以及后续的收尾工作，比如分支、worktree」

Fresh recheck before consume:

| Binding | Value |
|---|---|
| PR | [#188](https://github.com/shchnk1103/Universe-Keyboard/pull/188) OPEN, not draft |
| Head | `b735db807f3e913134117de6af15c71ff38b8e23` = local HEAD = `origin/grok/app-about-001` |
| Merge state | `MERGEABLE` / `CLEAN` |
| Hosted CI | Swift 6 Quality run [36426040680](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/36426040680) `headSha` `b735db8…` `success` same-head; classify/lightweight/format/KeyboardCore/RimeBridge/App+Keyboard/Keychain/Release/final-quality-gate + GitGuardian all SUCCESS |
| `origin/main` at recheck | `a536dca74acc18deebe1de9b7a2c22421cba9f95` |
| Delta | Full path: About Swift + tests + About docs/AUTH. Not docs-only. |
| Squash | `a46a6abe66be065039557897a1e3adef29cc7d32` on `origin/main`; `AboutSettingsView.swift` SHA-256 still `08d6ff83…` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-APP-ABOUT-001-MERGE",
  "record_type": "authorization",
  "title": "Squash-merge PR 188 APP-ABOUT-001",
  "status": "consumed",
  "updated_at": "2026-09-28T21:19:35+08:00",
  "revalidation_triggers": ["head_changed", "ci_mismatch", "merge_state_changed", "authority_revoked"],
  "authorization": {
    "action": "squash_merge_pr_188_app_about",
    "target": "APP-ABOUT-001",
    "artifact_bindings": [
      {"kind": "commit", "identity": "b735db807f3e913134117de6af15c71ff38b8e23"},
      {"kind": "commit", "identity": "a46a6abe66be065039557897a1e3adef29cc7d32"},
      {"kind": "github_pr", "identity": "188"}
    ],
    "scope": "Squash-merge GitHub PR 188 into origin/main at the rechecked head b735db8 with same-head hosted CI green and CLEAN merge state. Then fetch origin/main, confirm the merged content is reachable from the default branch, record the squash SHA via docs-only M-02, and safely delete the local and remote feature branch grok/app-about-001 plus the isolated worktree. Do not force-delete. Do not TestFlight or Release.",
    "exclusions": ["testflight_upload", "app_store_connect", "release_pass", "force_delete", "default_branch_direct_commit"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-28 Asia/Shanghai instruction: GitHub CI 已全绿，授权 merge 以及后续的收尾工作，比如分支、worktree",
    "issued_at": "2026-09-28T21:18:48+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

This Authorization does not grant TestFlight or Release.
