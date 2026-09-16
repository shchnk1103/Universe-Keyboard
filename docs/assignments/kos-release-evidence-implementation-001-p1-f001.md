# Assignment: KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001 — F-001 Main-App source identity fail-closed remediation

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001",
  "record_type": "assignment",
  "title": "Remediate UK-005 P1 F-001 Main-App source identity boundary",
  "lifecycle": "closed",
  "current_phase": "Reviewed → Closed: narrow Human Product Gate accepted F-001 Coverage-R1; no Release or merge authorization",
  "authorization_action": "remediate_uk005_p1_f001",
  "updated_at": "2026-09-16T17:30:56+08:00",
  "revalidation_triggers": [
    "base_commit_changed",
    "scope_changed",
    "authority_revoked",
    "review_finding",
    "source_owner_or_identity_changed",
    "contract_schema_or_evaluator_changed",
    "p1a_scope_changed",
    "p1b_scope_changed"
  ],
  "authorization_refs": [
    "AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001",
    "AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-COVERAGE-R1",
    "AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-QUALITY-R1"
  ],
  "parent_refs": [
    "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1",
    "PD-KOS-UPGRADE-UK-005-RELEASE-EVIDENCE",
    "PD-KOS-UPGRADE-UK-005-P1-A-SCOPE"
  ],
  "responsibilities": {
    "domain_owner": "Architecture and Knowledge Steward",
    "executor": "Current Codex executor in isolated feature branch",
    "environment_executor": "Current Codex executor for bounded local Python adapter, fixture and test checks; no device or release service",
    "human_dependency": "Human Product Owner / Product Lead only for scope, source-owner or authority changes; no device, account or credential dependency",
    "architecture_reviewer": "Independent Architecture and Knowledge Steward reviewer; fresh runtime required for exit review",
    "quality_reviewer": "Independent Quality, Performance and Release reviewer; fresh runtime required for exit review",
    "product_approver": "Human Product Owner acting as Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Closed |
| Current Phase | Reviewed → Closed: narrow Human Product Gate accepted F-001 Coverage-R1; no Release or merge authorization |
| Material non-claims | The narrow Product Gate accepts only F-001 Coverage-R1; no current-proof, overall UK-005/P1 Product or Release Gate, TestFlight, App Store Connect, merge or Release conclusion; Build 55 TD-003/004/005 remain open and untouched |
| Next handoff / decision | No further action for this narrow Assignment; any Release, merge, external publication or other finding requires a separate Assignment/Authorization/Product decision |
| Residuals | None within F-001. F-002–F-004 and other Quality findings remain outside this slice; P1-B stays under its existing `Not applicable` / `Deferred` disposition |

This is a successor remediation Assignment under the existing UK-005 P1-A
boundary. It preserves the older exact-digest `Needs work` review as history and
does not rewrite the later P1-A closure records. The current `5692cf6` baseline
contains a candidate case-fold/source-identity guard, but that observation is not
itself an independent remediation result.

## Authority

- **Assignment Authority:** Product Lead.
- **Decision Source / Date:** Human Product Owner current-session direction on `2026-09-16 Asia/Shanghai`: use clean baseline `5692cf6`, establish a new UK-005 P1 Assignment/Authorization, and prioritize F-001; keep Build 55 TD-003–005 open and do not treat the previous documentation merge as Release approval.
- **Product Approver:** Human Product Owner acting as Product Lead.
- **Clean baseline:** `5692cf60c344d79b428d50430422a7c76832df06`; local feature branch `codex/uk-005-f001-remediation` was created from this commit. No commit or push is authorized by this record.
- **Parent Assignment:** [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](kos-release-evidence-implementation-001-p1.md). Its consumed Authorization is not reused or widened.
- **Existing scope source:** [`PD-KOS-UPGRADE-UK-005-P1-A-SCOPE`](../product-decisions/KOS-UPGRADE-UK-005-P1-A-scope.md). The separate [`F-001 Product Gate decision`](../product-decisions/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-product-gate.md) records acceptance and closure only; it does not widen the implementation or Release boundary.
- **New Authorization:** [`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001.md).

## KOS v0.8.0 optional-contract selection

This newly created record opts in only to the advisory contracts needed to make
the authorization frontier and future remediation evidence explicit.

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Adopted | The future F-001 receipt may record content-free claim outcomes; the existing evidence owner remains authoritative. |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment and its matching Authorization expose the current F-001 slice and the next separately gated findings. |
| P-01 publication facts | Not applicable | No commit, push, PR, hosted publication, App Store Connect, TestFlight or Release handoff is in scope. |
| D-01 final-documentation receipt | Not applicable | This turn establishes governance records; no final documentation publication receipt is being asserted. |

`required` remains unauthorized. The optional contracts do not make a validator,
fixture result, reviewer or status mirror a Product, Quality or Release authority.

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current authorized slice | Closed / consumed | F-001 re-verification, bounded negative coverage and independent Architecture/Quality handoff are complete; no further execution is authorized by this closed Assignment | This Assignment → [F-001 Product Gate](../product-decisions/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-product-gate.md) → consumed F-001 Authorizations |
| Next independently gated slice | Not authorized | F-002–F-004, Quality `P1-01`/`P1-02`, any other historical `Needs work` finding, P1-B UI/storage, migration or background sync | New bounded Assignment and matching Authorization required |
| Environment or external slice | Not applicable | No device, raw diagnostic data, account, credential, network upload, App Store Connect, TestFlight, Beta Review or Release operation | This Assignment's local-only boundary |

## Boundary

### Objective

Close or accurately reclassify the historical F-001 boundary on the exact
`5692cf6` baseline: unresolved or foreign Main-App source input must fail closed
before it can participate in an evaluator `current-proof` input, while the
existing `SRC-MAIN-STORE` ownership boundary remains intact.

### Current authorized scope

1. Re-verify the adapter's Main-App source seam against the F-001 finding:
   `UNKNOWN`, case variants such as `unknown`, whitespace variants and `TODO`/
   `TBD` values must be treated as unresolved; `source_identity` must be the
   exact canonical `SRC-MAIN-STORE`; missing, extra or foreign source fields must
   be rejected.
2. Ensure the caller cannot enable a verified source binding with a boolean,
   `binding_status` field or another payload alias. If the owner-attested source
   receipt is not verifiable, the adapter must remain fail-closed and must not
   produce an input that supports `current-proof`.
3. If the baseline does not already satisfy the above, make the smallest change
   limited to `scripts/release/kos_release_evidence_adapter.py`, its focused test,
   and the bounded fixture matrix. If it already satisfies them, do not make a
   speculative duplicate change; record the re-verification evidence instead.
4. Add or retain negative coverage for the case-folded unresolved values, foreign
   source identity, missing/extra source keys and caller-controlled binding
   attempts. Run the focused checks with the pinned contract/evaluator and an
   explicit `--as-of` value.
5. Read the existing [`REP-Q-01 / hosted provenance receipt`](../evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md)
   as a predecessor input only. Do not edit it, silently transfer its package
   digest, or use it to bypass a changed source identity. Any mismatch or missing
   owner binding stops the slice.

### Affected systems

- Project-side release-evidence adapter and its content-free tests/fixtures.
- The existing Main-App source seam only as a read-only identity boundary.
- The F-001 executor receipt and fresh independent review handoff.

The Main-App store/UI, `ADR 0027`, App Group ownership, Keyboard Extension
runtime/hot path, RIME, device state and release services are not implementation
targets of this Assignment.

## Non-goals

- Do not implement or re-review F-002–F-004, Quality `P1-01`/`P1-02` or other
  historical UK-005 findings under this Authorization.
- Do not add or change P1-B Diagnostics UI/storage, retention, clear behavior,
  migration/backfill, background sync, network access or App Group ownership.
- Do not change the adopted `v0.8.0` pin, the `kos.release-evidence` candidate,
  the Profile, ADR 0027, the existing Product Decisions or the Main-App source
  owner.
- Do not record raw keyboard text, candidate text, host text, credentials, full
  logs or unrelated user data.
- Do not run device operations, archive/export, App Store Connect, TestFlight,
  Beta Review, external distribution, commit, push, PR, merge, tag, branch
  deletion or Release.
- Do not change the open status of Build 55 TD-003, TD-004 or TD-005. This
  Assignment is not a Release decision and the previous documentation merge is
  not a Release pass.

## Required Inputs

- Clean baseline `5692cf60c344d79b428d50430422a7c76832df06` and the changed-file
  allowlist in the matching Authorization.
- Historical F-001 finding in the
  [`2026-09-14 remediation Architecture review`](../reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-architecture-remediation-exact-digest-review-2026-09-14.md).
- Existing P1-A Assignment/Authorization and the accepted P1-A scope decision;
  the old Authorization is consumed and cannot be reused.
- [`release-evidence-profile.md`](../kos/release-evidence-profile.md), including
  `SRC-MAIN-STORE`, the content-free pointer boundary and fail-closed semantics.
- Current adapter, focused tests and fixture matrix under `scripts/release/`.
- The existing `REP-Q-01` closure receipt as a read-only source-owner input.
- Fresh independent Architecture and Quality reviewer runtimes before exit review.

## Assignment

- **Domain Owner:** Architecture and Knowledge Steward.
- **Executor:** Current Codex executor in isolated branch `codex/uk-005-f001-remediation`.
- **Environment Executor:** Same executor; local Python adapter, fixture and test checks only.
- **Human Dependency:** Human Product Owner / Product Lead for any scope, source-owner, ADR or authority change; otherwise Not Applicable for device/account access.
- **Architecture Reviewer:** Independent Architecture and Knowledge Steward reviewer; fresh runtime and exact package digest required.
- **Quality Reviewer:** Independent Quality, Performance and Release reviewer; fresh runtime and exact package digest required.
- **Handoff Target:** Independent Architecture reviewer → independent Quality reviewer → Product Lead; the accepted Product Gate decision completed the `Reviewed → Closed` lifecycle handoff.

## Gates

### Entry Criteria

- [x] `5692cf60c344d79b428d50430422a7c76832df06` is verified as the clean starting commit.
- [x] A new matching Assignment and Authorization have been established; the previous P1 Authorization is not reused.
- [x] F-001 is isolated from F-002–F-004, Quality `P1-01`/`P1-02`, P1-B and Build 55 TD-003–005.
- [x] The changed-file allowlist and local-only environment boundary are explicit.
- [x] Required responsibility fields are assigned; fresh reviewer runtime IDs remain an exit-review input, not an inferred historical fact.

### Exit Criteria

- [x] F-001 negative cases reject unresolved case/whitespace variants before envelope construction.
- [x] `main_app_source` accepts only the exact canonical key set and `SRC-MAIN-STORE`; foreign or caller-controlled binding attempts fail closed.
- [x] An unresolved or unverifiable source-owner receipt cannot produce an evaluator input that supports `current-proof`.
- [x] Focused tests and the pinned fixture runner pass with explicit `--as-of`; the receipt lists exact cases, outputs, exit codes, package identity and non-claims.
- [x] Fresh independent Architecture and Quality reviews assess the exact remediation package; no unresolved blocking finding remains for F-001.
- [x] Assignment/status mirrors are updated from the receipts, review conclusions and the accepted narrow Product Gate decision; no Release, merge or external-publication claim is added.

- [x] F-001 negative cases reject unresolved case/whitespace variants before envelope construction.
- [x] `main_app_source` accepts only the exact canonical key set and `SRC-MAIN-STORE`; foreign or caller-controlled binding attempts fail closed.
- [x] An unresolved or unverifiable source-owner receipt cannot produce an evaluator input that supports `current-proof`.
- [x] Focused tests and the pinned fixture runner pass with explicit `--as-of`; the receipt lists exact cases, outputs, exit codes, package identity and non-claims.
- [x] Fresh independent Architecture and Quality reviews assess the exact remediation package; no unresolved blocking finding remains for F-001.
- [x] Assignment/status mirrors are updated from the receipts, review conclusions and the accepted narrow Product Gate decision; no Release, merge or external-publication claim is added.

### Stop Conditions

- The baseline, changed-file set, source-owner receipt or reviewer independence becomes unknown or mismatched.
- F-001 would require a new Main-App store/UI, an ADR 0027 ownership change, a new Product Decision, device/account access or a release action.
- A test, evaluator, hosted result or documentation merge is presented as Product, Quality, Release Gate or Release acceptance.
- Any requested change expands into F-002–F-004, Quality `P1-01`/`P1-02`, P1-B or Build 55 TD-003–005.
- Any required responsibility becomes `UNKNOWN`; stop and return the Assignment to the Product Lead.

## Handoff

- **Required Handoff Content:** exact base/head or uncommitted working-tree identity; changed-file list; F-001 fixture IDs; pinned schema/evaluator and explicit `--as-of`; source-owner receipt pointer; focused test output; privacy/hot-path/non-claims; fresh Architecture and Quality review pointers; and explicit statement that no commit, push, publication or Release action occurred.
- **Current Receipt:** [`F-001 Coverage-R1 receipt`](../evidence/kos-release-evidence-implementation-001-p1-f001-coverage-r1-2026-09-16.md); the earlier [`read-only Preflight`](../evidence/kos-release-evidence-implementation-001-p1-f001-preflight-2026-09-16.md) remains a predecessor input.
- **Quality Preflight:** [`Quality-R1 preflight receipt`](../evidence/kos-release-evidence-implementation-001-p1-f001-quality-preflight-2026-09-16.md) freezes the 16-file package used by both review lanes.
- **Architecture Review:** [`Coverage-R1 independent Architecture re-review`](../reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-f001-architecture-review-coverage-r1-2026-09-16.md) returned `approve`; [`status-only revalidation`](../reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-f001-architecture-status-revalidation-2026-09-16.md) returned no blocking finding and cleared the current package for Quality. The prior [`request_changes`](../reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-f001-architecture-review-2026-09-16.md) finding is historical and resolved by Coverage-R1.
- **Quality Review:** [`F-001 Quality-R1 independent review`](../reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-f001-quality-review-r1-2026-09-16.md) returned `approve` with no blocking finding; the fresh runtime independently ran `26/26` focused tests, `20/20` F-001 subTests and `76/76` pinned matrix cases.
- **Product Gate:** [`F-001 Coverage-R1 Product Decision`](../product-decisions/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-product-gate.md) is accepted; the Assignment is `Reviewed → Closed` within this narrow evidence boundary.
- **Coverage-R1 Authorization:** [`durable negative coverage revalidation`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-COVERAGE-R1.md) is `active / consumed`; its authorized focused test/fixture update and fresh Architecture handoff are complete.
- **Quality-R1 Authorization:** [`independent Quality review`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-QUALITY-R1.md) is `active / consumed` for the one bounded read-only Quality review; it did not authorize implementation or Release actions.
- **Revalidation Trigger:** base commit changes; any adapter/Profile/source-owner/contract/evaluator change; F-001 review finding; scope or authority change; P1-B disposition change; or a request to address another finding.

## History

- `2026-09-16 Asia/Shanghai`: Established from clean baseline `5692cf6` at the Human Product Owner's direction. This record authorizes a Ready F-001 remediation slice; no code implementation, commit, push or Release action has started.
- `2026-09-16 Asia/Shanghai`: The historical `Needs work` review remains bound to its old exact package. The current baseline was read-only checked to contain case-folded unresolved handling and exact `SRC-MAIN-STORE` validation, but this was not promoted to a new F-001 closure or independent review result.
- `2026-09-16 Asia/Shanghai`: Build 55 TD-003, TD-004 and TD-005 remain open under the release umbrella Assignment; no status was changed here.
- `2026-09-16T16:11:16+08:00`: The bounded F-001 read-only Preflight ran against the exact baseline. Focused tests passed `25/25`; the pinned fixture matrix passed `76/76`; the source-identity negative probe found no remaining historical F-001 reproduction. No code change was made; fresh independent Architecture and Quality reviews remain required.
- `2026-09-16T16:28:00+08:00`: Fresh independent Architecture review verified the exact package and Preflight receipt, confirmed the code-level fail-closed mechanisms, and returned `request_changes` because the durable focused test/fixture set does not cover every F-001 boundary claimed by the receipt. Quality review was not started; no code or Build 55 status changed.
- `2026-09-16T16:39:07+08:00`: Product Lead revalidated a narrower Coverage-R1 Authorization to persist the F-001 negative boundaries and request a new fresh Architecture review. The scope excludes adapter/runner behavior changes, all other UK-005 findings, Build 55, Quality and Release actions.
- `2026-09-16T16:42:02+08:00`: Coverage-R1 consumed by adding the fixture-driven F-001 negative input set and durable focused assertions. Focused suite passed `26/26`; pinned Envelope/Delta matrix remained `76/76`; adapter and fixture runner stayed byte-identical to `5692cf6`. New exact package and fresh Architecture review handoff remain pending.
- `2026-09-16T16:52:49+08:00`: Fresh independent Architecture re-review `uk005-f001-architecture-review-coverage-r1-20260916` / session `a3d54b9e-aa21-4f98-a9e8-97c5242ec5f5` verified the exact Coverage-R1 package, independently ran the focused `26/26` suite, and returned `approve` with no blocking finding. The prior durable-coverage finding is resolved; Quality review remains separately gated. The single `lody_review_submit` attempt returned `REVIEW_RUN_NOT_FOUND`, so no formal Lody receipt is claimed.
- `2026-09-16T17:02:07+08:00`: Product Lead direction `按照 KOS 设定继续` established Quality-R1 as a separate, narrow Authorization. Because the post-review status synchronization changed package members, the current exact package must be re-frozen; a status-only Architecture revalidation precedes the fresh Quality review. No implementation or Build 55 status change is authorized.
- `2026-09-16T17:22:26+08:00`: Fresh independent Architecture status-only revalidation verified current package `ec0e79c2…acb273` with no blocking finding and cleared it for Quality. Fresh independent Quality review `uk005-f001-quality-review-r1-20260916` / session `f04a2961-268c-4147-8438-555d4673a3cb` independently passed `26/26`, `20/20` F-001 subTests and `76/76` pinned cases, returning `approve` with no blocking finding. Its single `lody_review_submit` returned `REVIEW_RUN_NOT_FOUND` (`retryable: false`); no formal Lody receipt is claimed. Product/owning Gate remains separate; Build 55 TD-003/004/005 remain open.
- `2026-09-16T17:30:56+08:00`: Human Product Owner acting as Product Lead accepted the bounded F-001 Coverage-R1 result through [`PD-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-PRODUCT-GATE`](../product-decisions/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-product-gate.md). With the independent Architecture and Quality `approve` conclusions and no blocking finding, this Assignment transitioned `Reviewed → Closed`; no Release, merge or external-publication authorization was granted, and Build 55 TD-003/004/005 remain open.
