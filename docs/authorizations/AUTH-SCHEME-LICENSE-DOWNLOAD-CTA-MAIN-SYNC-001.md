# Authorization: AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-MAIN-SYNC-001 — 有界 rebase、文档冲突解决与本地重验

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Assignment | [`SCHEME-LICENSE-DOWNLOAD-CTA-MAIN-SYNC-001`](../assignments/scheme-license-download-cta-main-sync-001.md) |
| Issuer | Human Product Owner |
| Decision source | Current session: “好吧，授权你按照建议继续” after disclosure of the two `origin/main` document conflicts and required post-rebase validation |
| Consumer | Current Codex task |
| Action | Amend the one unpushed local commit with this scope record, rebase onto the bound `origin/main`, resolve only two named Markdown conflicts, and run full local quality gates |
| Issued at | `2026-09-23T23:41:47+08:00` |
| Consumed at | `2026-09-23T23:55:31+08:00` |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-MAIN-SYNC-001",
  "record_type": "authorization",
  "title": "Rebase and validate the scheme license CTA publication candidate",
  "status": "consumed",
  "updated_at": "2026-09-23T23:55:31+08:00",
  "revalidation_triggers": ["origin_main_changed_before_rebase", "conflict_outside_named_markdown_files", "source_or_test_tree_changed", "product_gate_changed", "authority_revoked"],
  "authorization": {
    "action": "rebase_resolve_named_docs_and_run_local_quality_gates",
    "target": "SCHEME-LICENSE-DOWNLOAD-CTA-001",
    "artifact_bindings": [
      {"kind": "git_branch", "identity": "grok/scheme-license-download-cta-001"},
      {"kind": "pre_sync_commit", "identity": "3f8a1548439a5ea781c5c95a7fa7e68739d92c8b"},
      {"kind": "origin_main", "identity": "a9b82a58cac0c28e8a5d8a957d464d803d6d92d1"},
      {"kind": "conflict_paths", "identity": "CHANGELOG.md; docs/ACTIVE_WORK.md"},
      {"kind": "prior_publication_authorization", "identity": "AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-001 (superseded for this candidate sync)"},
      {"kind": "markdown_normalization_receipt_sha256", "identity": "docs/evidence/scheme-license-download-cta-markdown-normalization-2026-09-23.md:3417620947a8c92548f62630d8a0899ba167b06259eae46d97ccef0c51bde3cd"}
    ],
    "scope": "Supersede the prior no-rebase publication authorization; amend the single unpushed commit to add this Assignment and Authorization and required status writeback; rebase the resulting one-commit branch onto the exact bound origin/main; resolve only CHANGELOG.md and docs/ACTIVE_WORK.md; run strict Swift formatting, KeyboardCore, RimeBridgeTests, App + Keyboard Debug tests, Release build, and Markdown/KOS checks; record the post-rebase candidate and results. Stop before independent Quality revalidation, Human Product Gate, push, PR, merge, TestFlight, or Release.",
    "exclusions": ["source_or_test_behavior_change", "conflict_resolution_outside_named_markdown_paths", "push", "pull_request", "merge", "mark_pr_ready", "testflight", "app_store_connect", "release", "branch_or_worktree_cleanup"],
    "issuer_role": "Human Product Owner",
    "decision_source": "Current session instruction: 好吧，授权你按照建议继续",
    "issued_at": "2026-09-23T23:41:47+08:00",
    "expires_at": null,
    "supersedes_ref": "AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-001 for the prior candidate's no-rebase scope",
    "consumption_state": "consumed",
    "consumed_at": "2026-09-23T23:55:31+08:00",
    "consumed_by": "Current Codex task",
    "consumption_record": "Rebased the single local commit onto the bound origin/main, resolved only CHANGELOG.md and docs/ACTIVE_WORK.md, and completed the required Swift 6, Simulator, Release-build, Markdown, KOS, and CI-helper checks. Results are recorded in docs/assignments/scheme-license-download-cta-main-sync-001.md. No push, PR, merge, source/test edits, fresh Quality, or new Product Gate occurred."
  }
}
```

This Authorization does not treat the old Product Gate or Quality verdict as applicable to the post-rebase candidate. It does not authorize publication or external state changes.
