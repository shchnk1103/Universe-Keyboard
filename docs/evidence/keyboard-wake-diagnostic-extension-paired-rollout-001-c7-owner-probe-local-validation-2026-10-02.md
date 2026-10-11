# C7-A Debug owner 观测切片 — 本地交付 / M-02 同步记录

## 结论与权限

C7-A 本地实施已交付，父 Assignment 仍 Active。当前候选未通过 UIKit target 编译/交互验证或独立验收，不能安装、晋级、宣称根因/修复/完整 Gate。Human 当前“可以按这个方案继续”仅本次本地实施与隔离 Core host 验证；C7-B/C7-C 仍是另授权依赖。无模拟器、App 构建/测试、安装、arm、debugger attach、Git 发布或 Release。

## 已实现

- 独立 Debug 专用候选栏按钮放在原展开按钮左邻，原展开入口保留；普通 Debug/Release 不编入该 UI（须同时 DEBUG 与 KEYBOARD_WAKE_OWNER_PROBE）。未 arm 时有候选隐藏；arm 后停手至少 2 秒且无活跃触摸时允许旧候选仍在时取证。触摸/打字隐藏按钮，按钮点击仅 arm 或冻结/导出，不提交或清空候选、不切键盘、不恢复 owner。
- Core Debug 单实例单轮有限内存探针，默认关闭，10 分钟 monotonic TTL、128 条容量；与 Logger/journal 暂停独立。append 无编码、持久化、引擎等待；使用短 Mutex 临界区，不宣称绝对零阻塞/零开销。
- 已接 insert、schedule、suspend/resume、teardown/replacement 等边界，保留现有输入/引擎/部署行为。明确区分 owner absent 与 owner present / receipt absent。同步 attempt ordinal 不跨异步传播；重入、未完成 attempt 冻结、overflow 或 expiry 均标记不完整。
- 有限借用出口提供 Debug noinline 函数 `wakeOwnerProbeExportReady`。冻结解锁后编码/借用；实际 appex 中的符号、参数、有限读取和调试器 attach 均未验证。历史 toy fixture 导出成功不能代替本候选出口证明。

## 精确身份与验证

工作树 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`，branch `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`，保持不变。

9 文件 final source manifest：`9730e254cb8afd48f857ad9bef1659017fe90d26700ea3c9b1809249e3c751c8`。canonical 身份算法为 source-manifest JSON 在加入 identity_sha256 之前按 sort_keys / 紧凑 separators 序列化后 SHA256。它绑定本次九文件，不等于整合 dirty 树或 paired binary 身份。

| 验证 | 实际结果 / 边界 |
|---|---|
| 9 个 Swift 文件 swift-format lint --strict | 全通过，未格式化范围外文件 |
| 6 个 UI 文件启用 DEBUG+KEYBOARD_WAKE_OWNER_PROBE 与无 Debug 两次 frontend parse | 均通过；仅语法，不是 UIKit SDK 类型检查、target 编译或 Release build |
| allowlist git diff --check | 通过 |
| 首次 C7 draft 完整隔离 KeyboardCore suite（未完成 attempt 保护之前），Swift 6 complete concurrency / warnings-as-errors | exit 1，未执行断言；未改动 T9PinyinPathTests.swift:1429 的 optional interpolation 被诊断为 error。未另跑原基线，不能证明原基线必然同样失败；不改范围外文件 |
| 初次聚焦隔离 suite | exit 1，缺 FakeRimeEngine 公共 helper；仅在 scratch 加入同一原文件后重试 |
| 最终聚焦隔离 suite | **36/36 passed，0 failure，0 skip**：新增 probe 10，既有 ThreadAffineRimeSpike 10，ThreadAffineRimeWire 16 |
| 测试源码等价 | 聚焦包使用完整同一 Core 产品源码；三个测试 suite 加原 FakeRimeEngine helper。最终三份本次 Core allowlist 文件与工作树逐字节一致。未修改 package manifest/业务源码以绕过类型错误 |
| App + Keyboard / RimeBridge / paired Debug / Release / Simulator / runtime | 本阶段未执行，需 C7-B/C7-C；旧 30 skips 仍 unverified，不计本阶段通过 |

实际 host 为 arm64 macOS，工具为当前 Xcode 的 Swift；不将 host Core 通过称作 iOS RimeBridge 或 UIKit 通过。新增测试覆盖 default-off/one-shot、同步 attribution、TTL、overflow、frozen immutability/borrow、closed stage、owner/receipt 区分、reentrant invalidation、unfinished attempt、UI 纯 predicate。既有 thread-affine tests 验证原行为；它们没有 arm shared probe，不能替代真实接线观测证明。

Transport v1 是 11 个 UInt64 header + 每 event 11 个 UInt64，最多 1419 words / 11352 bytes。header 包括 magic/version/incomplete/run与process UUID/armedAt/expiresAt/count/overflow。event 为 seq/time/stage/coordinator/appearance/attempt/ownerPresent/receiptPresent/teardown/epoch/revision。`arm()` 自带第一条 synthetic armed（ordinal/owner 均默认零），UI 随后再写当前上下文 armed；第一条不是 owner absent 的运行证据。只有实际非零 coordinator、非零同一 attempt 的 schedule 及配对 insert 边界才可用于后续判定；receipt absent 单独不足以证明 owner absent。不捕获输入、候选、host 内容、指针身份或文本 fingerprint。

## 保全与文档影响

本次 9 个源码/测试路径外的既有文件逐 hash 保全（仅 parent Assignment 是本轮授权治理改动）；基线 2610 个非忽略文件、520 dirty。完整前后状态、最终计数与新增路径在 artifacts preservation.json 和 after-status.txt。无既有删除，staged entries 前后均零；HEAD/branch 不变。root 唯一 repo writer，Luna 仅 scratch Core 起草助手，非独立 reviewer。

本记录、当前 plan/authorization/Entry 和 Assignment 状态构成本次一次性 M-02 同步；不递归生成 receipt。CHANGELOG 不更新：仅未晋级 Debug 诊断候选，无用户发布；未改 journal wire / RIME 部署合同，不新增 ADR，本阶段 finite transport/UI 合同在 plan 和本记录中冻结。C6 历史证据、原 skip/review/恢复残项不改写。

## 剩余依赖与建议

C7-B（Current Codex Environment Executor + 原 Architecture/Quality 角色）：先冻结整合 candidate，取得新 exact review packet 和预算，编入专用 flag，执行真实 UIKit target / paired build / 必需套件，明确全 Core 编译阻断处置；新环境操作须 fresh exact-device exclusive Entry。C7-C（同 Environment Executor + Human）：另授权安装/出口验证及单次直接 AppSwitcher→Maps 复现，预先 arm，异常后先冻结，不通过候选选择改变现场。完整内存 packet 读取、按 attempt 对应与有限解码仍待实证。

建议下一步 C7-B；当前不继续模拟器，也不自动修复范围外测试。

[当前 Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-owner-probe-local-entry-2026-10-02.md) · [计划](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-owner-probe-local-slice-2026-10-02.md) · [授权](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c7-owner-probe-local-authorization-2026-10-02.md) · [源码 manifest](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-local-artifacts/source-manifest.json) · [最终聚焦测试](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-local-artifacts/focused-test-final.log) · [全套阻断](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-local-artifacts/core-test.log) · [本地检查](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-local-artifacts/local-checks.json) · [保全](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-local-artifacts/preservation.json)。
