# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 — P0 Architecture Review

## Review identity and boundary

| Field | Value |
|---|---|
| Reviewer | `Codex` — independent Architecture reviewer |
| Review date | `2026-09-14 Asia/Shanghai` |
| Review mode | Read-only review of the isolated worktree; this file is the only permitted addition |
| Worktree | `/private/tmp/universe-keyboard-kos-upgrade-uk-005` |
| Worktree HEAD | `3139f8d3bdb6be6622504ea731988f42681896fb` |
| P0 package digest | `6892e9d437139d71b4d2b1a006af9ac0f1451a68df077816726add33534e6a4a` |
| Freeze evidence | [`P0 freeze`](../evidence/kos-release-evidence-implementation-001-p0-freeze-2026-09-14.md#L8) |

Scope is limited to the P0 contract/Profile/owner-map architecture boundary and
the requested authority, privacy, derived-state, stage and mirror checks. This
record does not review or authorize runtime implementation.

## Verdict

**Changes Requested — Architecture review only.**

The package digest matches the freeze evidence, the authority and non-authority
boundaries are explicit, and no fail-open path to external publication is present.
P0 handoff is nevertheless not complete because the owner map is not yet strictly
one-fact/one-canonical-owner and the derived-state table is not exact against the
pinned candidate evaluator. P1 must remain behind the Assignment's P0 review
condition until these two documentation/contract residuals are fixed and reviewed.

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 2 |
| P2 | 0 |
| P3 | 0 |

## Digest verification

Recomputed from the eight files in the requested order, with no separators:

```bash
cat .kos/project.json docs/ACTIVE_WORK.md docs/kos/README.md docs/kos/UPGRADE_STATUS.md \
  docs/product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md \
  docs/authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001.md \
  docs/assignments/kos-release-evidence-implementation-001.md \
  docs/kos/release-evidence-profile.md | shasum -a 256
```

Observed digest:

```text
6892e9d437139d71b4d2b1a006af9ac0f1451a68df077816726add33534e6a4a
```

It matches [`P0 freeze`'s recorded digest](../evidence/kos-release-evidence-implementation-001-p0-freeze-2026-09-14.md#L19-L42).
The digest is an integrity fact only; it is not an acceptance or authorization.

## Findings

### A-P1-01 — Owner map is not yet one fact / one canonical owner

**Evidence:** [`Profile` owner map](../kos/release-evidence-profile.md#L35-L51) and
the Assignment requirement that every portable field map to one existing owner
([`Assignment` §Scope](../assignments/kos-release-evidence-implementation-001.md#L56-L67),
[`P0 exit criteria`](../assignments/kos-release-evidence-implementation-001.md#L139-L147)).

The map combines different roles in the `Universe owner` cell (`release-evidence
owner plus receipt`, `Release Assignment and environment owner`, `owner with
Quality reviewer`, and `owner and Human Product/Release authority`). It also has
no explicit canonical-owner rows for `record_id`, the policy inputs
(`required_claim_bindings`, `max_age_days` and history keys), or the `provenance`
object. A receipt source, reviewer, or later human authority may support or review
a fact, but must not make the fact's canonical owner ambiguous.

**Required closure:** split canonical fact owner from receipt/source, reviewer and
human-authority columns; add all portable schema areas, including record ID,
policy, provenance, delivery, final validation and promotion; bind each owner to
an existing project source/Assignment. Preserve the rule that the Profile is an
adapter and does not become a second evidence authority.

**Disposition:** `fix`; owner: `KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001` / its
Architecture and Knowledge Steward lane.

### A-P1-02 — Derived-state matrix is broader than the pinned evaluator

**Evidence:** [`Profile` freshness/derived-state matrix](../kos/release-evidence-profile.md#L89-L107),
the pinned candidate contract's derived-state rules
([`upstream contract`](https://github.com/shchnk1103/kos-agent-kit/blob/8e55551a3b56b57e7fc5ab5544d653f9c6854df9/ops/release-evidence.md#L109-L139)),
and the candidate evaluator's promotion result split
([`upstream evaluator`](https://github.com/shchnk1103/kos-agent-kit/blob/8e55551a3b56b57e7fc5ab5544d653f9c6854df9/scripts/validate_release_evidence.py#L708-L747)).

The Profile currently maps all of “target binding missing, first baseline missing,
or subsequent history missing” to `pending`. The evaluator maps only an unbound
target to `pending`; once the target is bound, a missing or mismatched required
baseline/history is `none` with blockers. The Profile also classifies an
unparseable timestamp as `stale/blocked`, while the pinned evaluator rejects an
unparseable timestamp as invalid input and emits no derived classification.

Finally, the `current-proof` row should explicitly include current provenance and
all candidate/artifact/input/environment/final-tree/head bindings required by the
candidate contract; those conditions must not be implied only by the later Beta
paragraph.

**Required closure:** make the matrix distinguish structural invalid input,
`pending` (target not bound), and `none` (bound target with failed promotion
prerequisite); state the exact `daily_beta` → `external` stage binding; include
fresh provenance and complete candidate/delivery/final-validation conditions; and
carry the same cases into the P1 focused contract fixtures/tests.

**Disposition:** `fix`; owner: `KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001` / its
Architecture and future adapter-test lane.

## Boundary checks that passed

| Boundary | Result | Evidence |
|---|---|---|
| Product Decision → Authorization → Assignment | Pass structurally | Authorization binds the Product Decision and exact action/target ([`Authorization`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001.md#L18-L36)); Assignment binds both parent decision and authorization ([`Assignment envelope`](../assignments/kos-release-evidence-implementation-001.md#L3-L32)). |
| v0.8 pin vs untagged candidate | Pass | `.kos/project.json` keeps advisory `v0.8.0` and its adopted commit ([`project profile`](../../.kos/project.json#L139-L147)); `UPGRADE_STATUS` explicitly says the UK-005 candidate does not become a new Kit Release ([`status`](../kos/UPGRADE_STATUS.md#L40-L68)). |
| Content-free / Main-App / hot-path / no-network | Pass as a design boundary | The Profile allowlist/exclusions are explicit ([`Profile`](../kos/release-evidence-profile.md#L63-L87)) and align with the local privacy, performance and diagnostic ownership sources ([`Privacy Policy`](../PRIVACY_POLICY.md#L53-L57), [`ADR 0027`](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md#L13-L20)). This is not runtime proof. |
| Daily Beta → external and history direction | Changes requested | Exact identity/freshness/coverage/comparison and first/subsequent requirements are present ([`Profile`](../kos/release-evidence-profile.md#L109-L123)), but A-P1-02 requires exact derived-state distinctions and provenance coverage. |
| P0 / P1 / P2 stage boundary | Pass structurally | P0 is documentation/owner-map only; P1 is adapter plus focused tests; P2 is a receipt handoff with final/hosted facts and separate human action ([`stage table`](../assignments/kos-release-evidence-implementation-001.md#L69-L83)). |
| README / UPGRADE_STATUS / `.kos` mirrors | Pass for the requested layering | README names `v0.8.0` as the advisory Kit pin and UK-005 as a project-level prospective contract ([`README`](../kos/README.md#L54-L80)); Active Work mirrors only the P0 handoff and open provenance blockers ([`ACTIVE_WORK`](../ACTIVE_WORK.md#L69-L82)). No mirror grants Product, Quality, Release, merge or publication authority. |

## Existing residuals outside these Architecture findings

- `REP-Q-01` remains open: no final Universe implementation SHA, actual base/head
  pair or hosted-CI provenance. The Assignment and Product Decision keep this as a
  later publication-readiness/implementation-handoff dependency; this review does
  not close it.
- Hosted upstream tag/Release revalidation remains open because the recorded network
  probe was unavailable. No absence of a hosted tag or Release is inferred.
- The P0 freeze receipt is executor-recorded. This review does not convert it into
  Quality, Product, Gate or Release evidence.

## Complete non-claims

This Architecture review does not:

- make, replace or re-issue a Product Decision, Product Gate or Product acceptance;
- provide a Quality, Performance, Release, Gate, TestFlight or App Store Connect
  conclusion;
- claim current-proof for a real release candidate or promote any Beta evidence to
  an external candidate;
- close `REP-Q-01`, establish a final implementation SHA, base/head relation,
  hosted-CI result, archive/export, device or runtime evidence;
- claim that the hosted upstream tag/Release is absent;
- authorize implementation beyond the documented P0 handoff, runtime changes,
  Main-App storage changes, Keyboard Extension changes, App Group changes, network
  access, publication, upload, commit, push, merge, tag, branch cleanup or Release;
- enable `required`, migrate/backfill historical Assignments or evidence, or alter
  the adopted Kit pin `v0.8.0`;
- treat the P0 digest, validator result, Profile, status mirror or this review as
  a Product/Quality/Release authority; or
- modify any packet, Profile, Assignment, status mirror or implementation file.
