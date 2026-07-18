# Assignment: KEYBOARD-LAYOUT-9KEY-PINYIN-001 — 九宫格精准选拼音

**Policy version:** `1.0.0`

**Lifecycle status:** `Active`

**Repository change types:** `Contract`, `Documentation`, `Evidence`, `Implementation`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Stable repository Product Decision [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-001`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-001-authorization.md), recorded `2026-07-18 Asia/Shanghai`.
- **Product Approver (Assignment / Product Gate):** Product Lead under `docs/ASSIGNMENT_POLICY.md` (KOS 2.0). Human Product Owner is **not** the Product Lead role; they act as Human Dependency for physical-device capture and final product acceptance where required.
- **Product Plan (non-authority input):** [`docs/plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md`](../plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md)
- **Architecture Decision (required deliverable):** New independent ADR extending ADR 0018 (filename/number assigned by Architecture & Knowledge Steward during phase 1; must not silently rewrite ADR 0018 decisions).
- **Related closed predecessors:**
  - Runtime V1: [`keyboard-layout-9key-001.md`](keyboard-layout-9key-001.md) (`Closed`)
  - Chrome placeholder: [`keyboard-layout-9key-ui-001.md`](keyboard-layout-9key-ui-001.md) (`Closed`)

## Acknowledgement And Lifecycle History

- **Product Decision recorded:** `2026-07-18 Asia/Shanghai` — Product Lead under Human Product Owner instruction to exercise KOS 2.0 Product Lead authority for this Work Item.
- **Assignment Decision:** Complete; no required field is `UNKNOWN`.
- **Executor acknowledgement:** Pre-authorized by Human Product Owner’s original execute-plan objective and subsequent Product Lead switch instruction; Executor **Grok** may treat Scope / Stop Conditions / plan phase order as acknowledged for `Ready → Active`.
- **Lifecycle:** `Assignment Required → Assigned → Acknowledged → Ready` on `2026-07-18 Asia/Shanghai`.
- **Domain Owner activation:** `2026-07-18 Asia/Shanghai` — 🧠 Input Intelligence Maintainer acknowledged Scope/Stop Conditions and moved lifecycle **`Ready → Active`** for plan phases 1–2 (ADR + real librime Spike). UI phases remain gated.
- **Work branch:** `feature/keyboard-layout-9key-pinyin-001`

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer (primary — composition refinement semantics, KeyboardCore path state/actions/effects, mixed-T9 invariants, fail-closed path parsing)
- **Executor:** Grok (bounded packages under Input Intelligence, RIME Platform, Keyboard Experience; documentation updates for touched contracts)
- **Supporting domain packages (not co-owners):**
  - 🔧 RIME Platform Maintainer — real `t9` Spike, `replaceInput` / candidate-window evidence, session-only boundary
  - ⌨️ Keyboard Experience Maintainer — fixed path bar, 选拼音 panel, mutual-exclusion chrome, a11y
- **Environment Executor:** Grok for Spike, simulator builds/tests, and local evidence packaging; Human Product Owner for physical-device keyboard-extension capture required by Product Gate
- **Human Dependency:** Human Product Owner — physical-device operation, side-by-side native comparison screenshots/video, and final product acceptance (**unsatisfied** until device gate)
- **Architecture Reviewer:** Architecture & Knowledge Steward via Codex review handoff
- **Quality Reviewer:** Quality, Performance & Release Maintainer via Codex review handoff + automated matrix in plan
- **Product Approver:** Product Lead
- **Handoff Target:** After each phase gate — Codex Architecture/Quality as required; final Product Gate returns to Product Lead

## Boundary

### Scope (authorized)

1. Product Decision (this Decision Source) and complete Assignment lifecycle management for this Work Item.
2. Independent ADR extending ADR 0018 for precise pinyin selection / mixed T9 raw input / composition refinement / comment provenance.
3. Real librime Spike on pinned vendor + deployed-compatible `t9` (no vendor upgrade), with transferable evidence archive.
4. KeyboardCore public models/actions/effects:
   - `T9PinyinPath`, `T9PinyinPathState`, `T9PinyinPathWindow`
   - `KeyboardAction.selectT9PinyinPath`
   - `KeyboardEffect.t9PinyinPathsChanged`
   - `KeyboardController.t9PinyinPathWindow(from:limit:)` (or equivalent pure API named in implementation)
5. Mixed T9 composition invariants (Space/Return/language/typo suppression/transactional `replaceInput`/state clear on commit-delete-visibility-recovery).
6. Keyboard Extension UIKit:
   - fixed-height `T9PinyinPathBarView` (34 pt reservation)
   - mutual-exclusive expansion modes (`none` / `candidateExpansion` / `pinyinPathExpansion`)
   - full 选拼音 path panel with lazy candidate-window scanning
7. Automated tests per plan (KeyboardCore, RimeBridge, UI/contract as applicable).
8. Debug/Release strict concurrency builds for affected targets.
9. Domain documentation updates after behavior lands: `KEYBOARD_LAYOUT.md`, input-pipeline docs, `UI_STYLE_GUIDE.md`, `RELEASE_CHECKLIST.md`, `CHANGELOG.md`; Dashboard sync.
10. Evidence packages for Spike and implementation reviews; device evidence folder when Human Dependency captures.

### Non-goals (explicitly prohibited)

- librime / RIME vendor binary upgrade
- Main-App deployment ownership change; Extension-side RIME deploy or schema install/patch beyond existing compatible `t9` consumption
- Changing 26-key product behavior or QWERTY metrics beyond unavoidable shared chrome constants already governed elsewhere
- English nine-key, multi-tap letter selection, swipe letter pick
- Live layout hot-switch while keyboard remains visible
- Second Chinese candidate engine / offline parallel pinyin graph
- Main-App settings UI or user toggle for V1
- Full 颜表情 product content
- Raw-input (digit/letter/mixed) host commits
- Commit, push, or PR creation unless Human Product Owner separately authorizes publication
- Skipping Spike or simulating Spike results in UI-only logic

### Required Inputs

- This Product Decision and Assignment (no `UNKNOWN`)
- Active plan: `docs/plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md`
- ADR 0018, ADR 0001 / 0002 / 0003 / 0004 (lifecycle, deploy, session, visibility)
- `docs/KEYBOARD_LAYOUT.md`, `docs/architecture/input-pipeline-and-marked-text.md`, `docs/UI_STYLE_GUIDE.md`
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- Playbooks: `keyboard-core.md`, `rime-bridge.md`, `keyboard-ui.md`, `test-release.md`
- Pinned librime / existing T9 Spike harness as starting point (`RimeT9CompatibilitySpikeTests` / `scripts/run_t9_compatibility_spike.sh` lineage)
- Closed predecessor Assignments for residual context only (not expanded authority)

## Gates

### Entry Criteria (`Ready` — satisfied `2026-07-18`)

| Criterion | Status |
|---|---|
| Verifiable Product Decision Source | **Met** — `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-001` |
| All Assignment required fields assigned or justified | **Met** — no `UNKNOWN` |
| Single primary Domain Owner | **Met** — Input Intelligence Maintainer |
| Plan phase order and hard Spike stop accepted | **Met** — bound in Product Decision |
| No conflict with permanent ownership / Closed predecessor non-goals | **Met** — new Work Item; residual 选拼音 explicitly reopened here |

### Phase Entry Criteria (for `Active` work packages)

| Phase package | May start when |
|---|---|
| 1 — ADR draft | Lifecycle `Ready` or `Active`; Product Decision in force |
| 2 — Real librime Spike | Phase 1 ADR draft exists **or** Spike runs in parallel only to feed ADR evidence; UI still blocked until Spike PASS + ADR Accepted |
| 3–4 — KeyboardCore | Spike **PASS** archived; ADR **Accepted** (Architecture) |
| 5–6 — Extension UI | Phases 3–4 complete with green KeyboardCore tests; Spike stop conditions still false |
| Product Gate | Implementation review complete; Human Dependency device matrix recorded |

### Exit Criteria

| Criterion | Owner of conclusion |
|---|---|
| ADR Accepted and linked from Assignment / KEYBOARD_LAYOUT | Architecture |
| Spike evidence archive with pinned librime, schema, I/O, comments, delete, performance notes | Domain Owner + Quality review |
| KeyboardCore + RimeBridge + applicable UI/contract tests green | Quality |
| Debug/Release strict concurrency builds green for affected targets | Quality |
| Docs updated (`KEYBOARD_LAYOUT`, input pipeline, UI guide, release checklist, CHANGELOG) | Domain Owner / Documentation under Architecture governance |
| Physical-device matrix in plan §真机验收 | Human Dependency capture + Quality/Product review |
| Independent Architecture + Quality conclusions | Codex handoff |
| Product Gate PASS and lifecycle `Closed` | Product Lead |

### Stop Conditions

Stop, set `Blocked`, and escalate to Product Lead / Architecture as applicable when:

1. Any required Assignment field becomes `UNKNOWN` or Revalidation Trigger fires without re-decision.
2. Spike shows `set_input` / `replaceInput` cannot accept required mixed forms.
3. Candidate comments cannot stably express full pinyin paths for product ranking/display.
4. Schema mutation or librime upgrade becomes mandatory for the feature to work.
5. Implementation attempts Extension deploy, readiness writes, or raw-input host commits.
6. UI proceeds without Spike PASS + ADR Accepted.
7. Second candidate engine or parallel pinyin table is introduced as product path source.
8. Privacy / Full Access expansion or network path is proposed for this feature.
9. Unexplained hot-path latency or keyboard-height thrash fails device performance expectations after measurement.

## Handoff

### Current handoff (Product Lead → Human Product Owner publication authority)

- **Status:** `Active` — Architecture **Pass**, automated Quality **Pass**, Product Gate **PASS**
- **Architecture (Codex rereview 5):** **Pass** — [`keyboard-layout-9key-pinyin-001-codex-rereview-5.md`](keyboard-layout-9key-pinyin-001-codex-rereview-5.md)
- **Quality automated matrix (Codex rereview 5):** **Pass**
- **Product Gate:** **PASS** (`2026-07-19 Asia/Shanghai`) — [`keyboard-layout-9key-pinyin-001-product-gate-pass.md`](keyboard-layout-9key-pinyin-001-product-gate-pass.md); Human Product Owner device acceptance「真机基本都 OK」
- **Authorized next action:** Human Product Owner **explicitly authorizes** commit (and optionally push / PR) of `feature/keyboard-layout-9key-pinyin-001`. After publication lands on default branch, Product Lead may move lifecycle toward `Completed` / `Reviewed` / `Closed`.
- **Publication:** **Ready pending Human authorization** — still dirty worktree until first feature commit; no commit/push/PR without explicit authorization.
- **Not authorized yet:** commit / push / PR (until Human Product Owner says so); lifecycle `Closed` (until publication + close decision).

### Required Handoff Content (implementation complete)

- Changed files and behavior summary
- Phase completion matrix vs plan
- Test/build commands and results
- Device-pending items
- Documentation updates
- Deviations from plan with reasons
- Residual risks and Stop Conditions status

### Revalidation Trigger

- Spike regression on pinned librime
- librime/vendor or T9 schema compatibility change
- Deployment-boundary change (ADR 0001/0018)
- Product request for English nine-key, multi-tap, swipe letter, user toggle, or second candidate engine
- Conflict with Accepted ADRs
- Scope expansion beyond this Assignment

## Completeness Checklist (Program Manager may verify)

| Field | Value |
|---|---|
| Task ID / Title | `KEYBOARD-LAYOUT-9KEY-PINYIN-001` / 九宫格精准选拼音 |
| Assignment Authority | Product Lead |
| Decision Source / Date | `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-001` / `2026-07-18 Asia/Shanghai` |
| Scope | Present |
| Non-goals | Present |
| Domain Owner | Input Intelligence Maintainer |
| Executor | Grok |
| Environment Executor | Grok (Spike/sim); Human for device |
| Human Dependency | Human Product Owner (device) |
| Architecture Reviewer | Architecture & Knowledge Steward (Codex) |
| Quality Reviewer | Quality, Performance & Release (Codex + matrix) |
| Product Approver | Product Lead |
| Required Inputs | Present |
| Entry / Exit / Stop | Present and executable |
| Handoff Target | Present |
| Lifecycle Status | `Active` |
| Revalidation Trigger | Present |
| Any `UNKNOWN` | **None** |

## Current Evidence Status

- **Product Decision:** Recorded.
- **Assignment completeness:** Complete; lifecycle **`Active`** (not `Completed` / `Reviewed` / `Closed`).
- **ADR:** [`0020-t9-precise-pinyin-path-selection.md`](../architecture/decisions/0020-t9-precise-pinyin-path-selection.md) — Accepted for implementation after Spike; dual-revision contract (`rawInputGeneration` vs `provenanceRevision`) and apply/soft boundary documented.
- **Architecture (Codex):** **Pass** — [`keyboard-layout-9key-pinyin-001-codex-rereview-5.md`](keyboard-layout-9key-pinyin-001-codex-rereview-5.md) (`2026-07-18 Asia/Shanghai`). No open P0/P1/P2 implementation blockers.
- **Quality automated matrix (Codex):** **Pass** — same rereview-5 record (KeyboardCore, KeyboardTests, Debug/Release strict Simulator builds, boundary scan). Does **not** close Product Gate.
- **Spike:** **PASSED** (`2026-07-18 Asia/Shanghai`). Summary: [`keyboard-layout-9key-pinyin-001-spike-summary.md`](keyboard-layout-9key-pinyin-001-spike-summary.md). Local archive: `evidence/keyboard-layout-9key-pinyin-spike/20260718-201043/` (dirty-worktree allowed run; re-archive on clean commit before publication if required).
  - librime `1.16.1`, schema `t9`
  - `replaceInput("o"|"ni")` no `committedText`; raw updated
  - `64 → ni`; continue digit → `ni4`; delete → `ni`
  - comments after `6` sparse (`o` in top window); after `64` at least `ni|mi`
- **KeyboardCore:** path models/actions/policy + dual revision + hard apply on new RimeOutput; `T9PinyinPathTests` (**21**); full package **615** tests (`swift test` in `Packages/KeyboardCore`, Codex rereview-5 independent run).
- **UI:** path bar + 选拼音 panel; a11y no business payload; panel/window/click bind **`provenanceRevision`** (not only raw generation); empty-path button disabled when availability is none.
- **Device / Product Gate:** **PASS** (`2026-07-19 Asia/Shanghai`) — Human Product Owner confirmed device OK; record [`keyboard-layout-9key-pinyin-001-product-gate-pass.md`](keyboard-layout-9key-pinyin-001-product-gate-pass.md).
- **Publication:** **Authorized** by Human Product Owner `2026-07-19` (commit + push + PR). Feature branch `feature/keyboard-layout-9key-pinyin-001`; lifecycle remains `Active` until PR merges and Product Lead closes Assignment.
- **Codex handoff package:** [`keyboard-layout-9key-pinyin-001-codex-handoff.md`](keyboard-layout-9key-pinyin-001-codex-handoff.md).
- **Codex implementation review:** [`keyboard-layout-9key-pinyin-001-codex-implementation-review.md`](keyboard-layout-9key-pinyin-001-codex-implementation-review.md) — Fail / Changes Required (historical).
- **Executor fix handoffs 1–5:**  
  [`handoff`](keyboard-layout-9key-pinyin-001-grok-fix-handoff.md) →  
  [`-2`](keyboard-layout-9key-pinyin-001-grok-fix-handoff-2.md) →  
  [`-3`](keyboard-layout-9key-pinyin-001-grok-fix-handoff-3.md) →  
  [`-4`](keyboard-layout-9key-pinyin-001-grok-fix-handoff-4.md) →  
  [`-5`](keyboard-layout-9key-pinyin-001-grok-fix-handoff-5.md) (new-output hard provenance + dual-revision docs).
- **Codex rereviews 1–5:**  
  [`r1`](keyboard-layout-9key-pinyin-001-codex-rereview.md) →  
  [`r2`](keyboard-layout-9key-pinyin-001-codex-rereview-2.md) →  
  [`r3`](keyboard-layout-9key-pinyin-001-codex-rereview-3.md) →  
  [`r4`](keyboard-layout-9key-pinyin-001-codex-rereview-4.md) →  
  [`r5`](keyboard-layout-9key-pinyin-001-codex-rereview-5.md) (**Architecture Pass / automated Quality Pass**).
- **Product Gate human handoff:** [`keyboard-layout-9key-pinyin-001-product-gate-human-handoff.md`](keyboard-layout-9key-pinyin-001-product-gate-human-handoff.md) (matrix; completed by Human acceptance).
- **Product Gate decision:** [`keyboard-layout-9key-pinyin-001-product-gate-pass.md`](keyboard-layout-9key-pinyin-001-product-gate-pass.md) — **PASS**.
- **Recommended next (KOS):** Merge feature PR into default branch → Product Lead marks Assignment `Completed` / `Closed` → branch cleanup only after merge reachability proven.
