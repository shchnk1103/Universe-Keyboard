# Assignment: TYPO-CORRECTION-002-RECALL-REMEDIATION-001

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | Read-only coverage audit and bounded recall design; implementation is not yet authorized. |
| **Non-claims** | No production recall change, no local model, no schema/vendor change, no new Run, no Product/Quality/Release Gate and no parent closure. |
| **Next** | Verify the existing production/preflight reachability matrix, publish a design note, obtain independent Architecture/Product direction, then request a separate implementation Authorization only if the bounded strategy is accepted. |
| **Residuals** | F-01 scope manifest still lacks a dedicated F-01 Assignment/Authorization; it is outside this recall lane. |

## Authority

- **Assignment Authority:** Product Lead / Human Product Owner, current Codex task, `2026-09-19 Asia/Shanghai`.
- **Parent Assignment:** [`TYPO-CORRECTION-002`](typo-correction-002.md).
- **Predecessor evidence:** [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](typo-correction-002-parent-revalidation-002.md) and its inconclusive INT-003 / QA-001 / paired-performance receipts.
- **Matching Authorization:** [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DESIGN-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DESIGN-001.md).

## Clean execution identity

| Field | Value |
|---|---|
| Worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-recall-remediation-001/Universe Keyboard` |
| Branch | `codex/typo-correction-002-recall-remediation-001` |
| HEAD | `5d55ce981adc4ef5a34046292a6edbc727db280b` |
| Source implementation freeze | `fb27b24ff85c48302e85309e834dbbe9a777871e` — the later `5d55ce9` delta is docs-only lifecycle writeback |
| `origin/main` context | `162b09fd58ba60538a944026b1902efa405c75aa` |
| Worktree state | Clean at Assignment creation; no parent dirty residuals copied |

## Objective

Determine the smallest safe, coverage-aware way to improve recall for the
canonical two-error pinyin case without turning the keyboard hot path into an
unbounded search or introducing a local large language model. The design must
separate:

1. hypothesis recall — whether a plausible corrected pinyin enters a bounded
   pool;
2. real-RIME candidate querying — which remains sidecar-only and isolated from
   the live composition; and
3. candidate ranking / product acceptance — which requires later independent
   Quality and Product review.

## Current facts to verify, not silently promote

- [`TYPO_BENCHMARK_REGISTRY_V2.md`](../TYPO_BENCHMARK_REGISTRY_V2.md) records the
  default-off progressive-recall preflight as at most 60 first-layer states,
  64 final hypotheses and 8 hypotheses per batch.
- The same registry records that
  `wimenjintianquhongyuan` can reach `womenjintianqugongyuan` in the 60/64/8
  preflight, while the production path remains bounded at 12 first-layer
  states and 8 hypotheses.
- The product contract says the preflight is not wired into the production
  controller or Keyboard Extension scheduling path.
- The prior read-only diagnosis suggested that the target's second useful edit
  can fall outside the production first-layer budget and that an early local
  substitution can consume the budget. That is a working hypothesis for this
  Assignment, not a Product or Quality conclusion; the exact source path and
  reachability matrix must be rechecked here.
- The absence of the target candidate in the existing QA receipt remains an
  evidence-grade inconclusive observation. It must not be converted into a
  causal claim merely because the preflight test reaches the target.

## Authorized design scope

1. Read the current production hypothesis engine, preflight implementation,
   benchmark registry, contracts and existing receipts.
2. Build a deterministic, content-safe reachability matrix for the canonical
   case and representative neighboring benchmark cases under the current 12/8
   production bound and the existing 60/64/8 preflight bound.
3. Identify the smallest candidate strategy that could improve recall while
   preserving explicit limits, cancellation, sidecar isolation, privacy and
   the existing marked-text/input ownership contract.
4. Compare bounded options such as coverage-aware budget escalation or
   priority-preserving hypothesis selection. Record why a blind 12→60
   production expansion is not yet justified.
5. Define the focused tests, source/package identity, performance measurements
   and fresh Run-ID requirements that a later implementation Authorization
   would need.
6. Record the result in a design note and hand it to independent Architecture
   review before any Swift implementation is proposed.

## Explicit exclusions

- No Swift, Objective-C, KeyboardCore, RimeBridge, schema, vendor archive,
  settings default, search budget or ranking implementation change.
- No local LLM, cloud/network correction, host context, user-history
  persistence, FakeCandidateProvider, old Ice directory or synthetic RIME
  fixture as runtime evidence.
- No build, install, Simulator/device capture, RIME deployment or new Run ID.
- No reuse of old Run IDs as proof for a future implementation.
- No F-01 manifest ownership, F-01 remediation, AX production cleanup or
  testability-child closure.
- No commit, push, PR, merge, TestFlight, Release, Product Gate, Quality Gate
  or parent Assignment closure unless separately authorized.

## Assignment roles

- **Domain Owner:** Input Intelligence Maintainer.
- **Executor:** Current Codex task, limited to this read-only/docs-only slice.
- **Architecture Reviewer:** Architecture & Knowledge Steward, independent of
  the design author.
- **Quality Reviewer:** Quality, Performance & Release Maintainer, only after
  an implementation or evidence slice is separately authorized.
- **Product Approver:** Human Product Owner / Product Lead.
- **Handoff Target:** Independent Architecture review, then Product Lead for a
  bounded implementation decision.

## Required inputs

- [`TYPO_CORRECTION.md`](../TYPO_CORRECTION.md)
- [`TYPO_BENCHMARK_REGISTRY_V2.md`](../TYPO_BENCHMARK_REGISTRY_V2.md)
- [`TYPO_BENCHMARK.md`](../TYPO_BENCHMARK.md)
- [`typo-correction-002.md`](typo-correction-002.md)
- [`typo-correction-002-parent-revalidation-002.md`](typo-correction-002-parent-revalidation-002.md)
- [`typo-correction-002-file-provenance-audit-2026-09-19.md`](../evidence/typo-correction-002-file-provenance-audit-2026-09-19.md)
- [`bounded recall design note`](../plans/typo-correction-002-recall-remediation-design-2026-09-19.md)
- [`recall coverage matrix`](../evidence/typo-correction-002-recall-coverage-matrix-2026-09-19.md)
- The exact source/package baseline at `fb27b24ff85c48302e85309e834dbbe9a777871e`.

## Exit criteria for this design slice

- The production 12/8 and preflight 60/64/8 bounds are tied to exact source
  paths and a reproducible reachability matrix.
- The design note states a bounded recommendation, rejected alternatives,
  privacy/hot-path constraints and the required implementation evidence.
- The design note explicitly keeps the production budget and preflight
  budget separate and does not authorize implementation.
- The coverage matrix labels missing frontier/range measurements as `UNKNOWN`
  rather than deriving them from a reimplementation or treating recall as
  candidate quality.
- Independent Architecture receives only this design record and its exact
  source baseline; no old Simulator receipt is upgraded.
- A later implementation request, if any, has a new Authorization, source
  commit, package identity and fresh Run IDs.

## Stop conditions

- The exact budget, generation order or benchmark fixture cannot be located.
- The design would require mutating live composition, using host context or
  querying RIME from the Extension hot path.
- A proposed strategy needs unbounded search, a local/cloud model or a schema
  change to establish basic recall.
- The work would silently claim the old QA-001/INT-003/performance receipts as
  a pass.

## Handoff and revalidation

The first handoff is a read-only Architecture review of the design and exact
source identity. Any production code change, default/budget change, schema or
vendor change, build/install restart, device change or new evidence capture
invalidates this design snapshot and requires a new Authorization and Run ID
where applicable.
