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

## Signed A1 Re-preparation After Final Review

Final independent Architecture and Quality reviews of implementation
`ba98ecf`, evidence binding `fb59735` and warning correction `939b0ed` both
returned `Pass`, P0–P3 none. The following signed A build was then prepared
without installing or launching it:

- source HEAD:
  `939b0ed0e9772449c9194631b5c846b458b34fc7`
- implementation checkpoint:
  `ba98ecf73114f95436b37a1181a8386660cd6b5d`
- configuration: `Release`
- condition:
  `-DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT`
- Xcode: `27.0 (27A5228h)`
- iPhoneOS SDK: `27.0 (24A5390e)`
- App bundle/version/build:
  `com.DoubleShy0N.Universe-Keyboard`, `1.0`, `1`
- Extension bundle:
  `com.DoubleShy0N.Universe-Keyboard.Keyboard`
- Team ID: `C33N6HTS9N`
- App executable SHA256:
  `f469fecf570d9dcc996f31ea66649ba6955d43e769085cc2c54dbc3b48d1c242`
- Extension executable SHA256:
  `392cb0f90f0f5b3e44f2fea1fae23307a8983f0de04e826df03832f873c9f552`
- UI-test executable SHA256:
  `f4def5247f85f40f697e07b1fe1e47044a78b355b4dd81ac18e955684e4af33d`
- App Mach-O UUID:
  `6A1C136F-C36B-31C9-93AA-754EE0C21346`
- Extension Mach-O UUID:
  `75502BBA-199A-3927-A9B8-3A3756026F96`

The Extension string inventory contains `T9DEVICE_DISABLED` and the common
preflight envelope/registry keys; it does not contain `T9DEVICE_ENABLED`.
`codesign -dv` reports the expected App/Extension bundle identifiers, arm64 and
Team ID. Host `codesign --verify --deep --strict` returns the existing beta
host trust result `CSSMERR_TP_NOT_TRUSTED`; this is retained as a host trust
warning and is not described as strict verification success.

Xcode 27 did not emit a `.xctestrun` beside this otherwise successful
`build-for-testing` product. The executor instantiated the same reviewed
FormatVersion 1 relative-path specification used by the prior physical arm,
pointing only through `__TESTROOT__` to this build's App, runner and test
bundle. `plutil -lint` passed. Its SHA256 is
`40d6c9417b18726b7e42559648f02e65bd801fdeea849d8f16afe40e502f9a5d`,
and its test-runner environment binds exactly:

- `T9_S6A_DEVICE_PREFLIGHT_RUN=1`
- `T9_S6A_DISPOSABLE_LIST=Universe Keyboard S6A 20260728`
- `T9_S6A_EXPECTED_MARKER=T9DEVICE_DISABLED`

The read-only device query still matched iPhone 13 Pro (`iPhone14,2`),
iOS `27.0 (24A5390f)`, arm64e and UDID
`00008110-000A08440198801E`, with Developer Mode enabled. It also reported
`localNetwork` transport and `passcodeRequired=true`. These violate the frozen
wired/unlocked preconditions, so no install or launch occurred. The signed A1
remains held at
`/private/tmp/universe-keyboard-s6a-coordinate-device-a-ba98ecf-939b0ed/`
pending a new Human confirmation after USB connection, unlock, exact-list
overview preparation and most-recent Universe Chinese nine-key selection.

## Physical A1 Coordinate Run 3

After fresh Human readiness, the device precheck reported `wired`,
`passcodeRequired=false`, the frozen iPhone/OS identity and the exact empty
list overview in portrait. The signed A1 was installed by replacement without
uninstall/reset, container deletion or userdb mutation.

`pair1-A-coordinate-run3.xcresult` entered the selected physical test method,
prepared a new token, opened the exact list and created one empty item. It
failed closed with `geometry-unavailable` before the coordinate fixture began.
The content-free summary reports one failed selected test on the frozen iPhone
13 Pro / iOS 27 identity. No arm is counted and the matrix remains `0 / 5`.
The raw result is isolated at
`/private/tmp/universe-keyboard-s6a-coordinate-device-evidence/`; no diagnostic
archive, screenshot or UI hierarchy attachment was opened, exported or copied.

Computer Use observed only the expected foreground transitions and did not
drive the device. The internal content-free evidence view was then launched
explicitly. It showed the current envelope remained `prepared` rather than
`consumed`; no token value is retained in repository evidence. That state
proves the Extension did not execute the new-token consumption path. Code
review found consumption only in `bootstrapKeyboard()`, while iOS may reuse the
already-selected Extension instance when returning from the main App.

The remediation adds a preflight-only visibility-boundary check for a fresh
token different from the instance's retained token, resets only per-arm
geometry flags, consumes before logging the marker and leaves normal Release
plus the input hot path unchanged.

### Reused-Extension remediation validation

Quality rejected the pre-commit results as insufficient provenance. The
following replacement results were therefore generated from clean immutable
source commit `202f08ca3726e54e41b208c3d334c1383ea3a61f`, whose parent is
`6603ccea6edaa5da295e87b4746188c0c6a4bdaf`. Immediately before validation,
`git status --porcelain=v1` returned no output and `git rev-parse HEAD`
returned the implementation commit above. Only this evidence/Assignment
follow-up changes after those runs.

Focused command:

```sh
swift test --package-path Packages/KeyboardCore \
  -Xswiftc -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT \
  --filter T9DevicePreflightRunTests
```

Result: `7 / 7`, including fresh-token acceptance plus same-token and
consumed-envelope rejection. Log:
`/private/tmp/universe-keyboard-202f08c-focused-device-preflight.log`,
SHA256 `dce0b66683f03d485776ece8c05b4942a56b5cc254886f008dc2d2ad0c0b5d56`.

Ordinary KeyboardCore command:

```sh
swift test --package-path Packages/KeyboardCore
```

Result: `751 / 751`. The existing optional interpolation warning at
`T9PinyinPathTests.swift:1429` remains outside this delta. Log:
`/private/tmp/universe-keyboard-202f08c-keyboardcore-full.log`, SHA256
`79f5f78d65321ab4c94ebcbeebc9eaf7aba9869e8a340f1a2dd2afba8e34e5d0`.

Release-like A and B were executed by XcodeBuildMCP `test_sim` with project
`Universe Keyboard.xcodeproj`, scheme `UniverseKeyboardUITests`,
configuration `Release`, iPhone 17 Pro Max iOS 27 Simulator
`06C5BC3E-7599-4761-A1A2-71DAEA991474`, `CODE_SIGNING_ALLOWED=NO`,
`ARCHS=arm64`, `ONLY_ACTIVE_ARCH=YES` and separate DerivedData:

- A: `/private/tmp/universe-keyboard-202f08c-ui-a`, with
  `OTHER_SWIFT_FLAGS=$(inherited) -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT`;
- B: `/private/tmp/universe-keyboard-202f08c-ui-b`, with the same flag plus
  `-DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED`.

Both selected exactly:

```text
-only-testing:UniverseKeyboardUITests/T9DevicePreflightUITests/testFrozenFixtureContract
-only-testing:UniverseKeyboardUITests/T9DevicePreflightUITests/testContentFreeIntervalStatisticsContract
-only-testing:UniverseKeyboardUITests/T9DevicePreflightUITests/testContentFreeGeometryContracts
-only-testing:UniverseKeyboardUITests/T9DevicePreflightUITests/testForegroundHostSnapshotAndPreparedGeometryContracts
-only-testing:UniverseKeyboardUITests/T9DevicePreflightUITests/testContentFreeEvidenceValidatorContracts
-only-testing:UniverseKeyboardUITests/T9DevicePreflightUITests/testContentFreeEvidenceValidatorFailsClosed
```

Neither selected the physical Reminders method.

| Arm | Result | Build/test log | Result bundle |
|---|---:|---|---|
| A | `6 / 6` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-29T11-37-46-470Z_pid23283_ce02f070.log` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-29T11-37-46-471Z_pid23283_2aa03f9b.xcresult` |
| B | `6 / 6` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-29T11-40-37-650Z_pid23283_a8e260ab.log` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-29T11-40-37-650Z_pid23283_5980bff0.xcresult` |

The A and B log SHA256 values are respectively
`6757c4ad955dd374e1c873fbe63eadee038d7578b5c694d6181d419f4a42eeda`
and
`224eccf9414ec4434cba69709d10e29b7d3c2a3a4b1b529030c3ed3c0b777277`.
XcodeBuildMCP reported zero failures, skips, warnings and errors for each arm.

The ordinary Release Simulator build used scheme `Universe Keyboard`, the
same simulator and architecture settings, no preflight Swift flag, and
DerivedData
`/private/tmp/universe-keyboard-202f08c-ordinary-release`. It passed with log:
`~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-07-29T11-43-09-690Z_pid23283_fcfc6622.log`,
SHA256 `9870c93f358fc2d541f4a86c15e846cb1bc181871f53a297765ba6e3164186de`.

The scanned ordinary Extension binary is:

```text
/private/tmp/universe-keyboard-202f08c-ordinary-release/Build/Products/Release-iphonesimulator/Universe Keyboard.app/PlugIns/Keyboard.appex/Keyboard
```

Its SHA256 is
`df9ecc372fc409f9e1c2d51b6696da261283e9882e6b7a05db288bde629df5aa`.
The exact inventory command was:

```sh
strings -a \
  '/private/tmp/universe-keyboard-202f08c-ordinary-release/Build/Products/Release-iphonesimulator/Universe Keyboard.app/PlugIns/Keyboard.appex/Keyboard' |
  rg -n 'T9DEVICE|T9_S6A|t9_s6a_run_envelope|t9_s6a_matrix_tokens'
```

It returned no matches (`rg` exit `1`), confirming ordinary Release contains
none of those preflight strings.

No physical retry is authorized by these local results. An immutable
checkpoint and independent Architecture/Quality re-review remain mandatory.
