# Assignment: TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001 — Live INT-003 product capture (stale cancel; unconsumed)

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001",
  "record_type": "assignment",
  "title": "Live AUTH: INT-003 product capture — long composition, <180 cadence, stale cancel observation (unconsumed)",
  "lifecycle": "active",
  "current_phase": "Active Live AUTH (unconsumed); waiting consume + separate Human ask before any Simulator/arm/Capture; markers already on main tip c1869cf9…",
  "authorization_action": "capture_int003_stale_cancel_product_observation_designated_simulator",
  "updated_at": "2026-09-23T19:39:00+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_c1869cf",
    "observability_audit_or_gap_matrix_superseded",
    "designated_simulator_or_arm_method_changed",
    "scope_expansion_toward_implementation_or_gates",
    "AUTH_revoked_or_executor_changed",
    "parent_close_or_int003_product_gate_granted_elsewhere",
    "markers_schema_or_emit_contract_changed_without_rebind"
  ],
  "authorization_refs": ["AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001"],
  "parent_refs": ["TYPO-CORRECTION-002"],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md",
    "docs/evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md",
    "docs/evidence/typo-correction-002-int003-cadence-2026-09-22-003.md",
    "docs/evidence/typo-correction-002-device-hub-validation.md",
    "docs/evidence/typo-correction-002-int003-cancel-observability-markers-impl-2026-09-23.md",
    "docs/reviews/typo-correction-002-int003-cadence-2026-09-22-003-architecture-review.md",
    "docs/reviews/typo-correction-002-int003-cadence-2026-09-22-003-quality-review.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Grok Bot (iOS开发大师) — AUTH Live/unconsumed; Capture only after consume + separate Human ask",
    "environment_executor": "Grok Bot — designated Device Hub Simulator arm/capture only when AUTH consumed under separate Human ask",
    "human_dependency": "Human Product Owner / Product Lead — AUTH Live marked; must separately authorize consume/run before any Simulator/capture; visual attestation during Live capture",
    "architecture_reviewer": "Not Applicable for this Live-unconsumed docs / future capture slice — separate Architecture AUTH required after Live capture package",
    "quality_reviewer": "Not Applicable for this Live-unconsumed docs / future capture slice — separate Quality AUTH required after Live capture package",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Active** (AUTH Live / unconsumed) |
| **Phase** | Active Live AUTH (unconsumed); waiting consume + separate Human ask before any Simulator/arm/Capture |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md) — **Live / unconsumed** |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** (do **not** Close) |
| **Tip baseline (docs)** | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (#152 markers on main); Proposed historical tip `4a51228fc8e435d538e9a5f7342ae325502e1e66` (#148/#149 path) |
| **Markers AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) remains **Consumed** |
| **Assignment Authority** | Human Product Owner / Product Lead |
| **Decision Source / Date** | Human docs-only Live mark for Capture AUTH — `2026-09-23T19:39:00+08:00` Asia/Shanghai; still do not auto-run Capture |
| **Next** | Separate Human ask to consume AUTH, then run Capture; do **not** auto-run from Live alone |
| **Non-claims** | AUTH is Live but not consumed; Capture **not** run; not Product Gate; not parent Close; no Run ID; Markers AUTH stays Consumed; no Swift under this child |

## Authority

- **Case / contract:** `TC2-CASE-INT-003` / `TC2-CTR-INT-002` ([Registry V2](../TYPO_BENCHMARK_REGISTRY_V2.md) — Pending).
- **Scenario owner:** [Device Hub Validation](../evidence/typo-correction-002-device-hub-validation.md).
- **Cadence lessons (carry forward):** [Cadence-003](../evidence/typo-correction-002-int003-cadence-2026-09-22-003.md) + [Product residual](../product-decisions/TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL.md) — same-process and rapid &lt;180 cleared for that Run only; Architecture **Pass-with-conditions** + Quality **Bounded Pass** noted; **not** Product Gate; **not** Live authority for this Capture.
- **Observability binding:** [Stale-cancel observability audit 2026-09-23](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md).
- **Gap matrix:** [Cadence-003 → Product gap matrix](../evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md).
- **Markers on tip:** [Markers impl evidence](../evidence/typo-correction-002-int003-cancel-observability-markers-impl-2026-09-23.md) — tip `c1869cf9…`; Capture may later collect positive `typo_recall.*` cancel/debounce/epoch evidence.
- **Does not reuse** consumed Cadence-003 / Capture-002 / Markers AUTHs as Live authority for this capture.

## Environment (when Live — execute only after consume)

| Item | Value |
|---|---|
| Designated Simulator | Device Hub iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` only |
| Arm | App Group **container** prefs (`logging_enabled`, category); high-fidelity window refreshed; dismiss/reopen keyboard |
| Journal | Dynamic `keyboard_extension-&lt;processInstanceID&gt;-…jsonl`; even-index `touch.terminal` starts for cadence math |
| Package binding | Record tip + installed identities as demanded; do **not** restore `RimeRuntimeProvenance` under this Assignment |
| Markers tip | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` — positive `typo_recall.*` codes available |

## Scope (Live AUTH unconsumed; execute Capture only after consume + Human ask)

1. Long synthetic composition on designated Simulator via **visible-key** taps (no `typeText` / pasteboard / host injection / candidate select).
2. Continuous intervals with rapid inter-key **starts** &lt;180 ms, then pause ≥180 ms.
3. Observe / attempt to prove:
   - no contextual candidate while typing;
   - stale work cancelled (journal markers now present on tip — prefer positive `typo_recall.*` evidence);
   - only the final unchanged composition receives a post-pause lookup.
4. Same-process smoke→rapid binding (Cadence-003 lesson).
5. Write a fresh Run evidence receipt under `docs/evidence/`; Architecture / Quality / Product Gate need **separate** AUTHs afterward.
6. **Do not** invent new Capture procedures beyond this Assignment’s existing Live-when-consumed scope. **Do not** authorize Swift changes under this child.

## Observation plan (cites audit + markers tip)

| Collect | Rule |
|---|---|
| `touch.terminal` even-index starts | Rapid slice must meet &lt;180 ms or Run is **inconclusive** for INT-003 stimulus |
| `processInstanceID` / `appearanceID` | Smoke and rapid must share one process or **inconclusive** for same-process |
| HF + dynamic JSONL growth | If absent → stop; re-arm; new Run ID |
| Human visual: contextual during typing | Attest absence; journal alone cannot strongly prove |
| Human visual: post-pause single lookup | Attest; correlate pause gap ≥180 ms |
| Cancel / query / epoch journal markers | **Present on tip `c1869cf9…`** — may collect positive `typo_recall.debounce_*` / `epoch_bumped` / `fence_discarded` / `query_*`; still do **not** self-declare Product Gate from Capture alone |
| Post-bump epoch caveat | On invalidate: `epoch_bumped` then optional `debounce_cancelled` carry **post-bump** `recall_epoch`; correlators must not bind invalidate-path `debounce_cancelled` to the pre-bump epoch |
| Stop if stimulus/arm fails | Produce **bounded Human+journal observation** only; do **not** self-declare Product Gate |

## Explicit non-goals

- QA-001 Product Gate
- Paired performance
- Physical device as substitute for designated Simulator
- Parent Close
- Release / TestFlight
- Swift / ObjC / RIME changes under this Assignment / AUTH
- Restoring `RimeRuntimeProvenance`
- Treating Live/unconsumed as already-consumed Capture authority
- Auto-running Capture from Live alone
- Reopening or altering Consumed Markers AUTH

## Dependencies

1. Matching AUTH is **Live / unconsumed**; still **consume** before any Simulator / capture; separate Human ask required before run.
2. Markers already on main tip `c1869cf9…`; Markers AUTH stays **Consumed**.
3. Parent TYPO-CORRECTION-002 stays Active regardless of this child’s Active Live-unconsumed state.

## Entry Criteria

1. No required Assignment responsibility field is `UNKNOWN`.
2. Observability audit + Cadence-003→Product gap matrix exist and do not claim Product Gate / cancel proof from docs alone.
3. Matching AUTH exists as **Live / unconsumed** (docs Proposed entry satisfied via #149; Live mark at `2026-09-23T19:39:00+08:00`).
4. Parent [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active**.
5. Designated Simulator UDID and Cadence-003 arm method are recorded.
6. Markers tip `c1869cf9…` (or revalidated) is the Live binding tip.
7. **Active Live AUTH (unconsumed).** Entering Capture additionally requires consuming the matching AUTH and a separate Human ask before the first Simulator/arm/capture.

## Exit Criteria (docs Proposed slice — met via #149)

1. Assignment + Proposed AUTH + audit + gap matrix written under `docs/` with tip `4a51228…`, non-claims, and Cadence-003 residual dependency without overclaiming Product Gate — **met** via #149.
2. Explicit statement that journal could not prove cancel on pre-markers tip remained intact for that slice — **met**.
3. No Simulator / capture / Run ID under the Proposed slice — **met**.

## Exit Criteria (future Live capture slice — only after AUTH consume + Human ask)

1. New Run ID on designated Simulator; tip + installed identities recorded as demanded.
2. Same-process smoke→rapid binding and rapid even-index starts &lt;180 ms (or **inconclusive** with reason).
3. Human visual attestations for contextual-while-typing and post-pause lookup (or bounded stop).
4. Fresh evidence receipt under `docs/evidence/`; positive `typo_recall.*` observations preferred; correlators respect post-bump epoch caveat; Capture alone still does not imply Product Gate.
5. Architecture / Quality / Product Gate remain **separate** AUTHs — not implied by capture alone.

## Stop Conditions

- AUTH revoked or not Live → **stop** before any Simulator / capture.
- AUTH still unconsumed / no separate Human ask to run → **stop** before any Simulator / capture.
- Tip drifts from `c1869cf9…` without revalidation → stop and reopen.
- Rapid starts fail &lt;180 / process churn / HF-JSONL absent → **inconclusive**; new Run ID after fix.
- Any request for Swift / ObjC / RIME / `RimeRuntimeProvenance` restore / parent Close / Product Gate / Release → stop; needs separate AUTH.
- Attempt to reuse consumed Cadence-003 / Capture-002 / Markers AUTH as Live Capture authority → stop.

## Required Evidence

| Slice | Evidence |
|---|---|
| Preflight (historical; met via #149) | [`stale-cancel observability audit`](../evidence/typo-correction-002-int003-stale-cancel-observability-audit-2026-09-23.md); [`gap matrix`](../evidence/typo-correction-002-int003-cadence-003-to-product-gap-matrix-2026-09-23.md) |
| Cadence residual (input) | [`Cadence-003`](../evidence/typo-correction-002-int003-cadence-2026-09-22-003.md); [`Product residual`](../product-decisions/TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL.md); Arch Pass-with-conditions + Quality Bounded Pass |
| Live mark (now) | Matching AUTH **Live / unconsumed** at `2026-09-23T19:39:00+08:00`; tip baseline `c1869cf9…`; Markers AUTH Consumed |
| Markers context | [`markers impl`](../evidence/typo-correction-002-int003-cancel-observability-markers-impl-2026-09-23.md) |
| Live capture (future) | Fresh `docs/evidence/typo-correction-002-*-int003-*-….md` Run receipt — **not minted yet**; requires consume + separate Human ask |

## Handoff Target

- **Now:** AUTH is Live / unconsumed. Next is Human squash-merge of this Live-mark PR after CI green, then a **separate** Human ask before any Capture consume/run.
- **After Live capture:** Independent Architecture / Quality reviewers under **new** AUTHs; Product Gate only under an explicit Gate AUTH.

## Outcome (current)

AUTH is **Live / unconsumed** after Human authorization with tip `c1869cf9…` (markers already on main). Assignment lifecycle **Active**. Capture **not** run. Markers AUTH remains **Consumed**. Parent Active (not Closed). No Gate. Next = Human merge of Live mark, then separate ask before consume/Capture.
