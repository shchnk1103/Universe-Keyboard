# F3 Quality 未覆盖项增量复核（round 2）

结论：**Pass with conditions**。本轮只补 Q1、Q2、Q4 与 Q5 依赖。Q3 和 A2 按冻结 packet 既有状态保留，不重审。该结论仅表示当前候选的 Quality 证据可进入另行授权的单轮诊断 F4；不表示 whole-F3、Architecture、F4 Ready、Maps 修复或 Release 通过。

冻结 packet SHA-256：`0847ea019ee4f35cbd4e265bd925243714a9be849241972d64b672fa8d36dad4`。Worktree 身份匹配 `codex/keyboard-wake-v3-compatibility-gate` / `84b9c19227330b0fe6ff391be001ee398010fd6a`。精确 allowlist 的 2,472 个文件大小与 SHA-256 全部匹配，其中 Swift/Vendor 仅读字节计算哈希、未读其源码内容。当前 input-check 记录 1,156/1,156 source rows、13/13 pinned inputs、4/4 原始日志、staged=0；匹配本 packet 身份。

本轮以修复 reader 的只读解析逻辑核验既有 xcresult、日志及收据，输出 `reader-output.json`（SHA-256 `fac15dae68e7183d39f51b3e5a8dfefd4cb03fdb8bcd4350510eaae6d9cdc161`）。为遵守 hash-only 源码边界，未执行 reader 中附带的 Swift 测试源码片段读取；该可选片段不参与以下方法/结果、skip 或日志核验。未运行测试、构建、lint 或 Simulator。

## Q1 — 当前候选、格式与 Gate：Covered

当前 1,156 条输入与 13 个 pinned inputs 的计数、零 staged 状态及 branch/HEAD 与冻结候选相符；完整 allowlist 哈希复算均匹配。strict Swift lint 收据的命令包含 `lint --strict`，exit 0、timeout=false，空日志与收据一致；未重跑 lint。当前 `KeyboardHostLifecycleRecoveryGateTests` 的 23 个实际方法与 required-gate-methods 集合及既有 23 项实际结果逐项相符，23/23 Passed、0 Skipped、0 Failed。四个目标 Swift 实际编译和零 Swift 诊断沿用前一轮独立 A2-4 结论；本轮不重审 A2 内容或源码。

## Q2 — 当前矩阵、30 项 Skip 与 Release build：Covered

只读现有结果得到：KeyboardCore 1,194 tests、0 failures；RimeBridge 105 项（85 Passed、20 Skipped、0 Failed）；App+Keyboard 454 项（444 Passed、10 Skipped、0 Failed），其中上述 23 个 Gate 方法全 Passed；签名 Keychain lane 1/1 Passed；Release 原始日志含 `** BUILD SUCCEEDED **`（第 1405 行），这里只证明 build，不是 Release 发布或运行。

reader 将 RimeBridge 的 20 个实际 skip methods/messages 与历史允许列表逐项比较为匹配，将 App 的 10 个实际 skip methods/messages 同样逐项比较为匹配；总计正好是授权的同 30 项。Human 授权仅适用于当前 F3 与后续单轮 F4：这些项是非阻塞、未验证、不得计为通过、不得用于 Release；出现新增 skip/fail 必须停止。本结论没有把它们转成通过。

## Q4 — 有界日志分类与 F4 影响：Covered with residual

reader 按 runtime inventory 的精确哈希和行号核对 19 条已定位日志及测试上下文：

- Rime 错误 3 条。A2-V-2 第 1697 行的 `essay` 只读打开错误落在 `testDeploymentServiceObservesRealTerminalSuccessAndFunctionalSchema` 中，该测试随后 Passed（0.079s）。第 1910、1911 行是同一个 malformed-schema negative fixture 的 YAML parse / invalid-schema 两条记录，位于 `testRealDeployerFailsClosedForMalformedSchema`，该测试随后 Passed（0.014s）。
- IOHID loader error 8 条及 factory companion 8 条，位于 App+Keyboard 与 signed Keychain 两份日志的已定位区段。App 区段紧邻 `testCanonicalCopyBoundariesRemainNonEmpty` 的 Passed 结果；Keychain 区段紧邻 signed Keychain 测试 Passed（0.038s）。这些是日志中的 CoreSimulator IOHID 加载/伴随记录；测试结果没有对应失败。

这些记录不阻断按授权范围进入有界诊断 F4，以便观察 Maps 路径；它们的成因、对产品运行的实际影响及“无害”均未由现有证据证明，故作为明确残项保留，不作因果或 no-harm 声明。此判断不授予 Maps 操作本身的权限。

## Q5 — 旧 Quality 身份复用与阶段建议：Covered

旧 Quality 报告的 Q1/Q2/Q3 结果绑定旧候选及旧 xcresult 身份，不能直接充当本轮候选的技术覆盖。本轮使用当前 1,156/13 输入身份、23 项 Gate 和 454/105 当前矩阵重新绑定 Q1/Q2；Q3 按本轮授权保留上一轮 Covered，不复核。A2 内容继续作为单独已接受事项，不在本轮重开。F3-Q-AUDIT-001 仍是已获接受的历史流程残项，原超时与账本文字矛盾不改写。

因此，仅建议 Quality stage 可交给另行授权的单轮诊断 F4，带着同 30 项 skip 与上述 runtime 日志影响未知的残项进入。Human 授权明确无 install/Maps 自动权限，也不改变 Release 边界。

## 边界

未读取包外文件或 Swift/Vendor 源码内容；未重审 A2/Architecture/Q3；未运行 build、test、lint、Simulator、LLDB 或网络操作；只写入 packet output directory。最终作者用量与三文件 hash 由修复 delivery writer 生成并读回。
