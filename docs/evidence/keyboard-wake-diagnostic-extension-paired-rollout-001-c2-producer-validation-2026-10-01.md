# C2 Extension producer 本地候选与 Debug Simulator 验证

2026-10-01 Asia/Shanghai。[Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c2-producer-authorization-2026-10-01.md) 与 [Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c2-producer-entry-2026-10-01.md) 绑定本次五文件阶段。[最终 manifest](keyboard-wake-diagnostic-extension-paired-rollout-001-c2-producer-final-manifest.json) 记录精确最终 SHA，内容是未提交工作树候选，不能说 HEAD 已包含实现。

## 实现与边界

仅三个 Extension Swift 文件、一个新 KeyboardTests Swift 文件与工程文件的 adapter test membership。复用现有 appearanceID，在四个真实 lifecycle 边界和 resume 调用前接有限 producer；RIME 固定 started，不记录 session/schema/owner/completed/failed 推测。hostDidBecomeActive 未观测且 producer 拒绝，不添加 observer。

同一 gate 控制 lifecycle/RIME/proxy：Debug 现有高保真内存 bool、缓存的现有 expiration Date，Release context disabled。到期判断不依赖 MainActor expiration task 是否已调度；按键路径不读 Defaults/category、不编码或 I/O，category 过滤仍由原后台 ingress 完成。proxy 的 insertText/setMarkedText/unmarkText 均为 entered → 原调用 → returned；setMarkedText 原字符到 UTF16 选区转换先执行。没有文本、长度、hash、宿主上下文或新的 actionID，actionSequence 无可靠归因时 nil；observer 仅表示提交尝试，returned 不证明宿主插入/显示，suspend 可丢弃队列尾批且未改变这一合同。

生产 writer 默认仍 v5，marker off。Core 与 Main App 完全未改；临时测试显式 v6 仅写测试临时目录。KeyboardTests 编译同一 adapter/helper 源，避免链接 appex 符号；工程仅新增单一 ref/buildFile/Sources membership，不改 target/scheme/package。

## 验证结果

精确设备为 iPhone 18 Pro / iOS 27.0，UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，Human 确认本轮独占。focused 与 full .xcresult 中设备 ID/OS 匹配。四 Swift format/strict lint 通过，plutil 与 test membership 解析通过，RIME vendor 12 个 framework 结构检查通过，无 fetch/download。

- 新 producer focused：2 passed / 0 skipped / 0 failed，exit0。[summary](keyboard-wake-diagnostic-extension-paired-rollout-001-c2-producer-focused-01-summary.json)、[raw log](keyboard-wake-diagnostic-extension-paired-rollout-001-c2-producer-focused-01.log)。正例验证 11 条 v6 typed marker 实际落盘、完整身份/finite fields、四 lifecycle/RIME started、三 proxy 前后顺序及 Unicode NSRange；负例验证 closed/expired/equality/v5 gate 与原代理参数不变。负例等待普通 sentinel 真正落盘后再断言无 marker，避免异步空日志假通过。
- 完整 App + Keyboard：431 total = 421 passed + 10 skipped + 0 failed，exit0。UniverseKeyboardTests 413 total/10 skipped，KeyboardTests 18/0 skipped；新 suite 在 full 中再次2/0通过。[summary](keyboard-wake-diagnostic-extension-paired-rollout-001-c2-producer-app-keyboard-01-summary.json)、[raw log](keyboard-wake-diagnostic-extension-paired-rollout-001-c2-producer-app-keyboard-01.log)、[test inventory](keyboard-wake-diagnostic-extension-paired-rollout-001-c2-producer-app-keyboard-01-tests.json)。使用 Swift6 complete/warnings-as-errors 与 unsigned Debug，非并行，独立 DerivedData/xcresult，无手动安装/启动/交互。argv、最终 source SHA、UTC 起止、log SHA 在对应 command JSON。
- 首次 focused 构建有4条 AppIntents metadata extraction skipped 工具警告（无该 framework 依赖）；无 Swift compiler warning/error，full 增量运行无 warning/error。没有扩围去修改此工具元数据行为。
- 10 个当前 skip 的逐项原始原因在 [skip inventory](keyboard-wake-diagnostic-extension-paired-rollout-001-c2-producer-app-keyboard-01-skips.json)。它们不是通过，未自动套用 Stage B 接受，不声明本轮非阻塞 Product disposition。
- C1 full host Core 1184/0 仅按未变化内容/依赖复用；本轮没有重跑 Core。只读保全见 manifest，Core/reader/既有 tests/历史 evidence 等2422既有文件未变。最终branch/HEAD保持，staged空；无 reset/cleanup/commit/push。

## 尚未验证 / 后续

测试 bundle 调用同一源码，不证明 appex 中实际 VC callback/系统键盘生命周期/宿主显示/真实 RIME session/Maps 已执行。没有新的独立 Architecture/Quality exact-candidate review；GPT6 Luna 是作者/只读咨询贡献者，root 审阅不算独立 review。RimeBridge 独立套件、签名 Keychain focused、Release 与完整 paired CI 未执行，当前只授权 C2 Debug producer/App+Keyboard；此前20 RimeBridge skips属于历史阶段未验证内容，不是当前通过证据。

下一阶段应冻结完整配对候选：绑定 Main App/Extension 的所有实际 writer 构造路径与每条新事件同一静态版本，再取得独立评审、完整质量矩阵、同 build/安装身份及另行 promotion/install/Maps 授权。生产 v6 启用不是本轮 C2 的结果。当前10 skips需要未来 Product disposition/适用的 fixture-backed验证，不自动接受。父 Assignment/parent保持Active、根因未确认，无 Gate、可合并、Release或关闭声明。

本轮只增加诊断接线且生产仍off，不改变既有输入/恢复合同、UI或已接受ADR；不更新 CHANGELOG/架构合同，实施状态与检查点记录在 owning Assignment。未来生产集成的文档更新由该阶段决定。
