# Assignment: TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001 — Proposed INT-003 product capture (stale cancel)

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001",
  "record_type": "assignment",
  "title": "Proposed INT-003 product capture: long composition, <180 cadence, stale cancel observation",
  "lifecycle": "ready",
  "current_phase": "Ready/Proposed — preflight docs only; waiting Human to mark matching AUTH Live before any capture",
  "authorization_action": "capture_int003_stale_cancel_product_observation_designated_simulator",
  "updated_at": "2026-09-23T11:21:00+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_4a51228",
    "observability_audit_or_gap_matrix_superseded",
    "designated_simulator_or_arm_method_changed",
    "scope_expansion_toward_implementation_or_gates",
    "AUTH_revoked_or_executor_changed",
    "parent_close_or_int003_product_gate_granted_elsewhere"
  ],
  "authorization_refs": ["AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001"],
  "parent_refs": ["TYPO-CORRECTION-002"],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md",
    "docs/evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md",
    "docs/evidence/typo-correction-002-int003-cadence-2026-09-22-003.md",
    "docs/evidence/typo-correction-002-device-hub-validation.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Grok Bot (iOS开发大师) — docs preflight now; capture only after AUTH Live",
    "environment_executor": "Grok Bot — designated Device Hub Simulator arm/capture only when AUTH Live",
    "human_dependency": "Human Product Owner / Product Lead — must mark matching AUTH Live before any Simulator/capture; visual attestation during Live capture",
    "architecture_reviewer": "Not Applicable for this Proposed preflight / capture slice — separate Architecture AUTH required after Live capture package",
    "quality_reviewer": "Not Applicable for this Proposed preflight / capture slice — separate Quality AUTH required after Live capture package",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Ready / Proposed** (not Active Live capture) |
| **Phase** | Office-hours docs-only preflight complete; **no** Simulator / capture until AUTH is Live |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md) — **Proposed / unconsumed** |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** |
| **Tip baseline (docs)** | `4a51228fc8e435d538e9a5f7342ae325502e1e66` (after #148) |
| **Assignment Authority** | Human Product Owner / Product Lead |
| **Decision Source / Date** | Docs-only preflight package for Human review — `2026-09-23 Asia/Shanghai`; Live mark is a separate Human decision |
| **Next** | Human reviews AUDIT + gap matrix + this Assignment/AUTH; marks AUTH **Live** when capture is wanted — until then stay Proposed |
| **Non-claims** | Not Live; not Product Gate; not parent Close; not cancel-marker implementation; no Run ID |

## Authority

- **Case / contract:** `TC2-CASE-INT-003` / `TC2-CTR-INT-002` ([Registry V2](../TYPO_BENCHMARK_REGISTRY_V2.md) — Pending).
- **Scenario owner:** [Device Hub Validation](../evidence/typo-correction-002-device-hub-validation.md).
- **Cadence lessons (carry forward):** [Cadence-003](../evidence/typo-correction-002-int003-cadence-2026-09-22-003.md) + [Product residual](../product-decisions/TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL.md) — same-process and rapid &lt;180 cleared for that Run only; **not** Product Gate.
- **Observability binding:** [Stale-cancel observability audit 2026-09-23](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md).
- **Gap matrix:** [Cadence-003 → Product gap matrix](../evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md).
- **Does not reuse** consumed Cadence-003 / Capture-002 capture AUTHs as Live authority.

## Environment (when Live)

| Item | Value |
|---|---|
| Designated Simulator | Device Hub iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` only |
| Arm | App Group **container** prefs (`logging_enabled`, category); high-fidelity window refreshed; dismiss/reopen keyboard |
| Journal | Dynamic `keyboard_extension-&lt;processInstanceID&gt;-…jsonl`; even-index `touch.terminal` starts for cadence math |
| Package binding | Record tip + installed identities as demanded; do **not** restore `RimeRuntimeProvenance` under this Assignment |

## Scope (Proposed; executes only after AUTH Live)

1. Long synthetic composition on designated Simulator via **visible-key** taps (no `typeText` / pasteboard / host injection / candidate select).
2. Continuous intervals with rapid inter-key **starts** &lt;180 ms, then pause ≥180 ms.
3. Observe / attempt to prove:
   - no contextual candidate while typing;
   - stale work cancelled (see observation plan — journal marker currently **missing**);
   - only the final unchanged composition receives a post-pause lookup.
4. Same-process smoke→rapid binding (Cadence-003 lesson).
5. Write a fresh Run evidence receipt under `docs/evidence/`; Architecture / Quality / Product Gate need **separate** AUTHs afterward.

## Observation plan (cites audit)

| Collect | Rule |
|---|---|
| `touch.terminal` even-index starts | Rapid slice must meet &lt;180 ms or Run is **inconclusive** for INT-003 stimulus |
| `processInstanceID` / `appearanceID` | Smoke and rapid must share one process or **inconclusive** for same-process |
| HF + dynamic JSONL growth | If absent → stop; re-arm; new Run ID |
| Human visual: contextual during typing | Attest absence; journal alone cannot strongly prove |
| Human visual: post-pause single lookup | Attest; correlate pause gap ≥180 ms |
| Cancel / query / epoch journal markers | **Expected absent** on tip `4a51228` per audit — **do not** convert absence into cancel claim |
| Stop if cancel unobservable | Produce **bounded Human+journal observation** only; do **not** self-declare Product Gate; escalate marker gap (docs-only Product condition vs future implementation AUTH) |

## Explicit non-goals

- QA-001 Product Gate
- Paired performance
- Physical device as substitute for designated Simulator
- Parent Close
- Release / TestFlight
- Swift / ObjC / RIME changes under this Assignment / AUTH
- Restoring `RimeRuntimeProvenance`
- Treating this Ready/Proposed record as Live capture authority

## Dependencies

1. Human marks matching AUTH **Live** before any Simulator / capture.
2. Office-hours / docs-only now: assignment + AUTH remain Proposed/Ready.
3. Parent TYPO-CORRECTION-002 stays Active regardless of this child’s Ready state.

## Entry Criteria

1. No required Assignment responsibility field is `UNKNOWN`.
2. Observability audit + Cadence-003→Product gap matrix exist on tip baseline `4a51228…` and do not claim Product Gate / cancel proof.
3. Matching AUTH exists as **Proposed / unconsumed** (this child’s Ready state does **not** authorize capture).
4. Parent [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active**.
5. Designated Simulator UDID and Cadence-003 arm method are recorded.
6. **Ready for docs preflight only.** Entering Active Live capture additionally requires Human marking the matching AUTH **Live**.

## Exit Criteria (docs preflight slice — current)

1. Assignment + Proposed AUTH + audit + gap matrix are written under `docs/` with tip `4a51228…`, non-claims, and Cadence-003 residual dependency without overclaiming Product Gate.
2. Explicit statement that journal cannot prove cancel on this tip remains intact.
3. No Simulator / capture / Run ID / ACTIVE_WORK Live implication under this slice.

## Exit Criteria (future Live capture slice — only after AUTH Live)

1. New Run ID on designated Simulator; tip + installed identities recorded as demanded.
2. Same-process smoke→rapid binding and rapid even-index starts &lt;180 ms (or **inconclusive** with reason).
3. Human visual attestations for contextual-while-typing and post-pause lookup (or bounded stop).
4. Fresh evidence receipt under `docs/evidence/`; cancel absence not converted into cancel claim.
5. Architecture / Quality / Product Gate remain **separate** AUTHs — not implied by capture alone.

## Stop Conditions

- AUTH still Proposed → **stop** before any Simulator / capture.
- Tip drifts from `4a51228…` without revalidation → stop and reopen.
- Rapid starts fail &lt;180 / process churn / HF-JSONL absent → **inconclusive**; new Run ID after fix.
- Cancel markers absent (expected) → do **not** claim journal-proven cancel; bounded observation only; escalate marker gap via Product disposition vs future implementation AUTH — **do not implement** under this Assignment.
- Any request for Swift / ObjC / RIME / `RimeRuntimeProvenance` restore / parent Close / Product Gate / Release → stop; needs separate AUTH.

## Required Evidence

| Slice | Evidence |
|---|---|
| Preflight (now) | [`stale-cancel observability audit`](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md); [`gap matrix`](../evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md) |
| Cadence residual (input) | [`Cadence-003`](../evidence/typo-correction-002-int003-cadence-2026-09-22-003.md); [`Product residual`](../product-decisions/TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL.md) |
| Live capture (future) | Fresh `docs/evidence/typo-correction-002-*-int003-*-….md` Run receipt — **not minted yet** |

## Handoff Target

- **Now:** Human Product Owner / Product Lead — review Proposed AUTH + audit finding (journal cannot prove cancel).
- **After Live capture:** Independent Architecture / Quality reviewers under **new** AUTHs; Product Gate only under an explicit Gate AUTH.

## Outcome (current)

Preflight package written. Assignment is **Ready/Proposed**. No Run ID. No capture. Still not Live.
