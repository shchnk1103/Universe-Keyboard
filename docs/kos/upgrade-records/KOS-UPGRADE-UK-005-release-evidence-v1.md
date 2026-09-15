# KOS Kit `kos.release-evidence` v1.0 Upgrade Record

- Owner: Human Product Owner; executor: current Codex runtime.
- From: adopted `v0.8.0` advisory, commit `2c9907565bf6b6fcd00e698cc539d9e2db573bc5`.
- Target: optional `kos.release-evidence` v1.0 candidate, implementation commit
  [`8e55551a`](https://github.com/shchnk1103/kos-agent-kit/commit/8e55551a3b56b57e7fc5ab5544d653f9c6854df9),
  adoption metadata commit
  [`f5c88d5`](https://github.com/shchnk1103/kos-agent-kit/commit/f5c88d57f599d7ef352322ea7664f637fb288d60)。
  At the snapshot time, no local tag points at the implementation commit. Hosted GitHub
  Release metadata was not independently re-fetched because the network probe failed;
  the KOS adoption record is the source of the current no-tag/no-Release statement and
  this fact must be revalidated before `Ready` or any project adoption.
- Checked at: `2026-09-14T17:07:29+0800`; method and outputs are in the
  [UK-005 preparation evidence](../../evidence/kos-upgrade-uk-005-release-evidence-v1-preparation-2026-09-14.md).
- Disposition: **Adopted prospectively** — the exact untagged candidate is adopted as a
  project-level optional contract for new release-evidence records and handoffs; the
  current `v0.8.0` Kit pin remains unchanged.
- Reason: the independent Architecture and Quality packet re-reviews passed, and the
  Human Product Owner recorded the project adoption decision. This record's frozen
  pre-decision assessment remains historical evidence for that decision.
- Risk: pinning an untagged upstream implementation as if it were a Kit Release would
  make the project's Upgrade Status ambiguous; adopting before the current local candidate
  has a final SHA would also confuse a worktree snapshot with a publication fact.
- Next handoff: the implementation Assignments own `REP-Q-01` and hosted-provenance
  closure; the separate P1-B Product Decision records duplicate UI/storage as
  `Not applicable` and migration/backfill/background sync as `Deferred`/unauthorized.
- Revalidation: new upstream tag/Release, any change to the pinned commits/digests, local
  finalization or semantic change of `RELEASE-EVIDENCE-PROMOTION-001`, or a request to
  migrate an existing Active Assignment.

## Current project disposition

The project-level adoption authority is [`PD-KOS-UPGRADE-UK-005`](../../product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md).
The review-only Assignment is [`KOS-UPGRADE-UK-005`](../../assignments/kos-upgrade-uk-005-release-evidence-v1.md),
now `Closed` after the exact-digest Architecture and Quality re-reviews and the Human
Product Owner disposition. The implementation handoff remains split between the parent
and child Assignments; it is not closed by this upgrade review.

The P1-B scope authority is [`PD-KOS-UPGRADE-UK-005-P1-B-SCOPE`](../../product-decisions/KOS-UPGRADE-UK-005-P1-B-scope.md):

- duplicate Main-App release-evidence UI/storage, retention/clear behavior and export
  work is `Not applicable` for the current objective because the existing
  `RELEASE-EVIDENCE-PROMOTION-001` implementation already owns that boundary;
- historical migration/backfill is `Deferred` and does not rewrite existing evidence;
- background sync, credentials, upload and runtime network are `Deferred` and not
  authorized;
- no new P1-B implementation Assignment exists unless Product later supersedes this
  decision with a precise residual scope.

These decisions do not close `REP-Q-01`, hosted provenance, current-proof or any
Product/Quality/Release Gate.

## Frozen upstream source map

| Artifact | Exact pin | Digest / boundary |
|---|---|---|
| Contract Source of Truth | `ops/release-evidence.md` at `8e55551a` | `f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673` |
| Standalone schema | `schemas/release-evidence-v1.schema.json` at `8e55551a` | `4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce` |
| Reference evaluator | `scripts/validate_release_evidence.py` at `8e55551a` | `a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9` |
| Adopter profile | `templates/docs/RELEASE_EVIDENCE_PROFILE.md` at `8e55551a` | Project-specific owners, privacy and Gate facts remain local |
| Candidate tree | reviewed implementation candidate | `fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9` |

The source map covers the optional contract only. It does not change the project's
current `v0.8.0` pin, KOS 2.2 advisory mode, existing record schema or validator.

### Candidate digest algorithm and manifest

The candidate tree digest is SHA-256 of the ordered raw-byte concatenation, without
separators, of these files; the evidence receipt is excluded:

```text
README.md
docs/adoption-guide.md
docs/assignments/KOS-RELEASE-EVIDENCE-PORTABILITY-001.md
docs/assignments/KOS-RELEASE-EVIDENCE-PORTABILITY-002.md
ops/release-evidence.md
schemas/release-evidence-v1.schema.json
scripts/validate_release_evidence.py
templates/docs/RELEASE_EVIDENCE_PROFILE.md
tests/fixtures/release_evidence_cases.json
tests/test_release_evidence.py
```

The canonical reproduction command is:

```bash
cat README.md docs/adoption-guide.md \
  docs/assignments/KOS-RELEASE-EVIDENCE-PORTABILITY-001.md \
  docs/assignments/KOS-RELEASE-EVIDENCE-PORTABILITY-002.md \
  ops/release-evidence.md schemas/release-evidence-v1.schema.json \
  scripts/validate_release_evidence.py templates/docs/RELEASE_EVIDENCE_PROFILE.md \
  tests/fixtures/release_evidence_cases.json tests/test_release_evidence.py \
  | shasum -a 256
```

The executor recheck returned the pinned digest above from the local KOS Kit mirror;
the source receipt at the implementation commit records the same manifest and result.

## Frozen pre-decision project applicability assessment (historical snapshot)

| Contract area | Current Universe input | Review condition before adoption | Current disposition |
|---|---|---|---|
| Candidate / artifact / context identity | Current project candidate record and Main-App store are the project facts owner; the current implementation is still an uncommitted input | Map each KOS identity/ref/context field to one local owner; worktree-only or unknown identity cannot support current proof | Review required |
| Observation / claim coverage | Project evidence owner keeps content-free outcomes and evidence pointers; KOS E-01 remains a separate optional contract | Use an adapter/profile over the existing record, not a second evidence authority; claim/coverage owner must be named in the adopting Profile | Review required |
| Freshness / `as_of` / `max_age_days` | The current candidate design proposes a 30-day window; final policy value remains project-owner input | Bind `as_of`, `timestamp`, `valid_until`, `max_age_days`, future and conflict handling; stale/unknown is fail-closed | Review required |
| Daily Beta → external candidate | Existing design allows reuse only after exact identity/context/freshness checks; first/next external history is fail-closed | Close `REP-Q-01` with final SHA and actual base/head provenance before any publication claim; old Beta remains comparator unless all bindings pass | Review required |
| Delivery / P-01 boundary | Current implementation retains CI as an independent full/delta authority | Record local/published/hosted heads and result explicitly; no same-head claim with `none`/`unknown` | Review required |
| Final validation / D-01 boundary | Docs and release checks exist, but a new receipt must bind the final tree and exact checker scope | Future adopting Assignment names checker, version, scope, baseline, output and freshness after the last edit | Review required |
| Privacy and runtime | Main App owns the local release-evidence page/store; ADR 0027, Privacy Policy and Performance Baseline prohibit content leakage and Extension hot-path I/O | Allow only opaque identity/status/provenance fields; exclude raw input/candidate/host text, credentials, full logs and user data; no runtime network or synchronous Extension file work | Review required |
| Migration | Existing Active Assignments and historical Build 7/55 evidence remain governed by their current sources | No bulk backfill; new adoption applies prospectively, with explicit opt-in per new Assignment | Review required |

## Project owner map to verify

- KOS Kit contract semantics: upstream [`ops/release-evidence.md`](https://github.com/shchnk1103/kos-agent-kit/blob/8e55551a3b56b57e7fc5ab5544d653f9c6854df9/ops/release-evidence.md#L1).
- Candidate/artifact/context facts and local retention: Universe release-evidence
  owner in the current `RELEASE-EVIDENCE-PROMOTION-001` packet; it must remain the
  project Source of Truth after any adoption. This is an uncommitted main-worktree
  input and intentionally has no stable repository link until its final SHA exists.
- CI classification: [`docs/CI_CHANGE_CLASSIFICATION.md`](../../CI_CHANGE_CLASSIFICATION.md#L1).
- Release gates and external-only checks: [`docs/RELEASE_CHECKLIST.md`](../../RELEASE_CHECKLIST.md#L1)
  plus the release Assignment; the KOS evaluator cannot close them.
- Privacy and content-free diagnostics boundary: [`docs/PRIVACY_POLICY.md`](../../PRIVACY_POLICY.md#L55),
  [`docs/PERFORMANCE_BASELINE.md`](../../PERFORMANCE_BASELINE.md#L32) and
  [`ADR 0027`](../../architecture/decisions/0027-enterprise-local-diagnostic-observability.md#L13).
- Product, Quality, Release and external action authority: existing project Decision,
  Assignment, Review and Gate owners; never the Kit validator or Main App status page.

### Profile allowlist and evidence boundary

The future adopter Profile must bind only content-free fields: candidate/artifact/context
identities, build/version/digest metadata, claim/coverage identifiers, outcome,
`as_of`/validity, evidence references, comparison state, delivery/final-validation status,
checker/version/scope, exit code and bounded provenance heads. It must exclude raw keyboard,
candidate or host text, credentials/tokens, full diagnostic-log payloads and unrelated user
data. Main App owns persistence and presentation; the Keyboard Extension does not write this
record synchronously and the Profile has no runtime network requirement. This is a design
allowlist, not device/runtime proof, and is grounded in the linked [`Privacy Policy`](../../PRIVACY_POLICY.md#L55),
[`Performance Baseline`](../../PERFORMANCE_BASELINE.md#L32) and
[`ADR 0027`](../../architecture/decisions/0027-enterprise-local-diagnostic-observability.md#L13).

## Freshness and derived-state matrix

The adopter must provide `as_of` and `policy.max_age_days`; the contract evaluator does
not infer either value. At evaluation time:

| Condition | Required derived result | Non-claim |
|---|---|---|
| Future/unparseable observation, age over `max_age_days`, or `as_of > valid_until` | stale/blocked; no current proof | Build number or upload time cannot establish freshness |
| Exact current candidate/artifact/context/profile/claim/coverage binding, fresh `pass`, no comparable conflict, valid delivery and final validation | Eligible to support `current-proof` only when promotion prerequisites also pass | Never a Product/Quality/Release conclusion |
| Observation exists but binds another candidate/artifact/context | comparator | Does not validate the current external candidate |
| Promotion target is declared but target binding, first baseline or subsequent history is missing | pending with all blockers | Pending never authorizes upload or release |
| Identity/context unknown or mismatched, stale/conflicting/non-pass, delivery failure or final-validation failure | none or blocker | No silent promotion |

For `target_sequence=first`, `previous_target_receipt` is `null` and a verified baseline
must bind the current candidate, stages, profile, contract and full identity/context. For
`target_sequence=subsequent`, the previous receipt must be for a different candidate and
bind the same stage/context/profile/contract, with all policy-declared history identity keys
resolved. These are derived evidence states only.

## Frozen pre-decision publication-fact snapshot (not a P-01 receipt)

| Fact | Value | Why |
|---|---|---|
| `local_candidate` | `UNKNOWN` | Universe release-evidence worktree has no final SHA |
| `published_head` | `none` | UK-005 has no Universe branch/PR publication |
| `hosted_ci_head` | `unknown` | No hosted CI covers this uncommitted packet |
| `hosted_ci_result` | `not-run` | No hosted result is claimed |
| `coverage` | `unknown` | Same-head cannot be established |
| `pr_state` | `none` | No PR is in scope |

At `2026-09-14T17:07:29+0800`, the local tag check was:

```bash
git -C /Users/doubleshy0n/Dev/kos-agent-kit tag --points-at 8e55551a3b56b57e7fc5ab5544d653f9c6854df9
```

It returned no lines. The hosted tag probe was:

```bash
git -C /Users/doubleshy0n/Dev/kos-agent-kit ls-remote --tags https://github.com/shchnk1103/kos-agent-kit.git 'refs/tags/*'
```

It exited `128` with `Failed to connect to github.com port 443 after 1 ms: Couldn't connect to server`.
This is recorded as unavailable rather than proof that no hosted Release exists. The snapshot
expires for `Ready`/adoption purposes and both checks must be re-run before that handoff, or
after any upstream commit, tag or Release metadata change.

## Historical review handoff

The preparation and review snapshot above was the input to the now-recorded Product
Decision. It did not itself authorize implementation, commit, push, merge, tag,
TestFlight or Release. Current scope and handoff authority are the Product Decision
and implementation Assignments linked in the current project disposition section.
