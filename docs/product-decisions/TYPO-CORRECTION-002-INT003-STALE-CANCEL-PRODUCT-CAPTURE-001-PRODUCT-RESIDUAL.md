# Product Decision: TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001 — residual disposition

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-RESIDUAL",
  "record_type": "decision",
  "title": "INT-003 Capture residual disposition — narrow query_* investigation completed, Product residual open",
  "status": "remediate_path_selected_diagnosis_completed_residual_open",
  "updated_at": "2026-09-26T10:37:24+08:00",
  "revalidation_triggers": [
    "human_chooses_accept_or_remediate",
    "new_int003_run_requested",
    "package_or_provenance_changed",
    "scope_changed",
    "parent_close_requested",
    "third_runtime_rereview_requested",
    "gate_auth_requested"
  ],
  "decision": {
    "authority_role": "Human Product Owner / Product Lead",
    "decision_source": "Human 2026-09-23 Asia/Shanghai chose Option B narrow query_* remediation; Human 2026-09-25 authorized the bounded diagnosis; Human 2026-09-26 removed the 180 ms hard pass condition for that follow-up only",
    "scope": "Original Product Capture query_* residual. The narrow source/journal diagnosis is completed; the wider Product residual has not been accepted or gated",
    "outcome": "Narrow diagnosis rules out duplicate marker-only emission and shows 26–32 real candidate-query calls per operation in the fresh run. The original rapid-window operation attribution remains unresolved. The follow-up's 180 ms hard pass condition is removed; original Capture facts and runtime debounce remain unchanged. Product residual stays open; no Swift, fence remediation, Gate, or parent Close",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **`Remediate path selected; diagnosis completed; wider residual open`** — Human chose Option B (narrow `query_*`); Accept **not** chosen |
| Target | `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` |
| Evidence state | Same-process smoke→rapid; rapid consecutive &lt;180 (15/15); positive debounce cancel/reschedule; Human visual both Pass; Architecture Pass with conditions; Quality Bounded Pass with conditions |
| Main tip after #162 | `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1` (Proposed historical `65a0a11…` after #161) |
| Remediation AUTH | [`AUTH-…-QUERY-DENSITY-REMEDIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001.md) — **Consumed** at `2026-09-25T15:35:47+08:00` after binding to `e28491a…`; the follow-up Capture AUTHs are also Consumed |
| Remediation Assignment | [`…-query-density-remediation-001`](../assignments/typo-correction-002-int003-query-density-remediation-001.md) |
| Parent | `TYPO-CORRECTION-002` remains **Active** |
| Non-claims | Not INT-003 Product Gate, Quality Gate, Release Gate, parent Close, Swift, TestFlight, Release; Live AUTH ≠ consumed diagnose authority; Capture AUTH stays Consumed; Markers AUTH stays Consumed |
| Next | [Bounded diagnosis](../evidence/typo-correction-002-int003-query-density-diagnosis-001.md) rules out duplicate marker-only writes; [Product removed](TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md) the 180 ms hard pass bar for the follow-up only. Wider query-density residual and old rapid-window attribution remain open for separate Product disposition; no Gate |

> **Current-state supersession:** The package-binding table and Option B history below retain the 2026-09-23 to 2026-09-25 Live/unconsumed sequence. Those are historical facts, not present authorization. The current AUTH state is Consumed, and this Product decision has not accepted the wider residual.

## History — original Capture disposition and AUTH activation

## Package binding

| Item | Bound value |
|---|---|
| Capture AUTH | `AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001` (**Consumed**) |
| Markers AUTH | `AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001` (**Consumed** — not reopened) |
| Run ID | `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` |
| Evidence | [`typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md`](../evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md) |
| Evidence SHA-256 | `3dde0362923fb36071c611134c6c0022ce70d20839afa2dd67894260428835b4` |
| Architecture | [`…-001-architecture-review.md`](../reviews/typo-correction-002-int003-stale-cancel-product-capture-2026-09-23-001-architecture-review.md) — **Pass with conditions** |
| Architecture SHA-256 | `50fba2bc918c26a39a86419ef15a444e4fd28105629cdfcbcba85a18d85b13a4` |
| Quality | [`…-001-quality-review.md`](../reviews/typo-correction-002-int003-stale-cancel-product-capture-2026-09-23-001-quality-review.md) — **Bounded Pass with conditions** |
| Quality SHA-256 | `bf54b8745091d24dd1af66136960c20356391a9c2a21098dfbe99d076c3495ac` |
| Capture install tip | `80091f35cc5411b292eca78662f39e2b91694045` |
| Markers impl tip | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (#152) |
| Evidence on main | PR #157 → `b9b5f3b565b06845297cd2fdfbb5c4454bd83ba4` |
| Architecture on main | PR #158 → `f555670f574c2eb19ffff16d93cf676b4beecebb` |
| Quality on main | PR #159 → `73de0d4481051d9706c76a552ba73e23186f3846` |
| Simulator | iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| processInstanceID / appearanceID | `583B3AB8-86FE-4480-BD1D-5EEF9F1BB1E2` / `320926C3-3992-473E-A75C-739BF054334B` |
| Journal SHA-256 (evidence-bound) | `a9af14932b1a0b78595c26966a6dd16fe4ba2aa654a91ec760f86fa12bda64cc` |
| Parent Assignment | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) |
| Capture child | [`TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001`](../assignments/typo-correction-002-int003-stale-cancel-product-capture-001.md) |
| Analogue | [`TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL`](TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL.md) (Accepted Cadence residual — different decision state) |

Capture ≠ Gate. Markers AUTH Consumed. This docs residual does **not** invent a Gate AUTH.

## What was proven / observed (this Run)

| Claim slice | Disposition |
|---|---|
| Same-process smoke→rapid | **Pass** — single `processInstanceID` / `appearanceID` |
| Rapid consecutive &lt;180 ms | **Pass** — 15/15 consecutive; even-index 6/7 (one ~200.27 ms); odd-index 7/7 |
| Debounce cancel/reschedule (positive journal) | **Pass** — `debounce_cancelled` 26 / `debounce_scheduled` 27 (rapid window 8/8) |
| Human visual both attestations | **Pass** — no contextual typo-correction candidates while typing; post-pause lookup/refresh only against final composition |
| Overall observation package | **Bounded / Pass-with-conditions** (Capture ≠ Gate) |

## Open residuals / conditions

| Residual | Status | Honest boundary |
|---|---|---|
| `fence_discarded=0` | Open / recorded boundary | Cancel observed via debounce cancel/reschedule path, **not** fence discard; not cancel failure |
| High `query_*` 574/574 | Open / Architecture+Quality residual | Journal alone ≠ post-pause-only proof; Human visual covers the Product-facing narrative |
| Same-lineage reviewer residual | Accept-with-condition class | Capture + Architecture + Quality share same agent lineage; not third-runtime independence |
| Raw JSONL not re-hashed on review hosts | Accept-with-condition class | Evidence file hash + evidence-bound journal SHA used; designated Simulator App Group path unavailable on review hosts |

## Disposition options considered (Human selected Option B)

Option B (narrow `query_*`) is **selected**. Option A remains documented for contrast only and is **not** the active disposition.

### Option A — Accept conditions

**Meaning if Human later chooses Accept:**

| Area | Impact |
|---|---|
| Child Assignment close / accounting | Capture child may be marked **Reviewed / Closed for observation accounting** under a **separate** Accept residual AUTH (not this draft). Bound residuals stay visible as accepted conditions. |
| Parent `TYPO-CORRECTION-002` | Remains **Active**. Accept does **not** Close the parent. |
| Gate eligibility | Still **not** Gate. INT-003 Product Gate / QA-001 Gate remain **ineligible** until a separate Gate AUTH exists and remaining Gate scope is satisfied. |
| Risk accepted | Product explicitly accepts: debounce-path cancel proof without fence coverage this Run; dense `query_*` as journal residual with Human visual as narrative cover; same-lineage review independence; evidence-bound journal identity without host re-hash. |
| Implementation / recapture | No remediation AUTH, no required same-hypothesis recapture, no Swift under Accept alone. |
| Cadence analogue | Similar shape to Cadence-003 residual Accept: clears named residuals **for this Run** without inventing Product Gate. |

Accept conditions ≠ Product Pass. It is bounded evidence disposition only.

### Option B — Open remediation AUTH — **SELECTED (narrow)**

**Human chose this path after #161** — formalized via #162 as narrow AUTH [`AUTH-…-QUERY-DENSITY-REMEDIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001.md). It was marked **Live / unconsumed** at `2026-09-23T22:10:00+08:00` on then-current tip `a9b82a58…`; the pre-merge rebind was `1ee2728712e67a32ff908a27befad2c537445077`, and M-02 revalidated the post-merge tip `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a`. Scope remains locked to `query_*` density diagnose-first; `fence_discarded` is out-of-scope. Accept (Option A) was **not** chosen. **Not consumed.** Live alone does **not** authorize diagnose without consume + separate ask.

**Meaning of Open remediation (narrow `query_*`):**

| Area | Impact |
|---|---|
| What it blocks | Blocks treating this Capture package as residual-closed / Gate-ready accounting. Child stays open for remediation follow-through. Parent stays Active. |
| Likely remediation scopes (illustrative — new AUTH must pin exact scope) | (1) `query_*` trigger density / observability semantics so journal can support post-pause-only claims without relying only on Human visual; (2) fence-path coverage / correlator guidance when `fence_discarded` is expected; (3) tests or harnesses that assert cancel/reschedule vs fence vs query density; (4) optional third-runtime Arch/Quality re-read if independence is elevated before Gate. |
| What new evidence is needed | Fresh Authorization + Assignment for the chosen remediation scope; if behavior/observability changes, a new Run ID and evidence package; Architecture/Quality on the remediation package; then a **new** Product residual (or Gate AUTH) — do not reuse Capture / Markers / Cadence AUTHs as Live. |
| Gate / Close | Still **not** granted by opening remediation. Remediation may be a prerequisite Human sets before any Gate AUTH. |
| Risk posture | Explicitly declines Accept; keeps residuals as blocking for child residual-close until remediation evidence lands. |

Opening remediation AUTH does **not** itself implement Swift, recapture, Gate, TestFlight, or Release.

## Explicit non-claims (this docs residual)

This document does **not**:

- grant INT-003 Product Gate, Quality Gate, or Release Gate;
- Close parent `TYPO-CORRECTION-002` or auto-Close the Capture child;
- authorize Swift / ObjC / RIME / `RimeRuntimeProvenance` restore;
- authorize TestFlight or Release;
- itself serve as the authority that marked the remediation AUTH Live; the separate Human-authorized Live mark is recorded in the AUTH and Assignment;
- invent a Gate AUTH or consume a Product residual Accept AUTH;
- reopen Markers AUTH;
- convert Capture disposition into Gate.

## Product boundary

Docs-only status synchronization after #159–#162: bind the observation package and record Human-selected Option B plus its separate Live/unconsumed AUTH state. Runtime, architecture, and product contracts are unchanged by this record. Other Active children (runtime hardening, QA-001, paired performance, etc.) keep their own evidence requirements and must not be inferred from this residual.

## Limits and revalidation

Disposition path is **Open remediation (narrow `query_*`)** via AUTH now **Live / unconsumed** and bound to verified post-merge main tip `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a`. Revalidate on any later main-tip change, consume/diagnose outcome, new INT-003 Run, package/schema/provenance change, contradictory evidence, expanded scope (e.g. fence follow-on), third-runtime re-review request, Gate AUTH request, or parent Close request. No ADR or CHANGELOG update is required for this docs-only M-02 synchronization.
