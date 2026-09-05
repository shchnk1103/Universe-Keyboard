# 测试目标与真实接口

按被测模块按需读取，不维护一份复制的 Swift API。

- Core 引擎接口：[RimeEngine.swift](../../../../Packages/KeyboardCore/Sources/KeyboardCore/RimeEngine.swift)。
- Core controller 场景：[CandidateKindTests.swift](../../../../Packages/KeyboardCore/Tests/KeyboardCoreTests/CandidateKindTests.swift)。从测试实际引用定位 fake，不推测路径或方法签名。
- Bridge 输出解析：[RimeEngineImpl+Output.swift](../../../../Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+Output.swift)，`parseOutputDictionary` 是无 live session 的解析入口。
- Bridge 测试：[RimeEngineContractTests.swift](../../../../Packages/RimeBridge/Tests/RimeBridgeTests/RimeEngineContractTests.swift)；真实 T9 fixture 见同目录 spike tests。
- App：[RimeSettingsStoreTests.swift](../../../../UniverseKeyboardTests/RimeSettingsStoreTests.swift)。
- Extension：[CandidateModelContractTests.swift](../../../../KeyboardTests/CandidateModelContractTests.swift)。

Swift 并发与可见性以实际源码和 target 配置为准。Core 无 iOS 依赖的测试与 Bridge iOS
Simulator 测试是不同证据层；通过前者不证明后者。
