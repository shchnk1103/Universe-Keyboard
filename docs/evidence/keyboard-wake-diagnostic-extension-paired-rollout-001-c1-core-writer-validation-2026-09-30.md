# C1 Core writer/API 本地验证

Human 仅授权 C1 五文件切片。选定工作树 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；分支 `codex/keyboard-wake-v3-compatibility-gate`；HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`。

[Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c1-core-writer-authorization-2026-09-30.md)、[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c1-core-writer-entry-2026-09-30.md)、[最终 manifest](keyboard-wake-diagnostic-extension-paired-rollout-001-c1-core-writer-final-manifest.json)绑定本地未提交内容；不是 HEAD 已包含实现的声明。

## 最终变化

仅四个既有 Core source 与一个新 Core test。静态 writer selector 默认 v5，经 Runtime → Ingress → Journal 传递；显式 v6 将新增普通事件及 typed payload/typo/health 统一写成 v6，且拒绝把 decoded v3/v4 历史事件重新标成 v6。三个 typed marker API 仅 Extension/v6 可提交，固定 code/level/category/空 fields，RIME phase/failure 成对校验；generic Runtime record 不允许 marker。返回 Bool 仅表示投递尝试，不保证落盘。

v6 encoded batch 在后台 writer 经当前 WireValidator 复核后才进入 I/O；默认 v5、公有 Event 默认构造、reader 3/4/5/6、原队列/锁/生命周期/背压合同保持。没有新增通用 count/duration 数值范围限制；草拟期间这项建议被撤回，最终文件和证据以 corrected focused 与最终 manifest 为准。

生产 Main App / Extension 不含显式 v6 opt-in；Extension marker producer 仍未启用。WireValidator、既有 reader tests、App/Extension/工程及历史证据未改，完整保存检查见 manifest。所有测试使用临时目录；没有真实 App Group 或 Simulator 操作。

## 已执行验证

- corrected focused：`DiagnosticsJournalV6WriterTests` **3 tests / 0 failures**。覆盖默认 v5 拒绝 marker、Main App 拒绝 marker、显式 v6 通过 Runtime/Ingress 落盘、既有 payload/typo/health 保留、appearance/action/localSequence/sessionEpoch max、混合 3/4/5/6 历史与旧 segment 字节不变、历史事件重写拒绝、非法 decoded route payload 后台拒绝。
- root full host `swift test`：**1184 tests / 0 failures**，无 filter。显式隔离 build/cache/config/security/module 路径；argv/env overrides、起止 UTC、退出码、最终五文件 SHA 与 log SHA 在 [full command](keyboard-wake-diagnostic-extension-paired-rollout-001-c1-core-writer-full-core-command.json)。[完整输出](keyboard-wake-diagnostic-extension-paired-rollout-001-c1-core-writer-full-core.log)。这是 host Core package 证据，不是 iOS paired CI。
- full 编译出现只读既有 `Tests/KeyboardCoreTests/T9PinyinPathTests.swift:1429` optional 字符串插值警告；该文件 hash 未变，本轮不扩围修改。host 命令没有 warnings-as-errors，因此此结果不能冒充完整 Swift 6 CI 质量门。
- 五个最终文件 strict swift-format lint 通过：[root lint](keyboard-wake-diagnostic-extension-paired-rollout-001-c1-core-writer-final-lint.log)。作者格式化与 corrected lint 原始记录同时保存。
- 首轮 focused 曾失败：非法 route 已正确拒绝，测试却假定写入拒绝后 `g1/open` 仍存在；修正断言为目录未创建后通过。[首轮日志](keyboard-wake-diagnostic-extension-paired-rollout-001-c1-core-writer-focused-test.log)保留，未覆盖失败记录。后续通用字段数值限制草稿已撤回，不属于最终候选。
- focused 仅显式指定 scratch build 路径，并产生用户 cache 只读警告；不声明其用户 cache 完全隔离。root full 的隔离范围以 command JSON 为准。

## 限制与后续

C1 没有独立 Architecture/Quality candidate review；复用 GPT6 Luna 作者不构成独立 review。此前 Stage B reviewer verdict 绑定旧内容，不能替代 C1 评审。RimeBridge、App + Keyboard、Release/Xcode、Simulator、安装和 Maps 未执行：当前范围仅 Core host。Stage B 的 30 skips 仍是历史阶段已接受的未验证残项，不成为 C1 通过证据，不自动沿用。

下一步 C2 Extension producer / paired integration 需单独精确范围和 Entry，另行绑定 Main App/Extension writer 版本、producer 接点与独立评审/环境证据。Assignment/parent 保持 Active；无 Gate、Release、可合并或关闭结论，无 Git 暂存/提交/推送。生产集成未启用且 wire 合同未变，本轮不更新 CHANGELOG/新增 ADR；需要时随另行授权的集成阶段更新。
