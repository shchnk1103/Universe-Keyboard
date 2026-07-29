# T9-AUTO-ANCHOR-001-S21 implementation evidence — 2026-07-29

## Scope and authority

- Assignment:
  [`T9-AUTO-ANCHOR-001-S21`](../assignments/t9-auto-anchor-001-s21-rolling-design.md)
- Product authorization:
  [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)
- Architecture boundary:
  [`ADR 0024`](../architecture/decisions/0024-t9-auto-anchor-shadow-observation-boundary.md)
- Design base: `c42cec2db3296e28a7cbcbd42471a4c7b005ea5e`
- Review target: the immutable local commit containing this evidence. The
  independent review handoff records its exact SHA rather than attempting to
  self-reference a commit from inside that commit.

This is automated implementation evidence. It is not physical-device
performance evidence, Product Gate, Release enablement or a public performance
claim.

## Implemented boundary

- The process-local ledger now retains exact mixed raw, complete digit
  authority, cumulative syllable/slot counts, attempt count and previous
  attempt source length.
- Accepted mixed identity is checked before a later digit reaches RIME. A
  mismatch, missing live session or unusable non-committing result performs one
  same-session fail-closed reset without recovery or replay.
- A successful later digit advances original digits and exact returned mixed
  raw in one state publication before rolling eligibility is evaluated.
- The second proposal preserves the accepted prefix byte-for-byte and appends
  exactly two catalog-legal complete syllables. No candidate-window query,
  later-page scan, adaptive backoff or second session was added.
- Attempt 2 is consumed before its single apply call. Rejection restores the
  prior accepted mixed raw once; restore failure abandons the composition.
- Pure digits remain Delete authority. Explicit Path and Partial Commit retain
  user ownership and clear automatic payload.
- `isRollingT9AutoAnchorEnabled` and
  `T9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED` are separate default-off B2 gates.
  Existing A1 and ordinary Release remain distinct.
- Diagnostics contain attempt/count/timing fields only; they do not retain raw
  input, pinyin, candidate text, committed text, host context or userdb data.

## Deterministic KeyboardCore evidence

Focused suite:

```text
swift test --package-path Packages/KeyboardCore \
  --filter T9ReversibleAutoAnchorTests
```

Result after the final focused additions:

```text
Executed 26 tests, with 0 failures, 0 unexpected
```

The cases cover A0/A1/B2 gate separation, atomic digit advancement, prefix
rewrite rejection, exactly-two-syllable extension, one transaction per key,
two accepted attempts, no third attempt, first-rejection terminal behavior,
second rejection/prior-mixed restore, restore failure, pre-key mismatch,
missing session, unusable output, Delete after one/two accepts, explicit Path,
Partial Commit and duplicate-candidate conservation.

Full suite:

```text
swift test --package-path Packages/KeyboardCore
```

Result:

```text
Executed 761 tests, with 0 failures, 0 unexpected
```

One pre-existing test-source warning about optional interpolation was emitted
by the macOS SwiftPM test build. It is outside the S2.1 files; all strict iOS
builds below completed with zero warnings.

## Pinned real-RIME integration

Environment:

- iOS 27.0 iPhone 17 Pro Max Simulator
  `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- scheme `RimeBridgeTests`, configuration `Debug`
- patched isolated T9 shared fixture under `/private/tmp`
- a new isolated child user directory per arm/test; no production or App Group
  userdb was queried or modified
- strict Swift/Clang warnings-as-errors

The final explicit S2.1 selection ran three tests with no skip:

```text
passed=3 failed=0 skipped=0
```

Positive 38-action arm record:

```text
T9_S21_A0_A1_B2
arm=a0 actions=38 sessions=1 replace=0 outcomes=none
arm=a1 actions=38 sessions=1 replace=1 outcomes=action18/attempt1
arm=b2 actions=38 sessions=1 replace=2
  outcomes=action18/attempt1|action20/attempt2
```

The assertions also require zero commit, candidate availability on every
action, one stable valid native session, no automatic Path ownership, exact
accepted-outcome counts and B2 attempt 2 strictly after attempt 1 and no later
than action 23.

Two additional real-session tests passed:

- Delete after two accepts restores the complete digit authority before normal
  Delete; explicit Path supersedes automatic state; a real partial selection
  leaves the data-free rejected tombstone.
- Forced second-apply candidate drift produces exactly three auto-anchor
  replacement calls and restores prior mixed raw with attempt budget
  exhausted. Forced prior-mixed restore failure produces exactly one reset,
  zero recovery and no retained automatic payload.

The four existing isolated-personalization cases were then rerun with zero
failure and zero skip. Their generated user roots were private temporary
children and retained the mandatory cleanup assertions. The known-positive
case moved one synthetic complete candidate from rank 4 to rank 0, preserved
the existing conservation decision after engine restart, and the B2 controller
then recorded exactly two accepted rolling outcomes. It performed no candidate
selection and acquired no Path ownership. The natural positive/negative and
partial-selection negative retained their frozen decisions, demonstrating
that learned rank remains bounded preference evidence rather than an authority
override.

## Strict builds and vendor

All builds used scheme `Universe Keyboard`, iOS 27.0 Simulator, warnings as
errors and separate DerivedData:

| Configuration | Gate identity | Result |
|---|---|---|
| Debug | existing Debug/A1 behavior; rolling off | Succeeded, 0 warnings |
| Release | ordinary gate-off Release | Succeeded, 0 warnings |
| Release | A1 conditions plus `T9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED` | Succeeded, 0 warnings |

Vendor verification:

```text
bash scripts/ensure_rime_vendor.sh verify
Verified structural inventory of 11 RIME framework artifacts
```

## Remaining gates

- Independent Architecture implementation review: pending.
- Independent Quality implementation review: pending.
- Human physical-device `A1→B2` exploratory pair: not started.
- Ordinary Release remains gate-off.
- No `CHANGELOG.md` entry is required before Product accepts a user-visible or
  shipping behavior change; this checkpoint is an internal experiment.
