# Assignment: KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1 — Delta-aware release-evidence implementation

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1",
  "record_type": "assignment",
  "title": "Implement delta-aware release-evidence adoption for new records",
  "lifecycle": "active",
  "current_phase": "P1-A implementation complete; exact-digest Architecture and Quality reviews passed; REP-Q-01 and candidate-bound hosted provenance closed; F-001 engineering merge complete; P-01/D-01 fact-only child active; P1-B Option A disposition recorded",
  "authorization_action": "implement_release_evidence_adopter_p1",
  "updated_at": "2026-09-16T18:58:07+08:00",
  "revalidation_triggers": [
    "upstream_candidate_changed",
    "contract_schema_or_evaluator_changed",
    "scope_changed",
    "owner_or_source_identity_changed",
    "required_mode_requested",
    "rep_q_01_finalized",
    "publication_boundary_changed",
    "privacy_owner_changed",
    "main_app_diagnostics_scope_changed"
  ],
  "authorization_refs": ["AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1"],
  "parent_refs": [
    "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001",
    "PD-KOS-UPGRADE-UK-005-RELEASE-EVIDENCE",
    "PD-KOS-UPGRADE-UK-005-P1-A-SCOPE"
  ],
  "responsibilities": {
    "domain_owner": "Architecture and Knowledge Steward",
    "executor": "Current Codex executor in isolated worktree",
    "environment_executor": "Current Codex executor for bounded local adapter, fixture and contract checks; no device, App Store Connect or TestFlight environment",
    "human_dependency": "Human Product Owner for any later scope change; Product/Release owner for any later publication handoff",
    "architecture_reviewer": "Independent Architecture reviewer, fresh runtime bound before P1 exit",
    "quality_reviewer": "Independent Quality, Performance and Release reviewer, fresh runtime bound before P1 exit",
    "product_approver": "Human Product Owner"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Lifecycle | active |
| Current Phase | P1-A implementation complete; exact-digest Architecture and Quality reviews passed; REP-Q-01 and candidate-bound hosted provenance closed; F-001 engineering merge complete; P-01/D-01 fact-only child active; P1-B Option A disposition recorded |
| Material non-claims | No new Swift/runtime change in this Assignment; no historical migration; no Keyboard Extension hot-path I/O; no Product/Quality/Release Gate or current-proof. PR #136 is a separate engineering merge fact, not Product/Release acceptance, a tag, Release or publication |
| Next handoff / decision | [`REP-Q-01 / hosted provenance closure receipt`](../evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md) binds the exact source-owner and UK-005 candidate identities. P-01/D-01 facts and any Product/Release handoff remain separate. P1-B has no implementation handoff under Option A |
| Residuals | [`P1 Residuals`](#residuals): P-01/D-01 delivery/final-validation facts and later Product/Release authority; `REP-Q-01` and candidate-bound hosted provenance are closed. P1-B disposition is recorded separately in [`PD-KOS-UPGRADE-UK-005-P1-B-SCOPE`](../product-decisions/KOS-UPGRADE-UK-005-P1-B-scope.md) |

The current P-01/D-01 fact-only child handoff is [tracked separately](kos-release-evidence-implementation-001-p01-d01.md); it may produce only fresh facts and does not authorize Product/Release/publication action. PR #136 is recorded as an engineering merge fact and does not widen this Assignment.

This is a child Assignment of the completed P0 contract/Profile handoff. It authorizes
the P1-A implementation boundary through its separate Authorization record. It does not
amend the P0 contract or authorize a new P1-B implementation. The later Product Decision
for P1-B records that the duplicate UI/storage slice is Not applicable for the current
objective and that migration/backfill and background sync remain Deferred.

## Authority

- Assignment Authority: Product Lead.
- Decision Source / Date: Accepted [`PD-KOS-UPGRADE-UK-005-P1-A-SCOPE`](../product-decisions/KOS-UPGRADE-UK-005-P1-A-scope.md), created from the Human Product Owner approval in the current task at `2026-09-14T19:13:06+08:00` Asia/Shanghai.
- P1-B Disposition: Accepted [`PD-KOS-UPGRADE-UK-005-P1-B-SCOPE`](../product-decisions/KOS-UPGRADE-UK-005-P1-B-scope.md), Human Product Owner approval of Option A, `2026-09-15 Asia/Shanghai`.
- Product Approver: Human Product Owner acting as Product Lead.
- Parent Assignment: [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001`](kos-release-evidence-implementation-001.md), P0 complete; its P0 Authorization is not widened by this record.
- P1 Authorization: [`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md).

## Boundary

### P1-A authorized scope

P1-A is the smallest implementation slice that makes the adopted contract useful for
daily incremental Beta work while preserving a later external-candidate handoff:

1. Implement the project adapter/profile mapping for **new** `kos.release-evidence`
   records. The adapter must preserve the exact candidate pins, leaf-level owner map,
   pointer grammar, privacy allowlist and evaluator precedence in the P0 Profile.
2. Reconcile and prepare a binding to the existing Main-App release-evidence authority
   identified by `SRC-MAIN-STORE` and ADR 0027. `REP-Q-01` is now closed by the exact
   source-owner and candidate-bound provenance receipt; this closes the implementation
   identity boundary, not a Product/Release decision. The reviewed adapter remains
   fail-closed and no current-proof or publication claim may be inferred from this
   receipt. Consume that owner boundary; do not create a second store, move persistence
   into the Keyboard Extension, or change clear/retention semantics.
3. Add bounded, content-free fixtures and run the pinned schema/evaluator against them
   with an explicit `--as-of` value. The fixture matrix must cover invalid input,
   unbound target, promotion reasons, current-proof prerequisites, unresolved candidate,
   non-comparable claims, and fallback `none`.
4. Add first/subsequent daily-Beta promotion fixtures: the first external candidate
   requires a same-lineage baseline; a subsequent candidate requires the previous
   target receipt. The stable history key remains exactly `release_lineage`.
5. Add exact P-01 and D-01 fixture pairs. A P-01 pass requires a fresh candidate-bound
   receipt, `relation=same-head`, hosted result `pass`, equal comparison basis and
   `local_head == published_head == hosted_ci_head == candidate_head`. A D-01 pass
   requires a fresh bound receipt, equal final-tree digest, resolved checker/version/
   scope/baseline/output and exit code `0`.
6. Implement the delta-aware validation/test-scope rule for new records:
   unchanged evidence may be reused only when candidate identity, contract/profile,
   evidence source, comparison basis and freshness remain valid; every touched claim
   or binding must be rechecked. A contract/schema/evaluator, owner/source, promotion,
   privacy, build/release or final-validation change escalates the scope and invalidates
   the narrow reuse path.
7. Demonstrate the daily Beta → external-candidate reuse path. Daily Beta evidence may
   supply the external candidate's claim/observation history when the exact bindings
   pass, but external delivery state, Beta Review and any Product/Release decision remain
   separate facts and gates. Reuse never means automatic external approval.
8. Produce a P1 implementation receipt that records the changed-surface set, fixture
   names, evaluator/schema pins, explicit `as_of`, reused evidence keys, invalidation
   triggers, test results and all non-claims. Obtain fresh independent Architecture and
   Quality review of that P1 receipt before declaring P1 complete.

### Historical P1-B follow-on boundary

> **Superseded for current status:** see [`PD-KOS-UPGRADE-UK-005-P1-B-SCOPE`](../product-decisions/KOS-UPGRADE-UK-005-P1-B-scope.md). The historical authorization narrative below is retained for audit; current disposition is duplicate UI/storage `Not applicable`, while migration/backfill and background sync remain `Deferred` and unauthorized.

The following is intentionally **not** authorized by this Assignment or its P1
Authorization:

- adding or changing a Main-App Diagnostics UI for release-evidence records;
- adding or changing `Diagnostics/v1/release-evidence/records.json` persistence,
  retention, clear behavior or its owning actor;
- adding a new user-facing diagnostics feature, export format, background sync or
  migration/backfill.

The prior P1-B follow-on was considered for the user's goal of reducing cross-tool
inspection. The current Product Decision concludes that the duplicate UI/storage
slice is not needed because the separately bounded Main-App release-evidence feature
already covers that objective. P1-A may verify and consume the existing source
boundary; it may not silently implement migration, background sync or any future
residual under this Authorization.

### Affected systems

- Project release-evidence adapter and its content-free contract/fixture tests.
- Existing Main-App release-evidence source seam reconciliation, only within the owner
  boundary already described by ADR 0027; a completed binding remains blocked by
  `REP-Q-01`.
- KOS evidence receipt and independent review handoff.

The Keyboard Extension hot path, runtime network, App Group ownership, archive/export,
App Store Connect, TestFlight and Release services are not affected systems for P1-A.

## Incremental validation contract

The purpose of P1 is not to require a full release rehearsal for every small daily
change. The first-principles rule is:

> Re-run the evidence that could have changed; reuse only evidence whose identity and
> freshness prove that it could not have changed.

| Change class | P1-A validation | Reuse boundary |
|---|---|---|
| Content-free record field or adapter mapping only | Focused serialization, allowlist, pointer and affected-claim fixtures | Reuse unchanged daily-Beta evidence only for untouched, still-fresh bindings |
| Candidate/artifact/context identity or comparison basis | Candidate-binding and comparison fixtures plus affected focused tests | Prior evidence is invalid for the changed identity/basis |
| Promotion, baseline or previous-receipt rule | First/subsequent history matrix and evaluator precedence fixtures | No promotion conclusion is reused across a changed rule |
| Schema, evaluator, profile, privacy or source-owner change | Full P1 contract/fixture set and independent review; re-freeze pins if changed | Narrow path is invalid; a new Product Decision may be required |
| Build, delivery, hosted CI, final validation or publication change | P1 records the escalation and stops before claiming publication proof | P-01/D-01 facts must be freshly produced by their owners |

`release_validation_profile` and the repository `ci_change_tier` are independent
classifiers. A release `delta` can narrow the release-evidence fixture/reuse set, but it
must never downgrade the repository CI tier. Only the existing CI Source of Truth may
classify a change as `docs_only`; every Swift, source, test, project, workflow, tooling
or unknown path remains `full` and must satisfy the repository's Swift hard gate and
applicable CI-equivalent tests before commit/push or merge consideration.

### Dependency-closed reuse rule

The delta classifier must receive a complete tuple of `changed_surface`, exact
`base_sha`/`head_sha`, candidate identity, Profile/contract/schema/evaluator pins, source
identity, affected claim/coverage keys, comparison basis and freshness inputs. A missing,
unparseable or ambiguous path, base/head, owner, binding or dependency is fail-closed:
the release-evidence reuse set is empty, the release-validation scope is `full`, and no
prior evidence may be used to claim current proof. The repository CI classifier runs
independently; an unknown non-document path is CI `full`, never `docs_only`.

| Changed surface | Evidence invalidated / required recheck |
|---|---|
| Candidate, artifact, context, environment or comparison identity | All observations and delivery/final-validation facts bound to that identity; rerun candidate-binding and comparison fixtures |
| Profile, source owner, claim/coverage binding or privacy allowlist | All records using the affected Profile/source/claim set; rerun owner, privacy and provenance fixtures |
| Observation freshness, `max_age_days`, `as_of` or provenance rule | All freshness/provenance conclusions in the affected record lineage; rerun future, expired and identity-mismatch fixtures |
| Promotion, `release_lineage`, baseline or previous-receipt rule | First/subsequent promotion conclusions; rerun the complete history matrix |
| Schema, contract or evaluator pin | All contract conclusions; no narrow reuse and a new exact pin/review package |
| Delivery/hosted CI or final-validation input | P-01 and/or D-01 facts; obtain a fresh owner receipt and stop before publication claims |
| Unknown, ambiguous or unclassifiable diff | Empty reuse set, release-validation `full`, CI `full` for the unknown path, and stop before current-proof |

This classification is a project-side execution aid. It does not add an unapproved field
to the portable Envelope and it never converts a validator result into Product,
Quality, Release or App Store Connect acceptance.

## Non-goals

- No change to the adopted `v0.8.0` Kit pin, the exact `kos.release-evidence` candidate,
  or the P0 Profile without a new Product Decision/revalidation.
- No historical migration, backfill or retroactive reinterpretation of existing Beta or
  release records.
- No raw user input, candidate text, host text, credentials, full logs or unrelated
  user data in records, fixtures or receipts.
- No synchronous Keyboard Extension I/O, runtime network dependency, new App Group
  ownership or background upload.
- No duplicate Main-App Diagnostics UI/storage feature for the current objective; Option A
  records that residual as `Not applicable`. A later superseding residual needs a new
  Product Decision, Assignment and Authorization.
- No archive/export, App Store Connect, TestFlight upload, Beta Review submission,
  external publication, Product Gate, Quality Gate or Release Pass.
- No unscoped GitHub action: the current receipt permits only the separately authorized
  scoped commit, push and PR; merge, tag, branch deletion and publication remain outside
  this Assignment.
- No activation of KOS `required` mode and no bulk legacy Envelope migration.

## Required Inputs

- The adopted candidate pins and contract semantics in [`PD-KOS-UPGRADE-UK-005`](../product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md) and [`release-evidence-profile.md`](../kos/release-evidence-profile.md).
- The reproducible P0 predecessor successor receipt [`kos-release-evidence-implementation-001-p0-status-sync-freeze-2026-09-14.md`](../evidence/kos-release-evidence-implementation-001-p0-status-sync-freeze-2026-09-14.md), digest `5fde8e2acf499711be279c4a6f43a83607e7d9e43d719c95e557de82c3335e73`; the original P0 receipt remains a historical snapshot at its recorded digest.
- The parent P0 Assignment and its separate P0 Authorization.
- ADR 0027's existing Main-App diagnostic/release-evidence ownership boundary.
- The pinned schema/evaluator sources and their recorded digests; no floating latest
  dependency is acceptable.
- The actual changed-surface set and base/head identity for the P1 implementation
  worktree. Ambient uncommitted Main-worktree state is an input to reconcile, not proof.
- Fresh Architecture and Quality reviewer runtimes before the P1 exit review.

## Evidence

- Current scope/authorization freeze: [`kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md).
  It is an executor-recorded documentation receipt, not an implementation result or an
  independent Architecture/Quality conclusion.

## KOS v0.8.0 optional-contract selection

This newly created Assignment opts into the same project-level contract for new records
and handoffs only:

| Contract | Selection | P1-A boundary |
|---|---|---|
| E-01 claim-bound observation | Adopted | Content-free observation/coverage mapping; existing Main-App evidence owner remains authoritative |
| P-01 publication facts | Adopted | Fixture and receipt contract only; actual delivery facts are produced by the named delivery owner |
| D-01 final-documentation receipt | Adopted | Fixture and receipt contract only; actual final-validation facts are produced by the named validation owner |
| A-01 / B-01 authorization chain and briefing | Not applicable to P1-A | Any later scope expansion, publication, merge or Release action needs its own human authorization |

`required` remains unauthorized. The optional contracts do not make the Executor,
validator or reviewer a Product/Quality/Release authority.

## Gates

### Entry Criteria

- [x] P0 contract/Profile handoff is complete and independently reviewed.
- [x] The exact adopted candidate and all contract/schema/evaluator digests are frozen
      in the P0 Profile.
- [x] Human Product Owner approved this separate P1 scope and Authorization.
- [x] P1-A and P1-B are explicitly separated; P1-B has no implied implementation
      permission.
- [x] The required responsibilities, affected systems and stop boundaries are named.
- [x] Before implementation: changed-file/test scope is bound to the actual P1
      execution branch; fresh reviewer runtimes remain required for the exit review.

### P1 Exit Criteria

- [x] New-record adapter/profile mapping passes focused contract and privacy tests.
- [x] Existing Main-App source seam is reconciled without a second store or hot-path I/O;
      the source-binding exit is closed by the exact implementation identity and
      candidate-bound hosted provenance in the [closure receipt](../evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md).
      This does not make the adapter's fail-closed observation a current-proof claim.
- [x] The pinned schema/evaluator fixture matrix passes with explicit `as_of` evidence.
- [x] Daily Beta first/subsequent baseline and previous-receipt rules pass.
- [x] Delta-aware validation reruns touched evidence and safely reuses only unchanged,
      identity-bound, fresh evidence.
- [x] Daily Beta evidence can be consumed by an external-candidate record without
      collapsing external delivery/Beta Review/Product/Release gates.
- [x] P-01/D-01 fixture/receipt conditions and privacy-safe pointer checks pass.
- [x] P1 implementation receipt records exact changed surface, pins, commands, results,
      reviewer inputs and non-claims.
- [x] Independent Architecture and Quality reviewers Pass the exact P1 package.
- [x] No publication readiness, Product Gate or Release conclusion is inferred from P1.

### Required negative-fixture inventory

The P1 implementation receipt must bind each case below to a fixture ID, exact pinned
schema/evaluator command, explicit `--as-of`, output, exit code and non-claim. A prose
summary without per-case evidence does not close this condition:

- Invalid JSON/schema/key/policy and a timezone-qualified `as_of` that violates the
  evaluator input contract.
- Unbound target → `pending`; bound target with baseline/history failure → `none`;
  all non-comparable claims → `comparator`; mixed claim outcomes → `none`.
- First target with a previous receipt; subsequent target with a baseline; mismatched
  or missing `release_lineage`; and candidate/identity mismatch.
- Observation, delivery, final-validation and provenance future timestamps, age beyond
  `max_age_days`, expired `valid_until` and identity mismatch.
- P-01 missing/unknown/mismatched head, non-`pass` hosted result and unequal comparison
  basis; D-01 final-tree mismatch, unresolved checker/version/scope/baseline/output,
  non-zero exit and non-`pass` result.
- One safe reuse case and one invalidation case for each dependency row above, including
  unknown/ambiguous diff input. Each invalidation case must show the old evidence key was
  not reused or was freshly re-executed.

## Stop Conditions

- Any candidate, artifact, context, source owner, baseline, previous receipt, final SHA,
  comparison basis, freshness or hosted provenance needed for a claim is unknown.
- The requested change requires a schema/evaluator pin change, a new evidence authority,
  a new Main-App store/UI feature or a migration/backfill.
- A test-scope classifier would skip a touched contract, privacy, source, promotion,
  delivery or final-validation rule.
- The implementation would add raw user content, credentials, full logs, synchronous
  Extension I/O or runtime network.
- A comparator, pending, none or unresolved result would be promoted to current proof.
- A P-01/D-01 condition is missing, stale or not bound to the candidate.
- Independent Architecture/Quality review is unavailable, non-independent or lacks the
  exact P1 package digest.
- Any action crosses into commit, push, merge, tag, App Store Connect, TestFlight,
  external publication or Release without a separate exact authorization.

## Residuals

| ID | Owner | Disposition | Boundary / pointer |
|---|---|---|---|
| `REP-Q-01` | Universe release-evidence owner | `closed` | Exact Main-App source-owner candidate, source blobs, actual base/head and same-head hosted run are bound together with the UK-005 package in the [closure receipt](../evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md) |
| `HOSTED-PROVENANCE` | Product/Release owner | `closed` for candidate-bound CI | UK-005 branch head `666a421…` equals hosted run `34924569095` `headSha`; upstream tag/Release, P-01/D-01 and publication facts remain separate and unclaimed |
| `P1-B-DIAGNOSTICS` | Human Product Owner | `accept` | Option A records duplicate Main-App UI/storage as Not applicable; historical migration/backfill and background sync remain Deferred and unauthorized. See [`P1-B scope decision`](../product-decisions/KOS-UPGRADE-UK-005-P1-B-scope.md) |

## Handoff

- Handoff Target: independent Architecture reviewer → independent Quality reviewer →
  Product/Release owner for any later publication handoff; P1-B Option A is recorded
  and has no implementation handoff.
- Required Handoff Content: exact candidate pins; P0 digest/reference; changed-surface
  set; adapter/source bindings; fixture matrix; explicit `as_of`; daily-Beta reuse keys;
  invalidation/escalation results; P-01/D-01 facts; privacy/hot-path checks; reviewer
  package digest; the [REP-Q-01 / hosted provenance closure receipt](../evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md);
  explicit non-claims.
- Revalidation Trigger: any candidate, schema/evaluator, Profile, owner/source,
  privacy, Main-App diagnostics, publication or `required` boundary change.

## History

- `2026-09-14T19:13:06+08:00`: Human Product Owner approved the independently scoped
  P1-A scope and Authorization, recorded in [`PD-KOS-UPGRADE-UK-005-P1-A-SCOPE`](../product-decisions/KOS-UPGRADE-UK-005-P1-A-scope.md).
  P1-A authorizes the new-record adapter, reconciliation of the existing Main-App
  source seam, pinned fixtures, delta-aware focused validation and review receipt.
  At that time, Main-App Diagnostics UI/storage work was recorded as P1-B and remained
  separately unauthorized; no implementation, device action, publication or GitHub action started.
- `2026-09-14T21:27:20+08:00`: P1-A remediation added fail-closed Main-App wrapper/source
  validation, explicit identity/receipt allowlists, claim/coverage-bound delta tuples,
  authority-path classification, fixed fixture inventory checks and expanded lineage,
  D-01, triggered-path and unsafe-input coverage. The updated receipt and fresh
  exact-digest Architecture/Quality review remain required before P1 exit.
- `2026-09-14T23:34:13+08:00`: P1-A implementation package digest
  `45afdbf879c6b0054790342861254abbc6d9cde846f61b43a160bd22064d0382` passed fresh
  independent Architecture and Quality/Release exact-digest review. The fixed report
  is `fix10` with 52/52 Envelope, 24/24 Delta and 76/76 total. At that time,
  `REP-Q-01`, hosted provenance and P1-B were explicit residuals; this did not authorize
  current-proof, Product/Release gates, publication or Git actions.
- `2026-09-15T10:44:38+08:00`: Human Product Owner adopted Option A for the P1-B
  scope. Duplicate Main-App UI/storage is `Not applicable` for the current objective;
  historical migration/backfill and background sync remain `Deferred` and unauthorized.
  No new P1-B Assignment or Authorization was created. The P1-A `REP-Q-01` and
  hosted-provenance residuals remain unchanged.
- `2026-09-15T11:36:22+08:00`: The [REP-Q-01 / hosted provenance closure
  receipt](../evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md)
  bound the Main-App source-owner candidate `ad39f44…` and the UK-005 package head
  `666a421…`; hosted run `34924569095` returned `success` with the exact UK-005
  `headSha`. The scoped commit/push/PR authorization was exercised; no merge, Release
  or publication action was performed.
- `2026-09-15T12:04:38+08:00`: PR #132's single documentation conflict in
  `docs/KNOWLEDGE_INDEX.md` was resolved in an isolated integration branch by
  retaining both link sets. Local CI-equivalent verification passed on merge
  resolution commit `1609a1b…`. The resulting six-file package digest is
  `f16573…`, which is a new integration identity; the prior exact-review digest
  `45afdb…` remains historical and is not relabeled. Push, hosted CI and merge
  remain separate authorized actions.
- `2026-09-15T12:17:21+08:00`: PR #132 head `e039a9a…` passed hosted run
  `34927490938` on rerun attempt `2`, including `test-app-keyboard` and
  `final-quality-gate`. Attempt `1` failed only because its runner lacked the named
  `iPhone 17 Pro` simulator; that environment observation is retained and was not
  treated as a source or contract failure. The PR is now merge-ready under the
  separately authorized merge action; no Product/Release or publication conclusion
  is inferred.
- `2026-09-16T18:58:07+08:00`: PR #136 was merged into `main` at `d5c53f2…` as a
  separately authorized engineering action, and its local/remote feature branches were
  removed only after reachability was verified. This did not widen the P1-A boundary or
  create Product/Release/publication proof. The new [P-01/D-01 fact-only Assignment]
  (kos-release-evidence-implementation-001-p01-d01.md) is active for the next bounded
  handoff.
