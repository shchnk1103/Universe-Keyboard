# Product Decision: SCHEME-DELIVERY-JOURNAL-001 — 方案交付写入诊断 v1

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-SCHEME-DELIVERY-JOURNAL-001",
  "record_type": "decision",
  "title": "Authorize scheme-delivery v1 journal assignment",
  "status": "accepted",
  "updated_at": "2026-08-28T21:10:00+08:00",
  "revalidation_triggers": ["scope_changed", "diagnostic_protocol_changed"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-28 Asia/Shanghai instruction to continue #83 as rebase, TD-015 journal, then Human retest",
    "scope": "Create SCHEME-DELIVERY-JOURNAL-001 to make download/integrity/install/deploy visible in Diagnostics/v1 without high-fidelity or merge",
    "outcome": "Authorize implementation and tests on the #83 branch after merging current main; merge of #83 remains separately unauthorized",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Current phase | Implementation on rebased #83 |
| Material non-claims | No merge; no Release; no high-fidelity change; no integrity weakening |
| Next decision | Human retest of v1 rows, then a later merge authorization |
| Residuals | [`TD-015`](../TECH_DEBT.md#td-015-方案交付日志未进入诊断-v1-journal) |

---

## Decision

在再次分类万象失败之前，方案交付必须把下载、完整性、安装、部署边界写入
ADR 0027 的有界 v1 `DiagnosticEvent`。PR #83 已实现 typed `scheme_delivery.*`
payload；本决定把它收口为独立 Assignment，而不是静默算进 INTEGRITY-001。

显示层只使用已审查枚举。Human 复测搜索 `scheme_delivery` 或 `wanxiang`，
不要期待自由中文「万象」字符串，也不要打开首屏高保真来补这条管道。
