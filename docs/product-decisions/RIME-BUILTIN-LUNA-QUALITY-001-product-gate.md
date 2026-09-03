# Product Decision: RIME-BUILTIN-LUNA-QUALITY-001 — Human Product Gate（proposed）

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-RIME-BUILTIN-LUNA-QUALITY-001-GATE",
  "record_type": "decision",
  "title": "Decide F-02 merge residuals and whether to merge PR #93",
  "status": "proposed",
  "updated_at": "2026-09-03T12:00:00+08:00",
  "revalidation_triggers": ["builtin_luna_closure_changed", "overlay_contract_changed", "head_sha_changed"],
  "parent_refs": ["RIME-BUILTIN-LUNA-QUALITY-001"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "not yet issued; Coordinator prepared the Gate packet after independent Architecture/Quality re-review of ecd3446",
    "scope": "Dispose remaining M-03 residuals for F-02 and decide whether to authorize merge of PR #93. Does not authorize TestFlight, Release, or Assignment Exit.",
    "outcome": "pending Human Product Owner",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-RIME-BUILTIN-LUNA-QUALITY-001-GATE`
- **Lifecycle status:** `proposed` — **not Accepted**
- **Date / timezone:** `2026-09-03 Asia/Shanghai`
- **Authority:** Human Product Owner only
- **Assignment:** [`RIME-BUILTIN-LUNA-QUALITY-001`](../assignments/rime-builtin-luna-quality-001.md)
- **PR:** [#93](https://github.com/shchnk1103/Universe-Keyboard/pull/93) HEAD `ecd3446`

## Current Status

| Field | Value |
|---|---|
| Status | proposed |
| Phase | Gate packet ready；等待 Human 填写残差 disposition 并决定是否 merge |
| Evidence | Architecture `Pass with conditions`；Quality KOS Fail closed + `Pass with conditions`；hosted CI `33642643269` green；真机 A–D ledger |
| Non-claims | 本文件不是 merge AUTH、不是 Exit、不是 TestFlight、不是 Release |
| Residuals | Assignment [M-03 table](../assignments/rime-builtin-luna-quality-001.md#m-03-residuals-before-merge) |

---

## What is already closed (not for re-decision)

- KOS P1 freeze supersession (`F02-A-P1-FREEZE-001` / `KOS-001`) — `fix`
- Q-01 / Q-02 / Q-04 Full Access / Q-08 — `Device-attested` PASS on signed Debug `b1d81fd`
- Hosted Swift 6 Quality path green on `ecd3446`
- Process-death atomicity remains `tech_debt:TD-001`
- ADR 0033 remains Accepted；实现已落地，不蕴含 Product Gate

## Decisions required from Human Product Owner

Each `open` residual must receive exactly one of `fix` / `accept` / `tech_debt:<ID>` before merge is authorized.

| Decision | If `accept` for this merge | If `fix` before merge |
|---|---|---|
| `F02-FIRST-LAUNCH-AUTODEPLOY-001` | 全新安装仍需设置页/引导手动部署；记为已知 UX 残差 | 必须先做 first-launch `rime_needs_deploy` seed |
| `F02-CONVERSION-LOOKUP-NOT-WIRED-001` | 内置 Luna 本片只承诺 `t2s` + 候选质量；s2t/t2hk/t2tw/Stroke reverse lookup 另开 | 必须接线/补包后再合 |
| fuzzy-default-ON | 确认文档中的默认 ON 为产品意图 | 改为默认 OFF 后再合 |
| `F02-Q06-EXTENSION-001` | 严格真机 fault-injection 留到 post-merge / 后续 Assignment | 必须补跑矩阵 |
| `F02-Q07-PERF-001` | 接受 Debug 观察，不把 1.06 s / 81.20 MB 当 Release 预算 | 必须补 release-like 矩阵并接受预算 |
| `F02-Q09-HUMAN-LEGAL-001` | 接受工程 inventory 足够支撑本片 merge；法律充分性另开 | 合入前完成法律审查 |
| `F02-Q10-ARCHIVE-001` | merge 不要求 exact archive | 合入前出 archive |

C.5 Extension 进程终止仍保持未授权，除非 Human 另行签发。

## Merge authorization boundary (only if residuals are disposed)

若 Human 接受本片 merge，授权范围仅限：

- 合并 PR #93 到 `main`
- 合并后跑 KOS 2.1 M-02 状态同步
- 不上传 TestFlight、不 Release、不关闭 Assignment Exit（除非 Human 另写 Exit）

Coordinator / Quality / Architecture **不得**代填 `accepted` 或签发 `AUTH-*-MERGE`。
