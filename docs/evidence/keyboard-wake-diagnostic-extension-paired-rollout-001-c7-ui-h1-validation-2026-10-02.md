# C7 UI 新候选 H1 host 验证

Human授权“执行H1吧”。root仅执行generic Simulator SDK专用Debug standalone配对构建及最终产物核验；本轮没有源文件修改、测试、设备实例操作、安装、LLDB或Maps。父子Assignment继续Active，H1 bounded Exit完成；不代表安装许可或整体Gate/Release。

## 身份与构建

沿[H1 Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h1-entry-2026-10-02.md)，原worktree/branch/HEAD一致。571 source/build输入及630 Vendor文件构建前后逐项相同；Swift源仍是已冻结UI接线修复，不重用旧候选digest。

Xcode27.0/27A266a、iPhoneSimulator SDK27.0、Apple Swift6.4编译器。结构化argv保持literal $(inherited)，Swift语言6、warnings-as-errors、DEBUG及KEYBOARD_WAKE_OWNER_PROBE实际编译行确认。SWIFT_STRICT_CONCURRENCY=complete为请求设置，实际swiftc行未输出单独-strict-concurrency=complete；[Swift官方说明](https://www.swift.org/blog/announcing-swift-6/)确认Swift6语言模式以编译错误检查潜在数据竞争。未声称不存在的显式flag，也未降低设置或重跑。

实际构建UTC15:29:01.892432至15:29:38.251863，36.359522秒、exit0。xcresult build-results为succeeded、errors0/warnings0/analyzerWarnings0，目标Any iOS Simulator Device。完整xcresult留private scratch `CandidateBuildHost.xcresult`；归档其只读摘要/读取receipt及实际build日志。MCP另任务defaults保持不动，使用冻结host CLI，不访问模拟器实例。

## 新候选字节绑定

新candidate SHA256 `43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50`；78文件payload digest `784c05694e420d3cab5187160c463066070fbdbd72b1c053cd39f3e6fe422aca`。digest规则与四项binding字段完整记录在paired-products.json；不是source canonical digest或旧runtime候选。

主App/appex bundle分别com.DoubleShy0N.Universe-Keyboard及其.Keyboard，版本1.0/build1。无xctest/test-host；6个arm64 MachO逐项SHA/UUID解析与dwarfdump一致；Keyboard.debug.dylib有观测UI及唯一出口相关符号。App/appex codesign --verify --deep --strict均exit0。

两份最终可执行文件__TEXT,__entitlements完整原始字节分别等于本轮对应Simulated.xcent，AppGroup均group.com.DoubleShy0N.Universe-Keyboard，application identifier匹配各自bundle。codesign展示的普通签名entitlements为空dict，不把它误报为Simulator嵌入AppGroup缺失。此核验不证明runtime权限/Keychain。

本轮没有独立dSYM；完整MachO UUID及现有调试dylib身份已保存，未来LLDB能力仍须新现场核验。scratch MachO解析器首次header偏移错误已修正，原脚本及repair receipt保留；只修证据工具，无源码变更/重构建。显式strict字符串断言首次失败同样如实记录，后以实际Swift6模式和官方语义区分，不倒写原事实。

## 边界与后续

[H1 artifacts](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h1-artifacts/)提供command/input manifest/log/xcresult摘要/payload/UUID/签名/权限原字节及preservation证明；完整构建产物留 `/private/tmp/ukey-wake-probe-ui-candidate-20261002/CandidateDerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app`。

下一建议H2 host普通Debug/Release隔离验证，再进行Q新candidate独立绑定评审；两者需对应阶段授权。T实际套件需fresh独占和测试前完整备份，I需另一次安装前备份及健康读回，U/M分别授权。当前没有按钮时延改善或Maps根因结论。旧Partial、预算超时、30skip及数据损失历史保留；无commit/push/Release/Gate/Close，CHANGELOG/架构合同无需改动。
