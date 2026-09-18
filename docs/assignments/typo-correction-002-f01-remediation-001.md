# Assignment: TYPO-CORRECTION-002-F01-REMEDIATION-001 — RIME identity sentinel fail-closed remediation

**Policy version:** `1.0.0`

**Repository Change Type:** `Implementation` + `Tests` + `Documentation`

This is a new, bounded remediation Assignment under the still-Active
`TYPO-CORRECTION-002` Assignment. It does not replace, close, or broaden the
parent Assignment. It exists to address the independent Quality finding that
the F-01 deployment guard accepts the production bridge sentinels
`(no api)` and `(unknown)` as if they were usable librime identities.

KOS 2.2 optional contracts (E-01, A-01/B-01, P-01, D-01) are not opted in.

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current Phase | Draft PR `#139` opened; latest hosted run `35362365167` is fully green for head `6e6374e`; exact F-01 review remains `Pass with conditions`; child closure still requires a separate Product/Assignment decision |
| Parent Assignment | `TYPO-CORRECTION-002` — remains Active and is not being closed or migrated |
| Exact base | `409eeab8ad4f1dd66f0139b5d1c561dc927316ce` (`7d2e3b212daa7c8dc36d82d629e5ee15313b34bf`) |
| Working branch | `codex/typo-correction-002-f01-remediation-001` |
| Merge / publication status | Draft PR `#139` is open; no merge, Release, TestFlight, or external publication is authorized |
| Material non-claims | No Product, Quality, Release, Device, performance, INT-003, or QA-001 conclusion follows from this Assignment |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner current-session authorization on `2026-09-18 Asia/Shanghai`: establish a new bounded F-01 remediation Assignment/Authorization, then repair F-01; do not open a merge-ready PR and do not close the parent Assignment.
- **Product Approver:** Human Product Owner acting as Product Lead
- **Authorization Record:** [`AUTH-TYPO-CORRECTION-002-F01-REMEDIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-F01-REMEDIATION-001.md)
- **Current PR/review Authorization:** [`AUTH-TYPO-CORRECTION-002-F01-PR-REVIEW-001`](../authorizations/AUTH-TYPO-CORRECTION-002-F01-PR-REVIEW-001.md)

### Post-commit revalidation note

On `2026-09-18 Asia/Shanghai`, the Human Product Owner separately authorized
commit/push of the completed remediation candidate. That action produced
commit `781ba235009e19a0be8b810a3441647dbcc23eb0` with tree
`25f589b8633ae95dfdb5c1f60d1e9e7d55ecb3a4`, and did not authorize a PR, merge,
or parent closure. The earlier Authorization's `candidate_commit_created`
revalidation trigger therefore fired; the current exact-commit review is
governed by [`AUTH-TYPO-CORRECTION-002-F01-COMMIT-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-F01-COMMIT-REVALIDATION-001.md).

On `2026-09-18 Asia/Shanghai`, the Human Product Owner authorized a bounded
draft PR/review lane. This permits governance-only state synchronization,
commit/push of that documentation delta, and draft PR creation; it does not
authorize merge, undraft, Product/Release closure, or either Assignment's
closure. The lane is governed by
[`AUTH-TYPO-CORRECTION-002-F01-PR-REVIEW-001`](../authorizations/AUTH-TYPO-CORRECTION-002-F01-PR-REVIEW-001.md).

## Boundary

### Scope

1. Correct the production RIME deployment identity seam so unavailable librime
   identities are fail-closed, including the Objective-C bridge sentinels
   `(no api)` and `(unknown)` after bounded normalization.
2. Add direct negative coverage for nil, empty/whitespace, and both production
   sentinel values, plus the smallest direct forwarding/normalization coverage
   available through the existing test seam.
3. Produce an executor evidence record bound to the exact candidate tree,
   changed files, commands, environment, results, and non-claims.
4. Request fresh independent Architecture/Quality review after the candidate is
   complete. Any review must bind to the exact candidate it evaluates.

### Non-goals

- Any typo-correction algorithm, sidecar query, candidate ranking, candidate
  count, latency policy, input history, or AI/model work.
- RIME schema, user dictionary, deployment package, fixture provenance, or
  vendor archive changes.
- Device Hub, real-device, Simulator capture, `INT-003`, `QA-001`, paired
  performance, TestFlight, App Store, Release, or Product Gate work.
- Changes to the parent Assignment's status, scope, evidence, or closure.
- Changes to the broad provenance/sidecar worktree or the user's dirty main
  checkout.
- Commit, push, pull request creation/modification, merge, tag, branch cleanup,
  or external publication. These require separate explicit authorization.

## Responsibilities

- **Domain Owner:** RIME Platform Maintainer, for the librime identity contract
  at the Main-App deployment boundary.
- **Executor:** Current Codex task in the isolated remediation worktree. The
  executor must not act as the independent Quality Reviewer.
- **Environment Executor:** Quality, Performance & Release Maintainer for
  independent local-gate interpretation; no device action is in scope.
- **Architecture Reviewer:** Architecture & Knowledge Steward, if the chosen
  implementation changes the source identity contract or crosses package
  boundaries.
- **Quality Reviewer:** Independent Quality, Performance & Release Maintainer
  who did not author the remediation.
- **Product Approver:** Human Product Owner acting as Product Lead.

## Gates

### Entry criteria

- The parent `TYPO-CORRECTION-002` Assignment is known to remain Active.
- The preceding F-01 independent review identified the sentinel acceptance as
  Quality P1 and placed the original tip on Product Hold.
- The remediation is bound to exact base `409eeab8...316ce` and the isolated
  branch/worktree named above.
- The new Authorization is recorded before implementation proceeds.

### Exit criteria

- Production identity handling rejects nil, blank, `(no api)`, and `(unknown)`
  as unavailable, without changing the normal valid-version path.
- Focused direct tests and the required local quality checks pass on the exact
  candidate state, with no raw user input or device claims in evidence.
- Executor evidence records the candidate identity. If a later review requires
  a commit SHA, that SHA must be created and separately authorized; prior
  receipts cannot be silently reused for a changed candidate.
- Independent Architecture/Quality review is requested with explicit residual
  non-claims. Product acceptance remains a separate later decision.

### Stop conditions

- The fix requires schema, dictionary, sidecar, candidate-ranking, device,
  performance, or Product Gate changes.
- The source identity cannot be bound to the exact candidate, or a test result
  cannot be shown to run against that candidate.
- A reviewer is not independent, or a new finding expands the scope.
- Commit, push, PR, merge, publication, or parent-Assignment closure is
  requested without fresh authorization.

## Handoff and revalidation

- **Handoff target:** Product Lead review of the exact-commit revalidation
  result, after independent Architecture/Quality review of commit
  `781ba235009e19a0be8b810a3441647dbcc23eb0` returned `Pass with conditions`.
  The parent Assignment remains Active.
- **Revalidation triggers:** base commit change; source identity or bridge API
  change; any scope expansion; new reviewer finding; candidate commit created;
  request for device/performance/evidence work; request for commit, push, PR,
  merge, Release, or Assignment closure.

## Evidence policy

All evidence produced here is executor evidence until an independent reviewer
records a separate conclusion. The previous `409eeab` evidence remains bound to
that exact candidate and is not edited or relabeled as evidence for this
remediation.

Current executor receipt: [`typo-correction-002-f01-remediation-001-executor-evidence.md`](../evidence/typo-correction-002-f01-remediation-001-executor-evidence.md). It remains bound to the pre-commit executor candidate and is not relabeled as the independent review of `781ba235`.

Current revalidation Authorization: [`AUTH-TYPO-CORRECTION-002-F01-COMMIT-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-F01-COMMIT-REVALIDATION-001.md).

Current exact-commit revalidation evidence: [`typo-correction-002-f01-commit-revalidation-001.md`](../evidence/typo-correction-002-f01-commit-revalidation-001.md).

Current PR/review handoff: [draft PR #139](https://github.com/shchnk1103/Universe-Keyboard/pull/139). Hosted run `35362365167` is fully green for head `6e6374e`; the evidence is recorded in [`typo-correction-002-f01-pr-review-001-hosted-run-2026-09-18.md`](../evidence/typo-correction-002-f01-pr-review-001-hosted-run-2026-09-18.md). The next decision is a separate Product/Assignment decision on child closure; this PR/review authorization does not include closure.
