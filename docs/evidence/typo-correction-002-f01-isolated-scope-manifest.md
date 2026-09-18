# TYPO-CORRECTION-002 / F-01 Isolated Scope Manifest

> **Status:** Executor-recorded isolated working-tree boundary; final
> post-gate read-only review passed; commit/push pending; no Quality approval
> or Gate decision
>
> **Final validation run:** `TC2-F01-AUDIT-20260918-FULL-04`

This manifest records a clean F-01-only working-tree diff created from the
Assignment baseline. It is separate from the broader dirty provenance/sidecar
worktree and does not reclassify that worktree's changes.

## Identity

| Field | Value |
|---|---|
| Baseline commit | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` |
| Baseline tree | `68dfd44cfe7b23a4aeb48df1ebc9f942e8949774` |
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-f01-audit` |
| Branch | `codex/typo-correction-002-f01-audit` |
| Final test-only validation run | `TC2-F01-AUDIT-20260918-FULL-04` |
| Simulator | `iPhone 17 Pro Max`, iOS `27.0`, build `24A434` |
| Simulator UDID | `06C5BC3E-7599-4761-A1A2-71DAEA991474` |

## Three-way selection

The baseline already had the real deployer obtain `librimeVersion` internally,
but it did not expose that identity in `RimeDeploymentResult` or gate the
success flags on it. The broader provenance/sidecar worktree contains the same
identity propagation and a stronger runtime-receipt transaction, but also
contains unrelated typo-correction and device-evidence changes.

For this commit/push authorization, the selected implementation is this
minimal, independently reviewed F-01 diff. The broader worktree is explicitly
excluded and remains untouched.

## Source diff boundary

Exactly four tracked source files differ from the baseline:

| Path | F-01-only purpose |
|---|---|
| `Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift` | Carries the observed `librimeVersion` from the real deployment service into `RimeDeploymentResult` |
| `Universe Keyboard/Services/SchemaManager+Deployment.swift` | Rejects nil or empty binary identity before publishing `rime_deployed=true`; restores pending flags |
| `UniverseKeyboardTests/RimeSettingsStoreTests.swift` | Updates the existing deployment test double so a simulated successful deployment carries the required test identity |
| `UniverseKeyboardTests/SchemaManagerTests.swift` | Supplies a test identity for successful fixtures and covers nil/empty identity fail-closed behavior |

The only additional worktree file is this documentation manifest. No typo
sidecar, runtime receipt store, direct-query diagnostics, schema archive
fixture, device evidence, or unrelated source change is present in this
isolated boundary.

## Dependency and validation evidence

The ignored RIME vendor payload was prepared using the repository script and
verified against the pinned manifest:

- Version: `rime-vendor-ios-1.16.1-lua.1-octagram.1`
- Archive SHA-256: `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`
- `bash scripts/ensure_rime_vendor.sh verify`: pass

The initial targeted test-only command was:

```text
xcodebuild -quiet -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination "id=06C5BC3E-7599-4761-A1A2-71DAEA991474" -derivedDataPath /private/tmp/universe-keyboard-f01-audit-clean-02-deriveddata -resultBundlePath /private/tmp/universe-keyboard-f01-audit-clean-02.xcresult CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES -parallel-testing-enabled NO -only-testing:UniverseKeyboardTests/SchemaManagerTests test
```

The retained result bundle is
[`universe-keyboard-f01-audit-clean-02.xcresult`](/private/tmp/universe-keyboard-f01-audit-clean-02.xcresult).
Its summary reports `Passed`, `87` passed, `0` failed, and `0` skipped.
Strict Swift formatting and `git diff --check` also passed.

The final validation set was run with new test-only audit identifiers after the
test-double contract correction:

| Audit run / command | Result | Retained evidence |
|---|---|---|
| `TC2-F01-AUDIT-20260918-CLEAN-02` — targeted `SchemaManagerTests` | 87 passed, 0 failed, 0 skipped | [`universe-keyboard-f01-audit-clean-02.xcresult`](/private/tmp/universe-keyboard-f01-audit-clean-02.xcresult) |
| `TC2-F01-AUDIT-20260918-RIME-SETTINGS-03` — targeted `RimeSettingsStoreTests` | 49 passed, 0 failed, 0 skipped | [`universe-keyboard-f01-rime-settings-store-03.xcresult`](/private/tmp/universe-keyboard-f01-rime-settings-store-03.xcresult) |
| `TC2-F01-AUDIT-20260918-FULL-01` — `RimeBridgeTests` | 81 passed, 0 failed, 20 skipped | [`universe-keyboard-f01-full-rimebridge.xcresult`](/private/tmp/universe-keyboard-f01-full-rimebridge.xcresult) |
| `TC2-F01-AUDIT-20260918-FULL-04` — App/Keyboard Debug tests | 377 passed, 0 failed, 9 skipped | [`universe-keyboard-f01-full-app-04.xcresult`](/private/tmp/universe-keyboard-f01-full-app-04.xcresult) |
| `TC2-F01-AUDIT-20260918-RELEASE-05` — App/Keyboard Release build | exit 0 | `/private/tmp/universe-keyboard-f01-full-release-deriveddata-05` |

The first App/Keyboard full run before the test-double correction failed seven
`RimeSettingsStoreTests` cases because the injected successful result omitted
`librimeVersion`. It is retained as diagnostic evidence at
[`universe-keyboard-f01-full-app.xcresult`](/private/tmp/universe-keyboard-f01-full-app.xcresult),
was corrected only in the test double, and is not counted as a passing gate.

All four changed Swift files passed `swift-format format --in-place` followed
by `swift-format lint --strict --configuration .swift-format`; `git diff
--check` also passed. The KeyboardCore package gate passed with 1,125 tests,
0 failures; it emitted one pre-existing optional-string-interpolation warning
in `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift:1429`.

## Independent read-only review

The pre-gate independent reviewer inspected the clean source boundary and
returned:

- `F01-SCOPE-01`: **closed**; the source diff is auditable against the exact
  baseline and contains no unrelated source changes.
- `F01-IDENTITY-01`: **pass**; the real deployment service carries the
  observed librime identity into `RimeDeploymentResult`.
- `F01-GUARD-01`: **pass**; nil and empty identity fail closed before the
  deployed flag is published.
- `F01-TEST-01`: **pass**; independent nil and empty cases exist and the
  successful fixture supplies `test-librime`.
- `F01-MANIFEST-01`: **pass** as an Executor evidence-boundary record.

The reviewer did not execute the test command, edit, deploy, commit, or push.
The result bundle remains Executor-provided evidence and was not promoted to
an independent Quality receipt. The final post-gate reviewer
(`01a0b4b7-898c-76a0-b63d-f1e67db16266`) then returned **Pass** with
`P0=none`, `P1=none`, and `P2=none`; it also did not modify files, run tests,
deploy, commit, or push. That conclusion remains limited to this F-01 source
and evidence boundary.

## Claims and non-claims

- The isolated source diff provides a reviewable F-01-only boundary relative
  to the exact baseline above.
- The nil and empty identity cases remain pending with
  `rime_deployed=false`, `rime_needs_deploy=true`, and
  `rime_deploying=false`.
- This is test-only evidence. It does not prove real RIME archive provenance,
  device behavior, candidate quality, latency, INT-003, QA-001, Product,
  Quality, TestFlight, Release, merge, or Assignment acceptance.
- No existing Simulator or physical-device evidence Run ID was changed. No
  product RIME deployment or evidence recapture was performed.
- Commit and push are now the only pending execution steps for this isolated
  branch; this manifest represents the clean worktree diff and its exact
  baseline identity.
