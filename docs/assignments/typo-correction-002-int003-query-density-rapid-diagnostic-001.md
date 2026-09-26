# Assignment: TYPO-CORRECTION-002-INT003-QUERY-DENSITY-RAPID-DIAGNOSTIC-001

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-RAPID-DIAGNOSTIC-001",
  "record_type": "assignment",
  "title": "INT-003 query-density rapid visible-key diagnostic capture",
  "lifecycle": "completed",
  "current_phase": "Product removed the 180 ms hard pass condition on 2026-09-26. The reserved rapid Run had a read-only UI snapshot only; no input or new journal. The consumed AUTH remains spent, and this no-run disposition completes the revised diagnostic accounting without a rapid-behavior claim",
  "authorization_action": "capture_int003_query_density_rapid_visible_key_diagnostic",
  "updated_at": "2026-09-26T10:47:54+08:00",
  "revalidation_triggers": [
    "github_main_tip_changed_from_4ef275b",
    "designated_simulator_unavailable_or_changed",
    "diagnostic_schema_or_marker_contract_changed",
    "raw_journal_capture_or_sha_unavailable",
    "AUTH_revoked_or_executor_changed",
    "scope_expansion_to_product_capture_or_gate_or_source_change"
  ],
  "authorization_refs": ["AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-RAPID-DIAGNOSTIC-001"],
  "parent_refs": ["TYPO-CORRECTION-002"],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-density-post-merge-state-sync-2026-09-26.md",
    "docs/product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md",
    "docs/evidence/typo-correction-002-int003-query-density-diagnosis-001.md",
    "docs/evidence/typo-correction-002-sim-run-2026-09-25-int003-query-density-diagnostic-001.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Codex current task under Human authorization to continue all remaining narrow query-density work",
    "environment_executor": "Codex current task — only the exact simulator, visible-key automation, and diagnostic operations named in the consumed AUTH",
    "human_dependency": "No additional Human typing is requested; this run makes no Human visual/Product claim",
    "architecture_reviewer": "Not Applicable for this diagnostic-only capture; any source change needs the appropriate separate review",
    "quality_reviewer": "Not Applicable for this diagnostic-only capture; no Product Gate or Quality claim is made",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Completed — revised no-run accounting; not Reviewed or Closed** |
| **Phase** | Product removed this follow-up's 180 ms hard pass condition. The reserved Run had one read-only UI snapshot; no diagnostic re-arm, keyboard input, or new raw journal. The remaining run permission will not be exercised |
| **Publication** | [PR #175](https://github.com/shchnk1103/Universe-Keyboard/pull/175) squash merged as `10faa51caf20e3c558f21f26b625eff7f3aa941d`; [M-02 receipt](../evidence/typo-correction-002-int003-query-density-post-merge-state-sync-2026-09-26.md) records this no-run lifecycle state |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** |
| **Source binding** | GitHub `main` `4ef275b57d16f116b4edbae99a0e244a28d6bf25`, reverified read-only immediately before this Assignment/AUTH; the installed Debug app and extension binaries were built from this tip |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-RAPID-DIAGNOSTIC-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-RAPID-DIAGNOSTIC-001.md) — **Consumed** |
| **Prior Capture AUTHs** | Product Capture, diagnostic Capture 001, and Markers AUTH are **Consumed** and not reused |
| **Designated Simulator** | `06C5BC3E-7599-4761-A1A2-71DAEA991474` — iPhone 17 Pro Max / iOS 27; no device substitution |
| **Run ID** | `TC2-SIM-20260925-171300-INT003-QUERY-DENSITY-RAPID-001` — generated before simulator inspection, arming, relaunch, or input |
| **Authorization source** | Human: 「授权你进行接下来的所有工作」 — `2026-09-25` Asia/Shanghai; this is a distinct one-run AUTH because prior Capture AUTHs are Consumed |
| **Next** | See the [Product criterion decision](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md) and the completed first [diagnostic run](../evidence/typo-correction-002-sim-run-2026-09-25-int003-query-density-diagnostic-001.md); any new rapid-behavior claim requires a new plan and authority |
| **Non-claims** | No Product/UX claim; no Product Gate / QA-001 Gate; no parent Close; no TestFlight / Release; no Swift / tests; no fence remediation; no `RimeRuntimeProvenance` restore |

## Scope

> **Superseded execution target (2026-09-26):** The following visible-key rapid-run instructions describe the original consumed AUTH. Product removed the 180 ms hard pass condition for this follow-up diagnosis before key input. This Run ID has no capture data and must not be reported as a rapid Pass or retried under the consumed AUTH.

1. Run once on the exact designated simulator and source tip above, using automated taps on the **visible on-screen keyboard keys**. The taps must be observable `touch.terminal` events; do not inject text with `type_text`, hardware-key sequences, APIs, or clipboard.
2. Produce at least five adjacent inter-key intervals below 180 ms, then pause at least 180 ms. Use only synthetic input in the existing app trial field.
3. Re-arm the existing high-fidelity diagnostics window for this run if required, and start a fresh Keyboard Extension process where practical so the run-specific journal can be separated.
4. Preserve the raw dynamic Extension JSONL outside the repository and record its SHA-256 before reading event rows. Report only event codes, timestamps/monotonic intervals, process and appearance IDs, operation ordinals, composition revisions, reason enums, and counts. Do not output composition, candidate, host, or fingerprint values.
5. Compare query pairs with visible-key timing, scheduled/cancelled debounce markers, operation ordinals, and fence markers. The result is diagnostic only; a missed rapid cadence must be recorded as a limitation.

## Entry and stop conditions

- AUTH was consumed at `2026-09-25T17:13:00+08:00`, after read-only verification that GitHub `main` still equals `4ef275b57d16f116b4edbae99a0e244a28d6bf25`, and before any simulator operation.
- Do not use the prior Capture AUTHs as authority for this run. No third run is authorized by this Assignment.
- If visible key controls are not exposed to the approved UI automation, stop without typing by another route. Record the automation limitation and preserve any journal only if the run has already begun.
- If source tip, simulator identity, diagnostic availability, or raw journal hash cannot be verified, stop and record the boundary; do not substitute a device or infer the timeline.
- Any request to change Swift, add tests, expand to fence remediation, make a Product claim, or perform a Gate/release/merge requires the corresponding distinct Assignment/AUTH.

## Exit criteria

1. Record whether at least five consecutive intervals were below 180 ms, plus the pause interval.
2. Preserve and hash the raw JSONL before inspection; record operation-level query counts/timing without input text.
3. Bound the original rapid-window question or explicitly state what remains unresolved.
4. Keep parent `TYPO-CORRECTION-002` Active. No Product Gate or source change follows from this capture.
