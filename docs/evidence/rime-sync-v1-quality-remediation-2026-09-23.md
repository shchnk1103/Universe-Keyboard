# RIME-SYNC-001 Quality Finding Remediation — 2026-09-23

## Identity and authority boundary

| Field | Value |
|---|---|
| Base commit | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Candidate | Exact uncommitted working-tree snapshot in the isolated `rime-sync-docs-close-20260923` worktree |
| Simulator | iPhone 18 Pro, iOS 27.0, `405D994F-28CB-4F89-BB22-B64AD81C05A2` |
| Scope | Remediate the three findings in the original independent Quality review; request a fresh exact-snapshot Quality re-review |
| Publication | No commit, push, PR, merge, release, device operation or Product lifecycle decision is authorized or claimed |

The prior Hegel review remains historical and is not overwritten. Its verdict
was `Blocked`. First fresh re-review by Aquinas (GPT-6 Luna) was also `Blocked`:
it found that fixture lifecycle code could still invoke production background
scheduling and required stronger attribution for the discovery-count delta.
The fixture lifecycle boundary is now corrected and re-tested. The binary
method-name inventory matches executed test IDs, although the cause of the
one-count MCP discovery over-report remains unknown. A distinct second fresh
Quality review must assess this exact snapshot; neither prior verdict is
rewritten.

## Finding disposition

| Finding | Remediation | Verification |
|---|---|---|
| Unsigned CI cannot execute OS Keychain integration | The broad suite skips only when a read-only Keychain preflight returns `errSecMissingEntitlement`. CI adds a focused ad-hoc-signed Simulator Keychain job (`CODE_SIGNING_IDENTITY=-`, no team credential) and includes its result in the fail-closed final gate. | Unsigned focused test: 0 passed / 0 failed / 1 expected skip. Ad-hoc-signed production Keychain CRUD test: 1 passed / 0 failed / 0 skipped. |
| UI tests could read or mutate production Simulator preferences/secrets | Every UI launch passes a unique defaults-suite name. The DEBUG fixture clears/seeds only that suite and injects an in-memory secret store; keyboard activity defaults use the same isolated suite. Fixture launches also disable background scheduling at the ViewModel boundary, skip app background-task registration, and bypass lifecycle-triggered automatic sync, deployment, backup, and schedule-refresh side effects. | Corrected-candidate full `RimeSyncSettingsUITests`: 8 passed / 0 failed / 0 skipped; result bundle `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T12-31-19-792Z_pid5815_919bbc64.xcresult`. Focused ViewModel regression test passed 1/1. |
| XcodeBuildMCP discovery count disagreed with executed result count | Reconcile the discovery count against the binary test-method inventory and executed result IDs; do not infer a missing test's identity from totals alone. | Corrected-candidate run: XcodeBuildMCP reports 396 discovered; `xcresult` reports 395 total (385 passed + 10 skipped, 0 failed). The 395 unique method names extracted from both XCTest binaries exactly match the 395 unique method names in result IDs (zero names missing either way). No absent test method accounts for the extra discovery count. Why XcodeBuildMCP's tally is one higher remains unexplained; it is retained as a tool-reporting limitation, not treated as an executed test. |

### Test-count reconciliation

The corrected-candidate App + Keyboard result bundle is
`~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T12-15-53-587Z_pid5815_d1efb7f2.xcresult`.
`xcresulttool get test-results summary` reports `totalTestCount=395`,
`passedTests=385`, `skippedTests=10`, and `failedTests=0`. XcodeBuildMCP's
discovery output reports 396. As a bounded reconciliation, the unique test
method-name inventory extracted from the `KeyboardTests` and
`UniverseKeyboardTests` binaries (395 names) was compared with normalized test
method names in all 395 `xcresult` test IDs; both set differences are empty.
Thus no missing or unexecuted test method accounts for the extra discovery
count. The extra tally itself remains unexplained; it is excluded from the
authoritative total and retained as a tool-reporting limitation. The skipped
tests are:

- `RimeIcePinnedArtifactTests/testVerifiedOfficialAndMirrorArchivesConvergeAfterProductionProcessing`
- `RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem` (expected unsigned-host entitlement skip; executed in the signed lane)
- `SchemeResourcePreparationCoexistenceTests/testCS06_UninstallInactiveWanxiangRetainsIcePeerInventory`
- `SchemeResourcePreparationCoexistenceTests/testCS0910_RealInstallerIceRemovalPreservesCompleteWanxiangInventory`
- `SchemeResourcePreparationCoexistenceTests/testCS0910_RealInstallerWanxiangRemovalPreservesCompleteIceInventory`
- `SchemeResourcePreparationCoexistenceTests/testKnownIceDefaultYamlPollutionIsRecoveredThenBuiltinRedeploySucceeds`
- `SchemeResourcePreparationCoexistenceTests/testProductionProcessedIceTreeKeepsOfficialDefaultYamlWhenFixturePresent`
- `TD012LMDGDeviceStagingTests/testPinnedModelLoadsThroughWanxiangGrammarOnAuthorizedPhysicalDevice`
- `TD012LMDGDeviceStagingTests/testRemovePinnedModelAfterAuthorizedPhysicalDeviceSpike`
- `TD012LMDGDeviceStagingTests/testStagePinnedModelForAuthorizedPhysicalDeviceSpike`

## Verification matrix

| Check | Result | Evidence |
|---|---|---|
| Strict formatting | Pass | `xcrun swift-format lint --strict --configuration .swift-format` on all changed Swift files |
| Diff whitespace | Pass | `git diff --check` |
| KeyboardCore | Pass | 1,153 tests, 0 failures; `swift test --package-path Packages/KeyboardCore --scratch-path /private/tmp/rime-sync-remediation-keyboardcore-build` |
| RimeBridgeTests | Pass | 82 passed, 20 skipped, 0 failed; iPhone 18 Pro Simulator result `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T11-47-42-423Z_pid5815_1d18b9f9.xcresult` |
| App + Keyboard | Pass | 385 passed, 10 skipped, 0 failed; authoritative total 395; result path above |
| Signed Keychain integration | Pass | Corrected-candidate ad-hoc-signed lane: 1 passed, 0 skipped; result `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T12-35-41-482Z_pid5815_f55e4935.xcresult` |
| Unsigned Keychain integration | Expected skip | 1 skipped only for missing entitlement; result `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T11-29-09-590Z_pid5815_749ca766.xcresult` |
| RIME settings UI | Pass | Corrected candidate: 8 passed, 0 skipped; result `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T12-31-19-792Z_pid5815_919bbc64.xcresult` |
| Release build | Pass | Corrected-candidate iPhone 18 Pro Simulator build; XcodeBuildMCP log `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-09-23T12-36-27-831Z_pid5815_7d95d89c.log` |
| RIME vendor inventory | Pass | `bash scripts/ensure_rime_vendor.sh verify`: 12 framework artifacts verified |
| CI gate script matrix | Pass | `bash scripts/ci/tests/test_verify_final_gate.sh`, including full-success and docs-only-skipped matrices |
| Lightweight CI checks | Pass | 12 Python CI tests and KOS governance-trigger checks passed. The CI helper called with commit-only base/head saw 0 changed Markdown files; a separate worktree-aware run validated repository-local links in all 13 changed Markdown files. |

The `.github/workflows/swift6-quality.yml` workflow was edited locally but no
hosted GitHub run exists because nothing was pushed. Hosted workflow execution
and merge readiness are not claimed. The RimeBridge suite's 20 skips remain
skips, not passes.

The UI suite's first post-isolation run had 7 passes and one failure because
the test treated accessibility-tree existence as visible/hittable state while
the status row was virtualized outside the viewport. It now scrolls the status
row back to a hittable position; the focused case and corrected-candidate full
8-test UI run both passed. A later fresh review also found lifecycle code
could reach production background scheduling. The fixture now injects a
disabled-scheduling mode and bypasses lifecycle sync/deployment/backup work.
These are test-isolation corrections, not product behavior changes.

## Remaining boundaries

- This is Simulator engineering evidence only. It does not establish physical
  iPhone Keychain behavior, a source/build identity for the human's installed
  app, or provider-side deletion semantics.
- The user-reported VoiceOver and enlarged-text check remains human-attested;
  fresh Quality review must retain its source-provenance limitation.
- The first fresh Quality re-review found a lifecycle side-effect leak and
  requested stronger attribution of the discovery discrepancy. The lifecycle
  leak is corrected locally; the one-count discovery reporting anomaly has no
  missing method identity but remains unexplained. Findings remain open until
  a new independent review assesses this evidence.
- Architecture review, Product lifecycle decision, parent closure, merge,
  TestFlight and Release remain separate future gates.

## Exact package file digests

The fresh reviewer should independently recompute these hashes before review.
This table binds every changed or added file except this report itself; the
report is excluded to avoid recursive self-hashing. It includes source,
tests, CI, evidence, Assignment, dashboard and historical review records.

| File | SHA-256 |
|---|---|
| `.github/workflows/swift6-quality.yml` | `cb4a41108ba0e9268b04b1aaca8bd06480da3e0dd8706221acbbce3ad6a0a6a8` |
| `Universe Keyboard/App/ContentView.swift` | `aa9abbe72bc40cc7561f82ce076b565f06b210ecdc7ffed570a1b9a9078fe33f` |
| `Universe Keyboard/App/Universe_KeyboardApp.swift` | `317497cc73acc83f136ab5477c633e53a3857c5fdb4cc46b688cefd94bcca8c6` |
| `Universe Keyboard/Models/RimeSyncUITestFixture.swift` | `e7059609de523009c5519b79c6f23936a162e9073b1b57794c984ad2b6bc3480` |
| `Universe Keyboard/Models/RimeSyncViewModel.swift` | `d354cc0460bf2c9e4f81e86496b2d8506b9846428c2efbcb665a7fc977380a85` |
| `Universe Keyboard/Services/RimeAutomaticSyncScheduler.swift` | `01f3c3a188341b1b34ef980f077f00323b0c9dcb5787c870c4b118297a182d13` |
| `Universe Keyboard/Services/RimeSyncCrypto.swift` | `6813f5c3e03e0483d2aca744ea68116e497b4b23fa81b622aa7e3c48efa192ea` |
| `Universe Keyboard/Views/Settings/RimeSyncSettingsView.swift` | `beb774914813c717c71c576d33590f84b53c7b5b39357b97f314d7734e6eea0d` |
| `UniverseKeyboardTests/RimeSyncTests.swift` | `63a3b25fdd7769e4613b9881c108740f0a7bd1adda43d20e71baf618b8cf7c1c` |
| `UniverseKeyboardUITests/RimeSyncSettingsUITests.swift` | `295f44b069756eb84423c05f56ac15e4451f5acefc35324d861656977cd2e4c7` |
| `scripts/ci/verify_final_gate.sh` | `eaaacf85e8869613bdb0870ef0b70148ca7dcd7d1dc168f04a530e0da3b0dd25` |
| `scripts/ci/tests/test_verify_final_gate.sh` | `d8708784f0d4d112217b7a26e69191315c83bdba01f65970cfedb5ab7b033200` |
| `docs/CI_CHANGE_CLASSIFICATION.md` | `cf33103e0a0c5c64bb48fed1c8b76453f1d570d2787873c4d20e9b87e1ab2ac7` |
| `docs/ACTIVE_WORK.md` | `83ba1d7b80b6ff00869ab8ff1603c5daf02aa83c25e30b9d013a61a0445acf54` |
| `docs/ENGINEERING_DASHBOARD.md` | `c0efb3f2708ab9d0ac0f70f2a537dc4d71cd5944278edf79de3124d5b3c60545` |
| `docs/RIME_SYNC.md` | `4d81533f52bcdcbd00b04e500c2d9537261f6996745f07fe9da76d0cf36db504` |
| `docs/TECH_DEBT.md` | `3a5c72d88da8d214cc35251564bf747a344d9cbb9018de40ab7c5cbab34e5f45` |
| `docs/assignments/rime-sync-001.md` | `bb5e501839ce7ccb31f28a40774a5584493a9c54d4799aa6f3c7e8e9b1128e83` |
| `docs/assignments/rime-sync-diagnostics-v1-001.md` | `99513607ffb6786aba2b415cc100de788437e6a4f70fdcbecdd51fd02a515307` |
| `docs/plans/rime-sync-001-implementation-plan.md` | `a6e96a22e7f450a3347226f7fb1aedbb4a04b8779df8dbf64da8ab8b8e1f8732` |
| `docs/evidence/rime-background-sync-natural-device-success-2026-09-22.md` | `c9c862e49d5fd7457f600025615e8e2c1cd4c038f4fda4decd2632393c3cc408` |
| `docs/evidence/rime-background-sync-natural-device-success-2026-09-23.md` | `86f65b5d6d0c420319d6af34953f7e30924fdf6a872abfa36e4981fdef940520` |
| `docs/evidence/rime-sync-v1-closure-readiness-2026-09-23.md` | `c78538e774888471a8d1b619f1e153bee22d17df3ab4c428a5e63e6c03c23e41` |
| `docs/reviews/rime-sync-v1-simulator-evidence-quality-review-2026-09-23.md` | `0b57653524e97ffb5d834f2fd0f9d01606b6ea2f0f09f14aa7545794d94fb3da` |
