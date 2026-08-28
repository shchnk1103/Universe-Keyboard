# Product Decision: KOS-2-2-DOC-ALIGN-001 — 核心文档渐进对齐

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-KOS-2-2-DOC-ALIGN-001",
  "record_type": "decision",
  "title": "Align current governance documents with KOS 2.2 advisory",
  "status": "accepted",
  "updated_at": "2026-08-27T22:41:00+08:00",
  "revalidation_triggers": ["scope_changed", "record_envelopes_mode_changed", "kit_release_changed"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-27 Asia/Shanghai request to inspect and update prior documentation for KOS 2.2",
    "scope": "Audit and align current governance, startup, collaboration, dependency and health documents with the adopted KOS 2.2 advisory profile",
    "outcome": "Authorize a docs-only progressive alignment; do not bulk-backfill historical records or enable required mode",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | accepted |

---

## Decision

Human Product Owner 授权检查项目既有文档是否需要按已采用的 KOS 2.2 更新，并在确有需要时开始工作。

本次采用渐进对齐：先更新当前治理入口、协作流程和文档健康记录；历史记录仅在进入当前工作、发生实质修改或未来 `required` Migration 时纳管。不得为了 envelope 覆盖率猜测旧 authority、claim、environment、artifact 或 Gate 结论。

## Non-goals

- 不启用 `.kos/project.json` 的 `required` 模式。
- 不批量改写历史 Assignment、Decision、Evidence、Review 或 ADR。
- 不改变产品功能、架构合同、Quality 结论、Release/TestFlight 状态或 PR #83。
- 不把 validator 绿色输出解释为 Product、Architecture、Quality、merge 或 Release Gate。
