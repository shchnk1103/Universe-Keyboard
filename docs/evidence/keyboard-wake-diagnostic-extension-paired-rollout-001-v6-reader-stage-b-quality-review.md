# 独立 Quality Review：Stage B reader candidate r2

WorkItem：`KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`；lane：`UK-WAKE-V6-B-QUALITY`；round：1。结论为 **Partial / incomplete**。本轮已逐项检查 Q1–Q7，但不授予 Quality Pass、full gate、Product Gate、Release 或父任务关闭。Stage B 当前 30 个 skip 尚无适用的书面风险处置；历史 v5 acceptance 不适用于本候选。Architecture 独立评审仍为 Partial，不能由本 Quality 评审代替。

## Scope 与候选身份

冻结 packet SHA-256：`07a9be61cf49eddfb4b623d34ff7a49caee71aa5294289a6e73873150a6a0557`（与 sidecar 一致）。`quality-inputs.json` 共 63 项；本轮逐项复算为 missing=0、mismatch=0。候选位于 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`；candidate-r2 的五个实现/测试文件均与其 SHA 相符（5/5），七个只读依赖均相符（7/7）。候选记录为 production writer v5、production wake markers=false。Stage B 修复只在 test-owned temporary fixture 中为 `g1/open` 创建父目录后写 fixture；最终测试源码仍绑定 candidate-r2。

执行器授权记录绑定 iPhone 18 Pro / iOS 27.0 / UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，Human 确认本次验证窗口独占该设备。结果命令使用同一个 UDID、独立 DerivedData 与关闭并行 simulator clone；CI 的 `iPhone 17 Pro` 在本机不可用时使用该已授权设备。Stage B 实际顺序是 RimeBridgeTests、App focused、App + Keyboard full Debug、signed Keychain focused、Release build。所有 r2 命令都带 `-collect-test-diagnostics never`，只停止失败后的 Xcode sysdiagnose 收集等待；target 与测试断言保持执行。

## Evidence Matrix

| Claim | Review result | Evidence and boundary |
|---|---|---|
| Q1 精确身份与授权 | Covered | packet/input digest、candidate HEAD/五文件与七依赖 SHA、writer v5/marker off，以及上述 Human 独占 UDID 与命令绑定均核对。 |
| Q2 格式与 CI 等价验证 | Covered | Stage B Entry 记录七个 Swift 文件 strict lint；strict-lint 记录冻结（7 行）。Stage A host `swift test --package-path Packages/KeyboardCore` 对相同 Core 输入/依赖执行 1181 项、0 failures；Stage B 只复用该证据。CI 等价的四个 Simulator gate 命令与当前 workflow 参数/target 对照。 |
| Q3 bundle、legacy、tree、日志计数 | Covered | 六个冻结 `.xcresult` inventory 全部逐文件复核：2608 文件，missing=0、mismatch=0；提取的 metrics 与 case status、raw log 的通过/跳过结论一致。Rime 105 total / 85 pass / 20 skip；App full 429 / 419 / 10；focused v6 test 1/1 pass；signed Keychain 1/1 pass；Release build exit 0。429 属 Stage B 本次执行，含新增 v6 test，不沿用 v5 计数。 |
| Q4 新 v6 App query 与失败保留 | Covered | `testV6HistoriesPropagateCompletenessThroughCompositeQuery` 覆盖并通过 `v6-only`、`mixed-complete`、`v6-incomplete`、`mixed-incomplete`、`rejected-only` 五个 scenario；focused 与 full r2 均通过。首次 full App 仍保留 fixture `NSCocoaErrorDomain` Code 4（缺少 `g1/open` 路径）和 xcodebuild exit -15；诊断收集等待后被 SIGINT 再 SIGTERM 终止的记录按失败保留，不计成功。 |
| Q5 30 个当前 skip 与风险处置 | Covered as inventory; disposition open | 下方逐个列出身份、原因和边界。它们不构成通过覆盖；v5-only acceptance 不继承至 Stage B。风险接受/非阻塞 disposition 归 Human Product Owner。 |
| Q6 配对产物与非声明 | Covered | Debug/Release App + Keyboard extension 四个可执行文件当前 SHA 均与 paired-binaries 记录相符（4/4）；结果树冻结如上。vendor 当前 630 个文件 hash：匹配=630，missing=0，mismatch=0；receipt 与 manifest digest 分别为 `32b81905629e811067cfc8dfcd8b1548cce6e4a92433a885aba3ed8e0beeca83` / `a67cf99046a180c9e648755c793182529f2937f3d0469e3b59d6f63638802804`。这不等价于与未保留的原始 archive 做独立逐字节比对。 |
| Q7 Residual matrix 与 Architecture | Covered as boundary | duplicate JSON member detection limitation 仍存在。Architecture R1/R2 均为 Partial；R2 只覆盖 AS1，AS2–AS6 未覆盖，预算已耗尽；fixture 修复后的 AS4 未得到 Architecture 复审。本 lane 不替代或推断该结论。 |

## Passed

- 五个 Stage B r2 gates 的 `.xcresult` / raw log 都记录 exit 0：RimeBridgeTests、App focused v6 test、App + Keyboard full Debug、signed Keychain test、Release build。full App 的 v6 方法也在整套运行中通过。
- r2 输入 metrics 与逐用例状态汇总：RimeBridgeTests=ok, AppV6Focused-r2=ok, AppKeyboardTests-r2=ok, SignedKeychain-r2=ok；Rime 与 App full 共 30 项 skip，0 failures。
- 原始 fixture 失败和 exit -15 保留；它没有被改写成成功证据。`-collect-test-diagnostics never` 后重跑时，focused 与 full target 均有独立 frozen result bundle。

## Failed / Blocked

- 无当前 r2 gate 失败。初次 App full run 失败于 test fixture 的 `g1/open` 父目录缺失，随后诊断收集挂起；矩阵记录 exit -15。修正发生在测试临时目录准备路径，不能把首次失败并入成功统计。
- Release build 是 Debug Simulator 配置对应的构建验证，未形成签名推广、手工安装、真实设备行为或 Release authorization 证据。

## Skipped With Reason

以下是当前 Stage B 的 30 个 skip。相同原因按组展示，但每个 test identifier 均列出。它们是环境条件或物理设备范围的 skip，不是通过结果；本轮未下载 fixture，也未重新部署。

| Suite / test identifiers | Recorded reason and scope |
|---|---|
| RimeLuaSmokeTests：`testCorrectionSidecarKeepsVisibleCompositionIntactWhenRuntimeFixtureIsProvided()`；`testRimeIceLuaDynamicCandidatesWhenRuntimeFixtureIsProvided()` | 缺少隔离 runtime fixture 的 `UK_RIME_LUA_SMOKE_SHARED_DIR` 与 `UK_RIME_LUA_SMOKE_USER_DIR`；真实 Lua smoke 未执行。 |
| RimeT9AutoAnchorRetryMatrixTests：`testCappedTwoSyllableControllerFrozenPairedMatrix()` | 缺少 immutable 40-character lowercase S4 commit；冻结配对矩阵未执行。 |
| RimeT9AutoAnchorRetryMatrixTests：`testIsolatedPersonalizationKnownPositive()`；`testIsolatedPersonalizationNaturalReminder()`；`testIsolatedPersonalizationNaturalWeather()`；`testPartialLongSelectionIsNotPersonalizationProof()`；`testRejectedCompositionLaterOpportunityTransactionMatrix()`；`testRollingControllerFrozenA0A1B2B3Matrix()`；`testRollingControllerMissingLiveCompositionFailsClosedBeforeKey()`；`testRollingControllerRealRimeDeletePathAndPartialOwnership()`；`testRollingControllerRealRimeSecondRejectRestoreMatrix()` | 缺少隔离 T9 Spike runtime directories；这些真实 runtime personalization/controller matrix 未执行。 |
| RimeT9CompatibilitySpikeTests：`testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor()` | 缺少 `UK_RIME_T9_SPIKE_SHARED_DIR` / `UK_RIME_T9_SPIKE_USER_DIR`；T9 compatibility Spike 未执行。 |
| RimeT9PinyinSelectionSpikeTests：`test004CatalogExactRawAcceptanceOnPinnedLibrime()`；`testAtomicPathDiscoveryStageAOnPinnedLibrime()`；`testGate5Phase05CandidateCoverageSelRangeOnPinnedLibrime()`；`testGate5Phase06AlternativeCoverageSelectionDeltaOnPinnedLibrime()`；`testPrecisePinyinPathRefinementOnPinnedLibrime()`；`testReadOnlyWindowCoverageForYiZiSibling()` | 缺少隔离 T9 Spike runtime directories；真实 pinned-librime selection / coverage Spike 未执行。 |
| ThreadAffineRimeRealEngineTests：`testRealEngineBootstrapCreatesAndCallsOffMainThroughOwner()` | 缺少 `UK_RIME_T9_SPIKE_SHARED_DIR` / `UK_RIME_T9_SPIKE_USER_DIR`（或 `UK_RIME_R4B_*`）；real-engine proof 未执行。 |
| RimeIcePinnedArtifactTests：`testVerifiedOfficialAndMirrorArchivesConvergeAfterProductionProcessing()` | 缺少由独立下载的来源 archive；archive convergence 未执行。 |
| RimeSyncModelTests：`testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem()`（unsigned full App run） | unsigned host 缺 Keychain entitlement；独立 signed Simulator lane 同一测试通过，故该集成行为有该 lane 的单用例证据，但原 full-suite skip 仍按记录保留。 |
| SchemeResourcePreparationCoexistenceTests：`testCS06_UninstallInactiveWanxiangRetainsIcePeerInventory()` | 缺少固定 Wanxiang extract tree。 |
| SchemeResourcePreparationCoexistenceTests：`testCS0910_RealInstallerIceRemovalPreservesCompleteWanxiangInventory()`；`testCS0910_RealInstallerWanxiangRemovalPreservesCompleteIceInventory()` | 缺少固定 CS09-10-01 对应的 Ice / Wanxiang extract tree；真实安装器 inventory 共存验证未执行。 |
| SchemeResourcePreparationCoexistenceTests：`testKnownIceDefaultYamlPollutionIsRecoveredThenBuiltinRedeploySucceeds()` | 缺少 Ice 2026.06.30 `default.yaml` fixture；P3 fingerprint recovery 未执行。 |
| SchemeResourcePreparationCoexistenceTests：`testProductionProcessedIceTreeKeepsOfficialDefaultYamlWhenFixturePresent()` | 缺少 `TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT` 指向的独立 Ice archives；processed tree 对照未执行。 |
| TD012LMDGDeviceStagingTests：`testPinnedModelLoadsThroughWanxiangGrammarOnAuthorizedPhysicalDevice()`；`testRemovePinnedModelAfterAuthorizedPhysicalDeviceSpike()`；`testStagePinnedModelForAuthorizedPhysicalDeviceSpike()` | 这些分别是模型加载、清理、staging 的授权物理设备专用测试；本轮只有 Simulator window，未执行。 |

上述 30 项中，v5 历史 disposition 仅属于 v5 验证，不适用于本轮。除 signed Keychain 单例另有当前 r2 通过证据外，其余条件性/设备性 coverage 仍待 Human Product Owner 对 Stage B 作明确处置；该处置不能由本 reviewer 推定。

## Release Decision

**Partial / incomplete；不授予 passed coverage 或 full gate。** 当前自动化 r2 gates 成功，但 30 个 Stage B skips 无适用的书面残余风险处置；Architecture AS2–AS6 也仍未覆盖。没有代码/生产 writer 扩围、fixture 获取、设备重部署、Maps/root-cause/performance/Release/发布或 Gate 声明。duplicate JSON member detection limitation 应留在 residual matrix 中。

## Owner Handoffs

- Human Product Owner：决定当前 Stage B 30 个 skip 的适用风险 disposition；不得援引 v5-only acceptance 替代。
- Architecture lane owner / Product Owner：在新授权与输入 digest 下完成 Architecture AS2–AS6，尤其复核 fixture 修复后的 AS4。R1/R2 的 Partial 状态保持原样。
- Quality / Test Release owner：只有获得 Stage B 适用的 residual dispositions 后，才可基于本 review 重新判断 Quality acceptance；不得把本结论解释为 Release 或 parent closure。

Next minimal handoff：将本 `quality-review.md` 与 `quality-usage.json` 作为冻结 Quality lane 输出交回 Coordinator；Coordinator 继续保持 Assignment Active 并保留 Gate / Release / parent closure 的非声明。
