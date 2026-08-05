# Quality Review: T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02 B 臂

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`P2-PERF-02`](t9-responsive-pipeline-001-p2-perf-02-release-like.md) |
| Evidence | [`P2-PERF-02 B evidence`](../evidence/t9-responsive-pipeline-p2-perf-02-b-2026-08-01.md) |
| Repository provenance | 当前工作树有未提交变更；B evidence 未提供 source/worktree fingerprint 或可读取原始附件 |
| Verdict | **Pass with conditions — Partial B-arm evidence**；不等于 A/B 完整比较、Release、Product Gate 或 ADR Accept |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 0** |

## 1. 复审范围与结论边界

本次只读检查 B 臂记录中的：

- 39 条连续 `T9SEG` 的范围与合法 run token；
- 5 条 `SLOW RIME` 的数量与可审计性；
- `T9ARM actions=38/session=0`、`T9GEOM execution invalid`、session validity；
- `T9RESP` 旁证、Human 定性反馈和缺失的 0–4 分；
- Release-optimized internal diagnostic 的 A/B、恢复和默认 gate 边界。

本 review 不修改生产逻辑、测试或证据，只新增本文件。Assignment 本身要求 A/B 两臂；
当前提供的文件只有 B 臂记录，因此本结论是 B-only 的 partial evidence，不能形成 A/B
方向比较或 Product Gate。

## 2. 证据审计

### 2.1 T9SEG 连续性与算术

证据声明 `action/event=1–39` 连续保留。这个闭区间包含：

```text
39 - 1 + 1 = 39 条
```

它与本 Assignment 声明的 `jintiandetianqizhenbucuowomenchuquwanba`（39 个 ASCII
字符）在数量上相符，且每条都绑定完整 run token 的声明。Run Header 中的
`S6A-A01A9F248ED449A4836888D883E36ABB` 是 `S6A-` 加 32 位大写十六进制，形式上符合
项目 `isCanonicalToken` 规则。

但 `T9ARM actions=38` 与 39 条 `T9SEG` 不一致。代码审计显示 `HotPathSegmentTiming`
在 `sampleOrdinal == 38` 时发出 `T9ARM`，所以它可能是第 38 条的 checkpoint，而非
39 条运行的最终 summary；证据没有明确写出这一语义，也没有 `actions=39` 的最终
summary。加上 `T9ARM session=0`，不能把这条 ARM 记录当作完整运行闭合证明。

### 2.2 五条 SLOW RIME

记录列出五个 `processKey` API 时长：

```text
56.5 ms, 147.1 ms, 151.3 ms, 178.7 ms, 181.9 ms
```

这五个数均达到或超过 `SLOW RIME` 的 50 ms 诊断阈值，数量和列出的值在文档内部一致。
它们支持“B 臂仍有约 150–182 ms 的 RIME 调用尾延迟”这一 bounded 观察。

由于原始附件字节未随仓库提供，Quality 无法独立确认是否确实只有五条慢行、也无法
从逐行 `T9SEG` 重新计算每条的 total/rime/UI 关系或完整 percentile。该结论应表述为
“文档列出的五条 SLOW RIME”，不能表述为已完成原始日志重算。

### 2.3 B 路径旁证

每个 revision 被记录为 `ACCEPT → VISIBLE(provisional) → PUBLISH`，并有第二条
`T9RESP-R5P` publish。记录说明第二条 publish 由
`performResponsivePresentationApply` 在 `isThreadAffineRimeOwnerEnabled` 时发出，
这对 B 的 thread-affine 行为提供了有价值的旁证。

不过导出没有正式的 `T9RESP marker=PATH path=thread-affine` / `READY` engine-category
行，所以不能将旁证升级为完整 path marker 证明。

## 3. Integrity / environment findings

### P2-PERF-02-Q1 — ARM/session/geometry 合同未闭合

本记录同时出现：

- 39 条 `T9SEG`，但 `T9ARM actions=38`；
- 所有 `T9SEG` 的 `sessionBefore/After=0 valid=false`；
- `T9ARM session=0 sessionStable=false sessionValid=false`；
- `T9GEOM phase=execution run=invalid status=unavailable`；
- 缺少正式 `PATH/READY` marker。

这些字段不能被改写为 session 稳定、geometry 连续或路径取证通过。Human 是手动输入，
所以 geometry invalid 不直接证明输入被坐标自动化污染；但它仍表示该物理诊断 envelope
没有完成完整 execution-geometry 证明。这个问题是 evidence integrity P2，不是生产
代码 P1。

### P2-PERF-02-Q2 — B-only 与 artifact/provenance 不完整

B Run Header 有设备 UDID、配置、flags、B App/Extension hash、raw attachment hash 和
合法 token，强于无来源的主观报告；但仍缺少：

- A 臂对应的 build/hash/log，无法做物理可比 A/B；
- source HEAD、dirty worktree fingerprint、Xcode/toolchain 完整身份；
- iOS 27 的具体 minor/build；
- 可读取的原始附件字节、大小/路径或独立 hash 重算记录。

因此只能审计 B 的文档声明，不能独立复现 39 行或五条慢 RIME。

### P2-PERF-02-Q3 — Human 反馈完整性有限

Human 定性反馈为：无漏键、重复、候选消失或键盘退出，整体流畅。这支持“本 B 运行未见
可见功能完整性回归”的 bounded 描述。

Assignment 要求 0–4 subjective stall score，但记录明确没有数值分数；不能擅自把“流畅”
转换为 0，也不能据此声称用户体验 SLO 或完成 A/B 主观比较。

### P2-PERF-02-Q4 — 恢复与 Release 边界仍未构成发布证据

记录说测试后替换回 A/普通 gate-off 包并发起一次性 preflight envelope cleanup，但没有
提供可独立复核的最终安装命令输出、A 包 hash 或 cleanup 完成凭据。即使恢复操作确实
完成，也只是环境善后，不是 shipping Release 证明。

本证据没有 memory/queue/jetsam、多设备/OS、iOS 26.0 Release RC、archive/dSYM、
TestFlight/App Store 或 Product Gate 资料。

## 4. What is actually proved

在上述边界内，可以形成以下可审计结论：

> 在一台真实 iPhone 13 Pro 上，B 的 Release-optimized internal diagnostic 配置产生
> 了 39 条连续 `T9SEG` 声明，并列出五条 56.5–181.9 ms 的 `processKey` API 慢调用；
> `ACCEPT/PROVISIONAL/PUBLISH` 顺序和 thread-affine-only publish 旁证表明，慢调用时
> B 能先接收输入并显示 provisional 反馈。Human 报告未见漏键、重复、候选消失或键盘
> 退出，且主观感觉整体流畅。

这足以支持“B 的响应式接受/临时视觉反馈方向在该设备上出现了有效行为观察”。它不
证明 RIME session/geometry 完整、B 已通过 A/B 比较，也不证明 Release 默认开启、长期
稳定、jetsam 安全或 Product Gate。

## 5. Gate / authority checks

- B flags 是显式注入的 Release-optimized internal diagnostic 条件；Assignment 声明
  responsive gates project-default 仍为 `false`，没有证据显示默认值被改变。
- `T9DEVICE ... gate=off` 指的是 auto-anchor device gate；它**不等于** responsive B
  gate 关闭，证据没有把两者混为一谈。
- ADR 0025 仍是 **Proposed**；本证据不 Accept ADR、不授权 R6、不创建 Product Gate，
  也不把 internal diagnostic arm 当作 App Store Release。

## 6. Passed / Failed / Skipped

### Passed（bounded）

- 39 条 `T9SEG` action/event 范围的文档计数与声明 fixture 长度一致；run token 形式合法。
- 文档列出的五个 SLOW RIME 值均越过诊断阈值，B 的 ACCEPT/PROVISIONAL/PUBLISH 顺序和
  thread-affine-only publish 旁证方向清楚。
- Human 定性完整性报告、内容无关诊断字段和 default-off/ADR 边界描述清楚。

### Failed / P0-P1 blockers

- **无 P0/P1 blocker。** 主要问题是 B-only 取证完整性、session/geometry invalid 和
  缺少比较/发布证据，不是本 review 授权修复生产代码。

### Skipped / residual P2

- `T9ARM actions=38` 与 39 条 T9SEG 的最终 summary 语义、session=0/invalid session
  稳定性、execution geometry、PATH/READY marker 未闭合；
- 原始附件不可重算、A 臂未提供、source/worktree/toolchain/OS 细节不完整；
- Human 0–4 分缺失；
- Release 默认行为、多设备/OS、memory/queue/jetsam、完整恢复/安装凭据、archive/
  TestFlight/App Store、R6、Product Gate、ADR Accept 均未验证。

## 7. Quality / Performance verdict and handoff

**结论：Pass with conditions — Partial B-arm evidence only。** 当前记录可信地支持
“B 在真实 iPhone 13 Pro 上先接收输入、再以 provisional 反馈遮蔽部分 RIME 延迟”的方向
观察，但不能把它写成 A/B Pass、off-main 完整证明、Release ready、Product Gate 或
ADR 0025 Accepted。

建议后续：

1. 若要关闭 P2-PERF-02，补齐 A 臂同源 fingerprints/export，并明确 B 的最终 39-action
   summary 语义（或将 `T9ARM actions=38` 明确标为 checkpoint）；
2. 重新导出可供 reviewer 读取的 content-free 原始附件，补齐有效 session、execution
   geometry、正式 PATH/READY marker 和完整 source/worktree/build header；
3. 获取 Human 0–4 score；把恢复后的普通 gate-off bundle identity/cleanup 完成作为
   可复核记录；
4. 将 Release、jetsam、内存、跨设备与 Product Gate 作为另行授权的后续工作。

在这些证据补齐前，继续保持双 gate default-off；本 review 不宣布 Spike Pass、ADR
Accept、Product Gate 或 Release default-on。
