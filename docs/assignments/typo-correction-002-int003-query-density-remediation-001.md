# Assignment: TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001 — Live narrow query_* density remediation (diagnose-first; unconsumed)

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001",
  "record_type": "assignment",
  "title": "Live AUTH: narrow typo_recall.query_begin / query_outcome density remediation (diagnose-first; unconsumed)",
  "lifecycle": "active",
  "current_phase": "Active Live AUTH (unconsumed); PR #163 merged; post-merge M-02 status sync in progress; waiting separate Human authorization to consume and diagnose; no diagnose run or Swift",
  "authorization_action": "diagnose_and_optionally_remediate_int003_query_density",
  "updated_at": "2026-09-25T15:05:41+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_15e2be5",
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
| **Phase** | Active Live AUTH (unconsumed); PR #163 merged; M-02 status sync in progress; waiting separate Human authorization to consume and diagnose |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001.md) — **Live / unconsumed** |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** (do **not** Close) |
| **Designated tip** | `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a` (verified `main` tip after PR #163 merged, 2026-09-25); pre-merge rebind was `1ee2728712e67a32ff908a27befad2c537445077`; initial Live-mark binding was `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1` after #162; Proposed historical tip `65a0a11d197616928c66f3c148193982c9935945` (#161 path) |
| **Capture AUTH** | [`AUTH-…-STALE-CANCEL-PRODUCT-CAPTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md) remains **Consumed** |
| **Markers AUTH** | [`AUTH-…-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) remains **Consumed** |
| **Assignment Authority** | Human Product Owner / Product Lead |
| **Decision Source / Date** | Human docs-only Live mark — `2026-09-23T22:10:00+08:00` Asia/Shanghai; Human separately authorized pre-merge tip rebind and PR #163 squash merge; Human authorized this docs-only M-02 status sync after merge on `2026-09-25` Asia/Shanghai. None of these grants consume, diagnosis, or Swift authority |
| **Next** | Complete this docs-only M-02 closeout PR; then obtain separate Human authorization before consuming AUTH and performing read-only diagnosis. Any Swift change still requires a further separate continue |
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
8. PR #163 merged under separate Human authorization as `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a`; Human authorized this docs-only M-02 state sync, which revalidates the current main-tip binding without consuming AUTH or authorizing diagnosis.

## Exit Criteria (docs Proposed slice — met via #162)

1. Assignment + Proposed AUTH written with tip pin, exclusions, Entry/Exit, and non-claims — **met**.
2. Light cross-links from residual + parent + `ACTIVE_WORK` — **met**.
3. Explicit: **not Live**; **no Swift**; **no Gate** for that slice — **met**.

## Exit Criteria (docs Live-mark slice — current)

1. AUTH Status **Live / unconsumed**; original `live_at` retained; `consumed_at` empty; post-merge binding revalidated to `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a`.
2. Assignment phase **Active Live AUTH (unconsumed)**; waiting consume + separate Human ask.
3. Explicit non-claims intact: not consumed; no diagnose; no Swift; no Gate; Capture/Markers stay Consumed; Live alone ≠ diagnose authority.
4. PR #163 merged after separate Human authorization; this M-02 closeout records the merge pointer and cross-document state without closing the parent or consuming AUTH.

## M-02 merge-trigger state sync — PR #163

- **Work Item:** `TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`.
- **Exact event:** Lifecycle-changing merge of the tip PR that published the Live / unconsumed query-density AUTH state.
- **Authority record:** [`AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001.md); the AUTH remains Live / unconsumed.
- **Merged tip PR:** [#163](https://github.com/shchnk1103/Universe-Keyboard/pull/163), source head `079bc3c12e36756c96ace8bd0b26b7f94cffe4c2`, base `1ee2728712e67a32ff908a27befad2c537445077`.
- **Merge pointer:** `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a`, merged at `2026-09-25T06:54:54Z`; after fetching GitHub `main`, the merge commit was verified reachable and was the observed main tip.
- **Post-merge revalidation:** the merged diff contains only the five docs-only files from PR #163; the parent remains Active, this child remains Active, the remediation AUTH is still unconsumed, and Capture / Markers AUTH remain Consumed. The current binding is therefore `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a`.
- **Closeout boundary:** this docs-only M-02 PR records the one synchronization for this trigger. Its administrative merge will not recursively trigger M-02 for the same identity; a later independent lifecycle-changing event needs its own trigger identity.

## Exit Criteria (future Live diagnose / remediation — only after AUTH consume + separate continue asks)

1. AUTH consumed before first non-docs remediation action.
2. Diagnose distinguishes over-emit vs real lookup storms; root-cause evidence recorded.
3. Any code change stays minimal and in-scope; 180 ms budget untouched unless documented necessity.
4. Still no Gate / parent Close / TestFlight / Release / fence expansion / Markers reopen from this AUTH alone.

## Stop Conditions

- AUTH revoked or not Live → stop before diagnose/Swift.
- AUTH still unconsumed / no separate Human ask to diagnose → **stop** before diagnose/Swift.
- Tip drifts from `15e2be5…` without revalidation → stop and reopen.
- Request to expand to fence / Gate / parent Close / provenance restore / Markers reopen → stop.
- Attempt to treat Live/unconsumed as consumed diagnose authority or reuse Consumed Capture AUTH as Live remediation → stop.
- Any further PR merge without separate Human merge authorization → stop.

## Outcome (current)

AUTH is **Live / unconsumed**, marked at `2026-09-23T22:10:00+08:00` and initially bound to `a9b82a58…` after #162. The pre-merge rebind was `1ee2728712e67a32ff908a27befad2c537445077`; after PR #163 merged as `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a`, M-02 revalidated that merge tip as current main. Assignment lifecycle **Active**. **Not consumed.** **No diagnose run yet.** **No Swift.** Capture AUTH remains **Consumed**. Markers AUTH remains **Consumed**. Parent Active (not Closed). No Gate. Live alone does **not** authorize diagnose without consume + separate ask. Revalidate again if main changes before any separately authorized consume/diagnose step.
