# Authorization: AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1 — P1-A implementation

## Current Status

| Field | Value |
|---|---|
| Status | active |
| Consumption | Consumed for the authorized P1-A implementation and local validation; exact-digest independent exit review remains open. Applies only to the child Assignment and does not authorize P1-B, publication or GitHub actions. |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1",
  "record_type": "authorization",
  "title": "Authorize P1-A delta-aware release-evidence implementation for new records",
  "status": "active",
    "updated_at": "2026-09-14T21:27:20+08:00",
  "revalidation_triggers": [
    "scope_changed",
    "upstream_candidate_changed",
    "contract_schema_or_evaluator_changed",
    "owner_or_source_identity_changed",
    "required_mode_requested",
    "rep_q_01_finalized",
    "publication_boundary_changed",
    "privacy_owner_changed",
    "main_app_diagnostics_scope_changed"
  ],
  "parent_refs": [
    "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001",
    "PD-KOS-UPGRADE-UK-005-RELEASE-EVIDENCE",
    "PD-KOS-UPGRADE-UK-005-P1-A-SCOPE"
  ],
  "authorization": {
    "action": "implement_release_evidence_adopter_p1",
    "target": "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1",
    "artifact_bindings": [],
    "scope": "P1-A new-record adapter/profile integration, existing Main-App release-evidence source seam reconciliation, pinned schema/evaluator fixtures, delta-aware focused validation and independent review receipt",
    "exclusions": [
      "Main-App Diagnostics UI or new release-evidence storage feature (P1-B)",
      "change to ADR 0027 ownership, retention, clear behavior or App Group boundary",
      "historical migration, backfill or reinterpretation of existing records",
      "Keyboard Extension synchronous I/O, runtime network or background upload",
      "schema/evaluator/candidate pin changes without Product revalidation",
      "archive/export, App Store Connect, TestFlight, Beta Review submission or Release",
      "Product Gate, Quality Gate, Release Pass or current-proof conclusion from validation alone",
      "commit, push, merge, tag, branch deletion or external GitHub action",
      "KOS required mode or bulk legacy Envelope migration"
    ],
    "issuer_role": "Human Product Owner",
    "decision_source": "PD-KOS-UPGRADE-UK-005-P1-A-SCOPE",
    "issued_at": "2026-09-14T19:13:06+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

## Authorization outcome

This Authorization is a new, independent P1-A permission. It does not widen
[`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001`](AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001.md),
which remains the historical P0 contract/Profile handoff Authorization.

The approved executor may implement and locally validate only the P1-A slice described
below, in the isolated worktree and task Assignment
[`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](../assignments/kos-release-evidence-implementation-001-p1.md).

## Authorized actions

1. Implement a content-free project adapter for new `kos.release-evidence` records,
   using the exact P0 Profile and candidate contract pins.
2. Reconcile and prepare that adapter's binding to the existing Main-App release-evidence
   source owner identified by `SRC-MAIN-STORE`/ADR 0027. Until `REP-Q-01` is closed with
   an exact implementation identity, this is only a source seam and cannot be called a
   completed binding or current proof. This is source consumption and identity binding
   only; it is not permission to create a competing store or modify the existing storage
   contract.
3. Add and run bounded fixtures for the pinned schema/evaluator, with explicit
   `--as-of`, including invalid, pending, none, comparator, current-proof,
   first-target and subsequent-target paths.
4. Add and run P-01/D-01 contract fixtures, privacy-safe pointer checks, and the
   delta-aware focused validation rules that rerun touched claims and reuse only
   unchanged, identity-bound, fresh daily-Beta evidence.
5. Validate that daily-Beta evidence can be carried into an external-candidate record
   when its bindings pass, while retaining separate delivery, Beta Review,
   Product/Release and hosted-provenance gates.
6. Produce the P1 implementation receipt and request independent Architecture and
   Quality review against its exact package digest.

The release-evidence validation profile and the repository CI change tier are independent.
A release `delta` may narrow only the release-evidence fixture/reuse set. It must not
downgrade an existing CI `full` classification: only the repository CI classifier may
classify a change as `docs_only`; Swift, source, test, project, workflow, tooling and
unknown paths remain `full` and retain the Swift hard gate and applicable CI-equivalent
checks.

If the authorized implementation later touches Swift, the repository's Swift formatting
hard gate and the applicable local CI-equivalent quality gates must pass before any
commit or push request. This Authorization does not itself authorize either action.

## Explicitly not authorized: P1-B

This Authorization does not authorize:

- a new Main-App Diagnostics UI or user-facing release-evidence view;
- new or changed persistence at `Diagnostics/v1/release-evidence/records.json`;
- retention, clear, export, migration, background sync or App Group ownership changes;
- any implementation that would be justified only by “减少去别的工具读取” without
  a separate Product scope, file allowlist and ADR 0027 review.

Those actions remain a valid follow-on proposal and require a separate P1-B Assignment
and Authorization. P1-A may report the exact source/display integration seam needed by
that follow-on, but must stop before implementing it.

## Evidence boundary

- The P0 Profile is the contract boundary; the pinned schema/evaluator are the semantic
  sources; the Main-App owner remains the fact source.
- `as_of` is an evaluator invocation input, not a portable Envelope field.
- A reused daily-Beta observation is valid only when candidate identity, artifact/context,
  source, coverage, comparison basis and freshness remain bound. A touched binding
  invalidates the narrow reuse path.
- An external candidate may reuse daily-Beta claim history, but this does not prove
  external delivery, Beta Review, hosted CI, Product Gate or Release readiness.
- `REP-Q-01` and hosted provenance remain open until independently bound; no current-proof
  or publication claim may be made from this Authorization alone.

## Human authority boundary

The issuer retains authority for Product scope, acceptance and any later P1-B decision.
The Executor may not infer:

- a final candidate SHA or hosted relation from an uncommitted worktree;
- a Product/Quality/Release decision from a green fixture or validator;
- permission to upload, submit, publish, merge or release;
- permission to change the adopted contract, `required` mode or the Main-App owner.

## Revalidation and consumption

Revalidate this Authorization before implementation exit if any trigger in the envelope
occurs, or if a focused test reveals that P1-A needs P1-B. The authorization record is
`active` with `consumption_state` `consumed`: the authorized P1-A implementation and local
validation have started, while the exact-digest independent exit review and residual
publication prerequisites remain open.
