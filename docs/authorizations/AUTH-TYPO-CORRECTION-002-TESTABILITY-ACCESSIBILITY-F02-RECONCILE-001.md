# Authorization: AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001 — F-02 证据与状态对账

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Current phase | docs-only 对账已写入；本收据不可再用于新的证据采集或发布 |
| Non-claims | 不是 Product Gate、不是 child/parent Close、不是 publication |
| Next | 独立 Architecture 最终收口与 consolidated Quality verdict 需**新** Authorization |

Human Product Owner, current session `2026-09-19 Asia/Shanghai`: **「建立一个新的 F-02 closure/reconciliation Authorization，仅允许更新证据和状态，不改代码、不发布。」**

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001",
  "record_type": "authorization",
  "title": "Reconcile F-02/QR-01 overlay on/off evidence and status only",
  "status": "consumed",
  "updated_at": "2026-09-19T16:20:00+08:00",
  "revalidation_triggers": ["scope_changed", "authority_revoked", "implementation_changed", "evidence_invalidated"],
  "authorization": {
    "action": "reconcile_f02_qr01_evidence_and_status",
    "target": "TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/authorizations/AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001.md"},
      {"kind": "file", "identity": "docs/assignments/typo-correction-002-testability-accessibility-f02-reconcile-001.md"},
      {"kind": "file", "identity": "docs/evidence/typo-correction-002-testability-accessibility-f02-reconciliation.md"},
      {"kind": "file", "identity": "docs/ACTIVE_WORK.md"}
    ],
    "scope": "Docs-only reconciliation of Architecture F-02 and Quality QR-01 for Debug touch-range overlay on/off at the same visible letter-key coordinate. May create or update a docs-only Assignment, evidence receipt, residual disposition, and Active Work status mirror. Bind existing Simulator runs without reinterpreting them as Product Gate. No Swift, no test-code edits, no new action path, no publication.",
    "exclusions": [
      "swift_implementation",
      "uikit_change",
      "keyboardcore_change",
      "rime_or_sidecar_change",
      "test_source_change",
      "new_toggle_or_instrumentation",
      "host_text_injection",
      "private_simulator_api",
      "int_003",
      "qa_001",
      "nine_key_claim",
      "physical_voiceover_claim",
      "performance_claim",
      "product_gate",
      "quality_pass_as_release",
      "parent_typo_correction_002_close",
      "commit",
      "push",
      "pr",
      "merge",
      "branch_cleanup",
      "testflight_upload",
      "app_store_connect",
      "release_pass",
      "profile_include",
      "required_mode"
    ],
    "issuer_role": "Human Product Owner",
    "decision_source": "in-session 2026-09-19 Asia/Shanghai instruction: 建立一个新的 F-02 closure/reconciliation Authorization，仅允许更新证据和状态，不改代码、不发布",
    "issued_at": "2026-09-19T16:00:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

## Allowed

本收据只授权 **docs / status** 对账：

1. 新建或更新 docs-only Assignment
   `TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001`（若 Assignment Policy 要求有独立工作项）。
2. 写入 F-02 / QR-01 证据收据，绑定已存在的 raw artifact，不改写运行事实：
   - Arm A overlay OFF：`QR-F02-REVAL-20260919T071659Z-FC1AEA63`（q 中心、`TOUCHPROBE ov=0`、`insertKey`）。
   - Arm B overlay ON：`QR-F02-REVAL-20260919T073732Z-113A0BDB`（同一坐标 `(25.65, 697.5)`、`TOUCHPROBE ov=1`、橙色 overlay 截图、`KBDVIS`/`insertKey`）。
3. 更新 residual 状态：QR-01 在 **26 键 Messages、q 键面中心、iPhone 17 Pro Max / iOS 27 Simulator** 上可记为有界 Pass；缝区、九键、真机 VoiceOver 仍 UNKNOWN。
4. 仅在上述事实已写入收据后，同步 `docs/ACTIVE_WORK.md` 的状态镜像（不把镜像写成生命周期 Source of Truth）。
5. 必要时在 parent `TYPO-CORRECTION-002` 或 testability 切片记录中 **链接** 本收据；不得把 parent Assignment 标为 Closed。

## Forbidden

- 任何 `.swift` / 工程 / 测试源码 / RIME / sidecar / 布局改动。
- 新增 overlay toggle、instrumentation 或第二条命中路径。
- commit、push、PR、merge、分支清理、TestFlight、App Store Connect、Release。
- 把本对账写成 Product Gate、INT-003、QA-001、性能或真机无障碍结论。

## Bound evidence (reference only)

这些路径是对账输入，不是本收据新跑的结果：

| Arm | Run ID | Pointer |
|---|---|---|
| overlay OFF | `QR-F02-REVAL-20260919T071659Z-FC1AEA63` | `/tmp/uk-f02-reval/QR-F02-REVAL-20260919T071659Z-FC1AEA63/` |
| overlay ON | `QR-F02-REVAL-20260919T073732Z-113A0BDB` | `/tmp/uk-f02-reval/QR-F02-REVAL-20260919T073732Z-113A0BDB/` |

Worktree 实现切片仍停在
`/private/tmp/universe-keyboard-typo-correction-002-testability-accessibility-001`
基线 `9eb83158e49218c1e8f75dbe7dd9e0390db81409`。本 AUTH **不**授权提交该切片。

## Stop conditions

- 需要对代码或测试才能「补齐」证据。
- 要把有界 Simulator 结论升级为 Product / Release / parent Close。
- 发现 Arm A / Arm B 坐标、overlay 状态或 action path 对不上，且无法在 docs 中诚实标 UNKNOWN。

> **Consumed:** [`TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001`](../assignments/typo-correction-002-testability-accessibility-f02-reconcile-001.md) · [`evidence`](../evidence/typo-correction-002-testability-accessibility-f02-reconciliation.md)
> QR-01/F-02 有界 Pass 已记录。本收据不可再用于新的采集、代码改动、publication，或关闭 child/parent Assignment。
