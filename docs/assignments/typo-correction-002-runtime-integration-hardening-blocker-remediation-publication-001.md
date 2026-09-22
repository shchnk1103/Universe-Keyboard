# Assignment: TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-001 — 发布已审 controller-sidecar 修复快照

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLICATION-001",
  "record_type": "assignment",
  "title": "Publish the exact reviewed blocker-remediation snapshot as a draft pull request",
  "lifecycle": "active",
  "current_phase": "Local full-CI revalidation and final publication manifest before commit, push and draft PR",
  "authorization_action": "publish_reviewed_controller_sidecar_blocker_remediation",
  "updated_at": "2026-09-22T16:00:00+08:00",
  "revalidation_triggers": [
    "staged_source_or_document_content_changed",
    "branch_or_base_identity_changed",
    "local_CI_result_or_environment_changed",
    "hosted_CI_head_or_result_changed",
    "merge_release_or_parent_close_requested"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-PUBLISH-001"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002",
    "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Current Codex task",
    "environment_executor": "Current Codex task — local isolated worktree, temporary verified Vendor symlink only if package resolution requires it, and host GitHub CLI publication",
    "human_dependency": "Human Product Owner authorization already supplied; no device action is in scope",
    "architecture_reviewer": "Not Applicable — no source change beyond the reviewed snapshot; any later independent review is assigned explicitly by the Human Product Owner",
    "quality_reviewer": "Not Applicable — prior independent Quality verdict is an input; this slice reruns required local CI but makes no new independent Quality conclusion",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | Revalidate the exact named-branch snapshot, bind final staged contents, then publish a draft PR. |
| **Next** | Complete local CI and exact staging checks before commit/push/PR. |
| **Residuals** | Inherited Architecture/Quality residuals remain bounded and explicit; they are not closed by publication. |
| **Non-claims** | No merge, Release, TestFlight, Product Gate, parent Close, RIME/device capture, QA-001, INT-003 or paired-performance conclusion. |

---

## Authority and scope

- **Assignment Authority / Product Approver:** Human Product Owner / Product Lead.
- **Decision source:** current task instruction, `授权正式把这份实现放上 GitHub`, 2026-09-22 Asia/Shanghai.
- **Snapshot input:** local branch `codex/typo-correction-002-runtime-hardening-blockers`, HEAD `4d1050f4b677494e06448cb40a83ef2da46d7b27`, tree `5f864a6f6f139810ed59c7e00ab6c33caad7e500`, pre-publication tracked diff SHA-256 `3f3de3aba53820340c25cafc6adaa87977c9ffe58b6a7e61e165c3c64e26db5e`.
- **Reviewed child:** [`blocker remediation`](typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md), `Reviewed`.

The Executor may only preserve the reviewed source snapshot, add its directly supporting KOS records and final publication record, run the full local CI sequence required by `AGENTS.md`, then stage, commit, push this branch and create a **draft** pull request against `main`.

## Stop conditions

- Stop before commit if staged source content differs from the reviewed snapshot, formatting or any required local CI command fails, or an unlisted source/test/project/vendor path is needed.
- Stop before push/PR if final commit identity, remote branch state or draft PR base is ambiguous.
- Do not merge, rebase, force-push, alter remote `main`, publish a Release/TestFlight build, or close the parent/child Assignment.

## Exit and handoff

- Record final staged inventory, commit SHA, pushed branch, draft PR URL and hosted-CI state as publication facts.
- Report local CI separately from hosted CI; hosted green is required only for any later merge decision.
- Parent `TYPO-CORRECTION-002` remains Active, with its remaining evidence lanes unchanged.
