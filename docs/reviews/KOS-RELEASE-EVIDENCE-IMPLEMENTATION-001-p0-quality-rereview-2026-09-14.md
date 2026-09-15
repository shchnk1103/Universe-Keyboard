# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 — P0 Quality / Evidence Re-review

## Review identity and boundary

| Field | Value |
|---|---|
| Reviewer | Independent Quality / Evidence Reviewer |
| Agent ID | `01a09b4a-6226-7f50-8b29-a5647bf1620e` (current Codex task/runtime binding) |
| Review date | `2026-09-14 Asia/Shanghai` |
| Review mode | Read-only independent re-review; this file is the only permitted addition |
| Worktree | `/private/tmp/universe-keyboard-kos-upgrade-uk-005` |
| Worktree branch / HEAD | `codex/kos-upgrade-uk-005-release-evidence` / `3139f8d3bdb6be6622504ea731988f42681896fb` |
| Exact P0 package digest | `8ded6d8937e7bc19f38fc3fe432b2174f05aa375037d07a9a5922a557d7ff4f0` |
| P0 digest scope | Ordered raw-byte concatenation of the eight files listed in the P0 freeze receipt; the freeze receipt, existing reviews and this review are excluded |
| Pinned semantic reference | `/Users/doubleshy0n/Dev/kos-agent-kit` at implementation commit `8e55551a3b56b57e7fc5ab5544d653f9c6854df9`; contract/schema/evaluator digests match the Profile |

This review is limited to the P0 contract/Profile/owner-map package. It does not review
or authorize Swift, Main-App storage, Keyboard Extension behavior, CI workflow changes,
device or archive evidence, hosted publication, Product Gate, Quality/Release Gate or
formal Release.

## Verdict

**Changes Requested — P0 handoff is not ready for P1 implementation.**

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 2 |
| P2 | 0 |
| P3 | 0 |

The package successfully closes the earlier semantic gaps around freshness, derived
states, promotion history, P-01/D-01 and the executor receipt. Two P1 contract/document
residuals remain: project-owned source boundaries are not uniformly locatable, and the
declared pointer grammar contradicts itself on digest requirements.

## Integrity and read-only verification

- Recomputed the P0 manifest with the receipt's exact command and obtained exactly
  `8ded6d8937e7bc19f38fc3fe432b2174f05aa375037d07a9a5922a557d7ff4f0`.
- `python3 -m json.tool .kos/project.json` passed.
- `git diff --check` passed.
- Re-ran the bounded eight-file JSON/Markdown link and trailing-whitespace check; it
  covered the manifest files even though several are untracked and returned
  `docs-json-links=ok files=8 trailing-whitespace=ok directory-targets=accepted`.
- Re-ran the recorded KOS validator read-only with `KOS_AS_OF=2026-09-14T17:54:12+08:00`
  and the absolute `validate-kos.sh` command. It exited `0`; only pre-existing unrelated
  legacy warnings appeared, and the validator itself states that structural success is
  not Product, Architecture, Quality, Gate, merge or Release approval.
- The P0 receipt records that the pinned release-evidence schema/evaluator were **not
  run** because P0 contains no Envelope. No Envelope was fabricated or evaluated in
  this re-review.

## Requested boundary checks

| Area | Result | Evidence / exact boundary |
|---|---|---|
| Owner map and source boundary | **P1 residual** | The Profile has one canonical owner per listed row and separates producer/reviewer/display/Human roles. Candidate/artifact/head/provenance rows visibly preserve pre-freeze or `REP-Q-01` status. However, `record_id`, `observations.*`, the project provenance receipt and policy/promotion instance sources still use generic or unlinked names such as `RELEASE-EVIDENCE-PROMOTION-001`, “existing project release-evidence/diagnostic evidence boundary” and “future handoff record”; they are not uniformly locatable to a path/anchor or stable receipt identity. [`Profile`](../kos/release-evidence-profile.md#L35-L78) · [`Assignment source boundary`](../assignments/kos-release-evidence-implementation-001.md#L96-L114) |
| `as_of` / `observed_at` / `valid_until` / `max_age_days` | Pass for P0 semantics | The Profile correctly places timezone-bearing evaluator `--as-of` outside the Envelope and observation, keeps `observed_at` distinct from `freshness.valid_until`, requires explicit `policy.max_age_days`, and rejects invalid policy/time input. The pinned evaluator additionally enforces the duplicated freshness timestamp equality and `valid_until >= observed_at`; these remain P1 fixture obligations, not P0 execution evidence. [`Profile`](../kos/release-evidence-profile.md#L61-L65) [`Profile`](../kos/release-evidence-profile.md#L80-L89) · pinned evaluator `validate_release_evidence.py` `L340-L349`, `L517-L543` |
| Invalid input and derived states | Pass | Invalid JSON/contract shape, unknown keys, unparseable or timezone-less timestamps, invalid `as_of` and invalid policy fail evaluation with no derived classification; they are not relabeled `stale`, `blocked`, `none` or `pending`. For valid input, future observations are claim `blocked`; expired observations are `stale`; all current fresh comparable passes plus required receipts can be `current-proof`; all required claims non-comparable are `comparator`; a missing promotion target is `pending`; a bound target with missing/invalid baseline, history, claim, delivery, final validation or provenance is `none`; partial mismatch is not `comparator`. [`Profile`](../kos/release-evidence-profile.md#L149-L183) · pinned evaluator `L846-L960` |
| First/subsequent promotion | Pass | The project mapping is explicit: `source_stage=daily_beta`, `target_stage=external_candidate`, sequence exactly `first` or `subsequent`; first requires current-candidate baseline and `previous_target_receipt=null`; subsequent requires `baseline=null`, a different previous candidate and `previous_receipt_identity_keys=["release_lineage"]` resolved in both artifact identities. Providing a baseline for subsequent or a previous receipt for first is a bound-target `none` rule. [`Profile`](../kos/release-evidence-profile.md#L172-L183) [`Profile`](../kos/release-evidence-profile.md#L185-L212) · pinned evaluator `L708-L747` |
| P-01 | Pass | Current delivery requires a fresh candidate-bound receipt, `relation=same-head`, `hosted_ci_result=pass`, matching comparison basis, and `local_head == published_head == hosted_ci_head == candidate_head`; missing/unknown heads, non-pass hosted result or another relation is fail-closed. [`Profile`](../kos/release-evidence-profile.md#L214-L222) · pinned contract `ops/release-evidence.md` `L85-L98` · pinned evaluator `L774-L798` |
| D-01 | Pass | Current final validation requires fresh candidate binding, `final_tree_digest == candidate.final_tree_digest`, resolved checker reference/version/scope/comparison baseline/output reference, `result=pass` and `exit_code=0`; a changed tree requires a new receipt. [`Profile`](../kos/release-evidence-profile.md#L214-L227) · pinned contract `L100-L107` · pinned evaluator `L801-L826` |
| P0 executor receipt | Pass | The freeze receipt contains the exact digest command, exact bounded eight-file command including untracked files, KOS validator command/result, explicit validator non-authority text, and explicit pinned schema/evaluator `not-run` boundary. [`P0 freeze`](../evidence/kos-release-evidence-implementation-001-p0-freeze-2026-09-14.md#L19-L106) |
| `evidence_ref` / `output_ref` lifecycle | **P1 residual** | Redaction/access, bounded targets, retention classes and the release-evidence owner's write/deletion responsibility are present. The grammar is not internally stable: it says the adapter accepts only “digest-bearing” pointers, but the `appdiag://...;class=...` form has no digest; later text makes digest conditional (“when a digest is present”), and `<retention-class>` is not an enumerated grammar. [`Profile`](../kos/release-evidence-profile.md#L127-L147) |
| Product/Quality/Release/current-proof wording | Pass | Adoption is explicitly prospective and separate from the `v0.8.0` advisory pin. `current-proof` is marked as non-Product/Quality/Gate/Release acceptance; pending/comparator/none cannot authorize publication; `REP-Q-01`, hosted provenance and final SHA/base-head remain open. The receipt and status mirrors carry the same non-claims. [`Profile`](../kos/release-evidence-profile.md#L15-L17) [`Profile`](../kos/release-evidence-profile.md#L162-L170) [`Assignment`](../assignments/kos-release-evidence-implementation-001.md#L36-L44) |

## Findings requiring closure

### `Q-RE-P1-01` — Project source locations are not uniformly resolvable

The owner rows are now separated into one canonical owner, which passes the ownership
shape check. The source side is still incomplete for project-owned facts. The Profile
uses a named but unlinked implementation work item for `record_id` and candidate input,
a generic existing evidence/diagnostic boundary for `observations.*`, a generic
producer/source receipt for `provenance`, and “future handoff record” language for
policy instances. Only some rows explicitly carry the pre-freeze/no-final-SHA or
`REP-Q-01` status. A future executor cannot yet resolve every fact to one existing
Assignment/ADR/path or stable receipt identity without consulting ambient worktree state.

Required closure before P1 implementation: keep the one-owner rows, but give every
project-owned source an exact repository link/anchor or named receipt boundary; mark
whether an unresolved identity is intentionally pre-freeze or specifically owned by
`REP-Q-01`; and distinguish the Profile's policy definition from the future Envelope
fact receipt. This does not require claiming a final SHA in P0.

### `Q-RE-P1-02` — Pointer grammar is internally contradictory

The lifecycle section calls all accepted pointers “digest-bearing”, then offers an
`appdiag://release-evidence/<record-id>/<operation-uuid>;class=<retention-class>` form
without `sha256`. The later “when a digest is present” wording implies that digest is
optional, while the retention-class placeholder has no closed value grammar. The
redaction, reviewer access, retention and deletion-owner boundaries are otherwise
present and are not the finding.

Required closure before Main-App persistence: define whether each pointer form requires
or optionally carries a digest; define the stable grammar/allowed retention classes;
retain the bounded redacted-export, reviewer-access, expiry and evidence-owner deletion
rules; and preserve `UNKNOWN` only for the pinned `not-run` exception.

## Open residuals and non-claims

- `REP-Q-01` remains open. This review does not establish a final Universe implementation
  SHA, actual base/head relation, hosted-CI provenance, archive/export, device, App Group,
  App Store Connect or TestFlight evidence.
- The P0 receipt's KOS validator exit `0`, the exact P0 digest and this review are not
  Product, Architecture, Quality, Gate, merge or Release approval.
- No current external-candidate proof or `current-proof` result was produced; no P-01
  delivery receipt or D-01 final-validation receipt exists in this P0 package.
- No historical migration/backfill, implementation, commit, push, merge, tag, upload,
  publication or Release action was performed or authorized by this review.
- No existing packet, Profile, Assignment, status mirror, implementation file or other
  pre-existing worktree file was modified; only this specified review artifact was added.
