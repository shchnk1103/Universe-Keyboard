# Assignment: KOS-SUG-OBS-PREFLIGHT-001 — SUG-07 可观测性 preflight 模板

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | `Active` |
| Current phase | Docs-only SUG-07 preflight convention; independent reviews pending |
| Non-claims | No device run; no SUG-04/08; no SUG-06 CI; no privacy/diagnostics/UI/log change; no `required`, historical backfill, product code, push, merge, or Release |
| Next handoff / decision | Independent Architecture and Quality reviews; then Human publication decision |
| Residuals | None known |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [KOS-SUG-OBS-PREFLIGHT-001 authorization decision](../product-decisions/KOS-SUG-OBS-PREFLIGHT-001-authorization.md), Human Product Owner, `2026-09-10 Asia/Shanghai`
- **Product Approver:** Human Product Owner
- **Authorization:** [AUTH-KOS-SUG-OBS-PREFLIGHT-001](../authorizations/AUTH-KOS-SUG-OBS-PREFLIGHT-001.md)

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | This template defines a preflight table; it makes no product/evidence claim. |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment, Authorization and Product Decision bound only the SUG-07 docs-only template. |
| P-01 publication facts | Not applicable | No commit-push-PR handoff is authorized. |
| D-01 final-documentation receipt | Not applicable | Local docs-only checks are not a publication receipt. |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current documentation slice | In progress | `implement_kos_sug_07_observability_preflight_template` | This Assignment → [Authorization](../authorizations/AUTH-KOS-SUG-OBS-PREFLIGHT-001.md) → [Accepted Product Decision](../product-decisions/KOS-SUG-OBS-PREFLIGHT-001-authorization.md) |
| Push / PR / merge / Release | Not authorized | Any remote publication | New Human authorization required |
| SUG-07 device run | Not authorized | Any Human Device Operator action | New human-device Assignment, privacy review, and Human Dependency |
| SUG-08 / SUG-04 / SUG-06 automation | Not authorized | Raw-data read, diagnostic manifest, or CI scripts | New bounded Assignment and matching Authorization |
| Environment or external slice | Not applicable | Documentation and local static validation only | No device, runtime, or raw-data operation belongs here |

## Boundary

### Objective

Before the first operator action of a **new, opted-in** human-device run, the
manifest must list each claim’s required content-free fields, where they are
visible, and whether they are readable now. Unreadable fields mark that claim
`inconclusive` without bypassing the UI.

### Scope

1. Add the opt-in observability-preflight table and rules to
   [`universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md).
2. Add a governance cross-reference in
   [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md).
3. Bind independent Architecture and Quality document review and record
   ordinary docs-only checks.

### Non-goals

- Execute or schedule a device run.
- Implement SUG-04, SUG-08, or SUG-06 CI/script automation.
- Change production logs, diagnostics UI, privacy policy, or Swift.
- Make the preflight globally mandatory or backfill historical/Active device Assignments.
- Treat an inconclusive preflight as SUG-08 authorization.
- Push, PR, merge, TestFlight, or Release.

### Required Inputs

- [Final disposition](../product-decisions/KOS-IMPROVEMENT-SUGGESTIONS-001-disposition.md)
- [Disposition ledger](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md)
- [Human-operated evidence profile](../kos/universe-keyboard-human-operated-evidence-profile.md)
- [Documentation Governance](../DOCUMENTATION_GOVERNANCE.md)

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Current Grok primary session
- **Environment Executor:** Not Applicable — documentation and local static validation only
- **Human Dependency:** Not Applicable — no device or raw-data operation in this slice
- **Architecture Reviewer:** independent runtime in logical lane `KOS-SUG-OBS-PREFLIGHT-001/document-architecture`
- **Quality Reviewer:** independent runtime in logical lane `KOS-SUG-OBS-PREFLIGHT-001/document-quality`
- **Handoff Target:** Product Lead

## Gates

### Entry Criteria

- [x] Product Decision and Authorization resolve to this exact docs-only SUG-07 slice.
- [x] Selected v0.8.0 contracts are explicit; unselected contracts stay out.
- [x] Existing Active product/device Assignments are outside scope.
- [ ] Independent Architecture and Quality reviews of the final documentation SHA.

### Exit Criteria

- [x] Profile states opt-in, no backfill, functional vs trace split, and `inconclusive` when a field is not UI/export-readable.
- [x] Event-code appearance cannot prove UUID/phase/elapsed.
- [x] Inconclusive preflight cannot authorize SUG-08 or a raw directory read.
- [ ] Independent Architecture review of the final diff.
- [ ] Independent Quality review of the final diff.
- [ ] Scoped docs-only validation after the last documentation edit.

### Stop Conditions

- A request to run a device, read raw logs/directories, or change production telemetry.
- A proposal to make the preflight globally mandatory.
- A missing/non-independent reviewer or a finding that changes the approved boundary.

## Handoff

- **Required Handoff Content:** final document locations; both independent reviews when available; scoped docs-only validation; statement that no push/PR/merge/device run occurred.
- **Revalidation Trigger:** disposition change; profile authority change; reviewer finding changes scope; request expands beyond docs-only SUG-07.

## History

- `2026-09-10 Asia/Shanghai` — Human Product Owner said “批准 SUG-07 docs-only preflight Assignment”.
