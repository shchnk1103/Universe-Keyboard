# T9-AUTO-ANCHOR-001 — S5 Architecture / Quality Review Handoff

Prepared by: Codex（Executor）
Handoff target: Architecture & Knowledge Steward + Quality, Performance &
Release Maintainer
Date / timezone: `2026-07-27 Asia/Shanghai`
Working tree: **dirty / uncommitted**

> This handoff prepares independent review. It does not self-approve
> Architecture, Quality, Product Gate, Release enablement or production
> personalization.

## Scope

The S5 delta is test-target-only:

- three independent complete-learning cases;
- one partial-selection negative;
- one generated UUID RIME user directory per case;
- candidate rank checked before learning, after learning and after reopening;
- the same two-syllable proposal/conservation transaction checked before and
  after learning;
- content-free machine summaries and mandatory directory deletion.

No production Controller, Keyboard Extension, App Group, real user dictionary,
sync/backup path, setting, retention policy or Release behavior was added.

## Authority

- Product Decision:
  [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)
- Assignment:
  [`t9-auto-anchor-001.md`](t9-auto-anchor-001.md)
- Architecture:
  [`ADR 0024`](../architecture/decisions/0024-t9-auto-anchor-shadow-observation-boundary.md)
- Plan:
  [`t9-long-composition-process-key-latency-plan.md`](../plans/t9-long-composition-process-key-latency-plan.md)
- Evidence:
  [`t9-auto-anchor-personalization-s5-2026-07-27.md`](../evidence/t9-auto-anchor-personalization-s5-2026-07-27.md)

## Executor pre-review

| Boundary | Executor observation |
|---|---|
| Target membership | S5 implementation is inside `RimeBridgeTests`; no production source was added for personalization |
| User-data root | Every case appends a UUID child to the supplied isolated fixture user root |
| Cross-case isolation | No case reuses another case's generated user directory |
| Session lifecycle | First engine finalizes before reopen; reopened engine finalizes before the exact generated directory is removed |
| Learning budget | Every complete case performs exactly one selection and zero continuation selections; the negative performs exactly one partial selection plus one continuation |
| Learning proof | Complete cases require a forward rank delta and the exact restart-stable expected rank; file existence is not used |
| Safety authority | Learned rank does not replace proposal or candidate-conservation authority |
| Content privacy | Candidate text is held only in local test memory; failure messages and summaries contain only case IDs, ranks, lengths, counts and decisions |
| Cleanup | Passing tests assert removal; post-run inspection found no `personalization-*` directory |
| Extension hot path | No scan, deployment, backup, sync or persistence work was added to the Extension |

This is an executor audit, not an independent Architecture conclusion.

## Frozen S5 matrix

| Case | Selection | Rank | Two-syllable before → after |
|---|---|---|---|
| `knownPositive` | one complete | `4 → 0 → 0` | accepted `3/5 → 3/5` |
| `naturalWeather` | one complete | `4 → 0 → 0` | accepted `3/5 → 3/5` |
| `naturalReminder` | one complete | `4 → 0 → 0` | rejected `2/5 → 2/5` |
| `partialNegative` | one partial + one continuation | `2 → 3` | accepted `3/5 → no proposal` |

The complete-case helper asserts every numeric value above. The negative
asserts that a partial selection cannot enter the positive corpus and cannot
become anchor authority.

## Current verification

| Check | Result |
|---|---|
| RIME vendor inventory | PASS — `11 / 11` |
| Strict iOS Simulator build-for-testing | PASS — zero compiler warnings/errors |
| Fixture-enabled full class after remediation | PASS — `6 / 6` |
| Post-format S5-only rerun | PASS — `4 / 4` |
| Default RimeBridge suite after remediation | PASS — `32` passed, `0` failed, `14` fixture-gated skips |
| Rejected non-temporary user root | PASS — expected pre-creation failure; no residual directory |
| Swift format lint | PASS |
| `git diff --check` | PASS |
| Generated-directory inspection | PASS — no residual `personalization-*` directory |

The default suite's pre-initialization logging warning remains unrelated. A
fixture-gated skip is not counted as a real-runtime pass.

## Independent reproduction

Prerequisites:

1. a booted iOS Simulator;
2. a complete isolated T9/rime-ice shared fixture with unsupported
   `t9_processor` removed;
3. an isolated parent user directory;
4. the pinned RIME vendor inventory.

Set all three environment forms because XCTest runs inside Simulator:

```bash
export UK_RIME_T9_SPIKE_SHARED_DIR="<isolated-shared>"
export UK_RIME_T9_SPIKE_USER_DIR="<isolated-parent-user>"
export TEST_RUNNER_UK_RIME_T9_SPIKE_SHARED_DIR="$UK_RIME_T9_SPIKE_SHARED_DIR"
export TEST_RUNNER_UK_RIME_T9_SPIKE_USER_DIR="$UK_RIME_T9_SPIKE_USER_DIR"
export SIMCTL_CHILD_UK_RIME_T9_SPIKE_SHARED_DIR="$UK_RIME_T9_SPIKE_SHARED_DIR"
export SIMCTL_CHILD_UK_RIME_T9_SPIKE_USER_DIR="$UK_RIME_T9_SPIKE_USER_DIR"
```

Then independently build and run:

```bash
bash scripts/ensure_rime_vendor.sh verify

xcodebuild test \
  -project "Universe Keyboard.xcodeproj" \
  -scheme RimeBridgeTests \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=<simulator-udid>" \
  -only-testing:RimeBridgeTests/RimeT9AutoAnchorRetryMatrixTests \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
  GCC_TREAT_WARNINGS_AS_ERRORS=YES
```

The reviewer must use a fresh isolated parent user directory or prove it
contains no prior learning state. App Group and real user directories are
prohibited.

## Required Architecture review

1. Confirm test-only `.fullCheck` deployment does not weaken ADR 0001's
   production Main-App ownership.
2. Confirm generated-directory isolation/finalization preserves ADR 0003/0004
   ownership and lifecycle.
3. Confirm rank remains preference evidence and never replaces Path/proposal
   or conservation authority.
4. Confirm the partial negative correctly freezes “selection is not completed
   learning” without defining a production learning API.
5. Confirm Product Decision, Assignment, ADR and plan describe one consistent
   boundary without authorizing retention or production userdb queries.

## Required Quality review

1. Re-run the fixture class from the reviewer's environment and compare all
   four content-free summaries.
2. Inspect target selection and failure messages for candidate/raw/pinyin
   leakage.
3. Verify each complete case uses a fresh directory, exact rank assertions and
   zero continuation selections.
4. Verify the negative is genuinely partial and fails closed before
   transaction validation after reopen.
5. Run the default suite without fixture variables and record skips separately
   from passes.
6. Verify no generated directory remains after both success and an
   intentionally induced assertion failure.
7. Decide whether fixture drift should intentionally fail exact ranks or be
   represented through a versioned matrix update.

## Findings and blockers

| Priority | Finding | Effect / owner |
|---|---|---|
| P1 | The implementation/evidence is not frozen to a clean commit or immutable diff | Blocks publication-grade evidence and `Reviewed`; Executor/Product Lead must authorize and create a scoped checkpoint before final independent evidence |
| Closed | Independent Architecture and Quality conclusions were missing | Both reviewers completed remediation re-review against the snapshot identified below |
| P2 | The S5 matrix does not yet have its own one-command fixture-preparation runner | Independent reviewer must prepare/reuse a proven isolated fixture; RimeBridge/Quality may add a runner only under explicit scope |
| P2 | `docs/evidence/` is ignored by repository policy | The evidence exists locally but must be explicitly included by the authorized publication flow |
| P2 | Coverage is four synthetic cases on iOS 27 Simulator | Does not prove representative language quality, physical-device latency, Release behavior or Product Gate |

No P0 production-boundary or privacy defect was found in the executor
pre-review.

## Remediation after first independent review

The first independent Architecture and Quality reviews both returned
`Pass with findings`. Their shared harness findings were remediated as follows:

| Finding | Remediation |
|---|---|
| User root was accepted from arbitrary environment path | Canonicalize the existing root through symlink resolution and fail unless it is a strict descendant of `/private/tmp`; pure policy and intentional invalid-root runs added |
| Complete-case budget could exceed 12 through nested continuation loops | Remove both loops; a complete case now performs exactly one selection |
| “One complete selection” was not mechanically frozen | Assert `selectionCount == 1` and require that first selection to commit |
| Partial negative had a looped continuation budget | Freeze exactly one partial selection plus one continuation |
| Assignment still described Stage 2 executor/lifecycle/handoff | Revalidated lifecycle, executor scope, S5 exit criteria, handoff and future revalidation triggers |
| ADR format was incomplete | Added Alternatives Considered, Risks, Follow-up Work and Related Documents |
| Knowledge Index still routed as S1-only | Updated the route summary to S1–S3 plus active S5 review |
| `essay` read-only runtime diagnostic absent from evidence | Recorded as a fixture/runtime limitation |

The immutable-checkpoint, ignored-evidence publication and portable-runner
findings remain open. Architecture and Quality independently re-reviewed the
remediation; their conclusions are recorded below.

## Independent remediation re-review

Reviewed snapshot:

- test file SHA-256:
  `ea75a2d8ff0e57ae42009f76727cebf8bd3d4fa2a4f7b3fff36d4804727d241f`;
- repository `HEAD`: `2ec7421dd29211906a577a272e0895f72a6ae128`;
- working tree: dirty / uncommitted;
- environment: iPhone 17 Pro Max Simulator, iOS 27.0, Debug,
  `RimeBridgeTests`.

### Architecture conclusion

**Pass with findings / Architecture Reviewed for the exact snapshot above.**

The reviewer confirmed that the strict `/private/tmp` boundary, selection
budgets, Assignment revalidation, ADR sections and Knowledge Index routing
close the first-review Architecture findings. Rank remains preference evidence
and does not replace proposal or conservation authority. Test-only deployment
and session reopening do not change production deployment/session ownership.

Open findings:

- **P1:** no immutable checkpoint binds implementation, evidence and reviewer
  conclusions;
- **P2:** no portable fixture runner;
- **P2:** four synthetic iOS 27 Simulator cases do not establish product
  language quality, physical-device performance, Release behavior or Product
  Gate.

The Assignment therefore remains `Active`. ADR 0024 remains `Proposed` until
the reviewed snapshot is frozen; no new ADR is required if that checkpoint is
identical to the reviewed boundary.

### Quality conclusion

**Pass with findings for the exact snapshot above.**

The independent rerun recorded:

- RIME vendor inventory: `11 / 11`;
- strict build-for-testing: PASS, zero compiler warnings/errors;
- fixture class: `6` passed, `0` failed, `0` skipped;
- default suite: `32` passed, `0` failed, `14` fixture-gated skips;
- rejected non-temporary root: expected fail-closed result before directory
  creation;
- success, policy-test and intentional-failure cleanup: no residual
  `personalization-*` directory;
- Xcode defaults restored to `Universe Keyboard` / Debug / the original
  Simulator.

The reviewer independently reconfirmed the frozen summaries: all three
complete cases produce `4 → 0 → 0` with exactly one selection and no
continuation; the partial negative produces `2 → 3` with exactly one partial
selection plus one continuation. The `essay` read-only diagnostic remains a
recorded runtime limitation rather than a hidden success signal.

Open findings:

- **P1:** no immutable checkpoint, so the review cannot yet become durable
  publication-grade provenance;
- **P2:** the fixture lacks a canonical digest/version manifest and a portable
  provenance-recording runner;
- **P2:** `docs/evidence/` remains ignored and must be included explicitly in
  any authorized publication flow;
- **P2:** evidence remains limited to four synthetic cases on iOS 27
  Simulator.

Neither reviewer accessed App Group or real userdb data. Neither conclusion
authorizes production personalization, Release enablement or Product Gate.

## Recorded conclusions and Product handoff

- **Architecture:** `Pass with findings` for the exact snapshot above.
- **Quality:** `Pass with findings` for the exact snapshot above.
- **Product Lead:** decide whether to authorize
  a scoped commit/publication checkpoint, a portable S5 runner, broader
  language coverage, or no further S5 work.

The independent conclusions now exist for the exact snapshot recorded above.
S5 is locally implemented and independently reviewed with findings, but it is
not frozen into durable publication-grade evidence and is not
production-authorized.
