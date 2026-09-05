# 可执行示例的来源

示例直接引用仓库已编译的测试，避免第二份 API 或行为合同漂移：

- Core candidate 行为：[CandidateKindTests](../../../Packages/KeyboardCore/Tests/KeyboardCoreTests/CandidateKindTests.swift)。
- Bridge keycode/engine 合同：[RimeEngineContractTests](../../../Packages/RimeBridge/Tests/RimeBridgeTests/RimeEngineContractTests.swift)。
- Bridge 输出解析与 T9：[RimeT9PinyinSelectionSpikeTests](../../../Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9PinyinSelectionSpikeTests.swift)，搜索 `parseOutputDictionary`。
- App settings：[RimeSettingsStoreTests](../../../UniverseKeyboardTests/RimeSettingsStoreTests.swift)。
- Extension 候选：[CandidateModelContractTests](../../../KeyboardTests/CandidateModelContractTests.swift)。

选择与当前行为和 target 相同的例子，读取其 setup、隔离和 imports。只增加当前合同需要的
断言；不要将历史样例的内部实现或硬编码数量提升为通用要求。
