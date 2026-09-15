# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 P0 Architecture Re-review

- Review mode: independent, read-only architecture review
- Review date: 2026-09-14
- Agent id: `CODEX_SESSION_ID=01a09b4a-6226-7f50-8b29-a5647bf1620e`
- Thread id: `CODEX_THREAD_ID=01a09f58-6bc0-7820-bfbe-f32436252aa3`
- Agent version: `CODEX_VERSION=0.154.0-alpha.6.2`
- Worktree: `/private/tmp/universe-keyboard-kos-upgrade-uk-005`
- Branch: `codex/kos-upgrade-uk-005-release-evidence`
- Worktree HEAD checked: `3139f8d3bdb6be6622504ea731988f42681896fb`
- Exact P0 package digest checked: `8ded6d8937e7bc19f38fc3fe432b2174f05aa375037d07a9a5922a557d7ff4f0`
- P0 package order: `.kos/project.json`, `docs/ACTIVE_WORK.md`, `docs/kos/README.md`, `docs/kos/UPGRADE_STATUS.md`, `docs/product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md`, `docs/authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001.md`, `docs/assignments/kos-release-evidence-implementation-001.md`, `docs/kos/release-evidence-profile.md`
- Digest reproduction: `cat <the eight files in the frozen manifest order> | shasum -a 256`; independently reproduced the exact digest above.

## Verdict

**Changes Requested — P0 Architecture handoff 尚未通过。**

The package establishes the intended governance boundaries and most of the release-evidence semantics, but the Profile owner map and the evaluator/pointer contract still contain three P1-level architecture ambiguities. They must be closed before the P0 handoff can be treated as complete. This verdict is about the P0 architecture handoff only; it is not a Product Gate, Quality acceptance, merge decision, or Release decision.

## Finding count

| Priority | Count |
|---|---:|
| P0 | 0 |
| P1 | 3 |
| P2 | 0 |
| P3 | 0 |

## Findings

### P1 — A-RE-P1-01: portable-field ownership is not yet leaf-exact

`docs/kos/release-evidence-profile.md` presents a field-level table and states that each row has one canonical owner, but several rows still use wildcard/object-level fields such as `observations.*`, `delivery.*`, `final_validation.*`, and the whole `provenance` object. The table also combines non-owner roles into one column rather than separately naming producer, reviewer, display, and Human authority. Several owners are generic project-owner labels rather than an explicit binding to the durable role/task source. In addition, `candidate.final_tree_digest` and `candidate.candidate_head` are sourced from P-01/D-01 receipts, which can blur candidate-identity production with later validation receipts.

Required closure: enumerate every portable leaf (or explicitly define a justified closed object boundary), name exactly one canonical owner and one canonical source/identity for each, and separately name producer, reviewer, display owner, and Human authority where applicable. Bind the candidate identity producer to an upstream source distinct from P-01/D-01 validation evidence. Do not treat the existing combined “Other roles” column as four separate authorities by implication.

### P1 — A-RE-P1-02: derived-state precedence is not fully aligned with the pinned evaluator

The Profile's prose says that a delivery, final-validation, provenance, or other failure yields `none`, while the pinned evaluator gives promotion state precedence and can return `comparator` when all required claims are `non-comparable`. An exact in-memory probe against the pinned candidate evaluator produced `derived_status=comparator` for a current envelope whose observation was bound to another candidate and whose delivery relation was `ahead`. This is not equivalent to a blanket `none` rule. The package therefore does not yet provide one unambiguous derived-state matrix for invalid input, future/stale, pending/none, comparator, and current-proof precedence.

Required closure: publish the exact precedence table used by the pinned evaluator, including candidate identity mismatch, future and stale observations, invalid input, promotion `pending`/`none`, all-`non-comparable` comparator, and current-proof. Add deterministic fixtures or equivalent review evidence for the boundary combinations; do not infer the result from a prose shortcut.

### P1 — A-RE-P1-03: pointer integrity and lifecycle grammar remain internally inconsistent

The Profile says the adapter accepts only bounded, digest-bearing pointers, but its `appdiag://release-evidence/<record-id>/<operation-uuid>;class=<retention-class>` form has no digest, and the lifecycle rule says to match a declared digest “when a digest is present”. This makes integrity optional for one pointer class. In addition, several content-bearing fields remain free-form at this layer, including `source_ref`, `comparison_basis`, `scope`, baseline/history reasons, checker references, and output references; their grammar, accessibility, redaction, retention, and deletion semantics are not uniformly constrained.

Required closure: choose and specify either a mandatory integrity digest for every pointer or an explicit immutable opaque receipt identity plus a separate required integrity mechanism. Define the accepted grammar and access/retention/deletion behavior for each pointer/reference field, including Main-App ownership and export redaction. This is a P0 architecture contract issue for the later adapter/persistence boundary, not an invitation to implement runtime storage in this review.

## Requested review areas

| Area | Result | Evidence boundary |
|---|---|---|
| Product Decision → Authorization → Assignment authority chain | Pass at contract level | PD is the accepted Human Product Owner decision; AUTH names that PD as decision source and parent; Assignment names AUTH/PD and separates Product Lead, Human Product Owner, executor, and review roles. |
| `v0.8.0` versus untagged candidate layering | Pass | `v0.8.0` remains the advisory adopted pin; the candidate is explicitly untagged and prospective, not a Kit Release or new formal Release. |
| Portable-field canonical ownership and role separation | **Fail — A-RE-P1-01** | The table exists, but wildcard/object ownership, generic owner labels, combined role column, and candidate/receipt source overlap prevent the requested leaf-exact proof. |
| Pinned release-evidence evaluator semantics | **Partial — A-RE-P1-02** | Invalid-input, future/stale, pending/none, comparator, and current-proof concepts are present, but Profile prose does not exactly preserve evaluator precedence. |
| `daily_beta → external_candidate` first/subsequent and baseline/history keys | Pass at contract level | First requires no previous receipt and a current candidate-bound baseline; subsequent requires no baseline, a different same-stage/context/profile/contract previous candidate, and resolved `release_lineage` keys. |
| P-01/D-01 precise closure | Pass as a declared contract; no closure claim | P-01 requires fresh candidate-bound same-head hosted pass and matching local/published/hosted/candidate heads. D-01 requires fresh candidate-bound final-tree equality, resolved checker/version/scope/baseline/output, pass, and exit 0. The package does not claim those receipts are currently complete. |
| Content-free, Main-App, hot-path/no-network, and `evidence_ref`/`output_ref` lifecycle | **Partial — A-RE-P1-03** | Content exclusions and Main-App/no-Extension-runtime-network boundaries are explicit, but pointer integrity and reference grammar/lifecycle are inconsistent or under-specified. |
| REP-Q-01 and hosted provenance as publication blocker | Pass as an explicit residual blocker | The package still requires final SHA, actual base/head, and hosted-CI provenance; hosted tag/Release revalidation remains required before Ready/implementation closure/publication. This review does not waive that blocker. |

## Authority and layering observations

- The Product Decision is the product-adoption authority; the Authorization is the bounded permission; the Assignment is the execution envelope. The KOS validator and release-evidence evaluator are not Product, Quality, merge, or Release authorities.
- The P0 package is prospective. It does not migrate or backfill historical records, and it does not turn the untagged candidate into `v0.8.0` or a formal Kit Release.
- The package preserves a separate Main-App local evidence boundary, with no Extension runtime file I/O and no network dependency in the input hot path. The architecture review does not validate a device/runtime implementation.

## Explicit non-claims

- No Swift was written, reviewed as an implementation, or changed.
- No existing file was modified. The only file added by this review is this review artifact.
- No adapter, evaluator, schema, persistence, Main-App, Extension, hot-path, network, device, simulator, CI, archive, export, App Store Connect, TestFlight, Product Gate, Release, commit, push, merge, tag, or publication action was performed.
- No `current-proof`, P-01 receipt, D-01 receipt, hosted-CI pass, final SHA/base-head provenance, or publication readiness is asserted.
- No claim is made that the P0 exit checkboxes are complete; the Assignment still leaves independent current P0 review and local receipt unchecked.
- No authority was expanded, no `required` adoption was inferred, and no historical migration/backfill was authorized.
- This artifact does not replace Product, Human authority, Quality, Release, or hosted provenance decisions.

## Reference comparison

For semantic comparison only, the pinned upstream source was read from `/Users/doubleshy0n/Dev/kos-agent-kit`:

- Formal tag: `v0.8.0` peeled commit `2c9907565bf6b6fcd00e698cc539d9e2db573bc5`.
- Untagged candidate implementation commit: `8e55551a3b56b57e7fc5ab5544d653f9c6854df9`.
- Current pinned-source branch commit inspected: `f5c88d57f599d7ef352322ea7664f637fb288d60`, described as `v0.8.0-2-gf5c88d5`.
- Independently checked candidate source digests: operations contract `f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673`; schema `4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce`; evaluator `a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9`.

No further implementation or repository action is authorized by this review.
