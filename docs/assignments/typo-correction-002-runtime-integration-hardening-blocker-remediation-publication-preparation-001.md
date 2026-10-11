# Assignment: TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-PREPARATION-001 — 建立已审快照的分支身份

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-PREPARATION-001",
  "record_type": "assignment",
  "title": "Establish branch identity for the reviewed blocker-remediation snapshot",
  "lifecycle": "completed",
  "current_phase": "Local named-branch identity established; awaiting a separately authorized publication decision",
  "authorization_action": "establish_reviewed_snapshot_branch_identity",
  "updated_at": "2026-09-22T15:45:00+08:00",
  "revalidation_triggers": [
    "review_snapshot_identity_changed",
    "tracked_diff_or_path_inventory_changed",
    "branch_or_publication_target_changed",
    "commit_push_PR_merge_or_release_requested",
    "reviewer_or_product_authority_changed"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-PREPARATION-001"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002",
    "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Current Codex task",
    "environment_executor": "Current Codex task — local isolated worktree and Git metadata only",
    "human_dependency": "Not Applicable — no device, account, network or external-state action is in scope",
    "architecture_reviewer": "Not Applicable — no source or architecture contract changes; any later independent review is assigned explicitly by the Human Product Owner",
    "quality_reviewer": "Not Applicable — no test, build, capture or quality conclusion is in scope; any later independent review is assigned explicitly by the Human Product Owner",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` |
| **Phase** | The exact snapshot is now a local named-branch checkpoint; no publication action has started. |
| **Next** | Stop. Commit, push and PR each require a new Authorization and must bind final staged contents, commit identity and publication target. |
| **Residuals** | Inherited bounded residuals remain in the reviewed child; no residual is accepted, fixed or closed by this preparation slice. |
| **Non-claims** | No source edit, test/build rerun, capture, RIME/device action, commit, push, PR, merge, Product Gate, Release or parent Close. |

---

## Authority

- **Assignment Authority / Product Approver:** Human Product Owner / Product Lead.
- **Decision source:** current task instruction, `授权进入“为该 Reviewed 快照建立分支身份并申请 publication”的单独车道`, 2026-09-22 Asia/Shanghai.
- **Predecessor:** [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001`](typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md), `Reviewed`.
- **Required inputs:** predecessor Architecture review, Quality review, Product residual decision, exact worktree identity and tracked-diff digest.

## Scope

The Executor may only:

1. Verify the detached worktree HEAD, tree, 16-path dirty inventory and tracked-diff SHA-256 against the reviewed snapshot.
2. Create or switch to the one local branch `codex/typo-correction-002-runtime-hardening-blockers` without modifying the snapshot contents.
3. Record the resulting branch identity and publication-preparation facts in the authorized documentation paths.

## Non-goals and stop conditions

- Do not change production, test, project, vendor, RIME, schema or diagnostics files.
- Do not stage, commit, push, fetch, rebase, merge, create or update a PR, alter remote state, or delete any branch/worktree.
- Do not rerun tests/builds or conduct capture, QA-001, INT-003, performance or device work.
- Stop if the branch name is already bound to a different commit, the exact snapshot identity drifts, a source/document path outside the Authorization is needed, or any publication action is requested without a new Authorization.

## Exit and handoff

- A receipt states the branch name, detached-to-branch transition, exact HEAD/tree, dirty-path count and tracked-diff SHA-256.
- The final handoff distinguishes branch preparation from publication and lists the authorization frontier for commit, push and PR.
- Parent `TYPO-CORRECTION-002` remains Active.
