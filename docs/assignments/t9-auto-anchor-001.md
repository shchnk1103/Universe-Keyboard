# Assignment: T9-AUTO-ANCHOR-001 — 九宫格安全自动锚定

**Policy version:** `1.0.0`
**Lifecycle status:** `Active — S5 reviewed at 9c4f86f and S2 review remediation durably reviewed at 0173782; broader stages pending`
**Repository change types:** `Implementation`, `Tests`, `Documentation`,
`Diagnostic Evidence`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner authorized the long-term
  automatic-bounding direction and Stage 1 on `2026-07-26 Asia/Shanghai`, then
  explicitly authorized implementation of the reversible Stage 2 design in the
  same Codex task on `2026-07-27 Asia/Shanghai`. The Product Owner later
  accepted a read-only Stage 3 observer for opportunities after the first
  rejection; this did not authorize another transaction. The Product Owner
  then explicitly authorized an isolated `/private/tmp` S5 personalization
  test using only synthetic candidate selections and mandatory fixture
  deletion, and subsequently authorized a first reviewed S5 extension of three
  independent complete-learning cases plus one partial-selection negative
  case under the same privacy boundary.
- **Product Approver:** Human Product Owner acting as Product Lead
- **Product Decision:** [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)

## Boundary

- **Scope:** Maintain the long-term plan; retain Stage 1 observation; implement
  a Debug/explicitly gated reversible-anchor prototype that uses only the
  already-returned first candidate page, attempts at most one automatic
  `replaceInput` per composition, validates bounded candidate conservation and
  restores the original digit identity on rejection or user Delete. After a
  rejection, Debug may observe later already-returned snapshots without
  changing the one-attempt ledger or calling RIME. A test target may create a
  generated `/private/tmp` user directory, learn from bounded synthetic
  candidate selections, reopen that same isolated directory to verify a rank
  delta, and delete it after the session closes.
- **Non-goals:** No Release-default enablement, candidate-window scan, second
  production RIME transaction/session, candidate commit, host-text commit,
  production deployment change,
  real/App-Group user-dictionary access, sync/backup access, production
  persistence, new user setting, numeric product budget, push/PR or Product
  Gate claim. The authorized test-only synthetic commit/reopen lifecycle is the
  sole exception and must stay inside its generated temporary directory.
- **Required Inputs:** `AGENTS.md`, `ASSIGNMENT_POLICY.md`,
  `PROJECT_CONTEXT.md`, `KEYBOARD_LAYOUT.md`, input pipeline, ADR 0010/0023/0024,
  `RIME_USER_DICTIONARY.md`, `PRIVACY_POLICY.md`, `PERFORMANCE_BASELINE.md`,
  frozen V7/V8 evidence and the linked plan.

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer
- **Executor:** Current Codex task
  `019f9dac-ff8d-7872-a913-d5dd3f930dc1`, limited to the authorized Stage 1–3
  implementation/evidence and Stage 5 isolated personalization
  tests/documentation/review remediation
- **Environment Executor:** Current Codex task on the user-opened iPhone 17 Pro
  Max iOS 27 Simulator, limited to build/test and synthetic diagnostic capture
- **Human Dependency:** Human Product Owner for manual typing judgment,
  Release-default/productization authorization and physical-device access
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer

## Gates

### Entry Criteria

- Product direction and Stage 1 measurement-only boundary are explicit.
- Existing V7/V8 evidence proves the bottleneck and explicit-Path mitigation.
- The implementation can consume the already-returned snapshot without an
  extra RIME call.
- Assignment contains no `UNKNOWN` field.

### Exit Criteria — Stage 2

- Stage 1 observation remains Debug-only and behavior-neutral.
- A pure policy proposes only a closed, catalog-legal prefix from a bounded
  first-page candidate sample and leaves an unresolved digit tail.
- The controller owns an explicit one-attempt ledger containing the original
  digit identity and accepted replacement identity.
- Accepted refinement preserves the baseline first candidate and the reviewed
  bounded candidate-overlap rule; rejection restores the original digit
  composition before returning.
- Delete transparently restores the original digit identity before applying
  the user's deletion. Explicit Path selection supersedes automatic ownership.
- No internal digit, proposed pinyin or candidate text is logged or persisted.
- Focused and full KeyboardCore tests pass.
- Strict Simulator build passes.
- The frozen 38-key sequence has comparable disabled/enabled simulator evidence.

### Exit Criteria — Stage 5 isolated matrix

- Every case rejects a fixture user root outside the canonical `/private/tmp`
  tree before creating, deploying or deleting data.
- Every case uses its own generated directory and finalizes all RIME sessions
  before deletion.
- Complete-learning cases perform exactly one complete candidate selection,
  prove a forward rank delta and prove the same rank after reopen.
- The partial negative is not counted as learning proof and cannot become Path,
  proposal or conservation authority.
- Machine output contains only case IDs, ranks, lengths, counts and decisions.
- Fixture-enabled, default-suite, cleanup and formatting checks pass.
- Independent Architecture and Quality reviewers record their own conclusions.

### Stop Conditions

Stop and return to Product/Architecture review if work requires:

- enabling the behavior by default in Release or adding a user-facing control;
- more than one anchor attempt per composition, any full candidate scan,
  candidate-window query, second production session or production deployment
  work;
- accepting an anchor without baseline-first-candidate preservation and the
  bounded overlap rule, or continuing after rollback cannot restore a usable
  composition;
- reading/writing/copying user-dictionary data or defining retention;
- content-bearing logs, synchronous persistence or Release instrumentation;
- treating a bounded candidate page as complete whole-sentence authority;
- changing Partial Commit, candidate ranking, 26-key behavior or host commit
  semantics.

For the isolated S5 test, stop if work would access a non-generated user
directory, log content, omit fixture deletion, invoke sync/backup, use host
text, exceed the declared bounded selection count or alter production
candidate-learning behavior.

The first reviewed S5 extension is additionally capped at four declared cases.
Each case must use a separate generated directory; cross-case userdb reuse is
prohibited so one synthetic learning result cannot contaminate another.

## Stage 5 isolated execution evidence

- A complete short synthetic candidate moved from rank 4 to rank 0 after one
  selection and remained rank 0 after reopening the same isolated user
  directory.
- The long-composition two-syllable transaction remained accepted at `3/5`
  bounded overlap before and after learning.
- The generated `personalization-*` directory was removed after session
  finalization; no production or App Group user data was accessed.
- Fixture-enabled focused class: `2 / 2` passed. Default RimeBridge suite:
  `31` passed, `0` failed, `11` fixture-gated skips.
- First reviewed extension: all three complete targets moved `4 → 0 → 0`
  across selection and restart. Two `3/5` transactions remained accepted and
  one `2/5` transaction remained rejected. The partial negative moved `2 → 3`
  and removed the later proposal, so it was not counted as personalization
  proof.
- Post-review-remediation fixture class: `6 / 6` passed. Default RimeBridge
  suite: `32` passed, `0` failed, `14` fixture-gated skips. A non-temporary
  user root produced the required pre-creation failure and no residual
  directory.

Evidence:
[`../evidence/t9-auto-anchor-personalization-s5-2026-07-27.md`](../evidence/t9-auto-anchor-personalization-s5-2026-07-27.md).

Independent review handoff:
[`t9-auto-anchor-001-s5-review-handoff.md`](t9-auto-anchor-001-s5-review-handoff.md).

## Handoff

- **Handoff Target:** Product Lead for the next-stage decision after the S5
  immutable checkpoint and durable Architecture/Quality review.
- **Required Handoff Content:** changed files, proposal/validation/rollback
  state semantics, exact RIME-call budget, tests/build results, frozen-sequence
  A/B evidence, rejected cases and remaining privacy/performance limits.
- **Revalidation Trigger:** Production personalization, retention/deletion,
  persistence, Release-default enablement, additional production
  RIME/session/threading work, new diagnostic payload, schema/vendor change or
  performance budget.

## Stage 1 implementation evidence

- `T9ShadowAnchorAnalyzer` is compiled only under `#if DEBUG`.
- The analyzer consumes only the already-returned current candidate page and
  T9 revisions; it performs no `RimeEngine` call and returns no content string.
- One Debug `T9SHADOW` line reports bounded counts and a reason code after each
  synthetic T9 digit.
- Focused tests: `9 / 9` passed.
- Full KeyboardCore: `729 / 729` passed.
- Strict iOS 27 Simulator Debug build: passed with zero diagnostics.
- Strict iOS 27 Simulator Release build: passed with zero diagnostics.
- Release extension binary contains no `T9SHADOW` marker; the current Debug
  build has been installed on the prepared iPhone 17 Pro Max Simulator.
- Five Reminders-hosted no-Path/no-candidate rounds completed on the prepared
  iPhone 17 Pro Max / iOS 27 Simulator. Raw lengths 24 / 32 / 34 reproduced as
  RIME-dominated slow positions in 5 / 5 rounds; the four warm rounds kept UI
  average at 1.55 ms and UI maximum at 2.1 ms.
- Every round emitted 38 shadow observations, zero `proposalReady`, 23
  positive observed-anchor counts and 13 compatible-zero cases. The final
  round was 38 / 38 `candidateSetIncomplete`.
- Runtime sampling is complete. Independent Architecture/Quality conclusions
  remain pending; therefore the Assignment remains `Active`.

## Stage 2 implementation evidence

- `T9ReversibleAutoAnchorPolicy` is pure and bounded. The first visible
  candidate must authorize a catalog-legal closed prefix; lower incompatible
  candidates cannot authorize spelling and remain protected by conservation.
- The controller attempts at most one automatic apply per composition. It
  preserves the pure-digit rollback ledger, validates first-candidate identity
  plus 60% bounded overlap, and permits one restore call only on rejection or
  Delete.
- The Extension enables the experiment only under `#if DEBUG`; the controller
  default and Release behavior remain off.
- Focused Fake RIME tests: `9 / 9` passed, including accepted continuation,
  drift rejection/restore, no retry, Delete rollback, disabled gate and failed
  restore fail-closed.
- Full KeyboardCore: `738 / 738` passed.
- iPhone 17 Pro Max / iOS 27 Simulator Debug and Release builds passed with
  zero diagnostics.
- Frozen Reminders A/B: the first strict all-sampled-compatible version made no
  proposal and retained slow RIME calls near `110 / 71 / 65 ms`. Requiring the
  first candidate to be compatible while retaining all sampled texts for
  conservation produced `T9AUTO status=accepted` at source length 18 with
  `baseline=5 result=5 overlap=5 anchorSlots=13 unresolvedSlots=5`; the
  corresponding major calls were approximately `77 / 54 / 41 ms`.
- Five-run B stability extension: `5 / 5` valid software-keyboard runs accepted
  at the same source slot with `5 / 5 / 5` candidate conservation and no
  rejection or restore-failure outcome. Source-slot 24 / 32 / 34 RIME medians
  were `73.9 / 54.6 / 41.1 ms`; the first two remained over 50 ms in four of
  five runs.
- First S3 corpus slice: six synthetic cases covered accepted (`5/5`, `3/5`),
  rejected/restored (`2/5`, `1/5`), 17-slot not-eligible, high ambiguity and
  Delete after acceptance. Candidate conservation failed closed correctly;
  rejected long input still contained 71–127 ms RIME calls, and Delete safely
  re-opened unresolved `42` spelling ambiguity without exposing digits.
- S3 regression additions freeze the five-candidate 60% boundary and ensure
  personalized candidate ordering cannot override compatible `jin/lin` Path
  disagreement. Focused tests remain 9/9 and KeyboardCore remains 738/738.
- One real-UI Delete left the Extension alive, retained letter-only marked
  presentation and exposed no digit to Reminders. Deterministic rollback
  semantics remain covered by Fake RIME tests.
- The opt-in Reminders XCUITest harness compiles. Its isolated invocation hit
  an iOS 27 cross-`UIScreen` presentation fault before key entry; the later
  manual software-keyboard run supplied the product evidence. The XCUITest
  result is therefore an environment limitation, not a pass.
- Independent review later found and closed two S2 correctness defects:
  Partial Commit could retain the previous automatic rollback ledger, and
  duplicate candidate text could shrink the declared five-slot overlap
  denominator. Checkpoint `0173782` clears old ledger data at the Partial
  Commit boundary while retaining a data-free no-retry tombstone, and counts
  candidate conservation as a bounded multiset over the original slot window.
  Regression tests cover continued remainder input, Delete/undo ownership and
  repeated candidate text at both `2/5` reject and `3/5` accept.
- Post-remediation validation passed focused tests `12 / 12`, KeyboardCore
  `745 / 745`, RIME vendor `11 / 11`, strict iOS 27 Simulator Debug/Release
  builds, the explicit RIME retry fixture `6 / 6` and the default RimeBridge
  suite `32` passed / `14` fixture-gated skips. Architecture and Quality
  independently bound `Pass` verdicts with no P0–P3 findings to full SHA
  `01737824ad95cdaaaf361e83b7b80d3c821aa402`.
- Evidence record:
  [`../evidence/t9-reversible-auto-anchor-s2-2026-07-27.md`](../evidence/t9-reversible-auto-anchor-s2-2026-07-27.md).
- S3 corpus evidence:
  [`../evidence/t9-reversible-auto-anchor-s3-corpus-2026-07-27.md`](../evidence/t9-reversible-auto-anchor-s3-corpus-2026-07-27.md).
- S3 rejection-afterward shadow evidence:
  [`../evidence/t9-auto-anchor-retry-shadow-s3-2026-07-27.md`](../evidence/t9-auto-anchor-retry-shadow-s3-2026-07-27.md).
- S3 real-RIME transaction matrix:
  [`../evidence/t9-auto-anchor-retry-transaction-matrix-s3-2026-07-27.md`](../evidence/t9-auto-anchor-retry-transaction-matrix-s3-2026-07-27.md).

## Stage 3 rejection-afterward shadow evidence

- `T9AutoAnchorRetryShadowAnalyzer` is Debug-only and starts only after the
  S2 ledger is `rejected` and the live raw is pure digits longer than the
  rejected source identity.
- It reuses the pure proposal policy against the already-returned output. It
  does not call RIME, mutate `KeyboardState`, alter the attempt ledger or
  authorize another `replaceInput`.
- Focused observer tests passed 4/4; combined S2 + observer tests passed 13/13;
  KeyboardCore passed 742/742; iOS 27 Simulator Debug and Release builds passed
  with zero diagnostics. The Release Extension contains no `T9RETRYSHADOW` or
  observer symbol.
- Three 40-slot Reminders/software-keyboard runs reproduced the same rejection
  at slot 18 (`5/5/2`) and the same later `proposalReady` positions. The five
  major slow keys immediately followed ready positions.
- This closes the read-only signal question only. A later transaction,
  candidate-conservation result and any change to the one-attempt budget remain
  pending Product/Architecture/Quality review.

## Stage 3 test-only transaction matrix evidence

- A fixture-gated RimeBridge test executed 15 maximal-prefix transactions and
  89 shorter-prefix backoffs in an isolated pinned-librime session. It does not
  call the production controller or modify its one-attempt ledger.
- All maximal proposals failed candidate conservation at `2/5`. Exactly one
  backoff per opportunity passed: two complete syllables with `5/5`
  conservation.
- All 104 transactions restored pure raw identity, active composition, first
  candidate and the bounded five-candidate set.
- In three alternating paired timing rounds, the two-syllable slot-18 anchor
  reduced `≥50ms` calls from 15 to 9. Fixed slow-slot medians improved by
  approximately 13–17ms, but later-input spikes remained.
- Strict test build, explicit real fixture test and the default RimeBridge
  suite passed. The default suite correctly skips this case without the
  isolated fixture.
- The result redirects S3 toward reviewed anchor-depth selection. It does not
  authorize a fixed two-syllable production cap, a second runtime attempt or a
  lower candidate-conservation threshold.
- The frozen six-case depth extension found that two syllables passed the
  known-positive, different-sentence, local-ranking and high-ambiguity cases.
  The legal-but-poor `a × 18` path still failed conservation, and the 17-slot
  threshold case remained ineligible.
- This makes a fixed/capped two-syllable proposal the leading S3 hypothesis.
  The corpus remains too small for production authorization, and adaptive
  multi-call backoff remains outside the current RIME-call budget.
- A declared 24-case extension covered natural sentence shapes, lengths,
  repeated ambiguity, poor shapes and threshold boundaries. Of 21 proposals,
  maximal prefixes accepted 8 and two syllables accepted 9.
- Two syllables preserved all 8 maximal acceptances, added one natural case,
  accepted no poor-input case and did not bypass either threshold case.
  Pinned-runtime regression assertions freeze this distribution.
- Real personalized userdb ordering remains outside this isolated empty-user
  fixture and must enter through the S5 privacy/persistence gate.

Stage 2 implementation, first simulator A/B and the first-sentence five-run B
stability slice are complete. The first S3 six-case corpus slice is also
complete. Independent Architecture/Quality review, a reviewed broader corpus,
later-attempt policy, frozen-startup paired S3 A/B, physical-device evidence
and any Release-default decision remain pending; the Assignment stays `Active`.
