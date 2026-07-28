# T9-AUTO-ANCHOR-001-S6A Coordinate Driver Evidence

## Scope

- **Collected:** 2026-07-28 22:30–22:32 Asia/Shanghai
- **Implementation checkpoint:**
  `13ee432cefa83d2b2d9717c9675db0ed6e934404`
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
| A | `5 / 5` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-28T14-30-25-114Z_pid60177_919378fa.log` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-28T14-30-25-114Z_pid60177_2ee498d5.xcresult` |
| B | `5 / 5` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-28T14-30-37-774Z_pid60177_16f7f4e8.log` | `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-28T14-30-37-775Z_pid60177_97c2b33a.xcresult` |

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

Result: `5 / 5`. This includes malformed existing envelope rejection,
retained-log and current-matrix reuse, prepared/consumed lifecycle, matching
cleanup predicate, versioned registry round-trip, duplicate/malformed registry
rejection and the 64-token bound.

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
| A App | `acd8a592f520a0d72a76f880197379cdfb02ef80f9b72754cd872612f3f134ff` |
| A Extension | `2a818c230e5f6c9515dd8abfeb5372cc7b0dc8fad41ea8a1266ade0328f1b015` |
| B App | `3f000916d176358b905da46fed7f3a2e6e634a843ac2cf9d3ecf120fe5e3983b` |
| B Extension | `1562d8b180461cef7228e8c53241b8b1da40dc8b59aed520458760e4c9e49288` |
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

No release or Product decision is made. This snapshot is eligible only for
independent pre-installation re-review.

## Owner Handoffs

- Architecture: re-review App Group ownership, malformed-state fail-closed
  behavior and ordinary Release isolation.
- Quality: reproduce the two prior P1 cases, inspect the expanded negative
  matrix and verify command/artifact traceability.
- Human Product Owner: no action until both reviewers return Pass; then prepare
  the exact disposable Reminders list before each separately announced arm.
