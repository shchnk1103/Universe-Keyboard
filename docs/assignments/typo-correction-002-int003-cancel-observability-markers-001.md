# Assignment: TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001 — Live INT-003 cancel/debounce/epoch Diagnostics journal markers (unconsumed)

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001",
  "record_type": "assignment",
  "title": "Live implementation AUTH: INT-003 cancel/debounce/epoch Diagnostics journal markers (unconsumed)",
  "lifecycle": "active",
  "current_phase": "Active Live AUTH (unconsumed); waiting consume before first Swift/ObjC/schema change; ADR 0027 field-budget before new Codes/Flags",
  "authorization_action": "implement_int003_cancel_observability_journal_markers",
  "updated_at": "2026-09-23T18:31:00+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_d74462e",
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
    "executor": "Grok Bot (iOS开发大师) — AUTH Live/unconsumed; Swift/journal emit only after consume",
    "environment_executor": "Not Applicable for this Live-unconsumed docs / future local implementation slice — no Simulator or Device Hub arm under this Assignment; Capture remains a separate AUTH",
    "human_dependency": "Human Product Owner / Product Lead — AUTH Live marked; consume before any Swift/ObjC/schema change; ADR 0027 field-budget review before landing new Codes/Flags",
    "architecture_reviewer": "Architecture & Knowledge Steward — required before/when implementing for DiagnosticEvent Code/Flag / ADR 0027 field-budget boundary review",
    "quality_reviewer": "Independent Quality reviewer — required after Live implementation tip for focused emit/non-regression tests",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Active** (AUTH Live / unconsumed) |
| **Phase** | Active Live AUTH (unconsumed); waiting consume before first Swift/ObjC/schema change; ADR 0027 field-budget before new Codes/Flags |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) — **Live / unconsumed** |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** |
| **Tip baseline (docs)** | `d74462ed26ec4c09cac35386ed71ec99b212aebc` (#150 squash-merge); Proposed package historically bound to `bf2b4c58562fbe44d61ff3938509cda8c69e2705` and landed via #150 → `d74462e…` |
| **Assignment Authority** | Human Product Owner / Product Lead |
| **Decision Source / Date** | Human chose audit **Option B** (implementation AUTH for markers) — `2026-09-23 Asia/Shanghai`; Human Live mark after #150 merge at `2026-09-23T18:31:00+08:00` |
| **Next** | Consume AUTH before first Swift (separate implementation slice); then ADR 0027 field-budget before new Codes/Flags |
| **Non-claims** | AUTH is Live but not consumed; still not Capture Live; not Product Gate; not parent Close; no cancel proof; Capture Assignment/AUTH remains Proposed and non-authorizing for Swift |

## Authority

- **Case / contract:** `TC2-CASE-INT-003` / `TC2-CTR-INT-002` ([Registry V2](../TYPO_BENCHMARK_REGISTRY_V2.md) — Pending).
- **Chosen path:** Observability audit [Option B — Implementation AUTH](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md) — controlled journal fields so a **future** Live product capture can **prove** cancel/stale discard rather than infer from absence.
- **Related but non-authorizing for Swift:**
  - [Stale-cancel observability audit 2026-09-23](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md)
  - [Cadence-003 → Product gap matrix](../evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md)
  - [Capture Assignment](typo-correction-002-int003-stale-cancel-product-capture-001.md) + [Capture AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md) — remain **Proposed**; do **not** authorize Capture Live under this child
- **Schema discipline:** [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md) field-budget / privacy allowlist review required before landing new `DiagnosticEvent.Code` / `Flag` values when implementing.
- **Does not reuse** consumed Cadence-003 / Capture-002 / stale-cancel Capture AUTH as Live authority for Swift.

## Why (hard-evidence path)

Merged tip after #149 proved the preflight package only. Journal v1 **cannot** prove stale cancel today (audit verdict). User disposition: take the markers path (audit Option B) so INT-003 Capture can later collect positive cancel/debounce/epoch observations instead of treating marker absence as evidence. #150 landed the Proposed AUTH/Assignment docs; Human then marked this AUTH Live (still unconsumed).

## Scope (Live AUTH unconsumed; execute Swift only after consume)

Minimal **controlled Diagnostics journal observability** — observe existing cancel/debounce/epoch behavior; **default: do not change** 180 ms product budget or eligibility rules unless required for emit correctness.

### Suggested event codes / observations (names explicit; refine under ADR 0027 when implementing)

| Observation intent | Suggested code / note (executor may refine names) |
|---|---|
| Debounce / recall **scheduled** (or rescheduled) | e.g. `typo_recall.debounce_scheduled` (or reschedule variant) |
| Debounce / pending work-item **cancelled** (re-schedule path — primary rapid &lt;180 path) | e.g. `typo_recall.debounce_cancelled` |
| **`recallEpoch` bump** / hard **invalidate** | e.g. `typo_recall.epoch_bumped` / `typo_recall.invalidated` |
| Fence / yielded-token **discard** (stale in-flight) | e.g. `typo_recall.fence_discarded` |
| Contextual **query begin** / **end or outcome** (success / discarded / cancelled) | e.g. `typo_recall.query_begin` / `typo_recall.query_outcome` — only if feasible **without** `RimeRuntimeProvenance` restore |

### Bindings / fields (design intent when implementing)

- `recallEpoch` (or equivalent bounded integer)
- Composition fingerprint / fence snapshot identity (**bounded**; no PII dump of composition text)
- Correlation with existing journal `processInstanceID` / `appearanceID` (and HF / schema version discipline)
- Keep high-fidelity + schema version discipline; cite ADR 0027 field-budget review before new Codes/Flags land

### Touch zones when implementing (listed only; consume AUTH before first edit)

- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift` (primary emit points)
- `Packages/KeyboardCore/.../DiagnosticEvent.swift` (Code/Flag schema)
- Possibly thin call sites in `KeyboardViewController+TypoCorrection` / presentation if emit must live there
- Focused unit/contract tests for emit + non-regression
- Docs evidence for implementation tip (post-consume)

## Explicit non-goals / exclusions

- Restoring `RimeRuntimeProvenance.swift`
- Product Gate / parent Close / Release / TestFlight
- Capturing under this AUTH (capture stays under separate Capture AUTH after markers land)
- Changing 180 ms product budget / eligibility rules unless required for emit correctness (default: observe only)
- Reusing consumed Cadence-003 / Capture-002 / stale-cancel Capture AUTH as Live authority for Swift
- Marking Capture AUTH Live; updating `ACTIVE_WORK` to imply Live beyond this markers AUTH Live mark
- Commit / push / merge of Swift without separate ask (this Live docs commit/PR is allowed under the Live-mark task)

## Dependencies

1. Matching AUTH is **Live / unconsumed**; still **consume** before any Swift / ObjC / schema change.
2. When implementing: consume AUTH **before** first Swift change; ADR 0027 field-budget review before new Codes/Flags.
3. Parent TYPO-CORRECTION-002 stays Active regardless of this child’s Active Live-unconsumed state.
4. Capture Assignment/AUTH stay Proposed and are **not** Live authority for this implementation.

## Entry Criteria

1. No required Assignment responsibility field is `UNKNOWN`.
2. Observability audit + Cadence-003→Product gap matrix exist and do not claim Product Gate / cancel proof; audit Option B is the chosen markers path.
3. Matching AUTH exists as **Live / unconsumed** (docs Proposed entry already satisfied via #150; Live mark at `2026-09-23T18:31:00+08:00`).
4. Parent [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active**.
5. Tip baseline is `d74462ed26ec4c09cac35386ed71ec99b212aebc` (or revalidated); Proposed historical tip `bf2b4c5…` landed via #150.
6. **Active Live AUTH (unconsumed).** Entering Swift implementation additionally requires consuming the matching AUTH before the first Swift/ObjC/schema change.

## Exit Criteria (docs Proposed slice — met via #150)

1. Assignment + Proposed AUTH written under `docs/` with tip `bf2b4c5…`, non-claims, audit Option B citation, and Capture remaining non-authorizing for Swift — **met** via #150 merge tip `d74462ed26ec4c09cac35386ed71ec99b212aebc`.
2. Explicit statement that this slice does **not** implement markers, capture, or prove cancel — **met**.
3. No Swift / ObjC / RIME edits; no Capture Live; no ACTIVE_WORK Live implication under the Proposed slice — **met**.

## Exit Criteria (future Live implementation slice — only after AUTH consume)

1. AUTH consumed before first Swift change; tip + schema/HF discipline recorded.
2. ADR 0027 field-budget review completed for any new Codes/Flags.
3. Minimal emit points land in allowed touch zones; focused unit/contract tests pass for emit + non-regression.
4. Behavior remains observe-only by default (no 180 ms / eligibility product-rule change unless emit correctness requires it — document if so).
5. Implementation tip evidence under `docs/evidence/`; Capture / Product Gate remain **separate** AUTHs — consumption of this AUTH does **not** grant Capture Live, Gate, or merge.

## Stop Conditions

- AUTH revoked or not Live → **stop** before any Swift / ObjC / schema change.
- Tip drifts from `d74462e…` without revalidation → stop and reopen.
- Request to restore `RimeRuntimeProvenance`, run Capture under this AUTH, mark Capture Live, Product Gate, parent Close, Release/TestFlight → stop; needs separate AUTH.
- Request to change 180 ms budget / eligibility for non-emit reasons → stop; out of default scope.
- Attempt to reuse consumed Cadence-003 / Capture-002 / Capture stale-cancel AUTH as Live Swift authority → stop.
- Attempt to edit Swift while AUTH remains unconsumed → stop; consume first.

## Required Evidence

| Slice | Evidence |
|---|---|
| Proposed (historical; met via #150) | Assignment + matching Proposed AUTH landed as tip `d74462e…` (#150); Proposed binding tip was `bf2b4c5…`; cite [`observability audit`](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md) Option B + [`gap matrix`](../evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md) |
| Live mark (now) | Matching AUTH **Live / unconsumed** at `2026-09-23T18:31:00+08:00`; tip baseline `d74462e…` |
| Related non-authorizing | [`Capture Assignment`](typo-correction-002-int003-stale-cancel-product-capture-001.md) (stays Proposed) |
| Live implementation (future) | Fresh `docs/evidence/…` tip/receipt for marker landing + test summary — **not minted yet**; requires separate ask after consume |
| Capture after markers | Separate Capture AUTH Live path — **not this Assignment** |

## Handoff Target

- **Now:** AUTH is Live / unconsumed. Next is consume + implement markers (needs separate ask for Swift commit/push/PR). Capture still Proposed.
- **After Live implementation tip:** Independent Architecture (ADR 0027 / Code-Flag budget) and Quality reviewers; then separate Capture AUTH Live for hard-evidence product observation; Product Gate only under an explicit Gate AUTH.

## Outcome (current)

AUTH is **Live / unconsumed** after Human authorization following #150 merge tip `d74462e…`. Assignment lifecycle **Active**. No Swift yet. No capture. Capture AUTH remains Proposed / unconsumed. Next = consume AUTH before first Swift (separate implementation slice).
