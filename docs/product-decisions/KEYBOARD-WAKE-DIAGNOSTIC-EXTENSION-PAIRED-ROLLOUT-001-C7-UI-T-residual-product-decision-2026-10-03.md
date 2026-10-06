# C7 UI 当前 T 残项 Product Decision

Status: Accepted — current T only

## Authority / Scope

2026-10-03 Human Product明确决定：「仅对当前 T 接受这 29 项为非阻塞、未验证残项。」root只记录此决定，不替代Product或独立审查者。对象为候选 `43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50` 的当前T测试验证阶段；原分支codex/keyboard-wake-v3-compatibility-gate / HEAD84b9c19227330b0fe6ff391be001ee398010fd6a，来源/产物hash-only归档前再次核对无变化。

下列20 Rime与9 AppKeyboard共29项，在当前T内接受为**非阻塞、未验证残项**。本决定不继承旧阶段处置，也不外推后续阶段或Release。

## Test accounting / preserved history

- iOS实际537条执行记录：507passed、0failed、30skipped。Rime105=85pass+20skip；AppKeyboard431=421pass+10skip；signed Keychain1=1pass。
- 原30raw skipped记录完整保留、不计通过。同一Keychain identity另轮signed通过，单列记录，不改写unsigned skip；因此当前尚未验证内容29项。
- Core1194/0/0为已独立核验可复用的host覆盖，不当作iOS/appex运行。
- T1–T6覆盖来自S-R2、P-R2与T2原因addendum；原Partial历史报告不改。本Product决定解除“当前T29残项处置缺失”这一依赖，当前T按上述固定范围收尾。
- 不授予新候选安装/运行、Maps复现、真实appex/LLDB、模拟器新窗口、commit/push/merge或Release；配对Assignment及父任务仍Active，根因仍未确认。

## Accepted unverified residuals

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

Prepared处置包保持历史原文；本文件为当前Product决定来源。
