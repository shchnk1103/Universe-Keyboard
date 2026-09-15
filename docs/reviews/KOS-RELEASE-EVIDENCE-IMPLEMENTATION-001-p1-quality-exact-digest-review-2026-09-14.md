# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1 Quality Review

## Reviewer identity and conclusion

| Field | Value |
|---|---|
| Reviewer | Codex — independent Quality Reviewer role; receipt treated as executor evidence, not review authority |
| Review date | 2026-09-14 |
| Scope | Exact-digest read-only review of `/private/tmp/universe-keyboard-kos-upgrade-uk-005` |
| Implementation digest | `d021c29e1fdba423a134167900aed1a7c45e6ff9cfc5ab97fe7cd156020f7e94` |
| Decision | **Needs work** |
| Review-side mutation | Only this report; no implementation or governance status file changed |
| External actions | None: no commit, push, merge, tag, upload, publication or release |

The fixed package digest was independently recomputed from the ordered raw-byte
concatenation of the six manifest files and matched exactly. The receipt and fixture
report are useful and reproducible, but the independent review found fail-closed defects
that can produce false current-proof or unsafe reuse for inputs outside the fixed happy
path matrix. This digest is therefore not ready for Adopt.

## Exact package and manifest

| Order | Path | Independently observed SHA-256 |
|---:|---|---|
| 1 | `scripts/release/kos_release_evidence_adapter.py` | `7e59bb034ef1b99c39d83e1980e7490ad29af8d4aff8d844793274e79326b1b6` |
| 2 | `scripts/release/run_kos_release_evidence_fixtures.py` | `aec842b6bb1dc94f7b7432b453ce22a37e420558a6f1f9a3522898f5c0278b48` |
| 3 | `scripts/release/fixtures/kos_release_evidence_cases.json` | `3b9fd7004c8a152d0c9eaf4e6a6ac80ebc2b6dbb156242b4d57010feb9fecec0` |
| 4 | `scripts/release/tests/test_kos_release_evidence_adapter.py` | `af6391759081c297fd2256369c1e9f7e4a95340989d8d72331e099bec507afe8` |
| 5 | `docs/kos/release-evidence-profile.md` | `b957bd09e12ee444455192df5e296318d876a777a62a1abb3e9563cd6efa4cd9` |
| 6 | `docs/RELEASE_CHECKLIST.md` | `06e75776be9024435aac536fb701cfae4aa4f9bad657157a66191e3b9ae04fa3` |

The receipt records the same manifest and digest at
`docs/evidence/kos-release-evidence-implementation-001-p1-implementation-2026-09-14.md:39-64`.

## Evidence paths reviewed

- Receipt: `docs/evidence/kos-release-evidence-implementation-001-p1-implementation-2026-09-14.md`
- Fixed fixture report: `/private/tmp/uk-kos-kos-fixtures-final/report.json`
- Receipt-recorded rerun: `/private/tmp/uk-kos-kos-fixtures-ci-20260914/report.json`
- Assignment: `docs/assignments/kos-release-evidence-implementation-001-p1.md`
- Authorization: `docs/authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md`
- Profile: `docs/kos/release-evidence-profile.md`
- Release checklist: `docs/RELEASE_CHECKLIST.md`
- Pinned contract: `/Users/doubleshy0n/Dev/kos-agent-kit/ops/release-evidence.md`
- Pinned schema: `/Users/doubleshy0n/Dev/kos-agent-kit/schemas/release-evidence-v1.schema.json`
- Pinned evaluator: `/Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py`

Pinned source digests were independently observed as:

| Source | SHA-256 |
|---|---|
| Contract | `f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673` |
| Schema | `4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce` |
| Evaluator | `a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9` |

## P1 findings

### P1-Q-001 — unresolved Main-App source identity can yield `current-proof`

`kos_release_evidence_adapter.py:311-330` validates `main_app_source.record_id` as a
bounded safe string, but does not apply its `_resolved` rule. The token `UNKNOWN` is
therefore accepted inside an `appdiag://` source pointer.

Independent in-memory reproduction, using the fixed base fixture and the pinned
evaluator at the fixed `as_of`, produced a pointer containing `/UNKNOWN/`, claim status
`pass / pass / pass`, and derived status `current-proof`.

This violates the Assignment dependency-closed and stop conditions at
`docs/assignments/kos-release-evidence-implementation-001-p1.md:157-165` and
`:283-295`: unknown source owner/binding must fail closed and cannot support current
proof. It is a direct false-positive provenance path.

Required disposition: reject unresolved source identifiers before pointer creation, bind
the accepted identity to the approved Main-App source seam, and add a negative fixture
and unit test proving unresolved source identity cannot yield current-proof.

### P1-Q-002 — Profile path is misclassified as docs-only and reuses all evidence

`kos_release_evidence_adapter.py:738-745` marks every path below `docs/` or `.kos/` as
docs-only. `plan_delta` applies that path rule before semantic dependency handling at
`:952-985`. For the actual path `docs/kos/release-evidence-profile.md`, independent
in-memory evaluation returned:

```text
release_validation_profile = delta
ci_change_tier = docs_only
reusable_evidence_keys = all three existing keys
invalidated_evidence_keys = none
stop_before_current_proof = false
```

The Profile itself is a release-evidence dependency and is part of this exact package.
The Assignment requires Profile/source-owner/claim-coverage/privacy changes to invalidate
all affected records and requires dependency changes to stop reuse
(`docs/assignments/kos-release-evidence-implementation-001-p1.md:167-175`). The fixed
matrix tests only `docs/RELEASE_CHECKLIST.md` as docs-only at
`scripts/release/fixtures/kos_release_evidence_cases.json:252-260`, so it misses this
path-specific over-reuse.

Required disposition: classify Profile and contract/governance paths before the broad
docs-only rule, or use an explicit docs-only allowlist; add a Profile-path fixture that
asserts empty reuse, full release validation and stop=true.

### P1-Q-003 — delta reuse does not enforce claim/coverage binding

The Assignment requires a complete delta tuple including affected claim/coverage keys
(`docs/assignments/kos-release-evidence-implementation-001-p1.md:159-165`), and the
Profile requires claim, coverage and comparison basis to match
(`docs/kos/release-evidence-profile.md:373-382`). However, the reuse check at
`kos_release_evidence_adapter.py:811-869` requires neither `scope`/coverage nor a
validated claim-to-scope mapping. `claim_ref` is accepted as any trimmed token, while
`plan_delta:1053-1072` uses `scope` only for invalidation and does not reject a missing
or unknown scope.

Independent in-memory reproductions showed that a wrong `claim_ref` still reuses an
otherwise fresh entry, and that changing the touched changed-path entry's scope to
`not-a-known-scope` makes an ordinary UI delta reuse that touched key. The normal
fixture invalidates that key. The current delta entries also omit `coverage_ref`, so the
green matrix does not prove coverage binding.

Required disposition: require and validate known scope/coverage keys, enforce the
claim-to-coverage registry, reject missing/unknown mappings, and add mismatched
claim/coverage reuse and invalidation fixtures.

## Matrix coverage and exact command properties

### 34 evaluator cases

The fixed report records `34/34` passed. The receipt records report SHA-256
`75e5c7dd175a6559dd445432edf0b4faecf527c065fb7c063933a6356cddaf81`. Each envelope
case invokes the exact pinned evaluator path and includes an explicit `--as-of`.
FX-005 intentionally supplies a timezone-less value and exits `2` without a derived
classification.

Coverage read from the fixed fixture:

- FX-002..005: invalid JSON/schema/key/policy/as-of.
- FX-006..014: unbound/bound promotion, first/subsequent, baseline/history and missing
  lineage.
- FX-008/009/015/034: comparator, mixed and candidate mismatch.
- Focused test `test_partial_step_maps_to_inconclusive`: partial -> inconclusive.
- FX-016..024: future, stale and expired observation/delivery/final/provenance.
- FX-025..028: P-01 missing/unequal heads, hosted failure and basis mismatch.
- FX-029..032: D-01 final-tree mismatch, checker reference, nonzero exit and failed
  result.
- FX-033: unresolved candidate head.

Gaps against the Assignment's required negative inventory at
`docs/assignments/kos-release-evidence-implementation-001-p1.md:262-281`: no mismatched
`release_lineage` case, and no separate D-01 unresolved checker-version, scope, baseline
or output-reference cases.

### 11 delta cases

The fixed report records `11/11` passed. It represents ordinary UI/full CI, checklist
docs-only/docs_only, dependency changes/full, delivery and final-validation
triggered/full, unknown path/full, and stale docs-only invalidation.

The delta command is `adapter delta --input ...`, not the evaluator CLI. It has no
literal `--as-of` option; each input carries a timezone-qualified `as_of` which
`plan_delta` parses, and the runner verifies pinned contract/schema/evaluator digests
before the matrix. This is an explicit payload clock and pinned-source precondition,
not 11 evaluator invocations with a CLI `--as-of` flag.

Delta coverage gaps remain for an actual Profile path, source-owner path, runtime or
keyboard triggered path, distinct malformed/unsafe changed-surface inputs, and safe
reuse plus invalidation for every dependency row. DELTA-010 covers an unknown path but
not all ambiguous input shapes.

## Repeatability and receipt boundaries

The receipt records focused tests exit `0` with 10 tests, the 45-case matrix exit `0`,
the rerun report SHA-256
`e0353be6c45ede12b958b31a8b145b142e4568be02e3a33ec16b035d5baf156a`, and pinned source
checks before execution. I independently reran the 10 focused tests with
`PYTHONDONTWRITEBYTECODE=1`; all 10 passed, and independently recomputed the package
digest. Full CI was intentionally not repeated per the user's instruction; its recorded
results remain executor evidence.

The receipt correctly limits the result to synthetic, content-free fixture evidence and
a derived evaluator `current-proof` classification. It explicitly does not prove an
actual Build 56, device run, archive/export, hosted CI run, Beta Review, TestFlight
availability, Product Gate, Quality Gate, formal Release or human approval. `REP-Q-01`
and `HOSTED-PROVENANCE` remain open. No P1-B UI/storage/migration, physical-device or
performance claim is made. A green fixture, unit test or KOS validator is not Product,
Quality, merge or Release acceptance.

The runner iterates caller-supplied `cases` and `delta_cases` at
`run_kos_release_evidence_fixtures.py:455-500`; it does not assert exactly 34 and 11
fixed IDs. The checked-in fixture is digest-bound for this review, but the runner alone
is not an inventory-substitution guard.

## Governance observation and final decision

Authorization remains active but says `Consumption: Not consumed; P1-A implementation
has not started` at
`docs/authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md:3-8`, while the
Assignment and receipt say implementation is complete and independent review is pending.
This review did not edit that status; it is a later closure/consumption reconciliation
prerequisite, not authority for P1-B or any Git/release action.

**Final decision: Needs work.** The receipt, exact digest, pin checks, 34/11 result
counts, explicit envelope `--as-of`, focused tests and non-claim boundaries are
adequate as executor evidence. P1-Q-001, P1-Q-002 and P1-Q-003 are independent
fail-closed/over-reuse blockers. Do not mark this digest Adopted or use it for a current
Product/Quality/Release conclusion until those findings and the required fixture gaps
are addressed.
