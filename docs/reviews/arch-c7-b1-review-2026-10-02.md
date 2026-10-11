# ARCH-C7-B1 独立 Architecture 静态审查

- 冻结 packet：`/private/tmp/ukey-wake-c7b-20261002/ARCH-C7-B1-packet.json`
- Packet digest：`00dff6cef7b14473d5fd0e9898b44a4241ccabf88ca98360736a145e13308aaf`，按 sorted compact JSON、UTF-8、排除 `packet_digest_sha256` 后复算一致。
- 候选身份：`9730e254cb8afd48f857ad9bef1659017fe90d26700ea3c9b1809249e3c751c8`；source manifest canonical identity 复算 `9730e254cb8afd48f857ad9bef1659017fe90d26700ea3c9b1809249e3c751c8`，匹配=true。
- 指定 worktree：`/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；52 个 allowlisted 文件逐项 SHA-256 核对全部匹配，无缺失或不一致。
- Reviewer：未参与 C7 实现；只读检查。未运行 build/test、模拟器/设备、LLDB、网络或源文件修改。

## 静态结论

A1–A3 的源代码覆盖均已完成。静态架构审查未发现足以阻止这份候选进入后续独立动态验证的材料性实现阻断；这不构成运行验收、根因结论、Product Gate、安装、Release 或 merge 结论。两个有限解释边界列为 F-01、F-02，后续读取证据必须保留。

## Criteria 覆盖

| Criterion | 覆盖 | 静态结论与依据 |
|---|---|---|
| A1 | 完整 | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardWakeOwnerProbe.swift:1-7,60-72,69-91,93-135,188-219,222-250,253-320,339-359`：探针实现仅在 DEBUG；固定 128 条记录、10 分钟 TTL、一次 arm；记录字段是 UUID 词、序号、时间、闭合 stage 码、布尔和 epoch/revision，没有文本。append 不编解码、不访问 journal/Logger、不做 I/O；freeze 在 mutex 内最多复制 128 条，编码在解锁后完成。`Keyboard/Controllers/KeyboardViewController+InputActions.swift:20-27` 只在 DEBUG+专用编译条件下包围原 insertKey 同步路径。`Universe Keyboard.xcodeproj/project.pbxproj:643` 仅列 DEBUG 默认条件，未定义 `KEYBOARD_WAKE_OWNER_PROBE`；项目/共享 scheme 的 Debug/Release 配置在 `Universe Keyboard.xcodeproj/xcshareddata/xcschemes/Universe Keyboard.xcscheme:68-100,119-140`。要启用 UI 接线需显式加该条件。注意 Debug coordinator 初始化仍在 `ThreadAffineRimeSession.swift:226-230` 取一次 coordinator ordinal，因此“默认关闭”表示未 arm、不采集记录；不能表述为完全零初始化成本。`Mutex` 是有界同步操作但不保证绝对无等待，源码只支持“不做锁内 I/O/编码/owner 等待”的结论。 |
| A2 | 完整（有界于键盘/候选栏输入触点） | `KeyboardWakeOwnerProbe.swift:60-67` 的纯 predicate 要求无活动触点、静默 2 秒，并且已观察或无候选。`KeyboardViewController+WakeOwnerProbe.swift:26-49,51-63` 维护 idle task 与 viewWillAppear/viewWillDisappear 可用状态；`KeyboardViewController.swift:381-385,479-483` 接入生命周期；`KeyboardViewController+CandidateBar.swift:149-172` 在候选刷新时重算，所以普通未 arm 且有候选时隐藏，已 arm/frozen 时可在旧候选仍存在时显示。`CandidateBarView.swift:417-462` 把 44pt 控件放在既有展开按钮左侧，展开按钮仍是 56pt；显示时只切换候选 collection 的 trailing constraint。`Keyboard/Controllers/KeyboardKeyButton.swift` 的 touch-tracking 回调与 `KeyboardViewController+KeyPressFeedback.swift:5-14` 连接键盘按键触点；`CandidateBarView.swift:438-447,703-730` 的观察器不延迟/取消触摸并清理终态。按钮首击只 arm，后续点击 freeze 并同步借用导出（`KeyboardViewController+WakeOwnerProbe.swift:75-90`），没有走 Core、proxy 或 dismiss。UIKit 手势的最终仲裁、命中测试和布局变化仍需真实 UIKit target/运行证据。 |
| A3 | 完整（仅有限同步观察，不代表 owner 线程运行） | `KeyboardViewController+InputActions.swift:20-27` 在单次同步 insertKey 周围 `beginAttempt`/defer `endAttempt`；`KeyboardViewController+WakeOwnerProbe.swift:65-72` 同步记录 appearance、coordinator 序号和 owner 指针是否存在。`ThreadAffineRimeSession.swift:226-230` 明确只读 `owner != nil`，注释也指出 readiness/epoch 缺省值不能区分 absent owner；`:414-420` 的 schedule 记录 `lastAcceptReceipt != nil` 和 epoch/revision，receipt 缺失只表示此采样没有 accept receipt，不能推出 owner 缺失或未执行。`KeyboardWakeOwnerProbe.swift:222-250,339-359` 在 expiry、记录溢出、reentrant context 或未结束 attempt 时置 incomplete；`KeyboardWakeOwnerProbeTests.swift:69-108,137-173` 将相应合同写成测试，但本 lane 没有执行测试。借用路径为 `KeyboardWakeOwnerProbe.swift:38-49` 到 `KeyboardViewController+WakeOwnerProbe.swift:83-99`：调用端在 `withUnsafeBytes` 闭包内同步进入 `@inline(never)` 出口，出口不保存地址；就当前调用路径，指针借用时间覆盖出口函数调用。公开 Snapshot API 仍依赖调用方遵守 closure 借用契约，Swift 类型系统不阻止外部闭包另行保存裸指针。 |

## 有限 Findings

- **F-01（解释边界，非材料性阻断）— `.armed` 合成记录不可作为 owner 缺失证据。** `KeyboardWakeOwnerProbe.swift:121-133` 在 `arm()` 内部先写 `.armed`，coordinator/appearance/attempt ordinal 为 0，owner/receipt 为 false；触发按钮随后在 `KeyboardViewController+WakeOwnerProbe.swift:77-80` 再同步写一条 `.armed`，带调用时刻可读到的 coordinator/owner 元数据。UI 对缺失 coordinator 也使用 `?? 0`（同文件 `:65-72`）；Core 的 `nextCoordinatorOrdinal()` 在 ordinal 溢出时也返回 0（`KeyboardWakeOwnerProbe.swift:138-147`）。因此 0/false 或 nil receipt 必须解读为“本行未提供 owner absence 证明”；ownerPresent 仅表示 MainActor 采样时 coordinator 持有 owner 引用，不代表 owner thread 正在运行、醒来或处理该 attempt。
- **F-02（触点范围边界，非材料性阻断）— 探针自身按钮的按压不进入 active-touch 集合。** `CandidateBarGestureBridge.gestureRecognizer(_:shouldReceive:)` 对探针按钮后代返回 false（`CandidateBarView.swift:48-54`），所以按住观测/取证按钮时它不会触发该观察器隐藏自身；这是让该按钮仍能完成 arm/freeze 的交互例外。键盘按键与候选栏触点仍受 predicate 管控。动态 UI 验证应覆盖候选触点、展开按钮、探针按钮、候选更新期间的布局及点击结果；若产品要求包括探针按钮自身在内的所有按压都隐藏，则本候选不满足该更强合同。

## 后续必需动态证据（本 lane 未执行）

1. **C7-B：** 绑定新的精确整合 candidate/paired identity，以 `KEYBOARD_WAKE_OWNER_PROBE` 专用 Debug 条件完成真实 `Universe Keyboard` UIKit/Extension target 编译、paired build 和对应测试；审查真实 target 的 Swift/UIKit actor 类型检查、约束和手势 wiring，并明确已有全套 Core 编译阻断处置。host 36/36 和 frontend syntax parse 不能替代此项。
2. **C7-C：** 取得新鲜且排他设备 Entry 后安装；预先 arm，再做一次直接 AppSwitcher→Maps 复现，异常后先 freeze，有限读取并解码冻结的 header/records，将 attempt、coordinator、appearance、owner/receipt 与 suspend/resume/teardown 记录逐项对齐。不要用候选选择改变现场。设备动作和 LLDB 均不属于本次授权。

Allowlisted validation 报告记录 host Core 36/36 和 parse，但同时明确真实 UIKit target、paired build、Simulator/runtime 尚未执行（`docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-owner-probe-local-validation-2026-10-02.md:27-31,43-45`）。本 Architecture lane 不把这些历史本地证据升级为运行通过或根因证明。
