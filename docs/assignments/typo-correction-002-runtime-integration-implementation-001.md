# Assignment: TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001 — Controller/sidecar runtime integration

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001",
  "record_type": "assignment",
  "title": "Controller and sidecar second-stage recall runtime integration",
  "lifecycle": "reviewed",
  "current_phase": "Product accepted bounded residuals of the uncommitted snapshot; publication and Close remain unauthorized",
  "authorization_action": "implement_controller_sidecar_second_stage_recall_runtime",
  "updated_at": "2026-09-21T22:49:47+08:00",
  "revalidation_triggers": [
    "source_or_checkpoint_identity_changed",
    "coverage_predicate_or_budget_changed",
    "adapter_api_or_owner_boundary_changed",
    "allowed_path_or_test_scope_changed",
    "diagnostics_or_privacy_scope_changed",
    "authorization_not_confirmed_live",
    "authority_revoked"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-ARCHITECTURE-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-QUALITY-001",
    "AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-PRODUCT-RESIDUAL-001"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002",
    "TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001",
    "PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001",
    "PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Grok",
    "environment_executor": "Grok for new implementation worktree copy, local Swift format, KeyboardCore, RimeBridgeTests and App+Keyboard tests; no device, RIME deploy or capture",
    "human_dependency": "Human Product Owner confirms AUTH is live before implementation; later independent Architecture and Quality reviews",
    "architecture_reviewer": "Independent Architecture and Knowledge Steward",
    "quality_reviewer": "Independent Quality, Performance and Release Maintainer",
    "product_approver": "Human Product Owner acting as Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Reviewed` |
| **Phase** | Product accepted Architecture Conditional Accept, Quality Pass with conditions, and named bounded residuals of the frozen uncommitted snapshot. |
| **Non-claims** | No Quality/Product/Release Gate, commit, push, PR, merge, capture, QA-001, INT-003, paired performance, parent Close or this Assignment Close. |
| **Next** | Codex receives [`Grok→Codex handoff`](../evidence/typo-correction-002-grok-to-codex-runtime-integration-handoff-2026-09-21.md). Publication and further source work remain separately unauthorized. |
| **Residuals** | Accepted by [`PD residual`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001.md). F-01/F-02/F-03 gaps, Q-01, identity-recipe and F-04 remain named conditions. Real RIME / QA-001 remain `UNKNOWN`. |

---

## Authority

- **Assignment Authority:** Human Product Owner / Product Lead.
- **Decision Source / Date:** [`PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md), `2026-09-21 Asia/Shanghai`.
- **Product Approver:** Human Product Owner / Product Lead.
- **Parent Assignment:** [`TYPO-CORRECTION-002`](typo-correction-002.md).
- **Predecessor:** [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001`](typo-correction-002-runtime-integration-design-001.md) (`Reviewed`, Conditional Accept).
- **Reviewed design:** [`runtime integration design`](../plans/typo-correction-002-runtime-integration-design-2026-09-21.md), SHA-256 `b91e11cf327f9ad3e5974ff0e5b4a53fe755920356927efffed12cfe9c28a848`.
- **Architecture re-review:** [`re-review`](../reviews/typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md).
- **Handoff:** [`Codex to Grok handoff`](../evidence/typo-correction-002-codex-to-grok-runtime-integration-handoff-2026-09-21.md).
- **Matching Authorization:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md).

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | This slice produces implementation and local test evidence, not a human-operated observation claim. |
| A-01 / B-01 authorization chain and briefing | Adopted | Current slice is AUTH-live confirmation then bounded implementation. Next gated slices are independent Architecture review, Quality review, real-RIME Run, QA-001, paired performance and publication. |
| P-01 publication facts | Not applicable | No commit, push, PR or hosted publication. |
| D-01 final-documentation receipt | Not applicable | No final documentation handoff in this slice. |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current authorized slice | Consumed | Bounded implementation snapshot recorded; AUTH consumed | [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md) |
| Architecture review slice | Consumed | Independent Architecture Conditional Accept of the uncommitted snapshot | [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-ARCHITECTURE-001.md) |
| Quality review slice | Consumed | Independent Quality Pass with conditions of the same snapshot | [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-QUALITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-QUALITY-001.md) |
| Next independently gated slice | Not authorized | Product Lead residual decision; publication / Gate / Close remain excluded | New Product Authorization |
| Environment or external slice | Not applicable | No device, RIME deploy, Simulator capture or new Run ID | Product Decision exclusions |

## Boundary

### Scope

After AUTH is confirmed live, Grok may:

1. Create a new implementation worktree from baseline
   `4d1050f4b677494e06448cb40a83ef2da46d7b27` / tree
   `5f864a6f6f139810ed59c7e00ab6c33caad7e500`. Copy the exact uncommitted
   pure-Core snapshot whose diff SHA-256 is
   `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab`. Leave
   the original preflight worktree untouched.
2. Implement one MainActor recall-operation lifecycle owned by
   `KeyboardViewController`: pending debounce, operation token, `recallEpoch`,
   cancellation, yielded one-query turns, fences and candidate-bar refresh.
3. Implement one `TypoCorrectionSidecarOwner` adapter over the already-installed
   query facade for default `RimeEngineImpl`, MainActor-responsive and
   thread-affine routes.
4. Implement stage-one / stage-two in-memory material under one operation
   identity, the pinned coverage-deficit predicate, the pinned 8/8/3/4 budgets,
   and exactly one conditional Core apply that joins, deduplicates, suppresses,
   ranks and writes `state.typoCorrection` once.
5. Add focused KeyboardCore, RimeBridge and App/Keyboard tests proving
   invalidate-first hooks, yielded turns, pre-query and post-return fences,
   adapter no-bypass, display no-op on stale/empty/budget-stop, and the
   coverage-deficit abstain path.
6. Run strict Swift formatting on changed Swift files and the CI-equivalent
   suite required by the actual changed paths. Record implementation evidence
   for independent Architecture review.

### Non-goals

- Do not reset, clean, overwrite or commit the original pure-Core checkpoint.
- Do not change production first-stage `12/8`, and do not make `60/64` the
  always-on first-stage path.
- Do not add an operation receipt, change diagnostic retention, or reuse the
  DEBUG decision trace.
- Do not call `TextInputClient`, `insertText`, `setMarkedText`, pasteboard,
  live RIME candidate selection or direct candidate-bar mutation.
- Do not use `Task.detached`, a second RIME session, a raw-engine cast, a
  parallel query lane, `FakeCandidateProvider`, an old Ice directory, host
  text or a model/network substitute.
- Do not run Simulator/device capture, create a new Run ID, retry QA-001,
  run INT-003, or claim paired performance / `180 ms`.
- Do not commit, push, open a PR, merge, TestFlight, Release, close a Gate or
  close this or the parent Assignment.

### Required Inputs

- Reviewed design SHA-256 `b91e11cf327f9ad3e5974ff0e5b4a53fe755920356927efffed12cfe9c28a848`.
- Architecture re-review Conditional Accept and F-01/F-02/F-03 implementation conditions.
- Exact pure-Core checkpoint identities above, re-verified immediately before the copy.
- [`PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md).
- ADR 0004, ADR 0016, `TYPO_CORRECTION.md`, input-pipeline / marked-text architecture.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer.
- **Executor:** Grok.
- **Environment Executor:** Grok — new implementation worktree copy and local Swift/KeyboardCore/RimeBridge/App+Keyboard toolchain only; no device or RIME environment operations.
- **Human Dependency:** Human Product Owner confirms AUTH is live before implementation starts; later independent Architecture and Quality reviews are separate Human-authorized slices.
- **Architecture Reviewer:** Independent Architecture & Knowledge Steward.
- **Quality Reviewer:** Independent Quality, Performance & Release Maintainer.
- **Product Approver:** Human Product Owner / Product Lead.
- **Handoff Target:** Independent Architecture review of the exact implementation snapshot, then Independent Quality review.

## Pinned contract

### Coverage-deficit predicate

Stage two may start only when all of the following hold:

1. The existing letter / Chinese / minimum-length eligibility still holds.
2. The same recall operation remains current after stage one.
3. Stage one produced zero accepted display-eligible corrections.
4. The structural selector returns at least one group not already accounted
   for by stage one.
5. Remaining started-query-attempt budget is greater than zero.

Otherwise the coordinator abstains from sidecar queries and uses the same
conditional-apply boundary for stage-one material only.

### Budgets

| Budget | Production value for this slice |
|---|---|
| Selected groups | `8` |
| Started query attempts | `8` |
| Per-query candidate limit | `3` |
| Accepted display results | `4` |

These are this lane's runtime caps. They do not change production `12/8`.

### Runtime fences

Preserve the reviewed design contract:

1. `KeyboardViewController` owns one MainActor recall-operation lifecycle.
2. Increment `recallEpoch` before composition mutation, page/mode change,
   visibility teardown, engine rebind/recovery or correction disable.
3. One synchronous sidecar query occupies one scheduler turn. After return,
   schedule at most one later attempt with
   `RunLoop.main.perform(inModes: [.default])`.
4. Fence before each query, after each return, before final Core apply and
   before candidate-bar refresh. Stale, cancelled, empty or budget-stop
   outcomes are display no-ops and must not start a later query.
5. Sidecar results are display-only. Existing user selection through Core
   remains the sole host-commit path.

## Gates

### Entry Criteria

- This Assignment has no `UNKNOWN` field.
- Human Product Owner has confirmed the matching Authorization is live.
- The original pure-Core checkpoint identities still match.
- A new implementation worktree can be created without modifying the original
  checkpoint worktree.

### Exit Criteria

- The copied snapshot identities match before and after the copy.
- Changed Swift files pass `swift-format lint --strict`.
- Focused and path-required KeyboardCore, RimeBridgeTests and App+Keyboard
  tests pass, or failures are retained as failures.
- Evidence names the adapter, fences, material apply, predicate, budgets and
  explicit non-claims.
- Independent Architecture can review the exact snapshot. This Assignment
  does not itself close that review.

### Stop Conditions

- AUTH is not confirmed live, is revoked, or the checkpoint identity drifts.
- A required change exceeds allowed paths or needs a second composition,
  commit, raw-engine, detached or parallel query path.
- Diagnostics/privacy scope, `60/64` always-on first-stage wiring, real-RIME
  capture, QA-001, INT-003, performance claims, commit or publication become
  necessary to continue.
- Tests require a live RIME result, FakeCandidateProvider-as-real-RIME, or
  host/clipboard content.

### Revalidation Trigger

Checkpoint identity, predicate, budgets, adapter API, allowed paths,
diagnostics scope, AUTH liveness, reviewer independence or Product Decision
revocation.

## Handoff

- **Required Handoff Content:** new worktree path, verified checkpoint
  identities, changed-file inventory, adapter/fence/apply evidence, test and
  format results, residual dispositions and non-claims.
- **Handoff Target:** Independent Architecture review, then Independent
  Quality review, then Product Lead.
