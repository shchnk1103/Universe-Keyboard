# F3 Quality 增量独立复核

结论：**Partial**。本轮在第 12 次实际工具调用到达技术核验停止点；Q1、Q2、Q4 必需核对项仍未全部完成。此状态不是对候选或测试结果的否定，也不支持将候选判为可进入 F4。剩余疑点定位在本包已允许文件中，未扩读、未申请续额。

冻结 packet SHA-256：`00bf35de8a0e8bf38f92ea58b9953a68ed4ed48c32ec06c3726fd48fc728deed`，与给定值一致。Worktree 身份为 `codex/keyboard-wake-v3-compatibility-gate` / `84b9c19227330b0fe6ff391be001ee398010fd6a`。ACK 已在首个有界调用中写入并读回；ACK 时间 `2026-10-05T02:08:34.595923Z`。在精确 allowlist 上独立校验 2,466 个文件大小与 SHA-256，全部匹配；Swift/Vendor 源内容未打开，只用于逐字节哈希。准备包 `input-check.json` 另记 `source_rows_match=1156`、`pinned_match=13`、`raw_log_match=4`、`staged_count=0`，branch/HEAD 与冻结身份相符。

## Q1 — 候选输入、lint 与 23 项 Gate：Partial

1156 行输入及 13 个 pinned 输入由准备包记录，且整个精确 manifest 哈希核对通过。当前四个 Swift 编译/无 Swift 诊断沿用前一独立 A2-4 结果；本轮没有重审 A2 或源代码。

本轮在截止点前尚未独立解析 strict lint receipts，也未把 `required-gate-methods.json` 的 23 个方法逐项与 `gate-23-actual-results.json` / 当前 xcresult 核成 23 Passed、0 Skipped、0 Failed。locator：`docs/evidence/keyboard-wake-host-activation-fix-001-a2-validation-execution-artifacts/{step-receipts.json,required-gate-methods.json,gate-23-actual-results.json}`、`/private/tmp/ukey-host-activation-fix-a2-validation-run-20261005/logs/A2-V-0-format.log` 与 `app-keyboard.xcresult`。

## Q2 — 当前矩阵与同 30 项 Skip：Partial

直接对已有 xcresult 读取到：RimeBridge 105 项（85 Passed、20 Skipped、0 Failed）；App+Keyboard 454 项（444 Passed、10 Skipped、0 Failed）；签名 Keychain lane 1 项 Passed。测试结果汇总通过。

到停止点尚未提取实际 20+10 个 skipped identity 并与 Human 授权的“同 30 项”逐项比较，也未完成 Core 1,194 数量、Gate 23 项以及 Release `BUILD SUCCEEDED` 的独立核验。因此只确认数量汇总，不声称身份相同或完整矩阵已覆盖。locator：精确 allowlist 中 `rimebridge.xcresult`、`app-keyboard.xcresult`、`keychain.xcresult`、`release-build.xcresult`，以及 `A2-V-1-keyboardcore.log`、`A2-V-4-release-build.log`；Human 授权在 `docs/product-decisions/KEYBOARD-WAKE-HOST-ACTIVATION-FIX-001-f3-incremental-authorization-2026-10-05.json`。

## Q3 — Restore 与机器状态证据：Covered

允许的 restore receipt 记录：before 中 78 个 installed-app 文件匹配，应用内容匹配、两次读取相等、目标进程缺席；provenance 新增 20、改写 44、missing 为 false，`all_metadata_exact_claim=false`。before-restore 说明记录的内容/模式/所有者/非 provenance xattrs 与基线一致，并保留了 provenance 例外。收据明确没有 launch、deploy、input 或 Maps 健康检查；本结论不扩展为用户输入健康。

locator：`docs/evidence/keyboard-wake-host-activation-fix-001-a2-before-restore-2026-10-05.md`、`docs/evidence/keyboard-wake-host-activation-fix-001-a2-restore-artifacts/restore-receipt.json`。

## Q4 — 运行时日志定位和影响分类：Uncovered

准备包 `input-check.json` 给出计数：Rime 错误 3、IOHID loader 8、IOHID factory companion 8。由于预算停止前的单次汇总脚本在处理 inventory 计数时发生序列化异常，未逐项核对 runtime inventory 的 19 个日志行、两条 malformed-schema fixture、essay 条目及各自测试上下文；也未完成它们是否阻断有界诊断 F4 的分类。没有据计数宣称因果或无害。

locator：`docs/evidence/keyboard-wake-host-activation-fix-001-f3-f4-prepared-artifacts/runtime-log-inventory.json`、`A2-V-2-rimebridge.log`、`A2-V-3-app-keyboard.log`、`A2-V-5-keychain.log`（均为本 packet 精确 allowlist 文件）。下一次独立核验应只读 inventory 指定的行及相邻测试标记；不泛扫日志。

## Q5 — 历史 Quality 与阶段边界：Partial

Human 授权记录确认：F3-Q-AUDIT-001 保留为历史流程残项，旧超时及账本文字矛盾不改写；仅当前 F3 与后续单轮 F4 可将“同一 30 项 skip”作为非阻塞、未验证、不得计为通过、不得用于 Release 的处置；新增 skip/fail 即停止。授权不替代本轮逐项身份核对。此前 Quality 报告中的 Q1/Q2/Q3 技术身份不能直接转用于本轮当前候选；本轮须以当前输入、xcresult 与 restore 收据重新绑定。A2 内容仍与本轮 F3 Quality 分开。

Q1/Q2/Q4 未闭合，故不建议据此判定 Quality stage eligibility。此报告不重审 Architecture，不代表 F4 Ready、Maps、whole-F3 或 Release 通过；无 Maps/安装授权。

## 范围与停点

只读本 packet 精确列出的文件与现有 xcresult；未读包外内容、未打开 Swift/Vendor 源码、未运行 build/test/lint/Simulator/LLDB、未访问网络，也未写仓库。技术检查在第 12 次工具调用停止；余下调用仅用于必需交付和 hash readback。
