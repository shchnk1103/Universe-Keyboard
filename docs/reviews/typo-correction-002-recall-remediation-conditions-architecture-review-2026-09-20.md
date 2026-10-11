# Independent Architecture Re-review: B1–B3 condition reconciliation

## Review identity

| Field | Value |
|---|---|
| **Verdict** | `Pass with conditions` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-001`](../assignments/typo-correction-002-recall-remediation-001.md) |
| **Authorization** | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CONDITIONS-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CONDITIONS-ARCHITECTURE-001.md) |
| **Conditions reconciliation tip** | `73114ed6fefe8bda95553fe8636e8a43b7828537` |
| **Current documentation tip** | `163aeef980cd3d6fd012d1edb3d3c631a7f00ed9` |
| **Source implementation freeze** | `fb27b24ff85c48302e85309e834dbbe9a777871e` |
| **Review mode** | Independent read-only source/design review; no file changes by reviewer |

## Verdict

The B1–B3 reconciliation is sufficient to enter a **bounded Product Lead
implementation decision**. It is not sufficient to authorize production code
directly.

### B1 — Counters and cancellation contract

Pass at the design-contract level:

- `N_generated`, `N_query_attempts`, `N_resolved_groups` and
  `N_candidates_returned` are distinct;
- `maxQueryAttempts` is correctly required as a future stage-level hard cap,
  while its numeric value remains `UNKNOWN`;
- cancellation before/after each query and between batches,
  composition revision/epoch validation, stale-result disposal and publish
  fencing are explicitly required.

These are not current implementation proofs. The frozen controller still lacks
the second-stage total attempt cap and stale-publish fence.

### B2 — Contextual 7/8 boundary

Pass. The matrix correctly keeps contextual 7-character rejection and
8-character acceptance `UNKNOWN`. The exact current contextual tests cover
`5/31`; `zhonghuo → zhongguo` remains legacy single-edit evidence, and the
generic Registry row is not used to close the contextual boundary.

### B3 — Edit-operation scope

Pass with a strict slice boundary. The first implementation slice is
substitution-only. Transposition, deletion and insertion remain excluded until
they each receive safety rules and evidence. Two-edit results remain
display-only, with no automatic promotion, silent rewrite, commit or host-text
mutation.

## Preserved budget boundaries

- Production: `12` first-layer / `8` final contextual hypotheses.
- Preflight: `60` first-layer / `64` final hypotheses / batch ≤ `8`.
- Corrected-input query: limit `3` candidates.
- Resolved groups: at most `4` non-empty groups.
- `4 × 3 = 12` remains only a conditional returned-candidate ceiling, not a
  query-attempt, cancellation or performance bound.

## Remaining implementation blockers

1. Select and bind a concrete `maxQueryAttempts` value.
2. Implement and verify cancellation, revision/epoch, stale-result discard and
   publish fencing.
3. Measure production frontier rank and the smallest useful expansion
   threshold before choosing a second-stage trigger or cap.

## Product handoff

The lane may proceed to a bounded Product Lead decision covering the strategy
and a future implementation-preflight slice. It must not be described as a
production implementation approval. F-01 remains outside this lane.

## Non-claims and operation boundary

This review is not a Product or Quality Gate, QA-001, INT-003, paired-
performance, 180 ms, real-RIME candidate-quality, PR, merge, Release or
parent-close conclusion. No build/test was run; no installation, Simulator or
device capture, Run ID or RIME query was performed; the reviewer changed no
files.
