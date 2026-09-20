# Product Decision: bounded recall remediation direction

## Decision identity

| Field | Value |
|---|---|
| **Decision** | `Bounded Accept with conditions — proceed to implementation-preflight only` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-001`](../assignments/typo-correction-002-recall-remediation-001.md) |
| **Authorization** | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PRODUCT-DECISION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PRODUCT-DECISION-001.md) |
| **Architecture input** | [`conditions re-review`](../reviews/typo-correction-002-recall-remediation-conditions-architecture-review-2026-09-20.md) |
| **Decision evidence tip** | `163aeef980cd3d6fd012d1edb3d3c631a7f00ed9` |
| **Source implementation freeze** | `fb27b24ff85c48302e85309e834dbbe9a777871e` |
| **Decision date** | `2026-09-20 Asia/Shanghai` |

## Product disposition

The Product Lead accepts the **direction**, not production implementation:

1. Explore a coverage-aware second-stage recall pass after the existing fast
   production `12/8` pass.
2. Keep the first implementation slice substitution-only.
3. Keep two-edit results display-only; no automatic promotion, silent rewrite,
   commit or host-text mutation.
4. Keep the 60/64/8 planner default-off and separate from production.
5. Keep real-RIME work in an isolated sidecar session and preserve the
   local-only privacy boundary.
6. Treat the local-model question as deferred; this decision does not approve
   a bundled or cloud model.

## Conditions before runtime implementation

The next step may request a separate **implementation-preflight
Authorization**, but production code is not authorized by this decision. That
preflight must first establish:

- production frontier rank and the smallest useful expansion threshold;
- a concrete stage-level `maxQueryAttempts` value and binding location;
- separate measurements for `N_generated`, `N_query_attempts`,
  `N_resolved_groups` and `N_candidates_returned`;
- cancellation before/after each query and between batches;
- composition revision/epoch checks, stale sidecar result disposal and a
  publish fence that prevents stale `state.typoCorrection` updates;
- focused tests for substitution-only operation filtering and display-only
  multi-edit behavior;
- explicit treatment of the contextual 7/8 boundary, which remains
  `UNKNOWN` unless exact evidence is obtained.

The preflight must use a new Authorization and exact source/package identity.
It must not use FakeCandidateProvider, an old Ice directory, host text,
clipboard, network or a new device Run as a substitute for pure recall
coverage.

## Explicit non-claims

This is not:

- a Product Gate or Quality Gate;
- a QA-001, INT-003, real-RIME candidate-quality or 180 ms result;
- approval to change production `12/8`;
- approval to wire preflight `60/64/8` into the keyboard;
- approval to add a local/cloud model;
- implementation, PR, merge, Release or parent Assignment closure.

## Next action

Create a separate bounded implementation-preflight Assignment/Authorization
for pure KeyboardCore coverage and contract tests. Only after that preflight
selects a defensible cap and passes independent Architecture/Quality review
should a later Authorization consider production wiring and real-RIME evidence.
