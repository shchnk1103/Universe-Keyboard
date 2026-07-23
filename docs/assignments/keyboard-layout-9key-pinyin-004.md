# Assignment: KEYBOARD-LAYOUT-9KEY-PINYIN-004 — 完整 Path 目录与原子同步

**Policy version:** `1.0.0`  
**Lifecycle status:** `Active — PR #27 landed; residual-B Path-ledger peel implemented (automation green); Human residual-B retest + PR for B fix pending`  
**Repository change types:** `Contract`, `State`, `Implementation`, `Evidence`, `Documentation`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-004`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md), `2026-07-22 Asia/Shanghai`
- **Product Approver:** Human Product Owner under KOS 2.0
- **Plan:** [`plans/keyboard-layout-9key-pinyin-004-complete-path-catalog-and-atomic-sync-plan.md`](../plans/keyboard-layout-9key-pinyin-004-complete-path-catalog-and-atomic-sync-plan.md)
- **Architecture:** [`ADR 0023`](../architecture/decisions/0023-t9-complete-local-path-catalog-and-atomic-presentation.md)

## Boundary

### Scope

1. Create PD / ADR 0023 / this Assignment and mark 003 as Human Product Gate failed, superseded by 004 (do not rewrite 003 history as pass).
2. Generate compile-time T9 syllable catalog from in-repo `luna_pinyin.dict.yaml` with provenance.
3. Core: full local Path catalog, complete vs prefix kinds, atomic composition snapshot/revision, prefix selection, complete-syllable advance, Delete / Partial Commit Path persistence, host-digit safety.
4. UIKit: fixed-height horizontal collection Path Bar for all focus Paths; remove completeness dependence on expanded candidate discovery.
5. Targeted KeyboardCore / RimeBridge / UI contract tests only; 26-key isolation.
6. Implementation evidence + human iPhone 13 Pro Product Gate template. Do not claim Product Gate from automation.

### Non-goals

- Product changes outside PD-004
- 26-key behavior change
- Full test suite
- Commit / push / PR unless user authorizes later
- Destructive reset of existing 003 worktree files

### Required Inputs

- `AGENTS.md`, `KNOWLEDGE_INDEX.md`, reading maps, playbooks
- PD-004, ADR 0023, plan file
- Predecessor 003 Assignment / ADR 0022 / Stage A evidence (failure retained)
- `PERFORMANCE_BASELINE.md`, input-pipeline and Partial Commit contracts

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer
- **Executor:** Grok 4.5（Gate 5 **Phase 1 β-limited Ready**；Product Lead `2026-07-23` 指派）
- **Environment Executor:** Grok 4.5 — 定向自动化；真机 Human 复测仅在独立复审后由 Product Lead 请求
- **Human Dependency:** Human Product Owner — iPhone 13 Pro · 备忘录 · 分项 A/B/C（B 预期仍可能 Fail；**勿**代填）
- **Architecture Reviewer:** independent Architecture & Knowledge Steward (separate from implementation claims)
- **Quality Reviewer:** independent Quality Reviewer not implementing the change
- **Supporting domains:** 🔧 RIME Platform Maintainer, ⌨️ Keyboard Experience Maintainer

## Gates

### Entry Criteria

- Assignment contains no `UNKNOWN`.
- Product behavior, non-goals and human gate recorded.
- Worktree may contain 003 implementation; preserve it as base, do not reset.

### Phase Gates

| Phase | Required exit evidence |
|---|---|
| 0 — Governance | PD, ADR, Assignment linked; 003 status amended |
| 1 — Catalog | Generator + generated Swift + metadata tests |
| 2 — Core Path / Snapshot | Local Path ranking, prefix/complete selection, RIME call bounds |
| 3 — Host safety / Delete / Partial Commit | Digit-free marked text; Path persists on recovery sequences |
| 4 — Path Bar UI | Full horizontal list, scroll, a11y, 26-key untouched |
| 5 — Targeted tests | Commands + results recorded |
| Product Gate | Human iPhone 13 Pro matrix filled |

### Exit Criteria

- `28 → bu/cu/a/b/c`; `94` retains `xi/yi/zi` without comment completeness.
- Prefix selection does not advance; complete syllable can advance.
- Path Bar shows full focus set; does not vanish while composition valid.
- No internal digits in marked-text history on audited paths.
- 26-key isolation tests pass.
- Architecture + Quality independent review + Human Product Gate before `Closed`.

### Stop Conditions

Stop and return to Product Lead when:

- syllable source / license / generation provenance cannot be recorded;
- meeting performance appears to require whole-sentence cartesian product or hot-path file I/O;
- required responsibility becomes `UNKNOWN`;
- 26-key isolation is broken;
- attempting Product Gate closure without human device evidence.

## Handoff

- **Current phase:** **PR [#27](https://github.com/shchnk1103/Universe-Keyboard/pull/27) on `main`**（H5 residual）。**Residual-B Path-ledger peel** 已在工作区实现并通过 KeyboardCore 全量自动化（708/1 skip/0 fail）；待功能分支 PR + 真机 residual-B 复测。
- **Handoff target now:** Human Product Owner — residual-B 真机复测（「请」单字 partial 后 Path 保留 wei/fan/dao、焦点 wo）；通过后合并 residual-B PR / 独立复审。
- **PR (landed):** https://github.com/shchnk1103/Universe-Keyboard/pull/27 — **MERGED** `2026-07-23T11:28:11Z`
- **Residual-B authority:** [`PD-…-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md)
- **β-limited review (pre-hotfix):** [`…-phase1-beta-independent-review.md`](keyboard-layout-9key-pinyin-004-gate5-phase1-beta-independent-review.md)
- **Post-β freeze handoff:** [`…-gate5-post-beta-human-residual-review-handoff.md`](keyboard-layout-9key-pinyin-004-gate5-post-beta-human-residual-review-handoff.md)
- **Post-β independent review:** [`…-gate5-post-beta-human-residual-independent-review.md`](keyboard-layout-9key-pinyin-004-gate5-post-beta-human-residual-independent-review.md)
- **Product disposition (H5):** [`PD-…-GATE5-POST-BETA-RESIDUAL`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-post-beta-residual-disposition.md)
- **Evidence (append-only):** [`…-gate5-remediation-evidence.md`](keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md) §21–§28
- **Phase 0.5 / 0.6 reviews:** [`phase05`](keyboard-layout-9key-pinyin-004-gate5-phase05-independent-review.md) · [`phase06`](keyboard-layout-9key-pinyin-004-gate5-phase06-independent-review.md)
- **Product decisions:** [`PD-…-GATE5-PATH`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-path-decision.md) · [`PD-…-GATE5-PHASE1-BETA`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md) · [`PD-…-GATE5-POST-BETA-RESIDUAL`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-post-beta-residual-disposition.md) · [`PD-…-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md)
- **Residual debt (open):** provisional-only mixed-raw C `XCTSkip`；doc wording A1；**residual-B Human retest**（自动化已绿，产品 Pass 未宣称）
- **Explicit non-claims:** **不**宣称完整 Human Product Gate Pass；**不**宣称 residual-B 真机已过
- **Revalidation Trigger:** catalog source change; selection semantics change; host preedit boundary change; schema/vendor change; Product path decision change; residual-B device outcome

### Phase 0.5 Authorization (Product Lead) — **Closed**

| Field | Value |
|---|---|
| **Authority** | Human Product Owner as Product Lead（本会话明确授权 Grok 4.5） |
| **Date** | `2026-07-23 Asia/Shanghai` |
| **Decision source** | [`keyboard-layout-9key-pinyin-004-gate5-phase05-grok-handoff.md`](keyboard-layout-9key-pinyin-004-gate5-phase05-grok-handoff.md) |
| **Scope** | 仅验证 librime `RimeComposition.sel_start/sel_end`（或等价 engine-native range）是否能在 A/B 真实候选选择前后，权威表达候选实际消费范围，并唯一映射到 T9 `sourceDigits` 槽位 |
| **Executor** | Grok 4.5 |
| **Outcome** | Spike Done；独立复审 Accept 否定结论 `UNRELIABLE_MENU_SCOPED_ONLY`；只读透传 Accept with constraints |
| **Product close** | `2026-07-23` Product Lead 接受复审；见 `PD-…-004-GATE5-PATH` |

### Phase 0.5 file allowlist（历史；已关闭）

**Production / bridge（只读元数据透传或 DEBUG/test 观测；禁止接入 identity reducer）：**

- `Packages/RimeBridge/Sources/RimeBridgeObjC/include/RimeSessionManager.h`
- `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m`
- `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+Output.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/RimeComposition.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/RimeOutput.swift`

**Tests:**

- `Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9PinyinSelectionSpikeTests.swift`
- `Packages/RimeBridge/Tests/RimeBridgeTests/RimeEngineContractTests.swift`（独立复审 Q3 Accept：纯 parser 契约）
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/FakeRimeEngine.swift`
- （若 range 可靠）定向 Core fail-closed 契约测试文件，须在 evidence 中点名；不得借机改 Partial/Delete 身份算法

**Docs:**

- 本 Assignment
- `docs/plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md`
- `docs/assignments/keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md`
- `docs/assignments/keyboard-layout-9key-pinyin-004-gate-entry-status.md`
- `docs/assignments/keyboard-layout-9key-pinyin-004-gate5-phase05-grok-handoff.md`
- `docs/assignments/keyboard-layout-9key-pinyin-004-gate5-phase05-independent-review.md`

### Phase 0.6 Authorization (Product Lead) — **Closed**

| Field | Value |
|---|---|
| **Outcome** | Spike + 独立复审：`UNRELIABLE_NO_ALLOWED_SLOT_MAP`；Path α **closed negative** |
| **Product close** | `2026-07-23` → 见 `PD-…-GATE5-PHASE1-BETA` |

### Phase 1 β-limited Authorization (Product Lead) — **Active / Ready**

| Field | Value |
|---|---|
| **Authority** | Product Lead |
| **Date** | `2026-07-23 Asia/Shanghai` |
| **Decision source** | [`PD-…-GATE5-PHASE1-BETA`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md) |
| **Product path** | **β-limited Phase 1**；α closed；γ 仍 reject；**B 验收不收窄** |
| **In scope** | (1) C Append/Delete 身份；(2) shortened remainder 严格唯一后缀；(3) unchanged-raw **fail-closed**（禁猜槽、禁错误重基准） |
| **Out of scope** | 完整 B 槽位消费证明；用禁止信号“修好” B；Human Gate 通过声明 |
| **Executor** | Grok 4.5 |
| **Architecture / Quality** | 实现后必须独立复审；通过后才请求 Human 分项真机 |
| **Forbidden** | 汉字数/comment/preedit/排名/sel_*/caret/previewLen 猜 B 槽；改 PD-004 主体/ADR 0023/catalog/26 键/UIKit；commit/push/PR（另批）；代填 Human 矩阵 |

### Phase 1 β-limited file allowlist

**Production（KeyboardCore identity only）：**

- `Packages/KeyboardCore/Sources/KeyboardCore/T9CompositionIdentity.swift`（新增，内部纯状态）
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PartialCommit.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TextEditing.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/PartialCommitState.swift`（仅内部 checkpoint；公共 init 兼容）
- `Packages/KeyboardCore/Sources/KeyboardCore/T9Gate5CompositionTrace.swift`（DEBUG；可收敛，禁 unsafe 隔离）

**Tests：**

- `Packages/KeyboardCore/Tests/KeyboardCoreTests/PartialCommitControllerTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PresentationSnapshotContractTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/FakeRimeEngine.swift`（coverage 仅显式测试输入；**不得**假装 engine-native 可靠）

**Docs：**

- 本 Assignment
- `docs/product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md`
- `docs/plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md`
- `docs/assignments/keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md`
- `docs/assignments/keyboard-layout-9key-pinyin-004-gate-entry-status.md`
- Executor handoff（若创建）

**明确禁止：** RimeBridge 生产改动（0.5/0.6 只读字段保持只读）；UIKit；catalog；26 键。越界 Stop。

## Reassignment History

| 生效时间 | Assignment Authority | 原 Executor | 新 Executor | 原因 | 剩余工作与边界 |
|---|---|---|---|---|---|
| `2026-07-22 Asia/Shanghai` | Human Product Owner（Product Lead；当前任务明确授权） | Grok 4.5 | Codex（当前任务） | Grok 4.5 额度耗尽，无法继续执行 | 仅先关闭 Gate 5 Phase 0 阻塞：安全诊断、真实设备/Bridge 轨迹、C 因果红测、定向证据；须由未参与实现的独立 Architecture/Quality Reviewer 批准后才可进入 Phase 1。不得 commit/push/PR，不得代填 Human Product Gate。 |
| `2026-07-23 Asia/Shanghai` | Human Product Owner（Product Lead；本会话明确授权） | Codex | Grok 4.5（Phase 0.5 only） | Architecture 三审 Reject：unchanged-raw B 缺 production-visible engine-native consumed range | 仅执行 Phase 0.5 candidate coverage Spike（上表 allowlist）；完成后立即停止，交独立 Architecture + Quality 复审。禁止 Phase 1、禁止 commit/push/PR、禁止宣布 Human Gate 通过。 |
| `2026-07-23 Asia/Shanghai` | Product Lead（本会话完成路径裁决） | Grok 4.5（Phase 0.5 已关闭） | Grok 4.5（Phase 0.6 Ready） | Phase 0.5 独立复审完成；Product Lead 选 Path α + β 底线，拒 γ | 执行 Phase 0.6 替代 coverage/selection-delta Spike；Phase 1 仍 blocked；禁止 commit/push/PR 与 Human Gate 通过声明。 |
| `2026-07-23 Asia/Shanghai` | Product Lead（α 否定后路径裁决） | Grok 4.5（Phase 0.6 已关闭） | Grok 4.5（Phase 1 β-limited） | Path α closed negative；授权 β-limited 实现 | C + shortened remainder + unchanged-raw fail-closed；**不**修完整 B 槽位；**不**收窄 B 验收；禁止 commit/push/PR 与 Human Gate Pass 声明。 |

## Completeness Check

- Required fields present: yes
- Any `UNKNOWN`: none
- Exactly one Domain Owner: yes
- Human and environment dependencies explicit: yes
- Product, Architecture, implementation and Quality authority separated: yes
