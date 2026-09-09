# KOS 改进建议：Scheme Delivery 工作复盘

日期：2026-09-09 Asia/Shanghai
状态：**建议稿；未采纳，不改变 KOS 2.0 / 2.1 规则或任何 Active Assignment**
输入：[CS09-10-02 真机失败证据](../evidence/scheme-delivery-cross-scheme-cs09-cs10-device-2026-09-08.md)、[runtime-route 提案](../plans/scheme-delivery-active-uninstall-runtime-route-reconciliation-2026-09-08.md)、KOS 2.1 M-01 至 M-06 与人工真机证据 Profile。

## 目的

本次工作没有发现 KOS 的 authority、独立审查或人工 Gate 原则失效。摩擦主要来自：自动化、CI、真机观察和后续提案之间缺少一个统一的“当前结论”表达；多个细粒度授权完成后，下一项需授权工作不够一目了然；运行时故障缺少与用户操作对应的诊断链路。

以下建议应当先按 KOS 的 System Governance 变更流程评审。采纳其中任何一项，需要新的 Product Assignment、Architecture review 和明确的迁移范围。

## 建议

| ID | 建议 | 解决的问题 | 建议落点 |
|---|---|---|---|
| KOS-SUG-01 | 为每条证据增加独立的 `Outcome`：`pass` / `fail` / `inconclusive` / `not-run` | 现有 M-04 的 grade 表示“谁产生证据”，但不表示结果。一条 Human-attested failure 应能显式压低与其冲突的自动化行为主张。 | KOS 2.1 evidence 模板与 Assignment Current Status |
| KOS-SUG-02 | 在每个 Active Assignment 增加简短的“授权前沿”表 | 可清楚列出已授权且进行中的片段、下一项需单独授权的片段、以及被设备/外部条件阻塞的片段。 | M-01 Current Status 模板；不增加新生命周期状态 |
| KOS-SUG-03 | 为候选交付增加“发布事实元组” | 区分本地 HEAD、已推送 head、CI 覆盖的 commit、PR 状态和未推送 docs-only 状态，避免“CI 已绿”被误读为覆盖本地后续提交。 | Handoff 模板、M-02 同步清单和 PR body |
| KOS-SUG-04 | 让人工运行 manifest 声明预期的内容无关诊断链路 | 人工测试前就知道每个操作应产生的 operation UUID、阶段、耗时和终态；日志缺失可以被判为 `inconclusive`，而非事后猜测 producer 或 reader。 | `universe-keyboard-human-operated-evidence-profile.md` 的 run manifest |
| KOS-SUG-05 | 固化“Proposed 工作包”交接头 | 当 Human 明确要求“只记录、不实现”时，未来线程可直接看到：问题、冻结事实、拟议 seam、授权边界、验证矩阵、停止条件和所需 reviewer。 | `docs/plans/` 模板；与 M-06 授权包相互链接 |
| KOS-SUG-06 | 增加 KOS 导航 pin 一致性检查 | `docs/kos/README.md` 仍写 KOS Kit `v0.6.0`，而 `UPGRADE_STATUS.md` 记录当前 adopted `v0.7.0`。这种导航级漂移会让零上下文线程读取到相互矛盾的事实。 | docs-only 检查：README、UPGRADE_STATUS、`.kos/project.json` 与升级记录 |
| KOS-SUG-07 | 在人工真机 Gate 前增加“可观测性就绪”检查 | 本次 `runtime_route.phase_changed` 事件已在诊断列表出现，但列表只显示 event code，不能证明 operation UUID、phase 或 elapsed 字段。应在操作前明确这些字段是否能从隐私安全的 UI 或导出中读取。 | 人工证据 Profile 的 preflight；不改变生产日志内容 |
| KOS-SUG-08 | 为原始诊断读取定义最小数据请求包 | 当 UI 不足以回答某个字段时，整目录读取可能超出本次诊断所需的数据范围。先固定 operation、文件范围、字段 allowlist 和保留方式，才可请求一次性读取授权。 | 人工证据 Profile 与 M-06 授权包 |
| KOS-SUG-09 | 将最终文档链接检查放入发布前状态同步 | 本次实现、测试和独立复审完成后，复审文档中的 `file.swift:line` 链接仍使 hosted lightweight CI 失败。最终证据与评审文档写入后还需跑一次同一链接检查。 | M-02 状态同步清单与 PR handoff |

## 建议的最小合同

### KOS-SUG-01：证据 grade 与结果分离

保留 M-04 的四种 grade，不重新定义其含义。证据记录额外拥有一个结果字段：

```text
grade: Executor-recorded | Quality-reverified | Device-attested
outcome: pass | fail | inconclusive | not-run
claim: <被验证的精确行为>
supersedes-or-conflicts: <可选的 claim / evidence pointer>
```

规则建议：同一环境和行为范围内，较高相关性的 `fail` 不会删除旧证据，但必须在 Assignment Current Status 中列为当前阻断事实；不能继续以较早的 `pass` 表述该行为“已完成”。本次“主 App Luna 部署成功”与“Extension Luna 可产生候选”应被写成两个不同 claim。

### KOS-SUG-02：授权前沿

建议在 Current Status 的 Next handoff 下添加至多三行：

| Slice | 状态 | 需要的决定 / 依赖 |
|---|---|---|
| 当前已授权片段 | 执行中 / 已得证据 | Assignment 指针 |
| 下一工程片段 | `awaiting-human-authorization` | 一句 M-06 packet 链接 |
| 外部/真机片段 | `awaiting-environment` | operator、设备或账号前置条件 |

它仅呈现授权边界，不替代 Product 决定，也不让 Executor 自行把下一行变为已授权。

### KOS-SUG-03：发布事实元组

每个需要 CI 或 PR 的 handoff 至少记录：

```text
local_head: <SHA>
published_head: <SHA | none>
hosted_ci_head: <SHA | unknown>
hosted_ci_result: green | red | pending | unknown
pr_state: draft | open | merged | none
local_ahead_of_published: <count>
```

这比单句“CI 全绿”更精确：后续 docs-only 或 code 提交存在时，读者不会误以为 hosted CI 已覆盖本地 HEAD。

### KOS-SUG-04：人工运行诊断 manifest

为每个可变操作声明：`runID`、操作顺序、预期 producer、预期事件、关联 ID、允许的延迟窗口和结果 capture 位置。对于 Scheme Delivery，活跃卸载应至少有：

1. route-before；
2. fallback route-after；
3. Luna deployment start/result/duration；
4. target staging start/result；
5. commit result；
6. Extension runtime route / session result。

事件只携带 schema identity、layout slot、operation UUID、布尔结果和耗时；不得记录拼音、候选文字、宿主文本或用户词典内容。缺少预期事件时，运行结果是 `inconclusive`，并保留设备观察本身。

### KOS-SUG-05：Proposed 工作包头

建议采用以下最小字段，而不是自动生成新的 Assignment：

```text
Status: Proposed / not implementation-authorized
Triggering evidence:
Frozen facts and unknowns:
Decision to preserve:
Proposed seam and alternatives rejected:
Verification matrix:
Stop conditions and non-goals:
Required authorization and reviewers:
Future-executor entrypoint:
```

本次 runtime-route proposal 说明这种格式可避免未来线程把“布局无关的方向”误读为已批准的 Swift 改动。

### KOS-SUG-07：人工 Gate 的可观测性就绪

在要求人工执行真机操作前，run manifest 增加一项只读 preflight：逐项列出
每个待验证 claim 所需的有限字段、该字段的可见位置，以及当前是否可读取。字段
不可见时应在 manifest 中把对应 claim 预先标记为 `inconclusive`，不要求操作者
绕过 UI 获取原始目录。

对于本次 active-uninstall 流程，功能 claim（卸载后切到 Luna，`ni` 有中文候选）
与 trace claim（同一 operation 的 phase、UUID、elapsed）必须分开记录。前者可以
由 `Device-attested / pass` 支持；后者在有限字段不可见时保持
`Device-attested / inconclusive`，不能由 event code 的出现推导。

### KOS-SUG-08：最小原始诊断读取请求包

当 KOS-SUG-07 的 preflight 显示 UI 不能提供必要字段，而继续诊断确有价值时，M-06
授权包应额外列出：

```text
operation identity: <UUID or bounded time window>
file scope: <exact file(s), never a directory by default>
field allowlist: <finite keys>
content exclusion: <input, candidate, host text, user dictionary>
retention and reporting: <where the filtered result is recorded>
```

没有这些字段时，Executor 只能保留“未获得”结论。该规则不是原始日志读取的自动
授权，也不要求新增持久化；它使人工决定能够针对最小数据范围作出判断。

### KOS-SUG-09：评审文档完成后的发布前检查

M-02 可增加一个适用于会触发 Markdown/KOS CI 的末尾步骤：在所有 Assignment、
evidence 和 review 文档落盘后，运行仓库的轻量检查，并记录其比较基线与 HEAD。
这一步必须位于最终文档编辑之后，因为先前通过的源代码测试不能覆盖后来写入的
本地 Markdown 链接。

Markdown 中引用仓库内具体行时使用可解析的锚点，例如
`path/to/file.swift#L77`，不使用 `path/to/file.swift:77`。前者保留读者所需的
定位信息，也能被现有本地链接检查识别为同一个文件。

## 采纳顺序建议

1. 先评审 KOS-SUG-01 和 KOS-SUG-02；它们只澄清当前事实和授权边界，收益最大。
2. 再将 KOS-SUG-03 纳入发布/CI handoff，形成可验证的交付状态。
3. 将 KOS-SUG-04 作为人工真机 Profile 的专项改进，不把它扩展为所有日志系统的强制遥测。
4. KOS-SUG-05 可作为 docs 模板试点；KOS-SUG-06 应先做一次 docs-only 一致性审计，再决定是否需要自动检查。
5. KOS-SUG-07 至 KOS-SUG-09 可先在 Scheme Delivery 的下一份人工 run manifest 和 PR handoff 中试点，再评估是否写入 KOS 2.1。

## 非目标

本建议不采纳任何新生命周期、新永久角色或自动授权机制；不改变 KOS 2.0 frozen constitution；不把 advisory 校验变成 Gate；不授权代码、真机、原始日志读取、push、合并、TestFlight、Release 或 ADR Accept。
