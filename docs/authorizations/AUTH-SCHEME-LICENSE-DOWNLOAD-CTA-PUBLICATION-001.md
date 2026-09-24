# Authorization: AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-001 — bounded commit, push, and draft PR

## Current Status

| Field | Value |
|---|---|
| Status | `superseded` — replaced for the rebased candidate; its original no-rebase boundary remains historical |
| Assignment | [`SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-001`](../assignments/scheme-license-download-cta-publication-001.md) |
| Issuer | Human Product Owner |
| Decision source | Current session: authorized commit/push/draft PR and relevant Markdown formatting normalization |
| Consumer | Current Codex task |
| Superseded by | [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-MAIN-SYNC-001`](AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-MAIN-SYNC-001.md) |
| Action | Original bounded publication authority; superseded before push when a current-main conflict was found |
| Issued at | `2026-09-23T23:10:08+08:00` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-001",
  "record_type": "authorization",
  "title": "Publish the gated scheme license CTA candidate as a draft PR",
  "status": "superseded",
  "updated_at": "2026-09-23T23:41:47+08:00",
  "revalidation_triggers": ["candidate_scope_changed", "product_gate_changed", "authority_revoked", "remote_base_changed_with_conflict"],
  "authorization": {
    "action": "commit_push_and_open_draft_pull_request",
    "target": "SCHEME-LICENSE-DOWNLOAD-CTA-001",
    "artifact_bindings": [
      {"kind": "git_branch", "identity": "grok/scheme-license-download-cta-001"},
      {"kind": "starting_git_head", "identity": "80091f35cc5411b292eca78662f39e2b91694045"},
      {"kind": "origin_main_observed", "identity": "a9b82a5 (6 commits ahead of starting HEAD)"},
      {"kind": "product_gate_decision_sha256", "identity": "docs/product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md:ec80a4dad63d66f22d1ad2b7a996717a37671b1596d74157ab25ec12248dcdb4"},
      {"kind": "quality_package_sha256", "identity": "4f097b709ef993b0c81eb879f8d093c99213ae766c8397582a67ff1ada5f9f3e"},
      {"kind": "quality_receipt_sha256", "identity": "docs/reviews/scheme-license-download-cta-quality-revalidation-001.md:1dde9b3bf058442be7c686494d2d4891da53ed1c7812b8b7d71874f5d97621c3"},
      {"kind": "documentation_normalization_receipt", "identity": "docs/evidence/scheme-license-download-cta-markdown-normalization-2026-09-23.md:3417620947a8c92548f62630d8a0899ba167b06259eae46d97ccef0c51bde3cd"}
    ],
    "scope": "Stage only the reviewed task worktree changes, including the Human-authorized whitespace-only Markdown normalization recorded in the linked receipt; create one local commit, push branch grok/scheme-license-download-cta-001 to origin, and open one draft PR targeting main with an accurate description of the Product Gate conditions and local verification. Keep the branch's starting base; do not rebase. Record actual commit and PR identifiers after creation.",
    "exclusions": ["rebase", "merge", "mark_pr_ready", "close_pr", "branch_protection_change", "testflight", "app_store_connect", "release", "new_source_or_test_changes_except_required_formatting"],
    "issuer_role": "Human Product Owner",
    "decision_source": "Current session instructions: 可以授权 commit 以及 push 并开 PR; 可以做相关 Markdown 的格式规划化等",
    "issued_at": "2026-09-23T23:10:08+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "superseded",
    "consumed_at": null,
    "superseded_by": "AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-MAIN-SYNC-001",
    "consumed_by": null,
    "consumption_record": "Superseded before push because current origin/main produced conflicts in CHANGELOG.md and docs/ACTIVE_WORK.md; Human authorized a bounded rebase/resolution and full local validation under AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-MAIN-SYNC-001."
  }
}
```

This authorization is superseded and may not be consumed for publication of the rebased candidate. Its original no-rebase and stop-on-conflict boundaries remain part of the historical record.
