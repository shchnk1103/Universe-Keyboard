# Independent Architecture Review: bounded recall remediation

## Review identity

| Field | Value |
|---|---|
| **Verdict** | `Pass with conditions` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-001`](../assignments/typo-correction-002-recall-remediation-001.md) |
| **Authorization** | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-ARCHITECTURE-001.md) |
| **Current documentation tip** | `c38578231baa05cf76821e0db5c4bd7d68b3acfb` |
| **Design/evidence tip** | `15887247040fd2dcef43a906b14525f6f48d71ef` |
| **Source implementation freeze** | `fb27b24ff85c48302e85309e834dbbe9a777871e` |
| **Review mode** | Independent read-only source/design review; no file changes by reviewer |

This review accepts only the architecture direction of a bounded,
coverage-aware second-stage recall pass. It does not authorize implementation,
new evidence capture, Product or Quality acceptance, PR, merge, Release or
parent closure.

## Boundary verification

| Boundary | Independent conclusion |
|---|---|
| Production | `12` first-layer states and `8` final contextual hypotheses remain the production contract |
| Preflight | `60` first-layer states, `64` final hypotheses and batches of at most `8` remain pure, default-off recall evidence |
| RIME query limit | `3` returned candidates per corrected input is the product query contract; a defensive bridge cap of `8` is not the product contract |
| Resolved groups | `4` limits non-empty resolved groups, not query attempts |
| Static candidate count | `4 × 3 = 12` is only a returned-candidate ceiling under the stated assumptions; it is not a query-attempt, cost or cancellation guarantee |

The preflight local rank `55` is correctly retained as expanded-search
evidence. It is not treated as production-frontier rank, production-final-8
survival, real-RIME candidate visibility or QA/Product evidence.

## Conditions that block implementation

### B1 — Independent total query-attempt and cancellation contract

`resolved-group = 4` cannot replace an explicit total `maxQueryAttempts`.
Before implementation, the design must define and later measure separately:

- `N_generated`;
- `N_query_attempts`;
- `N_resolved_groups`;
- `N_candidates_returned`.

The contract must also specify cancellation checks between batches and before
and after each query, composition revision/epoch validation, stale sidecar
result disposal and a rule that a cancelled or stale operation cannot publish
`state.typoCorrection`.

The current controller can statically inspect up to approximately `8 + 16`
hypotheses when contextual and legacy suggestions are combined. This is a
design-bound observation, not a performance measurement.

### B2 — Exact 7/8 contextual boundary

The Registry names a `7/31` boundary case, while the current exact
contextual tests visibly cover `5/31`. The present matrix must not claim that
the contextual 7-character rejection and 8-character acceptance pair is
closed until exact evidence is located or separately authorized. If no such
evidence exists, both fields remain `UNKNOWN`.

### B3 — Explicit second-stage edit-operation policy

The contextual generator contains substitution, transposition, deletion and
insertion paths, but the proposed second stage currently names only generic
“safe edits”. Before implementation, the design must state which operations
are permitted and bind each operation to its safety guard. The recommended
first slice is **substitution-only**, because the canonical case uses two safe
substitutions and the existing replacement guard is already explicit. Any
other operation requires a separate safety decision.

Two-edit results remain display-only; no automatic promotion, silent rewrite,
commit or host-text mutation is permitted.

## Boundary review

- **Privacy:** Pass. The direction uses only the local composition and bounded
  edit hypotheses; it does not require host text, clipboard, history, network
  input or persistence.
- **Sidecar:** Pass. Real-RIME work remains isolated from the live session.
- **Hot path:** Pass with conditions. Work remains post-pause, but a total
  attempt budget and cancellation fence are required before implementation.
- **Marked text:** Pass with conditions. Any future publish must revalidate the
  current composition revision/epoch and discard stale results.

## Non-claims

This review does not establish real-RIME candidate quality, QA-001, INT-003,
paired performance, 180 ms compliance, Product Gate, Quality Gate, local-model
need, PR readiness, merge readiness, Release readiness or parent closure.

## Recommended next step

Perform a docs-only condition reconciliation for B1–B3 under a new bounded
Authorization, then request a fresh independent Architecture re-review. No
implementation Authorization should be issued before that re-review.

## Operation boundary

No build/test was run. No installation, Simulator/device capture, Run ID or
RIME query was performed. No source, test or existing receipt was modified by
the reviewer.
