# C7-A local Entry — 2026-10-02

当前阶段：Ready / Active for C7-A local implementation；精确Core scope ACK已取得，源码编辑从本Entry确认后开始。Human授权与阶段顺序按本次C7计划，旧C6/Subreview/skip保持历史。

- selected worktree/branch/HEAD核对一致：paired-rollout-preflight/Universe Keyboard / codex/keyboard-wake-v3-compatibility-gate /84b9c19227330b0fe6ff391be001ee398010fd6a。
- dirty完整基线520、非忽略2610逐文件hash，scratch /private/tmp/ukey-wake-c7-implementation-20261002/before-*。
- root唯一仓库writer；live collaboration子代理仅Core scratch起草，无仓库写许可。当前未发现本任务其他activewriter，不能据此断言跨线程系统全局无writer。
- root Keyboard Experience scope ACK：仅Debug UI/probe接线；入口单独并排、原expand保留，touch/gesture隐藏不改变Core；任何实际布局/手势/routing回归需C7-B target evidence，不能由Corehost代替。
- Core scope ACK：复用Luna实现助手 /root/c7_core_probe 已读新C7计划/授权/Entry并确认“接受它们限定的 Debug-only、单实例单轮 Core 探针边界”；接口/隐私/并发/生命周期/停止条件绑定当前packet。原scratch-only ACK保持历史，新ACK仅C7-A本地，不代父GlobalExit或独立Gate。
- UI指南/输入架构/KeyboardUI及Core手册已路由；memory只作导航，live身份已验证。
- A不依赖Simulator，仅Corehostisolated本地验证；B/C负责实际UIKit target/paired identity/reviews/出口/安装/复现，当前都未授权，owner Current Codex+各review角色/Human。

源码/测试allowlist（仅这些9路径；原dirty逐文件保全）：
- Packages/KeyboardCore/Sources/KeyboardCore/KeyboardWakeOwnerProbe.swift
- Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift
- Packages/KeyboardCore/Tests/KeyboardCoreTests/KeyboardWakeOwnerProbeTests.swift
- Keyboard/Controllers/KeyboardViewController.swift
- Keyboard/Controllers/KeyboardViewController+InputActions.swift
- Keyboard/Controllers/KeyboardViewController+KeyPressFeedback.swift
- Keyboard/Controllers/KeyboardViewController+CandidateBar.swift
- Keyboard/Controllers/KeyboardViewController+WakeOwnerProbe.swift
- Keyboard/Views/CandidateBar/CandidateBarView.swift

新文档计划/授权/本Entry，以及parent Assignment当前阶段修订是本轮治理范围，未改permanent团队职责。最终保全核验报告所有9路径之外原2610文件无改（治理allowlist除外），无stage/commit/push。

## C7-A 收尾

本地实现交付，final nine-file identity `9730e254cb8afd48f857ad9bef1659017fe90d26700ea3c9b1809249e3c751c8`。最终聚焦host Core 36/36 passed；全套draft编译阻断未消除，UI仅syntax parse/format，C7-A不是父GlobalExit。无实际UIKit target或设备动作，B/C仍未授权。最终保全与完整状态见[交付](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-owner-probe-local-validation-2026-10-02.md)及其artifacts。
