# QUALITY-C7-B1 round 2 定点 Quality 补审

## 范围与身份

本轮仅审 R2-Q1（单行修复及断言/来源）、R2-Q2（204 文件完整 KeyboardCore host 严格测试证据）、R2-Q3（旧 C7-B1-F1 的限域处置）。packet digest `3c5552a94d940a7cc7063965d237477ec1a800eeaff6581408588993571e8333` 已按排除 `packet_digest_sha256` 后 sorted compact JSON、UTF-8、`ensure_ascii=true` 核对。26/26 内容输入和 210/210 hash-only 输入匹配；`codex/keyboard-wake-v3-compatibility-gate` / `84b9c19227330b0fe6ff391be001ee398010fd6a` 与冻结值一致。包清单含 204 个文件，工作树 Git 文件名为 204 项；均与清单相符。

## 判定

| Criterion | 覆盖 | 独立结论 |
|---|---|---|
| R2-Q1 | Covered | 单行测试类型注解修复成立；未见 fixture 内容、断言或产品源码变化。 |
| R2-Q2 | Covered | 原始完整 host XCTest 记录支持 1194 passed、0 failed、0 skipped，命令 exit 0；当前 204 文件包输入身份吻合。 |
| R2-Q3 | Covered（限域） | 可解除旧 C7-B1-F1“完整 Core suite 编译被此测试行阻断”这一单一 finding；不改变旧报告整体 Hold。 |

**finding C7-B1-F1-R2：Resolved（仅此编译阻断）**。归档单文件 diff 只把 `T9PinyinPathTests.swift:1428` 的 map 参数从推断类型改为 `(index: Int)`。修改前文件 SHA 为 `3310d5a43fabf0fa367992a858f74638c6a46fdfeb96c79e0496b3418704c316`，当前文件 SHA 与 source-test manifest 一致，为 `3c908fb727f1b83aeba8c70ef553a55013ecad3962d4a27ae785d9c9a00e152b`。行 1429 的 `RimeCandidate(... globalIndex: index)` 仍原样保留；`RimeCandidate.globalIndex` 是 `Int?`，初始化器位于 `Packages/KeyboardCore/Sources/KeyboardCore/RimeCandidate.swift:13`。固定闭包参数为 `Int` 消除插值表达式可能沿可选参数推断成 optional 的歧义，满足本轮单行修复授权。

**finding C7-B1-F1-R2-TEST：Covered**。`package-input-manifest.json` 列出 204/204 个 package 文件；逐项 SHA 匹配当前清单输入，包内文件名集合亦匹配。归档 `command.json` 指向完整 package，运行 `xcrun swift test`，保留 `-strict-concurrency=complete` 与 `-warnings-as-errors`；`full-core-test-result.json` 报 exit 0。独立对照 `full-core-test.log` 原始末端：`KeyboardCoreTests.xctest` passed，两个 XCTest 终端摘要均为 1194 tests、0 failures；`test-summary.json` 的 skip、compiler-warning、compiler-error records 均为空。这里确认的是已归档的 macOS host Core 结果，不代表本 reviewer 重跑，也不外推到 iOS/UIKit、RimeBridge、Keyboard extension 或运行时。

**遗留边界**：旧 round 1 的整体 Hold 保持原判；原 57 条 Swift 格式诊断仍相同，`lint-summary.json` 记录 after exit 1。F2/F3、SDK/Architecture 与整体 Gate 均不在本轮重审范围。实际 iOS target、安装、设备和运行时证据仍未由本轮覆盖，因此不能据此宣告整体 Gate、Product、安装或 Release 通过。

## 调用与限制

本轮 11/12 底层调用，checkpoint 在第 4 次文件调用后发送；总 elapsed 以首次 packet read/hash 时刻 `2026-10-02T07:28:28.875305Z` 到本次交付写入结束计算。Call 6 仅因读取 packet 输入字段名不匹配而返回空选择集，未扩大读取；随后按 packet 的 `allowed_content_inputs` 重新选择。未执行 build/test、Simulator/device/LLDB、network 或 repo 写入。完整逐次账本见 `usage.json`。
