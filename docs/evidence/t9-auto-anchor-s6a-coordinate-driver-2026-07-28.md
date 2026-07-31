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
XcodeBuildMCP structured results reported zero failures, skips, runtime
warnings and errors for each arm. The raw build/test logs each retain three
identical non-blocking `AppIntents` metadata-extraction-skipped warnings; this
evidence does not claim a zero-warning Release build.

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

## Signed A1 After Reused-Extension Remediation

Independent Architecture and Quality reviews of combined checkpoint
`188ccd0d4bcfe256366b4e555cec22bc05b4df02` both returned `Pass`, with
P0–P3 none. The reused-Extension implementation is immutable at
`202f08ca3726e54e41b208c3d334c1383ea3a61f`.

A fresh signed A was prepared without installation, launch or device-state
mutation:

```sh
xcodebuild -quiet -project 'Universe Keyboard.xcodeproj' \
  -scheme UniverseKeyboardUITests -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath \
  /private/tmp/universe-keyboard-s6a-coordinate-device-a-188ccd0 \
  -allowProvisioningUpdates \
  'OTHER_SWIFT_FLAGS=$(inherited) -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT' \
  build-for-testing
```

The terminal incremental invocation returned exit `0`. Its `-quiet` log is
`/private/tmp/universe-keyboard-s6a-coordinate-device-a-188ccd0-final.log`,
an empty successful log with SHA256
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
An earlier verbose capture ended without an xcodebuild terminal status and is
explicitly excluded from success evidence.

Build identity:

- configuration: `Release`;
- condition: `-DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT`;
- Xcode: `27.0 (27A5228h)`;
- iPhoneOS SDK: `27.0 (24A5390e)`;
- App bundle/version/build:
  `com.DoubleShy0N.Universe-Keyboard`, `1.0`, `1`;
- Extension bundle:
  `com.DoubleShy0N.Universe-Keyboard.Keyboard`;
- Team ID: `C33N6HTS9N`;
- App executable SHA256:
  `c098b6dd142099c4831ff0c597798510b3cf7e05e0a3d3db0e7609d6d2e58ffe`;
- Extension executable SHA256:
  `7d4991e087277ebd1e58dc271af3cae8efd81dbb141316793dba6d49c812d37d`;
- UI-test executable SHA256:
  `1718a0e332e8ff63ba2e574c4bbce867d97d2d80bceae978eb9b33574103abbf`;
- App Mach-O UUID:
  `0C684716-E7F8-36C4-83F6-76292746643C`;
- Extension Mach-O UUID:
  `07C24A5D-29E5-31AC-9265-B074CF354BE9`.

The Extension string inventory contains `T9DEVICE_DISABLED` and the common
`t9_s6a_run_envelope` / `t9_s6a_matrix_tokens` keys; it does not contain
`T9DEVICE_ENABLED`. `codesign -dv` reports the expected App, Extension and
runner identifiers, arm64 products and Team ID. Host
`codesign --verify --deep --strict` returns the existing beta-host trust result
`CSSMERR_TP_NOT_TRUSTED`; this remains an explicit trust warning and is not
described as strict verification success.

This Xcode 27 build emitted a FormatVersion 1 relative-path `.xctestrun`.
After the build completed, the executor added only the three Assignment-bound
test-runner values:

- `T9_S6A_DEVICE_PREFLIGHT_RUN=1`;
- `T9_S6A_DISPOSABLE_LIST=Universe Keyboard S6A 20260728`;
- `T9_S6A_EXPECTED_MARKER=T9DEVICE_DISABLED`.

`plutil -lint` passed and all three values were read back exactly. The final
file is:

```text
/private/tmp/universe-keyboard-s6a-coordinate-device-a-188ccd0/Build/Products/UniverseKeyboardUITests_iphoneos27.0-arm64.xctestrun
```

Its SHA256 is
`f55e5e8b3fa42a0a429a196a6c5a1d34a2dddbb614058d71615f25031338f3cc`.
Its dependent products remain relative to `__TESTROOT__` and point to this
build's standalone Extension, App, runner and UI-test bundle.

The signed A remains held locally. It must receive independent narrow review,
then a fresh read-only device precheck and a new Human confirmation of the
exact list overview, unlocked state and most-recent Universe Chinese nine-key
selection before any install or physical retry. The matrix remains `0 / 5`.

## Physical A1 Coordinate Run 4

After fresh Human readiness, the read-only precheck matched the frozen iPhone
13 Pro / iOS 27 identity, wired transport, unlocked state, Developer Mode and
the empty disposable-list overview in portrait. Computer Use observed without
clicking. The `30d0831`-bound signed A was installed by replacement without
uninstall, container deletion or userdb mutation.

`pair1-A-coordinate-run4.xcresult` entered only the frozen physical method,
created one empty item and failed closed with `geometry-invalid` before
`driveFrozenFixture`. No coordinate fixture action occurred, the source pinyin
`jintiandetianqihenbucuowomenchuquwanba` was not entered, no arm is counted and
the matrix remains `0 / 5`. The raw result remains isolated at
`/private/tmp/universe-keyboard-s6a-coordinate-device-evidence/`; its
diagnostics, screenshots and UI hierarchy were not opened, exported or copied.

Unlike run3, the fresh token was consumed and one same-token prepared geometry
record was present. The content-free evidence surface showed:

- portrait screen: `390 x 844` points at scale `3`;
- eight non-empty T9 button frames in the lower screen, approximately
  `y = 600 ... 743`;
- recorded `keyboard` frame: the full `390 x 844` screen with `minY = 0`.

The validator correctly rejected that root-view frame because a keyboard
interaction region must be in the lower half of the portrait screen. Source
review found that the producer used
`coordinateSpace.convert(view.bounds, from: view)`. On this physical
`UIInputViewController`, the root view spans the host screen even though the
actual T9 button hit targets are correctly positioned at the bottom.

The public Hamster repository exposes package-level T9 and keyboard-appearance
tests but no cross-host XCUI keyboard test target. The public fcitx5-ios tree
likewise exposes no XCTest/UI-test suite. Apple documents host-app invocation
of a custom keyboard and explicitly warns that hiding a keyboard does not
necessarily terminate its Extension process. Appium's iOS driver is also
XCTest-backed; substituting it would not correct an invalid geometry source.

The narrow remediation keeps all existing portrait, screen, digest, size,
containment, non-overlap and topology checks. It changes only the producer's
`keyboard` field to the union of the eight measured T9 hit-target frames.
Those frames are the driver's only coordinate targets, whereas the Extension
root view is not a reliable visible-keyboard boundary. A content-free contract
now accepts the hit-target envelope and explicitly rejects a full-screen root
frame.

### Hit-target envelope remediation validation

The implementation is immutable at
`af37383eecd3abb99f7e23f74bae81cee9497e10`, with parent
`30d083190499226d9a75aa55add16f6650709e50`. Immediately before validation,
`git status --porcelain=v1` returned no output and `git rev-parse HEAD`
returned that implementation SHA.

Release-like A and B used scheme `UniverseKeyboardUITests`, configuration
`Release`, iPhone 17 Pro Max iOS 27 Simulator
`06C5BC3E-7599-4761-A1A2-71DAEA991474`, `CODE_SIGNING_ALLOWED=NO`,
`ARCHS=arm64`, `ONLY_ACTIVE_ARCH=YES`, the same exact six non-physical
content-free methods and separate DerivedData:

- A: `/private/tmp/universe-keyboard-af37383-run4-fix-a`, with
  `OTHER_SWIFT_FLAGS=$(inherited) -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT`;
- B: `/private/tmp/universe-keyboard-af37383-run4-fix-b`, with the same flag
  plus `-DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED`.

| Arm | Result | Build/test log | Result bundle |
|---|---:|---|---|
| A | `6 / 6` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-29T12-13-05-880Z_pid23283_ea1e8fd7.log` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-29T12-13-05-880Z_pid23283_02720d57.xcresult` |
| B | `6 / 6` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-29T12-16-50-726Z_pid23283_e5e0b430.log` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-29T12-16-50-726Z_pid23283_2aea0e46.xcresult` |

The A and B log SHA256 values are respectively
`63cecb9a3ce7d8436b5e8a66cdb8924acf3ece96698d1010ad95c37ab64f93bb`
and
`2932000b87d5c81b0ced781f28d50ff7fb76c1314b67e5f4164fabac45153fbb`.
Structured results reported zero failures, skips, runtime warnings and errors.
Each raw build/test log retains three identical non-blocking `AppIntents`
metadata-extraction-skipped warnings; no zero-warning build is claimed.

The ordinary Release Simulator build used scheme `Universe Keyboard`, no
preflight flag and DerivedData
`/private/tmp/universe-keyboard-af37383-run4-fix-ordinary`. It passed with log
`~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-07-29T12-19-46-338Z_pid23283_d330c58a.log`,
SHA256 `2e592eb545c705d54cc28c8e97cb7a208e699ed26b1394e62d3fb871e61dcdfc`.
That raw build log retains two of the same non-blocking `AppIntents` warnings.

The ordinary Extension binary is:

```text
/private/tmp/universe-keyboard-af37383-run4-fix-ordinary/Build/Products/Release-iphonesimulator/Universe Keyboard.app/PlugIns/Keyboard.appex/Keyboard
```

Its SHA256 is
`842a01455a56ec2b00ffacf245c6aaae16fa9d4003746c0cff4ae1a6c69cabea`.
The exact `strings -a <binary> | rg -n` inventory for
`T9DEVICE|T9_S6A|t9_s6a_run_envelope|t9_s6a_matrix_tokens` returned no
matches (`rg` exit `1`).

These local results do not authorize another physical retry. Independent
Architecture and Quality review, a fresh signed A, artifact review, read-only
device precheck and fresh Human readiness remain mandatory. The matrix remains
`0 / 5`.

### Canonical-envelope review remediation

The first Architecture review accepted the hit-target-union direction but
failed the combined checkpoint because the ADR/Assignment still described a
keyboard-container frame and the validator also accepted larger lower-screen
rectangles. Checkpoint `0f52d2be2f537413e2e5e765db8030556157525a`
closes both findings:

- ADR 0024 and this Assignment define `keyboard` as the T9 hit-target
  interaction envelope, canonically equal to the union of the eight serialized
  slot rectangles within the existing geometry tolerance; it is explicitly
  not the Extension root view, keyboard chrome or container;
- validation recomputes the union from all eight parsed slots and requires the
  recorded envelope to match it;
- the synthetic canonical geometry now uses that union, while enlarged,
  offset and full-screen envelopes all fail closed.

The checkpoint's parent is
`d5c1ee0b3d42f4cf9c92a7070d268b5fe7f1bdc7`. Immediately before validation,
`git status --porcelain=v1` returned no output and `git rev-parse HEAD`
returned `0f52d2b`.

Release-like A and B reused the same Release configuration, simulator,
architecture controls, exact six non-physical content-free methods and
arm-specific flags documented above, with separate DerivedData:

- A: `/private/tmp/universe-keyboard-0f52d2b-canonical-envelope-a`;
- B: `/private/tmp/universe-keyboard-0f52d2b-canonical-envelope-b`.

| Arm | Result | Build/test log | Result bundle |
|---|---:|---|---|
| A | `6 / 6` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-29T12-26-28-122Z_pid23283_3338f896.log` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-29T12-26-28-123Z_pid23283_cd167457.xcresult` |
| B | `6 / 6` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-29T12-29-31-775Z_pid23283_4def1979.log` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-29T12-29-31-775Z_pid23283_961cac85.xcresult` |

The A/B log SHA256 values are respectively
`dc26db31bdf5ae96e85b8af738360ba0f1e3c80f394b6900f547d23f4464c0da`
and
`e1506ec49f890c67871e304a8e54e9d2dd3c36c35a0b0650c26cbeb2c2e1c365`.
Structured results reported zero failures, skips, runtime warnings and errors;
each raw log retains three identical non-blocking `AppIntents`
metadata-extraction-skipped warnings.

This checkpoint changes only the UI-test validator/contracts and authority
documents after implementation `af37383`; it changes no production build
input. The ordinary Release build, binary hash and negative strings scan bound
to clean `af37383` above therefore remain the production-isolation evidence.

These results still do not authorize a physical retry. Independent narrow
Architecture/Quality re-review, a fresh signed A, artifact review, read-only
device precheck and fresh Human readiness remain mandatory. The matrix remains
`0 / 5`.

## Fresh Signed A After Canonical-Envelope Review

Architecture and Quality independently reviewed combined checkpoint
`7c8a79896fe8646e9a8df06bb014acfc011b9f9e` and both returned `Pass`, with
P0–P3 none. The production geometry remediation remains immutable at
`af37383eecd3abb99f7e23f74bae81cee9497e10`; the canonical validator and
authority remediation is immutable at
`0f52d2be2f537413e2e5e765db8030556157525a`.

From a clean `7c8a798` worktree, a fresh signed A was built without
installation, launch or physical-device mutation:

```sh
xcodebuild -quiet -project 'Universe Keyboard.xcodeproj' \
  -scheme UniverseKeyboardUITests -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath \
  /private/tmp/universe-keyboard-s6a-coordinate-device-a-7c8a798 \
  -allowProvisioningUpdates \
  'OTHER_SWIFT_FLAGS=$(inherited) -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT' \
  build-for-testing
```

The build produced the expected App and `.xctestrun`; its `-quiet` log is
empty with SHA256
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
Build identity is:

- Xcode `27.0 (27A5228h)`, iPhoneOS SDK `27.0 (24A5390e)`;
- configuration `Release`, arm64, condition
  `-DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT`;
- App `com.DoubleShy0N.Universe-Keyboard`, version/build `1.0 (1)`;
- Extension `com.DoubleShy0N.Universe-Keyboard.Keyboard`;
- Team ID `C33N6HTS9N`;
- App executable SHA256
  `9925ffe442a260916d2cabb79d537e4eb8a5eac48b49362c963076757177683c`;
- embedded and standalone Extension executable SHA256
  `7b324c96d98b193a92fa029d488ad7fe2fbcc65c32325b6334d397d8d04fb94d`;
- UI-test executable SHA256
  `43c1323a6f10e92fbef3d84f1c9d195a81d9b6e9fb0c5273ff5861402e96c775`;
- App, Extension and UI-test Mach-O UUIDs respectively
  `0C684716-E7F8-36C4-83F6-76292746643C`,
  `04EA23FC-71DF-335D-9901-3F7BD56E60B4`, and
  `9AF55B51-E11F-3D22-AD6A-0D6500F988CC`.

`codesign -dv` reports the expected identifiers and Team ID for the App,
Extension, runner and UI-test bundle. Host
`codesign --verify --deep --strict` returns
`CSSMERR_TP_NOT_TRUSTED` for all four signed products; this is retained as the
known beta-host trust warning and is not claimed as strict verification
success. The standalone and embedded Extension executables are byte-identical.

The Extension string inventory contains `T9DEVICE_DISABLED` and the common
`t9_s6a_run_envelope` / `t9_s6a_matrix_tokens` keys, and contains no
`T9DEVICE_ENABLED`. After the final build command, only the three frozen
test-runner values were added to `EnvironmentVariables`:

- `T9_S6A_DEVICE_PREFLIGHT_RUN=1`;
- `T9_S6A_DISPOSABLE_LIST=Universe Keyboard S6A 20260728`;
- `T9_S6A_EXPECTED_MARKER=T9DEVICE_DISABLED`.

`plutil -lint` passed and all three values were read back exactly. The final
file is:

```text
/private/tmp/universe-keyboard-s6a-coordinate-device-a-7c8a798/Build/Products/UniverseKeyboardUITests_iphoneos27.0-arm64.xctestrun
```

Its SHA256 is
`f55e5e8b3fa42a0a429a196a6c5a1d34a2dddbb614058d71615f25031338f3cc`.
No build command ran after this injection.

The first narrow Quality artifact review found that these three values had
initially been placed under `TestingEnvironmentVariables`, contrary to the
frozen Assignment and the previously exercised physical-runner placement. No
binary was rebuilt. The values were removed from that dictionary and inserted
only under `EnvironmentVariables`; `TestingEnvironmentVariables` now contains
only Xcode's original scheme-name value. The lint, exact readback and final
hash above all describe the corrected artifact.

The signed A remains held locally and is not yet authorized for installation.
It requires independent narrow artifact review, then a fresh read-only device
precheck and a new Human readiness confirmation. The readiness statement made
while this artifact was still building is deliberately not reused. The matrix
remains `0 / 5`.

## Physical A1 Coordinate Run 5 And Automation Pause

Architecture and Quality independently passed the corrected signed-A artifact
checkpoint `d4161d913364d4afa883d957bec2f8843815abb1`, with P0–P3 none. A fresh
read-only precheck then confirmed the declared iPhone 13 Pro, iOS `27.0
(24A5390f)`, wired connection, unlocked state, portrait orientation and
Developer Mode. Device Hub visually confirmed the exact empty disposable
Reminders-list overview before installation.

The reviewed A artifact was installed by replacement. No app uninstall,
container deletion, userdb reset or Reminders cleanup occurred. The App,
Extension and final `.xctestrun` SHA256 values immediately before installation
matched the reviewed values:

- App:
  `9925ffe442a260916d2cabb79d537e4eb8a5eac48b49362c963076757177683c`;
- Extension:
  `7b324c96d98b193a92fa029d488ad7fe2fbcc65c32325b6334d397d8d04fb94d`;
- `.xctestrun`:
  `f55e5e8b3fa42a0a429a196a6c5a1d34a2dddbb614058d71615f25031338f3cc`.

Only the frozen physical method ran, with the unique result location:

```text
/private/tmp/universe-keyboard-s6a-coordinate-device-evidence/pair1-A-coordinate-run5.xcresult
```

The method reached Reminders, created one empty test item, focused its title
field and then failed closed with `geometry-invalid` before
`driveFrozenFixture`. Therefore:

- coordinate key actions: `0`;
- synthetic composition actions: `0 / 38`;
- valid physical arms: `0`;
- matrix: `0 / 5`;
- classification: invalid automation arm, not a keyboard-performance result.

No diagnostics, screenshots, UI hierarchy or attachments were opened,
exported or copied. Xcode then stalled while finalizing the failed result. At
the Human Product Owner's direction, the executor stopped the run; the process
ended with `BUILD INTERRUPTED`.

After two days of coordinate-driver work and five invalid attempts without one
synthetic key action, the Human Product Owner elected to stop further physical
coordinate automation for this iteration. This is a deliberate scope decision,
not a successful S6-A exit and not a Product Gate. The deterministic
content-free unit/Simulator contracts remain valuable regression coverage, but
the physical experience decision moves to the paired manual observation
runbook:

[`t9-auto-anchor-manual-device-observation-2026-07-29.md`](t9-auto-anchor-manual-device-observation-2026-07-29.md).

The device currently contains the internal signed A preflight build. Before
ordinary use, the same-source ordinary signed Release must be installed by
replacement; it must not be restored by uninstalling the app or deleting its
container.
