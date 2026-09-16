# Assignment: KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01 — UK-005 fact-only handoff

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01",
  "record_type": "assignment",
  "title": "Produce UK-005 P-01 publication facts and D-01 final-documentation receipt",
  "lifecycle": "closed",
  "current_phase": "P-01/D-01 facts recorded for the frozen candidate; fact-only handoff closed",
  "authorization_action": "produce_uk005_p01_d01_facts",
  "updated_at": "2026-09-16T21:30:22+08:00",
  "revalidation_triggers": [
    "candidate_head_changed",
    "final_tree_changed",
    "scope_changed",
    "hosted_ci_rechecked",
    "checker_or_scope_changed",
    "publication_boundary_changed",
    "authority_revoked"
  ],
  "authorization_refs": [
    "AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01"
  ],
  "parent_refs": [
    "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001",
    "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1",
    "PD-KOS-UPGRADE-UK-005-RELEASE-EVIDENCE"
  ],
  "responsibilities": {
    "domain_owner": "Architecture and Knowledge Steward / UK-005 release-evidence owner",
    "executor": "Current Codex executor in isolated documentation branch",
    "environment_executor": "Current Codex executor for local Git/checker and read-only hosted provenance; no device or release service",
    "human_dependency": "Human Product Owner / Product Lead for scope or authority changes; Product/Release owner only for any later action outside this slice",
    "architecture_reviewer": "Not Applicable — this slice produces facts and receipts, not an architecture or implementation conclusion",
    "quality_reviewer": "Not Applicable — this slice does not issue a Quality, Performance or Release conclusion",
    "product_approver": "Human Product Owner acting as Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Closed |
| Current Phase | P-01/D-01 facts recorded for the frozen candidate; fact-only handoff closed |
| Fact binding | Candidate `07b4a434…`; Hosted CI Run [#490](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35099850845) is same-head green |
| Material non-claims | No code or UI implementation; no current-proof, Product/Quality/Release Gate, TestFlight, App Store Connect, upload, Release or external-publication action |
| Next handoff / decision | Fact-only handoff complete; hand the two receipts to the UK-005 release-evidence owner. Any later Product/Release/publication action needs a new Assignment and Authorization |
| Residuals | None within this fact-only slice; Product/Release/publication remains outside scope and separately unauthorized |

This is a new child Assignment under the accepted UK-005 release-evidence adoption.
Build 55 public-testing history remains owned by its existing Assignment; this record
does not backfill or reinterpret that history. The current `main` snapshot observed at
creation is `d5c53f2cbda85e16721b9eafae09a763f6a04471`, which includes the previously
merged UI and F-001 engineering changes. It is an input snapshot, not a P-01/D-01 pass.

## Authority

- **Assignment Authority:** Product Lead.
- **Decision Source / Date:** Human Product Owner current-session authorization on `2026-09-16 Asia/Shanghai`: create a new Assignment/Authorization that only produces UK-005 P-01/D-01 fact receipts; no Release, merge or external publication is thereby authorized.
- **Product Approver:** Human Product Owner acting as Product Lead.
- **Parent Decision:** [`PD-KOS-UPGRADE-UK-005-RELEASE-EVIDENCE`](../product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md).
- **Parent Assignment:** [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001`](kos-release-evidence-implementation-001.md) and its P1-A child [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](kos-release-evidence-implementation-001-p1.md).
- **Matching Authorization:** [`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01.md).

## Observed candidate context

| Fact | Snapshot at Assignment creation | Binding rule |
|---|---|---|
| Local `main` | `d5c53f2cbda85e16721b9eafae09a763f6a04471` | Observation only; re-freeze before a receipt |
| `origin/main` | `d5c53f2cbda85e16721b9eafae09a763f6a04471` | Observation only; must be rechecked at handoff |
| Working tree | Clean before this documentation slice | New Assignment/Authorization edits must be included in the later final-tree decision or excluded explicitly |
| Final candidate | `UNKNOWN` until the last documentation edit and candidate freeze | No SHA may be inferred from this snapshot or from a different hosted run |

## KOS v0.8.0 optional-contract selection

This new record explicitly opts in only to the contracts needed for the bounded
fact handoff:

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | No product-behavior or runtime observation is created; the receipts record delivery and documentation facts only |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment and its matching Authorization expose the current fact-only slice and the separately gated external boundary |
| P-01 publication facts | Adopted | Release-evidence handoff owns local/published/hosted heads, relation, PR state and hosted result; missing identity remains `unknown` |
| D-01 final-documentation receipt | Adopted | Final-validation owner binds final commit/tree, checker/version/scope, baseline, time, output and result after the last documentation edit |

`required` remains unauthorized. These contracts do not make the Executor, checker,
hosted CI or status mirror a Product, Quality or Release authority.

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current authorized slice | Consumed | P-01/D-01 receipts recorded for candidate `07b4a434…`; read-only provenance and local documentation checks completed | This Assignment → matching Authorization → accepted UK-005 Product Decision |
| Next independently gated slice | Not authorized | Product Gate, Quality/Release conclusion, archive/export, upload, TestFlight, App Store Connect or Release | New bounded Assignment and matching human Authorization required |
| Environment or external slice | Not authorized | Device operation, signing, external distribution, remote mutation, commit, push, PR, merge, tag or branch deletion | Separate named environment/Release authority required |

## Boundary

### Objective

Produce auditable, content-free P-01 and D-01 facts for a selected UK-005 candidate
after the current `main` changes are frozen, while keeping delivery evidence,
documentation validation and Product/Release authority separate.

### Authorized scope

1. Re-freeze the exact candidate at execution time. Record the P-01 fields required
   by [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md#publication-facts-p-01-only):
   `local_candidate`, `published_head`, `hosted_ci_head`, `hosted_ci_result`,
   derived coverage, PR state and local-ahead count.
2. Classify P-01 as `same-head`, `mismatched` or `unknown` from the recorded facts.
   A green Hosted CI result on a different SHA must remain a mismatch, not a pass.
3. After the last documentation edit of this slice, produce the D-01 fields required
   by [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md#final-documentation-receipt-d-01-only):
   final commit/tree, baseline, exact checker/version/scope, output, hosted result and
   a Pass/Fail result for this handoff only.
4. Use only content-free identifiers, statuses, digests, commands, bounded outputs and
   repository pointers. Record unavailable or not-yet-authorized facts as `unknown` or
   `not-run`; do not fill them from inference.
5. Synchronize this Assignment, its parent status mirrors and the navigation links
   after the final receipt edit. A D-01 receipt must be regenerated after any later
   Markdown/KOS change in the same handoff.

### Fact semantics

P-01 records delivery provenance. It does not perform or authorize delivery.
D-01 records final documentation validation. It does not approve the content,
the product, the build or the release.

## Non-goals

- Do not change Swift, UI, tests, the release-evidence adapter, fixture runner, Profile,
  contract, schema, evaluator, ADR 0027, App Group ownership or Main-App storage.
- Do not re-review or close F-002–F-004, Quality P1-01/P1-02, P1-B or Build 55
  TD-003/TD-004/TD-005. Build 55 items remain `open` under their existing records.
- Do not backfill or reinterpret Build 55 public-testing evidence or historical
  Assignments.
- Do not access raw keyboard text, candidate text, host text, credentials, full logs or
  unrelated user data.
- Do not run device operations, archive/export, signing, App Store Connect, TestFlight,
  Beta Review, external distribution or Release actions.
- Do not commit, push, open/modify a PR, merge, tag, delete branches or mutate remote
  state under this Authorization. Those actions require separate authority.
- Do not call a P-01/D-01 fact receipt a Product Gate, Quality Pass, Release Pass,
  current-proof or publication approval.

## Gates and required evidence

### Entry Criteria

- [x] Accepted UK-005 Product Decision already adopts P-01 and D-01 prospectively.
- [x] A new matching Assignment and Authorization are recorded; the consumed P1/F-001
  Authorizations are not reused or widened.
- [x] The scope is limited to content-free fact receipts and explicit non-claims.
- [x] Current `main`/`origin/main` identity is observed and recorded as context only.
- [x] Final candidate is frozen before the post-freeze receipts and remains commit `07b4a434…` / tree `421c313d…`.

### Exit Criteria

- [x] P-01 receipt records all required heads, Hosted CI result, relation and PR state;
  any missing or unequal identity is preserved as `unknown`/`mismatched`.
- [x] D-01 receipt records final commit/tree, baseline, checker/version/scope, output,
  time and result after the last documentation edit.
- [x] Final receipt and this Assignment contain no Product, Quality, Release or external
  publication conclusion.
- [x] Parent Assignment, Dashboard, Active Work and navigation mirrors link the final
  receipt and preserve the non-claims.

### Stop Conditions

- Candidate, final tree, hosted head, checker output or comparison basis is missing,
  stale, changed or ambiguous; stop and record the affected fact as `unknown`.
- A later Markdown/KOS edit occurs after D-01; invalidate the old receipt and rerun it.
- The requested work requires code/UI changes, a device, credentials, remote mutation,
  Product Gate, Quality decision or Release action.
- Any request attempts to use Build 55 public testing as a substitute for current
  candidate provenance or final-documentation validation.

## Handoff

- **Handoff target:** UK-005 release-evidence owner, then the named Product/Release owner
  for any later decision; this handoff conveys facts only.
- **Required handoff:** exact candidate/heads and relation; final commit/tree/checker
  receipt; commands, bounded outputs, collection time, baseline, unresolved facts and
  explicit non-claims.
- **Expected next decision:** whether a separately authorized Product/Release process
  is needed after the facts are reviewed. No such process is authorized here.

## History

- `2026-09-16T18:50:05+08:00 Asia/Shanghai`: Human Product Owner authorized this
  fact-only P-01/D-01 Assignment. At creation, `main` and `origin/main` both pointed
  to `d5c53f2c…`; no receipt was claimed and no external action was performed.
- `2026-09-16T21:23:13+08:00 Asia/Shanghai`: P-01 and D-01 receipts recorded the
  frozen candidate `07b4a434…`, same-head Hosted CI Run [#490](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35099850845),
  and final-documentation checks. The Human-authorized lifecycle sync closes this
  fact-only child; Product/Release/publication remains separately unauthorized.
