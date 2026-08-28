# DIAGNOSTICS-VIEWER-LOAD-001 — Human 诊断查看阻塞 — 2026-08-27

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "EVIDENCE-DIAGNOSTICS-VIEWER-LOAD-20260827",
  "record_type": "evidence",
  "title": "Human diagnostics viewer load and resource screenshots",
  "status": "current",
  "updated_at": "2026-08-27T19:50:00+08:00",
  "revalidation_triggers": ["artifact_changed", "environment_changed"],
  "evidence": {
    "provenance": "device_attested",
    "environment_id": "ENV.HUMAN_DEVICE",
    "assignment_ref": "DIAGNOSTICS-VIEWER-LOAD-001",
    "operator_ref": "Human Product Owner",
    "reviewer_ref": null,
    "coverage": "exploratory",
    "observed_at": "2026-08-27T19:10:00+08:00",
    "valid_until": null,
    "artifact_bindings": [
      {
        "kind": "file",
        "identity": "session-attachments/diagnostics-viewer-load-2026-08-27"
      }
    ],
    "permits_claim_ids": ["CLAIM.DIAGNOSTICS.VIEWER_LOAD_BLOCKING"],
    "prohibits_claim_ids": []
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | current |

---

**Assignment:**
[`diagnostics-viewer-load-001.md`](../assignments/diagnostics-viewer-load-001.md)
**Collection date / timezone:** `2026-08-27 Asia/Shanghai`
**Evidence grade:** `Device-attested`（截图由 Human Product Owner 提供；原图留在会话附件，不入库）

## Observation 1 — 主 App 资源

Activity Monitor 显示 `Universe Keyboard` 主 App 进程：

| Field | Observed |
|---|---|
| CPU | 133% |
| Memory | 1.39 GB |
| Energy Impact | High |
| Disk | 32 KB/s |
| Network | Zero KB/s |

这是查看诊断页时的主 App 进程，不是 Keyboard Extension。数字是观察值，不是新的产品预算。

## Observation 2 — 加载空态

「键盘诊断」页选中「今天 8/27」，主体为 EmptyState：

> 暂无诊断日志
>
> 在设置中开启「记录诊断数据」开关，切换到键盘输入后返回此页面刷新。

Human 报告实际是长时间加载，过程中没有进度或忙碌 UI。当前代码在 `displayedLines.isEmpty` 时直接画该空态；根加载使用 `isRefreshing`，工具栏转圈只认 `isManualRefreshing`。因此该截图不能区分「确实没有 journal」与「仍在加载」。

## Context supplied by Human

- 已开启首屏高保真诊断。
- 同会话中万象拼音下载安装仍然失败。
- 目的是读取 INTEGRITY-001 的详细交付日志，但查看路径不可用。

## Non-claims

- 不证明 journal 为空。
- 不证明万象失败的 integrity 阶段。
- 不把 1.39 GB / 133% CPU 定为回归阈值。
