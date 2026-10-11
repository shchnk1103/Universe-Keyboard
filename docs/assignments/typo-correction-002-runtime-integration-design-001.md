# Assignment: TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001 — Controller/sidecar runtime design

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Reviewed` |
| **Phase** | Revised design received independent `Conditional Accept`. Its implementation Authorization was consumed by Grok; the resulting snapshot is `Reviewed` with bounded residuals accepted. A separate hardening Assignment is now `Ready`. |
| **Non-claims** | No Swift change, runtime wiring, RIME query, device Run, QA-001, performance, publication or Gate conclusion. |
| **Next** | Current Codex task may consume the separate [`hardening Authorization`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001.md) only after verifying its pinned source snapshot. The prior Grok receipt was superseded unconsumed. Independent Architecture review of the resulting hardening snapshot is separately gated. |
| **Residuals** | [Architecture re-review](../reviews/typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md): F-01/F-02/F-03 resolved in design but remain implementation conditions; F-04=`tech_debt`. Runtime behavior and all observable product outcomes remain `UNKNOWN`. |

---

## Authority

- **Assignment Authority:** Human Product Owner / Product Lead。
- **Decision Source / Date:** [`runtime-preflight residual decision`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-RESIDUAL-001.md)，`2026-09-21 Asia/Shanghai`。
- **Parent Assignment:** [`TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001`](typo-correction-002-runtime-preflight-implementation-001.md)。
- **Input Reviews:** [`Architecture`](../reviews/typo-correction-002-runtime-preflight-implementation-architecture-review.md) · [`Quality`](../reviews/typo-correction-002-runtime-preflight-implementation-quality-review.md)。
- **Matching Authorization:** [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001.md)。
- **Design Package:** [`controller/sidecar runtime design`](../plans/typo-correction-002-runtime-integration-design-2026-09-21.md)。
- **Architecture Review:** [`reconciled independent review`](../reviews/typo-correction-002-runtime-integration-design-architecture-review-2026-09-21.md)。
- **Revision Authorization:** [`F-01–F-03 design revision`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-REVISION-001.md)。
- **Re-review:** [`independent Architecture re-review`](../reviews/typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md)。
- **Grok Handoff:** [`runtime implementation handoff`](../evidence/typo-correction-002-codex-to-grok-runtime-integration-handoff-2026-09-21.md)。
- **Superseding residual-hardening child:** [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`](typo-correction-002-runtime-integration-hardening-001.md) (`Ready`; no publication or product-evidence authority).

## Scope

1. Read the exact pure-Core checkpoint and current controller/RimeBridge paths.
2. Specify ownership for a second-stage operation, its pause, work scheduling,
   pre-call/post-result stale fences and cancellation semantics.
3. Specify bounded group/query/result lifecycle and display-only merge into the
   existing candidate path without a second composition or commit route.
4. Specify the needed sidecar accounting and privacy-safe diagnostics boundary.
5. Identify exact future code paths, required tests, real-RIME observability,
   QA-001 and paired-performance lanes, each as separate authorization needs.
6. Produce a docs-only package for independent Architecture review.

## Non-goals

- No Swift, project, schema/vendor, RimeBridge, Keyboard controller or UI change.
- No actual async scheduler, sidecar query, diagnostics emission or candidate merge.
- No Simulator/device capture, new Run ID, QA-001, INT-003, paired performance,
  `180 ms` claim, FakeCandidateProvider, old Ice, model or network evidence.
- No commit, push, PR, merge, TestFlight, Release, Gate, publication or Close.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer。
- **Executor:** Current Codex task, restricted to the matching Authorization。
- **Architecture Reviewer:** Independent Architecture & Knowledge Steward。
- **Quality Reviewer:** Independent Quality, Performance & Release Maintainer。
- **Human Dependency:** Later implementation requires a separate Product decision
  and explicit implementation Authorization after design review.

## Required Inputs

- exact baseline `4d1050f4b677494e06448cb40a83ef2da46d7b27` / tree `5f864a6f6f139810ed59c7e00ab6c33caad7e500`;
- pure-Core checkpoint diff `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab`;
- preceding Product residual decision and Architecture/Quality reviews;
- controller, RimeBridge correction-query and diagnostics/privacy source boundaries.

## Exit Criteria

- Design identifies a single operation owner and all await/fence boundaries.
- Bounded resource/counter and display-only merge contracts are explicit.
- Privacy-safe observability contract contains no raw composition, candidate or
  host text.
- Every implementation, real-RIME, QA and performance claim is assigned to a
  later Authorization/Run lane.
- Independent Architecture review can accept, conditionally accept or reject
  the exact docs-only design.

## Stop Conditions

- Any requirement needs a Swift change, real RIME result, device capture,
  unbounded work or a performance/product conclusion.
- The design cannot preserve a single composition/commit path or a private
  sidecar session boundary.
- Exact source/checkpoint identity cannot be reproduced.

## Handoff

- **Handoff Target:** Independent Architecture review → Product Lead。
- **Required Handoff Content:** exact source/checkpoint identities, selected
  operation owner, scheduler/fence/cancel contract, merge/privacy limits,
  future file/verification matrix and explicit non-claims.
