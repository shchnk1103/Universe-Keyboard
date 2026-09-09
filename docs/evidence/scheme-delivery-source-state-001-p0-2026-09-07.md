# SCHEME-DELIVERY-SOURCE-STATE-001 P0 evidence

Executor-recorded, `2026-09-07 Asia/Shanghai`. Human authorized P0 reproduction only. Not Product Gate, merge, TestFlight, ADR 0034 acceptance, or a device-unique root-cause claim.

## Frozen inputs

| Item | Value |
|---|---|
| Clone | `/private/tmp/uk-scheme-delivery-fix` |
| Planning HEAD | `f4b9594a08525d0011a1423aa5a918253573a447` |
| Simulator | `36BAABED-6846-4F9A-A672-6884B54CF50E` (iOS 26.5, Xcode 27.0 `27A5252f`) |
| DerivedData | `/private/tmp/uk-scheme-p0-derived` |
| Ice fixture | `/private/tmp/rime-ice-20260630/github.zip` SHA-256 `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Processed Ice `default.yaml` | 14842 bytes, SHA-256 `0dacfbaca4774c07a0adb2ca2380dc290ada5dfb97e027d54063790ebaca37cd` |
| Bundled Prelude `default.yaml` | 1593 bytes, SHA-256 `0628ada16651d56c4cdfcb8e45ddba23d4d585cc8be0580a62c4e077c0bcc141` |

## Method

Production `SharedContainerSchemaArchiveInstaller.installSchemaFiles` with a test-only container URL override (production App Group path unchanged). Production `RimeBuiltinResourceInstaller.install` against a staged official bundle closure (`RimeConfigManager.stageBundledResourceClosure`). No fake installer. Integrity checks were not relaxed.

`SchemaManager.deployRimeConfig` maps any throw from `deploymentDirectories()` → `prepareDirectories()` → `install()` to `resource_preparation` failure without recording `InstallationError`. P0 therefore observes the installer error at the production `install()` boundary.

## Results

| Scenario | Result |
|---|---|
| Builtin receipt present, Ice plan writes `default.yaml`, builtin redeploy | `InstallationError.byteCountMismatch`; Ice bytes remain |
| Same, then Ice uninstall | `rime_ice.schema.yaml` removed; `default.yaml` still Ice; redeploy still `byteCountMismatch` |
| Wanxiang plan on a tree that contains `default.yaml` | `default.yaml` not installed; builtin redeploy succeeds |
| Builtin-only repeated deploy | succeeds, official bytes unchanged |
| No prior receipt, foreign `default.yaml` present | builtin `install()` replaces it with official bytes |
| Processed Ice `withLua` tree (fixture present) | installed `default.yaml` matches 14842 / `0dacfbac…`; redeploy `byteCountMismatch` |

Mechanism: `install()` validates every receipt-owned shared file **before** creating mutations. Ice `rime-ice-plan-1` admits `default.yaml` and does not list it in `removableFiles`. Size 14842 ≠ 1593, so `validateDeployedEntries` throws `.byteCountMismatch` (size is checked before SHA). The installer rollback list is empty, so fail-closed does not restore official Prelude bytes.

This is a sufficient production-path explanation for the device log `resource_preparation started → failed → terminal failed` **if** the device already had a valid builtin receipt. It is not a device-attested unique cause: the phone did not emit `InstallationError`, and overlay / `installation.yaml` / App Group membership failures remain possible parallel branches.

## Commands

```sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme RimeBridgeTests \
  -configuration Debug -destination 'platform=iOS Simulator,id=36BAABED-6846-4F9A-A672-6884B54CF50E' \
  -derivedDataPath /private/tmp/uk-scheme-p0-derived \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
  -only-testing:RimeBridgeTests/RimeBuiltinResourceInstallerTests/testRedeployFailsClosedWhenSharedDefaultYamlNoLongerMatchesReceipt \
  -only-testing:RimeBridgeTests/RimeBuiltinResourceInstallerTests/testRedeployRestoresDefaultYamlWhenNoPriorReceiptExists \
  test

TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT=/private/tmp/rime-ice-20260630 \
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" \
  -configuration Debug -destination 'platform=iOS Simulator,id=36BAABED-6846-4F9A-A672-6884B54CF50E' \
  -derivedDataPath /private/tmp/uk-scheme-p0-derived \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
  -only-testing:UniverseKeyboardTests/SchemeResourcePreparationCoexistenceTests \
  test
```

Focused results: RimeBridge 2/2 pass; App coexistence 5/5 pass (including processed Ice tree). xcresult: `/tmp/uk-scheme-p0-derived/Logs/Test/Test-RimeBridgeTests-2026.09.07_19-13-06-+0800.xcresult` and `Test-Universe Keyboard-2026.09.07_19-15-48-+0800.xcresult`.

## Not run

Full KeyboardCore, full App/Keyboard suite, Debug/Release build, hosted CI, physical-device retest, deployment-phase journal diagnostics.

## Stop

P0 complete. Do not enter P2/P3. Next: Human review of mechanism vs device; optional P1 audit; optional bounded diagnostics that record `InstallationError` without paths or YAML.
