# ADR 0024: T9 Auto-Anchor Observation And Reversible Prototype Boundary

- **Status:** Proposed — S4 capped-two-syllable preflight independently validated; Product/Release decision deferred
- **Date:** 2026-07-27
- **Decision owner:** 🏛️ Architecture & Knowledge Steward
- **Product authority:** [`PD-T9-AUTO-ANCHOR-001`](../../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)
- **Assignment:** [`T9-AUTO-ANCHOR-001`](../../assignments/t9-auto-anchor-001.md)
- **Extends:** ADR 0010 diagnostic provenance boundary and ADR 0023 T9 Path
  authority/presentation boundary

## Context

The frozen long-composition matrix shows that unresolved T9 ambiguity, not raw
length alone, amplifies librime `process_key` cost. Explicit cumulative Path
anchoring reduced the retained simulator slow-key count from `15 / 190` to
`0 / 190` without host commit.

The desired product outcome is uninterrupted long input without requiring the
user to select every Path. Before defining a production automatic anchor, the
system must prove what whole-composition authority is actually available.

ADR 0023 guarantees a complete local catalog for the **current focus
syllable**. It intentionally does not enumerate the cartesian product of all
whole-sentence segmentations. RIME candidate comments rank paths but a current
page may be incomplete. Neither source alone currently proves every valid
whole-composition Path.

## Decision

### 1. Stage 1 is observation-only

A Debug-only analyzer may inspect the `RimeOutput` and T9 provenance state that
already exist after a key. It returns a content-free observation and never
mutates product state.

It must not:

- call any `RimeEngine` method;
- replace input, select/commit a candidate or confirm a segment;
- add fields to `KeyboardState`;
- read or write App Group/user-dictionary data;
- influence candidate ranking, Path presentation or marked text.

### 2. Observed prefix is not authority

The analyzer may normalize compatible ASCII pinyin comments, compare them by
complete syllable and calculate their common prefix.

A common segment is considered **closed for observation** only when every
observed compatible Path contains at least one later segment. The last
potentially extendable segment remains unresolved.

The result is an observation, not production authorization. It is proposal
ready only for Stage 1 evaluation when all of these snapshot conditions hold:

- candidate page number is zero;
- `hasMorePages == false`;
- at least one candidate exists;
- every candidate supplies a valid, source-digit-compatible ASCII Path;
- current raw-input generation and provenance revisions are nonzero;
- at least one closed common syllable exists.

Any missing condition produces an explicit block reason while retaining
content-free coverage counts where available.

### 3. Personalization boundary

RIME user-dictionary learning may already influence current candidate order.
Stage 1 observes that resulting order but does not query, copy or persist the
dictionary.

Ordering cannot override divergent Path evidence. Reordering the same Path set
must produce the same common-prefix result. A later personalized auto-anchor
requires a separate decision covering authority, retention, deletion, decay,
rollback and privacy.

### 4. Privacy payload

The observation may contain only:

- raw/provenance revision numbers;
- candidate, compatible-path and rejected-path counts;
- observed/closed common-syllable counts;
- anchor/unresolved slot counts;
- evidence-completeness boolean and bounded reason code.

It must not return or log raw digits, pinyin strings, candidate text, committed
text, user-dictionary entries or host context.

### 5. Hot-path and Release boundary

- Analyzer and call site are guarded by `#if DEBUG`.
- It performs bounded in-memory parsing of the already-present current
  candidate page.
- It performs no I/O, async wait, lock, persistence, JSON encoding or RIME
  operation.
- The existing asynchronous bounded logger may record one content-free
  `T9SHADOW` line per synthetic T9 key when Debug performance diagnostics are
  used.
- Shipping Release does not compile or emit this observer.

## Consequences

- The project can measure whether current snapshots contain enough authority
  before designing production mutation.
- Candidate-page incompleteness becomes visible rather than silently treated as
  consensus.
- Stage 1 may report low proposal coverage; that is a valid result and informs
  the Stage 2 authority design.
- No automatic performance improvement is expected from Stage 1 because it
  intentionally does not change RIME input.

## Deferred Stage 2 decision

The Stage 1 evidence and the frozen-sequence catalog audit reject complete local
segmentation as a practical authority source: the representative 38-slot
sequence has `3,486,320,640` catalog-legal segmentations, starts with
`ji / li / jin / lin`, and has no forced target syllable at any intended
boundary. A full RIME candidate scan would move unbounded work into the hot path
and is also rejected.

## Stage 2 amendment: reversible bounded preference

### 6. Experimental gate

The reversible controller capability defaults off. The Keyboard Extension may
enable it only in an explicit Debug experiment. Release-default behavior and a
user-facing control remain unauthorized.

### 7. Proposal evidence

A proposal may inspect only a bounded prefix of the already-returned first
candidate page. The first candidate must have a source-digit-compatible ASCII
comment path. Lower-ranked sampled candidates with compatible paths may
strengthen the common prefix; incompatible or missing lower-ranked paths cannot
authorize spelling, but their candidate texts remain in the post-replacement
conservation check. The compatible prefix must:

- contain only complete catalog syllables matching their digit slices;
- contain at least two closed syllables;
- consume a meaningful leading slot run while leaving unresolved digits;
- never override an explicit Path, Partial Commit or stale composition.

This is a preference proposal, not complete authority. Candidate order may
reflect librime's local learning, but Stage 2 does not inspect or persist that
learning separately.

### 8. One-attempt transaction

Each composition owns one in-memory attempt ledger. Applying a proposal:

1. records the original pure-digit identity and bounded baseline candidates;
2. calls `replaceInput` once with `confirmed'syllables' + trailingDigits`;
3. rejects any commit, unusable composition or raw-identity mismatch;
4. requires the original first candidate to remain first and a reviewed bounded
   overlap of baseline candidates to remain present;
5. on rejection, restores the original digits before publishing state and never
   retries automatically in that composition.

Candidate text is used only ephemerally for same-transaction comparison. It is
never logged or persisted.

### 9. User ownership and Delete

- Explicit Path selection supersedes and clears automatic ownership.
- Delete first restores the accumulated original digit identity, then performs
  the user's normal deletion, so an automatic spelling never becomes
  irreversible user intent.
- Commit, mode/page/lifecycle abandonment, fallback and reset clear the ledger.
- Failure to restore a usable raw identity stops the experiment and fails
  closed; it must not expose digits or commit guessed text.

### 10. Call and privacy budget

- No candidate-window scan, later-page walk, second session, async wait,
  persistence or dictionary access.
- At most one automatic apply call per composition.
- One additional restore call is permitted only for validation rejection or
  explicit user Delete rollback.
- Debug diagnostics contain status, counts, slot lengths and timing only.
- The prototype does not alter 26-key behavior.

### 11. Initial Simulator observation

The frozen Reminders sequence first proved that requiring every sampled
candidate path to be compatible produced no attempt: the real first page
contained one compatible path and eight rejected paths. The reviewed
first-candidate rule above then produced one accepted transaction at source
length 18:

- baseline/result/overlap candidate counts: `5 / 5 / 5`;
- anchored/unresolved source slots: `13 / 5`;
- no host commit and no candidate-window query;
- one subsequent Delete restored the digit ledger before normal deletion;
- representative RIME slow calls changed from approximately
  `110 / 71 / 65 ms` to `77 / 54 / 41 ms` in the single Debug A/B pair.

This is prototype evidence, not an accepted architecture decision, production
budget or Release claim. Multi-run S3 evidence and independent review remain
required.

## Stop conditions

Stop Stage 2 if implementation needs later-page scans, repeated automatic
attempts, a second session, persistence, dictionary access, content-bearing
logs, Release-default enablement or an assumption that a partial candidate set
is complete.

## S4 preflight amendment: capped proposal depth

The reviewed S3 transaction matrices make a capped two-syllable proposal the
leading bounded hypothesis: across the declared corpus it preserved every
maximal-prefix acceptance, added one natural acceptance and did not admit the
declared poor or threshold cases. Product has authorized a Debug-only preflight
of that hypothesis.

For an otherwise eligible S2 proposal, the policy may retain only the first two
complete, catalog-legal syllables before appending the unresolved digit tail.
This is a proposal-depth cap, not a second transaction or runtime backoff
search. All other S2 authority remains unchanged:

- one automatic apply attempt per composition;
- no write to `selectedPath`, `confirmedSegmentValues` or other user-confirmed
  Path ownership;
- the same baseline first candidate;
- the same original-window multiset candidate-conservation threshold;
- the same rejection/Delete rollback and user-ownership boundaries;
- no candidate-window query, persistence, second session or content logging;
- no 26-key change, user-facing control or Release-default enablement.

Architecture entry review must confirm that the cap remains a pure policy input
and does not duplicate transaction ownership in the controller. Exit evidence
must include deterministic policy/controller tests, the declared 24-case and
isolated-personalization regressions, strict Debug/Release builds and a frozen
startup-paired Simulator A/B. Physical-device and Product Gate acceptance
remain outside this preflight.

The authorized S4 preflight is validated at immutable implementation checkpoint
`22d34ddb612dcf50e5dc0dde569ba82c226d3731`. Deterministic tests, the explicit
real-RIME class (`7 / 7`, zero skipped), the 24-case and isolated-personalization
matrices, strict Debug/Release builds and five valid startup pairs all passed.
Architecture and Quality independently returned `Pass` with no P0–P3 findings.
This validates the bounded Debug experiment only; the ADR remains Proposed
because Release-default behavior, product controls and physical-device Product
Gate evidence are still deferred.

## Stage 3 read-only amendment: later opportunity after rejection

After the single S2 transaction has rejected and restored pure digits, a
Debug-only observer may evaluate later, already-returned snapshots with the
same pure proposal policy.

The observer is allowed only when:

- the S2 ledger phase is `rejected`;
- the live raw is pure digits and longer than the rejected source identity;
- there is no Partial Commit, selected Path or confirmed Path segment.

It returns only eligibility and count fields. It must not call RIME, mutate
`KeyboardState`, reset the attempt ledger or execute another `replaceInput`.
The one-attempt transaction budget remains unchanged.

Three initial Simulator runs produced identical later opportunity positions,
with the principal slow keys immediately following an opportunity. This
supports a future test-only transaction matrix, but does not establish
candidate conservation or authorize a second runtime attempt. Evidence:
[`../../evidence/t9-auto-anchor-retry-shadow-s3-2026-07-27.md`](../../evidence/t9-auto-anchor-retry-shadow-s3-2026-07-27.md).

### Test-only transaction result

The isolated pinned-librime matrix subsequently executed every maximal
opportunity and progressively shorter prefixes. All 15 maximal proposals
failed the existing conservation gate at `2/5`. At every opportunity, only
the two-syllable backoff retained `5/5`; all 104 attempted variants restored
the original raw and bounded candidates.

A three-round paired timing slice reduced `≥50ms` calls from 15 to 9, while
later slow positions remained. This identifies proposal depth as the next S3
variable. It does not amend the production maximal-prefix algorithm,
one-attempt call budget or 60% conservation gate. Broader-corpus evidence and
separate review are required before any such amendment.

Evidence:
[`../../evidence/t9-auto-anchor-retry-transaction-matrix-s3-2026-07-27.md`](../../evidence/t9-auto-anchor-retry-transaction-matrix-s3-2026-07-27.md).

The frozen six-case extension retained the same safety shape: two syllables
passed four viable cases, still failed the legal-but-poor `a × 18` case, and
did not bypass the 18-slot threshold. A capped two-syllable proposal is
therefore eligible for broader S3 evaluation. It is not yet an amendment to
the production proposal rule. Adaptive backoff would require multiple
replacement calls and remains prohibited by the current call budget.

A subsequent 24-case declared corpus produced 21 proposals. The maximal rule
accepted 8; a fixed two-syllable cap accepted 9, preserving all 8 original
acceptances and adding one natural sentence. It accepted no poor-input case and
did not bypass the source-length threshold. This strengthens eligibility for
an explicitly authorized capped-policy prototype, but does not amend this ADR:
the corpus is synthetic, the isolated user directory is unpersonalized, and
physical-device evidence is absent.

## Stage 5 isolated personalization observation

Product authorized a test-target-only learning experiment in a generated
`/private/tmp` user directory. The test may select a synthetic candidate a
bounded number of times, close and reopen the isolated RIME session, and
compare candidate rank plus two-syllable conservation before/after learning.

Required controls:

- no App Group, real userdb, sync directory, backup or network access;
- no candidate text, raw input or pinyin in machine summaries/evidence;
- candidate-order delta is the proof; file existence is not;
- the RIME session is finalized before the generated directory is deleted;
- no production Controller, hot-path or retention-policy change.

This authorization observes whether existing RIME personalization changes the
evidence consumed by the cap. It does not make learned ordering sufficient Path
authority and does not authorize production userdb queries.

The isolated observation produced a restart-stable rank change from 4 to 0
after one complete synthetic selection. The same long-composition
two-syllable transaction retained `3/5` overlap and remained accepted before
and after learning. Earlier calibration also showed that selecting a partial
long-composition candidate can train its continuation rather than the visible
segment, so production logic must never infer learning success from a selection
call alone. The generated directory was removed after finalization.

Evidence:
[`../../evidence/t9-auto-anchor-personalization-s5-2026-07-27.md`](../../evidence/t9-auto-anchor-personalization-s5-2026-07-27.md).

The authorized first S5 extension may add at most three independent
complete-learning cases and one partial-selection negative case. Every case
uses a fresh generated user directory and the same content-free evidence
contract. This prevents learned state from one corpus item from contaminating
another and freezes the architectural distinction between candidate selection
and a completed, rank-observable learning event.

The completed matrix confirmed that boundary. Three complete selections each
produced restart-stable `4 → 0 → 0` ranking. Conservation remained independent:
two `3/5` cases stayed accepted and one `2/5` case stayed rejected. The partial
negative required a continuation selection, moved `2 → 3`, and removed the
later proposal. Therefore candidate selection alone is not learning authority,
and learned rank never replaces proposal or conservation authority.

## Alternatives Considered

### Use file existence as personalization proof

Rejected. A generated `*.userdb*` file does not prove ranking changed or that
the learned state survives reopening.

### Learn directly from a long partial candidate

Rejected as positive evidence. The frozen negative shows that a partial
selection may train a continuation, move the visible segment backward and
remove a later proposal.

### Reuse one personalized user directory across corpus cases

Rejected. Cross-case learning would make baselines order-dependent and prevent
one failing case from identifying its own state transition.

### Query production userdb state from the Keyboard Extension

Rejected. It would add persistence/filesystem coupling to the input boundary
and would require a separate product, privacy and architecture decision.

## Risks

- An environment variable could target real user data unless the test
  canonicalizes the path and fails outside `/private/tmp`.
- Exact rank assertions are intentionally sensitive to fixture/schema changes;
  an approved fixture update requires a reviewed new baseline.
- Synthetic candidates do not establish representative language quality.
- Simulator fixture timing and ranking do not prove physical-device or Release
  behavior.
- librime fixture deployment may emit an `essay` read-only diagnostic even
  when the declared matrix passes; this remains a fixture/runtime observation,
  not a suppressed success signal.

## Follow-up Work

- Keep the `/private/tmp` allowlist and exact selection budget under regression
  coverage.
- Preserve checkpoint `9c4f86f`, which freezes the S5 harness and previously
  ignored evidence reviewed by Architecture and Quality.
- Preserve checkpoint `0173782`, which closes the reviewed S2 Partial Commit
  ledger-boundary and duplicate-candidate overlap findings. Partial Commit
  owns the remainder composition, so the prior automatic ledger must retain no
  rollback payload; the data-free rejected phase only preserves the one-attempt
  budget. Candidate conservation counts bounded candidate slots as a
  multiset, using the original window length as the threshold denominator.
- Add a portable, provenance-recording S5 fixture runner only under explicit
  scope.
- Preserve the completed independent Architecture/Quality re-review against
  its exact snapshot; repeat it if that snapshot changes before checkpointing.
- Treat production personalization, retention/deletion, broader language
  coverage, physical-device performance and Release enablement as later gates.

## Related Documents

- [`PD-T9-AUTO-ANCHOR-001`](../../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)
- [`T9-AUTO-ANCHOR-001 Assignment`](../../assignments/t9-auto-anchor-001.md)
- [`S5 review handoff`](../../assignments/t9-auto-anchor-001-s5-review-handoff.md)
- [`S5 evidence`](../../evidence/t9-auto-anchor-personalization-s5-2026-07-27.md)
- [`RIME user dictionary`](../../RIME_USER_DICTIONARY.md)
- [`Shared container and RIME lifecycle`](../shared-container-and-rime-lifecycle.md)
- ADR 0001, ADR 0003, ADR 0004, ADR 0010 and ADR 0023
