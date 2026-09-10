# Assignment: KOS-SUG-EVIDENCE-AUTH-001 — SUG-01 / SUG-02 可选模板实施

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | `Closed` — final independent Architecture and Quality reviews Pass; scoped docs-only validation passed |
| Current phase | Complete; future use requires a new record's explicit opt-in |
| Non-claims | No SUG-03–SUG-09 implementation; no KOS 2.0/2.1 change, `required`, migration, CI, privacy, diagnostics, device, product-code, or publication action |
| Next handoff / decision | Product Lead may use the new optional conventions only through future bounded records; no follow-on implementation is authorized here |
| Residuals | None known |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [KOS-SUG-EVIDENCE-AUTH-001 authorization decision](../product-decisions/KOS-SUG-EVIDENCE-AUTH-001-authorization.md), Human Product Owner, `2026-09-10 Asia/Shanghai`
- **Product Approver:** Human Product Owner
- **Authorization:** [AUTH-KOS-SUG-EVIDENCE-AUTH-001](../authorizations/AUTH-KOS-SUG-EVIDENCE-AUTH-001.md)

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Adopted | Adds an optional outcome block for future new evidence records only; M-04 remains the grade source. |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment, its authorization, and its accepted Product Decision bind the current slice and show the authorization frontier. |
| P-01 publication facts | Not applicable | No commit, push, PR, hosted CI, merge, Release, or publication handoff is authorized. |
| D-01 final-documentation receipt | Not applicable | This uncommitted local docs slice has no final commit/tree or publication receipt. |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current documentation slice | Authorized | `implement_kos_sug_evidence_auth_templates`: update only `docs/DOCUMENTATION_GOVERNANCE.md` and `docs/ASSIGNMENT_POLICY.md`, then obtain independent document reviews | This Assignment → [Authorization](../authorizations/AUTH-KOS-SUG-EVIDENCE-AUTH-001.md) → [Accepted Product Decision](../product-decisions/KOS-SUG-EVIDENCE-AUTH-001-authorization.md) |
| SUG-03–SUG-09 or any expanded governance work | Not authorized | Any other rule, template, CI, privacy, diagnostics, device, migration, or publication change | New bounded Assignment and matching Authorization required |
| Environment or external slice | Not applicable | Documentation and local static validation only | No device, runtime, external service, raw-data, or publication operation belongs to this Assignment |

This is a manual advisory opt-in for E-01 and A-01/B-01 only. It does not
migrate historical records or make a template field mandatory outside a new
Assignment that explicitly selects the contract.

## Boundary

### Objective

Implement the selected first slice of the accepted nine-item disposition:
make future E-01 evidence results outcome-explicit, and let future A-01/B-01
Assignments expose their authorization frontier.

### Scope

1. Add an E-01 claim outcome convention to `docs/DOCUMENTATION_GOVERNANCE.md`.
2. Add optional v0.8.0 contract selection and A-01/B-01 authorization-frontier
   sections to the unified Assignment template in `docs/ASSIGNMENT_POLICY.md`.
3. Bind independent Architecture and Quality document review to the final
   scoped diff and record ordinary docs-only checks.

### Non-goals

- Implement KOS-SUG-03 through KOS-SUG-09, including raw diagnostic requests,
  preflight, pin audits, publication tuples, or final-documentation receipts.
- Change KOS 2.0/2.1, enable `required`, or migrate any existing Assignment or
  historical evidence record.
- Change CI/workflows/scripts, privacy or diagnostics behavior, device
  procedures, product code, or external systems.
- Commit, push, open a PR, merge, TestFlight, Release, or claim a D-01 receipt.

### Required Inputs

- [Final disposition](../product-decisions/KOS-IMPROVEMENT-SUGGESTIONS-001-disposition.md)
- [Disposition ledger](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md)
- [Documentation Governance](../DOCUMENTATION_GOVERNANCE.md)
- [Assignment Policy](../ASSIGNMENT_POLICY.md)
- [KOS v0.8.0 adoption status](../kos/UPGRADE_STATUS.md)

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Current Codex primary session
- **Environment Executor:** Not Applicable — documentation and local static validation only
- **Human Dependency:** Not Applicable — Product scope authorization is recorded; no new human/device gate is needed for this docs-only slice
- **Architecture Reviewer:** `/root/kos_suggestions_arch_review`, independent runtime in logical lane `KOS-SUG-EVIDENCE-AUTH-001/document-architecture`
- **Quality Reviewer:** `/root/kos_suggestions_quality_fast`, independent runtime in logical lane `KOS-SUG-EVIDENCE-AUTH-001/document-quality`
- **Handoff Target:** Product Lead

## Gates

### Entry Criteria

- [x] The accepted Product Decision and Authorization resolve to this exact SUG-01/SUG-02 documentation slice.
- [x] Every selected v0.8.0 contract is explicit; unselected contracts are excluded.
- [x] Existing Active Assignments and historical evidence are outside scope.
- [x] Independent Architecture and Quality reviewer lanes are bound to this Assignment.

### Exit Criteria

- [x] E-01 specifies the allowed outcome vocabulary, its relation to M-04, provenance/conflict handling, and no-backfill boundary.
- [x] A-01/B-01 template distinguishes current authority from next gated slices and cannot create authority.
- [x] Independent Architecture review resolves source-of-truth, compatibility, authority, and scope findings on the final diff: [Pass review](../reviews/KOS-SUG-EVIDENCE-AUTH-001-architecture-review.md).
- [x] Independent Quality review resolves clarity, validation, and residual findings on the final diff: [Pass review](../reviews/KOS-SUG-EVIDENCE-AUTH-001-quality-review.md).
- [x] Scoped docs-only validation passes without a D-01, merge, or publication claim.

### Stop Conditions

- A proposal to make either optional convention globally mandatory or retrofit historical records.
- Any implementation request outside the two named policy documents.
- A missing/non-independent reviewer, unresolved authority chain, or review finding that changes the approved boundary.

## Handoff

- **Required Handoff Content:** final document locations; both independent review records; scoped docs-only validation result; explicit statement that no commit/push/PR/merge/publication occurred.
- **Revalidation Trigger:** the accepted disposition changes; either source policy changes materially; reviewer finding changes scope; or a request expands beyond SUG-01/SUG-02.

## History

- `2026-09-10 Asia/Shanghai` — Human Product Owner said “批准继续”; this new bounded Assignment implements only SUG-01 and SUG-02.
- `2026-09-10 Asia/Shanghai` — Independent Architecture and Quality reviewers were bound before final review resolution; their actual reviewer records are the Close evidence.
- `2026-09-10 Asia/Shanghai` — Both final independent reviews passed with `P0/P1/P2/P3 = 0/0/0/0`; ordinary docs-only checks passed. Assignment Closed; no D-01, commit, push, PR, merge, or publication claim.
