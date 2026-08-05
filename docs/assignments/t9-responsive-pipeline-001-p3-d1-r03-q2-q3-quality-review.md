# T9-RESPONSIVE-PIPELINE-001 / P3-D1-R03 Q2/Q3
# Evidence Hardening 独立 Quality / Performance 只读复核

状态：`Completed — bounded hardening accepted with conditions; R03 remains Partial`

复核日期：2026-08-03

复核角色：独立 Quality / Performance reviewer（只读 addendum review）

## 1. 范围与方法

本复核只检查：

- `docs/assignments/t9-responsive-pipeline-001-p3-d1-r03-q2-q3-evidence-hardening.md`
- `docs/evidence/t9-responsive-pipeline-p3-d1-r03-evidence-hardening-followup-2026-08-03.md`
- `docs/evidence/t9-responsive-pipeline-p3-d1-r03-validator-summary-2026-08-03.json`
- P3-D1-R03 原始 Assignment/证据、父矩阵相关行及 P2-PERF-02 evidence contract

重点是字段来源、原始运行证据与事后 addendum 的分层、hash/build/restore/fixture digest、
`unavailable` 的处理和是否仍应保持 `Partial`。

本次没有修改生产逻辑、没有修改测试或默认 gate、没有执行设备操作、没有重跑 validator，
也没有开启 B/A-B 或作 Product Gate/Release 决定。

## 2. Verdict

**Verdict：Evidence Hardening 在其授权范围内有界通过，但不能关闭 Q2/Q3，也不能升级 R03。**

本次 addendum 可信地补强了两项历史缺口：

1. 外部诊断附件已有受控 validator 的 content-free summary、字节数、SHA-256、run token、
   39/39 连续性、geometry/session/privacy 结果；
2. 普通恢复包之后有人观察到键盘出现、单键生效、未退出且保持稳定。

这两项只关闭“附件 validator/reopenability”和“恢复后最小可见 smoke”的旧子缺口。它们
不是 P2 evidence contract 的整臂 `Complete`，更不是 R03 的 Product Gate 或 Release 结论。

严重度计数（本 addendum 复核仍开放的残余）：

| P0 | P1 | P2 | P3 |
|---:|---:|---:|---:|
| 0 | 0 | 2 | 3 |

P2/P3 均为证据绑定、可复核性或范围边界问题；没有据此断言用户数据泄漏或生产 gate
被打开。

## 3. 字段来源与证据分层判断

| 证据项 | 当前来源 | Quality 判断 |
|---|---|---|
| 原始 39-action 事实、时间统计、gate/path marker | R03 外部诊断附件的 run-token 摘要 | 属于历史运行时事实；本次 addendum 没有重跑设备，不能改写原始事实。 |
| `validator status=complete` | 受控临时目录运行的 validator；summary 给出 source SHA、命令和 exit 0 | 对 validator 的既定 expectation 有界成立，不等于 P2 contract 全字段 Complete。 |
| 附件 bytes/SHA/run-bound line count | follow-up 与 JSON summary | 可作为 content-free artifact 身份；原始文本不入仓库，符合隐私边界。 |
| Xcode/SDK/Swift/deployment/signing/build command | 既有 build record 的事后 provenance addendum | materially strengthens identity，但没有把未捕获的原始 run-header 内容变成运行时观察。 |
| untracked-content fingerprint | 原始 run 前未捕获 | 明确为 `unavailable`，处理正确，不得补猜。 |
| fixture ID/digest | validator marker expectation 与 addendum 的 derived digest | 发现与 P2 canonical human fixture 的 ID/digest 未建立映射，不能视为 Q3 已闭合。 |
| restore app/appex hash、CDHash、install sequence、命令 | 原始 restore 记录及 addendum | 可证明替换回普通包的有限事实；完整 restore identity/时间窗仍不齐。 |
| 恢复后单键 smoke | follow-up 中 Human 事后报告 | 关闭“是否观察到键盘可见”的子缺口；只覆盖单键，不覆盖长句性能。 |
| Full Access、opaque host/list ID、runtime/readiness、原始时间窗 | 原始 run 未捕获 | 均明确写为 `unavailable`；这保持了契约的 fail-closed/Partial 语义。 |

因此，addendum 是**事后证据补录**，不是对原始真机 run header 的 retroactive rewrite。它可以
减少已知残余，但不能把原始 run 未观察到的字段改称 observed。

## 4. 已确认的正向结果

### 4.1 Validator/reopenability 子缺口已有界关闭

Follow-up 与 JSON 一致记录：

- `runID` 与唯一 `runToken`；
- attachment bytes `20919` 与原始附件 SHA-256；
- run-bound line count `44`；
- validator source SHA-256、构建命令和 exit 0；
- `T9SEG` action/event 均为连续 `1…39`；
- prepared/execution geometry 存在且 digest 匹配；
- native session 有效且稳定；
- `sawCommit=false`、`sawPrivacyViolation=false`。

JSON 中 `hasReadyMarker=false` 与 `arm=sync` 不矛盾：A 同步臂不要求 B 的 READY；原始证据
另有 `path=sync dualGateRequested=0 dualGateActive=0`。因此不能把缺 READY 错报成失败，也
不能把 `status=complete` 误报成 B ready 或 off-main 证明。

### 4.2 恢复后最小 smoke 子缺口已关闭

普通 Release 恢复包上的 Human 报告为键盘可见、单个九宫格字母键生效、键盘未退出、运行稳定，
`stallScore=0` 明确限定为单键 smoke。该报告没有复制输入或宿主文本，且没有将 0 转写为
长句 SLO。它支持“设备回到可见、可操作的普通键盘状态”的有限结论。

### 4.3 Unavailable 处理合规

addendum 对未在原始 run 捕获的 untracked content、opaque host/list ID、Full Access、
runtime/readiness、时间窗口/节奏没有从另一份证据继承，也没有填默认值；这符合 P2-PERF-02
“缺失值写 `unavailable`，不能用 0/false/旧 run 替代”的合同。

## 5. P0–P3 findings

### P0：0

没有发现设备数据破坏、隐私泄漏、错误默认开启或不可恢复状态的证据。

### P1：0

本 addendum 没有发现必须将 R03 标记为 Blocked 的身份冲突；原始 R03 仍能作为有界 gate-off
A baseline 使用。但以下 P2 证据绑定残余必须在任何 A/B 比较前处理或明确接受。

### P2-HQ-01：Human fixture 与 marker fixture 的 ID/digest 未建立契约映射

P2-PERF-02 canonical fixture 字段是 `T9-RESP-PERF-39-V1` 与其固定 digest；本 addendum 和
validator summary 使用的是 `T9RESP-R5P`，并另列 `ccb15564…` 的“derived” digest。当前材料
没有说明：

- `T9RESP-R5P` 是否只是 runtime marker/validator fixture 身份；
- 它如何映射到 P2 canonical human fixture；
- `ccb15564…` 的 canonical bytes/序列化算法是什么；
- 为什么该 digest 不等于 P2 contract 中的 canonical digest。

因此，本次确实证明了“validator 按 `T9RESP-R5P` expectation 看到 39 个 marker”，但没有独立
证明这 39 个 marker 属于 P2 contract 声明的同一个 Human fixture。Q3 不能因新增一条 derived
digest 而关闭；否则未来 A/B 可能把相同 action count 的不同 fixture 当成同源比较。

处置建议（不在本次执行）：保留两个命名空间并明确映射，例如 `humanFixtureID/digest` 与
`markerFixtureID` 分开记录；canonical human digest 使用既定 contract 值，marker ID 只作为
运行协议身份。若无法建立映射，新的 run header 应直接把 fixture digest 标为 `unavailable`，
而不是继续使用推导值。

### P2-HQ-02：Build/restore provenance 得到补强，但仍不是完整不可变 run identity

addendum 新增了 Xcode、SDK、deployment target、Swift、configuration、bundle IDs、观察到的
code-sign settings、诊断/恢复包 hash、CDHash、安装命令和 install sequence，明显优于原始
记录；但以下历史事实无法由事后文档修复：

- 原始 dirty worktree 的 untracked **内容** fingerprint 在构建前未捕获；只有名称 fingerprint；
- 没有随仓库提供可重开的原始 build/restore 输出及其 manifest，无法独立证明命令、产物和安装
  sequence 的一一对应；
- restore 没有完整独立的 source/build fingerprint 与时间窗口；签名 authority 也明确不可由
 现有 `codesign -dv` 输出恢复。

这些字段被正确保留为部分可观察/不可用，足以支持“已安装某个 hash 对应的普通恢复包”的
有限结论，不足以满足完整 run-header/restore identity。因此 Q2 仍为 `Partial`。

处置建议：新 run 在 build 前生成 content-free worktree/build/restore manifest，记录命令、
toolchain、产物 hash、安装结果和时间窗口；对未捕获字段继续写 `unavailable`，不要从旧 run
继承。

### P3-HQ-03：Validator summary 是布尔投影，不是完整 marker/path manifest

JSON summary 记录 `hasPathMarker=true`，但没有把 `path=sync`、`dualGateRequested=0`、
`dualGateActive=0`、expectation 的 `requireReadyMarker=false` 等值逐项保存；这些值目前只能
从原始证据正文和 validator 实现语义拼接出来。对 A 的当前 bounded 结论尚不致命，因为原始
证据保留了明确的 sync marker，但 summary 单独不可作为完整 path/gate 审计包。

处置建议：后续 summary 增加 expected/observed path、dual-gate fields、required-marker
configuration 与 missing-field reasons；保持 content-free。不能用 `status=complete` 覆盖
contract 层缺失。

### P3-HQ-04：事后补录的 build command 与 derived digest 缺少独立生成记录

addendum 中的命令、Xcode/SDK 版本和 fixture digest 是可读的 provenance 声明，但没有关联的
受控 build-record/manifest hash 或 digest-generation record。它们可以作为审查输入，不能被
解释为原始设备运行时“当场观察”的字段。该边界已经部分写进 addendum，但后续 handoff 需要
明确标注 `observed-at-run` 与 `post-run-attestation` 两种来源。

### P3-HQ-05：单键恢复 smoke 与长句性能、B/A-B 仍完全分离

`stallScore=0` 仅覆盖一个 benign key；原始 39-action A 仍只有一组人工观测。没有因此产生
长句 SLO、主观不卡顿、真实 off-main、A/B、jetsam/memory、iOS 26 Release RC 或 Product Gate
证据。B 与 A/B 仍是 `NotRun`/另行授权范围。

## 6. 契约层结论

| 层 | 结论 | 依据 |
|---|---|---|
| Validator/content-free | `bounded closed` | summary 完整到可审阅的 run/token/39/geometry/session/privacy 子集；原始内容未入仓库。 |
| Gate/path A | `bounded pass` | 原始 evidence 明确 sync/dualGate=0；summary 单独不足以重建全部 path fields。 |
| Human fixture binding | `Partial` | marker ID/digest 与 P2 canonical human ID/digest 未有映射。 |
| Build identity | `Partial, strengthened` | toolchain/flags/hash/commands 已补；dirty untracked content、完整 manifest、authority/time 仍缺。 |
| Restore | `Partial, strengthened` | 普通包 hash、install sequence、非破坏性声明和 post-restore smoke 存在；完整 restoreRef identity 仍不齐。 |
| Human result | `Partial` | 原始长 fixture stallScore unavailable；单键 smoke 的 0 未越权替代。 |
| A/B comparability / B | `NotRun` | 不在本次授权内。 |

**最终分类：R03 仍为 `Partial — gate-off baseline captured; validator and post-restore smoke
hardened; B comparison not run`。** `validator status=complete` 只描述该 validator 对其
expectation 的结果，不改变上述分类。

## 7. 下一步建议与停止点

1. 保留当前 R03 与 addendum，不重写历史 run header，不把 `T9RESP-R5P` derived digest 宣称为
   P2 canonical human fixture digest。
2. 若要关闭 Q2/Q3，先明确 human fixture 与 marker fixture 的映射/双字段模型，并在新 run
   header 中记录完整 content-free manifest；旧 run 无法捕获的字段继续是 `unavailable`。
3. 若 Product Lead 另行授权 B，必须使用新的独立 Run ID/token、同源设备/OS/host envelope 和
   明确的 canonical fixture binding；A/B 任何一臂缺字段都只能报告 observed direction，不能写
   A/B Pass。
4. 在本复核之后不执行设备操作、不开启 B、不修改生产逻辑、不接受 ADR 0025、不宣布 Product
   Gate 或 Release；后续交由 Product Lead 决定是否建立新 run。

本独立 Quality/Performance addendum review 到此停止。
