# Product Decision: testability child 残余接受（有界）

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-PRODUCT-RESIDUAL",
  "record_type": "decision",
  "title": "Accept F-01/F-02 bounded Pass residuals for the testability child",
  "status": "accepted",
  "updated_at": "2026-09-19T17:10:00+08:00",
  "revalidation_triggers": ["scope_changed", "implementation_changed", "evidence_invalidated"],
  "parent_refs": ["TYPO-CORRECTION-002", "TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "In-session 2026-09-19 Asia/Shanghai residual-acceptance scope lock",
    "scope": "Accept Quality/Architecture residuals for the keyboard UI testability/accessibility child only.",
    "outcome": "F-01 and F-02 accepted as bounded Pass; gap/nine-key/physical VoiceOver remain UNKNOWN and out of this child; globe hidden accepted as a system condition; no INT-003/QA-001/performance/parent/Release conclusion; child and parent remain not Closed",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-PRODUCT-RESIDUAL`
- **Lifecycle status:** `Accepted`
- **Date / timezone:** `2026-09-19 Asia/Shanghai`
- **Authorization:** [`AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-PRODUCT-RESIDUAL-001`](../authorizations/AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-PRODUCT-RESIDUAL-001.md)
- **Quality:** [`quality-consolidated`](../reviews/typo-correction-002-testability-accessibility-001-quality-consolidated.md) — Pass with conditions
- **Architecture F-02:** [`architecture-final`](../reviews/typo-correction-002-testability-accessibility-f02-architecture-final.md) — 有界 Pass

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Phase | 残余已按下列范围接受；child/parent **未 Closed** |
| Next | publication Authorization 后 commit / push / PR；不 merge；parent 继续 sidecar / INT-003 / QA-001 / 性能 |

## Accepted scope

| Residual | Product disposition |
|---|---|
| F-01 AX 独立键 + UIKit tap | **有界 Pass** |
| F-02 overlay 开/关同一 q 键面中心命中 | **有界 Pass** |
| 缝区 same-coordinate tap | **UNKNOWN** — 不纳入本 child |
| 九键 overlay 开/关 | **UNKNOWN** — 不纳入本 child |
| 真机 VoiceOver | **UNKNOWN** — 不纳入本 child |
| globe hidden | **接受为系统条件**（`needsInputModeSwitchKey` 为 false 时隐藏） |

## Explicit non-conclusions

不对本决策做 INT-003、QA-001、性能、parent `TYPO-CORRECTION-002` Close、Product Gate 或 Release 结论。
