# 当前T Product残项处置包（Prepared）

状态：待Human Product明确决定，非接受回执。

建议仅对当前T测试验证阶段，将下列29项接受为非阻塞、未验证残项；原30skip记录全部保留，Keychain同identity另轮signed1pass单列，均不据此主张Release或新候选runtime。当前独立T1–T6覆盖增量组合已齐，整体T仍Hold直到Product决定。

| Suite | 未验证用例 | 历史跳过原因 |
|---|---|---|
| Rime | `RimeLuaSmokeTests/testCorrectionSidecarKeepsVisibleCompositionIntactWhenRuntimeFixtureIsProvided()` | Test skipped - Set UK_RIME_LUA_SMOKE_SHARED_DIR and UK_RIME_LUA_SMOKE_USER_DIR to run the real Lua smoke test. |
| Rime | `RimeLuaSmokeTests/testRimeIceLuaDynamicCandidatesWhenRuntimeFixtureIsProvided()` | Test skipped - Set UK_RIME_LUA_SMOKE_SHARED_DIR and UK_RIME_LUA_SMOKE_USER_DIR to run the real Lua smoke test. |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testCappedTwoSyllableControllerFrozenPairedMatrix()` | Test skipped - Set the immutable 40-character lowercase S4 commit to run the paired matrix. |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testIsolatedPersonalizationKnownPositive()` | Test skipped - Set isolated T9 Spike runtime directories to run this matrix. |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testIsolatedPersonalizationNaturalReminder()` | Test skipped - Set isolated T9 Spike runtime directories to run this matrix. |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testIsolatedPersonalizationNaturalWeather()` | Test skipped - Set isolated T9 Spike runtime directories to run this matrix. |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testPartialLongSelectionIsNotPersonalizationProof()` | Test skipped - Set isolated T9 Spike runtime directories to run this matrix. |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testRejectedCompositionLaterOpportunityTransactionMatrix()` | Test skipped - Set isolated T9 Spike runtime directories to run this matrix. |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerFrozenA0A1B2B3Matrix()` | Test skipped - Set isolated T9 Spike runtime directories to run this matrix. |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerMissingLiveCompositionFailsClosedBeforeKey()` | Test skipped - Set isolated T9 Spike runtime directories to run this matrix. |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerRealRimeDeletePathAndPartialOwnership()` | Test skipped - Set isolated T9 Spike runtime directories to run this matrix. |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerRealRimeSecondRejectRestoreMatrix()` | Test skipped - Set isolated T9 Spike runtime directories to run this matrix. |
| Rime | `RimeT9CompatibilitySpikeTests/testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor()` | Test skipped - Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 compatibility Spike. |
| Rime | `RimeT9PinyinSelectionSpikeTests/test004CatalogExactRawAcceptanceOnPinnedLibrime()` | Test skipped - Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. |
| Rime | `RimeT9PinyinSelectionSpikeTests/testAtomicPathDiscoveryStageAOnPinnedLibrime()` | Test skipped - Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. |
| Rime | `RimeT9PinyinSelectionSpikeTests/testGate5Phase05CandidateCoverageSelRangeOnPinnedLibrime()` | Test skipped - Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. |
| Rime | `RimeT9PinyinSelectionSpikeTests/testGate5Phase06AlternativeCoverageSelectionDeltaOnPinnedLibrime()` | Test skipped - Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. |
| Rime | `RimeT9PinyinSelectionSpikeTests/testPrecisePinyinPathRefinementOnPinnedLibrime()` | Test skipped - Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. |
| Rime | `RimeT9PinyinSelectionSpikeTests/testReadOnlyWindowCoverageForYiZiSibling()` | Test skipped - Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. |
| Rime | `ThreadAffineRimeRealEngineTests/testRealEngineBootstrapCreatesAndCallsOffMainThroughOwner()` | Test skipped - Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR (or UK_RIME_R4B_*) to run R4-B real-engine proof. |
| AppKeyboard | `RimeIcePinnedArtifactTests/testVerifiedOfficialAndMirrorArchivesConvergeAfterProductionProcessing()` | Test skipped - Set TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT to the independently downloaded source archives |
| AppKeyboard | `SchemeResourcePreparationCoexistenceTests/testCS06_UninstallInactiveWanxiangRetainsIcePeerInventory()` | Test skipped - CS09-10-01 requires the fixed Wanxiang extract tree |
| AppKeyboard | `SchemeResourcePreparationCoexistenceTests/testCS0910_RealInstallerIceRemovalPreservesCompleteWanxiangInventory()` | Test skipped - CS09-10-01 requires the fixed Wanxiang extract tree |
| AppKeyboard | `SchemeResourcePreparationCoexistenceTests/testCS0910_RealInstallerWanxiangRemovalPreservesCompleteIceInventory()` | Test skipped - CS09-10-01 requires the fixed Ice extract tree |
| AppKeyboard | `SchemeResourcePreparationCoexistenceTests/testKnownIceDefaultYamlPollutionIsRecoveredThenBuiltinRedeploySucceeds()` | Test skipped - Ice 2026.06.30 default.yaml fixture is required for P3 fingerprint recovery |
| AppKeyboard | `SchemeResourcePreparationCoexistenceTests/testProductionProcessedIceTreeKeepsOfficialDefaultYamlWhenFixturePresent()` | Test skipped - Set TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT to the independently downloaded Ice archives |
| AppKeyboard | `TD012LMDGDeviceStagingTests/testPinnedModelLoadsThroughWanxiangGrammarOnAuthorizedPhysicalDevice()` | Test skipped - TD-012 G2 model-load receipt is physical-device-only |
| AppKeyboard | `TD012LMDGDeviceStagingTests/testRemovePinnedModelAfterAuthorizedPhysicalDeviceSpike()` | Test skipped - TD-012 G2 cleanup is physical-device-only |
| AppKeyboard | `TD012LMDGDeviceStagingTests/testStagePinnedModelForAuthorizedPhysicalDeviceSpike()` | Test skipped - TD-012 G2 staging is physical-device-only |

不授权重跑、真机验证、新候选安装、Maps复现或Release。是否接受由Human决定。
