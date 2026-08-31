# Active Work Summary

> **KOS 2.1 ops · M-05**
> Cap: **≤ 10** items.
> **Lifecycle Source of Truth = Assignment Record** (not this file, not Dashboard).
> This page only **links** and restates **Current Status** fields.

Last synced: `2026-08-31 Asia/Shanghai` — F-02 provenance/Q-09 工程补强通过本地门禁及独立复审，无 P0/P1；旧 `d4572d9` candidate 已 supersede，clean `c5f3004` replacement signed candidate 已冻结。真机 handoff 在安装前仍 HOLD，等待 Human 授权；下游 Gate 不前移。核心 Active Work 为 `4/10`。

| # | Work Item | Lifecycle (from Assignment) | Phase / next | Assignment |
|---|---|---|---|---|
| 1 | RELEASE-2026-08-01 | Active | Human 已创建 Build 7 内部组并邀请两名 tester；Task11 F-01/F-02 仍 Pending。F-03 工程片已随 #83 合入 `main`，TestFlight tester 仍在 Build 7（不含该修复）。04/TD-003/004/005 仍需不同/稳定采集环境 | [`assignment`](assignments/release-2026-08-01.md) · [`Task11`](assignments/release-2026-08-01-11-internal-testflight-feedback.md) · [`feedback`](evidence/release-2026-08-01-11-internal-testflight-feedback-2026-08-25.md) · [`04 Assignment`](assignments/release-2026-08-01-04-device-performance.md) |
| 2 | RIME-BUILTIN-LUNA-QUALITY-001 | Active | P1；provenance/Q-09 remediation=`6cb2fee`/`3a9ce19`/`7260ca2`；`bb43c5f` 独立复审均 `Pass with conditions`、无 P0/P1；clean `c5f3004` replacement candidate 已冻结，下一步等待 Human 真机授权 | [`assignment`](assignments/rime-builtin-luna-quality-001.md) · [`evidence`](evidence/rime-builtin-luna-quality-f02-implementation-2026-08-30.md) · [`handoff`](evidence/rime-builtin-luna-quality-f02-device-handoff-2026-08-31.md) · [`Architecture`](assignments/rime-builtin-luna-quality-001-architecture-review.md#provenance-closure-re-review--bb43c5f--2026-08-31) · [`Quality`](assignments/rime-builtin-luna-quality-001-quality-review.md#q-09-inventory-closure-re-review--bb43c5f--2026-08-31) |
| 3 | TYPING-INTELLIGENCE-001 | Active | 自动化验证完成；真机 / 无障碍 / 外观门未关 | [`assignments/typing-intelligence-001.md`](assignments/typing-intelligence-001.md) |
| 4 | TYPO-CORRECTION-002 | Active | Contextual recovery；指定 Simulator 场景 pending | [`assignments/typo-correction-002.md`](assignments/typo-correction-002.md) |

## Completed (not Active)

| Work Item | Current handoff | Assignment |
|---|---|---|
| RIME-SCHEME-DELIVERY-001 | `Closed`；Human Product Gate Passed；PR [#83](https://github.com/shchnk1103/Universe-Keyboard/pull/83) merged `e9aea57`；GitHub 源与 acceptable-use 为 `accept` 残留；不授权 TestFlight | [`assignment`](assignments/rime-scheme-delivery-001.md) · [`Gate`](product-decisions/RIME-SCHEME-DELIVERY-001-product-gate.md) |
| RIME-SCHEME-DELIVERY-INTEGRITY-001 | `Closed`；CNB staged_content 已分类；空 zip 条目已解压 | [`assignment`](assignments/rime-scheme-delivery-integrity-001.md) · [`ADR 0032`](architecture/decisions/0032-verified-scheme-source-recovery-and-integrity-classification.md) |
| SCHEME-DELIVERY-JOURNAL-001 | `Closed`；Human v1 失败链与成功链均可见 | [`assignment`](assignments/scheme-delivery-journal-001.md) |
| TD-016-CI-TIERING-001 | `Closed`；Human Product Gate Passed；PR [#86](https://github.com/shchnk1103/Universe-Keyboard/pull/86) merged `78ed5b5`；PR [#87](https://github.com/shchnk1103/Universe-Keyboard/pull/87) merged `11fa096`；A-P2-02 仍为 TD-016 | [`assignment`](assignments/td-016-ci-tiering-001.md) · [`Gate`](product-decisions/TD-016-CI-TIERING-001-product-gate.md) |
| CODEX-GITHUB-AUTH-DIAG-001 | `Closed`；runbook 随 PR #86 发布；sandbox 内部机制仍不确定；不授权 Release | [`assignment`](assignments/codex-github-auth-diag-001.md) · [`runbook`](kos/codex-github-cli-auth-troubleshooting.md) · [`host evidence`](evidence/codex-github-auth-host-2026-08-28.md) |
| KOS-2-2-DOC-ALIGN-001 | `Closed`；Human Product Review accepted；核心治理/启动文档完成 advisory 渐进对齐；不启用 `required` | [`assignment`](assignments/kos-2-2-doc-align-001.md) · [`Gate`](product-decisions/KOS-2-2-DOC-ALIGN-001-product-gate.md) · [`evidence`](evidence/kos-2-2-doc-align-001-audit-2026-08-28.md) |
| DIAGNOSTICS-VIEWER-LOAD-001 | `Closed`；Human Product Gate Passed；PR [#85](https://github.com/shchnk1103/Universe-Keyboard/pull/85) merged `420322b`；方案交付可观测性转交 TD-015 | [`assignment`](assignments/diagnostics-viewer-load-001.md) · [`Gate`](product-decisions/DIAGNOSTICS-VIEWER-LOAD-001-product-gate.md) · [`TD-015`](TECH_DEBT.md#td-015-方案交付日志未进入诊断-v1-journal) |
| KOS-UPGRADE-UK-001 | `Reviewed`；Product Gate 接受 advisory pin；PR [#84](https://github.com/shchnk1103/Universe-Keyboard/pull/84) merged `e7da77e`；P2=`TD-014` | [`assignment`](assignments/kos-upgrade-uk-001.md) · [`Gate`](product-decisions/KOS-UPGRADE-UK-001-product-gate.md) · [`TD-014`](TECH_DEBT.md#td-014-kos-22-auth-consumption_state-卫生) |
| RELEASE-2026-0801-08 | `Closed`；PR [#80](https://github.com/shchnk1103/Universe-Keyboard/pull/80) merged `54ce3bd`；功能分支已清理 | [`assignment`](assignments/release-2026-08-01-08-kaomoji-content.md) · [`Gate`](evidence/release-2026-08-01-08-product-gate-2026-08-24.md) |
| RELEASE-2026-0801-05-PROVENANCE-A | `Completed`；Product 已接受派生收据为外部候选残留；不开 Phase B | [`assignment`](assignments/release-2026-08-01-05-provenance-recovery-phase-a.md) · [`PD`](product-decisions/RELEASE-2026-0801-05-provenance-a-accept.md) · [`evidence`](evidence/release-2026-08-01-05-provenance-recovery-phase-a-2026-08-23.md) |
| PATH-BAR-TOUCH-001 | `Completed`；Human 复验 Path 上半区可点；等 PR 合并后 Closed | [`assignments/path-bar-touch-001.md`](assignments/path-bar-touch-001.md) |
| KEYBOARD-LAYOUT-9KEY-PUNCT-001 | `Closed`；PR #75 已合并；功能分支已清理 | [`assignments/keyboard-layout-9key-punct-001.md`](assignments/keyboard-layout-9key-punct-001.md) |
| KEY-TOUCH-FILL-001 | `Completed`；26 键/九键 overlay 关/开同点与键面原生操作均通过 Human 真机 Product Gate | [`assignments/key-touch-fill-001.md`](assignments/key-touch-fill-001.md) |
| DEBUG-KEY-HITBOX-001 | `Closed`；PR #73 已合并；Human Product Gate Passed | [`assignments/debug-key-hitbox-001.md`](assignments/debug-key-hitbox-001.md) |
| T9-RESPONSIVE-PIPELINE-001 | `Reviewed`；ADR 0025 Accepted，DEFAULT-ON Product Gate 已交付；R6 仅 track；不再占 Active | [`assignment`](assignments/t9-responsive-rime-pipeline-001.md) · [`DEFAULT-ON`](assignments/responsive-default-on-001.md) |
| HELP-TIPKIT-001 | `Completed`；P1–P3 已交付；等待 Quality + Human Product Gate | [`assignments/help-tipkit-001.md`](assignments/help-tipkit-001.md) |
| HELP-J3-RESOURCES-001 | `Completed`；Help 内嵌 J3 slim 已交付；等待 Quality + Product Gate | [`assignments/help-j3-resources-001.md`](assignments/help-j3-resources-001.md) |
| APP-SEARCH-001 | `Completed`；搜索 Tab + J4 已交付；等待 Quality + Product Gate | [`assignments/app-search-001.md`](assignments/app-search-001.md) |
| DIAGNOSTICS-OBSERVABILITY-001 | `Completed`；P0 PR #57 已合并；等待 Human Product Gate；P1 见 TD-013 | [`assignments/diagnostics-observability-001.md`](assignments/diagnostics-observability-001.md) |
| CANDIDATE-TOUCH-HITBOX-001 | `Completed`；PR #72 已合并；等待 Product 授权一次真机 `5/5 · 5/5 · 5/5` | [`assignments/candidate-touch-hitbox-001.md`](assignments/candidate-touch-hitbox-001.md) |
| CANDIDATE-TOUCH-OBSERVABILITY-001 | PR #71 merged；固定 iPhone 13 Pro 单轮 `0/5 · 5/5 · 5/5`；几何与探针缺口转交 HITBOX-001 | [`assignment`](assignments/candidate-touch-observability-001.md) · [`evidence`](evidence/candidate-touch-observability-001-execution-evidence-2026-08-13.md) |
| KOS-2.1-OPS-001 / KOS-2.1-OPS-IMPL-001 | `Closed`；Must 设计已接受，运维包已在 KOS 2.0 轨道发布；S-01 / Migration / 2.1 frozen replacement 未授权 | [`design`](assignments/kos-2.1-ops-001.md) · [`implementation`](assignments/kos-2.1-ops-impl-001.md) |
| TD-012-LMDG-MODEL-G2 | `Closed`；Product Hold，G2-A Pass，G2-B invalidated，不进入 G3 | [`assignments/td-012-lmdg-model-g2.md`](assignments/td-012-lmdg-model-g2.md) |
| DIAGNOSTICS-DAY-BROWSER-001 | Simulator 代码级 Architecture / Quality Pass（PR #70）；等待 Human Product Review，不含真机、ADR Acceptance 或 Release 结论 | [`assignments/diagnostics-day-browser-001.md`](assignments/diagnostics-day-browser-001.md) · [independent review](assignments/diagnostics-day-browser-001-independent-review.md) · [evidence](evidence/diagnostics-day-browser-001-execution-evidence-2026-08-12.md) |
| DIAGNOSTICS-READ-RECOVERY-001 | PR #70 已合并；独立 Architecture / Quality Pass 已记录；等待 Human Product Review，不含真机/G2/Release 结论 | [`assignments/diagnostics-read-recovery-001.md`](assignments/diagnostics-read-recovery-001.md) · [evidence](evidence/diagnostics-read-recovery-001-execution-evidence-2026-08-12.md) |
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
| P1 | **[TD-015](TECH_DEBT.md#td-015-方案交付日志未进入诊断-v1-journal) 方案交付 → v1** | #83 已合；v1 `scheme_delivery` 已有 Human 成功/失败证据。其余 DEPLOY 自由文本见 TD-013 |
| P2 | **[TD-016](TECH_DEBT.md#td-016-ci-变更分级与文档提交快速门禁) required-check trust root** | 实现已合入；A-P2-02 仍待另行授权，未改 required checks |
| P1 optional | **[TD-011](TECH_DEBT.md#td-011-multi-scheme-lua--advanced-input-compatibility-雾凇--万象) B–D** | Diagnose / multi-schema deploy / install isolation — only if Product productizes 万象 toggles |
| P2 optional | Device smoke TD-011 A | 高级输入 + 万象：tips 显示 `/rq`·`orq`/`V`/`R`/`U`；裸 `rq` 仍属雾凇 |
| — | Freeze A hold | **Do not** unify fog `rq` ↔ 万象 `/rq` unless Product supersedes |

**Done this arc (do not re-open as WIP):** `RIME-SCHEME-WANXIANG-001` V1 catalog/layout path; TD-009 toast name+progress (PR #53); TD-010 capability gates + prefs preserve (#51/#52); TD-011 freeze A native usage copy (#54).

Debts index: [`TECH_DEBT.md`](TECH_DEBT.md) TD-009…016.

## Rules

- Do not add an 11th row without removing or closing another.
- On conflict with an Assignment header, **Assignment wins**; fix this file.
- Closed Work Items are removed here; history stays in the Assignment.
