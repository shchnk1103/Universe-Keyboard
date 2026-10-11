# C2 KeyboardCore 可执行性咨询（只读）

范围限定为现有 `KeyboardTests`、`KeyboardExtensionTests`、Xcode project/schemes、`UITextDocumentProxyAdapter` 及 Keyboard UI playbook。未构建、未运行测试或模拟器，未改 repo/scratch 源码。本结果是 C2 可执行性咨询，不是 reviewer 或代码授权。

## 结论

按当前工程拓扑，现有 `KeyboardTests` 不能链接或执行 Extension 内的 adapter/producer。`KeyboardExtensionTests` 是现有 Extension 相关测试入口，但当前只证明测试 bundle 可加载；它刻意不引用任何 appex 符号。静态证据不支持把它当成可调用 Extension 二进制内部符号的 XCTest host。因此，若要让 XCTest 实际执行 `UITextDocumentProxyAdapter` 或真实 Extension producer，当前 target/scheme 配置还不足；本咨询没有通过构建或运行来验证 linker 行为。

## 依据

- `Keyboard` 是 `com.apple.product-type.app-extension`，通过 file-system-synchronized `Keyboard` 根目录编入源码。`UITextDocumentProxyAdapter.swift` 在该目录下，是 `@MainActor` 的 internal 类型，依赖 UIKit 和 KeyboardCore；`KeyboardViewController+Bootstrap.swift:138` 在 Extension bootstrap 中实例化它。见 `Universe Keyboard.xcodeproj/project.pbxproj:93-100,247-269`、`Keyboard/Services/UITextDocumentProxyAdapter.swift:25-40`。
- `KeyboardTests` 的同步根目录只有 `KeyboardTests/`，target 无 target dependency，Frameworks phase 只链接 `KeyboardCore`，Debug/Release 的 `TEST_HOST` 都为空。其 package product dependency 也只有 KeyboardCore。见 `project.pbxproj:111-115,164-170,319-340,999-1052`。`Universe Keyboard` scheme 会运行 `KeyboardTests`，但它不会把 Keyboard Extension 模块加入该测试 target；见 `Universe Keyboard.xcscheme:74-96`。
- `KeyboardExtensionTests` 有 Extension target dependency，Frameworks phase 明确引用 `Keyboard.appex`，自身是 unit-test bundle，`TEST_HOST` 与 `BUNDLE_LOADER` 为空，`TEST_TARGET_NAME=Keyboard`。专用 `KeyboardExtensionTests` scheme 把该测试 bundle 列为唯一 testable。见 `project.pbxproj:179-185,365-386,571-575,1105-1152`、`KeyboardExtensionTests.xcscheme:40-57`。
- 它现有唯一测试 `CandidatePrefetchUIContractTests` 写有 `@testable import Keyboard`，但测试明确避免引用 appex symbol，并说明 app extension 不是可链接的 XCTest host；测试只检查自身 bundle identifier。见 `KeyboardExtensionTests/CandidatePrefetchUIContractTests.swift:3,5-10`。因此 `@testable import` 和 appex 的 Frameworks 条目不能单独证明 adapter/producer 符号可被 XCTest 实际调用。
- 当前 `Keyboard/` 没有对 C1 新增 `recordKeyboardLifecycle`、`recordRimeResume` 或 `recordTextProxyOperation` 的调用点；C1 final manifest `/private/tmp/ukey-wake-c1-20260930/applied-file-hashes.json` 中五个 KeyboardCore 文件的 SHA-256 与选定工作树当前文件全部匹配。Core API/Runtime 的测试可以继续由 KeyboardCore package tests 执行，但这不等于 Extension producer 已被执行。
- Keyboard UI playbook 将 UIKit keyboard presentation/lifecycle wiring 归 UI 领域，要求 focused UI/contract test 的 Simulator 证据；system-keyboard/lifecycle 等行为还需要设备证据。该 playbook 不改变 appex 与 XCTest 的链接边界。

## 最小工程调整路径

为了在 XCTest 中执行 adapter 源码，当前最小调整是把 `Keyboard/Services/UITextDocumentProxyAdapter.swift` 显式加入 `KeyboardTests` 的 Sources（通过 project 文件添加该文件到该 target 的编译 membership）。`KeyboardTests` 已链接 KeyboardCore，iOS unit-test target 可导入 UIKit；测试以 fake `UITextDocumentProxy` 保持其生命周期并直接验证委托和 range 转换。这会在 `KeyboardTests` 模块中编译同一 adapter 源码，不需要把 `.appex` 当 XCTest host，也不要求新增 package dependency。它证明该源码实现可执行，不证明 Extension binary 中的实例或 bootstrap wiring 已运行。

若目标是验证 producer helper，可把不依赖 `KeyboardViewController` 私有状态的有限 producer 逻辑放入同一可共享源码区，并同时编入 Keyboard 与 KeyboardTests；测试调用该 helper，验证它调用 C1 typed Runtime API 的参数、origin/expiry gate 和顺序。Extension 内真实生命周期 callback 到 helper 的 wiring 仍要由 Extension-host / Simulator 或设备证据覆盖。仅向现有 scheme 增加 testable 条目不会使 appex 成为 XCTest host，也不会执行尚未接入 Keyboard 的 producer call site。
