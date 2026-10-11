# Assignment: TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001",
  "record_type": "assignment",
  "title": "INT-003 query-density raw journal diagnostic capture",
  "lifecycle": "completed",
  "current_phase": "One bounded capture completed; raw journal hashed before inspection and grouped by operation. Product removed the under-180 ms hard pass condition for this follow-up diagnosis on 2026-09-26. Actual 285.075–575.942 ms intervals remain recorded; no rapid-behavior or Product claim",
  "authorization_action": "capture_int003_query_density_raw_journal_diagnostic",
  "updated_at": "2026-09-26T10:47:54+08:00",
  "revalidation_triggers": [
    "github_main_tip_changed_from_4ef275b",
    "designated_simulator_unavailable_or_changed",
    "diagnostic_schema_or_marker_contract_changed",
    "raw_journal_capture_or_sha_unavailable",
    "AUTH_revoked_or_executor_changed",
    "scope_expansion_to_product_capture_or_gate_or_source_change"
  ],
  "authorization_refs": ["AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001"],
  "parent_refs": ["TYPO-CORRECTION-002"],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-density-post-merge-state-sync-2026-09-26.md",
    "docs/product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md",
    "docs/evidence/typo-correction-002-int003-query-density-diagnosis-001.md",
    "docs/evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md",
    "docs/evidence/typo-correction-002-sim-run-2026-09-25-int003-query-density-diagnostic-001.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Codex current task under Human continuation authorization",
    "environment_executor": "Codex current task — exact Simulator build, install, launch, diagnostic configuration, and journal handling; Human enabled the keyboard in Settings and performed the visible synthetic key taps",
    "human_dependency": "Human completed the visible-key input step. Their fastest repeatable manual cadence remained above the requested 180 ms threshold; no Human visual/Product claim is made",
    "architecture_reviewer": "Not Applicable for this bounded diagnostic capture; any source change or architectural interpretation requires the appropriate separate review",
    "quality_reviewer": "Not Applicable for this bounded diagnostic capture; no Product Gate or Quality claim is made",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Completed — diagnostic evidence delivered; not Reviewed or Closed** |
| **Phase** | AUTH **Consumed at `2026-09-25T16:06:56+08:00`**; Run `TC2-SIM-20260925-161830-INT003-QUERY-DENSITY-DIAGNOSTIC-001` completed. [Product removed](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md) the follow-up's 180 ms hard pass condition; the recorded manual cadence did not reach that value and supplies no rapid-behavior claim |
| **Publication** | [PR #175](https://github.com/shchnk1103/Universe-Keyboard/pull/175) squash merged as `10faa51caf20e3c558f21f26b625eff7f3aa941d`; [M-02 receipt](../evidence/typo-correction-002-int003-query-density-post-merge-state-sync-2026-09-26.md) is the one closeout trigger for the three diagnostic children |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** |
| **Source binding** | GitHub `main` `4ef275b57d16f116b4edbae99a0e244a28d6bf25`, reverified by explicit HTTPS query after PR #174. The `e28491a…` → `4ef275b…` delta contains only three unrelated KOS documents; all six scoped runtime source paths are unchanged |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001.md) — **Consumed** |
| **Prior Capture AUTH** | Product Capture AUTH is **Consumed** and not reusable |
| **Designated Simulator** | `06C5BC3E-7599-4761-A1A2-71DAEA991474` — iPhone 17 Pro Max / iOS 27 in the prior Capture record; current availability must be checked by explicit UDID before execution |
| **Run ID** | `TC2-SIM-20260925-161830-INT003-QUERY-DENSITY-DIAGNOSTIC-001` — generated and recorded before Simulator installation, arm, launch, or input |
| **Assignment Authority** | Human Product Owner / Product Lead |
| **Decision Source / Date** | Human: 「授权你进行接下来的所有工作」 — `2026-09-25` Asia/Shanghai; this new Assignment/AUTH exists only to reacquire the missing raw query-density journal |
| **Next** | Evidence is mirrored in the [diagnosis](../evidence/typo-correction-002-int003-query-density-diagnosis-001.md). The Capture AUTH is Consumed and authorizes no further run. Wider residual disposition remains with Product; any new capture or source change needs its own current authorization |
| **Non-claims** | No Product visual claim; no Product Gate / QA-001 Gate; no parent close; no TestFlight / Release; no Swift change; no `fence_discarded` remediation |

## Scope

1. At verified tip `4ef275b57d16f116b4edbae99a0e244a28d6bf25`, perform one bounded diagnostic rerun on the designated Simulator, using the existing synthetic INT-003 visible-key cadence procedure. The intervening docs-only delta from `e28491a…` did not change the scoped runtime source files.
2. Capture and preserve the raw dynamic Keyboard Extension JSONL before any Simulator cleanup; hash it before reading event rows.
3. Summarize only event codes, timestamps, process/appearance identifiers, operation ordinals, composition revisions, and counts. Do not output or commit normalized composition, host text, candidate text, credentials, or unrelated journal fields.
4. Group `query_begin` / `query_outcome` events by operation ordinal; compare them with debounce markers and visible-key timestamps to determine whether calls are multiple hypotheses within settled operations or new operations crossing the intended 180 ms pause boundary.
5. This Assignment makes no Product behavior, UI, Gate, performance, or release claim. A later source change remains within the parent query-density remediation Assignment and its scope.

## Environment and fixed inputs

| Item | Value |
|---|---|
| GitHub source | `shchnk1103/Universe-Keyboard`, `main` at `4ef275b57d16f116b4edbae99a0e244a28d6bf25` |
| Simulator | iPhone 17 Pro Max / iOS 27 / UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`; must be rediscovered with `xcrun simctl list devices` and targeted by explicit UDID |
| Stimulus | Existing synthetic INT-003 long-composition sequence, visible-key taps only. Target was starts under 180 ms followed by a pause of at least 180 ms; actual manual intervals were 285.075–575.942 ms, so this run did not include a qualifying rapid segment |
| Diagnostics | Arm through the Simulator App Group container and refresh the high-fidelity window as documented by the prior capture procedure |
| Raw artifact | Dynamic `keyboard_extension-<processInstanceID>-<hour>-<part>.jsonl`; copy outside the repository into the run-specific `/private/tmp` directory and record the actual SHA-256 |
| Evidence output | Repository evidence note with run header, exact tool/device facts, hash, aggregate event timeline and explicit limits; raw JSONL stays outside the repository |

## Entry criteria

1. This new AUTH was **Consumed** at `2026-09-25T16:06:56+08:00` before the first Simulator listing, boot, arm, build, install, launch, input, or journal operation.
2. GitHub `main` still equals the bound tip `4ef275b57d16f116b4edbae99a0e244a28d6bf25`; otherwise stop and revalidate this Assignment/AUTH.
3. The exact designated Simulator UDID is currently available. Do not silently substitute a different device.
4. Run `TC2-SIM-20260925-161830-INT003-QUERY-DENSITY-DIAGNOSTIC-001` was generated before Simulator installation, arming, launch, or input.
5. The raw journal can be preserved and hashed without publishing its input fields.
6. Parent remains Active. No Gate, release, or unrelated work is in this run.

## Stop conditions

- Missing or changed Assignment/AUTH, source tip drift, unavailable exact Simulator, or unavailable raw journal: stop and record the precise boundary; do not substitute a device or infer an event timeline.
- Any request to include Product visual claims, expand to `fence_discarded` remediation, change product behavior, or claim a Gate: stop and open the appropriate separate Assignment/AUTH.
- Never reuse the Consumed Product Capture AUTH or Markers AUTH as authority for this run.
- Do not change Swift, tests, project configuration, or diagnostic schema under this capture Assignment.

## Exit criteria

1. Raw journal is preserved under the Run ID and its SHA-256 is recorded before inspection.
2. Evidence records operation-level query counts/timestamps without input text and cites exact source tip, device, OS, and capture method.
3. Root cause is either boundedly established or explicitly unresolved; no product or Gate inference.
4. Parent remains Active; this child remains Active until its evidence is mirrored and separately reviewed if required.
