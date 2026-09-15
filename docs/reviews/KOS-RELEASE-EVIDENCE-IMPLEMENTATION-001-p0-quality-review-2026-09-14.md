# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 — P0 Independent Quality / Performance / Release Review

## Review boundary

| Field | Value |
|---|---|
| Mode | Read-only independent review; only this review record was authorized for addition |
| Worktree | `/private/tmp/universe-keyboard-kos-upgrade-uk-005` |
| HEAD | `3139f8d3bdb6be6622504ea731988f42681896fb` |
| P0 digest | `6892e9d437139d71b4d2b1a006af9ac0f1451a68df077816726add33534e6a4a` |
| Digest result | Recomputed target = freeze record = exact match |

The digest was recomputed with the specified ordered raw-byte concatenation of the eight
P0 files. The review record is not part of that digest.

## Conclusion

**Changes Requested** — this is a contract/Profile review conclusion only; the P0 handoff
is not ready to pass.

| Severity | Count |
|---|---:|
| P0 | 3 |
| P1 | 4 |
| P2 | 0 |
| P3 | 0 |

## What passed

- Product Decision → Authorization → Assignment chain is bounded to prospective new
  records; E-01/P-01/D-01 are explicitly opted in, A-01/B-01 is outside P0/P1, and
  `required` plus historical migration remain unauthorized.
- The content-free, Main-App-owned, no synchronous Extension I/O/network allowlist and
  forbidden-field boundary are explicit.
- Daily Beta reuse is correctly conditional on exact identity/context/freshness/coverage/
  comparison and same-candidate delivery/final-validation bindings.
- P-01/D-01 are described as evidence receipts rather than authority; `REP-Q-01` and
  hosted provenance remain visible blockers.
- Independent local rerun of `validate-kos.sh` returned exit `0`; only pre-existing
  unrelated legacy warnings appeared, and the validator itself states that structural
  success is not a Product/Quality/Gate/Release decision.

## Findings

| ID | Sev | Finding and required closure |
|---|---|---|
| `Q-RE-P0-01` | P0 | The Profile owner map is not yet one-owner-per-portable-field. It is dimension-level and uses `plus`, `and`, `with` and `/`; `record_id`, `policy.required_claim_bindings`, `provenance` and the evaluator `as_of` owner/source are not separately mapped. The Assignment also points to an uncommitted main-worktree implementation input with no stable repository identity. Name one canonical owner and one canonical source for every envelope field; separately identify producer, reviewer, display surface and Human authority. [`Profile`](../kos/release-evidence-profile.md#L35) · [`Assignment`](../assignments/kos-release-evidence-implementation-001.md#L96) |
| `Q-RE-P0-02` | P0 | The derived-state matrix is not exact against the pinned evaluator. The Profile says a declared target with a missing target binding, first baseline or subsequent history is `pending`; the evaluator returns `pending` when the target binding is unbound, but returns `none` when a bound target fails baseline/history requirements. The Profile also does not state that overall `comparator` requires all required claims to be non-comparable. Align the Profile and future fixtures with the candidate semantics, including partial-mismatch and bound-target cases. [`Profile`](../kos/release-evidence-profile.md#L96) |
| `Q-RE-P0-03` | P0 | Freshness representation is ambiguous and can produce an invalid Envelope: the Profile says observations store `as_of`, but the pinned schema has no observation `as_of`; the evaluator receives `as_of` as its required external `--as-of` input. The Profile also classifies an unparsable time as stale/blocked, while the evaluator rejects invalid time input rather than emitting a derived stale state. Define the evaluation clock/owner/receipt location, keep `observed_at` and `freshness.valid_until` distinct, declare the concrete `policy.max_age_days` source, and distinguish invalid input from derived stale/conflict. [`Profile`](../kos/release-evidence-profile.md#L37) · [`Profile`](../kos/release-evidence-profile.md#L89) |
| `Q-RE-P1-01` | P1 | First/subsequent history is described conceptually but not executable: no project `source_stage`/`target_stage` mapping, explicit baseline/previous-receipt policy booleans, `previous_receipt_identity_keys`, or named baseline/history receipt source; the subsequent “baseline must be null” negative rule is also absent. Bind these before P1 implementation. [`Profile`](../kos/release-evidence-profile.md#L104) |
| `Q-RE-P1-02` | P1 | The P-01/D-01 boundary is directionally correct, but the Profile should carry the exact fail-closed conditions: `relation=same-head`, hosted result `pass`, local/published/hosted heads all equal to `candidate_head`, and D-01 final-tree equality plus resolved checker/scope/output, exit `0`, result `pass`. This prevents a later adapter from treating a relation label or green local check as coverage. [`Profile`](../kos/release-evidence-profile.md#L44) |
| `Q-RE-P1-03` | P1 | The P0 freeze records exact JSON, `git diff --check` and KOS-validator commands, but not the exact command for the bounded Markdown/link check; `git diff --check` does not inspect untracked files. The upstream release-evidence evaluator/schema were not run because no Envelope exists, which is honest but should be recorded explicitly as not-run/not-applicable rather than inferred from KOS validation. [`P0 freeze`](../evidence/kos-release-evidence-implementation-001-p0-freeze-2026-09-14.md#L44) |
| `Q-RE-P1-04` | P1 | The allowlist forbids full logs and unbounded dumps, but does not define stable `evidence_ref`/`output_ref` formats, redaction/access roles, retention or deletion ownership. Add that pointer-lifecycle boundary before implementing Main-App persistence; a content-free record must not become a pointer to unrestricted user data. [`Profile`](../kos/release-evidence-profile.md#L63) |

## Open residuals / blockers

- `REP-Q-01` remains open: no final Universe implementation SHA, actual base/head pair
  or hosted-CI provenance exists. It blocks later implementation/publication readiness,
  not the fact that the adoption decision was recorded.
- Hosted tag/Release revalidation remains unavailable after the recorded network failure;
  unavailable is not evidence of hosted Release absence. Re-run the exact probe before
  `Ready`, implementation closure or publication handoff.
- No current external-candidate receipt, verified first baseline or subsequent previous
  receipt exists in this P0 package.
- The Assignment's P0 exit checklist still has owner-map, derived-rule, independent-review
  and local-receipt items open; this review closes none of those items by itself.

## Complete non-claims

This review does not claim or authorize: Product adoption beyond the recorded Product
Decision; Product Gate, Quality Gate, Release Pass or external-candidate `current-proof`;
P-01 delivery receipt or D-01 final-validation receipt; final SHA/base-head equality or
hosted-CI coverage; hosted tag/Release presence or absence; Swift/runtime/App Group,
Simulator/device, performance, archive/export, App Store Connect or TestFlight evidence;
historical migration/backfill; implementation, commit, push, merge, tag, publication or
Release; or any modification to packet, Profile, Assignment, status mirror or implementation
files. The KOS validator exit `0`, digest match and this review are not any of those Gates.
