# T9 auto-anchor S5 isolated personalization evidence

**Date:** 2026-07-27 Asia/Shanghai
**Environment:** iPhone 17 Pro Max Simulator, iOS 27.0, Debug
**Scope:** Test-target-only RIME learning in a generated temporary user directory

## Boundary

- The test creates one UUID-named child directory inside the authorized
  `/private/tmp` fixture user root.
- Learning is produced only by bounded synthetic candidate selection.
- Candidate text remains in test memory and is absent from logs and this
  evidence.
- The test does not access App Group data, the real user dictionary, standard
  sync data, backups, host text, network services or the production
  `KeyboardController`.
- Both RIME sessions are finalized before the exact generated directory is
  removed.

## Calibration observations

Two rejected test designs established why a ranking assertion must distinguish
full commit from partial candidate selection:

- A rank-1 target did not move after 12 selections.
- A rank-2, length-3 partial target required a continuation selection, moved to
  rank 3 rather than forward, and removed the later two-syllable proposal.

Both runs used fresh generated directories and cleaned them. They were not
accepted as personalization proof. The final matrix learns a complete short
candidate first, then evaluates the long-composition two-syllable transaction
in the same isolated user directory.

## Accepted result

Content-free machine summary:

```text
T9_AUTO_ANCHOR_PERSONALIZATION case=knownPositive selections=1 baselineRank=4 learnedRank=0 reopenedRank=0 targetLength=2 completionSelections=0 baselineTwoAccepted=true baselineTwoOverlap=3 personalizedTwoAccepted=true personalizedTwoOverlap=3 cleanup=deferred
```

Interpretation:

- one complete synthetic selection promoted the target from rank 4 to rank 0;
- rank 0 survived engine finalization and reopening with the same isolated
  user directory;
- the long-composition two-syllable proposal remained accepted with three
  overlapping bounded candidates before and after learning;
- no generated `personalization-*` directory remained after the test.

The proof is the observable and restart-stable rank delta, not userdb file
existence.

## First reviewed matrix

The Product-authorized extension ran every case in a separate generated user
directory:

| Case | Selection shape | Restart-stable rank | Two-syllable before → after |
|---|---|---|---|
| `knownPositive` | one complete selection | `4 → 0 → 0` | accepted `3/5 → 3/5` |
| `naturalWeather` | one complete selection | `4 → 0 → 0` | accepted `3/5 → 3/5` |
| `naturalReminder` | one complete selection | `4 → 0 → 0` | rejected `2/5 → 2/5` |
| `partialNegative` | one partial plus one continuation | `2 → 3` | accepted `3/5 → no proposal` |

The complete-learning helper requires zero continuation selections, so a
partial candidate cannot silently enter the positive corpus. The matrix shows
that restart-stable ranking is preference evidence only: it neither overrides
the `3/5` conservation threshold nor turns an existing `2/5` rejection into an
acceptance. The partial negative is fail-closed before transaction validation.

## Validation

- RIME vendor structural inventory: `11 / 11` artifacts verified.
- Strict `build-for-testing`: passed, zero warnings and zero errors.
- Fixture-enabled class:
  `RimeT9AutoAnchorRetryMatrixTests` passed `6 / 6`, including the temporary
  root policy test.
- Default RimeBridge suite without fixture environment:
  `32` passed, `0` failed, `14` fixture-gated skips.
- An intentional run with the user root set outside `/private/tmp` failed
  before directory creation with
  `userRootOutsidePrivateTemporaryDirectory`; no generated directory appeared
  under either the rejected root or the authorized fixture root.
- Default suite emitted the existing pre-initialization logging warning; it
  produced no compiler warning or test failure.
- Fixture deployment emitted librime's
  `Error opening db 'essay' read-only.` diagnostic. It did not change any
  frozen rank/conservation result; it remains a recorded fixture/runtime
  limitation for RimeBridge review.

## Decision boundary

This evidence shows that existing isolated RIME learning can reorder candidates
while the current two-syllable conservation rule continues to accept or reject
independently. It also freezes partial selection as invalid learning authority.
It does not establish representative language quality, authorize production
personalization queries, define retention/deletion behavior, change the
one-attempt runtime budget or approve Release-default enablement.

## Independent remediation re-review

Architecture and Quality independently returned **Pass with findings** for the
local snapshot whose test file SHA-256 is
`ea75a2d8ff0e57ae42009f76727cebf8bd3d4fa2a4f7b3fff36d4804727d241f`
at repository `HEAD` `2ec7421dd29211906a577a272e0895f72a6ae128`.

Quality independently reproduced the vendor check, strict build, `6 / 6`
fixture class, `32` default passes with `14` fixture-gated skips, fail-closed
invalid-root path and cleanup checks. Architecture independently confirmed
that test-only deployment/session reopening does not change production
ownership and that learned rank remains preference evidence rather than
proposal or conservation authority.

At that time the snapshot was dirty and uncommitted, so its shared P1 finding
remained open until the checkpoint below. Those initial conclusions did not
advance the whole Assignment to `Reviewed`, accept ADR 0024, authorize
production personalization, or satisfy Product Gate.

## Immutable checkpoint

Commit `9c4f86f8ac8189a34bffe3793986dc45cd7ca77d` freezes the
reviewed S5 test SHA, this evidence and the linked S2/S3 evidence. Independent
Architecture and Quality checkpoint revalidation both returned **Pass with
findings** and closed the missing-checkpoint P1 for the S5 component.

Post-checkpoint results were:

- strict fixture class: `6 / 6`;
- default RimeBridge suite: `32` passed and `14` fixture-gated skips;
- standard KeyboardCore suite: `742 / 742`;
- RIME vendor inventory: `11 / 11`.

This makes the S5 component durably Architecture/Quality reviewed at
`9c4f86f`. The whole Assignment remains `Active`; ADR 0024 remains `Proposed`;
production personalization, Release enablement and Product Gate remain
unauthorized.
