# Assignment: HELP-TIPKIT-001 — 软首启、帮助入口与 TipKit 展示层

**Policy version:** `1.0.0`  
**Task ID:** `HELP-TIPKIT-001`  
**Decision source / date:** [`PD-HELP-TIPKIT-001`](../product-decisions/HELP-TIPKIT-001-authorization.md), Human Product Owner product choices locked in Grok session, `2026-07-25 Asia/Shanghai`  
**Predecessor:** [`RELEASE-2026-0801-03`](release-2026-08-01-03-onboarding-full-access.md) (`Closed` — activation checklist semantics)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` |
| **Phase** | P1–P3 实现已交付；等待独立 Quality 结论与 Human Product Gate |
| **Non-claims** | 不宣称 Product Gate、Quality 已过或 Activation 语义被改写 |
| **Next** | Quality Reviewer → Human Product Lead 验收软首启 / Help IA / TipKit 表面 |
| **Residuals** | 无实现残余；关单仍需 Product Gate |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-HELP-TIPKIT-001`](../product-decisions/HELP-TIPKIT-001-authorization.md), `2026-07-25 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead for presentation decisions recorded in `PD-HELP-TIPKIT-001`

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** Grok session acting as App & Data Operations Maintainer / Main App UI (soft Welcome, Help tab IA, Settings entry, optional TipKit packaging; main App only)
- **Environment Executor:** Grok session for Simulator / unit-test / build evidence; Human Product Owner for optional physical-device spot-check of tab visibility and Settings re-entry (not required to start P1)
- **Human Dependency:** Human Product Owner — final Product Gate on first-run soft path, Help tab hide/show, Settings re-entry and re-read behavior; wording acceptance if copy beyond existing C1–C9 is introduced
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward — **Not Applicable** for pure presentation/IA work that does not change App Group, FA observation model, privacy claims or activation success criteria; **required** if implementation crosses those boundaries
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer
- **Supporting Domain:** 📱 Main App UI playbook; consult Keyboard Experience only if copy implies Extension behavior (no Extension UI work in scope)
- **Handoff Target:** Quality Reviewer, then Product Lead

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-07-25 Asia/Shanghai` — presentation packaging for activation Help / soft first-run / TipKit authorized by `PD-HELP-TIPKIT-001`; Executor and Environment Executor named; no required field `UNKNOWN`.
- **Executor acknowledgement:** `2026-07-25 Asia/Shanghai` — Scope, Non-goals, Stop Conditions, soft Welcome + Help rename (P1) accepted; activation semantics remain `ONBOARDING_ACTIVATION` / `PD-RELEASE-2026-0801-03`.
- **Entry Criteria status:** **Met.** PD recorded; roles named; activation semantics predecessor closed; product source path clear; Executor acknowledged.
- **Product lifecycle decision:** `Ready → Active` on Human instruction “开始P1”, `2026-07-25 Asia/Shanghai`.
- **Current phase:** **Completed — P1–P3 implementation complete**; Product Gate / Quality handoff pending. Product Lead authorized Active-slot removal `2026-08-14 Asia/Shanghai`.

## Boundary

### Scope

Authorize and implement main-App **presentation packaging** for the existing activation journey:

1. **P1 — Soft Welcome + 帮助 rename**
   - Skippable Welcome (J0) on first main-App open.
   - Persist Welcome-seen separately from checklist completion.
   - Rename visible tab **引导 → 帮助**.
   - Keep re-entrant checklist and `ActivationChecklistState` rules.

2. **P2 — Tab visibility + Settings anchor + re-read**
   - Hide **帮助** tab when fully activated and healthy.
   - Permanent Settings navigation entry to the same Help surface.
   - Re-show Help tab when recovery conditions hold (incomplete checklist, `sharedDataUnavailable`, actionable resources recovery per PD).
   - **重新走一遍** = re-read step instructions without clearing affirmations or deployment truth.

3. **P3 — TipKit contextual tips (main App)**
   - Optional TipKit tips for activation steps (one tip / one action).
   - Invalidate on corresponding checklist completion.
   - iOS 17+ API only (deployment target already higher).
   - No Keyboard Extension tips.

4. **Documentation**
   - Keep `ONBOARDING_ACTIVATION.md` aligned with authorized presentation (Help IA, soft Welcome, TipKit mapping, re-read policy).
   - Do not invent competing journey semantics.

### Non-goals

- Changing activation success criteria, FA optionality, or capability matrix truth
- General feature Tips Library beyond activation steps
- Keyboard Extension TipKit or any Extension tip UI
- Default “重置启用进度” that clears user affirmations
- Extension deployment, new network/account services, programmatic keyboard enablement claims
- App Store submission / public materials
- Closing TD-004 unless separately assigned
- Unrelated Settings IA redesign beyond the Help entry row and recovery links already needed for activation

### Required Inputs

- [`PD-HELP-TIPKIT-001`](../product-decisions/HELP-TIPKIT-001-authorization.md)
- [`PD-RELEASE-2026-0801-03`](../product-decisions/RELEASE-2026-0801-03-activation-authorization.md)
- [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)
- [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) (main-App structure)
- [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- Existing: `GuideTab.swift`, `ActivationChecklistState.swift`, `ContentView.swift`, `ActivationChecklistStateTests`
- ADR 0001, 0003, 0007, 0008 (boundary only; no change expected)
- Apple TipKit documentation (P3)

## Gates

### Entry Criteria

- [x] Product Decision `PD-HELP-TIPKIT-001` recorded with locked choices (soft first-run, Help naming, recovery re-show, re-read not reset, TipKit iOS 17+, no Extension tips)
- [x] Domain Owner, Executor, Environment Executor, Human Dependency, Quality Reviewer named or justified
- [x] No required Assignment field is `UNKNOWN`
- [x] Activation semantics predecessor (`RELEASE-2026-0801-03`) remains the single source for checklist truth
- [ ] Executor acknowledgement on first `Active` turn

### Exit Criteria

**P1**

- Fresh install / cleared Welcome flag: soft Welcome appears once; Skip and Start both work; Welcome does not equal activation success.
- Tab label is **帮助** while the tab is shown.
- Existing checklist unit tests still pass; no FA/privacy copy regressions against C1–C9.

**P2**

- When `isFullyActivated` and no recovery condition: Help tab hidden; Settings entry opens the same guide content.
- When recovery condition true: Help tab visible again.
- Re-read path does not clear affirmations or `rime_deployed`.
- Unit tests cover Help-tab visibility projection (pure function preferred).

**P3**

- TipKit tips (if shipped) map 1:1 to activation actions; invalidate with checklist; no full privacy policy in tips; no Extension tips.
- Tips do not replace Help checklist as the only recovery surface.

**Assignment close**

- Handoff package complete; Quality conclusion recorded; Product Gate (Human) accepts soft first-run + Help IA; `ONBOARDING_ACTIVATION.md` presentation sections updated; lifecycle → `Closed` only after Product acceptance.

### Stop Conditions

Stop and escalate to Product Lead / Architecture as applicable if:

- Implementation requires claiming a live Extension Full Access flag from the main App alone
- Copy states that Full Access is required for basic Chinese typing
- Activation next-step order or success definition is changed without amending `PD-RELEASE-2026-0801-03`
- TipKit or Help path is placed in Keyboard Extension
- “重新走一遍” is implemented as silent progress reset without a new Product Decision
- App Group / deployment ownership (main App deploys; Extension does not) is altered
- Required evidence is fabricated when device/Simulator runs fail

## Phased execution notes

| Phase | Primary files (expected) | Evidence |
|---|---|---|
| P1 | `ContentView`, Welcome view, `GuideTab` title/label, Welcome `@AppStorage` | Simulator first-open + Skip; unit tests green |
| P2 | Tab visibility helper pure logic + tests; Settings link; Help surface shared | Unit tests for visibility matrix; Simulator complete → hide → recovery → show |
| P3 | TipKit tip types, invalidate wiring to checklist | Simulator tip show/invalidate; no Extension target changes |

Executor may ship P1 alone behind a complete handoff if Product accepts incremental review; P2 is required before claiming the full IA Decision done; P3 may be deferred only with explicit Product note on the Assignment (TipKit remains authorized, not abandoned).

## Handoff

- **Required Handoff Content:**
  - Changed files and phase completed (P1/P2/P3)
  - Welcome / Help visibility / Settings entry behavior summary
  - Test commands and results
  - Screenshots or short notes for soft Welcome, tab hide, Settings re-entry, recovery re-show (when available)
  - Confirmation that activation semantics and C1–C9 were not rewritten ad hoc
  - Known limitations (e.g. P3 deferred)
- **Handoff Target:** Quality Reviewer → Product Lead (Human Product Gate)
- **Revalidation Trigger:** Activation state model change; FA/privacy matrix change; deployment target drop below TipKit floor; product request for progress-reset or Extension tips; Help content expansion beyond activation steps

## Completion Record

### P1 (`2026-07-25 Asia/Shanghai`)

- Soft Welcome sheet on first open; Start → Help tab; Skip / dismiss → stay Home; `activation_welcome_seen` independent of checklist.
- Tab label **帮助**.
- Files: `ActivationWelcomeView.swift`, `ContentView.swift`, `ActivationChecklistState.swift` (`ActivationPresentationStorage` + welcome copy), tests.
- Evidence: `UniverseKeyboardTests/ActivationChecklistStateTests` **7/7 PASS** on iPhone 17 Pro Simulator (id `900FB396-…`, iOS 26.5).

### P2 (`2026-07-25 Asia/Shanghai`)

- `ActivationChecklistState.shouldShowHelpTab` pure visibility; Help tab hidden when fully activated and healthy; re-shows on incomplete / FA recovery / resources recovery.
- Settings permanent entry: **使用帮助与启用指南** → same `GuideTab` (no nested NavigationStack).
- Re-read: banner + expandable checklist steps; does not clear affirmations or `rime_deployed`.
- Files: `ActivationChecklistState.swift`, `ContentView.swift`, `SettingsTab.swift`, `GuideTab.swift`, tests.
- Evidence: `UniverseKeyboardTests/ActivationChecklistStateTests` **12/12 PASS** on iPhone 17 Pro Simulator (id `900FB396-…`, iOS 26.5).

### P3 (`2026-07-25 Asia/Shanghai`)

- TipKit configured in main App only (`ActivationTips.configure()`); no Keyboard Extension tips.
- Four tips (add keyboard / Full Access / prepare resources / first input), each one action; copy from `ActivationCopy`; `@Parameter stepComplete` + `#Rule` invalidates on checklist completion via `ActivationTips.sync`.
- Surfaces: Help next-step popover; Settings RIME row (prepare resources); Home keyboard card (first input when that step is next).
- Files: `ActivationTips.swift`, `Universe_KeyboardApp.swift`, `ContentView.swift`, `GuideTab.swift`, `HomeTab.swift`, `SettingsTab.swift`, `ActivationChecklistState.swift` (`nonisolated` pure model/copy for Tip protocol).
- Evidence: `UniverseKeyboardTests/ActivationChecklistStateTests` **14/14 PASS** on iPhone 17 Pro Simulator (id `900FB396-…`, iOS 26.5).
- **Remaining for Assignment close:** Human Product Gate on soft Welcome + Help IA + tip surfaces; optional Quality review.
