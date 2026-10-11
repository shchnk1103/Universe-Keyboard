# 两项签名readout收尾（Human 已批准）

目标：补齐同一成功编译产物的 embedded Keyboard 签名 verify/display，关联已通过的 parser 和 Simulator entitlement 读取。

工具准备：新私有输出目录内 runner 全文 ast.parse、mock 两命令成功、首失败停止、报告 JSON roundtrip 及真实固定输入预检均已通过。release/consume 绑定脚本哈希；旧错误脚本/Consumed AUTH/失败回执不修改。

执行：只读 `/usr/bin/codesign --verify --strict <固定 Keyboard.appex>`，然后 `/usr/bin/codesign --display --entitlements :- <同一 Keyboard.appex>`；仅一次，最多2调用，300秒命令轮。任何失败停止、不自动重试。前后核对83固定输入（74产物+9原始证据）；同22源码、HEAD/index与原编译关联。

不重build、不测试产品、不改源码或签名、不使用模拟器、不追main、不发布/merge/Capture/Gate/父Close。结论仅Executor-recorded产物metadata；之后runtime/observer/采集及29skip仍保持各自未验证边界。无需CHANGELOG或ADR改动。
