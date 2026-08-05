# T9-RESPONSIVE-PIPELINE-001 / P2-PERF-03
# 四臂复现与反向顺序真机证据：独立 Quality / Performance 复审

状态：`Completed — bounded four-arm evidence review; matrix remains Partial`

复审日期：2026-08-03

复审角色：独立 Quality / Performance reviewer（只读）

## 1. 范围与停止边界

本次复审检查：

- `docs/assignments/t9-responsive-pipeline-001-p2-perf-03-replicated-ab-proposal.md`
- `docs/evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-2026-08-03.md`
- `docs/evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-summary-2026-08-03.json`
- P2-PERF-02 Evidence Contract 及既有 P2 Quality review 的 A/sync、B/PUBLISH、privacy 与
  restore 判定边界
- 四个 content-free 当前-token 子集及 Assignment 引用的普通 restore 记录（只读）

没有修改生产代码、Lua/schema、测试或默认 gate，没有执行新的设备输入，也没有把四臂观察
升级为 Product Gate、ADR 0025 Accepted、Release 或生产接线批准。

## 2. Verdict

**Verdict：条件通过（bounded four-arm runtime evidence）；P2-PERF-03 仍为 `Partial`。**

四个有效 arm 的核心运行事实是完整且相互一致的：

- A1/A2 sync 都有 39/39 `T9SEG`、稳定有效 session 和 `dualGate=0/0`；
- B1/B2 thread-affine 都有 PATH/READY、39/39 ACCEPT、39/39 epoch-bound ordered PUBLISH、
  稳定有效 session；
- B1/B2 的 immediate `T9SEG` 最大值分别为 0.8/0.7 ms，而 A1/A2 的同步 RIME 长峰分别
  约 241/245 ms；
- A→B 与 B→A 两种顺序的 Human 评分方向都显示 B 更低（A1 2.5→B1 1，B2 1→A2 3）。

但是，这不是完整可发布的证据包：B1/B2 各有 35 条 `PAINT`，4 个 revision 没有 PAINT，且
所有已记录的 `coalesced` 都为 0、缺失原因未提供；Full Access 仍 unknown/unavailable；
Human report 没有落实 Assignment 新增的 `protocolAdherence` 字段；tokenless geometry 是
事后派生；隐私 allow-list 只对当前-token marker 子集通过，原始附件因历史 token 与
`candidates=12` deny-list 规则不能宣称完整 pass。

严重度计数（本复审发现的残余）：

| P0 | P1 | P2 | P3 |
|---:|---:|---:|---:|
| 0 | 0 | 4 | 3 |

P2/P3 表示 evidence contract、可复核性和 presentation 语义残余；不是已发现的输入破坏或
隐私泄漏。

## 3. 已证实的运行事实

### 3.1 四臂身份、顺序与 build/path

- Pair `P2P03-AB` 为 A→B，Pair `P2P03-BA` 为 B→A；每个 arm 有独立 fresh `runID` 与
  canonical token。
- 四臂共享 source HEAD、pre-run tracked/untracked fingerprints、iPhone 13 Pro、iOS 27.0、
  Xcode/SDK/Swift 和同一 canonical fixture ID/digest；A1/A2、B1/B2 的包复用关系已记录。
- A1/A2 只有 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`，实际 path 为 sync、dual gate `0/0`；
  不套用 B 的 ACCEPT/PUBLISH 合同。
- B1/B2 额外注入 `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`，实际 path 为 thread-affine、
  dual gate `1/1`，且有 `READY bootstrap=config-only session=owner-thread`。
- 没有定义 auto-anchor `*_ENABLED` 条件，也没有修改项目默认 gate。

### 3.2 四臂 validator 核心完整性

| Arm | `T9SEG` | Session | Path/owner | Human integrity | Validator 摘要 |
|---|---|---|---|---|---|
| A1 | 39，action/event `1..39`，commit=false | `4384574040` valid/stable | sync `0/0`；A 专用，不要求 B 链 | 四项均 `no` | `complete` |
| B1 | 39，action/event `1..39`，commit=false | `4386175000` valid/stable | PATH/READY；ACCEPT/PUBLISH `1..39` | 四项均 `no` | `complete` |
| B2 | 39，action/event `1..39`，commit=false | `4424090840` valid/stable | PATH/READY；ACCEPT/PUBLISH `1..39` | 四项均 `no` | `complete` |
| A2 | 39，action/event `1..39`，commit=false | `4577961560` valid/stable | sync `0/0`；A 专用，不要求 B 链 | 四项均 `no` | `complete` |

`T9ARM actions=38` 在 A1/A2 只是历史 checkpoint；P2 retained count 正确使用 `T9SEG` 的
39 行，没有将 checkpoint 当成漏键或 39-action summary。

### 3.3 B owner completion 与 presentation 分层

- B1/B2 均为 39/39 ACCEPT、39/39 epoch=1 PUBLISH，owner completion 证据闭合；这证明 accepted
  revision 没有在 owner 层被丢弃、合并或乱序。
- B1/B2 各有 42 条 VISIBLE（35 engine + 7 provisional）和 35 条 PAINT；每臂 4 个 revision
  没有 PAINT。该差异不等于漏键，因为 PUBLISH 仍是 39/39。
- 但每条已记录 PAINT 的 `coalesced=0`，且没有 `coalesced=1`、吸收区间或其他 reason；
  因此只能判 owner completion 完整，不能判逐 revision 的 UI presentation 完整。

### 3.4 顺序与 Human 评分

| Pair | A 评分 | B 评分 | B-A | 观察 |
|---|---:|---:|---:|---|
| A→B | A1 `2.5/4` | B1 `1/4` | `-1.5` | B 较低 |
| B→A | A2 `3/4` | B2 `1/4` | `-2.0` | B 较低 |

方向在两种顺序中一致，且所有 arm 都报告漏键、重键、候选消失、键盘退出为 `no`。但每个
顺序只有一对样本，评分仍来自同一 Human；A1 无效 token 尝试后重跑、A/B 固定手工节奏、
疲劳/熟练度及诊断包切换仍可能影响主观分数。

## 4. Token 过滤与隐私判断

### 4.1 已证实的隔离行为

- A1 的首次无 token 准备尝试明确标为 `invalid-run-token`，没有并入有效 A1 统计。
- B2/A2 原始导出包含此前 arm 的历史 token，这是“不清空日志”的预期；当前-token 子集按
  唯一 token 截取，四臂分别有独立行数、字节数与 SHA-256。
- 当前-token 子集 validator 均为 `complete`，privacy result 为 false/allow-list pass；
  没有把历史 token 的 marker 或 timing 混入本 arm 汇总。

### 4.2 隐私结论的正确边界

原始附件仍在受控外部目录，仓库只保留摘要/哈希，不保存 raw pinyin、候选、宿主文本、截图或
UI hierarchy。原始导出的 `SLOW RIME ... candidates=12` 会触发旧 deny-list 对字段名的保守
拦截；这不是候选文本泄漏的证据。当前做法只对 token-bound marker-only 子集声明 pass，证据
本身也明确没有把原始附件宣称为完整 privacy allow-list pass。

因此本复审可以接受“当前 retained evidence content-free 且 token 隔离正确”的有界结论，不能
把它扩大为原始附件、未来导出或所有候选数量格式都已完成隐私证明。

## 5. P0–P3 findings

### P0：0

没有看到用户输入漏失/重复、不可恢复设备状态、实际 raw 内容落入仓库或生产 default gate
被打开的证据。

### P1：0

四个有效 arm 的 device/token/path 身份、39/39 segment 和 B 39/39 owner completion 没有出现
必须阻断证据归档的错误；A1 无效尝试已隔离，不构成有效 arm 污染。

### P2-P03-01：Human protocolAdherence 与 canonical raw fixture 不能由本次报告独立确认

Assignment 的 Human protocol 明确要求每臂报告 `protocolAdherence`（manual、no-prohibited-actions
或 not-observed），并禁止 numeric page、Path/candidate、space、commit、Delete、paste 和
coordinate automation。但四臂 summary 的 `humanReport` 只有四项 integrity、评分和 inputMethod，
没有 `protocolAdherence`。

39 个有序 `T9SEG` 只能证明收到 39 个 marker 事件，不能证明实际每一次手工触点就是 canonical
raw fixture，也不能证明没有使用某个被禁止的辅助动作。隐私规则禁止把 raw sequence 写入日志是
正确的；缺口是没有 content-free adherence 状态，而不是要求保存原始文本。

处置：后续每臂增加 `protocolAdherence` 枚举；不可观察就写 `not-observed`，不要推断为 manual。
在此之前，保留“protocol-declared 39-action observation”，不要写成 raw fixture 已被 Quality
逐键验证。

### P2-P03-02：B1/B2 的 PAINT 35/39 缺失 revision 没有 coalescing/reason 终态

B1/B2 各有 39/39 PUBLISH，但只有 35 条 PAINT；四个缺失 revision 没有逐 revision 原因，且
35 条现有 PAINT 的 `coalesced=0`。P2 contract 允许 latest-only coalescing，但要求 PAINT 的
`coalesced`/reason 保持 content-free、可审计；当前数据无法区分“已按 latest-only 吸收”与
“presentation marker 没有产生/导出漏行”。

该 finding 不降低 39/39 owner completion，也不构成输入漏键；它只阻止 UI presentation 合同
升级为 Complete。

处置：为每次 coalescing 记录 `coalesced=1`、被吸收 revision 区间或明确 terminal reason，并
让 validator 对缺失 paint reason fail-closed。

### P2-P03-03：Full Access unknown、host opaque ID 与独立时间/run-header 不完整

证据明确 Full Access 本次未重新观察，保持 `unavailable/unknown`；host 只描述为同一提醒事项
disposable list，没有可比对的 opaque list ID；summary/Markdown 没有四臂独立 start/end/timezone/
log-window 字段。P2 contract 要求这些字段不能从历史 run 或另一 arm 继承。

因此 A/B 顺序结果可以作 bounded same-device direction observation，但不能升格为 contract
Complete、无条件 A/B Pass 或用户 SLO。

### P2-P03-04：Privacy pass 只覆盖当前-token marker 子集，不是原始附件完整 allow-list pass

四个当前-token filtered subset 的 `privacyAllowList=pass` 是可接受的 content-free retained
evidence；但 B2/A2 原始附件包含历史 token，且 `candidates=12` 触发旧 deny-list。证据诚实地把
这一点写成“原始附件不能宣称完整 allow-list pass”，没有将它误报为泄漏。

这是一个证据范围 residual：如果后续消费者把 summary 的 `complete` 或子集 `pass` 误读为
原始附件全量通过，就会越过隐私边界。保留 `bounded privacy closure` 语义，直到 validator/
allow-list 版本、逐步 reasons 和受控原始附件复核路径被固定。

### P3-P03-05：tokenless geometry 是事后派生，且复用 package 的 per-arm bundle binding 不显式

每个 arm 的 prepared/execution tokenized geometry digest 都匹配，去除 token 后得到相同的
`114c78…ed4d0` shape digest；这是有价值的跨臂观察。但 evidence 明确标记它是 post-hoc derived
metadata，不是运行前冻结 marker，因此不能完全替代 geometry contract 的 pre-run normalized
digest。

此外，A2/B2 使用 `packageReuse` 指向 A1/B1 binary，summary 没有在这两个 arm 重复记录 App/
Keyboard executable SHA；虽然包复用声明可读，完整 per-arm run header 仍应通过 artifact ref
明确绑定。

### P3-P03-06：validator summary 的 provenance 与失败理由不足以长期重放

四个 arm 的 validator 结果写为 `complete`，但 summary 没有记录 validator source/schema
version、每臂 reasons、allow-list version 或独立 `privacy-scan.txt`；原始附件和当前-token
subset 仍在外部/临时位置。当前文档足以进行一次 bounded review，但不足以形成长期 immutable
evidence package。

### P3-P03-07：四臂仍是单设备、小样本、固定顺序内的主观观察

A→B 与 B→A 两种顺序都给出 B 较低评分，这是对方向二的更强支持；但每个顺序只有一对样本，
评分由同一 Human 提供，未覆盖重复日、多设备、iOS 版本、帧率/主线程 paint trace、队列/内存/
jetsam 或真实 Release RC。B 的 1/4 也不是“完全不卡”，只是比 A 低的主观报告。

## 6. Contract disposition

| Evidence layer | Quality 判定 | 说明 |
|---|---|---|
| A sync runtime | `bounded pass` | A1/A2 39/39 `T9SEG`、session、geometry、sync 0/0；不要求 B marker 链。 |
| B owner runtime | `bounded pass` | B1/B2 PATH/READY、ACCEPT/PUBLISH 39/39、epoch 1、有序。 |
| Presentation | `Partial` | PAINT 35/39，4 revision 缺 reason；不能冒充 39/39 UI paint。 |
| Input/Human protocol | `Partial` | integrity/评分齐全，但 `protocolAdherence` 缺失，raw fixture 不可重建。 |
| Token/privacy | `bounded pass` | 当前 token subset pass、无混入；原始附件全量 allow-list 仍未宣称。 |
| Runtime identity/comparability | `Partial` | Full Access unknown、host/time/run-header 不完整；geometry tokenless digest post-hoc。 |
| Restore | `bounded pass` | 普通 Release 无条件包安装序号 3800、hash、Human smoke 已记录。 |
| Product/ADR/Release | `not-authorized` | Assignment 与 summary 明确保持禁止升级。 |

**最终分类：**

`Partial — four arms validator-complete for their scoped runtime contracts; A sync semantics valid;
B owner ACCEPT/PUBLISH 39/39; B PAINT 35/39 with four missing reasons; token-bound privacy subset
pass; Full Access/protocol/manifest residuals remain; ordinary restore 3800 passed.`

## 7. 下一步建议与停止点

1. 保留当前四臂数据和 invalid A1 排除记录，不把 `validator=complete` 误写成整组 Pair Complete。
2. 首先补齐 `protocolAdherence`、Full Access/host/time/run-header、每臂 package hash ref 和
   pre-run tokenless geometry binding；缺失项继续写 `unavailable/not-observed`，不要从旧 run 推断。
3. 明确 PAINT latest-only coalescing 的 content-free终态，给四个 missing revisions 各自可审计
   reason；在此之前只宣称 owner PUBLISH 39/39，不宣称逐 revision UI 完整。
4. 固定 privacy allow-list/validator source/schema 版本，保持原始附件受控、不复制用户内容；
   不要把 `candidates=12` 的 deny-list false positive 改写成隐私事故。
5. 可保留的方向性事实是：两种顺序下 B immediate path 均低于 1 ms、sync A 有约 242–247 ms
   RIME 尖峰、B Human score 较低；不能将其升级为用户 SLO、唯一根因、ADR 0025、Product Gate
   或 Release 结论。

本独立 Quality/Performance 复审到此停止。
