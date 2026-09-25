# Assignment: TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001 — Live narrow query_* density remediation (diagnose-first; unconsumed)

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001",
  "record_type": "assignment",
  "title": "Live AUTH: narrow typo_recall.query_begin / query_outcome density remediation (diagnose-first; unconsumed)",
  "lifecycle": "active",
  "current_phase": "Active Live AUTH (unconsumed); waiting consume + separate Human ask before diagnose/Swift; no diagnose run yet; no Swift in this Live-mark slice",
  "authorization_action": "diagnose_and_optionally_remediate_int003_query_density",
  "updated_at": "2026-09-25T14:24:06+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_1ee2728",
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
    "executor": "Grok Bot (iOS开发大师) — AUTH Live/unconsumed docs mark now; diagnose / optional emit or scheduling fixes only after AUTH consume + separate Human ask",
    "environment_executor": "Not Applicable for Simulator/Device Hub arm under this Live-unconsumed docs slice; any later Live diagnose uses existing Capture journal / code correlation only",
    "human_dependency": "Human Product Owner / Product Lead — AUTH Live marked; must separately authorize consume before diagnose/code; Live alone does not authorize diagnose; merge of this Live-mark PR is a separate ask (executor does not merge)",
    "architecture_reviewer": "Architecture & Knowledge Steward — Not Applicable for this docs-only Live-mark slice; required later if Live remediation changes emit/scheduling semantics",
    "quality_reviewer": "Independent Quality reviewer — Not Applicable for this docs-only Live-mark slice; required later after any Live remediation tip",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Active** (AUTH Live / unconsumed) |
| **Phase** | Active Live AUTH (unconsumed); waiting consume + separate Human ask before diagnose/Swift |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001.md) — **Live / unconsumed** |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** (do **not** Close) |
| **Designated tip** | `1ee2728712e67a32ff908a27befad2c537445077` (verified `origin/main` tip before #163 merge, 2026-09-25); initial Live-mark binding was `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1` after #162; Proposed historical tip `65a0a11d197616928c66f3c148193982c9935945` (#161 path) |
| **Capture AUTH** | [`AUTH-…-STALE-CANCEL-PRODUCT-CAPTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md) remains **Consumed** |
| **Markers AUTH** | [`AUTH-…-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) remains **Consumed** |
| **Assignment Authority** | Human Product Owner / Product Lead |
| **Decision Source / Date** | Human docs-only Live mark — `2026-09-23T22:10:00+08:00` Asia/Shanghai 「授权 docs-only 将 query_* remediation AUTH 标为 Live/unconsumed，开 PR，不自动合、不诊断、不改 Swift」; Human separately authorized a docs-only tip rebind to the verified current main tip on `2026-09-25` Asia/Shanghai; this does not authorize consume, diagnose, or Swift |
| **Next** | Human squash-merge this Live-mark PR after CI green (executor does **not** merge); revalidate the main-tip binding after that merge, then obtain a separate Human authorization to consume and diagnose; further continue before Swift if needed |
| **Non-claims** | AUTH is Live but **not consumed**; **no diagnose run yet**; **no Swift**; not Product Gate / QA-001 Gate; not parent Close; Capture AUTH stays Consumed; Markers AUTH stays Consumed; Live alone does **not** authorize diagnose without consume + separate ask |

## Authority

- **Case / contract:** `TC2-CASE-INT-003` / `TC2-CTR-INT-002`.
- **Disposition path:** Capture Product residual Option B — **Open remediation AUTH**, narrowed to `typo_recall.query_begin` / `query_outcome` density (not Accept conditions; not fence remediation).
- **Related package (non-authorizing as Live remediation execution authority while unconsumed):**
  - Evidence [`…-int003-stale-cancel-product-001.md`](../evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md) SHA-256 `3dde0362923fb36071c611134c6c0022ce70d20839afa2dd67894260428835b4`
  - Architecture **Pass with conditions**; Quality **Bounded Pass with conditions**
  - Product residual [`…-PRODUCT-RESIDUAL`](../product-decisions/TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md)
  - Capture AUTH [`AUTH-…-STALE-CANCEL-PRODUCT-CAPTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md) — **Consumed**
  - Markers AUTH [`AUTH-…-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) — **Consumed**
- **Does not reuse** Consumed Capture / Markers / Cadence AUTHs as Live authority for this remediation.

## Why (narrow residual)

Capture Run `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` recorded **574/574** `typo_recall.query_begin` / `query_outcome` while Product narrative (Human visual) claims post-pause-only contextual lookup. Journal density alone cannot currently support that claim without Human visual cover. This child formalizes a **diagnose-first** remediation AUTH. AUTH is now **Live / unconsumed**; a future consume + separate Human ask can distinguish **observability over-emit** vs **real lookup storms** in `TypoCorrectionRecallCoordinator`, then (only if Human continues) apply minimal emit/semantics or scheduling fixes under a separate continue.

## Scope (Live AUTH unconsumed; execute diagnose/Swift only after consume + separate Human ask)

### In scope when later consumed under separate ask (stated now; **not** authorized while unconsumed)

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
- Auto diagnose / auto Swift / merge without ask
- Changing 180 ms product budget unless root-cause proves emit correctness requires it (document if so)
- Reusing Consumed Capture AUTH as Live remediation authority
- Treating Live/unconsumed as already-consumed diagnose/Swift authority
- Diagnose or Swift from Live alone (consume + separate ask required)

## Entry Criteria (docs Proposed slice — met via #162)

1. #161 squash-merged; designated Proposed tip `65a0a11…` — **met**.
2. Human selected narrow Open remediation for `query_*` density — **met**.
3. Matching AUTH existed as **Proposed / unconsumed** — **met** via #162.
4. Parent remains **Active** — **met**.
5. No Swift / Gate / Capture under Proposed slice — **met**.

## Entry Criteria (Live-mark slice — current)

1. #162 squash-merged; the original Live-mark binding was `a9b82a58…`.
2. Human authorized the docs-only Live mark (still do not auto-merge; do not diagnose; do not change Swift).
3. Matching AUTH is **Live / unconsumed** at `2026-09-23T22:10:00+08:00`.
4. Parent remains **Active**.
5. Capture AUTH stays **Consumed**; Markers AUTH stays **Consumed**.
6. Human authorized a docs-only rebind to the verified `origin/main` tip `1ee2728712e67a32ff908a27befad2c537445077` on `2026-09-25`; this does not consume AUTH or authorize diagnosis.
7. **Active Live AUTH (unconsumed).** Diagnose still requires consuming the matching AUTH and a separate Human ask before the first non-docs remediation action.

## Exit Criteria (docs Proposed slice — met via #162)

1. Assignment + Proposed AUTH written with tip pin, exclusions, Entry/Exit, and non-claims — **met**.
2. Light cross-links from residual + parent + `ACTIVE_WORK` — **met**.
3. Explicit: **not Live**; **no Swift**; **no Gate** for that slice — **met**.

## Exit Criteria (docs Live-mark slice — current)

1. AUTH Status **Live / unconsumed**; original `live_at` retained; `consumed_at` empty; current pre-merge tip rebound to `1ee2728712e67a32ff908a27befad2c537445077`.
2. Assignment phase **Active Live AUTH (unconsumed)**; waiting consume + separate Human ask.
3. Explicit non-claims intact: not consumed; no diagnose; no Swift; no Gate; Capture/Markers stay Consumed; Live alone ≠ diagnose authority.
4. Light cross-links updated minimally; PR #163 remains unmerged and executor does **not** merge it.

## Exit Criteria (future Live diagnose / remediation — only after AUTH consume + separate continue asks)

1. AUTH consumed before first non-docs remediation action.
2. Diagnose distinguishes over-emit vs real lookup storms; root-cause evidence recorded.
3. Any code change stays minimal and in-scope; 180 ms budget untouched unless documented necessity.
4. Still no Gate / parent Close / TestFlight / Release / fence expansion / Markers reopen from this AUTH alone.

## Stop Conditions

- AUTH revoked or not Live → stop before diagnose/Swift.
- AUTH still unconsumed / no separate Human ask to diagnose → **stop** before diagnose/Swift.
- Tip drifts from `1ee2728…` without revalidation → stop and reopen.
- Request to expand to fence / Gate / parent Close / provenance restore / Markers reopen → stop.
- Attempt to treat Live/unconsumed as consumed diagnose authority or reuse Consumed Capture AUTH as Live remediation → stop.
- Request to merge this Live-mark PR without separate Human merge ask → stop (executor does not merge).

## Outcome (current)

AUTH is **Live / unconsumed**, marked at `2026-09-23T22:10:00+08:00` and initially bound to `a9b82a58…` after #162. Human authorized a docs-only rebind to current pre-merge `origin/main` tip `1ee2728712e67a32ff908a27befad2c537445077` on `2026-09-25`. Assignment lifecycle **Active**. **Not consumed.** **No diagnose run yet.** **No Swift.** Capture AUTH remains **Consumed**. Markers AUTH remains **Consumed**. Parent Active (not Closed). No Gate. Live alone does **not** authorize diagnose without consume + separate ask. After #163 merges, revalidate the new main tip before any separately authorized consume/diagnose step.
