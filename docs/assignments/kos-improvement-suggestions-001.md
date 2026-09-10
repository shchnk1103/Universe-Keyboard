# Assignment: KOS-IMPROVEMENT-SUGGESTIONS-001 — 建议稿逐条处置准备

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | `Closed` — Human Product Owner recorded all nine dispositions |
| Current phase | Complete; future implementation starts only through new bounded Assignments |
| Non-claims | Product directions do not authorize templates, KOS rules, CI, privacy, diagnostics, device, publication, or Active-Assignment migration changes |
| Next handoff / decision | Use the ledger's per-row implementation boundary; SUG-04 reopens only at its recorded trigger |
| Residuals | No review residual; SUG-04 is a Product Deferred decision, not a task residual |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [PD-KOS-IMPROVEMENT-SUGGESTIONS-001](../product-decisions/KOS-IMPROVEMENT-SUGGESTIONS-001-authorization.md), Human Product Owner, `2026-09-10 Asia/Shanghai`
- **Product Approver:** Human Product Owner
- **Authorization:** [AUTH-KOS-IMPROVEMENT-SUGGESTIONS-001](../authorizations/AUTH-KOS-IMPROVEMENT-SUGGESTIONS-001.md)

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | This task evaluates governance proposals; it makes no new product/evidence claim. |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment, the linked Authorization receipt, and this Accepted Product Decision are the authority chain for this docs-only action. |
| P-01 publication facts | Not applicable | No commit, push, PR, or hosted CI handoff is authorized. |
| D-01 final-documentation receipt | Not applicable | This local assessment is explicitly uncommitted and has no final commit/tree or publication handoff. Ordinary docs-only checks remain required, but must not be called a D-01 receipt. |
| H-02 / W-01 | Not applicable | Outside the adopted v0.8.0 scope; neither is instantiated by this task. |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current docs-only packet | Authorized | `prepare_kos_improvement_suggestions_disposition_packet` for `KOS-IMPROVEMENT-SUGGESTIONS-001`; repair current pin mirrors, prepare the ledger and obtain independent document reviews | This Assignment → [AUTH-KOS-IMPROVEMENT-SUGGESTIONS-001](../authorizations/AUTH-KOS-IMPROVEMENT-SUGGESTIONS-001.md) → [Accepted Product Decision](../product-decisions/KOS-IMPROVEMENT-SUGGESTIONS-001-authorization.md) |
| Per-row Product disposition | Recorded | See [PD-KOS-IMPROVEMENT-SUGGESTIONS-001](../product-decisions/KOS-IMPROVEMENT-SUGGESTIONS-001-disposition.md) | The final decision; no reviewer, validator, status mirror, or chat summary selected it |
| Any adopted-suggestion implementation | Not authorized | Rule/template/CI/privacy/diagnostics/device/publication changes, migration, or `required` | New bounded Assignment and matching authorization are required |

This is a manual advisory opt-in for A-01/B-01 only. This Assignment, its
Authorization and its Product Decision are deliberately not Profile-included
canonical records; their authority is resolved from the linked documents. A
separate onboarding Assignment would be required before changing
`.kos/project.json` or adding an envelope. This does not migrate historical
records.

## Boundary

### Objective

Turn the nine unadopted `KOS-SUG-*` proposals into a Product-ready decision
packet. “Done” means every row has an independently reviewed impact assessment
and is ready for a Human Product disposition; it does not mean every proposal
is adopted.

### Scope

1. Repair current v0.8.0 navigation wording that conflicts with the adopted pin.
2. Freeze the suggestion document as the inventory input.
3. Create a ledger for `KOS-SUG-01` through `KOS-SUG-09`, with owner sources,
   affected boundaries, decision criteria, migration rule, validation shape and
   required next Assignment.
4. Bind independent Architecture and Quality document reviews to the packet.
5. Produce a Product handoff that requests one explicit disposition per row.

### Non-goals

- Adopt, implement, or declare complete any `KOS-SUG-*` proposal.
- Change KOS 2.0 or KOS 2.1, enable `required`, or migrate existing Active Assignments.
- Change CI/workflow/scripts, product code, diagnostics, privacy policy, device procedures, or raw-data access.
- Commit, push, open a PR, merge, TestFlight, or Release.

### Required Inputs

- [Suggestion document](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09.md)
- [Assignment Policy](../ASSIGNMENT_POLICY.md)
- [KOS 2.1 operational maturity package](../kos/kos-2.1-operational-maturity.md)
- [Documentation Governance](../DOCUMENTATION_GOVERNANCE.md)
- [v0.8.0 upgrade record](../kos/upgrade-records/KOS-UPGRADE-UK-004-v0.8.0.md)
- [v0.8.0 adoption decision](../product-decisions/KOS-UPGRADE-UK-004-adoption.md)

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Current Codex primary session
- **Environment Executor:** Not Applicable — documentation and local validation only; no device, runtime, external service, or raw-data operation
- **Human Dependency:** Human Product Owner — selects one final disposition for each reviewed ledger row
- **Architecture Reviewer:** `/root/kos_suggestions_arch_review`, independent runtime in logical lane `KOS-IMPROVEMENT-SUGGESTIONS-001/document-architecture`
- **Quality Reviewer:** `/root/kos_suggestions_quality_fast`, independent runtime in logical lane `KOS-IMPROVEMENT-SUGGESTIONS-001/document-quality`
- **Handoff Target:** Human Product Owner

## Gates

### Entry Criteria

- [x] Product Decision and matching Authorization resolve to this exact docs-only action.
- [x] v0.8.0 remains advisory; current Active Assignments remain pinned.
- [x] Every responsibility is assigned or justified Not Applicable.
- [x] Independent reviewer lanes have a bounded, document-only remit.

### Exit Criteria

- [x] Current pin mirrors use v0.8.0 or label prior pins as historical.
- [x] The ledger covers all nine proposals without inventing a disposition.
- [x] Independent Architecture review records source-of-truth, authority, scope and migration findings.
- [x] Independent Quality review records documentation validation, test/CI boundary and residual findings.
- [x] Ordinary docs-only validation is recorded without claiming a D-01 final commit/tree receipt.
- [x] Product handoff identifies the exact nine decisions required to Close this Assignment.

### Stop Conditions

- Any attempt to treat a recommendation, reviewer conclusion, validator result, or ledger row as a Product adoption decision.
- Any request to implement a suggestion or expand into CI, privacy, diagnostics, device, raw-data, or publication work.
- A missing or non-independent reviewer; an unresolved authority chain; or a source conflict that changes the proposed scope.
- A request to migrate an existing Active Assignment or enable `required`.

## Handoff

- **Required Handoff Content:** final ledger; Architecture and Quality conclusions that identify their distinct runtimes and reviewed final-document baselines; ordinary docs-only validation output without a D-01 claim; [final Product disposition](../product-decisions/KOS-IMPROVEMENT-SUGGESTIONS-001-disposition.md); explicit next Assignment for every future `Adopted` row.
- **Revalidation Trigger:** the suggestion source changes; Product changes the objective; a review finds an authority/source conflict; or the scope expands beyond docs-only assessment.

## History

- `2026-09-10 Asia/Shanghai` — Human Product Owner authorized the compliant near-term objective: repair current pin mirrors and prepare the bounded, independently reviewable disposition packet. No `KOS-SUG-*` adoption is implied.
- `2026-09-10 Asia/Shanghai` — Independent Architecture and Quality document delta reviews both reached `Pass` with `P0/P1/P2/P3 = 0/0/0/0`. The only remaining work is the nine-row Human Product disposition; this task moves to `Reviewed`, not `Closed`.
- `2026-09-10 Asia/Shanghai` — Human Product Owner instructed “按照你的建议继续吧”. [PD-KOS-IMPROVEMENT-SUGGESTIONS-001](../product-decisions/KOS-IMPROVEMENT-SUGGESTIONS-001-disposition.md) records eight Adopted directions and one Deferred direction; no implementation is authorized. Assignment Closed after M-02 state sync.
