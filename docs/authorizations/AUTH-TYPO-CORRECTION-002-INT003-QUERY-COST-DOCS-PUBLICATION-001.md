# Authorization: INT-003 query-cost assessment docs publication 001

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-DOCS-PUBLICATION-001",
  "record_type": "authorization",
  "title": "Docs-only draft publication of bounded INT-003 query-cost assessment",
  "status": "consumed",
  "updated_at": "2026-09-26T22:37:17+08:00",
  "revalidation_triggers": [
    "github_main_tip_changes_from_9f6f83e",
    "diff_expands_beyond_docs_only_query_cost_assessment_and_status_sync",
    "evidence_or_product_boundary_changes_after_validation",
    "request_to_merge_or_gate_or_change_swift"
  ],
  "authorization": {
    "action": "publish_int003_query_cost_assessment_docs_only_draft_pr",
    "target": "TYPO-CORRECTION-002-INT003-QUERY-COST-ASSESSMENT-001",
    "scope": "Validate and commit allowlisted docs in isolated worktree, push codex function branch, and open a draft docs-only pull request",
    "issuer_role": "Human Product Owner acting as Product Lead",
    "issued_at": "2026-09-26T22:37:17+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "decision_source": "Human 2026-09-26 Asia/Shanghai: 请你针对查询成本与总量做一个新评估，并且我授权你按照KOS设定完成后续的工作。 This is a separate docs publication slice; neither this nor the assessment AUTH reuses a previous Consumed Capture or remediation AUTH.",
    "artifact_bindings": [
      {"kind": "commit", "identity": "9f6f83edb13c8dd7d5598c1b398587bf4aa76f5b"},
      {"kind": "file", "identity": "docs/evidence/typo-correction-002-int003-query-cost-assessment-2026-09-26.md"},
      {"kind": "sha256", "identity": "aa523a6e8330b529e0ffc03283b142f842401b2321e2b323e6ce2762d5b59f84"}
    ],
    "exclusions": [
      "Swift_project_or_test_file_change",
      "raw_journal_or_sensitive_payload_publication",
      "simulator_or_new_capture",
      "merge_or_branch_cleanup",
      "Product_or_QA001_Gate_or_parent_Close",
      "TestFlight_or_Release_or_ADR_Accept",
      "RimeRuntimeProvenance_restore"
    ]
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | `2026-09-26T22:37:17+08:00` by Codex current task |
| Authority | Human 2026-09-26 assessment and KOS continuation instruction; Consumed for this single docs-only draft publication |
| Scope | Validate and commit the bounded assessment/Assignment/AUTH/mirror package, push one `codex/` branch and open a draft PR |
| Source binding | GitHub `main` `9f6f83edb13c8dd7d5598c1b398587bf4aa76f5b`, checked before analysis |
| Stop | Any non-doc delta, stale source tip, invalid KOS/Markdown, or missing PR provenance |
| Non-claims | No merge, Product cost acceptance, Gate, Swift, raw journal upload, parent Close or Release |

The earlier diagnostic and Capture AUTHs remain Consumed. A new Product decision is needed to change the query budget or accept the wider residual.
