# Evidence: TYPO-CORRECTION-002 test-contract/environment remediation — diagnosis

## Identity

| Field | Value |
|---|---|
| Assignment | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001`](../assignments/typo-correction-002-recall-remediation-test-contract-environment-001.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001.md) |
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| Source HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| Source tree before test-only change | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| Fixture blob before change | `UniverseKeyboardTests/RimeSettingsStoreTests.swift:55bd3e697da246ec2455deebb4c63dc364b40baa` |
| Fixture Git blob after change | `UniverseKeyboardTests/RimeSettingsStoreTests.swift:45c571adff9169331b8e43df7a900f5b8d613fa9` |
| Fixture file SHA-256 after change | `UniverseKeyboardTests/RimeSettingsStoreTests.swift:788d6fd0fc814a034a61873cda6ba67432e21042f7953c8849212f350e8066f9` |
| Evidence status | `Test-only repair validated; independent review pending` |

This is a bounded diagnosis record, not a product Run, device evidence, performance result, Product/Quality/Release Gate, or publication receipt.

## Findings

1. Before the repair, `UniverseKeyboardTests/RimeSettingsStoreTests.swift` defined `StoreDeploymentService.deploy(_:)` as:
   `RimeDeploymentResult(succeeded: succeeded, diagnosticMessage: "test")`.
2. `RimeDeploymentResult` retains `librimeVersion` as optional for legacy/injected services, while the real deployment service supplies it.
3. `Universe Keyboard/Services/SchemaManager+Deployment.swift` calls `writeRuntimeProvenanceReceipt` before publishing `rime_deployed`; it throws `binaryIdentityUnavailable` when `librimeVersion` is nil or empty.
4. The seven failing tests expect `.deployed` from `StoreDeploymentService(succeeded: true)`, so the observed `.failed` state is consistent with the fail-closed provenance contract:
   - `testCancelLiveDeploymentReleasesRetryWithoutWaitingForCompletion`
   - `testLoadTreatsOrphanedDeployingFlagAsFailedWithoutAutoRetry`
   - `testTriggerDeploymentCompletesInsideMainAppBeforeKeyboardUse`
   - `testTriggerFuzzyDeploymentIfNeededOnlyRunsWhenPending`
   - `testTriggerPendingDeploymentIfNeededRunsAfterFreshLoadSeed`
   - `testTriggerPendingDeploymentIfNeededRunsForGenericNeedsDeployIntent`
   - `testTriggerPendingDeploymentIfNeededRunsForUserDictionaryIntent`
5. The Debug test invocation recorded `CODE_SIGNING_ALLOWED=NO`. The project has App Group entitlements for the App and Keyboard targets, but no checked-in entitlement change is authorized in this child. Repeated `client is not entitled` warnings are therefore retained as a separate test-environment residual, not used to justify changing production entitlements.

## Remediation and validation

- First test-only iteration added `librimeVersion: "test-fixture-librime"`; strict format passed, but the Debug suite remained `372` passed, `7` failed, `9` skipped. This prevented treating the first change as sufficient.
- Read-only inspection of `RimeRuntimeProvenanceReceipt.isValid` showed that builtin receipts also require `runtimeSmokePassed == true`.
- Final test-only fixture result now supplies the deterministic `test-fixture-librime` identity and `runtimeSmokePassed: true` only when `succeeded == true`; failed/cancelled paths retain nil values.
- Strict format/lint passed. Final App + Keyboard Debug run on `iPhone 17 Pro / iOS 26.0 / 8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`: authoritative xcresult `388` total, `379` passed, `0` failed, `9` skipped in `20.2s`.
- The executor's outer XcodeBuildMCP summary recorded `389 discovered`; this historical wrapper count is not corroborated by the xcresult. Raw XCTest output reconciles to `UniverseKeyboardTests=377` plus `KeyboardTests=11`, also `388` total. The reconciliation receipt records `388` as the authoritative execution count.
- Final artifacts: log `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-20T04-14-55-533Z_pid25092_4f6e4ffb.log`; result bundle `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-20T04-14-55-533Z_pid25092_7a8d6b42.xcresult`; test products `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/test-products/test_sim_2026-09-20T04-14-55-533Z_pid25092_5abccf14.xctestproducts`.
- The final build log still contains `107` `client is not entitled` messages because the invocation used `CODE_SIGNING_ALLOWED=NO`. The test result itself reports no diagnostics warnings/errors, and no checked-in entitlement was changed. This residual remains separate and unclosed.

## Count and scope reconciliation

The authoritative count is bound to the retained result bundle:

- `xcrun xcresulttool`: `totalTestCount=388`, `passedTests=379`, `skippedTests=9`, `failedTests=0`.
- Raw XCTest log: `UniverseKeyboardTests.xctest` executed `377` tests with `9` skipped; `KeyboardTests.xctest` executed `11` tests; `377 + 11 = 388`.
- The child scope contains only the test fixture file `UniverseKeyboardTests/RimeSettingsStoreTests.swift`. The other uncommitted KeyboardCore source/tests and governance records remain parent or adjacent work and are not silently absorbed into this child.
- Child-scope manifest digest: `507e3ba431c2f64c0cdbd22d8eb1c1b03cc466ce3b3b12b1966538560b9d0c1a`.

## Decision and next action

The primary red gate was a test-only fixture contract mismatch, not evidence that the production fail-closed path should be weakened. The consumed Authorization permitted the smallest test-only correction: successful fixture results carry a deterministic non-empty test `librimeVersion` and a successful builtin smoke flag, while failed/cancelled paths and production code remain unchanged.

The independent Architecture and Quality reviews are now recorded as `Pass with conditions`. The next step is a new publication-preflight Authorization bound to a fresh final manifest for the parent snapshot. If entitlement warnings require checked-in changes, request a separate Authorization; do not infer that from the green test suite.

## Non-claims

- No production Swift, RIME bridge, schema, vendor, entitlement, signing or runtime code was changed; only `UniverseKeyboardTests/RimeSettingsStoreTests.swift` changed under this child.
- No new Simulator/device/product Run ID was created.
- This record does not close the publication preflight or authorize commit, push, PR, merge, TestFlight or Release.
