# Authorization: AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-002 — 精确候选 commit、push 与 draft PR

## Current Status

| Field | Value |
|---|---|
| Status | `active` |
| Assignment | [`SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-001`](../assignments/scheme-license-download-cta-publication-001.md) |
| Issuer | Human Product Owner |
| Decision source | Current session: “授权 commit push 以及开 PR”；`2026-09-24 Asia/Shanghai` |
| Consumer | Current Codex task |
| Action | Commit the listed CTA governance writeback, push `grok/scheme-license-download-cta-001`, and open one draft PR targeting `main` |
| Scope boundary | Draft PR only; no ready, merge, TestFlight, or Release |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-002",
  "record_type": "authorization",
  "title": "Publish the exact-gated scheme license CTA candidate as a draft PR",
  "status": "active",
  "updated_at": "2026-09-24T08:41:20+08:00",
  "revalidation_triggers": ["candidate_head_changed", "origin_main_changed", "product_gate_changed", "quality_receipt_changed", "scope_changed", "authority_revoked"],
  "authorization": {
    "action": "commit_push_and_open_draft_pull_request",
    "target": "SCHEME-LICENSE-DOWNLOAD-CTA-001",
    "parent_assignment": "SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-001",
    "artifact_bindings": [
      {"kind": "git_branch", "identity": "grok/scheme-license-download-cta-001"},
      {"kind": "starting_git_head", "identity": "d614b8e03006ff305137754ac118e50445938068"},
      {"kind": "origin_main", "identity": "a9b82a58cac0c28e8a5d8a957d464d803d6d92d1"},
      {"kind": "product_gate_decision_sha256", "identity": "docs/product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate-revalidation-002.md:5baa946b4c8ccb50feae2e0c6b7583721ac3afb1c446678a47ed10bcb8ba45e3"},
      {"kind": "product_gate_packet_sha256", "identity": "docs/evidence/scheme-license-download-cta-product-gate-packet-2026-09-24.md:a131b46c4669bc24307ad15c18a06afef644205ef89e5b04eb771c2d7f42525d"},
      {"kind": "quality_package_sha256", "identity": "6146c454c0f0305f0f6055bbe141db8e1473fc6c99657c525f11bb3b3ef6fe39"},
      {"kind": "quality_receipt_sha256", "identity": "docs/reviews/scheme-license-download-cta-quality-revalidation-002.md:9a5418ab863eea4f896bd61917555451d9193b8df204c39d063619690afa837b (presentation-normalized from the original receipt hash in the Gate decision)"},
      {"kind": "markdown_normalization_receipt", "identity": "docs/evidence/scheme-license-download-cta-publication-markdown-normalization-2026-09-24.md"}
    ],
    "scope": "Commit the existing authorized scheme-license CTA candidate records and the current bounded KOS writeback on branch grok/scheme-license-download-cta-001; push that branch to origin without force; create exactly one draft pull request targeting main with an accurate description of the contract, implementation, validations, accepted Product Gate conditions, and remaining non-claims. The candidate HEAD at entry is d614b8e03006ff305137754ac118e50445938068; origin/main at entry is a9b82a58cac0c28e8a5d8a957d464d803d6d92d1. After successful publication, update only this AUTH, the publication Assignment, Active Work, and Dashboard with actual commit/push/PR identities and consumption result, then commit and push that status writeback on the same branch.",
    "exclusions": ["rebase", "force_push", "mark_pr_ready", "merge", "close_pr", "branch_protection_change", "testflight", "app_store_connect", "release", "source_or_test_changes", "scope_expansion"],
    "issuer_role": "Human Product Owner",
    "decision_source": "Current session instruction: 授权 commit push 以及开 PR",
    "issued_at": "2026-09-24T08:41:20+08:00",
    "expires_at": null,
    "supersedes_ref": "Supersedes the publication scope only for the exact candidate after fresh Quality revalidation 002 and Product Gate 002; prior publication AUTH remains historical and superseded.",
    "consumption_state": "active",
    "consumed_at": null,
    "consumed_by": null,
    "consumption_record": null
  }
}
```

This authorization is limited to one non-force push and one draft PR for the bound branch/candidate. It does not authorize marking the PR ready, merging, TestFlight, or Release.
