# Quality Review: T9-RESPONSIVE-PIPELINE-001 / P2-PERF-01

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`P2-PERF-01`](t9-responsive-pipeline-001-p2-perf-01.md) |
| Canonical evidence | [`canonical partial device evidence`](../evidence/t9-responsive-pipeline-p2-perf-01-canonical-partial-2026-08-01.md) |
| Prior evidence | [`partial non-canonical device evidence`](../evidence/t9-responsive-pipeline-p2-perf-01-partial-2026-08-01.md) |
| Repository provenance | `HEAD 3585a54` + 当前工作树有未提交变更；无 Release artifact 作为诊断 run 的替代物 |
| Verdict | **Pass with conditions：bounded diagnostic attribution only**；P2-PERF-01 不关闭，不等于 SLO、Release、Product Gate 或 ADR Accept |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 0** |

## 1. 复审边界

本次只读复审检查：

1. 规范人工输入保留下来的 34 条 `T9SEG` 与四个 `total ≥ 50 ms` 事件是否内部算术
   一致；
2. 附件 hash、设备/build/source、恢复记录和内容脱敏是否足以形成可审计证据；
3. Human 功能完整性报告、缺失前五条记录、Debug/单设备限制的分类；
4. 是否错误地越过 gate-off、ADR 0025、Product Gate 或 Release 边界。

本角色没有修改生产代码、测试或既有证据，只新增本 review。由于仓库中只有附件的
SHA-256，而没有可直接读取的原始诊断附件字节，本次对 34 行逐行分布、median/P95
的审计是“文档内部一致性检查”，不是从原始行重算的独立复现。

## 2. 证据清单与算术审计

### 2.1 34 条保留样本

规范记录声明保留 `action=6...39` / `event=6...39` 的连续范围。闭区间计数为：

```text
39 - 6 + 1 = 34
```

因此“34 条连续保留样本”的计数与文档一致；动作 1–5 缺失，不能把它称为完整 39
键曲线。`rawLen` 从 6 到 41，以及 event 18 的 17→20 跳变，与记录中说明的
one-anchor Debug 诊断臂相符，但没有原始行无法独立验证每一行的 rawLen 序列或该跳变
的因果。

### 2.2 四个慢事件

文档列出四个 `total ≥ 50 ms` 事件：

| action / raw length | total | rime | processKey api | collect | UI |
|---:|---:|---:|---:|---:|---:|
| 16 / 16 | 175.3 ms | 173.0 ms | 172.7 ms | 0.2 ms | 1.1 ms |
| 25 / 27 | 165.3 ms | 163.0 ms | 162.7 ms | 0.1 ms | 1.1 ms |
| 33 / 35 | 205.6 ms | 203.2 ms | 203.0 ms | 0.1 ms | 1.1 ms |
| 35 / 37 | 189.6 ms | 187.3 ms | 187.1 ms | 0.1 ms | 1.0 ms |

内部算术检查结果：

- 四个 `total` 都严格大于 50 ms；表格本身与 `SLOW T9SEG` 阈值一致；
- `processKey api + collect` 与 `rime` 在一位小数舍入误差内一致；
- 每个事件中 `rime / total` 约为 98.6%–98.8%，因此“RIME API 约占 99%”的归纳
  与表格一致；
- UI 合计约 1.0–1.1 ms，与 `pathUI + candUI` 的归因一致。

但由于原始附件未随仓库提供，Quality 无法独立确认“除这四行外没有第五个慢事件”，
也无法从 34 个原始数值重新计算 median `12.9 ms`、P95 `175.3 ms`、worst `205.6 ms`。
因此应写作“文档列出的四个事件与阶段算术一致”，不能写作“原始日志已被本角色完整
重算”。

## 3. Provenance / integrity review

### 3.1 已具备的强证据

规范记录包含：

- iPhone 13 Pro (`iPhone14,2`)、iOS 27.0 (`24A5390f`)；
- Reminders 空标题、software keyboard、Universe Chinese nine-key；
- Debug / Swift 6 / `-Onone`、bundle ID 与版本；
- App 与 Extension executable SHA-256；
- Source HEAD `3585a540...`；
- 诊断附件 SHA-256 `5fce05c3...5d88a`；
- 本地日志时间窗 `22:38:48.628`–`22:38:54.618`；
- 所有保留行 `committed=false`、session identity 一致、session valid、12 candidates；
- Release 恢复 build 的 app/extension hash、`CONFIGURATION=Release`、无诊断字符串、
  `devicectl device install app` 成功以及 install database sequence `3600`。

这些字段足以让该记录成为一个有明确设备和二进制身份的 bounded observation，而不是
无来源的主观描述。

### 3.2 仍缺少的可审计字段（P2-PERF-Q1）

附件 hash 是完整性指纹，但当前仓库没有对应附件字节、大小、保存路径或独立 hash
重算记录；因此 reviewer 不能重建 34 行和 percentile。Assignment 还要求的以下字段
没有在 canonical run header 中明确出现：

- 独立 Run ID 与 dirty worktree fingerprint（只有 Source HEAD）；
- Debug run 的 Xcode/SDK/toolchain identity；
- 观测到的 schema/readiness 与 Full Access 状态；
- Human 0–4 主观 stall score（只有“仍偶尔感到卡顿”的定性报告）；
- post-restore 的人工 gate-off 功能 smoke/可复核安装命令输出附件。

Release replacement 记录本身足以支持“已完成恢复”的 bounded 声明，但不能补齐上述
诊断 run 的缺失元数据。

## 4. Human report / redaction review

### 4.1 内容脱敏：通过

保留内容是长度、阶段耗时、session/integrity、candidate count 和结构状态；没有宿主
文本、候选文本、拼音 payload、用户词典或截图。`candidateSetIncomplete` 被正确标记为
结构诊断状态，而没有被误报成候选栏消失。

### 4.2 功能完整性：定性通过，量化字段缺失

Human 报告确认按声明 fixture 手动输入，并报告：无漏键、重复、候选消失、键盘退出或
数字泄漏；主观仍偶尔感到卡顿。这足以支持“本次 retained run 没有可见功能完整性
回归”的 bounded 描述。

但是 Assignment 要求 0–4 主观 stall score，当前记录没有数值评分，也没有逐事件 stall
位置的 Human 标注。因此不能把“功能无回归”写成完整的 exit-criteria 通过，也不能把
定性“偶尔卡顿”转成产品用户体验 SLO。

## 5. Missing prefix / Debug / single-device classification

### 5.1 前五条缺失：P2-PERF-Q2

保留范围从 action 6 开始，前 5 条没有随附件提供。它的影响是：

- 不能证明完整 39-tap 输入的首段延迟和首个 session 状态；
- 不能计算完整 39 行的 median/P95 或前缀随长度的完整曲线；
- 不能做首段与后段的固定 cadence 比较。

它不否定 retained action 16、25、33、35 的单事件归因：这些行均在同一 valid native
session 内，且 `rime`/`processKey api` 明显大于 UI。但该 run 仍应标记为 canonical
**partial**，而不是完整 fixture evidence。

### 5.2 Debug / 单设备：P2-PERF-Q3

本 run 是 iPhone 13 Pro、iOS 27.0、Debug `-Onone` 的单设备观察；没有 Release-like
同 fixture 对照，没有其他设备/OS、memory/jetsam、queue-depth 或长时间压力数据。它
不能证明 Release 仍有相同延迟分布，也不能证明产品主观“不再卡顿”。

附件没有 `T9RESP marker=PATH/READY`，所以不能把本 run 当作 off-main thread-affine
owner 成功证据；它更准确地支持“当前 gate-off/同步 RIME API 路径存在 163–203 ms
的 engine-dominated stall”，并把 Arch P1-3 作为下一工程问题。

one-anchor Debug arm 在 event 18 有一次 `T9AUTO status=accepted`，但没有 matched
control/A-B，也没有证明 anchor efficacy；文档对此边界表述诚实。

## 6. Bounded conclusion

在当前证据边界内，可以形成以下可审计结论：

> 在声明的 iPhone 13 Pro / iOS 27.0 / Debug `-Onone` 环境中，Human 手动输入目标九宫格
> fixture 的保留 action 6–39 样本中，四个列出的 175.3/165.3/205.6/189.6 ms 慢事件
> 均由约 163–203 ms 的 RIME `processKey` API 主导，而 Path/Candidate UI 约 1 ms；
> 同一 session 内未观察到 commit、数字泄漏或 Human 报告的功能完整性回归。

这个结论支持“优先调查同步 librime/processKey 的主线程占用”，并不支持把 Path/Candidate
reload 认定为首要根因之外的任何产品承诺。由于原始附件不可重算、前五条缺失、Debug/
单设备且没有 off-main marker，它不关闭 P2-PERF-01，也不形成性能 SLO、Release、jetsam、
ADR 0025、Product Gate 或 default-on 结论。

## 7. Passed / Failed / Skipped

### Passed

- 34 条 retained range 的闭区间计数正确；四个列出慢事件的阈值、阶段加总关系和 RIME
  占比在文档内一致；
- 设备、OS、bundle、app/extension hash、source HEAD、诊断 attachment hash、日志时间窗
  与 Release replacement 恢复记录已提供；
- Human 定性功能完整性报告和内容脱敏边界清楚；
- 未发现本证据改变 responsive gate、auto-anchor、ADR 0025 或 Product Gate 状态。

### Failed / P0-P1 blockers

- **无 P0/P1 blocker。** 证据限制影响的是完整性与可推广性，不是对当前生产代码提出
  的 P1 修复要求。

### Skipped / residual P2

- 原始 34 行附件不可直接读取，无法独立重算 percentile 或排除未列出的慢事件；
- action 1–5 缺失，完整 39-key length curve 未形成；
- Run ID/worktree fingerprint、schema/readiness、Full Access、Human 0–4 score 等
  Assignment exit fields 未完整记录；
- real librime/Lua/OpenCC 对照、off-main owner 验证、Release-like same-fixture、
  多设备/OS、queue/memory/jetsam、archive/TestFlight/App Store 未执行。

## 8. Quality verdict and handoff

**结论：Pass with conditions（bounded diagnostic attribution only）。** 当前记录足以
把 retained slow events 可信地归因到 RIME `processKey` API 主导的同步路径，并支持把
Arch P1-3 作为下一工程方向；但 P2-PERF-01 仍保持 `In Progress`，不能宣称完整
acceptance、主观不卡顿、性能 SLO、Release ready 或 Product Gate。

建议后续若要关闭本 assignment：

1. 以可供 reviewer 读取的附件或逐行 content-free export 补齐 hash 可重算性，并附 Run ID、
   worktree fingerprint、schema/readiness、Full Access 与 Human 0–4 score；
2. 重新运行完整 39 条人工 fixture，保留 action 1–39 的连续行，并明确 cadence；
3. 另开授权任务验证真实 off-main/thread-affine owner、Release-like build、设备/内存/
   jetsam 与性能对照，不把本 Debug 单机 observation 当作产品 Gate。

在这些工作完成前，保持普通 gate-off 恢复状态；本 review 不接受 ADR 0025、不创建
Product Gate、不授权 Release default-on。
