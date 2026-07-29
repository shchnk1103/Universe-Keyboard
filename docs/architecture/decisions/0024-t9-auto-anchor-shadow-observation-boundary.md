# ADR 0024: T9 Auto-Anchor Observation And Reversible Prototype Boundary

- **Status:** Proposed — S4 independently validated; S6-A manual pair complete;
  S2.1 rolling-extension design independently reviewed and implementation
  authorized; shipping decision deferred
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

## S6-A amendment: internal Release-like physical-device evidence

S6-A uses two source-visible conditions. Both must be absent from
`project.pbxproj`, shared schemes, ordinary Release settings and archive/export
paths:

- `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` compiles the same minimum measurement
  surface into A and B;
- `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED` additionally enables the existing
  S4 transaction in B only.

Both arms use the common condition and Release optimization. The enabled
condition is their only declared difference; A keeps the controller default
off.

The preflight condition may expose only the minimum content-free measurement
surface required to identify:

- gate identity and ordered event count;
- total/controller/UI and existing segmented RIME timings;
- automatic-attempt status plus candidate/slot counts;
- session/startup validity and unexpected commit/termination.

It must not enable unrelated Debug observers or diagnostics. In particular,
S1 shadow/retry analyzers, typo traces and content-bearing developer logs
remain excluded unless separately authorized. The measurement surface may
record only lengths, counts, durations, bounded status/reason values and
opaque run identifiers.

S6-A evidence is mandatory when the common condition is compiled: its
content-free marker, per-action records, transaction outcome and arm summary
bypass the user-facing diagnostics preference and performance-category
switch. The bypass is unavailable in ordinary Release. Each action records
only whether an engine commit occurred plus the opaque native session identity
and read-only validity before/after the call. The 38th action writes an arm
summary and submits an ordered, non-blocking flush; the driver then keeps the
extension visible for one second and fails the arm unless the internal
content-free evidence view returns exactly 38 ordered records, no commit, one
stable valid session, the expected marker and the expected A/B outcome count.
The gate itself never depends on logging state.

The driver uses a monotonic clock and a fixed 200 ms start-to-start schedule.
Maximum lateness from that schedule is frozen at 50 ms as a driver-validity
budget only, not a Product latency SLO. Any arm exceeding it remains in the
manifest as invalid; it is never silently replaced.

A and B are separate signed internal binaries from one immutable source
checkpoint. Their declared behavioral difference is only the B-only enabled
condition; both contain the identical measurement surface. Both use Release
optimization and the same bundle/App Group/signing/schema/runtime identity.
The harness must preserve device RIME and userdb state, avoid candidate/Path
selection and operate only visible T9 letter-group keys.

Physical iOS 27 on the declared iPhone 13 Pro can render Universe Keyboard
while exposing none of its third-party keyboard elements to the XCTest process,
including when Reminders and SpringBoard are queried as separate coherent
accessibility owners. Two Human-confirmed attempts reached this exact boundary
before any fixture action. S6-A therefore permits a test-only coordinate
executor, but not fixed or guessed coordinates.

For each arm, the internal main App prepares a unique opaque token with
canonical form `S6A-[0-9A-F]{32}` from a new 128-bit UUID. One versioned App
Group envelope is atomically replaced through
`absent → prepared(token) → consumed(token) → absent`; it contains no user
content. Main App is the sole producer/cleaner and Extension the sole consumer.
The Extension snapshots the token once for the arm and may continue with that
in-memory value after consumption; a reconstructed Extension must reject a
consumed envelope. Missing, malformed, retained-log-reused or
current-matrix-reused tokens fail closed. Crash residue is recorded and
replaced only by a new token, never resumed; cleanup removes only a matching
consumed envelope. A separate versioned, bounded, content-free registry retains
the opaque tokens used by the current physical matrix so reuse still fails
after older log lines roll out of retention. It is not a transfer channel:
Main App updates it before preparing an envelope, Extension never reads it, and
per-arm cleanup leaves it intact. Malformed registry state fails closed. After
the final arm cleanup and before ordinary Release restoration, an explicit
preflight-only finalize action may remove the registry only while the envelope
is absent.

The Extension binds every gate marker, geometry record, segment record, arm
summary and transaction outcome to that token. Geometry contains only eight
ordered slot indices and rectangles for the visible T9 letter groups; it
contains no letters, internal digits, pinyin, candidates or host text.

The one canonical coordinate space is the current keyboard
`view.window.windowScene.screen.coordinateSpace` in portrait logical points
with top-left origin. This is the iOS 27 context-owned form of the active
physical screen, not deprecated global screen lookup. A geometry record carries
screen bounds, native scale, portrait orientation, the T9 hit-target
interaction envelope and slot rectangles. The envelope is canonically the
union of the eight serialized slot rectangles within the existing geometry
tolerance; it is not the `UIInputViewController` root view, keyboard chrome or
container frame. Screen, envelope and slots must be finite and strictly
positive; each slot is at least `30 × 30` points, wholly inside the envelope
and screen, and non-overlapping. The envelope must be wholly on-screen with
`minY ≥ 0.5 × screenHeight`. Slots must match the frozen row-major topology
`2 + 3 + 3`: center Y differs by at most four points within
each row, center X strictly increases within a row, and row centers strictly
increase. The runner also requires the recorded logical screen bounds to equal
the foreground Reminders frame before converting slot centers to normalized
screen offsets.

The runner first reads a `phase=prepared` geometry and its canonical SHA256.
After it returns to the same empty editor, the first real T9 key handler emits
`phase=execution` geometry from the current view before input processing. Its
digest must equal the prepared digest.

Final acceptance uses a same-token partial order rather than a false linear
log order. Marker precedes prepared geometry, which precedes execution
geometry. The 38 `T9SEG` records are ordered by action and `T9ARM` follows
action 38. A has no scoped `T9AUTO`; B has exactly one after execution geometry
and before `T9ARM`, bound to the producing action/event. Because it is emitted
inside `controller.handle`, it may precede that action's later `T9SEG`. Thus
coordinates execute input, while fresh Extension-owned geometry plus the
handler-time geometry and resulting records prove origin and layout stability.

A stale/reused token, non-canonical coordinate space, invalid topology, a fixed
screen-coordinate table, a rectangle outside the validated software-keyboard
region, geometry drift, an incomplete token transition, or any missing/
duplicate/mismatched record in that chain invalidates the arm. The token and
geometry path are compiled only by `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`; ordinary
Release neither reads nor writes its envelope or matrix registry. They do not
alter keyboard layout, product accessibility, RIME behavior or user data.

This amendment does not accept Release behavior. It only makes physical-device
evidence possible without compiling all `DEBUG` behavior into the measured
binary. Ordinary Release must remain gate-off and contain no S6-A marker after
the preflight. Because the fixed matrix ends on B, cleanup must reinstall the
same-checkpoint ordinary gate-off Release without uninstall/reset and verify
the installed identity plus successful keyboard switching. A failed restore
blocks the task and must be reported before the keyboard returns to ordinary
use.

Runtime evidence identifies the synthetic fixture only by stable case ID,
SHA256, action count and cadence. Automation is confined to a Human-created,
otherwise-empty disposable Reminders list and never deletes host objects.
The UI runner does not issue XCTest failures while Reminders is visible; it
first replaces the host with an internal content-free evidence surface.
Physical `.xcresult` bundles stay in an exact per-arm temporary directory,
must be scanned for attachments before extraction and are never copied into
repository evidence. Any content-bearing screenshot or UI hierarchy makes the
arm invalid; only reviewed content-free console/manifest output and artifact
digests may be retained.
Any project-default flag, archive path, uninstall/reset requirement, content
logging, second transaction/backoff, undeclared A/B difference or automated
host-object deletion is a Stop Condition.

Architecture entry and exit reviews are required under:
[`T9-AUTO-ANCHOR-001-S6A`](../../assignments/t9-auto-anchor-001-s6a-device-preflight.md).

### S6-A execution-method amendment: Human physical input

Physical iOS rendered Universe Keyboard without exposing its key elements to
the XCTest accessibility owner. Five coordinate-driver attempts produced zero
synthetic key actions. The Product Owner therefore retired coordinate-driven
XCTest, guessed screen positions and Computer Use typing from this
third-party-keyboard performance workflow.

Future physical evidence uses:

- exact same-source signed internal artifacts installed by replacement;
- a Human-prepared empty Reminders field and software keyboard;
- Human entry of the frozen synthetic sequence without Path/candidate
  selection;
- content-free App diagnostics bound to executable hashes and device/build
  identity;
- event/session/commit integrity checks plus Human-reported functional
  anomalies and perceived stall position;
- ordinary gate-off Release replacement restoration after internal variants.

Manual cadence prevents this evidence from becoming a fixed-cadence benchmark.
Deterministic timing and state-machine automation remain at controller and
pinned-RIME integration boundaries. The detailed reusable procedure belongs to
`PERFORMANCE_BASELINE.md`; the former coordinate contract remains historical
evidence for why it was retired, not a route to retry.

## S2.1 proposed amendment: one cumulative rolling extension

The first physical-device Human pair showed that one accepted seven-slot
anchor lowered matched RIME peaks but left eleven unresolved slots and did not
remove the perceived failure class. The next bounded architecture hypothesis
is one cumulative extension of an already accepted automatic prefix.

Architecture and Quality independently passed this design. Product subsequently
authorized implementation under the linked S2.1 Assignment. Release behavior
remains unauthorized.

### 12. Accepted-prefix continuity

The existing first S4 transaction remains unchanged. A second transaction may
be considered only after:

- the first transaction was accepted;
- at least one later physical T9 digit was successfully processed;
- the live raw still exactly matches the first transaction's updated mixed
  identity;
- there is no Partial Commit, selected Path or confirmed Path segment;
- the already-returned snapshot produces a cumulative proposal that preserves
  every previously automatic syllable exactly and adds exactly two new
  complete, catalog-legal syllables.

The extension is cumulative because the prior mixed prefix is reversible
transaction state, not user Path authority. It may extend that state but may
not rewrite or reinterpret it. Missing or divergent evidence performs no call
and does not consume the second attempt.

### 13. Two-attempt ledger

The process-local ledger must retain:

- the complete original digit identity, updated as new digits arrive;
- the exact applied mixed raw;
- cumulative anchored syllable/slot counts;
- attempt count and source length at the preceding attempt;
- a data-free terminal tombstone for Path, Partial Commit, rejection and
  exhausted-budget boundaries.

Candidate text remains ephemeral inside one transaction. No content is logged
or persisted.

While the ledger is accepted, a later digit advances original and mixed
identity atomically. Before ordinary RIME processing, the previous live raw
must exactly equal the ledger's applied mixed raw. Only a successful,
non-committing, usable output may append that digit to the full original
`sourceDigits` and replace the applied mixed identity with that output's exact
raw. The updated ledger is published before attempt-2 eligibility is checked;
anchor counts and attempt count do not change during this advancement.

Ignored/failed input, commit, unusable output, Path, Partial Commit, reset,
fallback and lifecycle abandonment do not advance the ledger. Their existing
clear/tombstone transitions apply. A pre-key identity mismatch is an invariant
failure: do not process the digit or rebase the ledger; clear the composition
with exactly one same-session reset and discard automatic payload. No session
recovery/creation or input replay is allowed.

Attempt 2 is consumed before its `replaceInput` call. It is the final automatic
attempt in the composition. Attempt 1 rejection remains terminal; S2.1 is not a
rejection retry or adaptive backoff.

### 14. Second-transaction validation and rollback

The second transaction applies the cumulative extended raw once and uses the
same exact-raw, no-commit, usable-composition, first-candidate and bounded
multiset-conservation rules as S4.

Its rollback target is the exact prior accepted mixed raw captured immediately
before attempt 2:

- acceptance publishes the cumulative output and updates the ledger;
- rejection restores the prior mixed raw once, retains the first anchor and
  exhausts the budget;
- restore failure resets the session and abandons composition fail-closed;
- no pure-digit fallback chain runs during transaction validation.

Pure digits remain the user-Delete authority. Delete after either accepted
anchor restores the accumulated original digits once and then performs the
existing normal deletion.

The exact additional RIME boundary-mutation budget counts cumulative
auto-anchor-owned `replaceInput` and fail-closed reset mutations beyond
ordinary successful key/Delete `processKey` work:

| Composition path at endpoint | Cumulative extra `replaceInput` | Same-session clear/reset |
|---|---:|---:|
| first accepts; no second transaction | 1 | 0 |
| both attempts accept | 2 | 0 |
| first rejects and pure digits restore | 2 | 0 |
| first restore fails | 2 | exactly 1 |
| first accepts; second rejects and prior mixed raw restores | 3 | 0 |
| second prior-mixed restore fails | 3 | exactly 1 |
| accepted pre-key identity mismatch after first acceptance, second acceptance, or second rejection/prior-mixed restore | 1, 2 or 3 total; 0 new at mismatch | exactly 1 |
| Delete succeeds/fails after first acceptance only | 2 total | 0 on success; exactly 1 on failure |
| Delete succeeds/fails after two acceptances | 3 total | 0 on success; exactly 1 on failure |
| second rejects/restores, then Delete succeeds/fails | 4 total | 0 on success; exactly 1 on failure |

Only one automatic transaction may execute on one physical key.
Every reset above clears the existing session composition only. S2.1 prohibits
`recoverSession`, session creation, rebuild/replay, deployment and multi-step
fallback.

Accepted-identity advancement is one indivisible ledger publication:
`sourceDigits` and exact returned mixed raw update together; cumulative anchor
counts and attempt count remain unchanged; attempt 2 is not consumed.
Eligibility may read only the fully published ledger. Commit, failed/unusable
output, Path, Partial Commit and lifecycle abandonment allow only their
existing clear/tombstone transition—never `recoverSession`, session creation or
input replay.

### 15. Personalization and user authority

RIME's existing local learning may influence the current first-candidate rank,
so rolling proposals naturally observe personalized ordering. S2.1 does not
query userdb, create a learning event, persist candidate history or treat rank
as correctness authority.

Every proposal still needs compatible catalog evidence; every transaction
still needs first-candidate preservation and bounded conservation. Explicit
Path selection supersedes automatic and learned preference. Path/Partial
transitions clear automatic rollback payload and retain an exhausted
composition tombstone so later state changes cannot re-grant an attempt.

### 16. Evidence boundary

The experiment uses three logical arms:

- `A0`: automatic anchor disabled;
- `A1`: existing one-anchor S4 behavior;
- `B2`: one cumulative S2.1 extension.

The B2 artifact adds
`T9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED` to the two existing A1 preflight
conditions. The controller keeps a separate default-off rolling gate so
enabling the established base prototype alone remains exactly A1.

Deterministic KeyboardCore and pinned-RIME integration tests own exact call,
state, rollback and corpus coverage. Physical-device exploration compares
`A1` with `B2` through the canonical Human-input method. The first pair stops
immediately if B2 does not execute its second accepted transaction before the
first known event-24 spike, introduces a functional anomaly, fails to reduce
the paired `≥100 ms` event count or increases paired worst latency. These are
experiment routing rules, not a shipping SLO.

Content-free diagnostics may add attempt number, bounded status/reason,
cumulative/new anchor counts, unresolved slots, conservation counts and
apply/restore duration. Every transaction outcome also carries the same opaque
run identity and one-based action ordinal as the arm's ordered key records.
For the frozen fixture, B2 attempt 2 is valid only when its ordinal is strictly
after attempt 1 and `<= 23`, before physical action 24. Diagnostics may not
contain raw input, pinyin, candidates, host text or user-dictionary data.

The frozen integration arm contract is exact: A0 performs zero automatic
apply/accepted outcomes/extra replacement calls; A1 performs exactly one
existing S4 accepted apply and no second transaction; B2 performs exactly two
accepted cumulative applies. All other source, optimization, fixture, schema,
isolated-user-root, session, cadence and instrumentation facts are identical;
any undeclared difference or positive-fixture rejection invalidates the arm.

For physical exploration, the first `A1→B2` pair counts as pair 1 if it passes
the stop rule. A later counterbalanced matrix adds only `B2→A1` and `A1→B2`,
for three total pairs rather than four.

### S2.1 stop conditions

Stop if the design requires:

- a second attempt after first rejection, a third attempt or two automatic
  transactions on one key;
- adaptive prefix backoff or rewriting the existing automatic prefix;
- weaker candidate conservation or learned-rank authority;
- candidate-window/later-page scans, another RIME session or async RIME work;
- multi-step validation rollback, persistence or content-bearing logs;
- host-text, 26-key, schema/vendor, user-setting or Release-default changes.

The complete design and acceptance matrix are owned by:
[`T9-AUTO-ANCHOR-001-S21`](../../assignments/t9-auto-anchor-001-s21-rolling-design.md).

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
