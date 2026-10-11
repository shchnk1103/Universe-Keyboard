# C2 producer Entry

2026-10-01 Asia/Shanghai。C2 local implementation/Debug Simulator verification Entry satisfied only；父任务/Assignment 保持 Active。global paired Exit、promotion/Gates 未满足。

[Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c2-producer-authorization-2026-10-01.md)；[pre-edit manifest](keyboard-wake-diagnostic-extension-paired-rollout-001-c2-producer-pre-edit-manifest.json)。worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`，branch `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`。330 dirty（12 modified、318 untracked），staged empty；2427 既有文件 hash 不变，C1 五文件与 final manifest 全匹配。

| Allowed source/test/project | Pre-edit SHA256 |
|---|---|
| `Keyboard/Controllers/KeyboardViewController.swift` | `8591c5d9c7b93530bb2c5eb2a3eb000a3c53bc8133183eaa3b9a48b1be147aa8` |
| `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` | `e931105a51915084e90ef39270ebd3c3378b0d3e01dfe633d51f54293ff48db8` |
| `Keyboard/Services/UITextDocumentProxyAdapter.swift` | `f5cad10abb6b01594819cbb5dcf72a2989d389ed235364237abdfce7853b6de5` |
| `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift` | `NEW / absent` |
| `Universe Keyboard.xcodeproj/project.pbxproj` | `adc7e4a2e1fd10ede0a7e9346683b0a86dc833f8279f34db3f1f0b2b4091e1d3` |

## 当前 ACK / writer / 环境

GPT6 Luna 当前贡献作者 /root/core_stage_a 已核验四既有 allowed input SHA 与选定工作树匹配，新测试 absent；阅读 C2 packet、Keyboard UI playbook 与 lifecycle/input 必读资料。无当前五路径 scope conflict/UNKNOWN。确认默认 v5/markers off、真实四 lifecycle phase、RIME 仅 started、Debug 内存高保真+缓存 expiration、按键不读 Defaults/category、proxy 三操作保序且无文本/count/actionID；helper 同 adapter 源编入 KeyboardTests。只写指定 scratch 五文件，不独立 review、不改 repo/环境/Git，等待 Entry start。


root 承接 Human C2 AUTH，是唯一 selected repo writer；Luna 仅写隔离 scratch 五文件；apply 前核验全部 baseline（本 Assignment 阶段文档除外）与四个既有 allowed inputs，漂移即停止。当前贡献 ACK 不重分配 Keyboard Experience 永久 Domain Owner，旧 reviewer ACK 不自动绑定 C2。

root 是本轮 Environment Executor。MCP list_sims 确认精确 UDID、iOS27、Booted/available；Human 独占确认有效至本轮验证结束。沙箱 simctl list 因 CoreSimulator IPC 权限失败，MCP 主机核验成功，不据沙箱失败推定设备坏。只操作该 UDID，独立 DerivedData/xcresult；不手动安装/启动/Maps。

## 必需检查与未来依赖

五文件只含四 Swift 源/测试；strict format/lint，仅 project membership 接线、plutil 校验。focused producer suite 通过后执行实际新测试所在 Universe Keyboard scheme App+Keyboard 回归，Swift6 complete/warnings-as-errors；所有日志/结果绑定最终五文件 hash。不声明完整 paired CI/可合并，Core C1 1184/0 仅在 Core 与依赖内容不变时复用。

KeyboardTests 测试实际同一 adapter/helper 源码；生产 VC callback 接点做静态核验，运行的测试 bundle 不证明 appex callback、宿主插入、实际 session 或 Maps。未来完整 paired version binding 由 App/Data 与 Keyboard Experience 明确，独立 Architecture/Quality packet 与预算另行冻结；production opt-in/promotion、install/Maps/Release/publication仍独立授权。原30 skips不会自动变为本次通过或接受。

测试/实现需要五路径外修改、Core/RimeBridge 状态 instrumentation、reader/payload合同、生产 v6 opt-in 或不同设备时停止具体依赖部分并交 Product。
