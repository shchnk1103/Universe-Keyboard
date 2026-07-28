# Product Decision: T9-AUTO-ANCHOR-001 Authorization

**Decision ID:** `PD-T9-AUTO-ANCHOR-001`
**Lifecycle status:** `Recorded — S4 validated; S6-A physical-device Release-like preflight authorized`
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

## S6-A physical-device preflight authorization

On `2026-07-28 Asia/Shanghai`, after the connected device was identified as a
physical iPhone 13 Pro on iOS 27.0, the Human Product Owner explicitly replied
“授权S6-A 真机预检”.

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
