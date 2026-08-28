# Product Decision: TD-016-CI-TIERING-001 — CI 变更分级与稳定最终门禁

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-TD-016-CI-TIERING-001",
  "record_type": "decision",
  "title": "Implement fail-closed CI change classification",
  "status": "accepted",
  "updated_at": "2026-08-28T20:30:00+08:00",
  "revalidation_triggers": ["scope_changed", "workflow_contract_changed", "required_checks_changed"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-28 Asia/Shanghai instruction to implement TD-016 and decide PR packaging after validation",
    "scope": "Implement auditable docs-only versus full CI classification, lightweight common checks, cancellation of stale runs and an always-run final gate",
    "outcome": "Authorize isolated implementation and validation; keep merge and branch-protection mutation behind later Human review",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Current phase | Consumed by Human Product Gate; PRs merged |
| Material non-claims | No branch-protection/required-check mutation; no KOS required mode; no secret; no Release |
| Next decision | None. Required-check migration needs a new Product Decision |
| Residuals | [`TD-016`](../TECH_DEBT.md#td-016-ci-变更分级与文档提交快速门禁) |

---

## Decision

实施 TD-016，但保持 fail-closed：只有根目录 Markdown、`docs/**` 与 `.kos/**` 的变更
可以走轻量路径；Swift、测试、工程、Package、RIME/Lua/词典、资源、脚本、workflow
以及任何未知路径都必须运行完整 Swift 6 门禁。分类、轻量检查和最终聚合 Gate 始终运行。

实现从 PR #86 当前 tip 建立独立堆叠分支。完成后根据实际 diff 与验证决定是否保持
独立 PR；本决定不授权把 workflow 改动静默塞入 #86，也不授权 merge。

## Non-goals

- 不降低 Swift 6、warnings-as-errors、RIME artifact 或现有测试要求。
- 不通过 `paths-ignore` 隐藏 required check。
- 不修改 GitHub branch protection 或 required checks。
- 不加入 PAT、代理凭据或其他跨仓库 secret。
- 不启用 KOS `required`，不复制私有 KOS Kit validator 到本仓库。
