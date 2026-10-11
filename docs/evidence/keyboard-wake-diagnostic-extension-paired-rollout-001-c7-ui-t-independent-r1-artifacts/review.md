# 独立 T 验收审查

- Lane / Round：`QUALITY-C7-UI-T-INDEPENDENT` / `1`
- 冻结 packet：`/private/tmp/ukey-wake-ui-t-independent-review-20261003/packet.json`
- 授权摘要：`e4ea33e9e183fe5c1264b16a68580ec8fd607984406e9f611e1f30b7e0a29fa8`
- 实测 packet SHA-256：`9e93749875e1669016adb60c1e669550268cfcc2652e3e4deb35d4c68449467a`
- 结果：`Partial`；总体 T acceptance：`Hold`

## 范围与停止原因

本轮只读取并解析了冻结 packet，并计算其文件 SHA-256。实测值与授权给定摘要及 packet 自载的 `packet_digest_sha256` 均不一致（期望 `e4ea33e9e183fe5c1264b16a68580ec8fd607984406e9f611e1f30b7e0a29fa8`，实测 `9e93749875e1669016adb60c1e669550268cfcc2652e3e4deb35d4c68449467a`）。这触发 packet 定义的 stop condition「allowed input hash mismatch」。因此没有读取或核验 packet 内列出的仓库文件、日志、result bundle 或 inventory；也未访问设备、测试、构建、网络、进程或 LLDB。没有执行 T1–T6 的依赖证据检查。

## T1–T6 覆盖矩阵

| 项目 | 覆盖 | 独立核验与定位 |
|---|---|---|
| T1 候选身份与工具链 | Partial | 未验证 baseline 的 worktree/branch/HEAD、候选 source571/Vendor630、build manifest、命令参数、编译标志、工具链或 simulator ID。packet 中的声明位于 `baseline`、`allowed_content_inputs`、`hash_only_source_vendor_inputs`；因 packet digest 不符，均未作为有效证据。旧安装基线不能被推断为新候选运行时。 |
| T2 三套测试与 skip | Partial | 未读取摘要、逐项 skip identity/reason、日志或 xcresult。packet 的 `criteria.T2` 声明期望计数 `85/0/20 + 421/0/10 + 1/0/0`（537 total / 507 passed / 30 skipped），这些数值未经本轮独立核验，也不能把 skipped 计作 passed。 |
| T3 Core 复用证据 | Partial | 未验证 C7-B2 的 package manifest、204 个最终文件及 hash、源/文件集合、环境、基线、覆盖或工具链；packet 中的 `c7b2-core-artifacts` 与 hash-only 路径声明不构成本轮核验。 |
| T4 恢复、备份与保护状态 | Partial | 未比对任何 allowed inventories、hash/结构、action receipts、metadata/root/snapshot 或 provenance。未打开用户 backup 内容；初始 Hold、恢复后、健康检查后的 Keychain backup/test-after/minimal-restore 链均未独立确认。 |
| T5 skips 与 Product disposition | Partial | task 指令告知当前 30 个 skip 尚无本阶段 Product 接受；packet `criteria.T5` 也要求不得沿用旧阶段接受。本轮没有核验 skip identities/reasons 或取得任何新的 Product disposition。30 个 skip 仍是未验证残项，必须由 Product Owner 提供本阶段逐项处置；不能据此宣称 T acceptance。 |
| T6 交付与范围边界 | Partial | packet 摘要失配使来源链无法成立。没有独立确认历史 Hold、最终报告与证据索引的一致性，也没有评估 Quality/Product/Release Gate。不会据此作出 Gate、Release、Maps、新候选或运行时结论。 |

## Findings

- **F-001 — Blocker — packet 身份摘要不匹配。** `packet.json` 的实测 SHA-256 为 `9e93749875e1669016adb60c1e669550268cfcc2652e3e4deb35d4c68449467a`；Human authorization 输入与 JSON 内 `packet_digest_sha256` 均给出 `e4ea33e9e183fe5c1264b16a68580ec8fd607984406e9f611e1f30b7e0a29fa8`。审查按停止条件中止。Owner：coordinator / packet producer（root），需由 Product Owner 提供经重新冻结且摘要匹配的审查输入及授权；本轮不自动续预算。
- **F-002 — Blocker for overall acceptance — Product disposition 缺失。** 当前 30 个 skip 尚无本阶段 Product 接受（见授权任务指令、packet `criteria.T5`）；应由 Product Owner 对经核实的逐项残项作本阶段处置。Owner：Product Owner。

## 结论

六项覆盖全部为 `Partial`，所以覆盖状态为 `Partial`（不满足 `Complete` 条件）。本轮无法给出限定证据意见；总体 T acceptance 保持 `Hold`。不声明整体 T Gate、Quality、Product 或 Release 通过，也不沿用旧 v5/B/C7 的接受状态。继续审查需要新的、digest 匹配的冻结 packet 与授权；不自动续展本轮预算。
