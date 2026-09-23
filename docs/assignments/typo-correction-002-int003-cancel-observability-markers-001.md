# Assignment: TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001 — Proposed INT-003 cancel/debounce/epoch Diagnostics journal markers

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001",
  "record_type": "assignment",
  "title": "Proposed implementation: INT-003 cancel/debounce/epoch Diagnostics journal markers",
  "lifecycle": "ready",
  "current_phase": "Ready/Proposed — docs-only preflight; waiting Human to mark matching AUTH Live before any Swift/ObjC change",
  "authorization_action": "implement_int003_cancel_observability_journal_markers",
  "updated_at": "2026-09-23T16:03:00+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_bf2b4c5",
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
    "docs/assignments/typo-correction-002-int003-stale-cancel-product-capture-001.md",
    "docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md",
    "docs/architecture/decisions/0027-enterprise-local-diagnostic-observability.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Grok Bot (iOS开发大师) — docs Proposed preflight now; Swift/journal emit only after AUTH Live + consume",
    "environment_executor": "Not Applicable for this Proposed docs / future local implementation slice — no Simulator or Device Hub arm under this Assignment; Capture remains a separate AUTH",
    "human_dependency": "Human Product Owner / Product Lead — must mark matching AUTH Live before any Swift/ObjC/schema change; ADR 0027 field-budget review before landing new Codes/Flags",
    "architecture_reviewer": "Architecture & Knowledge Steward — required when Live for DiagnosticEvent Code/Flag / ADR 0027 field-budget boundary review (Not Applicable for this docs-only Proposed slice)",
    "quality_reviewer": "Independent Quality reviewer — required after Live implementation tip for focused emit/non-regression tests (Not Applicable for this docs-only Proposed slice)",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Ready / Proposed** (not Active Live implementation) |
| **Phase** | Docs-only Proposed Assignment + AUTH for controlled journal markers; **no** Swift / ObjC / RIME edits until AUTH is Live |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) — **Proposed / unconsumed** |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** |
| **Tip baseline (docs)** | `bf2b4c58562fbe44d61ff3938509cda8c69e2705` (`origin/main` after #149) |
| **Assignment Authority** | Human Product Owner / Product Lead |
| **Decision Source / Date** | Human chose audit **Option B** (implementation AUTH for markers) over docs-only Product path A — `2026-09-23 Asia/Shanghai`; Live mark is a separate Human decision |
| **Next** | Human reviews this Assignment/AUTH; marks AUTH **Live** when marker implementation is wanted — until then stay Proposed |
| **Non-claims** | Not Live; not Capture Live; not Product Gate; not parent Close; no cancel proof; no Run ID; Capture Assignment/AUTH remains Proposed and non-authorizing for Swift |

## Authority

- **Case / contract:** `TC2-CASE-INT-003` / `TC2-CTR-INT-002` ([Registry V2](../TYPO_BENCHMARK_REGISTRY_V2.md) — Pending).
- **Chosen path:** Observability audit [Option B — Implementation AUTH (future)](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md) — controlled journal fields so a **future** Live product capture can **prove** cancel/stale discard rather than infer from absence.
- **Related but non-authorizing for Swift:**
  - [Stale-cancel observability audit 2026-09-23](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md)
  - [Cadence-003 → Product gap matrix](../evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md)
  - [Capture Assignment](typo-correction-002-int003-stale-cancel-product-capture-001.md) + [Capture AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md) — remain **Proposed**; do **not** authorize marker implementation or Capture Live under this child
- **Schema discipline:** [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md) field-budget / privacy allowlist review required before landing new `DiagnosticEvent.Code` / `Flag` values when Live.
- **Does not reuse** consumed Cadence-003 / Capture-002 / stale-cancel Capture AUTH as Live authority for Swift.

## Why (hard-evidence path)

Merged tip after #149 proved the preflight package only. Journal v1 **cannot** prove stale cancel today (audit verdict). User disposition: take the markers path (audit Option B) so INT-003 Capture can later collect positive cancel/debounce/epoch observations instead of treating marker absence as evidence.

## Scope (Proposed; executes only after AUTH Live)

Minimal **controlled Diagnostics journal observability** — observe existing cancel/debounce/epoch behavior; **default: do not change** 180 ms product budget or eligibility rules unless required for emit correctness.

### Suggested event codes / observations (names explicit; refine under ADR 0027 when Live)

| Observation intent | Suggested code / note (executor may refine names) |
|---|---|
| Debounce / recall **scheduled** (or rescheduled) | e.g. `typo_recall.debounce_scheduled` (or reschedule variant) |
| Debounce / pending work-item **cancelled** (re-schedule path — primary rapid &lt;180 path) | e.g. `typo_recall.debounce_cancelled` |
| **`recallEpoch` bump** / hard **invalidate** | e.g. `typo_recall.epoch_bumped` / `typo_recall.invalidated` |
| Fence / yielded-token **discard** (stale in-flight) | e.g. `typo_recall.fence_discarded` |
| Contextual **query begin** / **end or outcome** (success / discarded / cancelled) | e.g. `typo_recall.query_begin` / `typo_recall.query_outcome` — only if feasible **without** `RimeRuntimeProvenance` restore |

### Bindings / fields (design intent when Live)

- `recallEpoch` (or equivalent bounded integer)
- Composition fingerprint / fence snapshot identity (**bounded**; no PII dump of composition text)
- Correlation with existing journal `processInstanceID` / `appearanceID` (and HF / schema version discipline)
- Keep high-fidelity + schema version discipline; cite ADR 0027 field-budget review before new Codes/Flags land

### Touch zones when Live (listed only; not execute now)

- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift` (primary emit points)
- `Packages/KeyboardCore/.../DiagnosticEvent.swift` (Code/Flag schema)
- Possibly thin call sites in `KeyboardViewController+TypoCorrection` / presentation if emit must live there
- Focused unit/contract tests for emit + non-regression
- Docs evidence for implementation tip (post-Live)

## Explicit non-goals / exclusions

- Restoring `RimeRuntimeProvenance.swift`
- Product Gate / parent Close / Release / TestFlight
- Capturing under this AUTH (capture stays under separate Capture AUTH after markers land)
- Changing 180 ms product budget / eligibility rules unless required for emit correctness (default: observe only)
- Reusing consumed Cadence-003 / Capture-002 / stale-cancel Capture AUTH as Live authority for Swift
- Marking Capture AUTH Live; updating `ACTIVE_WORK` to imply Live
- Commit / push / merge without separate ask (docs Proposed commit on this branch is allowed under the drafting task; push/PR/merge are not)

## Dependencies

1. Human marks matching AUTH **Live** before any Swift / ObjC / schema change.
2. When Live: consume AUTH **before** first Swift change; ADR 0027 field-budget review before new Codes/Flags.
3. Parent TYPO-CORRECTION-002 stays Active regardless of this child’s Ready state.
4. Capture Assignment/AUTH stay Proposed and are **not** Live authority for this implementation.

## Entry Criteria

1. No required Assignment responsibility field is `UNKNOWN`.
2. Observability audit + Cadence-003→Product gap matrix exist and do not claim Product Gate / cancel proof; audit Option B is the chosen markers path.
3. Matching AUTH exists as **Proposed / unconsumed** (this child’s Ready state does **not** authorize Swift).
4. Parent [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active**.
5. Tip baseline is `bf2b4c58562fbe44d61ff3938509cda8c69e2705` (or revalidated).
6. **Ready for docs Proposed preflight only.** Entering Active Live implementation additionally requires Human marking the matching AUTH **Live**.

## Exit Criteria (docs Proposed slice — current)

1. Assignment + Proposed AUTH written under `docs/` with tip `bf2b4c5…`, non-claims, audit Option B citation, and Capture remaining non-authorizing for Swift.
2. Explicit statement that this slice does **not** implement markers, capture, or prove cancel.
3. No Swift / ObjC / RIME edits; no Capture Live; no ACTIVE_WORK Live implication under this slice.

## Exit Criteria (future Live implementation slice — only after AUTH Live)

1. AUTH consumed before first Swift change; tip + schema/HF discipline recorded.
2. ADR 0027 field-budget review completed for any new Codes/Flags.
3. Minimal emit points land in allowed touch zones; focused unit/contract tests pass for emit + non-regression.
4. Behavior remains observe-only by default (no 180 ms / eligibility product-rule change unless emit correctness requires it — document if so).
5. Implementation tip evidence under `docs/evidence/`; Capture / Product Gate remain **separate** AUTHs — consumption of this AUTH does **not** grant Capture Live, Gate, or merge.

## Stop Conditions

- AUTH still Proposed → **stop** before any Swift / ObjC / schema change.
- Tip drifts from `bf2b4c5…` without revalidation → stop and reopen.
- Request to restore `RimeRuntimeProvenance`, run Capture under this AUTH, mark Capture Live, Product Gate, parent Close, Release/TestFlight → stop; needs separate AUTH.
- Request to change 180 ms budget / eligibility for non-emit reasons → stop; out of default scope.
- Attempt to reuse consumed Cadence-003 / Capture-002 / Capture stale-cancel AUTH as Live Swift authority → stop.

## Required Evidence

| Slice | Evidence |
|---|---|
| Proposed (now) | This Assignment + matching Proposed AUTH; cite [`observability audit`](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md) Option B + [`gap matrix`](../evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md) |
| Related non-authorizing | [`Capture Assignment`](typo-correction-002-int003-stale-cancel-product-capture-001.md) (stays Proposed) |
| Live implementation (future) | Fresh `docs/evidence/…` tip/receipt for marker landing + test summary — **not minted yet** |
| Capture after markers | Separate Capture AUTH Live path — **not this Assignment** |

## Handoff Target

- **Now:** Human Product Owner / Product Lead — review Proposed AUTH; decide Live for marker implementation.
- **After Live implementation tip:** Independent Architecture (ADR 0027 / Code-Flag budget) and Quality reviewers; then separate Capture AUTH Live for hard-evidence product observation; Product Gate only under an explicit Gate AUTH.

## Outcome (current)

Proposed docs package written for audit Option B (markers). Assignment is **Ready/Proposed**. No Swift. No capture. Still not Live. Capture AUTH remains Proposed / unconsumed.
