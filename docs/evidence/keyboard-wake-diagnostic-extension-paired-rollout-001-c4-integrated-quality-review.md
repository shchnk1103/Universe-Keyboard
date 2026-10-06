# Q-C4 独立 Quality Review

**结论：Blocker。** Q1–Q6 均已完成证据覆盖；当前唯一 Quality 阻塞是冻结的 30 个 skipped case 没有本阶段 Human Product 接受。这里的 Blocker 是处置未获授权，不表示审查覆盖不完整，也不把 skipped 计为通过。旧 Stage B 的接受不带入本轮。Architecture R3 属于并行评审，不替代本结论。

## 范围与身份

本次为未参与实现的独立 Quality review。冻结 packet：/private/tmp/ukey-wake-c4-20261001/quality-packet.md，SHA-256 175b4a059e8cc87daeab63a14f0583873f853c8019b9b25102b8ab3a5b1710c4。输入清单：/private/tmp/ukey-wake-c4-20261001/quality-input-manifest.json，SHA-256 12677b893a67d942777e16202f8e2e7fa62ae38656b1524928cddf9351887851。Candidate manifest SHA-256 af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9；仓库固定在 /Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard，HEAD 84b9c19227330b0fe6ff391be001ee398010fd6a。输入清单 64/64 项、568 个 source/build 输入及 34 个 review target 均匹配冻结哈希。

| Criterion | 结论 | 独立核对 |
|---|---|---|
| Q1 身份、冻结输入与环境 | Covered | 所有上述输入与哈希匹配。冻结 candidate manifest 记录 dirty_total=365、staged=0；评审时只读 status 为 368 行、staged=0。root 说明冻结后增加的 3 行是授权的 Entry、candidate、Architecture 文档记录；这是阶段证据追加，不是 source 漂移。 |
| Q2 质量命令与结果 | Covered | 17 个 Swift 文件的 format 与 strict lint 共 34 项均 exit 0，scratch 格式化副本逐个与源文件字节一致；KeyboardCore 1184 tests、0 failures；RimeBridge 105 tests、20 skipped、0 failures；App+Keyboard 431 tests、10 skipped、0 failures；signed Keychain test 1/1/0；Release build exit 0。原始日志有两条非致命 AppIntents metadata 提取警告，结构化 warningCount 为 0；原日志说明因无 AppIntents.framework dependency 而跳过提取。 |
| Q3 v6 行为与目标覆盖 | Covered | Core 原始日志确认 v6 reader/validator、混合 V3/V4/V5、incomplete/rejected records、默认 V5 gate、marker 写入及 decoded-payload 重检等指定用例通过。App+Keyboard 的 DiagnosticsLogSource 测试覆盖 V6 完整/不完整、混合历史、rejected-only 与 legacy fallback；producer/adapter 测试覆盖 lifecycle、RIME resume、proxy 前后 marker、Unicode 与 V5/closed/expired gates。target membership 已核对。测试注入 proxy/runtime 不等于真实 UIInputViewController callback 或实际运行写入，见下方限制。 |
| Q4 skip inventory 与处置 | Covered，Blocker | 冻结 skip-inventory 的 30 项身份、test-tree Skipped 状态及 raw skip notice 与日志逐项吻合；具体原因见冻结 inventory。CS0910 映射为：Ice removal 用例缺 Wanxiang tree；Wanxiang removal 用例缺 Ice tree。当前 Entry/summary 明确没有沿用旧 30-skip 接受，且标为 unverified、无当前阶段 Product acceptance。故不得将 30 项视为通过，且这是唯一实质阻塞。 |
| Q5 paired products | Covered | Debug/Release MainApp 与 appex 的实际 executable 和 Info.plist 文件存在且哈希吻合；四项 pair 均同源。MainApp ID 为 com.DoubleShy0N.Universe-Keyboard，appex ID 为 com.DoubleShy0N.Universe-Keyboard.Keyboard，均 version 1.0/build 1。actual installed=false、actual_appex_callback_validated=false。 |
| Q6 设备与授权边界 | Covered | 矩阵固定 UDID 405D994F-28CB-4F89-BB22-B64AD81C05A2；测试 destination 一致。独占窗口收据结束于 2026-10-01T00:13:00.077225Z；之后不再执行 Simulator 操作。manual install、diagnostics arming、Maps 均为 false；此窗口不可复用。 |

## 阻塞与非声明

C4-Q-01（Blocker）：本阶段 30 个 skip 没有 Human Product 接受。解除方式是对当前精确 skip 集取得本阶段接受，或经另行授权完成 fixture-backed 验证；本审查没有替代接受或重跑授权。完整原因与逐项 locator 见冻结文件 /private/tmp/ukey-wake-c4-20261001/skip-inventory.json。

ADR 0036 Addendum 002 说明 Foundation JSONDecoder 无法暴露重复 JSON member occurrence；本结论不声称实现重复成员检测。产物哈希和测试不证明已安装身份、真实 appex callback、默认 runtime 写入或 marker 的实际设备发射；也不代表 Gate、Release、已安装或生产运行时验收。