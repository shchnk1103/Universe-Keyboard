---
name: keyboard-test-writer
description: Design, update, and run behavior tests for Universe Keyboard when tests are requested or a behavior change needs coverage. Select the owning Core, RimeBridge, App, or Extension target.
---

# Keyboard Test Writer

先从真实被测代码确定模块和既有测试。测试应观察行为或不变式，不能把 fake 的输出当成真实
Bridge 的解析/session 证据。读取 [REFERENCE.md](REFERENCE.md) 定位目标；需要实际模式时读
[EXAMPLES.md](EXAMPLES.md)，不要复制可能漂移的 API 声明。

| 被测边界 | 测试位置 | 必须执行的入口 |
|---|---|---|
| KeyboardCore 状态/纯逻辑 | `Packages/KeyboardCore/Tests/KeyboardCoreTests/` | `swift test --package-path Packages/KeyboardCore` |
| 真实 RimeBridge 解析/引擎合同 | `Packages/RimeBridge/Tests/RimeBridgeTests/` | iOS Simulator 的 `RimeBridgeTests` scheme |
| 主 App 模型/设置/编排 | `UniverseKeyboardTests/` | `Universe Keyboard` scheme test |
| Extension UIKit/候选交互 | `KeyboardTests/` | `Universe Keyboard` scheme test |

遵循现有 actor 隔离和 testable import；RimeBridge 为 iOS 包，不要求其在 macOS SwiftPM 运行。
Core fake 适合验证 Core 如何消费引擎结果，真实解析直接调用 Bridge 的测试入口。

合法产品/架构合同变化时可更新既有测试，并说明行为前后差异；不得删弱断言来隐藏回归。
无行为变化的文案/机械改动不强制新增镜像测试。修复 bug 时优先建立可复现失败断言。

精确 xcodebuild 参数和 merge-bound 完整门禁以根目录 `AGENTS.md` 为准；改了某测试必须运行
其实际 target。有效证据复用按 `docs/AI_WORKFLOW.md`；记录运行对象、命令、环境、结果与缺口。
