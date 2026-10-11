# Assignment: TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001 — Controller/sidecar residual hardening

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001",
  "record_type": "assignment",
  "title": "Controller and sidecar runtime-integration residual hardening",
  "lifecycle": "active",
  "current_phase": "Independent Architecture review returned Blocker; new bounded remediation or explicit Product residual disposition is required before Quality review",
  "authorization_action": "remediate_bounded_controller_sidecar_runtime_integration_residuals",
  "updated_at": "2026-09-22T09:44:00+08:00",
  "revalidation_triggers": [
    "source_snapshot_or_checkpoint_identity_changed",
    "accepted_residual_or_allowed_path_changed",
    "adapter_owner_or_recall_lifecycle_changed",
    "test_scope_or_result_changed",
    "runtime_capture_or_publication_requested",
    "authority_revoked"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-EXECUTOR-REASSIGNMENT-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-ARCHITECTURE-001"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002",
    "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001",
    "PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Current Codex task",
    "environment_executor": "Current Codex task, new isolated local worktree and local test toolchain only; no device or RIME environment operation",
    "human_dependency": "Not Applicable — this Assignment is active from the current Human Product Owner authorization; Codex must still verify the pinned source identity before consuming its receipt",
    "architecture_reviewer": "Independent Architecture and Knowledge Steward",
    "quality_reviewer": "Independent Quality, Performance and Release Maintainer",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | Codex hardening has an independently reproduced identity, but Architecture returned `Blocker`. New bounded remediation or an explicit Product residual disposition is required before Quality review. |
| **Non-claims** | No runtime capture, real RIME result, QA-001, INT-003, paired performance, commit, push, PR, merge, Gate, Release or Assignment Close. |
| **Next** | Product Lead must choose a new bounded remediation slice or explicitly accept the three Architecture blockers. Quality review is not authorized. |
| **Residuals** | F-01 canary/P3D1 order and yielded-callback ownership, F-03 fallback unique-writer proof, and three-route adapter/no-bypass proof are `fix` unless Product accepts them. F-04 remains `tech_debt`; product outcomes remain `UNKNOWN`. |

---

## Authority

- **Assignment Authority:** Human Product Owner / Product Lead.
- **Decision Source / Date:** current task instruction `授权按照你的建议继续进行下一步`, `2026-09-22 Asia/Shanghai`.
- **Product Approver:** Human Product Owner / Product Lead.
- **Parent Assignment:** [`TYPO-CORRECTION-002`](typo-correction-002.md).
- **Predecessor:** [`runtime-integration implementation`](typo-correction-002-runtime-integration-implementation-001.md) (`Reviewed`; bounded residuals accepted, not published).
- **Residual decision:** [`PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001.md).
- **Superseded Grok Authorization:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001.md) (`superseded` / `unconsumed`; never consumed).
- **Executor reassignment:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-EXECUTOR-REASSIGNMENT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-EXECUTOR-REASSIGNMENT-001.md) (`consumed`; docs-only).
- **Execution Authorization:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001.md) (`consumed`; Current Codex task only).
- **F-01 entrypoint supplement:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001.md) (`consumed`; single additional UI entrypoint path only).
- **Test-only dependency receipt:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001.md) (`consumed`; ignored local Vendor link only).
- **Executor handoff:** [`Grok → Codex runtime-integration handoff`](../evidence/typo-correction-002-grok-to-codex-runtime-integration-handoff-2026-09-21.md).

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | This lane has no device or product-observation claim. |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment is the next source-changing slice; the exact input snapshot and Grok-only execution receipt are pinned. |
| P-01 publication facts | Not applicable | Commit, push, PR and merge are excluded. |
| D-01 final-documentation receipt | Not applicable | Independent reviews, not final documentation closure, are the required handoff. |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Prior implementation | Consumed | Frozen uncommitted controller/sidecar snapshot | [`implementation AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md) |
| Superseded hardening | Superseded | Grok-only receipt remained unconsumed | [`Grok AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001.md) |
| Current hardening | Consumed | Codex-only residual remediation after identity verification | [`Codex AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001.md) |
| F-01 entrypoint supplement | Consumed | One discovered UI entrypoint file; invalidate before existing page/mode actions | [`F-01 supplement`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001.md) |
| Local test environment | Consumed | Ignored link to the preserved, already verified Vendor only for xcodebuild resolution | [`test dependency AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001.md) |
| Independent Architecture review | Consumed / Blocker | [`Architecture review`](../reviews/typo-correction-002-runtime-integration-hardening-architecture-review-2026-09-22.md) identifies three source-level blockers | Remediation or Product residual decision required |
| Independent Quality review | Blocked | Review/re-run only a newly Architecture-acceptable snapshot | New Authorization required after blocker disposition |
| Publication or product evidence | Not authorized | Commit/push/PR/merge and real-RIME/QA/performance are separate future decisions | Product decision required |

## Scope

Current Codex task may only perform the following in a **new** isolated hardening worktree:

1. Resolve the `#ActorIsolatedCall` warning in
   `TypoCorrectionRecallCoordinator.swift` without weakening Swift concurrency
   diagnostics.
2. Make empty and budget-stop recall outcomes structural display no-ops:
   no candidate-bar refresh and no observable display mutation merely because
   the result set is empty.
3. Apply invalidate-first `recallEpoch` behavior at the named page toggle,
   canary/P3D1 install and empty-composition mode-toggle entry points.
4. Prevent the legacy hot path from independently writing
   `state.typoCorrection` while the controller-owned recall operation is
   current.
5. Add focused tests for those four contracts. Existing adapter-route tests
   may be strengthened only where the lifecycle change needs no-bypass proof;
   no adapter redesign is in scope.

## Non-goals

- Do not modify the preserved implementation worktree at
  `/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001`.
- Do not modify the original pure-Core checkpoint at
  `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard`.
- Do not change first-stage `12/8`, make `60/64` always-on, add a second
  composition/commit/RIME session/query lane, or change diagnostic retention.
- Do not use `FakeCandidateProvider`, old Ice content, host text, clipboard,
  a model or network substitute as real-RIME evidence.
- Do not run a Simulator/device capture, deploy RIME, issue a Run ID, retry
  same-package same-phrase QA-001, run INT-003 or claim paired performance.
- Do not commit, push, open a PR, merge, TestFlight, Release, close a Gate or
  close this or the parent Assignment.

## Required Inputs

- source snapshot: HEAD `4d1050f4b677494e06448cb40a83ef2da46d7b27`, tree
  `5f864a6f6f139810ed59c7e00ab6c33caad7e500`, tracked diff SHA-256
  `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b`;
- independent changed-file manifest SHA-256
  `4b701835f070e2c337fd2d3b76b67813e7e5722bdaa7db1b82faa7e00d2c891e`;
- preserved pure-Core checkpoint diff SHA-256
  `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab`;
- the predecessor Architecture Conditional Accept and Quality Pass with
  conditions, plus the accepted residual Product Decision;
- the Grok handoff listed above and the existing controller/RimeBridge
  ownership, marked-text and privacy contracts.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer.
- **Executor:** Current Codex task.
- **Environment Executor:** Current Codex task — isolated local worktree and local test
  toolchain only; no device, deployment or capture operation.
- **Human Dependency:** Not Applicable — current Product authorization created
  the active receipt; identity verification remains Codex's Entry Criterion.
- **Architecture Reviewer:** Independent Architecture & Knowledge Steward.
- **Quality Reviewer:** Independent Quality, Performance & Release Maintainer.
- **Product Approver:** Human Product Owner / Product Lead.
- **Handoff Target:** independent Architecture review, then independent Quality
  review, then Product Lead.

## Gates

### Entry Criteria

- The Codex hardening Authorization is `consumed` by the named Codex consumer.
- All five pinned source identities match before the copy.
- The two preservation worktrees remain unchanged.
- A separate hardening worktree can be created without reusing or cleaning any
  preserved worktree.
- No source path outside the Authorization allow-list is needed.

### Exit Criteria

- Execution evidence records the verified input identities, source-copy method,
  changed-file inventory and preservation-worktree checks.
- Every changed Swift file passes strict `swift-format` lint.
- Focused negative tests prove the four scoped contracts; path-required
  KeyboardCore, RimeBridge and App+Keyboard checks report actual results.
- Q-01's strict-concurrency warning outcome is explicit, not inferred from a
  successful local test process.
- Independent Architecture can review the exact resulting snapshot. This
  Assignment does not itself close that review or quality lane.

### Stop Conditions

- Source or preservation-worktree identity changes or cannot be verified.
- A required fix needs an unlisted path, weakens concurrency checks, or creates
  another input/commit/query path.
- Real RIME, capture, QA-001, INT-003, performance, publication or a Gate
  conclusion becomes necessary.
- A test failure reveals a residual beyond this bounded scope.

### Revalidation Trigger

Any source identity, accepted residual, allowed path, ownership boundary,
verification result, executor identity or Product authority change.

## Handoff

- **Required Handoff Content:** new worktree path; verified bindings before the
  copy; preservation-worktree proof; changed-file manifest; each residual's
  concrete disposition; format/test results; remaining residuals; and explicit
  non-claims.
- **Handoff Target:** Independent Architecture review → Independent Quality
  review → Human Product Owner / Product Lead.
