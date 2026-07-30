# Product Decision: T9-AUTO-ANCHOR-001 Authorization

**Decision ID:** `PD-T9-AUTO-ANCHOR-001`
**Lifecycle status:** `Recorded — S2.3 exploratory complete (direction FAIL); Product chose Hold/harvest residual route; default-off S2.1–S2.3 stack retained; no next knife authorized`
**Date / timezone:** `2026-07-27 Asia/Shanghai`
**Decision source:** Human Product Owner instructions in active Codex task
`019f9dac-ff8d-7872-a913-d5dd3f930dc1`
**Assignment:** [`T9-AUTO-ANCHOR-001`](../assignments/t9-auto-anchor-001.md)
**Plan:** [`T9 long-composition process_key latency`](../plans/t9-long-composition-process-key-latency-plan.md)
**Architecture:** [`ADR 0024`](../architecture/decisions/0024-t9-auto-anchor-shadow-observation-boundary.md)

## Product problem

Long uninterrupted Chinese nine-key input grows an unresolved pinyin ambiguity
graph. The frozen simulator matrix attributes its deterministic stalls to
librime sentence construction and table lookup. Explicit user Path selection
collapses that graph and removes the measured spikes, but requiring repeated
Path interaction is not the intended final experience.

## Product direction

The final direction is automatic, safe and reversible bounding of the
unresolved T9 tail:

1. Explicit user-selected Path remains the correctness reference and correction
   surface.
2. Complete local-path proof is not achievable for representative long T9
   input: the 38-slot frozen sequence has billions of catalog-legal
   segmentations and no forced leading syllable. The experimental production
   model is therefore a bounded preference followed by candidate-conservation
   validation and immediate rollback, not a claim of mathematical uniqueness.
3. The first implementation stage is observation-only shadow analysis. It may
   calculate proposals and content-free metrics, but must not change RIME,
   marked text, candidates, host text or user learning.
4. Local user-dictionary ranking may later contribute a preference/confidence
   signal. It is not Path authorization and cannot independently select or
   anchor a spelling.

## Stage 2 authorization

Stage 2 may:

- ship a controller capability that defaults off and is enabled only by an
  explicit experimental/Debug integration;
- derive one closed, catalog-legal prefix from a bounded sample of the
  already-returned first candidate page;
- call `replaceInput` once to apply that prefix while retaining the unresolved
  digit tail;
- accept only when the resulting raw identity is exact, no text was committed,
  the original first candidate is preserved and bounded candidate overlap
  passes;
- call `replaceInput` once more only to roll back a rejected proposal or to
  restore pure-digit ownership before Delete;
- keep an in-memory composition ledger of the original digits and accepted
  replacement; clear it at commit, abandon, explicit Path ownership and other
  composition boundaries;
- emit content-free reason/count/timing diagnostics in Debug and add fake-engine
  tests plus synthetic simulator evidence.

Stage 2 may not:

- claim that first-page candidate consensus is complete authority;
- scan candidate windows or later pages, create a second session, deploy
  resources or persist from the key path;
- commit text, learn a phrase, read/copy the user dictionary or add a duplicate
  phrase store;
- retry multiple automatic anchors in one composition;
- enable the behavior by default in Release or expose a user setting without a
  later Product/Architecture/Quality decision.

## Stage 1 authorization

Stage 1 may:

- add Debug-only pure analysis over the already-returned RIME snapshot;
- distinguish observed common closed prefixes from complete authority;
- fail closed when the candidate set is paged, comments are missing/invalid,
  the snapshot is stale or digit compatibility fails;
- emit only bounded counts, revisions and reason codes;
- add deterministic KeyboardCore tests and synthetic simulator diagnostics.

Stage 1 may not:

- call `replaceInput`, select/commit a candidate or mutate a segment ledger;
- add RIME calls, candidate-window scans, a second session or deployment work;
- read, copy, persist or reset user-dictionary data;
- log raw input, pinyin, candidate text, committed text or host context;
- ship the observer in Release;
- claim that current candidate comments enumerate every valid whole-sentence
  Path.

## Decisions deferred

The following require a later Product and Architecture amendment:

- personalization thresholds, retention and deletion;
- background/serial RIME execution;
- default enablement, user controls and Release acceptance budgets.

## S2.1 rolling-shadow-anchor design authorization

On `2026-07-29 Asia/Shanghai`, after reviewing the first physical-device manual
pair, the Human Product Owner directed the team to continue the S2.1 rolling
shadow-anchor design under KOS 2.0.

The observed B arm accepted one seven-slot/two-syllable anchor with full
bounded candidate conservation, but left eleven unresolved slots. Its matched
RIME-dominated peaks were lower than A yet remained visibly slow. Product
therefore authorizes **design only** for one cumulative extension after the
first anchor has already been accepted.

The design direction is:

- keep the existing first S4 transaction unchanged;
- permit at most one later cumulative extension, for at most two total
  automatic apply attempts per composition;
- require at least one successfully processed later physical T9 digit and
  fresh already-returned candidate evidence before the extension;
- preserve the existing automatic prefix exactly and add no more than two
  complete catalog-legal syllables;
- retain first-candidate identity, bounded multiset conservation, explicit
  Path precedence, Delete restoration and fail-closed behavior;
- if the second validation rejects, restore the prior accepted mixed raw once
  and exhaust the attempt budget;
- keep personalization indirect: current RIME ranking may influence the first
  candidate, but there is no userdb query, new learning event or learned-rank
  authority;
- keep Release default off and collect no content-bearing diagnostics.

This authorization does **not** permit implementation, retry after a first
rejection, adaptive backoff, more than one automatic transaction on one key,
candidate-window scans, a second session, threshold weakening, production
personalization, user controls or Release enablement. Implementation requires a
later Product instruction after Architecture and Quality have reviewed the
design Assignment:
[`T9-AUTO-ANCHOR-001-S21`](../assignments/t9-auto-anchor-001-s21-rolling-design.md).

The Product Owner also replaced the physical third-party-keyboard execution
method. Future device performance evidence uses Human typing in a prepared
Reminders field plus content-free App diagnostics and exact artifact binding.
Coordinate-driven XCTest, guessed tap positions and Computer Use typing are not
to be retried for this workflow. Deterministic automation remains in
unit/controller/pinned-RIME layers.

## S2.1 implementation authorization

On `2026-07-29 Asia/Shanghai`, after Architecture and Quality independently
returned `Pass` with P0–P3 all zero for the remediated S2.1 design, the Human
Product Owner explicitly replied “授权”.

This authorizes implementation, tests, Simulator/pinned-RIME evidence,
independent implementation review and internal-artifact preparation exactly
within
[`T9-AUTO-ANCHOR-001-S21`](../assignments/t9-auto-anchor-001-s21-rolling-design.md).
It does not authorize ordinary Release enablement, a user-facing setting,
physical keyboard automation, Product Gate, public performance claims or
skipping the Human `A1→B2` exploratory pair.

The implemented internal-arm identity is source visible and default-off:
`T9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED` may be added only on top of
`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` and
`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED`. It distinguishes `B2` from the
existing `A1`; it does not authorize ordinary Release enablement.

## Product routing after S2.1 three-pair matrix (2026-07-30)

On `2026-07-30 Asia/Shanghai`, after the Human three-pair matrix was recorded in
[`t9-auto-anchor-s21-exploratory-a1b2-2026-07-30.md`](../evidence/t9-auto-anchor-s21-exploratory-a1b2-2026-07-30.md)
and discussed under KOS 2.0, the Human Product Owner confirmed:

### North star (reaffirmed)

The intended long-term experience is:

> Continuous Chinese nine-key input should feel as smooth as practical **without
> requiring** the user to tap Path or change typing habits. Path remains the
> correctness/correction and optional acceleration surface, not a performance
> obligation.

This reaffirms the destination already stated in this Decision and in the plan
Q1 supersession. Idle Path education may continue as optional help; it is not
the primary latency remedy.

### S2.1 product positioning (closed for product goal)

S2.1 (S4 one-anchor + one rolling extension, internal gates only):

- **Mechanism:** useful and contract-valid (stable sessions, exact attempt
  budgets, fail-closed ownership).
- **Performance direction:** weak and non-robust (direction stop rule **1/3**
  PASS across the counterbalanced matrix).
- **Product goal:** **not met** for “no Path, long composition still smooth”.
- **Shipping:** ordinary Release remains gate-off; no Product Gate; no public
  performance claim.
- **Retention:** the default-off implementation and evidence remain valuable as
  a safe automatic-bounding base; they are not deleted solely because the matrix
  failed the product goal.

Force_gc / Lua-as-primary and several T9-only schema knobs remain **closed** as
primary remedies per existing case-close and plan records. Reopening them
requires new contradictory evidence.

### Next knife (authorized)

Product prioritizes the **controller automatic-bounding** lane over a new
RIME/schema primary track for the next increment.

This section authorizes **design only** of child Assignment
[`T9-AUTO-ANCHOR-001-S22`](../assignments/t9-auto-anchor-001-s22-stronger-controller-bounding.md):

- strengthen automatic, reversible bounding of the unresolved T9 tail under the
  same safety family as S4/S2.1 (Path/Partial/Delete ownership, content-free
  diagnostics, default-off internal gates);
- use Human typing plus App content-free performance logs (`T9SEG` / `T9AUTO` /
  `T9ARM`) as the canonical physical evidence method;
- freeze exact attempt budgets, syllable increments, eligibility and rollback
  before any implementation.

This section does **not** authorize:

- implementation, Release enablement, user settings or Product Gate;
- adaptive unbounded loops, candidate-window scans, second sessions or
  background RIME;
- reopening force_gc/Lua as the primary latency track without new evidence;
- treating Path education as the primary performance fix.

Implementation of S2.2 requires a later explicit Product instruction after
Architecture and Quality independently pass the frozen S2.2 design.

## S2.2 implementation authorization

On `2026-07-30 Asia/Shanghai`, after Architecture and Quality independently
returned `Pass` (P0–P3 all zero) for the remediated S2.2 design, the Human
Product Owner explicitly replied “授权 S2.2 实现”.

This authorizes implementation, tests, Simulator/pinned-RIME evidence,
independent implementation review and internal-artifact preparation exactly
within
[`T9-AUTO-ANCHOR-001-S22`](../assignments/t9-auto-anchor-001-s22-stronger-controller-bounding.md)
and ADR 0024 §17–20. It does **not** authorize ordinary Release enablement, a
user-facing setting, Product Gate, public performance claims or skipping the
Human `B2→B3` exploratory pair after automated evidence.

Internal B3 identity is source-visible and default-off:
`T9_AUTO_ANCHOR_TRIPLE_ROLLING_PREFLIGHT_ENABLED` may be added only on top of
the A1 and B2 preflight conditions.

## Product routing after S2.2 B2→B3 exploratory pair (2026-07-30)

On `2026-07-30 Asia/Shanghai`, after S2.2 implementation and the valid Human
exploratory **B2→B3** pair were recorded in
[`t9-auto-anchor-s22-b2b3-2026-07-30.md`](../evidence/t9-auto-anchor-s22-b2b3-2026-07-30.md),
and the Human Product Owner replied “按推荐执行” to the KOS 2.0 routing
recommendation, Product records the following.

### S2.2 product positioning (closed for product goal; retained as base)

S2.2 (S4 first-anchor + S2.1 rolling + one additional rolling extension under
internal B3 gate only):

- **Mechanism:** useful and contract-valid (Layer 1–2 PASS; valid B3 accepts at
  physical events 18/21/24 on the frozen fixture).
- **Performance direction:** exploratory **PASS** on one B2→B3 pair
  (≥100 ms count 4→3; worst 182.0→178.8 not increased). Not a multi-pair
  robust claim; not Product Gate.
- **Product goal:** **not met** for “no Path, long composition still smooth”.
  Residual ≥100 ms spikes remain at **e16** (pre-first-anchor), **e33** and
  **e35**. The extra dose mainly compressed the mid-string **e25-class** spike.
- **Shipping:** ordinary Release remains gate-off; no Product Gate; no public
  performance claim.
- **Retention:** default-off S2.1/S2.2 implementation and evidence remain the
  safe automatic-bounding base. They are not deleted solely because the product
  goal is unmet.

### Stop default attempt-N expansion

Further **attempt 4+** automatic apply attempts are **not** authorized by
default. Opening a fourth attempt requires a new Product amendment with
Architecture/Quality review. S2.2 does not grow by silent dose escalation.

Force_gc / Lua-as-primary and T9-only schema primary tracks remain **closed**
unless new contradictory evidence reopens them under a separate Product
decision. Path education remains optional help, not the primary latency
remedy.

### Next knife (authorized — design only)

Product prioritizes **earlier first-anchor** to attack the residual
**pre-first-anchor e16-class** spike, while retaining the accepted two-syllable
first-anchor product choice and the existing S2.1/S2.2 rolling stack.

This section authorizes **design only** of child Assignment
[`T9-AUTO-ANCHOR-001-S23`](../assignments/t9-auto-anchor-001-s23-earlier-first-anchor.md):

- diagnose why first accept still lands at physical ~18 under the S4 floor
  (`minimumSourceDigitCount = 18`, two closed syllables);
- freeze one primary earlier-first-anchor contract (digit/slot floors, arm
  identity, ordinal mechanism validity, rollback/ownership inheritance);
- define Layer 1–3 acceptance and Human log procedure using existing content-free
  App performance signals;
- keep Path/Partial/Delete ownership, conservation, content-free diagnostics and
  default-off internal gates.

This section does **not** authorize:

- implementation, Release enablement, user settings or Product Gate;
- attempt 4+, rejection-retry loops, candidate-window scans, second sessions or
  background RIME;
- one-syllable first-anchor as the silent default (any one-syllable fork requires
  explicit Product re-authorization after stop-fast evidence);
- reopening force_gc/Lua as the primary latency track without new evidence;
- treating Path education as the primary performance fix.

Implementation of S2.3 requires a later explicit Product instruction after
Architecture and Quality independently pass the frozen S2.3 design.

## S2.3 implementation authorization

On `2026-07-30 Asia/Shanghai`, after Architecture and Quality independently
returned `Pass` (P0–P3 all zero) for the S2.3 earlier-first-anchor design, the
Human Product Owner explicitly replied “授权 S2.3 实现”.

This authorizes implementation, tests, Simulator/pinned-RIME evidence,
independent implementation review and internal-artifact preparation exactly
within
[`T9-AUTO-ANCHOR-001-S23`](../assignments/t9-auto-anchor-001-s23-earlier-first-anchor.md)
and ADR 0024 §21–24. It does **not** authorize ordinary Release enablement, a
user-facing setting, Product Gate, public performance claims, attempt 4+,
one-syllable first-anchor as default, or skipping the Human `B3→B3e`
exploratory pair after automated evidence.

Internal earlier-first identity is source-visible and default-off:
`T9_AUTO_ANCHOR_EARLIER_FIRST_PREFLIGHT_ENABLED` may be added only on top of
the A1 preflight conditions. It is orthogonal to rolling/triple gates.

## Product routing after S2.3 B3→B3e exploratory pair (2026-07-30)

On `2026-07-30 Asia/Shanghai`, after the valid Human exploratory **B3→B3e**
pair was recorded in
[`t9-auto-anchor-s23-b3b3e-2026-07-30.md`](../evidence/t9-auto-anchor-s23-b3b3e-2026-07-30.md),
Product records:

### S2.3 product positioning

- **Mechanism:** useful and contract-valid (B3e first accept @ physical **12**;
  attempts 12/18/24; Layer 1–2 already PASS).
- **Performance direction:** exploratory **FAIL** on the frozen rule
  (≥100 ms count **3→3**; worst improved 188.1→156.7 but count is the hard bar).
- **Product goal:** **not met**. Residual ≥100 ms spikes remain at **e16**,
  **e33**, **e35**. Under B3e, e16 is no longer “pre-first-anchor” (anchor at
  12) but still RIME-dominated. Subjective hitch reduced to roughly one clear
  site, consistent with e16 remaining the outlier.
- **Shipping:** ordinary Release restored gate-off; no Product Gate; no public
  performance claim.
- **Retention:** earlier-first + rolling/triple default-off stack remains a
  valuable automatic-bounding base; not deleted solely because direction FAIL.

### Stop default attempt-N expansion

Attempt **4+** remains **not** authorized by default. Further controller dose
escalation requires a new Product amendment with Architecture/Quality review.

Force_gc / Lua-as-primary remains closed unless new contradictory evidence
reopens it under a separate Product decision.

### Next knife (not auto-authorized)

Controller automatic-bounding has delivered diminishing returns on the frozen
≥100 ms **count** bar (S2.1 weak → S2.2 weak count help → S2.3 magnitude help
without count help). Product should choose one residual route explicitly:

1. **Hold / harvest** — keep default-off S2.1–S2.3 stack; stop further dose
   until a new north-star metric or multi-fixture baseline is defined;
2. **Residual controller** — design a new knife aimed at **post-early-anchor
   mid spikes** (e16-class after accept @12) and/or **late 33/35**, without
   attempt 4 as the silent default;
3. **RIME-side residual** — reopen a carefully scoped engine/schema secondary
   track only with a fresh design Assignment (not force_gc-as-primary).

No implementation of (2) or (3) is authorized by this section alone.

## Product residual route: Hold / harvest (2026-07-30)

On `2026-07-30 Asia/Shanghai`, after the S2.3 B3→B3e exploratory direction
FAIL and the residual-route options were presented, the Human Product Owner
explicitly chose **option 1 — Hold / harvest**.

This records:

1. **Retain** the default-off S2.1–S2.3 automatic-bounding stack (single anchor,
   rolling, triple rolling, earlier-first) as internal capability and evidence
   base. Do **not** delete it solely because the product goal is unmet.
2. **Stop** further controller dose escalation by default. Attempt **4+**, a
   new residual-controller knife, and any RIME-side residual track require a
   **later** explicit Product amendment with Architecture/Quality review.
3. **Ordinary Release** remains gate-off. No user setting, Product Gate, public
   performance claim or shipping enablement is authorized by this choice.
4. **Optional later prep (not authorized now):** redefine north-star measurement
   (e.g. multi-fixture baseline, magnitude-aware scoring) before reopening a
   next knife. That prep is documentation/baseline work only unless Product
   issues a separate Assignment.

This section does **not** authorize implementation of residual routes (2) or
(3), schema/Lua reopen, or Release productization.

## S6-A physical-device preflight authorization

On `2026-07-28 Asia/Shanghai`, after the connected device was identified as a
physical iPhone 13 Pro on iOS 27.0, the Human Product Owner explicitly replied
“授权S6-A 真机预检”.

This section retains the historical S6-A authorization. Its coordinate-driver
execution route was retired by the later `2026-07-29` method decision above;
the child Assignment is now a blocked record and must not be used to restart
physical keyboard automation.

S6-A may:

- add two source-visible, project-default-absent conditions:
  `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` compiles the same minimum content-free
  measurement surface into both arms, while
  `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED` enables the already-validated
  capped-two-syllable gate in B only;
- build Release-like A/B arms from the same source/optimization with the common
  measurement condition; the enabled condition is their only declared
  difference;
- install the internal variants alternately on the named iPhone 13 Pro without
  uninstalling or resetting app, App Group, RIME or userdb state;
- automate only the visible T9 letter-group keys in Reminders using the frozen
  synthetic sequence and retain five valid paired runs;
- reinstall the same-checkpoint ordinary gate-off Release after the final B
  arm and verify the device no longer runs a preflight-enabled binary;
- use only a Human-created disposable Reminders list. Automation may create
  test items inside it but may not delete items or lists; the Human Product
  Owner owns deletion of that exact list after evidence closes.

S6-A does not authorize:

- putting either condition in project/shared-scheme/archive defaults;
- enabling ordinary Release or exposing a user control;
- `DEBUG` behavior wholesale, a second automatic attempt, runtime backoff,
  candidate scanning, threshold changes or any 26-key/schema/vendor mutation;
- candidate/Path selection, userdb reset, production personalization,
  persistence, sync/backup access or content-bearing diagnostics;
- a Product Gate, Release budget or external performance claim.

Runtime evidence identifies the declared synthetic case only by fixture ID,
SHA256, action count and cadence. Literal pinyin/digit identity remains in
repository test source rather than device logs or runtime evidence.

The child Assignment freezes the exact Run Header, comparability, privacy,
cleanup and Stop Conditions:
[`T9-AUTO-ANCHOR-001-S6A`](../assignments/t9-auto-anchor-001-s6a-device-preflight.md).

## S4 preflight authorization: capped two-syllable proposal

On `2026-07-27 Asia/Shanghai`, after the S2 review remediation and durable
Architecture/Quality verdicts at `0173782`, the Human Product Owner explicitly
authorized the recommended S4 preflight experiment.

After the existing S2 policy has produced an otherwise eligible proposal, the
preflight may truncate that proposal's anchored-syllable prefix to its first
two complete, catalog-legal syllables and rebuild the unresolved digit tail. It
must not write `selectedPath`, `confirmedSegmentValues` or otherwise create
user-confirmed Path ownership. It may:

- execute the same single automatic apply attempt per composition;
- retain the existing first-candidate identity and bounded multiset candidate
  conservation validation;
- retain the existing rejection and Delete rollback behavior;
- add deterministic KeyboardCore coverage, rerun the declared 24-case
  real-RIME corpus and isolated S5 personalization matrix, and collect a frozen
  startup-paired Simulator A/B using the existing synthetic sequence;
- produce content-free counts and timing evidence for independent Architecture
  and Quality review.

The authorization does not permit a second automatic attempt, a backoff loop,
candidate-window scan, second production session, threshold reduction,
production personalization, new persistence, 26-key changes, a user-facing
control or Release-default enablement. Physical-device and Release-like
acceptance remain later Product Gate dependencies.

## Isolated Stage 5 personalization-test authorization

On `2026-07-27 Asia/Shanghai`, the Human Product Owner explicitly authorized
an isolated personalization experiment with these limits:

- use only a generated directory under `/private/tmp`;
- create learning only by selecting synthetic RIME candidates a bounded number
  of times;
- prove personalization through an observable candidate-rank delta before and
  after reopening the same isolated user directory;
- retain candidate text only ephemerally in test memory; logs and evidence may
  contain ranks, counts and conservation outcomes only;
- delete the generated user directory after the test closes its RIME session.

The experiment may not access App Group data, the real user dictionary,
standard sync directories, backups, host text, network services or production
Keyboard Extension state. It does not authorize production personalization
logic, retention policy changes or userdb access from the keyboard hot path.

The authorized observation completed on the iOS 27 Simulator. One complete
synthetic candidate selection moved the target from rank 4 to rank 0; rank 0
survived closing and reopening the isolated RIME user directory. The
two-syllable transaction remained accepted with `3/5` bounded overlap before
and after learning, and the generated directory was removed. This is S5
evidence only; the deferred production decisions above remain deferred.

Evidence:
[`../evidence/t9-auto-anchor-personalization-s5-2026-07-27.md`](../evidence/t9-auto-anchor-personalization-s5-2026-07-27.md).

Later on `2026-07-27 Asia/Shanghai`, the Human Product Owner authorized
continuation to the first reviewed S5 matrix. That extension is limited to
three independent complete-learning cases and one partial-selection negative
case. Each case must use its own generated temporary user directory, cap
synthetic selection at 12, finalize every session before deletion, and keep
content out of logs/evidence. The negative case may prove that a partial
selection is not valid learning evidence; it must not be reclassified as a
successful rank-delta case. This still does not authorize production
personalization integration or retention policy.

The first reviewed matrix completed with three independent complete-learning
cases and one partial negative. Every complete target moved from rank 4 to rank
0 and remained there after reopening. Two `3/5` cases stayed accepted, one
`2/5` case stayed rejected, and the partial negative changed rank `2 → 3` but
produced no later two-syllable proposal. Thus learning remains preference
evidence only; it does not override conservation or Path authority.

## Product acceptance for Stage 1

- Existing input behavior is byte-for-byte/state-for-state unchanged by
  observation.
- Missing authority is reported as blocked, never inferred as safe.
- Diagnostics contain no content payload.
- The frozen synthetic sequence produces useful coverage/block-reason evidence
  without extra RIME calls.
- Automated evidence does not substitute for future physical-device Product
  Gate acceptance.
