# Assignment: KOS-SUG-PROPOSAL-HANDOFF-001 — SUG-05 Proposed 工作包交接头

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | `Closed` — final independent Architecture and Quality reviews Pass; scoped docs-only validation passed |
| Current phase | Complete; future plans choose `Proposed` deliberately and still need their own implementation authority |
| Non-claims | No implementation of SUG-01–04 or SUG-06–09; no KOS 2.0/2.1 change, `required`, migration, CI, privacy, diagnostics, device, product code, or publication action |
| Next handoff / decision | Product Lead may use the non-authorizing header for a future proposal; any implementation remains separately gated |
| Residuals | None known |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [KOS-SUG-PROPOSAL-HANDOFF-001 authorization decision](../product-decisions/KOS-SUG-PROPOSAL-HANDOFF-001-authorization.md), Human Product Owner, `2026-09-10 Asia/Shanghai`
- **Product Approver:** Human Product Owner
- **Authorization:** [AUTH-KOS-SUG-PROPOSAL-HANDOFF-001](../authorizations/AUTH-KOS-SUG-PROPOSAL-HANDOFF-001.md)

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | This documentation pilot makes no product, runtime, device, or evidence claim. |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment, its Authorization and its Accepted Product Decision bound only the SUG-05 pilot. |
| P-01 publication facts | Not applicable | No commit, push, PR, hosted CI, merge, Release, or publication handoff is authorized. |
| D-01 final-documentation receipt | Not applicable | The local docs slice has no final commit/tree or publication receipt. |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current documentation pilot | Authorized | `implement_kos_sug_proposal_handoff_pilot`: update the plan-lifecycle convention and create one Proposed-plan pilot | This Assignment → [Authorization](../authorizations/AUTH-KOS-SUG-PROPOSAL-HANDOFF-001.md) → [Accepted Product Decision](../product-decisions/KOS-SUG-PROPOSAL-HANDOFF-001-authorization.md) |
| Any plan implementation or another suggestion | Not authorized | Product, code, CI, device, diagnostics, privacy, data-read, migration, or publication work | New bounded Assignment and matching Authorization required |
| Environment or external slice | Not applicable | Documentation and local static validation only | No device, runtime, external service, raw-data, or publication operation belongs to this Assignment |

## Boundary

### Objective

Give future “record only; do not implement” work a consistent Proposed-plan
handoff header, and prove it with one plan whose own status cannot be mistaken
for implementation authorization.

### Scope

1. Define `Proposed` as a plan lifecycle state and prescribe the handoff header
   in `docs/DOCUMENTATION_GOVERNANCE.md`.
2. Create one documentation-only pilot under `docs/plans/` that uses every
   header field and retains unproved facts as `UNKNOWN`.
3. Bind independent Architecture and Quality document review to the final
   scoped diff and record ordinary docs-only checks.

### Non-goals

- Turn any Proposed plan into an Assignment, implementation guide, Product
  decision, device/data permission, or current development truth.
- Implement KOS-SUG-01–04 or KOS-SUG-06–09, including CI, publication facts,
  pin automation, preflight, diagnostic manifest, or raw diagnostic access.
- Change KOS 2.0/2.1, enable `required`, or migrate historical/Active records.
- Commit, push, open a PR, merge, TestFlight, Release, or claim a D-01 receipt.

### Required Inputs

- [Final disposition](../product-decisions/KOS-IMPROVEMENT-SUGGESTIONS-001-disposition.md)
- [Disposition ledger](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md)
- [Documentation Governance](../DOCUMENTATION_GOVERNANCE.md)
- [Assignment Policy](../ASSIGNMENT_POLICY.md)

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Current Codex primary session
- **Environment Executor:** Not Applicable — documentation and local static validation only
- **Human Dependency:** Not Applicable — scope authorization is recorded and no human/device operation is in this slice
- **Architecture Reviewer:** `/root/kos_suggestions_arch_review`, independent runtime in logical lane `KOS-SUG-PROPOSAL-HANDOFF-001/document-architecture`
- **Quality Reviewer:** `/root/kos_suggestions_quality_fast`, independent runtime in logical lane `KOS-SUG-PROPOSAL-HANDOFF-001/document-quality`
- **Handoff Target:** Product Lead

## Gates

### Entry Criteria

- [x] Accepted Product Decision and Authorization resolve to this exact SUG-05 docs-only slice.
- [x] The pilot cannot authorize its own implementation and includes every required handoff field.
- [x] Independent reviewer lanes are bound before final review.

### Exit Criteria

- [x] Proposed plan lifecycle and header preserve the plan-versus-authorization distinction.
- [x] The pilot contains triggering evidence, frozen facts/unknowns, decision, seam, verification, stops, and required next authority/reviewers without inventing facts.
- [x] Independent Architecture review resolves source-of-truth, compatibility, authority, and scope findings on the final diff: [Pass review](../reviews/KOS-SUG-PROPOSAL-HANDOFF-001-architecture-review.md).
- [x] Independent Quality review resolves clarity, validation, and residual findings on the final diff: [Pass review](../reviews/KOS-SUG-PROPOSAL-HANDOFF-001-quality-review.md).
- [x] Scoped docs-only validation passes without a D-01, merge, or publication claim.

### Stop Conditions

- Any wording that makes `Proposed` current implementation guidance or creates authority.
- Any attempt to use the pilot as a substitute for a future Assignment, authorization, or Accepted Product Decision.
- A missing/non-independent reviewer, unresolved authority chain, or finding that changes the approved boundary.

## Handoff

- **Required Handoff Content:** final header and pilot locations; both independent reviews; scoped docs-only validation; explicit statement that no plan implementation, commit, push, PR, merge, or publication occurred.
- **Revalidation Trigger:** a plan-lifecycle policy change; a review finding changing scope; or any request to implement the pilot or another suggestion.

## History

- `2026-09-10 Asia/Shanghai` — Human Product Owner approved the next bounded work item. This Assignment implements SUG-05 only.
- `2026-09-10 Asia/Shanghai` — Final independent Architecture and Quality reviews passed with `P0/P1/P2/P3 = 0/0/0/0`; ordinary docs-only checks passed. Assignment Closed; no D-01, commit, push, PR, merge, or publication claim.
