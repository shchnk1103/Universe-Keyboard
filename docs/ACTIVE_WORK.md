# Active Work Summary

> **KOS 2.1 ops · M-05**
> Cap: **≤ 10** items.
> **Lifecycle Source of Truth = Assignment Record** (not this file, not Dashboard).
> This page only **links** and restates **Current Status** fields.

Last synced: `2026-08-09 Asia/Shanghai` — `DIAGNOSTICS-OBSERVABILITY-001` 的 P0 已由 PR #57 合并且 CI 通过，现等待人类 Product Gate；后续 P1 已转入 TD-013，原 `KEYBOARD-STARTUP-PERF-001` 保持 Completed，作为该工作项的真机异常证据来源。

| # | Work Item | Lifecycle (from Assignment) | Phase / next | Assignment |
|---|---|---|---|---|
| 1 | RIME-SCHEME-WANXIANG-001 | Active | 009/010/011A done; **next TD-012** (or 011 B–D if Product opens) | [`assignments/rime-scheme-wanxiang-001.md`](assignments/rime-scheme-wanxiang-001.md) |
| 2 | T9-RESPONSIVE-PIPELINE-001 | Active | Dual-gate request default-on; residual hygiene | [`assignments/t9-responsive-rime-pipeline-001.md`](assignments/t9-responsive-rime-pipeline-001.md) |
| 3 | RELEASE-2026-0801 | Active | Release coordination; Entry Criteria pending | [`assignments/release-2026-08-01.md`](assignments/release-2026-08-01.md) |
| 4 | HELP-TIPKIT-001 | Active | P1–P3 done; Product Gate pending | [`assignments/help-tipkit-001.md`](assignments/help-tipkit-001.md) |
| 5 | HELP-J3-RESOURCES-001 | Active | Slim resource prepare | [`assignments/help-j3-resources-001.md`](assignments/help-j3-resources-001.md) |
| 6 | APP-SEARCH-001 | Active | Search tab + J4 trial field | [`assignments/app-search-001.md`](assignments/app-search-001.md) |
| 7 | TYPING-INTELLIGENCE-001 | Active | Implementation; Quality pending | [`assignments/typing-intelligence-001.md`](assignments/typing-intelligence-001.md) |
| 8 | TYPO-CORRECTION-002 | Active | Contextual recovery; sim scenarios pending | [`assignments/typo-correction-002.md`](assignments/typo-correction-002.md) |
| 9 | KEYBOARD-LAYOUT-9KEY-PINYIN-002 | Active | Amendment D done; clean-commit / Product Gate pending | [`assignments/keyboard-layout-9key-pinyin-002.md`](assignments/keyboard-layout-9key-pinyin-002.md) |
| 10 | DIAGNOSTICS-OBSERVABILITY-001 | Active | P0 已合并；等待 Product Gate，P1 后续见 TD-013 | [`assignments/diagnostics-observability-001.md`](assignments/diagnostics-observability-001.md) |

## Completed (not Active)

| Work Item | Current handoff | Assignment |
|---|---|---|
| KEYBOARD-STARTUP-PERF-001 | 已交付首帧性能修复与最小 Debug 诊断；真机异常日志是 `DIAGNOSTICS-OBSERVABILITY-001` 的输入，而不是继续扩大旧任务 | [`assignments/keyboard-startup-perf-001.md`](assignments/keyboard-startup-perf-001.md) |

Closed this session (removed from Active): `RESPONSIVE-CANDIDATE-ANOMALY-001` (Completed; R-01 device smoke `accept`), `RESPONSIVE-DELETE-ANOMALY-001`, `KOS-2.1-OPS-001`, `KOS-2.1-OPS-IMPL-001`, `RESPONSIVE-DEFAULT-ON-001` (Reviewed; optional formal close).

## Cold-session resume (万象 arc · 2026-08-08 EOD)

New session: `AGENTS.md` → `KNOWLEDGE_INDEX` → **this file** → Assignment row #1 → full handoff block inside the Assignment.

### 待办 / Backlog（未做 · 下次会话）

| Priority | Item | Notes |
|---|---|---|
| **P0 next eng** | **[TD-012](TECH_DEBT.md#td-012-optional-rime-grammar-model-万象-lmdg--gram-integration)** optional LMDG `.gram` | Default next if Product does not reopen 万象 advanced **controls** |
| P1 optional | **[TD-011](TECH_DEBT.md#td-011-multi-scheme-lua--advanced-input-compatibility-雾凇--万象) B–D** | Diagnose / multi-schema deploy / install isolation — only if Product productizes 万象 toggles |
| P2 optional | Device smoke TD-011 A | 高级输入 + 万象：tips 显示 `/rq`·`orq`/`V`/`R`/`U`；裸 `rq` 仍属雾凇 |
| P2 optional | Formal **Completed** stamp on RIME-SCHEME-WANXIANG-001 | Product may stamp when ready; path already merge-ready |
| P3 residual | R-04 re-smoke | 长句分段选词末段双插（`sel-*` 已缓解） |
| P1 deferred | **[TD-013](TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化)** diagnostics v1 hardening | 严格分页、周期性 retention、完整 health/竞争矩阵、legacy migration；需新授权 |
| — | Freeze A hold | **Do not** unify fog `rq` ↔ 万象 `/rq` unless Product supersedes |

**Done this arc (do not re-open as WIP):** TD-009 toast name+progress (PR #53); TD-010 capability gates + prefs preserve (#51/#52); TD-011 freeze A native usage copy (#54).

Debts index: [`TECH_DEBT.md`](TECH_DEBT.md) TD-009…013.

## Rules

- Do not add an 11th row without removing or closing another.
- On conflict with an Assignment header, **Assignment wins**; fix this file.
- Closed Work Items are removed here; history stays in the Assignment.
