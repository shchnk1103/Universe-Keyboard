# Product Decision: CI-HEAVY-JOB-SPLIT-001 — 接受 heavy job 拆分 Assignment 范围

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-CI-HEAVY-JOB-SPLIT-001",
  "record_type": "decision",
  "title": "Accept and implement bounded CI heavy-job split Assignment",
  "status": "accepted",
  "updated_at": "2026-09-15T10:29:15+08:00",
  "revalidation_triggers": ["scope_changed", "workflow_contract_changed", "required_checks_changed", "skip_rule_requested"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-15 Asia/Shanghai instruction: 可以，按照你的建议写一个 Assignment 吧。",
    "scope": "Record the Assignment that splits the full-path Swift 6 heavy job for parallel localization and drops the redundant Debug build, without new skip rules",
    "outcome": "Authorize authoring, then implementation of the bounded heavy-job split; keep publication, merge, branch protection and required-check migration behind later Human review",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Current phase | 隔离功能分支 commit/push 已授权；merge 仍未授权 |
| Material non-claims | 不引入路径跳过；不迁移 required checks；不 merge；不 Release |
| Next decision | hosted `full` 结果与是否另开不合并的 `docs_only` fixture；merge 仍须另授权 |
| Residuals | 见 Assignment ledger：CHS-A-02 closed；CHS-Q-01/02/03 仍为 `fix`；A-P2-02 仍 TD-016 |

---

## Decision

Human Product Owner 在 `2026-09-15 Asia/Shanghai` 接受先前讨论的有界方案，并要求写成 Assignment：

- `docs_only` / `full` 分类保持 ADR 0031 fail-closed 合同；
- `full` 路径把现在的单一 `build-and-test` 拆成可并行 heavy jobs，用于定位失败和缩短墙钟时间；
- 去掉 Debug `test` 之后重复的 Debug `build`；
- Release `build` 仍留在每个 `full` 变更上；
- **不**按 UI / Rime / KeyboardCore 等路径跳过测试。

Human Product Owner 随后在同一日接受 Assignment 并授权实施（「接受这份 Assignment 并开始实施吧」）。实施授权见 [`AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT`](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT.md)。仍不授权 commit、push、PR、merge、branch protection 或 required-check 迁移。

## Non-goals

- 不降低 Swift 6、warnings-as-errors、RIME artifact 或现有测试要求。
- 不通过 `paths-ignore` 或新的路径 allowlist 隐藏检查。
- 不把 Release build 限制为仅 `main`。
- 不关闭 [TD-016](../TECH_DEBT.md#td-016-ci-变更分级与文档提交快速门禁) 的 required-check trust-root 残余。
- 不启用 KOS `required`，不加入跨仓库 secret。

## Related Records

- Assignment: [`CI-HEAVY-JOB-SPLIT-001`](../assignments/ci-heavy-job-split-001.md)
- Authorization: [`AUTH-CI-HEAVY-JOB-SPLIT-001`](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001.md)（撰文）· [`AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT`](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT.md)（实施）
- Predecessor: [`TD-016-CI-TIERING-001`](../assignments/td-016-ci-tiering-001.md)（Closed）
- ADR: [0031](../architecture/decisions/0031-fail-closed-ci-change-classification.md)（Accepted；实施时修订 job 合同，不新开 ADR）
