# Architecture Review：P3-D1-R03 Q2/Q3 evidence hardening

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立、只读） |
| 日期 | 2026-08-03（Asia/Shanghai） |
| 复审对象 | [`Q2/Q3 evidence hardening`](t9-responsive-pipeline-001-p3-d1-r03-q2-q3-evidence-hardening.md)、[`R03 Assignment`](t9-responsive-pipeline-001-p3-d1-r03-device-baseline.md)、[`R03 device evidence`](../evidence/t9-responsive-pipeline-p3-d1-r03-device-2026-08-03.md)、[`Evidence Hardening follow-up`](../evidence/t9-responsive-pipeline-p3-d1-r03-evidence-hardening-followup-2026-08-03.md) |
| Run ID | `P3D1-R03-OFF-20260803-001` |
| Architecture verdict | **Pass with conditions（仅 Q2/Q3 证据补强层，bounded）** |
| 父矩阵状态 | **保持 `Partial — gate-off baseline captured`** |
| 治理边界 | 不接受 ADR 0025，不打开 B，不形成 Release、Product Gate 或用户 SLO 结论 |

## 1. 复审范围

本次只读复审检查补强文档是否把事后可读取的 build/restore/fixture 信息误写成原始设备
运行观测，以及 `unavailable` 是否被诚实保留。复审不重跑设备、构建、validator 或测试，
不修改原始附件、生产逻辑、默认 gate、矩阵或 ADR。

先前 [`R03 Architecture review`](t9-responsive-pipeline-001-p3-d1-r03-device-architecture-review.md)
对同步 RIME/processKey 与主观卡顿的方向性判断仍然有效；本文件只复核证据完整性补强，
不重新解释性能因果关系。

## 2. 证据分层检查

| 信息 | 当前处理 | Architecture 判断 |
|---|---|---|
| 原始 source/dirty-state、App/appex hash、设备与 gate/path marker | 继承原始 R03 Run ID 和记录值 | 可作为原始 run 的 bounded observed facts；仍不等于完整可重放构建 |
| Xcode/SDK/deployment target/Swift/code-sign settings、restore CDHash 与 install sequence | 标题和正文说明为从既有 build/restore record 事后读取；addendum 未重建或重装 | 可以作为 post-hoc provenance evidence；不能回填为“运行开始前已捕获的 run-header 观测”，也不能替代完整命令/manifest |
| untracked-content fingerprint | 明确为 `unavailable`，原因是设备构建前未捕获 | 诚实，不能用 untracked-name fingerprint 代替内容绑定 |
| host opaque ID、Full Access、runtime/schema/readiness、原始时间窗 | 均写为 `unavailable`，并说明原始 run 未记录；`T9RESP path=sync` 单独保留 | 没有把 `sync` 误写成 `READY` 或 B-ready；Q3 仍应为 Partial |
| Fixture ID `T9RESP-R5P` | 由 validator expectation/marker 观察得到 | 可作为 marker fixture identity；不是原始人工报告中完整 fixture 复核 |
| Fixture digest `ccb155…` | 明确写为从声明的 synthetic fixture **派生**，content-free | 只能是 post-hoc derived metadata。它与 P2-PERF-02 canonical digest `772b4b…` 的字节序列化不同（前者包含额外行尾变体），addendum 未冻结 hash input/规范化方法，因此不能证明同一 canonical fixture 或 A/B 可比性 |
| validator 与恢复后单键 smoke | 由 follow-up 的受控摘要提供 | 关闭“无法重开/无恢复后可见冒烟”的 bounded 缺口；不升级为长句、完整生命周期或性能通过 |

第一性原理结论是：addendum 可以增加“从现存 artifact 读到的事实”和“明确标记的派生
摘要”，但不能改变原始 R03 run 已经捕获了什么。当前文档总体遵守这个边界，不过 fixture
digest 的规范化差异必须保留为残余，不能让下游把它当作新的原始观测。

## 3. P0–P3 findings

### P0：0

没有发现数据破坏、隐私泄露、不可恢复设备状态或错误默认开启的 P0 问题。

### P1：0

没有发现必须阻断这份 bounded evidence addendum 归档的架构缺陷。其缺口会限制结论范围，
但不会把同步路径误接成 B 路径。

### P2：2

#### ARCH-R03-Q2Q3-P2-01：fixture digest 不是已证明的 canonical digest

addendum 的 `ccb155…` 明确是事后派生值；与 P2-PERF-02 固定合同的 `772b4b…` 不一致，
差异符合输入字节包含额外 line-ending 的序列化变体。文档没有给出不含用户原文的
canonical hash input 规范、生成脚本/版本或 manifest 字段，因此该 digest 不能证明原始
39-action run 使用了合同定义的同一 fixture，也不能支撑 A/B comparability。

**处置：** 保留两个 digest 及其 provenance；把 addendum 值标为 `derived/post-hoc`，不覆盖
P2-PERF-02 canonical digest。任何新 A/B run 必须在 run header 生成前冻结 hash input 规范，
并让 validator/manifest 绑定同一个 fixture ID + canonical digest。

#### ARCH-R03-Q2Q3-P2-02：post-hoc provenance 不能扩展 immutable run header

补强表格把新 build/restore 字段组织得很清楚，但 parent R03 Assignment 已链接该 addendum。
若下游只读取“Evidence record”而忽略 `observed from existing build record`、`derived` 和
`unavailable` 标签，容易把事后读取的 SDK、签名、CDHash 或 fixture digest 看成运行开始前
的原始观测，进而误称 source/build/restore 已完整 immutable-bound。

**处置：** 归档和后续报告必须保留三态 provenance：`observed-at-run`、`observed-post-hoc`
和 `derived`；缺失字段继续写 `unavailable`，不得把 addendum 合并成原始 run header 或升级
Q2/Q3/整体 R03 状态。

### P3：2

#### ARCH-R03-Q2Q3-P3-01：unavailable 缺少统一的 owner/retry 说明

`untracked-content`、host ID、Full Access、runtime/readiness 和 time window 已诚实写成
`unavailable`，但各字段没有统一列出负责补录的 owner 与 retry condition。它们因此可用于
历史证据的有界说明，却还不是下一次 capture 可直接执行的缺口清单。

**处置：** 下一次新 Run ID 的 run header 为每个 unavailable 字段附 `reason/owner/retry`
三元组；本次历史 run 不应通过回忆或另一 run 补值。

#### ARCH-R03-Q2Q3-P3-02：restore identity 不等于完整恢复生命周期证明

普通包 app/appex hash、CDHash、install sequence 与单键 smoke 已提供有价值的恢复证据，
但仍没有证明长句性能、进程终止/重载、schema/readiness 或完整 keyboard lifecycle 在恢复
后均正常。addendum 没有把单键 `stallScore=0` 扩大成 SLO，这是正确的。

**处置：** 保持 restore 结论为“同源普通包替换 + bounded visible smoke”；完整生命周期或
性能恢复需要新的、明确授权的设备 run，不得改写本次历史记录。

## 4. ADR、gate 与隐私边界

- **ADR 0004：** `T9RESP path=sync` 仍对应现行 MainActor/主线程串行 session 规则。
- **ADR 0025：** 继续为 `Proposed`；本 addendum 没有 owner-thread、真实 librime 或
  `@unchecked Sendable` 接线，也不构成 ADR 接受。
- **默认 gate：** 没有启用 responsive/thread-affine 或 auto-anchor enabled flag；addendum
  不修改 Release default。
- **B/A：** 没有新增 B、没有 A/B 对照、没有把 `T9DEVICE gate=off` 解释成 B 证明；R03 仍为
  gate-off A baseline。
- **隐私：** 文档只保留 content-free digest/summary，不复制原始拼音、候选、宿主文本、
  user dictionary 或凭据；fixture digest 的派生性质和 validator summary 的边界均应保持可见。

## 5. 已证实与未证实

### 已证实（bounded）

1. 既有 R03 Run ID、设备、gate/path、App/appex hash 与恢复包摘要可以继续追溯。
2. 补强文档没有把历史未捕获的 untracked content、host ID、Full Access、runtime/readiness
   或原始时间窗补猜成 observed。
3. validator reopenability 与恢复后单键 smoke 已有 content-free follow-up 摘要。
4. addendum 明确 Q2/Q3 仍 Partial，且没有授权 B、ADR 0025 或 Release/Product Gate。

### 未证实

1. addendum 派生的 fixture digest 与 P2-PERF-02 canonical fixture 的语义等价性。
2. 完整 source/build/restore 可重放性、原始 command/manifest 与 dirty untracked-content 绑定。
3. Full Access、schema/runtime/readiness、时间窗口和 host opaque ID 的历史真实状态。
4. off-main/thread-affine 改善、A/B、真实 librime、jetsam、Release RC 或用户 SLO。

## 6. Verdict 与下一步建议

本次 **Pass with conditions（bounded evidence hardening）** 只表示：补强文档在总体上诚实地区分
原始观察、事后读取、派生值和 unavailable，并且没有越过 ADR 0025/默认 gate/B 边界。它不关闭
Q2/Q3，不提升 R03，不是 Quality Pass 或 Product 决策。

若 Product Lead 未来授权新 A/B 或 B spike，建议先冻结 canonical fixture hash 规范和完整
run-header（含 unavailable 的 reason/owner/retry），再生成新的 Run ID；不得把本 addendum
的事后 digest 或恢复摘要继承到新 run。

## 7. 停止声明

独立 Architecture 只读复核已完成。本角色未运行测试、未操作设备、未修改生产逻辑、默认 gate、
原始证据、矩阵或 ADR；到此停止，交由独立 Quality 与 Product Lead 处理后续决策。
