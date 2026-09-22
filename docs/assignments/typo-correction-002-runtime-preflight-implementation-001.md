# Assignment: TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001 — Pure Core selector and operation-contract preflight

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `In Review` |
| **Phase** | The matching implementation and Quality Authorizations were consumed; implementation evidence, independent Architecture and bounded Quality reviews are recorded; Product accepted the pure-Core residual boundary only. |
| **Non-claims** | No controller/RIME wiring, device Run, QA-001, performance, publication or Gate conclusion. |
| **Next** | Create a bounded controller/sidecar runtime-integration design Authorization; runtime/controller/RIME and publication remain separately unauthorized. |
| **Residuals** | AR-01～AR-04 have implementation candidates in the preflight model; runtime integration remains open until separately authorized and reviewed. |

---

## Authority

- **Assignment Authority:** Human Product Owner / Product Lead。
- **Decision Source / Date:** [`PD-TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001.md)，`2026-09-21 Asia/Shanghai`。
- **Product Approver:** Human Product Owner / Product Lead。
- **Parent Assignment:** [`TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001`](typo-correction-002-second-stage-recall-runtime-design-001.md)。
- **Architecture Input:** [`runtime design Architecture review`](../reviews/typo-correction-002-second-stage-recall-runtime-design-architecture-review-2026-09-21.md)。
- **Matching Authorization:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001.md)。
- **Implementation Architecture review:** [`typo-correction-002-runtime-preflight-implementation-architecture-review.md`](../reviews/typo-correction-002-runtime-preflight-implementation-architecture-review.md)。
- **Implementation Quality review:** [`typo-correction-002-runtime-preflight-implementation-quality-review.md`](../reviews/typo-correction-002-runtime-preflight-implementation-quality-review.md)，bounded verdict `Pass with conditions`。
- **Product residual decision:** [`TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-RESIDUAL-001`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-RESIDUAL-001.md)，accepted pure-Core foundation only。

## Scope

1. Add a deterministic, substitution-only, structural coverage-selector contract to the listed pure-Core files. It must keep generated hypotheses, selected groups and query-attempt budget as separate concepts.
2. Define and test provisional preflight-only selector configuration, including selected-group and `maxQueryAttempts` caps. The values must be represented as preflight data rather than production defaults.
3. Define and test an operation-scoped opaque GroupID mapping contract and decision-level cancellation/stale-publish fence, without controller/RIME integration.
4. Add focused tests for rank-order independence, duplicate/different/new-operation group behavior, cap boundaries and stale/cancelled decision outcomes.
5. Run strict Swift formatting and the KeyboardCore suite in a writable-cache environment; record exact baseline, changed files and results for independent review.

## Non-goals

- No `Keyboard/`, RimeBridge, schema/vendor, candidate UI, App Group, host-text, clipboard, diagnostics-retention or learning-store changes.
- No production `12/8` change, controller wiring, actual async sidecar delivery or real-RIME query.
- No Simulator/device capture, Run ID, QA-001, INT-003, paired performance or `180 ms` conclusion.
- No FakeCandidateProvider/old Ice/model/network evidence, commit, push, PR, merge, TestFlight, Release, Gate or Assignment Close.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer。
- **Executor:** Current Codex task, limited to matching Authorization。
- **Environment Executor:** Current Codex task — local Swift/KeyboardCore toolchain only; no device/RIME environment operations。
- **Human Dependency:** Human Product Owner accepted this bounded slice; any runtime/controller/RIME scope needs a further explicit decision。
- **Architecture Reviewer:** Independent Architecture & Knowledge Steward。
- **Quality Reviewer:** Independent Quality, Performance & Release Maintainer。

## Required Inputs

- [`runtime design package`](../plans/typo-correction-002-second-stage-recall-runtime-design-2026-09-21.md)；
- [`runtime design Architecture review`](../reviews/typo-correction-002-second-stage-recall-runtime-design-architecture-review-2026-09-21.md)；
- [`ADR 0016`](../architecture/decisions/0016-progressive-contextual-recall-preflight.md)；
- exact baseline `4d1050f4b677494e06448cb40a83ef2da46d7b27`。

## Entry Criteria

- The Product decision is not revoked and matching Authorization is `active`/unconsumed.
- A new clean worktree is created from the exact baseline; all unrelated parent docs remain untouched.
- The executor records the pre-change source/package identity before modifying Swift.

## Exit Criteria

- All allowed changed Swift files pass strict formatting.
- Focused and complete KeyboardCore tests pass, or failures are retained as failures.
- Evidence names the provisional selector/caps and proves they did not change production `12/8` or controller calls.
- Independent Architecture and Quality review the exact changed snapshot; AR-01～AR-04 are each explicitly retained, narrowed or fixed with a disposition.

## Stop Conditions

- Any required change crosses into `Keyboard/`, RimeBridge, production budget/controller, RIME, device, user content or an excluded path.
- A proposed contract requires an unbounded selector, a real-RIME result or an unstated production cap to be meaningful.
- Source identity, test target, role independence or Authorization scope cannot be reproduced.

## Handoff

- **Handoff Target:** Independent Architecture review → Independent Quality review → Product Lead.
- **Required Handoff Content:** exact worktree/commit/tree, changed files, provisional selector/caps, GroupID/fence behavior, command results, residual disposition and explicit non-claims.
- **Revalidation Trigger:** baseline/source/package, selector/cap, privacy boundary, controller/RIME scope, test result, reviewer scope or Authorization changes.
