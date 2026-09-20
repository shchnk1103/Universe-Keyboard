# Evidence: TYPO-CORRECTION-002 recall remediation publication preflight

## Identity

| Field | Value |
|---|---|
| Assignment | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`](../assignments/typo-correction-002-recall-remediation-publication-preflight-001.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001.md) |
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| Source HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| Source tree | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| Package.swift SHA-256 | `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` |
| Frozen remediation manifest SHA-256 | `c135c78b435fb2278fc734ed354bbf9e396266cdfffe878aef8a887b22c30ac0` |
| Simulator target | `iPhone 17 Pro / iOS 26.0 / 8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` |
| Evidence status | `Blocked — App + Keyboard Debug test gate failed` |

This record describes a preflight attempt, not a product Run. It has no new INT-003, QA-001, RIME, device, or performance Run ID.

## Required dependency pin

The checked-in manifest declares the only acceptable restoration input for this build precondition:

| Field | Value |
|---|---|
| Vendor version | `rime-vendor-ios-1.16.1-lua.1-octagram.1` |
| Archive SHA-256 | `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` |
| Archive URL | `https://github.com/shchnk1103/Universe-Keyboard/releases/download/rime-vendor-ios-1.16.1-lua.1-octagram.1/universe-keyboard-rime-vendor-ios-1.16.1-lua.1-octagram.1.zip` |
| Framework inventory | 12 iOS xcframeworks listed by `config/rime-vendor-manifest.env` |

The archive was materialized under the separate vendor-materialization Authorization and verified in the isolated worktree. The full provenance record is [`RIME vendor materialization evidence`](typo-correction-002-recall-remediation-rime-vendor-materialization-2026-09-20.md).

## Results

| Check | Result | Details |
|---|---|---|
| Swift format in-place | Pass | Ran on the three changed Swift files; post-format SHA-256 remained `9fb3fdc9c4cb809cf08b098bd882226e74a1a74eef23a043bba261d017216b57`, `e05488596a044e199b30fb3f262f72877ff31b172ba98638091b44ce7b030c9d`, `9147004b425c19f2326292358f13e6db90c4d3969f2e4fb758841119991f3fd6`. |
| Swift strict lint | Pass | `xcrun swift-format lint --strict --configuration .swift-format` passed for all three changed Swift files. |
| KeyboardCore full test | Pass | Host-permission retry with writable caches: `1143` tests, `0` failures, completed `2026-09-20 11:25:37 +0800`. First sandbox attempt stopped before manifest compilation with `sandbox_apply: Operation not permitted`; it was not treated as a test result. |
| RimeBridgeTests | Pass | After exact pinned vendor materialization: `85` passed, `0` failed, `20` skipped. Log: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-20T03-51-37-493Z_pid25092_2f1f3594.log`; result bundle: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-20T03-51-37-493Z_pid25092_ac5aa118.xcresult`. |
| Universe Keyboard Debug tests | Fail | `389` discovered: `372` passed, `7` failed, `9` skipped. All seven failures are in `RimeSettingsStoreTests` and assert `"failed"` instead of `"deployed"`. Log: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-20T03-52-08-786Z_pid25092_14f8e123.log`; result bundle: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-20T03-52-08-786Z_pid25092_b9427a3f.xcresult`. |
| Universe Keyboard Release build | Pass | `build_sim` completed successfully in `72.5s`; log: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-09-20T03-54-57-362Z_pid25092_5959df6d.log`. |
| `ensure_rime_vendor.sh verify` | Pass | The exact archive checksum, receipt, 12-framework inventory, required device/simulator slices, and vendor tree aggregate are recorded in the vendor-materialization evidence. |
| `git diff --check` | Pass | Final docs-only update checked with no whitespace errors. |

## Root cause and boundary

The first preflight attempt was blocked because the isolated worktree had no ignored `Packages/RimeBridge/Vendor/` directory. That dependency blocker was resolved by the separate materialization Authorization: the pinned archive matched SHA-256 `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`, and `ensure_rime_vendor.sh verify` passed.

The remaining publication blocker is the App + Keyboard Debug test gate. The seven failing cases are all in the unchanged `RimeSettingsStoreTests` fixture path:

- `testCancelLiveDeploymentReleasesRetryWithoutWaitingForCompletion`
- `testLoadTreatsOrphanedDeployingFlagAsFailedWithoutAutoRetry`
- `testTriggerDeploymentCompletesInsideMainAppBeforeKeyboardUse`
- `testTriggerFuzzyDeploymentIfNeededOnlyRunsWhenPending`
- `testTriggerPendingDeploymentIfNeededRunsAfterFreshLoadSeed`
- `testTriggerPendingDeploymentIfNeededRunsForGenericNeedsDeployIntent`
- `testTriggerPendingDeploymentIfNeededRunsForUserDictionaryIntent`

The fixture service returns a successful `RimeDeploymentResult` without a `librimeVersion`. The current `SchemaManager+Deployment` path fail-closes before marking the deployment `deployed` when that provenance field is absent, so these fixtures remain `failed`. The unchanged `UniverseKeyboardTests/RimeSettingsStoreTests.swift` blob is `55bd3e697da246ec2455deebb4c63dc364b40baa`, identical to `HEAD:UniverseKeyboardTests/RimeSettingsStoreTests.swift`. The build log also contains repeated `container_create_or_lookup_app_group_path_by_app_group_identifier: client is not entitled` warnings. The current remediation does not modify these tests, the App/Extension targets, RIME bridge code, or entitlements; therefore this is not evidence that the pure KeyboardCore change caused the failure, but it is still a red local CI gate.

## Residuals / next authorization frontier

- The pure KeyboardCore remediation remains unchanged and its local Core gates are green.
- Vendor provenance is complete; `RimeBridgeTests` and the Release build are green.
- Publication preflight remains blocked because the App + Keyboard Debug test gate is red in the existing deployment-fixture contract/environment.
- Do not commit, push, open a PR, or request merge/publication from this snapshot while that required gate is red.
- The next authorization frontier is a separate bounded test-contract/environment remediation for `RimeSettingsStoreTests` and/or the signed App Group test lane. It must preserve the production provenance requirement and must not weaken the fail-closed runtime path.

## Non-claims

This evidence is not a Product/Quality/Release Gate, not a commit/push/PR/merge authorization, and not evidence for INT-003, QA-001, paired performance, 180 ms, real-device behavior, RIME deployment correctness, or production readiness. A green `RimeBridgeTests` or Release build does not override the red App + Keyboard Debug test gate.
