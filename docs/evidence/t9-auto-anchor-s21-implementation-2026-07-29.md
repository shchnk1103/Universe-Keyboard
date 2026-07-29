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

Result after the independent-review remediation:

```text
Executed 34 tests, with 0 failures, 0 unexpected
```

The cases cover A0/A1/B2 gate separation, atomic digit advancement, prefix
rewrite rejection, exactly-two-syllable extension, one transaction per key,
two accepted attempts, no third attempt, first-rejection terminal behavior,
second rejection/prior-mixed restore, restore failure, pre-key mismatch,
missing live composition with the generic restore flag false in all three
accepted-ledger phases, unusable and committing later output, Delete restore
success/failure after one/two accepts and after second rejection, exact
replacement budgets, explicit Path, Partial Commit and duplicate-candidate
conservation.

Full suite:

```text
swift test --package-path Packages/KeyboardCore
```

Result:

```text
Executed 769 tests, with 0 failures, 0 unexpected
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

The independent-review remediation selection ran these four exact tests:

```text
RimeBridgeTests/RimeT9AutoAnchorRetryMatrixTests/
  testRollingControllerFrozenA0A1B2Matrix
RimeBridgeTests/RimeT9AutoAnchorRetryMatrixTests/
  testRollingControllerRealRimeDeletePathAndPartialOwnership
RimeBridgeTests/RimeT9AutoAnchorRetryMatrixTests/
  testRollingControllerRealRimeSecondRejectRestoreMatrix
RimeBridgeTests/RimeT9AutoAnchorRetryMatrixTests/
  testRollingControllerMissingLiveCompositionFailsClosedBeforeKey
```

The XcodeBuildMCP test invocation resolved to the following
`test-without-building` command (line wrapping only):

```text
/Applications/Xcode-beta.app/Contents/Developer/usr/bin/xcodebuild
  -testProductsPath /Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/test-products/test_sim_2026-07-29T14-50-15-939Z_pid23283_ac8cfea3.xctestproducts
  -destination "platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474"
  -collect-test-diagnostics never
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
  GCC_TREAT_WARNINGS_AS_ERRORS=YES
  -only-testing:<each of the four identifiers above>
  -resultBundlePath /private/tmp/universe-keyboard-s21-rimebridge-remediation.xcresult
  test-without-building
```

The preceding `build-for-testing` used project
`Universe Keyboard.xcodeproj`, scheme `RimeBridgeTests`, configuration
`Debug`, DerivedData
`/private/tmp/universe-keyboard-s21-rimebridge-remediation`, the same four
`only-testing` selectors, and the same strict warning settings. XcodeBuildMCP
bound these exact test-runner values:

```text
UK_RIME_T9_SPIKE_SHARED_DIR=/private/tmp/universe-keyboard-s3-retry-matrix.0E3dQi/shared
UK_RIME_T9_SPIKE_USER_DIR=/private/tmp/universe-keyboard-s3-retry-matrix.0E3dQi/user
```

Result:

```text
passed=4 failed=0 skipped=0
```

The new native regression clears the live composition while retaining the
controller's cached accepted mixed raw and keeping
`shouldRestoreRimeComposition=false`. It proves zero `processKey`, zero
`replaceInput`, zero recovery, exactly one same-session reset, unchanged valid
native session identity and a data-free rejected tombstone.

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

The exact common command shape was:

```text
/Applications/Xcode-beta.app/Contents/Developer/usr/bin/xcodebuild
  -project "/Users/doubleshy0n/Dev/Universe Keyboard/Universe Keyboard.xcodeproj"
  -scheme "Universe Keyboard"
  -configuration <Debug|Release>
  -skipMacroValidation
  -destination "platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474"
  -collect-test-diagnostics never
  -derivedDataPath <path below>
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
  GCC_TREAT_WARNINGS_AS_ERRORS=YES
  <B2 flags below when applicable>
  build
```

| Artifact | DerivedData | Additional flags | Log SHA-256 |
|---|---|---|---|
| Debug ordinary | `/private/tmp/universe-keyboard-s21-remediation-build-debug` | none | `b836bc1175afa3e31a75d43641b2da40b1741a6c74aaa9dcfb396b5b8192d559` |
| Release ordinary | `/private/tmp/universe-keyboard-s21-remediation-build-release` | none | `043880d979658796f270d1bb1a9bb5fc7a305f11abb425216cdb55d03face13e` |
| Release B2 | `/private/tmp/universe-keyboard-s21-remediation-build-b2` | `OTHER_SWIFT_FLAGS=$(inherited) -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED -DT9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED` | `26b44d0cd3a3c4f49386a2a4fc11c615470b842734bf05d10e6706b802b9ebac` |

The four-test integration log SHA-256 is
`62a6bef6573d6bab76d94a124ed6a222798d81cbfdfce08e4aaf87ec5d0543b5`;
the result bundle is
`/private/tmp/universe-keyboard-s21-rimebridge-remediation.xcresult`.
The log records both resolved Xcode commands, every test identifier, the
frozen A0/A1/B2 action record and `Executed 4 tests, with 0 failures`.

## Independent-review remediation

The first immutable implementation review of `ed28923` returned:

- Architecture: P0=0, P1=1, P2=0, P3=0;
- Quality: P0=0, P1=1, P2=2, P3=0.

The shared P1 was a real native-boundary hole: accepted cached raw could match
while live composition was absent and the generic restore flag was false.
Because the ObjC bridge may create a session from `processKey`, the digit had
to be rejected before crossing RIME. The remediation independently checks live
composition health, performs one same-session fail-closed reset and adds the
real-RIME session-identity regression above.

Quality's first P2 exposed two evidence gaps and one behavior defect. The
Layer-1 matrix is now explicit for all accepted-ledger phases, commit/unusable,
Delete restore failure and exact attempt-2 rollback budgets. Its new red test
showed that recursive Delete issued a fifth replacement after a rejected and
restored second attempt; Delete now consumes the already-restored pure-digit
session directly, making the cumulative total exactly four. A committed later
digit no longer re-enters retained Path resynchronization. Exact integration
and strict-build commands, selectors, DerivedData, result bundle, logs and
digests are recorded above.

Independent re-review of the remediation commit remains required before Human
physical-device work.

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
