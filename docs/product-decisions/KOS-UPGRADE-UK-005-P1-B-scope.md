# Product Decision: KOS-UPGRADE-UK-005-P1-B-SCOPE — Adopt Option A

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-KOS-UPGRADE-UK-005-P1-B-SCOPE",
  "record_type": "decision",
  "title": "Disposition UK-005 P1-B after the release-evidence implementation",
  "status": "accepted",
  "updated_at": "2026-09-15T10:44:38+08:00",
  "revalidation_triggers": [
    "scope_changed",
    "main_app_diagnostics_scope_changed",
    "privacy_owner_changed",
    "app_group_owner_changed",
    "migration_requested",
    "background_sync_requested"
  ],
  "decision": {
    "authority_role": "Human Product Owner / Product Lead",
    "decision_source": "Current Codex task, Human Product Owner approval of Option A, 2026-09-15 Asia/Shanghai",
    "scope": "Disposition UK-005 P1-B residuals after the separate RELEASE-EVIDENCE-PROMOTION-001 implementation",
    "outcome": "Duplicate Main-App release-evidence UI/storage work is Not applicable for the current objective; historical migration/backfill and background sync remain Deferred and unauthorized; no new P1-B implementation Assignment is created",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Decision | Option A adopted: no duplicate P1-B implementation; migration/backfill and background sync remain Deferred |
| Non-claims | No new runtime change, migration, network sync, Product/Quality/Release Gate, TestFlight, App Store Connect, commit, push, merge or Release authorization |
| Next handoff / decision | No P1-B implementation handoff under Option A; reopen only if Product Lead records a new bounded residual scope that supersedes this decision |

## Authority

- Product Approver / Decision maker: Human Product Owner acting as Product Lead.
- Decision source / date: current task instruction to adopt Option A, `2026-09-15 Asia/Shanghai`.
- This decision is the Product source for the UK-005 P1-B disposition. It does not
  alter the separate P1-A implementation decision, its `REP-Q-01` or hosted-provenance
  residuals, or the `RELEASE-EVIDENCE-PROMOTION-001` Assignment.

## Decision

The current release-process objective is to keep daily Beta evidence and the formal
external-candidate handoff inspectable in the Main App while avoiding unnecessary
full rehearsals. That objective is already served by the separately bounded
`RELEASE-EVIDENCE-PROMOTION-001` implementation, including its Main-App content-free
evidence page, bounded App Group store, structured sharing path and explicit separation
from ordinary diagnostic-log clearing. PR [#128](https://github.com/shchnk1103/Universe-Keyboard/pull/128)
merged that implementation into `main` at `1a405143` after its hosted checks passed.

Therefore Product adopts the following disposition for UK-005 P1-B:

1. **Duplicate Main-App UI/storage work — `Not applicable`.** Do not create another
   diagnostics page, release-evidence store, retention/clear path or export path for
   the same current objective. The existing implementation remains owned by
   `RELEASE-EVIDENCE-PROMOTION-001`; its state is not transferred into the UK-005
   Assignment lifecycle.
2. **Historical migration/backfill — `Deferred`.** Do not rewrite, migrate or
   backfill existing Active Assignments or historical Build evidence. A future request
   must name the exact record cohort, data contract, rollback and stop conditions.
3. **Background sync/network — `Deferred` and `Not authorized`.** Do not add a
   background task, credentials, upload or runtime network dependency. A future request
   must define Product, privacy, architecture, failure and Release ownership separately.
4. **No new P1-B Assignment.** The current decision closes the need for a duplicate
   implementation slice. A new bounded Assignment is required only if Product later
   supersedes this decision with a precise residual scope.

## Evidence and boundary

- Existing implementation input: `RELEASE-EVIDENCE-PROMOTION-001`, candidate
  `ad39f443b7f77d96c28359bd652356a89bb173de`, hosted Swift 6 Quality run
  `34865917284`, and merge commit `1a405143` for PR #128.
- Post-merge status reconciliation is recorded in [PR #129](https://github.com/shchnk1103/Universe-Keyboard/pull/129)
  and is an input to scope reconciliation, not an automatic transfer of UK-005 lifecycle
  or review evidence.
- ADR 0027 is unchanged. This decision does not expand the diagnostic journal,
  change App Group ownership, add Keyboard Extension I/O, or introduce runtime network
  access. Any future change to those boundaries requires fresh Architecture review.
- The separate UK-005 P1-A `REP-Q-01` and hosted-provenance residuals remain open;
  this Product Decision does not close them and does not create current-proof,
  publication, Product Gate or Release evidence.

## Non-goals

- No Swift, Main-App, Keyboard Extension, App Group or diagnostic-journal change.
- No historical migration/backfill, background sync, credentials, upload or network.
- No change to the adopted `v0.8.0` advisory pin, `required` mode, ADR 0035 or CI
  classification.
- No Product/Quality/Release Gate, TestFlight, App Store Connect, merge, commit, push,
  tag or Release authorization.

## Handoff and revalidation

The Executor may synchronize the affected KOS mirrors in the isolated documentation
worktree. This does not authorize publication or external GitHub actions. Reopen this
decision only when Product specifies a new residual behavior, data cohort, file
allowlist or network/privacy boundary; then create a new Assignment and matching
Authorization before implementation.
