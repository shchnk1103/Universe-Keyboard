# Assignment: KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 — Prospective release-evidence adopter

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001",
  "record_type": "assignment",
  "title": "Implement the prospective kos.release-evidence adopter boundary",
  "lifecycle": "closed",
  "current_phase": "Engineering/KOS implementation and P-01/D-01 fact-handoff scope closed; Product/Release remains a separate authorization boundary; P1-B Option A disposition recorded",
  "authorization_action": "implement_release_evidence_adopter",
  "updated_at": "2026-09-16T22:37:06+08:00",
  "revalidation_triggers": [
    "upstream_candidate_changed",
    "hosted_provenance_rechecked",
    "scope_changed",
    "required_mode_requested",
    "rep_q_01_finalized",
    "publication_boundary_changed",
    "privacy_owner_changed"
  ],
  "authorization_refs": ["AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001"],
  "parent_refs": ["PD-KOS-UPGRADE-UK-005-RELEASE-EVIDENCE"],
  "responsibilities": {
    "domain_owner": "Architecture and Knowledge Steward",
    "executor": "Current Codex executor in isolated worktree",
    "environment_executor": "Current Codex executor for local read-only document and contract checks; no device or release environment",
    "human_dependency": "Human Product Owner for any later scope change; Product/Release owner for any later publication handoff",
    "architecture_reviewer": "Independent Architecture reviewer, fresh runtime to be bound before implementation-stage exit",
    "quality_reviewer": "Independent Quality, Performance and Release reviewer, fresh runtime to be bound before implementation-stage exit",
    "product_approver": "Human Product Owner"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Closed |
| Current Phase | Parent P0、P1-A implementation/reviews/provenance、F-001 engineering merge 与 P-01/D-01 fact-only handoff均已闭合；P1-B Option A 已处置。 |
| Material non-claims | No historical migration; no Keyboard Extension hot-path I/O; no runtime network; no duplicate Main-App Diagnostics UI/storage change; no Product/Release Gate、current-proof、tag 或 Release conclusion。 |
| Next handoff / decision | 本 Parent Assignment 无下一动作；任何 Product/Release/publication action 都需要新的 bounded Assignment 与匹配 Human Authorization。 |
| Residuals | [`UK-005 Close receipt`](../evidence/kos-release-evidence-implementation-001-close-2026-09-16.md)；P1-B duplicate UI/storage `Not applicable`，migration/backfill 与 background sync/network `Deferred`/unauthorized。 |

The P-01/D-01 fact-only handoff is tracked by the [child Assignment](kos-release-evidence-implementation-001-p01-d01.md),
which is now Closed. Its receipts remain candidate-bound facts and do not authorize
Product/Release/publication action.

## Authority

- Assignment Authority: Product Lead.
- Decision Source / Date: [`PD-KOS-UPGRADE-UK-005-RELEASE-EVIDENCE`](../product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md), `2026-09-14T17:23:45+08:00`.
- Product Approver: Human Product Owner.

## Boundary

### Scope

1. Create the project-owned adopter Profile and owner map for the exact
   `kos.release-evidence` candidate accepted by the Product Decision.
2. Map candidate/artifact/input/context identity, observation/claim coverage,
   freshness/comparison, delivery facts, final validation and promotion history to
   one existing Universe owner each; do not create a competing Source of Truth.
3. Preserve daily Beta → external-candidate reuse as exact current proof only when
   identity, freshness, coverage and comparison bindings pass; otherwise retain
   `comparator`, `pending` or `none`.
4. Define the first/subsequent external baseline and previous-receipt requirements,
   content-free field allowlist, privacy exclusions and Main-App ownership.
5. Prepare the later implementation-stage evidence contract, including final-tree,
   local/published/hosted head, checker and output bindings needed to close `REP-Q-01`.

### Current authorized stage: P0

This turn is limited to the contract/Profile/owner-map handoff and its documentation
checks. It does not edit Swift, Main App storage, Keyboard Extension code, CI workflows,
App Group behavior, archive/export state or release services. A later P1 implementation
stage must preserve the P0 contract and obtain fresh independent Architecture/Quality
review before claiming implementation readiness.

### Stage dependencies

| Stage | Authorized output | Entry | Stop boundary |
|---|---|---|---|
| P0 contract/Profile handoff | Project adopter Profile, field-level owner map, field allowlist, derived-state matrix and implementation plan | Product Decision accepted; exact candidate/packet pins available; every owner role is named and any unresolved source identity is explicitly retained as `REP-Q-01` | Stop if a field would duplicate an existing authority, contain user content or require Extension I/O/network |
| P1 implementation | Adapter/profile integration and contract tests for new records only | P0 review Pass; implementation diff and test scope frozen; fresh reviewer runtimes bound | Stop before runtime/publication if `REP-Q-01`, final SHA/base-head or required evidence is unknown |
| P2 publication handoff | P-01/D-01 receipt with final-tree and hosted-CI facts | P1 review Pass; final artifact and hosted provenance available; Product/Release action separately authorized | No automatic upload, merge, TestFlight, App Store Connect or Release |

## Non-goals

- No change to `v0.8.0` pin, KOS 2.0 constitution, KOS 2.1 operations or `required` mode.
- No migration/backfill of existing Active Assignments or historical release evidence.
- No raw keyboard text, candidate text, host text, credentials, full logs or unrelated
  user data in the adopter record.
- No synchronous Keyboard Extension file I/O, runtime network dependency or new App
  Group ownership boundary.
- No Product Gate, Quality Gate, Release Pass, commit, push, merge, tag or external
  publication authorization.

## Required Inputs

- [`KOS-UPGRADE-UK-005` review packet](kos-upgrade-uk-005-release-evidence-v1.md) and
  its exact packet digest `18eb208bec1bd4ee29968bc9bf1989000ceea51c50848a5f74da47ee2eeb9d3a`.
- [`UK-005 preparation receipt`](../evidence/kos-upgrade-uk-005-release-evidence-v1-preparation-2026-09-14.md).
- Independent [Architecture re-review](../reviews/KOS-UPGRADE-UK-005-release-evidence-v1-architecture-rereview-2026-09-14.md)
  and [Quality re-review](../reviews/KOS-UPGRADE-UK-005-release-evidence-v1-quality-rereview-2026-09-14.md).
- [`UPGRADE_STATUS`](../kos/UPGRADE_STATUS.md), `.kos/project.json`,
  [`ASSIGNMENT_POLICY`](../ASSIGNMENT_POLICY.md), [`RELEASE_CHECKLIST`](../RELEASE_CHECKLIST.md),
  [`PRIVACY_POLICY`](../PRIVACY_POLICY.md), [`PERFORMANCE_BASELINE`](../PERFORMANCE_BASELINE.md)
  and ADR 0027.
- KOS Kit candidate source map and contract semantics recorded in the Product Decision;
  the local KOS Kit mirror remains the reproduction source until a later revalidation.
- Current P0 adopter Profile: [`release-evidence-profile.md`](../kos/release-evidence-profile.md).
- The current Universe release-evidence implementation input in the main worktree,
  including `RELEASE-EVIDENCE-PROMOTION-001` and Proposed ADR 0035; these remain
  uncommitted and are not inferred to have a final SHA. This is an explicit pre-freeze
  source boundary, not current-proof provenance; `REP-Q-01` must bind its stable identity
  before P1/P2 can claim final candidate facts.

## KOS v0.8.0 optional-contract selection

This Assignment explicitly opts into the following advisory contracts for new
release-evidence records and handoffs only:

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Adopted | Project adopter Profile owns content-free observation/coverage mapping; existing evidence owner remains authoritative |
| P-01 publication facts | Adopted | Release handoff owns local/published/hosted heads, relation and hosted result; unknown is fail-closed |
| D-01 final-documentation receipt | Adopted | Final validation owner binds final tree, checker/version/scope, baseline, time, result and output |
| A-01 / B-01 authorization chain and briefing | Not applicable in P0/P1 | External publication, merge and Release actions require separate human authorization records |

`required` remains unauthorized. This opt-in does not convert the Product Decision,
validator, reviewer or Main-App status page into a Product/Quality/Release authority.

## Gates

### Entry Criteria

- [x] Product Decision records `Adopted` for the exact candidate and prospective scope.
- [x] Current `v0.8.0` pin, advisory mode and no-migration boundary are identified.
- [x] Architecture and Quality re-reviews pass for the exact UK-005 packet digest.
- [x] P0 scope excludes Swift/runtime/publication actions and names all owners.
- [x] `REP-Q-01` and hosted provenance are visible as blockers for later publication readiness.

### P0 Exit Criteria

- [x] Project adopter Profile path and field schema are written and linked:
      [`release-evidence-profile.md`](../kos/release-evidence-profile.md).
- [x] Each portable field has exactly one project owner and every forbidden field is listed.
- [x] Daily Beta reuse, freshness, comparator/pending/none and first/subsequent history rules
      are represented in the adopter Profile; executable fixtures remain a P1 implementation
      input and no second evidence authority is introduced.
- [x] Independent Architecture and Quality reviewers Pass the P0 contract/profile handoff
      for the exact frozen package digest.
- [x] Local document/KOS validation receipt records exact commands, as-of time and non-claims.

### Full Assignment Exit Criteria

- [x] P1-A implementation has focused contract tests and no observed hot-path/network/privacy regression; the exact package passed fresh Architecture and Quality/Release review.
- [x] `REP-Q-01` is closed with the final Main-App source-owner identity, UK-005 package SHA, actual base/head pairs and same-head hosted-CI provenance in the [P1-A closure receipt](../evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md).
- [x] P-01/D-01 receipts bind the final candidate, artifact/context, checker scope and output; the fact-only child is closed with candidate-bound Hosted CI facts.
- [ ] Human Product/Release authority separately authorizes any publication action.

## Stop Conditions

- Any owner, candidate identity, baseline, history key, final SHA or provenance becomes unknown.
- The implementation would duplicate the existing release-evidence Source of Truth or move
  persistence into the Keyboard Extension hot path.
- A proposed record would contain raw user text, credentials, full logs or runtime network state.
- A comparator, pending or unknown result is promoted to current proof.
- A reviewer runtime, required evidence or separate Product/Release authority is missing.

## Handoff

- Handoff Target: independent Architecture reviewer → independent Quality reviewer → Human Product Owner / Release owner for any later publication action.
- Required Handoff Content: exact candidate pins, adopter Profile, owner map, allowlist, derived-state matrix, P0/P1 test scope, `REP-Q-01` status, final-tree/provenance facts and explicit non-claims.
- Revalidation Trigger: any upstream candidate/tag/Release change, contract/schema/evaluator digest change, Profile or privacy scope change, `REP-Q-01` finalization, `required` request or publication-scope expansion.

## History

- `2026-09-14T17:23:45+08:00`: Human Product Owner chose `Adopted` for the exact
  `kos.release-evidence` candidate. The current v0.8.0 pin remains unchanged; this
  Assignment begins the prospective new-record implementation handoff only.
- `2026-09-14T17:23:45+08:00`: P0 was bounded to Profile/owner-map documentation and
  local checks. Swift, runtime, device, hosted CI, archive/export, App Store Connect,
  TestFlight, commit and push actions remain outside this turn.
- `2026-09-14T17:50:33+08:00`: The first P0 Architecture/Quality review requested
  changes. The Profile now separates canonical field owners from producer/reviewer/
  Human authority, matches the pinned evaluator's invalid/pending/none/comparator
  semantics, makes daily-Beta-to-external first/subsequent rules executable, records
  exact P-01/D-01 conditions and defines bounded pointer lifecycle. A fresh independent
  review is required before P0 exit; no implementation or publication action started.
- `2026-09-14T18:02:00+08:00`: The fresh Architecture/Quality re-review reduced the
  open work to leaf-exact ownership/source binding, evaluator precedence evidence and
  pointer grammar. The Profile now enumerates portable leaves, defines source IDs and
  explicit pre-freeze `REP-Q-01` boundaries, and records the deterministic precedence
  matrix. A final fresh review is required; P1 fixtures and runtime work remain closed.
- `2026-09-14T18:41:22+08:00`: Architecture spot-check identified the final leaf-level
  distinction: `contract_version.major`/`minor` are now separate rows and derived
  evaluator output is explicitly outside the portable Envelope owner map. Quality had
  already passed the preceding digest; a fresh two-lane review is required for this
  revised digest before P0 closure.
- `2026-09-14T18:48:58+08:00`: Architecture closure review found the nested
  `target_binding`, `baseline` and `previous_target_receipt` contract-version objects
  also needed leaf rows. Those `major`/`minor` rows are now explicit; no implementation
  or publication scope changed.
- `2026-09-14T18:57:13+08:00`: Fresh independent Architecture and Quality closure
  reviews both passed the exact P0 digest `d0281b01b18315c4f6d7b4110335e9638010a74d127cb0f155b09b70cc9e2e5d`
  with P0/P1/P2/P3 `0/0/0/0`. P0 is now complete; P1 implementation remains outside
  this authorization and awaits a separate scope decision.
- `2026-09-14T19:13:06+08:00`: Human Product Owner approved the separate child
  P1-A scope and Authorization. P1-A covers the new-record adapter, existing
  Main-App source binding, pinned fixtures, delta-aware focused validation and the
  independent review receipt. The later P1-B Product Decision records that duplicate
  Main-App Diagnostics UI/storage is not applicable for the current objective; no
  separate implementation handoff or publication action is created.
- `2026-09-14T23:34:13+08:00`: Child P1-A implementation package digest
  `45afdbf879c6b0054790342861254abbc6d9cde846f61b43a160bd22064d0382` passed fresh
  independent Architecture and Quality/Release exact-digest review. The fixed report
  is `fix10` with 52/52 Envelope, 24/24 Delta and 76/76 total. `REP-Q-01` and hosted
  provenance remain open; the child implementation closure does not close the full
  Assignment or authorize current-proof, publication or Git actions.
- `2026-09-15T10:44:38+08:00`: Human Product Owner selected Option A for the P1-B
  residuals. The parent mirror now treats duplicate UI/storage as `Not applicable`,
  migration/backfill and background sync/network as `Deferred` and unauthorized, and
  retains only `REP-Q-01` and hosted provenance as open implementation residuals.
- `2026-09-15T11:36:22+08:00`: The [UK-005 P1-A provenance receipt](../evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md)
  closed `REP-Q-01` and candidate-bound hosted provenance. The parent remains `Active`
  because P-01/D-01 facts and Product/Release/publication authority are not produced by
  this receipt; no merge or Release action was performed.
- `2026-09-16T18:58:07+08:00`: PR #136 was merged into `main` as a separately authorized
  engineering action at `d5c53f2…`; the feature branch cleanup completed after reachability
  was verified. This did not produce current-proof, Product/Release acceptance or a Release.
  The new [P-01/D-01 fact-only Assignment](kos-release-evidence-implementation-001-p01-d01.md)
  was authorized separately; its final candidate and receipts remain unproduced.
- `2026-09-16T22:37:06+08:00`: Human Product Owner authorized the engineering/KOS
  Assignment Close recorded in the [UK-005 Close receipt](../evidence/kos-release-evidence-implementation-001-close-2026-09-16.md).
  Parent and P1 are now Closed; this does not authorize Product/Release/publication.
