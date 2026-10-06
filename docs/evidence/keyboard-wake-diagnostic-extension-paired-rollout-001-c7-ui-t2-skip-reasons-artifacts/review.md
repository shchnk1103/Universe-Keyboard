# T2 skipped 用例原因独立补审（round 1）

- Packet whole-file SHA-256：`8b3e01f005f69a01bd74463c9aa34dc4d72532fe7088b87c5784c834cec2f72e`；canonical self digest：`fdb84ba3bf412f3d64b1fb11df8b45c4f49204469891bebfc6a165df99d335ea`（声明值 `fdb84ba3bf412f3d64b1fb11df8b45c4f49204469891bebfc6a165df99d335ea`）。
- Baseline branch/HEAD 与 packet 匹配：True。allowlist：43 项，摘要漂移：0。
- Scope：仅补审 T2 的 unsigned suites skipped 原因；使用冻结 xcresult index 记录，没有调用 xcresulttool 或读取用户备份原内容。

## 判定：Covered

逐项闭环 30/30：索引详情文件 SHA-256 均由冻结 allowlist 约束；每条同时核对 `Test Case Run`=`Skipped`、Test Identifier 与原 20+10 skip 清单、Simulator UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，并从 `Test skipped - …` 节点取原因。

| Suite | Test Case | Skipped 原因 | Evidence index |
|---|---|---|---|
| AppKeyboard | `RimeIcePinnedArtifactTests/testVerifiedOfficialAndMirrorArchivesConvergeAfterProductionProcessing()` | Set TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT to the independently downloaded source archives | `AppKeyboard-943035445a10ecee.json` |
| Rime | `RimeLuaSmokeTests/testCorrectionSidecarKeepsVisibleCompositionIntactWhenRuntimeFixtureIsProvided()` | Set UK_RIME_LUA_SMOKE_SHARED_DIR and UK_RIME_LUA_SMOKE_USER_DIR to run the real Lua smoke test. | `Rime-967c91bf68efaed5.json` |
| Rime | `RimeLuaSmokeTests/testRimeIceLuaDynamicCandidatesWhenRuntimeFixtureIsProvided()` | Set UK_RIME_LUA_SMOKE_SHARED_DIR and UK_RIME_LUA_SMOKE_USER_DIR to run the real Lua smoke test. | `Rime-371b95ca919c8def.json` |
| AppKeyboard | `RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem()` | Unsigned host lacks Keychain entitlement; signed Simulator lane covers integration. | `AppKeyboard-0de0da0f21b8fb82.json` |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testCappedTwoSyllableControllerFrozenPairedMatrix()` | Set the immutable 40-character lowercase S4 commit to run the paired matrix. | `Rime-b73c1cd2dad07151.json` |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testIsolatedPersonalizationKnownPositive()` | Set isolated T9 Spike runtime directories to run this matrix. | `Rime-b6f73a5bef26d382.json` |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testIsolatedPersonalizationNaturalReminder()` | Set isolated T9 Spike runtime directories to run this matrix. | `Rime-1486019404fdbb48.json` |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testIsolatedPersonalizationNaturalWeather()` | Set isolated T9 Spike runtime directories to run this matrix. | `Rime-4838ed1ee2171974.json` |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testPartialLongSelectionIsNotPersonalizationProof()` | Set isolated T9 Spike runtime directories to run this matrix. | `Rime-7f4f523378eeda14.json` |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testRejectedCompositionLaterOpportunityTransactionMatrix()` | Set isolated T9 Spike runtime directories to run this matrix. | `Rime-a2ce149367777eec.json` |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerFrozenA0A1B2B3Matrix()` | Set isolated T9 Spike runtime directories to run this matrix. | `Rime-c9c1d794c56064bf.json` |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerMissingLiveCompositionFailsClosedBeforeKey()` | Set isolated T9 Spike runtime directories to run this matrix. | `Rime-9a1f2a49fd4c02af.json` |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerRealRimeDeletePathAndPartialOwnership()` | Set isolated T9 Spike runtime directories to run this matrix. | `Rime-5924ec3f526f5e61.json` |
| Rime | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerRealRimeSecondRejectRestoreMatrix()` | Set isolated T9 Spike runtime directories to run this matrix. | `Rime-6cb7135c181d5f39.json` |
| Rime | `RimeT9CompatibilitySpikeTests/testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor()` | Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 compatibility Spike. | `Rime-b43defb182096ef7.json` |
| Rime | `RimeT9PinyinSelectionSpikeTests/test004CatalogExactRawAcceptanceOnPinnedLibrime()` | Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. | `Rime-24e901a3509489ca.json` |
| Rime | `RimeT9PinyinSelectionSpikeTests/testAtomicPathDiscoveryStageAOnPinnedLibrime()` | Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. | `Rime-1f9b6446ee72cdf3.json` |
| Rime | `RimeT9PinyinSelectionSpikeTests/testGate5Phase05CandidateCoverageSelRangeOnPinnedLibrime()` | Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. | `Rime-2f76fad856d96299.json` |
| Rime | `RimeT9PinyinSelectionSpikeTests/testGate5Phase06AlternativeCoverageSelectionDeltaOnPinnedLibrime()` | Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. | `Rime-9a369d02e2ff785d.json` |
| Rime | `RimeT9PinyinSelectionSpikeTests/testPrecisePinyinPathRefinementOnPinnedLibrime()` | Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. | `Rime-75a2f7b6f8012ed5.json` |
| Rime | `RimeT9PinyinSelectionSpikeTests/testReadOnlyWindowCoverageForYiZiSibling()` | Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike. | `Rime-4d13bc82b079d75d.json` |
| AppKeyboard | `SchemeResourcePreparationCoexistenceTests/testCS06_UninstallInactiveWanxiangRetainsIcePeerInventory()` | CS09-10-01 requires the fixed Wanxiang extract tree | `AppKeyboard-421a6c26b48046a1.json` |
| AppKeyboard | `SchemeResourcePreparationCoexistenceTests/testCS0910_RealInstallerIceRemovalPreservesCompleteWanxiangInventory()` | CS09-10-01 requires the fixed Wanxiang extract tree | `AppKeyboard-f26a949dfd152ebe.json` |
| AppKeyboard | `SchemeResourcePreparationCoexistenceTests/testCS0910_RealInstallerWanxiangRemovalPreservesCompleteIceInventory()` | CS09-10-01 requires the fixed Ice extract tree | `AppKeyboard-b252be64f884ca6c.json` |
| AppKeyboard | `SchemeResourcePreparationCoexistenceTests/testKnownIceDefaultYamlPollutionIsRecoveredThenBuiltinRedeploySucceeds()` | Ice 2026.06.30 default.yaml fixture is required for P3 fingerprint recovery | `AppKeyboard-ae65643df52a5a30.json` |
| AppKeyboard | `SchemeResourcePreparationCoexistenceTests/testProductionProcessedIceTreeKeepsOfficialDefaultYamlWhenFixturePresent()` | Set TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT to the independently downloaded Ice archives | `AppKeyboard-a5dd875793e60275.json` |
| AppKeyboard | `TD012LMDGDeviceStagingTests/testPinnedModelLoadsThroughWanxiangGrammarOnAuthorizedPhysicalDevice()` | TD-012 G2 model-load receipt is physical-device-only | `AppKeyboard-7629bc812ea00008.json` |
| AppKeyboard | `TD012LMDGDeviceStagingTests/testRemovePinnedModelAfterAuthorizedPhysicalDeviceSpike()` | TD-012 G2 cleanup is physical-device-only | `AppKeyboard-d57ad2f9e1bb3f5d.json` |
| AppKeyboard | `TD012LMDGDeviceStagingTests/testStagePinnedModelForAuthorizedPhysicalDeviceSpike()` | TD-012 G2 staging is physical-device-only | `AppKeyboard-9761a713e6721e05.json` |
| Rime | `ThreadAffineRimeRealEngineTests/testRealEngineBootstrapCreatesAndCallsOffMainThroughOwner()` | Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR (or UK_RIME_R4B_*) to run R4-B real-engine proof. | `Rime-7bc9fb5734150f44.json` |

## Findings and ownership

- `T2-SKIP-REASONS-001` — 原 S-R2 review 所述原因缺口由逐项 index 记录闭合：Covered。severity: evidence traceability; owner: Quality reviewer (this bounded reason check).
- 所有 30 项仍是 skipped，不计入通过。另行签名的同名 Keychain continuation pass 不改写 AppKeyboard 原 skipped 状态。
- Product Lead 仍需决定未验证 skipped work 的处置；其余 29 项 Product disposition 保持 open，Overall T 继续 Hold。
- Coverage 仅表示 T2 skip-reason gap；不改变 T1/T3–T6 状态或整体 Quality/Product Gate。
- 未执行 build/test/device/Simulator/install/LLDB/network 操作。
