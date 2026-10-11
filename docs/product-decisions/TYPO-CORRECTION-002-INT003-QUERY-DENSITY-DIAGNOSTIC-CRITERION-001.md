# Product Decision: INT-003 query-density diagnostic criterion

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001",
  "record_type": "decision",
  "title": "Remove the 180 ms hard pass condition from the query-density follow-up diagnosis",
  "status": "accepted",
  "updated_at": "2026-09-26T10:37:24+08:00",
  "revalidation_triggers": [
    "new_rapid_behavior_claim_requested",
    "query_density_product_residual_disposition_requested",
    "debounce_runtime_budget_change_requested",
    "INT003_or_QA001_Gate_requested",
    "contradictory_raw_journal_or_source_evidence"
  ],
  "decision": {
    "authority_role": "Human Product Owner / Product Lead",
    "decision_source": "Human 2026-09-26 Asia/Shanghai: authorized cancellation of the 180 ms hard pass condition and continuation of unfinished work under KOS",
    "scope": "Only the follow-up INT-003 query-density diagnostic criterion and disposition of the prepared rapid diagnostic run; historical Capture facts and runtime debounce contract are unchanged",
    "outcome": "Record measured key intervals and query/debounce timing without a minimum rapid-cadence pass bar. Stop the prepared second capture before input because the new diagnostic criterion is already addressed by the completed first follow-up run. Preserve the original rapid-window attribution as unresolved; do not infer a rapid-behavior pass or accept the broader query-density Product residual.",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Decision | **Accepted** for this follow-up diagnostic only |
| Evidence | [Diagnostic Run 001](../evidence/typo-correction-002-sim-run-2026-09-25-int003-query-density-diagnostic-001.md): 359 real query pairs in 12 operations; measured key intervals 285.075–575.942 ms |
| Prepared rapid run | `TC2-SIM-20260925-171300-INT003-QUERY-DENSITY-RAPID-001`: AUTH Consumed and Run ID reserved; read-only UI snapshot only, no diagnostic re-arm, key input, or run-specific journal; stopped after Human pause and this criterion decision |
| Remaining boundary | The 2026-09-23 Product Capture's 16/16 rapid-window query pairs cannot be grouped by operation without its original raw journal. This exact attribution remains unresolved |
| Parent | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) remains **Active** |
| Non-claims | No rapid-behavior Pass, Product/QA-001 Gate, parent Close, Swift change, 180 ms runtime-budget change, or acceptance of the wider `query_*` residual |
| Publication / next | Bounded accounting merged in [PR #175](https://github.com/shchnk1103/Universe-Keyboard/pull/175) as `10faa51caf20e3c558f21f26b625eff7f3aa941d`; [M-02 closeout](../evidence/typo-correction-002-int003-query-density-post-merge-state-sync-2026-09-26.md) is pending publication. Product may separately decide whether the remaining query fan-out and unknown old rapid-window attribution are acceptable or require a new scoped remediation |

## Decision boundary

The 180 ms value is the coordinator's debounce delay. A follow-up diagnosis can answer whether marker density reflects actual candidate-query calls, and how those calls group by operation, without requiring a person or UI tool to generate five consecutive inter-key intervals below that delay. The actual intervals remain evidence, not a pass/fail substitute.

A claim specifically about behavior during a `<180 ms` rapid segment still requires qualifying evidence. The historical [Cadence-003](TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL.md) and [Product Capture](TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md) observations retain their original measured cadence and bounded review dispositions. This decision neither changes those records nor retroactively passes the new follow-up run as rapid.

The [source/journal diagnosis](../evidence/typo-correction-002-int003-query-density-diagnosis-001.md) rules out duplicate marker-only emission and identifies per-hypothesis query fan-out in the fresh run. It does not prove that the earlier rapid-window queries were scheduled after every keystroke, or that the fan-out is acceptable for product performance. No source fix follows from this decision alone.

## Rapid Capture no-run disposition

The [rapid diagnostic AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-RAPID-DIAGNOSTIC-001.md) was already Consumed at `2026-09-25T17:13:00+08:00`; it remains Consumed and cannot be reused. The run identifier was allocated before a read-only UI snapshot. The snapshot exposed the app trial field but no visible keyboard-key tap references. The Human then requested a pause. No keyboard input, high-fidelity re-arm, fresh Extension process, or new raw journal is claimed for that Run ID. Product has now removed this run's hard-cadence purpose; the remaining one-run permission is not exercised.

## Revalidation

If Product later requires an exact rapid-window explanation, create a new evidence plan with a reproducible input method and a separate Assignment/AUTH; keep the `<180 ms` condition for any actual rapid-behavior claim. A Swift change, Gate, Release, or parent Close requires its own authority and evidence. No ADR or CHANGELOG change is required because runtime behavior and product contract are unchanged.
