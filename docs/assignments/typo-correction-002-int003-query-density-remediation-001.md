# Assignment: TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001 — Consumed narrow query_* density diagnosis

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001",
  "record_type": "assignment",
  "title": "Consumed AUTH: narrow typo_recall.query_begin / query_outcome density diagnosis (diagnose-first)",
  "lifecycle": "completed",
  "current_phase": "Bounded diagnose-first output complete: duplicate marker-only emission ruled out; fresh run confirms 359 real query pairs across 12 operations (26–32 per operation). Product removed the follow-up's 180 ms hard pass condition. Original rapid-window attribution remains unresolved and the wider query-density Product residual remains open; no Swift, Gate, or parent Close",
  "authorization_action": "diagnose_and_optionally_remediate_int003_query_density",
  "updated_at": "2026-09-26T10:47:54+08:00",
  "revalidation_triggers": [
    "docs_tip_changed_from_e28491a",
    "capture_package_or_evidence_sha_superseded",
    "scope_expansion_to_fence_or_gate_or_provenance",
    "AUTH_revoked_or_executor_changed",
    "parent_close_or_int003_product_gate_granted_elsewhere",
    "180_ms_product_budget_changed_without_emit_necessity",
    "markers_auth_reopened_or_schema_contract_changed_without_rebind"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001",
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSIS-DOCS-PUBLICATION-001",
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-POST-MERGE-STATE-SYNC-001"
  ],
  "parent_refs": ["TYPO-CORRECTION-002"],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-density-post-merge-state-sync-2026-09-26.md",
    "docs/product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md",
    "docs/evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md",
    "docs/evidence/typo-correction-002-int003-query-density-diagnosis-001.md",
    "docs/product-decisions/TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md",
    "docs/reviews/typo-correction-002-int003-stale-cancel-product-capture-2026-09-23-001-architecture-review.md",
    "docs/reviews/typo-correction-002-int003-stale-cancel-product-capture-2026-09-23-001-quality-review.md",
    "docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md",
    "docs/assignments/typo-correction-002-int003-stale-cancel-product-capture-001.md",
    "docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Codex current task — Human reassigned executor on 2026-09-25; Codex acknowledged the bounded Scope and dependencies. Previous executor Grok Bot (iOS开发大师) retained in Assignment history",
    "environment_executor": "Not used for the bounded source diagnosis; any fresh Simulator capture requires its own current Capture Assignment/AUTH",
    "human_dependency": "Human authorized the remaining narrow query-density work on 2026-09-25; no additional decision is pending for the partial diagnosis. Human Product Owner / Product Lead retains Product, Gate, parent-close, release, and scope-expansion decisions",
    "architecture_reviewer": "Architecture & Knowledge Steward — required if a later source remediation changes emit/scheduling semantics",
    "quality_reviewer": "Independent Quality reviewer — required for any later remediation tip review",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Completed — bounded diagnostic output; not Reviewed or Closed** (matching AUTH **Consumed**) |
| **Phase** | Source diagnosis plus a distinct diagnostic capture found 359 real query pairs in 12 operations (26–32 each); first queries began 219–260 ms after scheduling. [Product removed](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md) the follow-up's 180 ms hard pass condition. Measured manual intervals remain 285–576 ms; the original Product Capture's rapid-window attribution is unresolved. No Swift |
| **Matching AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001.md) — **Consumed at `2026-09-25T15:35:47+08:00`** |
| **Docs publication AUTH** | [`AUTH-…-DIAGNOSIS-DOCS-PUBLICATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSIS-DOCS-PUBLICATION-001.md) — separate **Consumed** docs-only publication permission; PR #175 merge was separately authorized by Human |
| **Published package** | [PR #175](https://github.com/shchnk1103/Universe-Keyboard/pull/175) squash merged as `10faa51caf20e3c558f21f26b625eff7f3aa941d`; [single M-02 receipt](../evidence/typo-correction-002-int003-query-density-post-merge-state-sync-2026-09-26.md) records the trigger. Closeout PR merge remains pending |
| **Parent** | [`TYPO-CORRECTION-002`](typo-correction-002.md) remains **Active** (do **not** Close) |
| **Designated tip** | Diagnosis binding `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c`; the capture was installed from `80091f35cc5411b292eca78662f39e2b91694045`, an ancestor whose relevant source blobs match e284. GitHub main was verified by explicit HTTPS URL; the worktree `origin` points to the protected local checkout and its stale ref was not used |
| **Capture AUTH** | [`AUTH-…-STALE-CANCEL-PRODUCT-CAPTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md) remains **Consumed** |
| **Markers AUTH** | [`AUTH-…-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) remains **Consumed** |
| **Assignment Authority** | Human Product Owner / Product Lead |
| **Decision Source / Date** | Human authorized the remaining narrow query-density work and reassigned execution to the current Codex task on `2026-09-25` Asia/Shanghai; Codex acknowledged the Scope and dependencies. The AUTH was rebound to current main tip `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c` and consumed before diagnosis. No Gate / parent-close / TestFlight / Release / ADR Accept authority |
| **Next** | Keep the parent Active. Product must separately dispose of the wider query-density residual before any Gate claim. No source fix is justified by this run alone; a new rapid-behavior claim needs qualifying evidence under a distinct plan/AUTH |
| **Non-claims** | `query_*` markers are not duplicate writes, but the scheduler-level cause is unresolved; raw JSONL was not available for rehash; **no Swift change**; not Product Gate / QA-001 Gate; not parent Close; Capture AUTH and Markers AUTH remain Consumed; no fence expansion |

> **2026-09-26 criterion supersession:** The follow-up diagnosis no longer has a 180 ms hard pass condition. Historical entry/exit text below describes the original AUTH; it does not reopen the prepared rapid run or change the runtime debounce budget. See the [Product decision](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md).

### Executor reassignment — 2026-09-25

- **Previous executor:** Grok Bot (iOS开发大师), as recorded in the prior Assignment envelope.
- **Current executor:** Codex in this task. Human Product Owner / Product Lead authorized Codex to perform the remaining work on 2026-09-25 Asia/Shanghai; Codex acknowledged the Scope, dependencies, and Stop Conditions before resuming.
- **Remaining work:** complete operation-level correlation using the evidence-bound raw journal or a distinct Capture AUTH, then determine whether the observed real query calls violate the intended post-pause schedule. Any source fix must stay within the narrow query-density touch zones. Parent Close, Gate, TestFlight/Release, ADR Accept, fence expansion, and provenance restoration remain excluded.

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

Capture Run `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` reports **574/574** `typo_recall.query_begin` / `query_outcome`, including **16/16** during the reported rapid window. The original evidence report's SHA-256 was reverified, but its raw journal remains unavailable on this host. On the exact capture install source, each `query_begin` immediately precedes a candidate-query facade call and each `query_outcome` follows the driver's fence classification; duplicate marker emission does not explain the density. Counts are per hypothesis query, not per debounce operation. A distinct follow-up run on source tip `4ef275b…` recorded 359 paired query calls across 12 operations, with 26–32 calls per operation; the user's fastest repeatable manual input remained above the 180 ms threshold. This supports per-operation hypothesis fan-out as a density factor, but does not correlate the earlier 16 rapid-window pairs. The diagnosis is recorded in [`typo-correction-002-int003-query-density-diagnosis-001.md`](../evidence/typo-correction-002-int003-query-density-diagnosis-001.md). No source change is claimed.

## Scope (Consumed AUTH; bounded query-density diagnosis)

### Current authorized scope

1. Read-only code/journal correlation against Run `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` / evidence SHA `3dde0362…`; distinguish marker over-emission from candidate-query calls.
2. Docs evidence of findings under the clean, verified source tip.
3. The Human's 2026-09-25 continuation authorization covers the remaining narrow query-density work. Any source change must remain minimal and within `TypoCorrectionRecallCoordinator` (and tightly related marker helpers only if needed for emit correctness); do not change the 180 ms budget without evidence.
4. Any fresh Simulator capture requires a distinct current Capture Assignment/AUTH; the Consumed Product Capture AUTH is not reusable.

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

## Entry Criteria (Live-mark slice — historical; superseded after consume)

1. #162 squash-merged; the original Live-mark binding was `a9b82a58…`.
2. Human authorized the docs-only Live mark (still do not auto-merge; do not diagnose; do not change Swift).
3. Matching AUTH is **Live / unconsumed** at `2026-09-23T22:10:00+08:00`.
4. Parent remains **Active**.
5. Capture AUTH stays **Consumed**; Markers AUTH stays **Consumed**.
6. Human authorized a docs-only rebind to `1ee2728712e67a32ff908a27befad2c537445077` before PR #163; historical only.
7. PR #163 merged as `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a`; the M-02 closeout PR #173 merged as `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c`.
8. On 2026-09-25 Human authorized the remaining scoped work and reassigned execution to Codex; Codex acknowledged.
9. AUTH was rebound to verified current main tip `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c` and consumed at `2026-09-25T15:35:47+08:00` before diagnosis.

## Exit Criteria (docs Proposed slice — met via #162)

1. Assignment + Proposed AUTH written with tip pin, exclusions, Entry/Exit, and non-claims — **met**.
2. Light cross-links from residual + parent + `ACTIVE_WORK` — **met**.
3. Explicit: **not Live**; **no Swift**; **no Gate** for that slice — **met**.

## Exit Criteria (docs Live-mark slice — historical; superseded after consume)

1. AUTH was Live / unconsumed with original `live_at` retained; the later consume is recorded below.
2. PR #163 and M-02 closeout PR #173 merge pointers are recorded; parent remains Active.
3. This historical slice made no diagnosis, Swift, Gate, or parent-close claim.

## M-02 merge-trigger state sync — PR #163

- **Work Item:** `TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`.
- **Exact event:** Lifecycle-changing merge of the tip PR that published the Live / unconsumed query-density AUTH state.
- **Authority record at merge:** [`AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001.md) was Live / unconsumed at this historical trigger; it was consumed later on `2026-09-25` under Human continuation authorization.
- **Merged tip PR:** [#163](https://github.com/shchnk1103/Universe-Keyboard/pull/163), source head `079bc3c12e36756c96ace8bd0b26b7f94cffe4c2`, base `1ee2728712e67a32ff908a27befad2c537445077`.
- **Merge pointer:** `15e2be5ef3ebdef2b07ac6ec2429a1fe8cd9436a`, merged at `2026-09-25T06:54:54Z`; after fetching GitHub `main`, the merge commit was verified reachable and was the observed main tip.
- **M-02 closeout pointer:** PR [#173](https://github.com/shchnk1103/Universe-Keyboard/pull/173) merged as `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c` at `2026-09-25T07:28:01Z`; it completes the one synchronization for the #163 trigger and does not recursively trigger another M-02.
- **Post-closeout revalidation and consume:** after fetching GitHub `main`, `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c` was verified as current main. Human reassigned this bounded work to Codex and authorized continuation; the AUTH was rebound to this tip and consumed at `2026-09-25T15:35:47+08:00`. Parent remains Active; Capture / Markers AUTH remain Consumed.
- **Closeout boundary:** this docs-only M-02 PR records the one synchronization for this trigger. Its administrative merge will not recursively trigger M-02 for the same identity; a later independent lifecycle-changing event needs its own trigger identity.

## Diagnosis / remediation exit criteria (current authorized path)

1. Correlate each observed query pair with its operation token and timing using the raw journal bound by SHA-256, or a new run under a distinct Capture AUTH.
2. Determine whether the 16 rapid-window calls are multiple hypothesis queries in an operation or additional operations crossing the intended 180 ms debounce.
3. If a source fix is indicated, keep it minimal and within the AUTH touch zones; preserve the 180 ms budget unless evidence proves a correctness need.
4. No Gate / parent Close / TestFlight / Release / fence expansion / Markers reopen.

## Stop Conditions

- AUTH revoked or current Human authorization withdrawn → stop before further work.
- Main tip differs from the bound diagnostic source `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c` before diagnosis begins → stop and revalidate.
- Request to expand to fence / Gate / parent Close / provenance restore / Markers reopen → stop.
- Attempt to treat Live/unconsumed as consumed diagnose authority or reuse Consumed Capture AUTH as Live remediation → stop.
- Any further PR merge without separate Human merge authorization → stop.

## Outcome (current)

The remediation AUTH is **Consumed** at `2026-09-25T15:35:47+08:00`, after revalidation to GitHub main tip `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c` and Human reassignment/continuation authorization. The separate diagnostic Capture AUTH is **Consumed** at `2026-09-25T16:06:56+08:00` and its run is complete. The paired query markers are real facade calls; the new run shows 26–32 queries per operation after the debounce delay. The original rapid-window cause remains **unresolved** because the original raw journal is unavailable and the follow-up did not reach `<180 ms`. No Swift change. Capture AUTHs and Markers AUTH remain **Consumed**; parent remains **Active**; no Gate. Any fresh capture requires a distinct Capture AUTH.
