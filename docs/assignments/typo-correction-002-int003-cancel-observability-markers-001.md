# Assignment: TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001 — INT-003 cancel/debounce/epoch Diagnostics journal markers (AUTH consumed; implementing)

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001",
  "record_type": "assignment",
  "title": "INT-003 cancel/debounce/epoch Diagnostics journal markers (AUTH consumed; implementing)",
  "lifecycle": "active",
  "current_phase": "Markers slice Done on implementation tip; AUTH consumed; PR unmerged; Capture still Proposed",
  "authorization_action": "implement_int003_cancel_observability_journal_markers",
  "updated_at": "2026-09-23T18:47:17+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_implementation_tip",
    "observability_audit_or_gap_matrix_superseded",
    "ADR_0027_field_budget_or_schema_policy_changed",
    "scope_expansion_toward_capture_gate_or_provenance_restore",
    "AUTH_revoked_or_executor_changed",
    "parent_close_or_int003_product_gate_granted_elsewhere",
    "180_ms_product_budget_or_eligibility_rules_changed_without_emit_necessity"
  ],
  "authorization_refs": ["AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001"],
  "parent_refs": ["TYPO-CORRECTION-002"],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md",
    "docs/evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md",
    "docs/evidence/typo-correction-002-int003-cancel-observability-markers-field-budget-2026-09-23.md",
    "docs/evidence/typo-correction-002-int003-cancel-observability-markers-impl-2026-09-23.md",
    "docs/assignments/typo-correction-002-int003-stale-cancel-product-capture-001.md",
    "docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md",
    "docs/architecture/decisions/0027-enterprise-local-diagnostic-observability.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Grok Bot (iOS开发大师) — AUTH consumed; implementing markers under Human continue-auth",
    "environment_executor": "Not Applicable for Simulator/Device Hub arm under this Assignment; Capture remains a separate AUTH",
    "human_dependency": "Human Product Owner / Product Lead — continue-auth granted consume + open implementation PR; do not merge without separate ask",
    "architecture_reviewer": "Architecture & Knowledge Steward — ADR 0027 field-budget recorded; post-tip Architecture review still separate",
    "quality_reviewer": "Independent Quality reviewer — required after implementation tip for focused emit/non-regression tests",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Active** (AUTH **Consumed**; markers implementing) |
| **Phase** | Markers slice Done on implementation tip; AUTH consumed; PR unmerged; Capture still Proposed |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) — **Consumed** at `2026-09-23T18:47:17+08:00` |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** |
| **Tip baseline (docs Live mark)** | `9b8b7a73f4d373adbd7ee436d318cde3d9bc4c78` (#151) |
| **Assignment Authority** | Human Product Owner / Product Lead |
| **Decision Source / Date** | Human chose audit **Option B**; Live mark after #150; continue-auth consume+impl PR — `2026-09-23 Asia/Shanghai` |
| **Next** | Land markers tip → hosted CI → Human merge decision; then separate Architecture/Quality; Capture AUTH stays Proposed |
| **Non-claims** | Not Capture Live; not Product Gate; not parent Close; no cancel proof from markers alone; Capture Assignment/AUTH remains Proposed |

## Authority

- **Case / contract:** `TC2-CASE-INT-003` / `TC2-CTR-INT-002`.
- **Chosen path:** Observability audit Option B — controlled journal fields.
- **Schema discipline:** [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md); field-budget [`evidence`](../evidence/typo-correction-002-int003-cancel-observability-markers-field-budget-2026-09-23.md) **accepted before Swift**.
- Capture Assignment/AUTH remain **Proposed** / non-authorizing for Swift beyond this markers child.

## Scope (AUTH consumed; observe-only markers)

Minimal controlled Diagnostics journal observability — **default: do not change** 180 ms product budget or eligibility.

### Accepted Codes / fields

See AUTH + field-budget evidence. Emit gated by high-fidelity window. No composition text; FNV-1a fingerprint + length only.

### Touch zones

- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift`
- `Packages/KeyboardCore/.../DiagnosticEvent.swift`
- `Packages/KeyboardCore/.../TypoCorrectionRecallDiagnosticMarkers.swift`
- Focused KeyboardCore tests; implementation evidence under `docs/evidence/`

## Explicit non-goals / exclusions

- Restoring `RimeRuntimeProvenance.swift`
- Product Gate / parent Close / Release / TestFlight
- Capturing under this AUTH
- Changing 180 ms / eligibility unless emit correctness requires it
- Merging the implementation PR without separate Human ask
- Marking Capture AUTH Live

## Exit Criteria (Live implementation slice)

1. AUTH consumed before first Swift change; tip + schema/HF discipline recorded — **in progress on this PR**.
2. ADR 0027 field-budget review completed — **met**.
3. Minimal emit points land; focused unit/contract tests for schema/fields.
4. Observe-only by default (no 180 ms / eligibility change).
5. Implementation tip evidence; Capture / Product Gate remain separate.

## Stop Conditions

- Request to restore `RimeRuntimeProvenance`, run Capture under this AUTH, mark Capture Live, Product Gate, parent Close, Release/TestFlight → stop.
- Request to change 180 ms budget / eligibility for non-emit reasons → stop.
- Attempt to merge PR without separate Human ask → stop.

## Outcome (current)

AUTH **Consumed** at `2026-09-23T18:47:17+08:00` under Human continue-auth. Field-budget accepted. Markers implementation follows on the same PR. Capture AUTH remains Proposed. Parent Active. No Gate.
