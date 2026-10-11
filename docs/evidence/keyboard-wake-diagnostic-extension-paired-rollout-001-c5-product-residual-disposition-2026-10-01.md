# C5 专属 Product 残项决定 — 2026-10-01

## Authority / Scope / Decision

Human Product Owner 对紧邻的明确问题“仅对当前C5，将30项skipped接受为非阻塞、未验证残项，仍不记为通过”回复“同意”。本记录是**当前C5、精确候选的新的阶段专属 `accept`**，不是复用C4-only接受；不授权晋级/安装/启动/设置/诊断采集/输入/设备操作。无需重跑测试或为了数量差异验证。

| Field | Binding |
|---|---|
| Work Item | KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001 |
| Stage | 当前C5最小Debug配对晋级／安装／受控真实callback计划；执行另行授权 |
| Candidate | `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9` |
| Branch / HEAD | `codex/keyboard-wake-v3-compatibility-gate` / `84b9c19227330b0fe6ff391be001ee398010fd6a` |
| Full Debug payload manifest SHA256 | `28a47d2d7bf669ec3927dbf62112be268dd2bd6c161d11d59a7e0e545fcaa89a` |
| Frozen30skip inventory SHA256 | `bba5d6f7ad913d54e82fc2bc9a43fc5119fa20177a352753f7c560fccd929e30` |
| C5-P round2 manifest SHA256 | `56d6c3b4875712dee712ef93c7e691fd0bf905cbdfd555b96539bed006e34f15` |
| C5-P round2 report SHA256 | `b75deed87f460abbafc54c9b7f144ed773e195bbbcfbaf005a9fcd572baa459f` |
| Disposition | `accept`：非阻塞、未验证；20RimeBridge+10App仍Skipped，不是passed |
| Authority / owner | Human Product Owner / Product Lead；Environment/Quality负责证据和未来核验 |

## Evidence / Risks / Boundaries

[C5-P round2](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-p-r2-validation-2026-10-01.md)已在3/4工具、237.973/300秒内完成D1–D3，解释skip对受控暴露的影响。部分真实RIME／fixture环境残项与后续resume路径有关；本决定接受其当前未验证风险，不补齐fixture或证明runtime readiness。

本轮先核实指定worktree/branch/HEAD、436dirty（19tracked+417untracked、staged0）、前轮report/usage/timer/validation、568source/build及111Debug文件完全不变；30/30原记录仍Skipped。签名Keychain单独通过不改变对应unsigned skip状态。原C5-P round1超时Partial、Architecture身份呈现／计数限制、duplicate-member检测限制和所有历史结果保持原样。

仅关闭C5P-Q-01及C5P-R2-01的**C5专属残项接受依赖**；不代替Product晋级／安装执行授权或其他Entry。C5-I/R仍未授权NotReady，需新的精确设备独占窗口和安装后11Mach-O/配对身份、FullAccess/AppGroup/RIME/宿主核验，再按阶段授权采集；当前没有设备窗口、已安装配对或真实callback证明。本决定不自动延伸到后续候选/阶段、Maps、Release或父Assignment关闭，也不构成整体QualityPass/ProductGate/ReleaseGate。

[原inventory](keyboard-wake-diagnostic-extension-paired-rollout-001-c4-integrated-skip-inventory.json)为不可变来源；以下仅列精确身份及未验证状态，不复制或改写原结果。

| Suite | Exact case identifier | Status |
|---|---|---|
| RimeBridgeTests | `RimeLuaSmokeTests/testCorrectionSidecarKeepsVisibleCompositionIntactWhenRuntimeFixtureIsProvided()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeLuaSmokeTests/testRimeIceLuaDynamicCandidatesWhenRuntimeFixtureIsProvided()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9AutoAnchorRetryMatrixTests/testCappedTwoSyllableControllerFrozenPairedMatrix()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9AutoAnchorRetryMatrixTests/testIsolatedPersonalizationKnownPositive()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9AutoAnchorRetryMatrixTests/testIsolatedPersonalizationNaturalReminder()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9AutoAnchorRetryMatrixTests/testIsolatedPersonalizationNaturalWeather()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9AutoAnchorRetryMatrixTests/testPartialLongSelectionIsNotPersonalizationProof()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9AutoAnchorRetryMatrixTests/testRejectedCompositionLaterOpportunityTransactionMatrix()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerFrozenA0A1B2B3Matrix()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerMissingLiveCompositionFailsClosedBeforeKey()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerRealRimeDeletePathAndPartialOwnership()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerRealRimeSecondRejectRestoreMatrix()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9CompatibilitySpikeTests/testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9PinyinSelectionSpikeTests/test004CatalogExactRawAcceptanceOnPinnedLibrime()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9PinyinSelectionSpikeTests/testAtomicPathDiscoveryStageAOnPinnedLibrime()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9PinyinSelectionSpikeTests/testGate5Phase05CandidateCoverageSelRangeOnPinnedLibrime()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9PinyinSelectionSpikeTests/testGate5Phase06AlternativeCoverageSelectionDeltaOnPinnedLibrime()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9PinyinSelectionSpikeTests/testPrecisePinyinPathRefinementOnPinnedLibrime()` | Skipped / 未验证 |
| RimeBridgeTests | `RimeT9PinyinSelectionSpikeTests/testReadOnlyWindowCoverageForYiZiSibling()` | Skipped / 未验证 |
| RimeBridgeTests | `ThreadAffineRimeRealEngineTests/testRealEngineBootstrapCreatesAndCallsOffMainThroughOwner()` | Skipped / 未验证 |
| AppKeyboardTests | `RimeIcePinnedArtifactTests/testVerifiedOfficialAndMirrorArchivesConvergeAfterProductionProcessing()` | Skipped / 未验证 |
| AppKeyboardTests | `RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem()` | Skipped / 未验证 |
| AppKeyboardTests | `SchemeResourcePreparationCoexistenceTests/testCS06_UninstallInactiveWanxiangRetainsIcePeerInventory()` | Skipped / 未验证 |
| AppKeyboardTests | `SchemeResourcePreparationCoexistenceTests/testCS0910_RealInstallerIceRemovalPreservesCompleteWanxiangInventory()` | Skipped / 未验证 |
| AppKeyboardTests | `SchemeResourcePreparationCoexistenceTests/testCS0910_RealInstallerWanxiangRemovalPreservesCompleteIceInventory()` | Skipped / 未验证 |
| AppKeyboardTests | `SchemeResourcePreparationCoexistenceTests/testKnownIceDefaultYamlPollutionIsRecoveredThenBuiltinRedeploySucceeds()` | Skipped / 未验证 |
| AppKeyboardTests | `SchemeResourcePreparationCoexistenceTests/testProductionProcessedIceTreeKeepsOfficialDefaultYamlWhenFixturePresent()` | Skipped / 未验证 |
| AppKeyboardTests | `TD012LMDGDeviceStagingTests/testPinnedModelLoadsThroughWanxiangGrammarOnAuthorizedPhysicalDevice()` | Skipped / 未验证 |
| AppKeyboardTests | `TD012LMDGDeviceStagingTests/testRemovePinnedModelAfterAuthorizedPhysicalDeviceSpike()` | Skipped / 未验证 |
| AppKeyboardTests | `TD012LMDGDeviceStagingTests/testStagePinnedModelForAuthorizedPhysicalDeviceSpike()` | Skipped / 未验证 |

## Preservation / Handoff

root sole repo writer，仅追加owningAssignment、新增本决定及[保存凭据](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-disposition-final-receipt.json)。其余既有文件逐项保持，不创建工作树、不暂存/提交/推送、不改源码、不测试/build、不发现或操作Simulator、不安装/启用诊断/输入/Maps。下一步需要Human单独授权[C5-I最小安装核验切片](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-real-appex-promotion-install-slice.md)，并取得fresh exclusive window；本轮无需新增review预算或自动补审。父Assignment保持Active。
