# Authorization: AUTH-KOS-2-2-DOC-ALIGN-001 — 对齐当前治理文档

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KOS-2-2-DOC-ALIGN-001",
  "record_type": "authorization",
  "title": "Align current governance documents with KOS 2.2 advisory",
  "status": "active",
  "updated_at": "2026-08-27T22:41:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "record_envelopes_mode_changed"],
  "authorization": {
    "action": "align_kos_2_2_documentation",
    "target": "KOS-2-2-DOC-ALIGN-001",
    "artifact_bindings": [],
    "scope": "Docs-only audit and alignment of current governance, startup, collaboration, dependency and documentation-health sources under KOS 2.2 advisory",
    "exclusions": ["required_mode", "bulk_legacy_backfill", "product_code", "product_or_quality_conclusion", "release", "merge_pr_83"],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-27 Asia/Shanghai request to inspect and update prior documentation for KOS 2.2",
    "issued_at": "2026-08-27T22:41:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "unconsumed"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | active |

---

本收据只授权本次 docs-only 渐进对齐。它不授权 `required`、历史批量回填、产品/测试/发布状态改变或 PR #83。

对应 bounded action 已完成并进入 Human Product Review。由于当前 advisory validator 要求 Assignment 引用 `active` AUTH，机器状态暂保留 `active/unconsumed`；这不构成重放许可，终态消费语义统一由 [`TD-014`](../TECH_DEBT.md#td-014-kos-22-auth-consumption_state-卫生) 追踪。
