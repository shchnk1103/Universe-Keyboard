# Product Decision: TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003 — residual disposition

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-RESIDUAL",
  "record_type": "decision",
  "title": "Accept bounded residual dispositions for performance revalidation 03",
  "status": "accepted",
  "updated_at": "2026-09-19T20:38:02+08:00",
  "revalidation_triggers": [
    "new_performance_run_requested",
    "comparison_design_changed",
    "package_or_provenance_changed",
    "scope_changed",
    "parent_close_requested"
  ],
  "decision": {
    "authority_role": "Human Product Owner / Product Lead",
    "decision_source": "Current Codex task, 2026-09-19 Asia/Shanghai: confirmed docs-only Product residual reconciliation",
    "scope": "Disposition only the residuals of TC2-PERF-20260919-195848-REVAL-03",
    "outcome": "Accepted as bounded evidence disposition; paired performance remains inconclusive and no Gate is closed",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Lifecycle | `Accepted — bounded residual disposition only` |
| Target | `TC2-PERF-20260919-195848-REVAL-03` |
| Evidence state | BASELINE and TREATMENT were captured, but the keyboard-extension process changed between arms; paired performance is `inconclusive / not measurable` |
| Parent | `TYPO-CORRECTION-002-PARENT-REVALIDATION-002` remains `Active` |
| Non-claims | Not a performance Pass, 180 ms budget, QA-001 Pass, INT-003 Pass, Product/Quality/Release Gate, merge, Release or Assignment Close |
| Next | Do not rerun under this decision; a future valid pair requires a new Authorization, Run ID and explicit comparison design |

## Authority and review basis

- Product residual Authorization: [`AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-PRODUCT-RESIDUAL-001`](../authorizations/AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-PRODUCT-RESIDUAL-001.md)
- Run Receipt: [`performance revalidation 03`](../evidence/typo-correction-002-sim-run-2026-09-19-performance-reval-03-inconclusive.md)
- Independent Architecture: [`performance Architecture review`](../reviews/typo-correction-002-sim-run-2026-09-19-performance-reval-03-architecture-review.md)
- Independent Quality: [`performance Quality review`](../reviews/typo-correction-002-sim-run-2026-09-19-performance-reval-03-quality-review.md)
- Parent Assignment: [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md)

The Product Lead accepts the independent reviewers' evidence-boundary
dispositions. This is a residual decision, not a claim that the contextual
correction path is fast, slow, correct, or ready for Release.

## Bound residual decisions

| Residual | Product disposition | Boundary / required follow-up |
|---|---|---|
| `PR-01` — different keyboard-extension processes | **Accepted as the reason this pair is invalid** | Do not derive a delta, median, percentile, worst value or budget; a future comparison needs a new Authorization/Run with explicitly controlled process lifecycle |
| `PR-02` — startup `route=unavailable` before later direct sidecar events | **Accepted as lifecycle evidence** | Do not claim every key from cold start used `real_rime_sidecar` |
| `PR-03` — treatment sidecar elapsed `1–6 ms` | **Accepted as bounded internal observation only** | Not end-to-end, user-perceived or 180 ms performance evidence |
| `PR-04` — Debug/Simulator and human-operated cadence | **Accepted as diagnostic limitation** | Not physical-device or Release performance evidence |
| `PR-05` — candidate recovery, QA-001 and INT-003 remain separate | **Retained open outside this Run** | Must not be closed or inferred from this Product Decision |

## Product boundary

This decision authorizes only the documentation reconciliation for this exact
Run. It does not authorize implementation, a new capture, a new process-control
harness, publication, merge, TestFlight or Release. The parent Assignment stays
Active for its remaining lanes and may be revisited only through their own
Assignment/Authorization chain.
