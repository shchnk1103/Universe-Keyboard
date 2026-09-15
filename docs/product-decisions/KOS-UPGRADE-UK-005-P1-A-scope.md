# Product Decision: KOS-UPGRADE-UK-005-P1-A-SCOPE — Approve the P1-A implementation slice

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-KOS-UPGRADE-UK-005-P1-A-SCOPE",
  "record_type": "decision",
  "title": "Approve the P1-A delta-aware release-evidence implementation slice",
  "status": "accepted",
  "updated_at": "2026-09-14T19:13:06+08:00",
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
  "decision": {
    "authority_role": "Human Product Owner / Product Lead",
    "decision_source": "Current task approval of the P1 scope and Authorization, 2026-09-14 Asia/Shanghai",
    "scope": "Approve P1-A implementation for new release-evidence records: project adapter/profile mapping, reconciliation of the existing Main-App source seam, pinned schema/evaluator fixtures, delta-aware focused validation, daily-Beta reuse fixtures and independent review receipt",
    "outcome": "Accepted as a child implementation slice under the prospective kos.release-evidence adoption; P1-B Main-App Diagnostics UI/storage and all publication actions remain separately gated",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Decision | P1-A implementation slice approved; P1-B Diagnostics UI/storage remains separately gated |
| Non-claims | Not Product/Quality/Release acceptance; no current-proof; no upload, TestFlight, App Store Connect, merge, push or Release authorization |

## Authority

- Product Approver / Decision maker: Human Product Owner / Product Lead.
- Assignment Authority: Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- Decision Source / Date: Current task approval of the P1 scope and Authorization,
  `2026-09-14T19:13:06+08:00` Asia/Shanghai.
- Parent Decision: [`PD-KOS-UPGRADE-UK-005-RELEASE-EVIDENCE`](KOS-UPGRADE-UK-005-release-evidence-adoption.md).

## Decision

The P1-A child slice is accepted for implementation under the exact candidate and
project Profile already adopted by the parent Product Decision. It is intended to make
small daily Beta changes evidence-efficient without weakening the engineering quality
classification or release authority model.

### Accepted P1-A scope

- Map **new** release-evidence records through the project adapter and existing Profile.
- Reconcile the existing Main-App release-evidence source seam. Until `REP-Q-01` is
  closed with an exact implementation identity, the seam is not a completed binding and
  no current-proof or publication claim may use it.
- Run pinned schema/evaluator fixtures with explicit `--as-of`, covering both pass and
  fail-closed states, including daily-Beta first/subsequent promotion history and the
  P-01/D-01 contract conditions.
- Implement delta-aware focused validation: rerun evidence affected by a changed claim
  or binding and reuse only unchanged, identity-bound, fresh daily-Beta evidence.
- Preserve the existing CI change classifier as an independent gate. A release-evidence
  delta may reduce only the release-evidence fixture/reuse scope; it never changes a
  source/test/project/workflow/tooling/unknown path from CI `full` to `docs_only`.
- Prove that daily-Beta evidence can feed an `external_candidate` record while keeping
  external delivery, Beta Review, hosted provenance and Product/Release decisions
  separate.

### Explicitly deferred P1-B

This decision does not approve a new Main-App Diagnostics UI, a new release-evidence
store, changes to `Diagnostics/v1/release-evidence/records.json`, retention/clear/export
behavior, migration/backfill, background sync or App Group ownership changes. P1-B needs
its own Product Decision, Assignment, Authorization, file allowlist and ADR 0027 review.

## Boundaries

- The exact `kos-agent-kit v0.8.0` advisory pin and the adopted untagged candidate remain
  unchanged.
- E-01, P-01 and D-01 remain opt-in contracts for new records; `required` remains
  unauthorized.
- No validator, fixture, Architecture review or Quality review is a substitute for
  Product, Release, Beta Review, hosted CI or App Store Connect authority.
- No historical Assignment/evidence migration and no raw user content, credentials,
  full logs, synchronous Extension I/O or runtime network are allowed.

## Handoff

The child execution record is [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](../assignments/kos-release-evidence-implementation-001-p1.md)
and its implementation Authorization is [`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md).
Both must preserve this decision's P1-A/P1-B boundary and exact candidate pins.
