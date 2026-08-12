# Active Work Summary

> **KOS 2.1 ops · M-05**
> Cap: **≤ 10** items.
> **Lifecycle Source of Truth = Assignment Record** (not this file, not Dashboard).
> This page only **links** and restates **Current Status** fields.

Last synced: `2026-08-13 Asia/Shanghai` — KOS 2.1 ops lifecycle reconciled；`TD-012-LMDG-MODEL-G2` Product Hold；Active Work `8/10`。

| # | Work Item | Lifecycle (from Assignment) | Phase / next | Assignment |
|---|---|---|---|---|
| 1 | T9-RESPONSIVE-PIPELINE-001 | Active | Dual-gate request default-on; residual hygiene | [`assignments/t9-responsive-rime-pipeline-001.md`](assignments/t9-responsive-rime-pipeline-001.md) |
| 2 | RELEASE-2026-0801 | Active | Release coordination; Entry Criteria pending | [`assignments/release-2026-08-01.md`](assignments/release-2026-08-01.md) |
| 3 | HELP-TIPKIT-001 | Active | P1–P3 done; Product Gate pending | [`assignments/help-tipkit-001.md`](assignments/help-tipkit-001.md) |
| 4 | HELP-J3-RESOURCES-001 | Active | Slim resource prepare | [`assignments/help-j3-resources-001.md`](assignments/help-j3-resources-001.md) |
| 5 | APP-SEARCH-001 | Active | Search tab + J4 trial field | [`assignments/app-search-001.md`](assignments/app-search-001.md) |
| 6 | TYPING-INTELLIGENCE-001 | Active | Implementation; Quality pending | [`assignments/typing-intelligence-001.md`](assignments/typing-intelligence-001.md) |
| 7 | TYPO-CORRECTION-002 | Active | Contextual recovery; sim scenarios pending | [`assignments/typo-correction-002.md`](assignments/typo-correction-002.md) |
| 8 | DIAGNOSTICS-OBSERVABILITY-001 | Active | P0 已合并；等待 Product Gate，P1 后续见 TD-013 | [`assignments/diagnostics-observability-001.md`](assignments/diagnostics-observability-001.md) |

## Completed (not Active)

| Work Item | Current handoff | Assignment |
|---|---|---|
| KOS-2.1-OPS-001 / KOS-2.1-OPS-IMPL-001 | `Closed`；Must 设计已接受，运维包已在 KOS 2.0 轨道发布；S-01 / Migration / 2.1 frozen replacement 未授权 | [`design`](assignments/kos-2.1-ops-001.md) · [`implementation`](assignments/kos-2.1-ops-impl-001.md) |
| TD-012-LMDG-MODEL-G2 | `Closed`；Product Hold，G2-A Pass，G2-B invalidated，不进入 G3 | [`assignments/td-012-lmdg-model-g2.md`](assignments/td-012-lmdg-model-g2.md) |
| DIAGNOSTICS-READ-RECOVERY-001 | Executor 实现与 Simulator 质量门完成；等待独立 Quality reverify，不含真机/G2/Release 结论 | [`assignments/diagnostics-read-recovery-001.md`](assignments/diagnostics-read-recovery-001.md) · [evidence](evidence/diagnostics-read-recovery-001-execution-evidence-2026-08-12.md) |
| TD-012-OCTAGRAM-VENDOR-G1 | Vendor pin + Bridge G1 **Closed**; model G2+ remain TD-012 debt | [`assignments/td-012-octagram-vendor-g1.md`](assignments/td-012-octagram-vendor-g1.md) · [Arch](assignments/td-012-octagram-vendor-g1-architecture-review.md) · [Quality](assignments/td-012-octagram-vendor-g1-quality-review.md) |
| TD-013-DIAGNOSTICS-V1-P1 | Architecture **Pass**、Quality **Pass with conditions**、Human Product Gate **Passed**；P2 residual 继续由 TD-013 追踪 | [`assignments/td-013-diagnostics-v1-p1.md`](assignments/td-013-diagnostics-v1-p1.md) · [re-review](assignments/td-013-diagnostics-v1-p1-r3-review-summary.md) |
| 九键精准拼音 `002` / `003` → `004` | `002` 已 Blocked，`003` 已被 supersede；继任 `004` 已 **Accepted / Closed**，历史记录仅供追溯 | [`004 Assignment`](assignments/keyboard-layout-9key-pinyin-004.md) · [`002`](assignments/keyboard-layout-9key-pinyin-002.md) · [`003`](assignments/keyboard-layout-9key-pinyin-003.md) |
| KEYBOARD-STARTUP-PERF-001 | 已交付首帧性能修复与最小 Debug 诊断；真机异常日志是 `DIAGNOSTICS-OBSERVABILITY-001` 的输入，而不是继续扩大旧任务 | [`assignments/keyboard-startup-perf-001.md`](assignments/keyboard-startup-perf-001.md) |

Earlier closures retained for context: `RESPONSIVE-CANDIDATE-ANOMALY-001` (Completed; R-01 device smoke `accept`), `RESPONSIVE-DELETE-ANOMALY-001`, `RESPONSIVE-DEFAULT-ON-001` (Reviewed; optional formal close).

## Cold-session resume (万象 arc · 2026-08-08 EOD)

New session: `AGENTS.md` → `KNOWLEDGE_INDEX` → **this file** → pick Active row → full Assignment handoff.  
TD-012 G1 is **Closed** (see Completed table); do not re-open vendor G1 without revalidation.

### 待办 / Backlog（未做 · 下次会话）

| Priority | Item | Notes |
|---|---|---|
| P1 optional | **[TD-011](TECH_DEBT.md#td-011-multi-scheme-lua--advanced-input-compatibility-雾凇--万象) B–D** | Diagnose / multi-schema deploy / install isolation — only if Product productizes 万象 toggles |
| P2 optional | Device smoke TD-011 A | 高级输入 + 万象：tips 显示 `/rq`·`orq`/`V`/`R`/`U`；裸 `rq` 仍属雾凇 |
| — | Freeze A hold | **Do not** unify fog `rq` ↔ 万象 `/rq` unless Product supersedes |

**Done this arc (do not re-open as WIP):** `RIME-SCHEME-WANXIANG-001` V1 catalog/layout path; TD-009 toast name+progress (PR #53); TD-010 capability gates + prefs preserve (#51/#52); TD-011 freeze A native usage copy (#54).

Debts index: [`TECH_DEBT.md`](TECH_DEBT.md) TD-009…013.

## Rules

- Do not add an 11th row without removing or closing another.
- On conflict with an Assignment header, **Assignment wins**; fix this file.
- Closed Work Items are removed here; history stays in the Assignment.
