# F3 Architecture 独立实现审查（round 1）

**结论：Partial / incomplete。当前候选尚不适合进入另行授权的 F4。** 冻结 packet SHA-256：`34a37a0b8f3dbeba81b015c78985adc295c69440f0f913bc5a18d2ad108cb281`。审查只覆盖 `lanes.architecture` 与包内 F0→F3 五文件 diff/精确源码输入；未参加 Grok 实施，未读 1156 项 hash-only 输入的内容。

| 条款 | 覆盖 | 独立判断 |
|---|---|---|
| A1 状态合同、ADR0002、范围边界 | Covered | gate 为 MainActor 内存决策；按当前 presentation generation/context 配对 pending；Core canary状态不复制进 gate，也没有恢复 composition 的新路径。五文件 diff 未扩到 Core、RIME 部署或 I/O。 |
| A2 实际接线、canary许可、首帧和交错 | **Uncovered** | 双通知同 context 过滤；visibilitySuspended 先取得 `beginVisibilityResume()`，许可后才调用 shared resume，并保留 owner-ready/`markCanaryReady` fail-closed 顺序。**但首帧回调未与其 display-link/presentation generation 绑定，旧 target 回调在新 gate 已重臂时无法被识别为旧事件；隐藏/无窗口 `viewDidAppear` 也会无条件尝试 arm gate。**现有代码与17个gate测试不足以证明 late/cancelled/hidden 事件不会进入当前首帧路径。 |
| A3 五文件范围与 XCTest/pbx 能力 | Covered（静态） | gate 源显式加入 `KeyboardTests` Sources，Keyboard appex 由同步 `Keyboard` 组纳入；17个测试方法断言 gate action/count。测试注释明确不证明真实通知投递、controller 接线或runtime恢复。没有运行任何测试。 |

关键 finding `A2-F1`：`KeyboardFirstFrameDisplayLinkTarget.displayLinkDidFire` 只把控制器交给共享 tick handler，未传入 link 或 generation 身份；handler只检查当前 `rimeFirstFrameDisplayLink != nil`，gate的 `handleFirstFrameElapsed` 也没有 armed-token 参数。新旧 display-link 的回调因此无法由当前候选区分。另 `viewDidAppear` 在 action 不是 shared resume 时总会调用 `activateRimeRuntimeAfterKeyboardPresentation()`，而该函数本身不检查当前 presentation phase/window。窗口检查可阻止后续不可见时的 owner activation，但无法替代按当前世代拒绝旧 tick 的约束。

最小下一步：在现有五文件范围内为首帧 arm/tick传递并核对当前 generation/token；只接受当前 arm 的两次 tick，重臂前/展示失效后的旧 tick必须 no-op；`viewDidAppear` 仅在 gate确认当前可见窗口后启动首帧门。补充测试覆盖 resign 后 active 前旧 tick、重臂后旧 target tick、hidden/no-window 不 arm，以及当前 token恰好两次才完成。修订后需冻结新候选并做独立静态复审，再决定是否进入 F4。

真实系统通知 object/投递、Maps回归、owner/receipt运行证据仍未验证；本审查不声称这些已修复。R1/R2设计结论不替代本实现审查，也未在此重开。
