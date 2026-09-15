# Authorization: AUTH-CI-HEAVY-JOB-SPLIT-001-PUBLISH — 隔离分支 commit/push

## Current Status

| Field | Value |
|---|---|
| Status | active |
| Consumption | 隔离功能分支 commit/push 进行中；未授权 merge、PR 合并、docs-only fixture PR 合并 |

Human Product Owner, current session `2026-09-15 Asia/Shanghai`: 「可以，按照你的建议在隔离功能分支上commit/push吧」

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-CI-HEAVY-JOB-SPLIT-001-PUBLISH",
  "record_type": "authorization",
  "title": "Commit and push CI-HEAVY-JOB-SPLIT-001 on an isolated feature branch",
  "status": "active",
  "updated_at": "2026-09-15T12:00:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "mixed_tree_commit"],
  "authorization": {
    "action": "commit_push_isolated_ci_heavy_job_split",
    "target": "CI-HEAVY-JOB-SPLIT-001",
    "artifact_bindings": [
      {"kind": "file", "identity": ".github/workflows/swift6-quality.yml"},
      {"kind": "file", "identity": "scripts/ci/verify_final_gate.sh"}
    ],
    "scope": "Create an isolated feature branch from origin/main. Commit and push only CI-HEAVY-JOB-SPLIT-001 workflow, Gate scripts, Assignment/AUTH/PD/reviews/evidence, and surgical SoT updates. Do not include RELEASE-EVIDENCE-PROMOTION-001 product files or revert origin/main ADR 0035 / Active Work status.",
    "exclusions": ["merge", "pr_merge", "branch_protection_mutation", "required_check_mutation", "paths_ignore", "add_path_skip", "release", "weaken_full_gate", "commit_release_evidence_slice"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-15 Asia/Shanghai instruction: 可以，按照你的建议在隔离功能分支上commit/push吧",
    "issued_at": "2026-09-15T12:00:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "active"
  }
}
```

本收据不授权 merge、把 docs-only fixture 合进默认分支，或 required-check 迁移。Hosted `full` 跑完后 CHS-Q-01 仍须独立 Quality 核对。CHS-Q-02 需要另开不合并的 docs-only fixture。
