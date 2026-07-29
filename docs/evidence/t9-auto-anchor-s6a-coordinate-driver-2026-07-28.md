# T9-AUTO-ANCHOR-001-S6A Coordinate Driver Evidence

## Scope

- **Collected:** 2026-07-28 22:43–22:44 Asia/Shanghai
- **Implementation checkpoint:**
  `cff226dc08502d881bb480ec59c990932a21db67`
- **Working tree:** clean before post-checkpoint validation
- **Host:** Xcode `27.0 (27A5228h)`, iOS Simulator SDK `27.0`
- **Simulator:** iPhone 17 Pro Max, iOS `27.0 (24A5390f)`, arm64,
  `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- **Scope limit:** local compile, unit and content-free Simulator evidence
  only. No signed physical build was installed and the valid device matrix
  remains `0 / 5`.

This snapshot supersedes the local-validation claim attached to `8c5aa6d` for
coordinate-driver pre-installation review. Revalidate after any source,
compiler/SDK, simulator runtime, build-condition, evidence-validator or
App Group lifecycle change.

## Evidence Matrix

### Release-like A build

```sh
xcodebuild -quiet -project 'Universe Keyboard.xcodeproj' \
  -scheme UniverseKeyboardUITests -configuration Release \
  -destination 'platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474' \
  -derivedDataPath /private/tmp/universe-keyboard-s6a-qfix-a-final \
  CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES \
  'OTHER_SWIFT_FLAGS=$(inherited) -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT' \
  build-for-testing
```

Result: exit `0`.

### Release-like B build

```sh
xcodebuild -quiet -project 'Universe Keyboard.xcodeproj' \
  -scheme UniverseKeyboardUITests -configuration Release \
  -destination 'platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474' \
  -derivedDataPath /private/tmp/universe-keyboard-s6a-qfix-b-final \
  CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES \
  'OTHER_SWIFT_FLAGS=$(inherited) -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED' \
  build-for-testing
```

Result: exit `0`.

### Content-free UI contracts

Both prepared `.xctestrun` files were executed through XcodeBuildMCP
`test_sim`, restricted to:

- `testFrozenFixtureContract`
- `testContentFreeIntervalStatisticsContract`
- `testContentFreeGeometryContracts`
- `testContentFreeEvidenceValidatorContracts`
- `testContentFreeEvidenceValidatorFailsClosed`

The physical Reminders test was not selected.

| Arm | Result | Build log | Result bundle |
|---|---:|---|---|
| A | `5 / 5` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-28T14-43-53-463Z_pid60177_71b1e09f.log` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-28T14-43-53-463Z_pid60177_2b9657a0.xcresult` |
| B | `5 / 5` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-28T14-44-08-465Z_pid60177_c0004e10.log` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-28T14-44-08-465Z_pid60177_c64ddeb7.xcresult` |

The geometry method exercises one valid geometry plus 23 invalid/parser
cases, including slot count/index, finite values, dimensions, containment,
coordinate space, orientation, scale and topology. Evidence validation
exercises three valid A/B outcomes plus 21 fail-closed cases covering marker,
geometry count/drift/order, segment order/commit/session, summary and A/B
outcome identity/count/status.

### KeyboardCore

```sh
swift test --package-path Packages/KeyboardCore \
  -Xswiftc -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT \
  --filter T9DevicePreflightRunTests
```

Result: `6 / 6`. This includes malformed existing envelope rejection,
retained-log and current-matrix reuse, prepared/consumed lifecycle, matching
cleanup predicate, versioned registry round-trip, duplicate/malformed registry
rejection, leading/trailing/consecutive empty-field rejection, the 64-token
bound, explicit `absent / valid / invalid` storage inspection and fail-closed
cleanup/finalization predicates.

```sh
swift test --package-path Packages/KeyboardCore
```

Result: `751 / 751`. One pre-existing optional-interpolation warning remains at
`T9PinyinPathTests.swift:1429`; it is outside this diff.

### RimeBridge and vendor

```sh
xcodebuild -quiet -project 'Universe Keyboard.xcodeproj' \
  -scheme RimeBridgeTests -configuration Debug \
  -destination 'platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474' \
  -derivedDataPath /private/tmp/universe-keyboard-s6a-qfix-rimebridge \
  CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES test
```

Result: `33` passed, `0` failed, `15` skipped. The skipped tests remain
external-fixture non-coverage.

Result bundle:
`/private/tmp/universe-keyboard-s6a-qfix-rimebridge/Logs/Test/Test-RimeBridgeTests-2026.07.28_22-31-32-+0800.xcresult`.

```sh
bash scripts/ensure_rime_vendor.sh verify
```

Result: structural inventory of all `11` RIME framework artifacts verified.

### Ordinary Debug/Release and compile isolation

Ordinary arm64 Debug and Release builds both exited `0`. Release used:

```sh
xcodebuild -quiet -project 'Universe Keyboard.xcodeproj' \
  -scheme 'Universe Keyboard' -configuration Release \
  -destination 'platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474' \
  -derivedDataPath /private/tmp/universe-keyboard-s6a-qfix-ordinary-final \
  CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES build
```

Search of `.pbxproj`, shared `.xcscheme` and `.xcconfig` files found neither
preflight condition. `strings` scans of the ordinary App and Extension found
none of `T9_S6A`, `T9DEVICE`, `T9GEOM`, `t9_s6a_run_envelope` or
`t9_s6a_matrix_tokens`.

The enabled-only command was intentionally run without the common condition:

```sh
xcodebuild -quiet -project 'Universe Keyboard.xcodeproj' \
  -scheme Keyboard -configuration Release \
  -destination 'platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474' \
  -derivedDataPath /private/tmp/universe-keyboard-s6a-qfix-enabled-only \
  CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES \
  'OTHER_SWIFT_FLAGS=$(inherited) -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED' \
  build
```

Expected result: exit `65` at
`KeyboardViewController+Bootstrap.swift:18`, stating that the enabled
condition requires the common preflight condition.

## Artifact Digests

| Product | SHA256 |
|---|---|
| A App | `cd0f86e18dc09fb402c2d616402c42351e7c3766eea0c447e3d6c5e8b8f95bab` |
| A Extension | `8aaa2c1ec69e022885b970d7c41573a0bac088849601e1e1bddcdad5607383a1` |
| B App | `5fcdbcac3cb9d941dd9b8200a8e812f20582ec8e203bbb6abcc7bde47a7dbf7d` |
| B Extension | `b106fee3693218c853ef25518d55a67453f8d94a1f21ef55d4ec7e089248606f` |
| Ordinary App | `c055b99a8ff7b42abc4b72c75c249eac109fea98a3835a5c2b79ee6c0b8911b8` |
| Ordinary Extension | `1bb50c48f0d6dd9d79ccf4819c91f5daa4d1ddef01941416de7884102eb15e43` |

These are unsigned Simulator identities, not physical-device or release
archive identities.

## Passed

- The two Quality P1 reproduction paths now fail closed.
- The frozen content-free negative matrix is executable in both A and B.
- A/B common instrumentation and B-only gate compile as declared.
- Ordinary Release contains neither preflight code marker nor state-key
  string.
- Core and RIME bridge regressions are green within the stated coverage.

## Failed / Blocked

- No local validation failed at the final checkpoint.
- Physical execution remains blocked pending independent Architecture and
  Quality re-review of this checkpoint and this evidence snapshot.

## Skipped With Reason

- RimeBridge: `15` external-fixture-gated tests; retained as non-coverage.
- Signed physical A/B build, install and the five-pair matrix: deliberately
  not run while independent review is open.
- Product Gate: Human-only and outside this evidence scope.

## Release Decision

Independent Architecture and Quality re-review of
`cff226dc08502d881bb480ec59c990932a21db67` both returned `Pass`, P0–P3 none.
This permits preparation of the next signed A1 arm under the Assignment, but
records no physical-device result and makes no release or Product decision.

## Owner Handoffs

- Architecture and Quality: completed independent pre-installation re-review;
  both Pass, P0–P3 none.
- Human Product Owner: prepare the exact disposable Reminders list before each
  separately announced arm; the prior confirmation cannot be reused.

## Physical A1 Invalid Attempt And Host-Frame Ordering Remediation

`pair1-A-coordinate-run2.xcresult` initialized physical automation and entered
the opt-in test method, then failed before the 38-action fixture with the
content-free driver code `geometry-invalid`. The raw result remains isolated
under `/private/tmp/universe-keyboard-s6a-coordinate-device-evidence/`; no
diagnostic archive, screenshot or UI hierarchy was opened, exported or copied.
The matrix therefore remains `0 / 5`.

The driver had read `reminders.frame` after `loadContentFreeEvidence()` launched
the main App and backgrounded Reminders. That ordering made a background-host
frame participate in the prepared-geometry comparison. The narrow remediation
freezes a finite, positive host frame only while Reminders is confirmed
foreground, before launching the evidence App. It also distinguishes a missing
same-token consumed envelope (`token-consumption-invalid`) from a true geometry
shape/frame mismatch (`geometry-invalid`).

A read-only Device Hub inspection after teardown confirmed the named physical
iPhone remained connected and portrait but was at the Home screen. This
post-test observation is not geometry evidence for the invalid arm. It only
confirms that every subsequent arm still requires a new Human readiness
confirmation. The Device Hub screenshot was not retained because it contained
the user's Home-screen application layout.

### Remediation validation

#### Immutable delta scope

- Implementation checkpoint:
  `ba98ecf73114f95436b37a1181a8386660cd6b5d`
- Parent checkpoint:
  `0a0883369001ef1b8514d9309c14b4f8e9bddb76`
- Pre-run state: `git status --short --branch` reported only
  `## codex/t9-auto-anchor-s5-checkpoint`.
- Delta: one UI-test driver plus this Assignment/evidence only; no production
  source, package source, project build setting, scheme or configuration file.

The first pre-commit A/B `6 / 6` runs are retained as development evidence but
are not used for checkpoint provenance. After Quality reported that P2 gap,
both Release-like Simulator arms were rebuilt and rerun from clean
`ba98ecf`. Each passed the six selected content-free UI contracts, including
the new foreground-host snapshot and prepared-geometry error-separation
contract.

Both runs used scheme `UniverseKeyboardUITests`, configuration `Release`,
iPhone 17 Pro Max iOS 27 Simulator
`06C5BC3E-7599-4761-A1A2-71DAEA991474`, `CODE_SIGNING_ALLOWED=NO`,
`ARCHS=arm64` and `ONLY_ACTIVE_ARCH=YES`. A used:

```text
OTHER_SWIFT_FLAGS=$(inherited) -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT
```

B used:

```text
OTHER_SWIFT_FLAGS=$(inherited) -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT
-DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED
```

Both selected exactly:

- `testFrozenFixtureContract`
- `testContentFreeIntervalStatisticsContract`
- `testContentFreeGeometryContracts`
- `testForegroundHostSnapshotAndPreparedGeometryContracts`
- `testContentFreeEvidenceValidatorContracts`
- `testContentFreeEvidenceValidatorFailsClosed`

| Arm | Result | Result bundle |
|---|---:|---|
| A (`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`) | `6 / 6` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-28T15-13-26-257Z_pid60203_ce55e7ad.xcresult` |
| B (common condition + `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED`) | `6 / 6` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-28T15-14-50-465Z_pid60203_9008559a.xcresult` |

Build logs:

- A:
  `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-28T15-13-26-257Z_pid60203_249daf4f.log`
- B:
  `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-28T15-14-50-465Z_pid60203_d980e247.log`

Both XcodeBuildMCP structured results reported zero failures, skips, warnings
and errors. The bound raw logs each contain three identical
`appintentsmetadataprocessor` warnings:

```text
warning: Metadata extraction skipped, no AppIntents.framework dependency found
```

These six raw-log warnings are retained rather than rewritten as zero. The
message comes from metadata extraction for targets without an AppIntents
dependency; this delta changes only a UI-test source and documentation, and
does not change App Intents source, dependencies or build settings. It does not
invalidate the selected UI contract results, but remains explicit build-log
noise and is not a zero-warning Release claim.

The prior KeyboardCore `751 / 751`, focused storage `6 / 6`, RimeBridge `33`
pass with `15` external-fixture skips, vendor verification and ordinary Release
negative scan are carried forward from the already reviewed pre-installation
baseline: this delta changes none of their source or build inputs. They are not
misrepresented as newly rerun evidence.

This validation proves the deterministic driver contracts and compilation
symmetry only; a new signed physical A1 build plus fresh Human readiness
confirmation remain mandatory before another physical attempt.
