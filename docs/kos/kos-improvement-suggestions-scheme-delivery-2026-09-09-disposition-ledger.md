# KOS 改进建议处置台账：Scheme Delivery 复盘

> **Superseded assessment snapshot:** the table below records the pre-decision assessment. Current dispositions are in [PD-KOS-IMPROVEMENT-SUGGESTIONS-001](../product-decisions/KOS-IMPROVEMENT-SUGGESTIONS-001-disposition.md) and the current table below.
>
> **权威任务：** [KOS-IMPROVEMENT-SUGGESTIONS-001](../assignments/kos-improvement-suggestions-001.md)
> **输入冻结：** [建议稿](kos-improvement-suggestions-scheme-delivery-2026-09-09.md)（`2026-09-09 Asia/Shanghai`）

## 处置规则

每一行只能由 Human Product Owner 在独立 Architecture 与 Quality 文档审查后选择
`Adopted`、`Deferred` 或 `Not applicable`。`Adopted` 不等于可实施：它必须再获得
一个有明确迁移范围、验证和授权链的 implementation Assignment。`Deferred` 必须给出
重审触发条件；`Not applicable` 必须给出为什么该项目不需要它的理由。

| ID | 建议与现有合同关系 | 受影响的权威来源 / 边界 | 评估必须回答的问题 | 迁移与验证形状 | 当前处置 |
|---|---|---|---|---|---|
| KOS-SUG-01 | 独立 Outcome；与 E-01 有部分重叠，但不是已采纳的 E-01 全量实现 | 证据模板、M-04 grade 语义、Assignment Current Status | Outcome 是否只描述观察结果，而不取代 grade、Gate 或 Product Decision？冲突是否 fail-closed 为 `inconclusive`？ | 仅新证据记录；禁止回填历史。以证据模板字段和冲突示例验证。 | Pending Product disposition |
| KOS-SUG-02 | 授权前沿；与 A-01/B-01 有部分重叠，但固定表格式尚未采纳 | Assignment Policy、Assignment 模板、Authorization / Decision chain | 前沿能否显示已授权、待授权与阻塞片段，而不把状态镜像当 authority？ | 仅新 Assignment；需完整 authority-chain 和模板审查。 | Pending Product disposition |
| KOS-SUG-03 | 发布事实元组；与 P-01 部分重叠 | Handoff 模板、Git/PR/hosted-CI 事实、M-02 / PR handoff | local、published、hosted 三个候选头如何取得并判定 `same-head`？ | 仅发布/PR Assignment；需要同头或明确 `unknown` 的手工/hosted 验证。 | Pending Product disposition |
| KOS-SUG-04 | 人工运行 manifest 的预期内容无关诊断链 | 人工证据 Profile、隐私边界、真机 run manifest | operation、phase、elapsed、终态能否在不记录用户内容的前提下预先声明和读取？ | 仅新真机证据 Assignment；需隐私审查与 Human Dependency。 | Pending Product disposition |
| KOS-SUG-05 | Proposed 工作包交接头 | `docs/plans/` 生命周期与 M-06 交接 | 该头是否保留计划和授权的区分，且不把 proposal 写成 current truth？ | 仅新 Proposal/plan；模板链接和一个 bounded 示例审查。 | Pending Product disposition |
| KOS-SUG-06 | KOS navigation pin 一致性检查 | `UPGRADE_STATUS`、`.kos/project.json`、KOS README、Knowledge OS、CI current wording | 哪些文件是当前镜像，何时检测，自动化检查是否值得引入？ | 本次仅修正已知 v0.8 文案漂移；自动检查另需 CI/脚本 Assignment 与完整验证。 | Pending Product disposition |
| KOS-SUG-07 | 人工 Gate 前的可观测性就绪 | 人工证据 Profile、诊断 UI、隐私边界 | UI/导出是否能读取所需字段；不能时应如何提前标为 `inconclusive`？ | 仅新真机 Assignment；需 preflight、隐私审查和人类操作。 | Pending Product disposition |
| KOS-SUG-08 | 最小原始诊断读取请求包 | M-06、原始数据读取授权、隐私/保留边界 | 如何限定 operation、文件、字段 allowlist、保留方式和一次性授权？ | 仅确有必要的数据读取 Assignment；需单独 Human authorization 与验证留痕。 | Pending Product disposition |
| KOS-SUG-09 | 最终文档链接检查；与 D-01 部分重叠 | D-01 receipt、M-02、链接检查器和 PR handoff | 最终内容变化后，哪个检查器、版本、范围和输出构成有效 receipt？ | 仅文档/发布 handoff；最后一次内容改动后重跑指定检查。 | Pending Product disposition |

## 已知边界

- 本台账不把 v0.8.0 的 E-01、A-01/B-01、P-01 或 D-01 误写成建议稿的整体采纳；这些合同仅在新的记录明确 opt-in 时可用。
- SUG-04、SUG-07、SUG-08 需要先确认隐私、诊断和 Human Dependency，不得以 docs-only 结论代替。
- SUG-06 的本次文本修复是 M-02 文档缺陷修复，不是对“自动一致性检查”的采纳。
- 每个未来 `Adopted` 项目必须单独建 implementation Assignment；只有 Product 明确把同一组项目写入一个有逐项迁移边界的 Assignment 时，才可作为例外合并处理。

## Current Product dispositions

| ID | Disposition | Effective boundary / trigger |
|---|---|---|
| KOS-SUG-01 | Adopted | New evidence records only; no historical backfill; implementation needs a new Assignment. |
| KOS-SUG-02 | Adopted | New formal Assignments only; the frontier cannot create authority. |
| KOS-SUG-03 | Adopted | Publication/PR handoffs only; unknown candidate identity remains unknown. Template implementation: [`KOS-SUG-PUB-HANDOFF-001`](../assignments/kos-sug-pub-handoff-001.md). |
| KOS-SUG-04 | Deferred | Reconsider only after SUG-07 preflight proves required content-free fields are readable and a specific human-device claim needs the manifest. |
| KOS-SUG-05 | Adopted | Proposed-plan template pilot only; it does not authorize implementation. |
| KOS-SUG-06 | Adopted | Manual docs-only pin audit first; CI/script automation needs a separate Assignment. |
| KOS-SUG-07 | Adopted | New human-device Assignments only; privacy and Human Dependency remain required. Template implementation: [`KOS-SUG-OBS-PREFLIGHT-001`](../assignments/kos-sug-obs-preflight-001.md) (docs-only preflight; no device run). |
| KOS-SUG-08 | Adopted | Only if SUG-07 is insufficient and a separate minimal data-read authorization exists. |
| KOS-SUG-09 | Adopted | Commit/PR handoffs only; final documentation changes require a recheck. Template implementation: [`KOS-SUG-PUB-HANDOFF-001`](../assignments/kos-sug-pub-handoff-001.md). |

## 后续授权边界

本次 Product Decision 只冻结当前处置表的方向、适用范围和 SUG-04 重审触发条件。任何
`Adopted` 行的模板、KOS 规则、CI、隐私、诊断、设备或发布实现，均需新的 bounded
implementation Assignment、明确迁移范围和匹配授权；本台账不创建这些工作。
