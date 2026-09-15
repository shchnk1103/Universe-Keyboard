# Universe Keyboard adopter Profile: `kos.release-evidence` v1.0

## Profile status

| Field | Value |
|---|---|
| Profile ID | `universe-keyboard-release-evidence-v1` (human/document identifier) |
| Adoption | Adopted prospectively; explicit opt-in required per new record or handoff |
| Contract owner | Universe release-evidence owner; current task owner is Architecture & Knowledge Steward |
| Upstream identity | Exact untagged candidate in [`PD-KOS-UPGRADE-UK-005`](../product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md) |
| Project pin | `kos-agent-kit v0.8.0` remains advisory and unchanged |
| Runtime boundary | Main-App-owned local evidence; no Keyboard Extension synchronous I/O and no runtime network |
| Envelope profile ref | `profile://universe-keyboard/release-evidence-v1` (machine binding) |
| Current stage | P1-A adapter, fixture and delta-planning implementation present; Main-App Swift/UI/storage unchanged; `REP-Q-01` source identity unresolved, so adapter-generated pass observations remain non-proof; exact-digest independent exit review remains an explicit gate |

This document is the project adapter Profile. It does not copy the KOS Kit schema into
the project, replace the existing release-evidence Source of Truth, or create a Product,
Quality, Gate or Release decision.

## Exact adopted candidate

| Input | Identity |
|---|---|
| Implementation commit | `8e55551a3b56b57e7fc5ab5544d653f9c6854df9` |
| Adoption metadata commit | `f5c88d57f599d7ef352322ea7664f637fb288d60` |
| Candidate tree digest | `fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9` |
| Contract source digest | `f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673` |
| Standalone schema digest | `4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce` |
| Reference evaluator digest | `a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9` |
| Universe review packet digest | `18eb208bec1bd4ee29968bc9bf1989000ceea51c50848a5f74da47ee2eeb9d3a` |

The candidate tree digest is the ordered raw-byte concatenation of the ten files named
in the pinned Kit implementation receipt. The fixture runner also requires the pinned
implementation commit to be an ancestor of the adoption metadata commit, requires the
Kit `HEAD` to equal that adoption metadata commit, and requires a clean Kit worktree
before it runs the matrix. The three semantic source digests and the complete candidate
identity are reported separately so a passing source pin cannot hide candidate-tree
drift.

The candidate remains explicitly untagged in the recorded snapshot. A later hosted
tag/Release check is required before `Ready` or publication; failure to reach GitHub is
not evidence that a hosted Release is absent.

## Source identifiers used by the owner map

These identifiers make the owner table locatable without treating ambient worktree state
as evidence:

| Source ID | Exact source / identity | Boundary |
|---|---|---|
| `SRC-KOS-CONTRACT` | Pinned candidate `ops/release-evidence.md`, `schemas/release-evidence-v1.schema.json` and `scripts/validate_release_evidence.py`; digests above | Canonical contract/evaluator semantics; not a project fact store |
| `SRC-PD` | `docs/product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md` | Human Product adoption decision and candidate pins |
| `SRC-P1-PD` | `docs/product-decisions/KOS-UPGRADE-UK-005-P1-A-scope.md` | Accepted P1-A scope decision; does not authorize P1-B or publication |
| `SRC-ASSIGNMENT` | `docs/assignments/kos-release-evidence-implementation-001.md` | This P0 execution envelope and its scope/owner boundary |
| `SRC-P1-ASSIGNMENT` | `docs/assignments/kos-release-evidence-implementation-001-p1.md` | Child P1-A execution envelope and delta-validation boundary |
| `SRC-MAIN-PROMOTION` | Main-worktree-only `docs/assignments/release-evidence-promotion-001.md`, `docs/product-decisions/RELEASE-EVIDENCE-PROMOTION-001-authorization.md`, `docs/authorizations/AUTH-RELEASE-EVIDENCE-PROMOTION-001.md` and `docs/architecture/decisions/0035-release-evidence-accumulation-and-promotion.md` | Existing implementation input; uncommitted and absent from this frozen worktree, so stable identity is explicitly `REP-Q-01`, not current-proof provenance |
| `SRC-MAIN-STORE` | `Diagnostics/v1/release-evidence/records.json` ownership and lifecycle at [`ADR 0027`](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md#L33) | Main-App source seam only until `REP-Q-01` binds the actual implementation identity; not current-proof provenance before then |
| `SRC-P0-RECEIPT` | [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 P0 predecessor successor`](../evidence/kos-release-evidence-implementation-001-p0-status-sync-freeze-2026-09-14.md) | Executor-recorded document/contract validation receipt, not an Envelope receipt; successor digest is the reproducible predecessor identity |
| `SRC-P1-ADAPTER` | [`scripts/release/kos_release_evidence_adapter.py`](../../scripts/release/kos_release_evidence_adapter.py) plus its focused tests | Project-side mapping and fail-closed delta planner; does not take ownership of Main-App storage |
| `SRC-P1-FIXTURES` | [`kos_release_evidence_cases.json`](../../scripts/release/fixtures/kos_release_evidence_cases.json) and [`run_kos_release_evidence_fixtures.py`](../../scripts/release/run_kos_release_evidence_fixtures.py) | Fixed contract/evaluator and reuse matrix; no runtime or publication facts |
| `SRC-P1-RECEIPT` | [`P1 implementation receipt`](../evidence/kos-release-evidence-implementation-001-p1-implementation-2026-09-14.md) plus any named future `release-evidence` record, delivery, final-validation or provenance receipt under `SRC-MAIN-PROMOTION` / `SRC-MAIN-STORE` | Executor-recorded implementation/fixture result; actual Main-App source binding remains blocked by `REP-Q-01` until given a stable path and digest |

`SRC-MAIN-STORE` is therefore a named architectural seam, not a completed source
binding. P1-A may reconcile its path and owner, but only a closed `REP-Q-01` with an
exact implementation identity can promote that seam to a binding used for current-proof.
Until then, the adapter's code-controlled `MAIN_APP_SOURCE_BINDING_STATE` remains
`unresolved`: it accepts the bounded source pointer for diagnostics/reconciliation but
downgrades otherwise passing Main-App observations to `inconclusive`. No caller field can
enable this gate, and an adapter-generated Envelope cannot produce `current-proof`.

## P1-A implementation mapping (new records only)

The project-side implementation is deliberately a build/release adapter rather than a
second evidence authority:

| Component | Location | Responsibility | Boundary |
|---|---|---|---|
| Envelope adapter | [`scripts/release/kos_release_evidence_adapter.py`](../../scripts/release/kos_release_evidence_adapter.py) | Map one content-free Main-App `release_evidence_run` export to the adopted Envelope; validate bounded IDs, pointers, identities and timestamps | No App Group/store access, network, Swift/runtime code or authority decision |
| Fixed contract matrix | [`scripts/release/fixtures/kos_release_evidence_cases.json`](../../scripts/release/fixtures/kos_release_evidence_cases.json) | Keep positive/negative evaluator and delta-reuse inputs deterministic | Fixture strings are opaque test data; Main-App notes are discarded |
| Fixture runner | [`scripts/release/run_kos_release_evidence_fixtures.py`](../../scripts/release/run_kos_release_evidence_fixtures.py) | Verify complete pinned Kit identity/tree and semantic source digests, invoke the evaluator with explicit `--as-of`, and record per-case output/exit/non-claim | Read-only subprocess orchestration; it does not upload, publish or mutate project authority |
| Focused tests | [`scripts/release/tests/test_kos_release_evidence_adapter.py`](../../scripts/release/tests/test_kos_release_evidence_adapter.py) | Protect mapping, privacy, promotion-history, mutation and delta boundaries | Python standard library only |

The adapter accepts only the canonical Main-App export wrapper: exact keys
`schemaVersion`, `evidenceContractVersion`, `recordType`, `run`, `outcome` and
`nonClaims`, with values `1`, `release-evidence-v1` and `release_evidence_run` for the
three version/type fields. A direct `run` object, a foreign wrapper version, an unknown
wrapper field or an unresolved Main-App source record ID is rejected before Envelope
construction. The separately supplied `main_app_source` object must use the exact
`SRC-MAIN-STORE` source identity and a resolved record/operation/digest binding; a
case-variant unresolved value, foreign source or extra source field is rejected. The
wrapper's `nonClaims` and aggregate `outcome` must match the canonical Main-App export
contract and run-derived outcome. Run/step nested fields are closed to the Main-App
Codable shape; notes are bounded and discarded. The adapter emits only the Profile's
allowlisted Envelope fields. A Main-App `note`, raw text, full log or unknown export
field is not copied. The Main-App's source-specific `partial` step outcome is mapped to
KOS `inconclusive`, preserving its non-passing meaning without inventing a new KOS
outcome.
Missing P-01/D-01 receipts become explicit `not-run`/`UNKNOWN` fields; the adapter never
fills them with a passing value. The existing `SRC-MAIN-STORE` path and ADR 0027 owner
remain the source seam; this P1-A slice does not create or change
`Diagnostics/v1/release-evidence/records.json`.
Because `REP-Q-01` has not supplied a stable owner-attested implementation identity, the
adapter also maps a pass step to `inconclusive` while its source-binding gate is
`unresolved`. This is an intentional fail-closed handoff state, not a new Main-App
outcome and not a substitute for closing the residual.

The claim registry is stable and explicit:

| Main-App step scope | Envelope claim | Coverage |
|---|---|---|
| `candidate_identity` | `UK-RE-CANDIDATE-IDENTITY` | `UK-RE-COVERAGE-CANDIDATE-IDENTITY` |
| `changed_path_validation` | `UK-RE-CHANGED-PATH-VALIDATION` | `UK-RE-COVERAGE-CHANGED-PATH-VALIDATION` |
| `affected_path_smoke` | `UK-RE-AFFECTED-PATH-SMOKE` | `UK-RE-COVERAGE-AFFECTED-PATH-SMOKE` |
| `evidence_reuse` | `UK-RE-EVIDENCE-REUSE` | `UK-RE-COVERAGE-EVIDENCE-REUSE` |
| `triggered_boundary` | `UK-RE-TRIGGERED-BOUNDARY` | `UK-RE-COVERAGE-TRIGGERED-BOUNDARY` |
| `baseline_boundary` | `UK-RE-BASELINE-BOUNDARY` | `UK-RE-COVERAGE-BASELINE-BOUNDARY` |
| `external_candidate_readiness` | `UK-RE-EXTERNAL-CANDIDATE-READINESS` | `UK-RE-COVERAGE-EXTERNAL-CANDIDATE-READINESS` |

The adapter's command boundary is explicit. For a new Main-App export, first produce a
bounded input JSON and run:

```bash
python3 scripts/release/kos_release_evidence_adapter.py envelope \
  --input <main-app-export-input.json> \
  --output <envelope.json>

python3 <pinned-kos-agent-kit>/scripts/validate_release_evidence.py \
  <envelope.json> \
  --as-of <ISO-8601 timestamp with timezone>
```

The repository fixture command verifies the exact contract/schema/evaluator digests and
uses an explicit `--as-of` for every evaluator invocation:

```bash
python3 scripts/release/run_kos_release_evidence_fixtures.py \
  --kos-kit-root <pinned-kos-agent-kit> \
  --work-dir <bounded-local-fixture-output> \
  --output <fixture-report.json>
```

The checked-in fixture inventory is fixed at 52 Envelope cases (`UK-RE-FX-001` through
`UK-RE-FX-052`) and 24 delta cases (`UK-RE-DELTA-001` through `UK-RE-DELTA-024`). The
runner rejects an inventory substitution before executing a case, and records the exact
inventory in its machine report. Every delta plan preserves its supplied `base_sha` and
`head_sha`; equal heads with a non-empty changed surface and duplicate/ambiguous surface
entries fail closed instead of being silently normalized. Every delta evidence tuple is
normalized before reuse:
its scope, claim and coverage must match the Profile registry, its identity/pins must
match the current candidate, and a malformed, duplicate or extra-field tuple empties
reuse and stops before current-proof.

The delta command returns two independent results: `release_validation_profile` controls
which release-evidence facts may be rerun/reused, while `ci_change_tier` mirrors the
repository CI classifier's `docs_only`/`full` boundary. Therefore a `docs/kos/**` or
`.kos/**` change is `ci_change_tier=docs_only` but still has a release-validation
`full` profile when it changes the adopted Profile or KOS machine state. A delivery or final-validation
change retains unrelated fresh observation keys but sets `stop_before_current_proof`;
candidate, source-owner/privacy, freshness, promotion, schema/contract/evaluator and
unknown changes empty the reuse set and escalate to `full`. The concrete
`Universe Keyboard/Services/ReleaseEvidenceStore.swift` Main-App source-owner path is
also a release dependency and forces `full`/no reuse; it is not treated as an ordinary
Services delta. A docs-only path may reuse all exact, fresh keys, but the docs-only
allowlist contains only `docs/RELEASE_CHECKLIST.md`. Profile, KOS machine-state,
Assignment, Authorization, product-decision and architecture-decision paths are
release-evidence dependencies and always require `full`/stop behavior; none can
authorize a release.

## Leaf-exact owner map

The table enumerates every portable leaf. The only grouped entries are bounded identity
maps, whose key/value boundary is explicitly closed by the pinned schema limits; they are
not wildcard ownership of unrelated fields. Each row has one canonical project owner and
one source. The four role columns are intentionally separate: they never transfer
canonical ownership.

Role labels used below:

- `P-Evidence`, `P-Delivery`, `P-Validation` and `P-Promotion` are fact producers;
- `R-Arch/Quality` is the independent reviewer;
- `D-Main-App` is the Main-App diagnostics/release-evidence display and redacted-export owner;
- `H-Product/Release` is the Human authority for a later action, never the producer of a fact.

| Portable leaf | Canonical owner | Canonical source / identity | Producer | Reviewer | Display owner | Human authority |
|---|---|---|---|---|---|---|
| `contract` | KOS contract owner | `SRC-KOS-CONTRACT` | none | `R-Arch/Quality` | `D-Main-App` | none |
| `contract_version.major` | KOS contract owner | `SRC-KOS-CONTRACT` | none | `R-Arch/Quality` | `D-Main-App` | none |
| `contract_version.minor` | KOS contract owner | `SRC-KOS-CONTRACT` | none | `R-Arch/Quality` | `D-Main-App` | none |
| `record_id` | Universe release-evidence record owner | `SRC-ASSIGNMENT`; persistence identity is a P1/`REP-Q-01` input | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `candidate.candidate_id` | Universe candidate owner | `SRC-MAIN-PROMOTION`; pre-freeze, no final SHA | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `candidate.artifact_identity[<bounded-key>]` | Universe artifact owner | `SRC-MAIN-PROMOTION`; pre-freeze, no final SHA | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `candidate.context_identity[<bounded-key>]` | Universe release-context owner | `SRC-MAIN-PROMOTION` and the release Assignment named there; pre-freeze | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `candidate.artifact_or_input_ref` | Universe artifact owner | `SRC-MAIN-PROMOTION`; stable receipt identity pending `REP-Q-01` | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `candidate.environment_ref` | Universe environment owner | `SRC-MAIN-PROMOTION`; named environment source pending `REP-Q-01` | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `candidate.comparison_basis` | Universe release-context owner | `SRC-MAIN-PROMOTION` handoff input; pre-freeze | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `candidate.profile_ref` | Adopter Profile owner | This Profile, `Profile ID` above | none | `R-Arch/Quality` | `D-Main-App` | none |
| `candidate.final_tree_digest` | Universe candidate owner | Candidate source receipt in `SRC-MAIN-PROMOTION`; D-01 validates but does not produce candidate identity | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `candidate.candidate_head` | Universe candidate owner | Candidate source receipt in `SRC-MAIN-PROMOTION`; P-01 validates but does not produce candidate identity | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `policy.required_claim_bindings[].claim_ref` | Adopter Profile owner | This Profile's claim contract and `SRC-ASSIGNMENT` | none | `R-Arch/Quality` | `D-Main-App` | none |
| `policy.required_claim_bindings[].coverage_ref` | Adopter Profile owner | This Profile's coverage contract and `SRC-ASSIGNMENT` | none | `R-Arch/Quality` | `D-Main-App` | none |
| `policy.max_age_days` | Adopter Profile owner | Explicit value in the exact handoff Envelope; definition in this Profile, fact receipt at `SRC-P1-RECEIPT` | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `policy.require_baseline_for_first_target` | Adopter Profile owner | This Profile's first-target policy | none | `R-Arch/Quality` | `D-Main-App` | none |
| `policy.require_previous_target_for_subsequent` | Adopter Profile owner | This Profile's subsequent-target policy | none | `R-Arch/Quality` | `D-Main-App` | none |
| `policy.previous_receipt_identity_keys[]` | Adopter Profile owner | This Profile: exactly `release_lineage` | none | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].observation_id` | Universe evidence owner | `SRC-MAIN-STORE`; actual store identity pending `REP-Q-01` | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].claim_ref` | Universe evidence owner | `SRC-MAIN-STORE` | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].observation_outcome` | Universe evidence owner | `SRC-MAIN-STORE` | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].observed_at` | Universe evidence owner | `SRC-MAIN-STORE` | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].evidence_ref` | Universe evidence owner | `SRC-MAIN-STORE` and the bounded pointer grammar below | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].environment_ref` | Universe evidence owner | `SRC-MAIN-STORE`, bound to `candidate.environment_ref` | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].artifact_or_input_ref` | Universe evidence owner | `SRC-MAIN-STORE`, bound to the candidate input | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].coverage_ref` | Universe evidence owner | `SRC-MAIN-STORE`, bound to `policy.required_claim_bindings` | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].comparison_basis` | Universe evidence owner | `SRC-MAIN-STORE`, bound to candidate basis | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].freshness.observed_at` | Universe evidence owner | `SRC-MAIN-STORE`; must equal `observations[].observed_at` | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].freshness.valid_until` | Universe evidence owner | `SRC-MAIN-STORE`; optional expiry in the observation receipt | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].candidate_id` | Universe evidence owner | `SRC-MAIN-STORE`, bound to candidate | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].artifact_identity[<bounded-key>]` | Universe evidence owner | `SRC-MAIN-STORE`, bound to candidate | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `observations[].context_identity[<bounded-key>]` | Universe evidence owner | `SRC-MAIN-STORE`, bound to candidate | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `provenance.producer_ref` | Universe provenance owner | `SRC-P1-RECEIPT`; absent in P0 and `REP-Q-01`-bound | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `provenance.created_at` | Universe provenance owner | `SRC-P1-RECEIPT` | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `provenance.source_ref` | Universe provenance owner | `SRC-P1-RECEIPT` and pointer grammar below | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `provenance.content_digest` | Universe provenance owner | `SRC-P1-RECEIPT`; optional upstream field, required by this Profile for current-proof | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `as_of` evaluator input | Evaluator execution owner | Exact `--as-of` invocation in `SRC-P0-RECEIPT` or `SRC-P1-RECEIPT`; never an Envelope field | `P-Evidence` | `R-Arch/Quality` | `D-Main-App` | none |
| `delivery.observed_at` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT` | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.candidate_id` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT` | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.artifact_identity[<bounded-key>]` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT` | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.context_identity[<bounded-key>]` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT` | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.profile_ref` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT` | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.local_head` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT`; final head pending `REP-Q-01` | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.published_head` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT`; final head pending `REP-Q-01` | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.hosted_ci_run_ref` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT`; hosted provenance pending revalidation | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.hosted_ci_head` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT`; hosted provenance pending revalidation | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.hosted_ci_result` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT` | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.pr_state` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT` | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.comparison_basis` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT` | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `delivery.relation` | Universe delivery owner | P-01 receipt at `SRC-P1-RECEIPT` | `P-Delivery` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.observed_at` | Universe final-validation owner | D-01 receipt at `SRC-P1-RECEIPT` | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.candidate_id` | Universe final-validation owner | D-01 receipt at `SRC-P1-RECEIPT` | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.artifact_identity[<bounded-key>]` | Universe final-validation owner | D-01 receipt at `SRC-P1-RECEIPT` | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.context_identity[<bounded-key>]` | Universe final-validation owner | D-01 receipt at `SRC-P1-RECEIPT` | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.profile_ref` | Universe final-validation owner | D-01 receipt at `SRC-P1-RECEIPT` | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.final_tree_digest` | Universe final-validation owner | D-01 receipt at `SRC-P1-RECEIPT`, compared with candidate identity | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.checker_ref` | Universe final-validation owner | D-01 receipt and bounded pointer grammar below | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.checker_version` | Universe final-validation owner | D-01 receipt at `SRC-P1-RECEIPT` | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.scope` | Universe final-validation owner | D-01 receipt at `SRC-P1-RECEIPT`; bounded token, not narrative dump | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.comparison_baseline` | Universe final-validation owner | D-01 receipt and bounded pointer grammar below | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.exit_code` | Universe final-validation owner | D-01 receipt at `SRC-P1-RECEIPT` | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.result` | Universe final-validation owner | D-01 receipt at `SRC-P1-RECEIPT` | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `final_validation.output_ref` | Universe final-validation owner | D-01 receipt and bounded pointer grammar below | `P-Validation` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.source_stage` | Universe promotion owner | This Profile and `SRC-ASSIGNMENT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.target_stage` | Universe promotion owner | This Profile and `SRC-ASSIGNMENT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.target_sequence` | Universe promotion owner | This Profile and `SRC-ASSIGNMENT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.target_binding.candidate_id` | Universe promotion owner | New promotion record at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.target_binding.artifact_identity[<bounded-key>]` | Universe promotion owner | New promotion record at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.target_binding.context_identity[<bounded-key>]` | Universe promotion owner | New promotion record at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.target_binding.profile_ref` | Universe promotion owner | New promotion record at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.target_binding.contract_version.major` | Universe promotion owner | New promotion record at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.target_binding.contract_version.minor` | Universe promotion owner | New promotion record at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.baseline.verification_ref` | Universe promotion owner | First-target baseline receipt at `SRC-P1-RECEIPT` and pointer grammar below | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.baseline.reason` | Universe promotion owner | First-target baseline receipt at `SRC-P1-RECEIPT`; bounded token, not free-form log | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.baseline.candidate_id` | Universe promotion owner | First-target baseline receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.baseline.artifact_identity[<bounded-key>]` | Universe promotion owner | First-target baseline receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.baseline.context_identity[<bounded-key>]` | Universe promotion owner | First-target baseline receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.baseline.source_stage` | Universe promotion owner | First-target baseline receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.baseline.target_stage` | Universe promotion owner | First-target baseline receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.baseline.profile_ref` | Universe promotion owner | First-target baseline receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.baseline.contract_version.major` | Universe promotion owner | First-target baseline receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.baseline.contract_version.minor` | Universe promotion owner | First-target baseline receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.previous_target_receipt.receipt_ref` | Universe promotion owner | Subsequent-target receipt at `SRC-P1-RECEIPT` and pointer grammar below | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.previous_target_receipt.candidate_id` | Universe promotion owner | Subsequent-target receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.previous_target_receipt.artifact_identity[<bounded-key>]` | Universe promotion owner | Subsequent-target receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.previous_target_receipt.context_identity[<bounded-key>]` | Universe promotion owner | Subsequent-target receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.previous_target_receipt.source_stage` | Universe promotion owner | Subsequent-target receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.previous_target_receipt.target_stage` | Universe promotion owner | Subsequent-target receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.previous_target_receipt.profile_ref` | Universe promotion owner | Subsequent-target receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.previous_target_receipt.contract_version.major` | Universe promotion owner | Subsequent-target receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
| `promotion.previous_target_receipt.contract_version.minor` | Universe promotion owner | Subsequent-target receipt at `SRC-P1-RECEIPT` | `P-Promotion` | `R-Arch/Quality` | `D-Main-App` | `H-Product/Release` decision only |
This map deliberately distinguishes candidate identity production from P-01/D-01
validation: those receipts validate candidate facts but do not become their owner. The
Main-App store, diagnostics presentation and `SRC-MAIN-PROMOTION` inputs remain project
boundaries; KOS Kit is not a second storage authority.

Evaluator output is explicitly excluded from the portable Envelope owner map. It is a
derived, non-authoritative result owned by the evaluator execution boundary and may be
mirrored by `D-Main-App` only after binding the exact Envelope and `as_of` receipt. It
cannot become a project fact, a Source of Truth or a Product/Quality/Release decision.

## Explicit KOS v0.8.0 opt-in

| Contract | Selection | Effective boundary |
|---|---|---|
| E-01 claim-bound observation | Adopted | New release-evidence observations only; content-free fields and bounded references |
| P-01 publication facts | Adopted | Future publication handoffs only; no same-head claim without all required heads and hosted result |
| D-01 final-documentation receipt | Adopted | Future final-validation receipts only; final content changes invalidate the receipt |
| A-01 / B-01 | Not applicable in P0/P1 | External action authorization remains a separate human-owned boundary |
| `required` mode | Not adopted | Advisory structural/semantic checks never create permission |

## Content allowlist and exclusions

### Allowed

- Opaque candidate, artifact, input, context, environment, claim and coverage IDs.
- Build/version/digest metadata and bounded provenance heads.
- Outcome, observation time, `valid_until`, declared `max_age_days`, the external
  evaluation-clock reference and derived freshness/comparison state.
- Evidence references, checker/version/scope, exit code, result and bounded output
  references.
- Promotion target sequence, baseline identity and previous-receipt identity.

### Forbidden

- Raw keyboard text, candidate text, host text, clipboard, user dictionary contents or
  unrelated user data.
- Credentials, tokens, secrets, full diagnostic-log payloads or unbounded filesystem dumps.
- Synchronous Keyboard Extension file I/O, runtime network calls or a new App Group
  ownership contract for this evidence.

The allowlist is a privacy and hot-path boundary, not evidence that the runtime has
already been implemented or device-validated. It is grounded in the project
[`Privacy Policy`](../PRIVACY_POLICY.md#L55),
[`Performance Baseline`](../PERFORMANCE_BASELINE.md#L32) and
[`ADR 0027`](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md#L13).

### Bounded reference grammar and lifecycle

Every pointer-bearing field listed in the owner map uses exactly one of these forms;
`sha256` is mandatory, not conditional:

```text
repo://<repo-relative-path>#<anchor>;sha256=<64-lower-hex>;class=<retention-class>
appdiag://release-evidence/<record-id>/<operation-uuid>;sha256=<64-lower-hex>;class=<retention-class>
opaque://<namespace>/<identifier>;sha256=<64-lower-hex>;class=<retention-class>
```

`<retention-class>` is one of `release-candidate`, `diagnostic-short` or
`review-record`. Repository paths must stay within the repository and use canonical
relative segments: no absolute path, empty segment, `.` or `..`. App-Diagnostics
operation identifiers must be canonical UUID strings; they remain opaque local
record/event pointers and are not dereferenced by the adapter. A missing target, digest
mismatch, expired class or inaccessible redacted export is an unresolved blocker. The pinned
`UNKNOWN` exception remains available only where the upstream contract explicitly allows
it for `not-run`.

`comparison_basis`, `scope`, `reason`, `checker_version`, stage names and `pr_state` are
bounded opaque tokens, not narrative fields: UTF-8, non-empty, at most 1024 characters,
with raw user content and log fragments forbidden. Human explanation belongs in the
bounded review receipt outside the Envelope. This closes the otherwise free-form
boundary for `source_ref`, `comparison_basis`, `scope`, baseline/history reasons,
checker references and output references without changing the upstream schema.

The release-evidence owner is the write and deletion owner. Architecture/Quality
reviewers receive only a bounded redacted export; Human Product/Release authority sees
receipt facts, not raw logs. `release-candidate` records support publication review,
`diagnostic-short` records support bounded diagnosis, and `review-record` records retain
the independent review artifact. There is no implicit indefinite retention. The same
evidence owner records the retention decision and owns deletion when the class expires.
P0 defines this lifecycle only; it does not authorize deletion, runtime persistence or a
new Main-App storage implementation.

## Evaluation clock and freshness boundary

`as_of` is the reference evaluator's external `--as-of` input. It is recorded in the
executor's validation receipt or invocation context and is not an `Envelope` field, an
observation field or a replacement for `observed_at`. `observed_at` is the time of the
observation; `freshness.valid_until`, when present, is the observation's expiry. The
adopter retains the exact timezone-bearing `as_of` value and validator identity for each
derived classification. `policy.max_age_days` is a required Envelope policy input
selected for the exact handoff; if it is absent or invalid, evaluation fails rather than
selecting a project-wide default.

## Pinned evaluator derived-state matrix

The following precedence is copied as a project contract from the pinned evaluator; it
is not a prose shortcut. P1 must add executable fixtures for every row before claiming
implementation readiness. P0 records the deterministic matrix but does not claim that an
Envelope has been evaluated.

### Precedence

For a structurally valid Envelope, the evaluator applies this order:

1. If `validate_payload` or the external `as_of` parser fails, exit with invalid input
   and emit no derived classification.
2. If promotion is present and its target binding is absent, emit `pending`.
3. If promotion is present, its target is bound, and promotion reasons remain, emit
   `none`.
4. Otherwise emit `current-proof` only if every required claim is `pass`, candidate
   bindings are resolved, delivery/final-validation/provenance are current and valid,
   and no promotion blocker remains.
5. Otherwise, if candidate bindings are unresolved, emit `none`.
6. Otherwise, if every required claim is `non-comparable`, emit `comparator`.
7. Otherwise emit `none`.

| Deterministic input condition | Claim state | Derived result | Exact boundary |
|---|---|---|---|
| Invalid JSON/schema/unknown key, invalid policy, unparseable or timezone-less timestamp, or invalid `as_of` | No claim state | Evaluator rejects input; no classification | Never relabel as `stale`, `blocked`, `none` or `pending` |
| Promotion target is absent/unbound, even when baseline/history or evidence also has blockers | Any | `pending` | Promotion pending has precedence; reasons retain visible baseline/history blockers |
| Promotion target is bound but baseline/history rule, target binding, or stage rule fails | Any | `none` | Bound-target failure is not `pending` |
| Current-candidate observation is newer than `as_of` | `blocked` | Usually `none` | Future observation cannot support proof |
| Current-candidate observation exceeds `max_age_days` or is past `valid_until` | `stale` | `none` unless a higher-priority promotion state applies | Parsed freshness failure is not invalid input |
| Every required claim is current, fresh, comparable `pass`; delivery/final-validation/provenance all current | All `pass` | `current-proof` | Still not Product/Quality/Gate/Release acceptance; the current adapter source gate blocks this until `REP-Q-01` closes |
| Every required claim is `non-comparable`, including when an unrelated delivery fact is `ahead` or otherwise non-current | All `non-comparable` | `comparator` | This result is possible only when no higher-priority promotion result or candidate-resolution failure applies |
| Some claims are `non-comparable` but another is `missing`, `stale`, `blocked` or `pass` | Mixed | `none` | Partial mismatch is not an overall comparator |

## Promotion profile and daily Beta → external candidate reuse

The adopter uses one explicit promotion mapping for this workflow:

| Field | Required value / rule |
|---|---|
| `promotion.source_stage` | `daily_beta` |
| `promotion.target_stage` | `external_candidate` |
| `promotion.target_sequence` | Exactly `first` or `subsequent`; never inferred from upload time or file names |
| `policy.require_baseline_for_first_target` | `true` |
| `policy.require_previous_target_for_subsequent` | `true` |
| `policy.previous_receipt_identity_keys` | Exactly `["release_lineage"]`; the key is resolved in both artifact identity maps for a subsequent receipt |
| First target | `target_binding` matches the current candidate; `baseline` is an explicit current-candidate-bound `review-record` receipt object; `previous_target_receipt` is exactly `null` |
| Subsequent target | `target_binding` matches the current candidate; `baseline` is exactly `null`; `previous_target_receipt` is required, references a different candidate and matches stage/context/Profile/contract/history bindings |

Daily Beta evidence may be reused for a formal external candidate only when the same
record proves all of the following:

1. Candidate, artifact/input, context, environment and Profile identities match exactly.
2. The observation is fresh under the external `as_of`, `max_age_days` and
   `valid_until` policy.
3. Claim, coverage and comparison basis match the external target; comparable negative or
   conflicting evidence blocks current proof.
4. Delivery facts and final validation cover the same candidate and final tree.
5. First-target baseline or subsequent-target history requirements are satisfied. A
   first-target baseline is supplied as an explicit receipt object; a Boolean presence
   flag is rejected and the adapter never synthesizes its verification pointer.

These identity and receipt checks do not close the Main-App source trust root. While
`REP-Q-01` is unresolved, the adapter's code-controlled source-binding gate keeps
adapter-generated pass observations at `inconclusive`; therefore no Main-App-derived
Envelope can produce `current-proof` until a separately reviewed package enables the
owner-attested binding.

If any binding is absent, unknown, stale or mismatched, Beta evidence remains
`comparator`, `pending` or `none` according to the precedence matrix. It may inform
diagnosis, but it cannot be silently promoted to an external-candidate proof or a Release
decision.

### Exact P-01 / D-01 closure conditions

The adopter does not reduce the optional contracts to a Boolean flag:

- P-01 is current only when the delivery receipt is fresh and candidate-bound,
  `relation=same-head`, `hosted_ci_result=pass`, the comparison basis equals the
  candidate basis, and `local_head == published_head == hosted_ci_head == candidate_head`.
  A missing/unknown head, `ahead`, `divergent`, `unknown` relation or non-pass hosted
  result is a blocker.
- D-01 is current only when the final-validation receipt is fresh and candidate-bound,
  `final_tree_digest == candidate.final_tree_digest`, checker reference/version, scope,
  comparison baseline and output reference are resolved, `result=pass` and
  `exit_code=0`. A changed final tree requires a new receipt; a successful generic
  `git diff` is not a substitute for the declared checker/scope/output.

## Retention and migration

- New records opt in prospectively and retain the existing project evidence pointer
  discipline; the Profile does not require a runtime service or network endpoint.
- Existing Active Assignments and historical Build evidence remain under their original
  Source of Truth. No bulk backfill or schema rewrite is authorized.
- A materially changed old Assignment requires its own review of whether to opt in; it
  does not inherit this Profile merely because the Profile exists.

## P0 handoff and next stage

This Profile began as the P0 artifact for
[`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001`](../assignments/kos-release-evidence-implementation-001.md).
The P0 handoff remains historical and closed. The child P1-A slice now implements the
adapter, stable pointer mapping and focused contract fixtures described above. P1 still
cannot claim publication readiness until `REP-Q-01`, final SHA/base-head provenance and
any hosted tag/Release revalidation are closed; its evaluator output remains derived
contract evidence rather than Product, Quality, Gate or Release acceptance.
