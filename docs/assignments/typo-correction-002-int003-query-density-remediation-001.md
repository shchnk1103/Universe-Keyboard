# Assignment: TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001 — Proposed narrow query_* density remediation (diagnose-first)

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001",
  "record_type": "assignment",
  "title": "Proposed remediation: narrow typo_recall.query_begin / query_outcome density (diagnose-first)",
  "lifecycle": "ready",
  "current_phase": "Ready/Proposed — docs-only; Human selected Open remediation from Capture Product residual; waiting Live mark before diagnose/code; no Swift in this slice",
  "authorization_action": "diagnose_and_optionally_remediate_int003_query_density",
  "updated_at": "2026-09-23T21:49:00+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_65a0a11",
    "capture_package_or_evidence_sha_superseded",
    "scope_expansion_to_fence_or_gate_or_provenance",
    "AUTH_revoked_or_executor_changed",
    "parent_close_or_int003_product_gate_granted_elsewhere",
    "180_ms_product_budget_changed_without_emit_necessity",
    "markers_auth_reopened_or_schema_contract_changed_without_rebind"
  ],
  "authorization_refs": ["AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001"],
  "parent_refs": ["TYPO-CORRECTION-002"],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md",
    "docs/product-decisions/TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md",
    "docs/reviews/typo-correction-002-int003-stale-cancel-product-capture-2026-09-23-001-architecture-review.md",
    "docs/reviews/typo-correction-002-int003-stale-cancel-product-capture-2026-09-23-001-quality-review.md",
    "docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md",
    "docs/assignments/typo-correction-002-int003-stale-cancel-product-capture-001.md",
    "docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Grok Bot (iOS开发大师) — docs Proposed preflight now; diagnose / optional emit or scheduling fixes only after AUTH Live + consume under separate continue",
    "environment_executor": "Not Applicable for Simulator/Device Hub arm under this Proposed docs slice; any later Live diagnose uses existing Capture journal / code correlation only",
    "human_dependency": "Human Product Owner / Product Lead — selected narrow Open remediation after #161; must mark matching AUTH Live before diagnose/code; merge of this Proposed PR is a separate ask; Live mark is a further separate ask",
    "architecture_reviewer": "Architecture & Knowledge Steward — Not Applicable for this docs-only Proposed slice; required later if Live remediation changes emit/scheduling semantics",
    "quality_reviewer": "Independent Quality reviewer — Not Applicable for this docs-only Proposed slice; required later after any Live remediation tip",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Ready / Proposed** (not Active Live remediation) |
| **Phase** | Docs-only Proposed Assignment + AUTH for **narrow** `query_*` density remediation; **no** Swift / ObjC / RIME / Gate in this slice |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001.md) — **Proposed / unconsumed** |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** |
| **Designated tip** | `65a0a11d197616928c66f3c148193982c9935945` (`origin/main` after #161 squash-merge) |
| **Assignment Authority** | Human Product Owner / Product Lead |
| **Decision Source / Date** | Human after #161: merge residual then open narrow-scope `query_*` remediation Proposed AUTH — `2026-09-23 Asia/Shanghai` 「可以，那就先 merge #161，然后窄 scope 的 query_* remediation Proposed AUTH」 |
| **Next** | CI green → Human merge this Proposed docs PR → later separate ask to mark AUTH **Live** → diagnose-first (observability over-emit vs real lookup storms) |
| **Non-claims** | Not Live; no Swift; no Product Gate / QA-001 Gate; no parent Close; no TestFlight / Release; Capture AUTH stays **Consumed** (not reused as Live remediation authority); Markers AUTH stays **Consumed** (not reopened); `fence_discarded` remediation out of scope |

## Authority

- **Case / contract:** `TC2-CASE-INT-003` / `TC2-CTR-INT-002`.
- **Disposition path:** Capture Product residual Option B — **Open remediation AUTH**, narrowed to `typo_recall.query_begin` / `query_outcome` density (not Accept conditions; not fence remediation).
- **Related package (non-authorizing as Live remediation authority):**
  - Evidence [`…-int003-stale-cancel-product-001.md`](../evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md) SHA-256 `3dde0362923fb36071c611134c6c0022ce70d20839afa2dd67894260428835b4`
  - Architecture **Pass with conditions**; Quality **Bounded Pass with conditions**
  - Product residual [`…-PRODUCT-RESIDUAL`](../product-decisions/TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md)
  - Capture AUTH [`AUTH-…-STALE-CANCEL-PRODUCT-CAPTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md) — **Consumed**
  - Markers AUTH [`AUTH-…-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) — **Consumed**
- **Does not reuse** Consumed Capture / Markers / Cadence AUTHs as Live authority for this remediation.

## Why (narrow residual)

Capture Run `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` recorded **574/574** `typo_recall.query_begin` / `query_outcome` while Product narrative (Human visual) claims post-pause-only contextual lookup. Journal density alone cannot currently support that claim without Human visual cover. This child formalizes a **diagnose-first** remediation AUTH so a future Live+consumed continue can distinguish **observability over-emit** vs **real lookup storms** in `TypoCorrectionRecallCoordinator`, then (only if Human continues) apply minimal emit/semantics or scheduling fixes under a separate continue.

## Scope (Proposed; executes only after AUTH Live + consume)

### In scope when later Live+consumed (stated now; **not** authorized while Proposed)

1. **Diagnose-first (preferred):** read-only code + journal correlation against Run `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` / evidence SHA `3dde0362…`; document root-cause (over-emit vs real storms).
2. Docs evidence of root-cause under clean tip.
3. **Only if Human continues after diagnose:** minimal emit/semantics or scheduling fixes in `TypoCorrectionRecallCoordinator` (and tightly related DiagnosticEvent/marker helpers if required for emit correctness) — under separate continue-auth after Live consume; default observe-correctness first.
4. Focused unit/contract tests for any Live emit/scheduling change; docs tip evidence.

### Explicit exclusions

- Product Gate / QA-001 Gate
- Parent Close
- TestFlight / Release
- `RimeRuntimeProvenance` restore
- Expanding this AUTH to `fence_discarded` remediation (follow-on only)
- Markers AUTH reopen
- Auto Live / auto Capture / merge without ask
- Changing 180 ms product budget unless root-cause proves emit correctness requires it (document if so)
- Reusing Consumed Capture AUTH as Live remediation authority
- Swift / diagnose execution while status remains **Proposed**

## Entry Criteria (docs Proposed slice)

1. #161 squash-merged; designated tip `65a0a11…`.
2. Human selected narrow Open remediation for `query_*` density.
3. Matching AUTH exists as **Proposed / unconsumed**.
4. Parent remains **Active**.
5. No Swift / Gate / Capture under this slice.

## Exit Criteria (docs Proposed slice — current)

1. Assignment + Proposed AUTH written with tip pin, exclusions, Entry/Exit, and non-claims.
2. Light cross-links from residual + parent + `ACTIVE_WORK`.
3. Explicit: **not Live**; **no Swift**; **no Gate**.

## Exit Criteria (future Live diagnose / remediation — only after AUTH Live + consume + continue asks)

1. AUTH consumed before first non-docs remediation action.
2. Diagnose distinguishes over-emit vs real lookup storms; root-cause evidence recorded.
3. Any code change stays minimal and in-scope; 180 ms budget untouched unless documented necessity.
4. Still no Gate / parent Close / TestFlight / Release / fence expansion / Markers reopen from this AUTH alone.

## Stop Conditions

- Request to mark Live / implement Swift / merge without separate Human ask → stop.
- Request to expand to fence / Gate / parent Close / provenance restore / Markers reopen → stop.
- Attempt to treat Proposed as Live or reuse Consumed Capture AUTH as Live remediation → stop.

## Outcome (current)

Docs-only **Proposed** remediation Assignment for narrow `query_*` density. Matching AUTH **Proposed / unconsumed**. Parent Active. Capture AUTH Consumed. Markers AUTH Consumed. No Live. No Swift. No Gate.
