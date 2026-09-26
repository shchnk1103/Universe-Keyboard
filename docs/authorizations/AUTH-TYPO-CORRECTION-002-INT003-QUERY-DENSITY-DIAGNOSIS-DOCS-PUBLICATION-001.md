# Authorization: INT-003 query-density diagnosis docs publication 001

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSIS-DOCS-PUBLICATION-001",
  "record_type": "authorization",
  "title": "Docs-only publication of bounded INT-003 query-density diagnosis and criterion decision",
  "status": "consumed",
  "updated_at": "2026-09-26T10:37:24+08:00",
  "revalidation_triggers": [
    "github_main_tip_changes_from_4ef275b",
    "diff_expands_beyond_docs_only_query_density_accounting",
    "product_decision_or_evidence_changes_after_validation",
    "request_to_merge_or_gate_or_change_swift"
  ],
  "authorization": {
    "action": "publish_int003_query_density_diagnosis_docs_only_draft_pr",
    "target_assignment": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001",
    "parent_assignment": "TYPO-CORRECTION-002",
    "consumption_state": "consumed",
    "consumed_at": "2026-09-26T10:37:24+08:00",
    "consumer": "Codex current task",
    "decision_source": "Human 2026-09-26 Asia/Shanghai: authorized cancellation of the 180 ms hard pass condition and continuation of unfinished work according to KOS; earlier Human continuation authorization covered the narrow query-density work. This separate publication AUTH does not reuse the consumed diagnosis or Capture AUTHs.",
    "artifact_bindings": [
      {"kind": "source_tip", "identity": "4ef275b57d16f116b4edbae99a0e244a28d6bf25"},
      {"kind": "product_decision", "identity": "PD-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001"},
      {"kind": "diagnostic_run", "identity": "TC2-SIM-20260925-161830-INT003-QUERY-DENSITY-DIAGNOSTIC-001"},
      {"kind": "no_run_identifier", "identity": "TC2-SIM-20260925-171300-INT003-QUERY-DENSITY-RAPID-001"}
    ],
    "allowed_external_effects_when_live": [
      "stage_and_commit_only_allowlisted_docs_in_isolated_worktree",
      "push_codex_function_branch",
      "open_draft_docs_only_pull_request"
    ],
    "exclusions": [
      "Swift_or_project_or_test_file_change",
      "raw_journal_publication",
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
| Authority | Human 2026-09-26 criterion decision and KOS continuation instruction; consumed for one docs-only publication |
| Scope | Local docs validation, allowlisted commit, push to `codex/` function branch, draft PR |
| Source binding | GitHub `main` `4ef275b57d16f116b4edbae99a0e244a28d6bf25`, verified read-only on 2026-09-26 before publication |
| Stop | Any non-doc delta, changed source tip, invalid KOS/Markdown link, or missing commit/PR provenance |
| Non-claims | No Swift, raw journal upload, merge, Gate, parent Close, TestFlight, Release, or ADR Accept |
| Outcome | [PR #175](https://github.com/shchnk1103/Universe-Keyboard/pull/175) was separately authorized by Human and squash merged as `10faa51caf20e3c558f21f26b625eff7f3aa941d`. The [M-02 closeout](../evidence/typo-correction-002-int003-query-density-post-merge-state-sync-2026-09-26.md) is a distinct Consumed AUTH and pending docs PR |

This AUTH does not make the 2026-09-23 Capture or its reviews newly valid. The original query-density Product residual remains open, and the parent Assignment remains Active.
