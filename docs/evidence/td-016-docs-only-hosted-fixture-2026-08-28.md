# Evidence: TD-016 hosted docs-only fixture

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "EVIDENCE-TD-016-DOCS-ONLY-HOSTED-FIXTURE",
  "record_type": "evidence",
  "title": "Hosted docs-only CI path fixture",
  "status": "current",
  "updated_at": "2026-08-28T20:15:00+08:00",
  "revalidation_triggers": ["classification_table_changed", "workflow_contract_changed", "hosted_run_available"],
  "evidence": {
    "provenance": "executor_recorded",
    "environment_id": "ENV.GITHUB_ACTIONS",
    "assignment_ref": "TD-016-CI-TIERING-001",
    "operator_ref": "Current Grok session",
    "reviewer_ref": null,
    "coverage": "focused",
    "observed_at": "2026-08-28T20:15:00+08:00",
    "valid_until": null,
    "artifact_bindings": [
      {"kind": "commit", "identity": "0623e7c"},
      {"kind": "commit", "identity": "bd4b6eb"},
      {"kind": "url", "identity": "https://github.com/shchnk1103/Universe-Keyboard/pull/88"},
      {"kind": "url", "identity": "https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33169007898"}
    ],
    "permits_claim_ids": [],
    "prohibits_claim_ids": ["CLAIM.CI.TIERING_FAIL_CLOSED"]
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | current |
| Evidence grade | `Executor-recorded` |
| Material non-claims | Not merge authority; not Product/Quality acceptance; not required-check proof |

Temporary Draft PR [#88](https://github.com/shchnk1103/Universe-Keyboard/pull/88) targeted
`codex/td016-ci-tiering` (`0623e7c`). The exact PR diff contained one `docs/**` file and no
workflow, script, source, project, package, test or product-resource change.

Hosted run [`33169007898`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33169007898)
on GitHub synthetic merge ref `216267b`:

| Job | Result |
|---|---|
| `classify-change` | success in 4s; `docs_only`, `requires_full=false`, `changed_count=1` |
| `lightweight-checks` | success in 6s |
| `build-and-test` | skipped |
| `final-quality-gate` | success in 5s |

Classifier output:

```json
{"classification": "docs_only", "requires_full": "false", "reason": "all_paths_in_lightweight_allowlist", "changed_count": "1", "base_sha": "0623e7c489679d42dbda2d8d612a5d16c19e88d1", "head_sha": "216267b3e886cb0e127b33e2869b06292d951b78", "full_required_paths": []}
```

The fixture PR must be closed without merge after this evidence is recorded. Closing it does not
authorize #86/#87 merge, branch protection, required checks, Product acceptance or Release.
