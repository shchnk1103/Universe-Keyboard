# Architecture Review — Paired Rollout v5 Validation Evidence R4

## Frozen identity

- **Work Item:** `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`
- **Review lane / round:** `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001/v5-validation-architecture` / `4`
- **Reviewer:** `gpt-6-luna`
- **Packet:** [Architecture R4 packet](keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r4-packet.md), SHA-256 `5330210ac46941fe510cbe0b123a7bb79203b05953d7f29d2015c0448d78cbcb`
- **Baseline / HEAD:** `84b9c19227330b0fe6ff391be001ee398010fd6a`
- **Assignment SHA-256 at dispatch:** `fe6a454e3fde21f01df905fc62547a2380c5358ecaea8e4e6e7ac2a6e545b84c`
- **Manifest r2 SHA-256:** `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- **Validation report SHA-256:** `f35b9e13a546450616a32c852f88e84fddfd7f638f5efc5e3a435440a2a88cde`
- **R2 usage SHA-256:** `f21c68e000f8c1265db1e39ce80598161f053d4dca3d51908814d28c6a2d45c6`
- **Artifact index SHA-256:** `80147fb5288926695569dc33f411e1e6687e1212b4a22b7ee728e7d0621151c2`
- **Recursive `.xcresult` inventory SHA-256:** `8c429cc52f0b1c020454b8646c53c6c169b2286b4dfc0fd53f8a916507ede138`

The Human Product Owner authorized dispatch of this exact frozen packet. The reviewer reported that all packet-bound repository evidence, the artifact index, the result-bundle inventory, and the eight named logs/summaries matched their frozen identities.

## Disposition

Both R4 evidence checks are complete. R1–R4 Architecture coverage supports closing `ARV5-R1-COV-02`: R4 verified the R2 usage-file identity and reconciled every one of the 30 skipped test cases against the named logs, summaries, and validation report. This closes only the Architecture review-coverage residual; it does not change the earlier R1–R3 verdicts.

## R2 usage-file identity

The file `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r2-usage-2026-09-30.md` exists, is 2,332 bytes, and hashes to `f21c68e000f8c1265db1e39ce80598161f053d4dca3d51908814d28c6a2d45c6`, matching the frozen packet. This confirms the current file identity only; it does not backfill or alter R3's historical reviewer coverage.

## RimeBridge skip reconciliation — 20 skipped

The raw log, summary, and validation report reconcile to 105 total, 85 passed, 20 skipped, and 0 failed. Each skip remains a skip.

| Report category | Skipped test case(s) | Recorded reason |
|---|---|---|
| Lua smoke (2) | `testCorrectionSidecarKeepsVisibleCompositionIntactWhenRuntimeFixtureIsProvided`; `testRimeIceLuaDynamicCandidatesWhenRuntimeFixtureIsProvided` | Runtime fixture was not provided; `UK_RIME_LUA_SMOKE_SHARED_DIR` and `UK_RIME_LUA_SMOKE_USER_DIR` are required. |
| Frozen paired matrix (1) | `testCappedTwoSyllableControllerFrozenPairedMatrix` | Immutable 40-character lowercase S4 commit identity was not provided. |
| T9 runtime matrix (9) | `testIsolatedPersonalizationKnownPositive`; `testIsolatedPersonalizationNaturalReminder`; `testIsolatedPersonalizationNaturalWeather`; `testPartialLongSelectionIsNotPersonalizationProof`; `testRejectedCompositionLaterOpportunityTransactionMatrix`; `testRollingControllerFrozenA0A1B2B3Matrix`; `testRollingControllerMissingLiveCompositionFailsClosedBeforeKey`; `testRollingControllerRealRimeDeletePathAndPartialOwnership`; `testRollingControllerRealRimeSecondRejectRestoreMatrix` | Isolated T9 Spike runtime directories were not provided. |
| T9 compatibility Spike (1) | `testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor` | `UK_RIME_T9_SPIKE_SHARED_DIR` and `UK_RIME_T9_SPIKE_USER_DIR` were not set. |
| T9 pinyin-selection Spike (6) | `test004CatalogExactRawAcceptanceOnPinnedLibrime`; `testAtomicPathDiscoveryStageAOnPinnedLibrime`; `testGate5Phase05CandidateCoverageSelRangeOnPinnedLibrime`; `testGate5Phase06AlternativeCoverageSelectionDeltaOnPinnedLibrime`; `testPrecisePinyinPathRefinementOnPinnedLibrime`; `testReadOnlyWindowCoverageForYiZiSibling` | T9 Spike runtime directories were not provided. |
| R4-B real-engine proof (1) | `testRealEngineBootstrapCreatesAndCallsOffMainThroughOwner` | T9 Spike runtime directories or the required `UK_RIME_R4B_*` configuration were not provided. |

## App + Keyboard skip reconciliation — 10 skipped

The raw log, summary, and validation report reconcile to 428 total, 418 passed, 10 skipped, and 0 failed. Each skip remains a skip.

| Report category | Skipped test case(s) | Recorded reason |
|---|---|---|
| Pinned Ice archive source (2) | `RimeIcePinnedArtifactTests.testVerifiedOfficialAndMirrorArchivesConvergeAfterProductionProcessing`; `SchemeResourcePreparationCoexistenceTests.testProductionProcessedIceTreeKeepsOfficialDefaultYamlWhenFixturePresent` | No independent downloaded-source archive was provided through `TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT`; the second case specifically requires Ice archives. |
| Installer coexistence (3) | `testCS06_UninstallInactiveWanxiangRetainsIcePeerInventory`; `testCS0910_RealInstallerIceRemovalPreservesCompleteWanxiangInventory`; `testCS0910_RealInstallerWanxiangRemovalPreservesCompleteIceInventory` | The first two lacked the fixed Wanxiang extract tree; the third lacked the fixed Ice extract tree. |
| Ice recovery (1) | `testKnownIceDefaultYamlPollutionIsRecoveredThenBuiltinRedeploySucceeds` | Ice `2026.06.30 default.yaml` fixture was not provided. |
| Unsigned-host Keychain (1) | `testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem` | The unsigned host lacks the required Keychain entitlement. |
| TD-012 physical-device-only checks (3) | `testPinnedModelLoadsThroughWanxiangGrammarOnAuthorizedPhysicalDevice`; `testRemovePinnedModelAfterAuthorizedPhysicalDeviceSpike`; `testStagePinnedModelForAuthorizedPhysicalDeviceSpike` | These require physical-device-only model-load receipt, cleanup, and staging checks, respectively. |

The separate signed Keychain integration lane reports 1 passed / 0 skipped. Its limited result does not change the unsigned-host test's skipped status.

## Residuals and boundary

- **`ARV5-R1-COV-02` — Architecture review coverage:** Owner: Architecture & Knowledge Steward / Coordinator. R4 completed the two omitted checks. Disposition: **closed as `fix`**, supported by this R4 receipt and the R1–R4 coverage record.
- **`ARV5-R1-EVID-04` — Quality evidence:** remains owned by Quality; R4 does not disposition it.
- **`V5-Q-001..003` — Product residuals:** remain pending Product disposition.
- MCP discovery reported 429 while the raw log and `.xcresult` report 428; the difference remains unexplained.

No v6 implementation or promotion, production marker emission, Maps reproduction, root-cause conclusion, behavior fix, Product/Quality/Release Gate, parent closure, or release state is established. The paired-rollout Assignment and parent diagnostic Assignment remain Active.

## Review usage

See the [R4 usage record](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r4-usage-2026-09-30.md).
