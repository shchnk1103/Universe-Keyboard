# Assignment: KOS-2-2-DOC-ALIGN-001 — 核心文档渐进对齐

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "KOS-2-2-DOC-ALIGN-001",
  "record_type": "assignment",
  "title": "Align current governance documents with KOS 2.2 advisory",
  "lifecycle": "closed",
  "current_phase": "Human Product Review accepted; bounded KOS 2.2 advisory documentation alignment closed",
  "authorization_action": "align_kos_2_2_documentation",
  "updated_at": "2026-08-28T18:25:00+08:00",
  "revalidation_triggers": ["scope_changed", "record_envelopes_mode_changed", "kit_release_changed"],
  "authorization_refs": ["AUTH-KOS-2-2-DOC-ALIGN-001"],
  "parent_refs": ["KOS-UPGRADE-UK-001"],
  "responsibilities": {
    "domain_owner": "Architecture and Knowledge Steward",
    "executor": "Current Codex session",
    "environment_executor": "Current Codex session for local read-only validation",
    "human_dependency": "Human Product Owner for required-mode, bulk migration, or product authority changes",
    "architecture_reviewer": "Architecture and Knowledge Steward conformance review within this docs-only assignment",
    "quality_reviewer": "Not Applicable - docs-only structural validation; no product quality claim",
    "product_approver": "Human Product Owner"
  }
}
```

**Policy version:** `1.0.0`

**Repository Change Type:** `Documentation` + `Governance`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | closed |
| Current Phase | Human Product Review accepted; bounded KOS 2.2 advisory documentation alignment closed |
| Material non-claims | Advisory only; no `required`; no bulk legacy backfill; no product/Quality/Release conclusion; no PR #83 |
| Next handoff / decision | Published via PR [#86](https://github.com/shchnk1103/Universe-Keyboard/pull/86) merged `78ed5b5`. Any `required` or bulk-migration proposal needs a new Assignment |
| Residuals | Historical records and current product Assignments migrate only when next materially touched or under a separately authorized required-mode Migration |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-KOS-2-2-DOC-ALIGN-001`](../product-decisions/KOS-2-2-DOC-ALIGN-001-authorization.md), `2026-08-27 Asia/Shanghai`
- **Product Approver:** Human Product Owner

## Boundary

- **Scope:**
  1. 对照 KOS Agent Kit `v0.5.0` 的 adoption、ops、upgrade 与 project-adaptation 规范，审计当前文档。
  2. 更新当前治理、启动、协作、依赖、图谱与健康来源，使其明确 envelope、validator、advisory/required 和渐进迁移边界。
  3. 修复 PR #84 合并后的 KOS Upgrade 状态镜像。
  4. 将本 workflow 精确加入 advisory include，并记录可复现审计证据。
- **Non-goals:**
  - 不批量 envelope 历史记录，不猜旧 authority/claim/environment/artifact/Gate。
  - 不启用 `required`，不修改 KOS 2.0 冻结原则或 Assignment lifecycle。
  - 不改产品代码、测试、CI workflow、RIME、PR #83 或 Release/TestFlight 状态。
- **Required Inputs:**
  - [`KOS-UPGRADE-UK-001`](kos-upgrade-uk-001.md) 与 [`UPGRADE_STATUS`](../kos/UPGRADE_STATUS.md)
  - Human Product Review [`PD-KOS-2-2-DOC-ALIGN-001-GATE`](../product-decisions/KOS-2-2-DOC-ALIGN-001-product-gate.md)
  - Kit `v0.5.0` adoption、operational reliability、upgrade governance 与 project adaptation 文档
  - [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md)、[`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)、[`KNOWLEDGE_OS.md`](../KNOWLEDGE_OS.md)

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** 当前 Codex 会话
- **Environment Executor:** 当前 Codex 会话，仅执行本地只读 validator、格式与链接检查
- **Human Dependency:** Human Product Owner，仅当范围需要扩大到 `required`、批量迁移或产品权威改变
- **Architecture Reviewer:** Architecture & Knowledge Steward 在本 docs-only Assignment 内做规范一致性复核；不宣称独立审查
- **Quality Reviewer:** Not Applicable — docs-only 结构校验，不产生产品 Quality 结论

## Gates

- **Entry Criteria:** Human 已明确授权检查并更新；Kit pin 与 advisory Profile 可读；Assignment 无 `UNKNOWN`。
- **Exit Criteria:** 核心文档边界一致；渐进纳管规则明确；PR #84 状态同步；审计证据包含命令与结论；KOS validator、格式与本地链接检查通过。
- **Stop Conditions:** 需要启用 `required`、批量迁移、猜测历史权威、改变产品/Quality/Release 结论，或 validator 尝试写入项目。

## Handoff

- **Handoff Target:** Human Product Owner
- **Required Handoff Content:** 必修项、明确保留的 legacy 范围、修改文件、验证结果、未执行检查及后续触发条件。
- **Revalidation Trigger:** Kit 新 Release、Profile mode/include 策略改变、现有 Active Assignment 被实质修改，或 Product 决定进入 required-mode Migration。

## History

- `2026-08-27 Asia/Shanghai`: Human Product Owner 授权检查并按需要更新此前文档；Assignment 进入 `Active`，仅限 docs-only advisory 渐进对齐。
- `2026-08-28 Asia/Shanghai`: 核心文档对齐、PR #84 状态同步与里程碑审计完成；`git diff --check`、变更文件本地链接检查及 Kit `v0.5.0` advisory validator 通过。Assignment 进入 `Completed`，等待 Human Product Review；不自动 `Closed`。
- `2026-08-28 Asia/Shanghai`: Human Product Owner 明确接受本 Assignment 的 Human Product Review，并授权状态同步、清理已合并旧 KOS worktree/分支及创建 PR（暂不合并）。Assignment `Closed`；不启用 `required`，不授权历史批量迁移。
