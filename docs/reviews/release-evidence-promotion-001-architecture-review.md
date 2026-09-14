# RELEASE-EVIDENCE-PROMOTION-001 — Independent Architecture Review

## Review Metadata

| Field | Value |
|---|---|
| Reviewer | Independent Architecture & Knowledge Steward |
| Review thread | `01a09dca-843d-73b0-92dd-33886bf9f9ce` |
| Review date | 2026-09-14 Asia/Shanghai |
| Review scope | 本地未提交工作树中的 release planner、Candidate receipt、Main App 发布证据存储/UI、测试与 ADR/KOS 路由 |
| Review mode | 只读独立复核；Reviewer 未修改仓库文件 |

## Decision

**Conditional Accept** — 架构边界和隐私方向基本成立，但在将 Proposed 设计纳入日常发布合同前，必须完成下列 P1/P2 修复并再次复核。

## Passed Boundaries

- Main App 负责记录和导出，Keyboard Extension 不进入发布证据写入路径。
- CI 分类与 release validation profile 保持独立；release profile 不替代 CI full 门禁。
- App Group 文件数量上限为 50，并使用原子写入。
- 证据不包含输入、候选文字、日志正文或 archive 内容。
- `daily_beta`、`external_candidate`、`pending`、`comparator` 与外部专属门禁的职责方向清晰。
- ADR 0035 保持 Proposed，未被实现或本次复核自动升级为 Accepted。

## Findings And Disposition

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| `REP-P1-01` | P1 | Main App promotion 在产物尚未核对时把 `evidenceReuse` 置为 pass；需要保证 pending 不会形成总体通过。 | `fix`；修复 `ReleaseEvidenceRun.outcome`、promotion 默认步骤与测试，待复核 |
| `REP-P1-02` | P1 | “完整候选事实元组”和 CLI 字段边界需要明确；当前证明还必须绑定证据上下文，而不能只比较版本/构建/哈希。 | `fix`；区分五个最小 identity 字段与 provenance 字段，并加入行为契约、环境、档位、候选绑定、证据版本、时效约束，待复核 |
| `REP-P1-04` | P1 | ADR 0027 的共享容器 ownership/lifecycle 表没有列出 release-evidence 子空间。 | `fix`；补充 owner、reader、上限、clear 隔离、损坏恢复和隐私边界，并增加自动测试，待复核 |
| `REP-P2-01` | P2 | `records.json` 损坏时 `save()` 先 `load()`，无法建立新会话；UI 的“重新开始”描述不准确。 | `fix`；隔离保留损坏文件后建立新 archive，待复核 |
| `REP-P2-02` | P2 | `note: String` 没有长度边界，存在无界持久化风险。 | `fix`；固定最大长度并在解码时重新裁剪，待复核 |

## Evidence Boundary

本评审不是 Quality Pass、Release Pass、Product Gate、设备验收、签名 archive 验收或 App Store Connect/TestFlight 操作授权。修复后的状态仍需独立 Quality 复核，最终是否采纳 ADR 0035 由 Human Product Owner 决定。

## Handoff

修复入口为 [RELEASE-EVIDENCE-PROMOTION-001 Assignment](../assignments/release-evidence-promotion-001.md)。修复后需重新交 Architecture，再交 Quality；任何复核通过均不改变外部动作授权边界。
