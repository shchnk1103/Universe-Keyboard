# Assignment: KEYBOARD-LAYOUT-9KEY-PINYIN-002 — 九宫格精准选项与选拼音循环

**Policy version:** `1.0.0`  
**Lifecycle status:** `Blocked — physical-device Product Gate failed; remediation delegated to KEYBOARD-LAYOUT-9KEY-PINYIN-003`
**Repository change types:** `Contract`, `State`, `Implementation`, `Evidence`, `Documentation`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-002`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md), `2026-07-19 Asia/Shanghai`
- **Product Approver:** Product Lead under KOS 2.0
- **Related Closed predecessor:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-001`](keyboard-layout-9key-pinyin-001.md)
- **Required Architecture Decision:** [ADR 0021](../architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md)

## Acknowledgement And Lifecycle

- Human Product Owner explicitly approved continuation under KOS 2.0 on `2026-07-19 Asia/Shanghai`.
- Assignment Decision is complete; no required field is `UNKNOWN`.
- Executor acknowledges Scope, Non-goals, phase gates, and Stop Conditions.
- Lifecycle advanced `Assignment Required -> Assigned -> Acknowledged -> Ready -> Active` on `2026-07-19 Asia/Shanghai`.
- Phase 1 ADR accepted and Phase 2 Spike passed on `2026-07-19 Asia/Shanghai`.
- Phase 3 KeyboardCore and Phase 4 Keyboard UI implementation completed locally; focused/full Core tests, RimeBridgeTests, main scheme Simulator tests, and Debug/Release strict builds passed. Phase 5 remains `Active` for clean-commit evidence and physical-device Product Gate; independent Architecture/Quality addenda are recorded below.
- Human Product Owner authorized Amendment A segmented disambiguation on `2026-07-19 Asia/Shanghai`. Its real-RIME hard gate passed, and the bounded Core/UI implementation plus automated validation completed locally; independent review and physical-device Product Gate remain open.
- Human Product Owner authorized Amendment C on `2026-07-21 Asia/Shanghai` after observing that long segmented input could collapse the next focus to one displayed RIME-ranked syllable. Product Decision and ADR revalidation are complete; bounded diagnosis and implementation may proceed under the existing roles and Stop Conditions.
- Human Product Owner authorized Amendment D on `2026-07-21 Asia/Shanghai` after observing wrong Partial Commit remainder provenance, host-visible spaced T9 digits, and predictive rather than visible-character Delete. Product Decision and ADR revalidation are complete under the existing role and Stop Condition boundaries.

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer — choice/cycle state, refinement transaction, lifecycle invariants
- **Executor:** Codex — bounded implementation and documentation within this Assignment
- **Supporting domains:**
  - 🔧 RIME Platform Maintainer — pinned-librime Spike and session evidence
  - ⌨️ Keyboard Experience Maintainer — path-bar rendering, button forwarding, accessibility
- **Environment Executor:** Codex for local Spike preparation, Simulator tests/builds, and evidence packaging; Human Product Owner for physical-device Product Gate capture
- **Human Dependency:** Human Product Owner — physical-device native comparison and final product acceptance
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward through a separate review handoff
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer through a separate review handoff
- **Handoff Target:** Architecture and Quality review after implementation; Product Lead after physical-device evidence

## Boundary

### Scope

1. Publish this Product Decision, Assignment, ADR 0021, and KOS navigation/status mirrors.
2. Extend KeyboardCore precise-path state to preserve an authorized displayed choice set and cycle selection across successful `replaceInput` refinement.
3. Provide deterministic single-digit key-group choices using one canonical T9 key-identity mapping.
4. Continue using current compatible RIME comments for multi-key full paths.
5. Add a Core-owned next-choice action; route direct tap and **选拼音** cycling through the same transactional selection path.
6. Replace **选拼音** full-panel presentation with first/next/wrap selection behavior.
7. Preserve no-raw-host-commit, rollback, stale-state invalidation, session-only Extension, and bounded hot-path contracts.
8. Add focused KeyboardCore tests, real RimeBridge Spike coverage, Keyboard UI/contract coverage, strict Simulator builds, documentation, changelog, and Product Gate handoff.
9. Amendment A: add whole-composition versus segmented modes; retain a focused tentative segment across later digit groups; confirm/advance by tapping the already selected path; display the next segment's RIME-authorized choices; show **选定** on active T9 composition while preserving candidate commit semantics.
10. Amendment C: treat the initial 16-candidate window as non-exhaustive, preserve explicit user choice when long-input next-focus discovery yields one syllable, and supplement exact syllables only with bounded live-authorized branches while capacity remains.
11. Amendment D: align Partial Commit to the true remaining digit suffix even when RIME preedit contains spaced digits; prohibit host-visible T9 raw digits; make ordinary unconfirmed T9 Delete shorten the exact visible pinyin character while preserving segmented/checkpoint rollback contracts.

### Non-goals

- Every Non-goal in the linked Product Decision
- Unrelated candidate-bar, keyboard-layout, settings, typo-correction, or RIME deployment refactors
- Reopening or rewriting the Closed `001` Assignment
- Claiming Architecture, Quality, or Product acceptance from implementation alone

### Required Inputs

- Linked Product Decision and this Assignment
- ADR 0018, ADR 0020, proposed ADR 0021
- `KEYBOARD_LAYOUT.md`, input-pipeline architecture, UI style guide, debugging and release checklist
- KeyboardCore, RimeBridge, Keyboard UI, Test/Release, Coordinator, and Documentation playbooks
- Pinned librime `1.16.1`, compatible deployed `t9` fixture, existing T9 Spike harness
- User-provided screenshots as Product reference inputs; repository evidence must record behavior without depending on temporary clipboard paths

## Gates

### Entry Criteria

| Criterion | Status |
|---|---|
| Stable Product Decision | **Met** |
| Required Assignment fields complete | **Met — no `UNKNOWN`** |
| Single Domain Owner | **Met** |
| Closed predecessor preserved | **Met** |
| Phase-specific Stop Conditions explicit | **Met** |

### Phase Gates

| Phase | Entry condition |
|---|---|
| 1 — Contract / ADR | Assignment `Active` |
| 2 — Real RIME Spike | ADR 0021 Proposed; pinned fixture available |
| 3 — KeyboardCore tests/implementation | Spike proves `m/n/o`; ADR 0021 Accepted |
| 4 — Keyboard UI | Core focused tests green |
| 5 — Integrated validation/docs | Core/UI implementation complete |
| Product Gate | Independent Architecture + Quality handoffs complete; Human Dependency device comparison captured |

Amendment A repeats Phase 1 Contract/ADR and Phase 2 real-RIME Spike before any segmented Core/UI implementation. Earlier baseline implementation evidence does not waive the new gate.

Amendment C revalidates Phase 1 Contract/ADR before implementation. It does not require a new librime binary or schema Spike unless diagnosis shows the existing `candidateWindow` and live-probe contracts cannot establish the required alternatives; that condition stops implementation and returns to RIME Platform/Architecture.

Amendment D revalidates Phase 1 Contract/ADR before implementation. It stays within existing RIME `replaceInput`, Partial Commit and display-projection contracts; any need for schema mutation, digit-to-letter guessing, UIKit-owned state or unbounded replay stops implementation.

### Exit Criteria

- ADR 0021 Accepted and linked from domain authority
- Real Spike evidence proves all single-digit `6` choices are safe refinements
- Focused and full KeyboardCore tests pass
- RimeBridge Simulator tests and affected Debug/Release builds pass
- UI shows `m/n/o`, direct selection, `m -> n -> o -> m` cycling, and selected accessibility state
- Lifecycle and rollback regression matrix passes
- `KEYBOARD_LAYOUT.md`, input pipeline, UI guide, release checklist, Dashboard, Knowledge Index, and changelog are synchronized
- Independent Architecture and Quality conclusions are recorded
- Physical-device Product Gate is decided by Product Lead

### Stop Conditions

Stop and return to Architecture/Product Lead when:

1. Any Assignment field becomes `UNKNOWN` or authority conflicts appear.
2. Pinned librime cannot safely refine any displayed `m/n/o` choice without commit or candidate loss.
3. Meeting the behavior requires librime upgrade, schema mutation, Extension deployment, or a second pinyin/candidate engine.
4. Cycle state cannot be invalidated safely across Delete, new key, commit, page/language, visibility, fallback, or recovery.
5. Production implementation begins before Spike PASS and ADR acceptance.
6. Unbounded path probing, synchronous persistence, private host-text logging, or raw-input host commit is introduced.
7. Automated evidence is presented as physical-device Product acceptance.

## Handoff

- **2026-07-22 Product Gate outcome:** physical-device reports confirmed Path Bar latency, stale post-candidate paths and remaining internal-digit exposure. `002` cannot advance to `Reviewed` or `Closed`; remediation authority moved to [`KEYBOARD-LAYOUT-9KEY-PINYIN-003`](keyboard-layout-9key-pinyin-003.md). Historical A–H implementation evidence remains valid only for the runs it records.
- **Current phase:** Amendment D local implementation, automated validation and Architecture/Quality addenda complete; clean-commit Spike and physical-device Product Gate remain for A+B+C+D
- **Completed gate evidence:** [`keyboard-layout-9key-pinyin-002-spike-summary.md`](keyboard-layout-9key-pinyin-002-spike-summary.md) — librime `1.16.1`, deterministic `m/n/o`, candidate counts `9/9/4`, no host commit
- **Local implementation evidence:** focused `T9PinyinPathTests` passed (`27`, zero failures); KeyboardCore full suite passed; RimeBridgeTests and main scheme Simulator tests passed; Debug/Release generic iOS Simulator builds passed with strict concurrency and warnings-as-errors. Counts describe this local run only and are not release invariants.
- **Known environment skips:** the default RimeBridgeTests run skipped four fixture-gated real-runtime cases as designed; the new `m/n/o` real T9 case was separately executed with explicit fixture and passed under the tracked Spike summary.
- **Acceptance clarification fix:** visible preferred-candidate-style path highlight plus exact selected-path marked text are implemented. Focused path tests, KeyboardCore full suite, main scheme Simulator tests, and Debug/Release strict builds were refreshed after the fix and passed.
- **Pending validation:** clean-commit Spike re-run; physical-device long Partial Commit, digit-safety, visible-character Delete, VoiceOver and latency evidence; Product Gate. Quality therefore remains overall `Blocked` even though the Amendment D automated scope passed.
- **Amendment A evidence:** [`keyboard-layout-9key-pinyin-002-native-segmented-observation.md`](keyboard-layout-9key-pinyin-002-native-segmented-observation.md)
- **Amendment A Spike:** [`keyboard-layout-9key-pinyin-002-segmented-spike-summary.md`](keyboard-layout-9key-pinyin-002-segmented-spike-summary.md) — PASS; `authorizedSuffixes=g|h`, with fallback-only `i` rejected.
- **Amendment A local validation:** focused path tests `34/34`; KeyboardCore full suite `628/628`; main App + Extension Debug and Release strict generic-Simulator builds PASS. Interactive product comparison remains pending.
- **Amendment B (2026-07-20):** Product authorized progressive first-syllable compact paths + syllable-level confirm/advance; multi-syllable whole labels banned from path bar; UI single-line defense; direct path tap confirms/advances immediately while **选拼音** only cycles tentative selection. Focused `T9PinyinPathTests` `39/39` PASS.
- **Amendment C (2026-07-21):** Product rejected single-option next-focus collapse as an implicit decision. Core now uses a bounded 48-item discovery window, supplements exact syllables with bounded live-authorized key branches while capacity remains, restores raw after every probe, and publishes every new focus with `selectedPath == nil`. Focused `T9PinyinPathTests` `41/41`, KeyboardCore `639/639`, RimeBridgeTests `28` passed + `4` fixture-gated skips, main scheme tests `127/127`, and Debug/Release strict generic-Simulator builds PASS. Physical-device replay and latency evidence remain pending.
- **Amendment D (2026-07-21):** Core now normalizes digit/separator-only preedit tails to remaining raw, aligns `toutoumaiqiule → 偷偷买` to `74853 / qiu le`, blocks internal digits and digit-bearing comments from host display including session fallback, and implements ordinary unconfirmed Delete `tou → to → t → empty` through exact refinement with double-failure fail-closed. Focused T9/Partial/display matrix `90/90`, KeyboardCore `642/642`, RimeBridgeTests `28` passed + `4` fixture skips, main scheme `127/127`, Vendor verification and Debug/Release strict builds PASS. Physical-device replay and latency evidence remain pending.
- **Independent Architecture Review + Amendments C/D addenda (2026-07-21):** [Pass with mandatory Quality, latency and physical-device follow-up](../evidence/keyboard-layout-9key-pinyin-002-architecture-review-2026-07-21.md). This does not close the Assignment or replace Quality/Product Gate evidence.
- **Independent Quality Review + Amendments C/D addenda (2026-07-21):** [Automated Amendment D scope PASS; overall Blocked because clean Spike and device/Product Gate evidence remain open](../evidence/keyboard-layout-9key-pinyin-002-independent-quality-review-2026-07-21.md). This does not accept risk or make a Product Gate decision.
- **Review handoff:** [`keyboard-layout-9key-pinyin-002-review-handoff.md`](keyboard-layout-9key-pinyin-002-review-handoff.md)
- **Human Product Gate handoff:** [`keyboard-layout-9key-pinyin-002-product-gate-human-handoff.md`](keyboard-layout-9key-pinyin-002-product-gate-human-handoff.md)
- **Required handoff content:** changed behavior/files, state-transition examples, exact commands/results, skipped validation, Stop Condition status, docs impact, and physical-device matrix
- **Revalidation Trigger:** librime/T9 schema change; choice-source or cycle-order change; panel restoration; new multi-digit generation strategy; lifecycle/session contract change; scope expansion

## Completeness Checklist

| Required field | Value |
|---|---|
| Task ID / Title | `KEYBOARD-LAYOUT-9KEY-PINYIN-002` / 九宫格精准选项与选拼音循环 |
| Assignment Authority | Product Lead |
| Decision Source / Date | `PD-...-002`, `2026-07-19 Asia/Shanghai` |
| Domain Owner | Input Intelligence Maintainer |
| Executor | Codex |
| Environment Executor | Codex local/Simulator; Human Product Owner device |
| Human Dependency | Human Product Owner |
| Architecture Reviewer | Architecture & Knowledge Steward, separate handoff |
| Quality Reviewer | Quality, Performance & Release, separate handoff |
| Product Approver | Product Lead |
| Required Inputs | Present |
| Entry / Exit / Stop Conditions | Present |
| Handoff Target | Present |
| Revalidation Trigger | Present |
| Any `UNKNOWN` | **None** |

## Amendment E/F/G execution addendum

- **授权角色：** Product Lead 授权 E（确认前缀与候选 session 同步）、F（有界完整音节发现）、G（逐键最多一个可见字母）；Architecture/Quality 仅在各自证据文件内裁决，Product Gate 保留给真机交互验收。
- **Scope 12：** 确认 `qiu` 后将 live raw 锚定为 `qiu' + 剩余数字`，marked text 只显示用户确认部分，所有候选与路径必须继承确认前缀。
- **Scope 13：** 对最多 6 位剩余数字执行最多 48 次 exact live-RIME probe，完整音节优先于单字母后备；不得发布未经 provenance 校验的组合。
- **Scope 14：** 普通 T9 comment 按已输入 ASCII 字母/数字槽位投影，保证 `8 → t`、`86 → to`、`868 → tou`，内部预测与数字不可见。
- **Stop / rollback：** 锚定 raw、usable session、confirmed-prefix comment 或 probe 恢复任一失败，回滚完整转换；不得以 UI 层猜测补齐。
- **Local evidence：** T9 Path `46/46`、布局与运行时 `14/14`、KeyboardCore 全量 `647/647`。最终 Debug 包已成功构建并安装到 iPhone 13 Pro / iOS 27.0；空白备忘录首按 `TUV` 实测 marked text 为 `t`。Device Hub 后续焦点漂移使 `to / tou` 与 `qiu → le` 未能稳定留证，Product Gate 仍为 Pending。
- **Handoff：** Phase A–G 实现与自动化评审完成后交 Human Product Owner 执行 iPhone 13 Pro 矩阵；设备、OS、构建、marked text、候选和 Path Bar 结果必须逐项留证。

## Amendment H continuation

- **Scope 15：** Path Bar 只替换已选择槽位，保留未确认可见后缀（`qiu/shu + le`）。
- **Scope 16：** 嵌套候选 Delete 恢复显式锚定 raw 与安全 host 快照，禁止字母数字混合 preedit 泄漏。
- **Scope 17：** 候选撤销后的下一次 Delete 删除当前未确认尾槽（最后一次输入：`qiu'53 → qiu'5`、`qiule → qiul`）。
- **Current state：** 实现已写入；focused qiu 完整序列曾 PASS。最后 refined-raw 通用修正因执行额度限制尚未复跑，Quality 与 Product Gate 均不得标记最终 PASS。
- **Cross-model handoff：** [`keyboard-layout-9key-pinyin-002-grok-handoff-2026-07-21.md`](keyboard-layout-9key-pinyin-002-grok-handoff-2026-07-21.md)。
