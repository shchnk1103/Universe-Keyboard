# Product Decision: HELP-TIPKIT-001 — 帮助入口、软首启与 TipKit 展示层

**Decision ID:** `PD-HELP-TIPKIT-001`  
**Lifecycle status:** `Recorded`  
**Date / timezone:** `2026-07-25 Asia/Shanghai`  
**Assignment:** [`HELP-TIPKIT-001`](../assignments/help-tipkit-001.md)  
**Predecessor / binding activation semantics:** [`PD-RELEASE-2026-0801-03`](RELEASE-2026-0801-03-activation-authorization.md), [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)

## Authority

- **Product Approver / Decision maker:** Human Product Owner, through explicit product choices in the active Grok session (`2026-07-25 Asia/Shanghai`) locking first-run intensity, Help IA, TipKit scope and Extension non-goals; Product Lead records those choices here under KOS 2.0 Product authority.
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 📱 App & Data Operations Maintainer (main-App onboarding / Help presentation).
- **Executor:** Named on the linked Assignment (main-App UI only).
- **Architecture / Quality review:** Architecture & Knowledge Steward only if App Group, Full Access observation, privacy claims or activation success criteria change beyond existing ADR 0007/0008 and `PD-RELEASE-2026-0801-03`; Quality, Performance & Release Maintainer for independent evidence conclusions.

This Decision authorizes **presentation and navigation packaging** for the existing activation journey. It does **not** replace activation success criteria, Full Access optionality, capability matrix or canonical copy owned by `PD-RELEASE-2026-0801-03` / `ONBOARDING_ACTIVATION.md`.

## Product Problem

Task `RELEASE-2026-0801-03` shipped a truthful, re-entrant activation checklist in the main-App Guide tab. Residual product gaps:

1. First open has no soft Welcome; users land on Home without a clear “what to do first” moment.
2. The Guide tab is always a top-level tab, even after recommended activation is complete.
3. There is no product-bound path to **re-read** activation steps after completion.
4. TipKit was only documented as a future carrier; presentation rules for soft first-run, Help tab visibility, Settings entry and TipKit phase need an explicit Decision before implementation.

## Bound Product Decisions

### 1. Activation semantics remain single-sourced

1. Journey steps J0–J5, state model, C1–C9 copy, Full Access capability matrix and forbidden patterns remain owned by [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md) and [`PD-RELEASE-2026-0801-03`](RELEASE-2026-0801-03-activation-authorization.md).
2. Implementation must continue to drive progress from `ActivationChecklistState` (or an equivalent pure projection of the same rules). Presentation layers must not invent a second checklist or competing next-step order.
3. Changing activation success definition, Full Access optionality, privacy claims or the capability matrix still requires amendment of `PD-RELEASE-2026-0801-03`, not this Decision alone.

### 2. First-run intensity: soft

1. On first open of the main App, the product may present a **skippable** Welcome (J0): value + short privacy lines + primary CTA to begin setup + secondary CTA to dismiss.
2. Skip / dismiss must not block Home, must not force a tab switch, and must not equal activation success.
3. A dedicated preference (e.g. `activation_welcome_seen`) controls Welcome auto-presentation only. It is independent of checklist completion.
4. After Welcome has been seen or skipped, it must not auto-present again on ordinary launches. Users re-read activation content via Help, not by re-forcing Welcome every launch.

### 3. Help naming and information architecture

1. The top-level tab currently labeled **引导** is renamed **帮助** while it is visible.
2. Help content for this Decision is **activation-only**: re-enter / re-read J0–J5 (add keyboard → Full Access → prepare resources → first input → complete). It is not a general Tips Library of unrelated product features.
3. Settings always exposes a permanent navigation entry to the same Help / activation guide surface (stable anchor whether or not the Help tab is visible).

### 4. Help tab visibility (complete → Settings; recovery → tab returns)

Define **Help tab should be visible** when any of the following is true:

| Condition | Meaning |
|---|---|
| `ActivationChecklistState.nextStep != nil` | Recommended activation incomplete |
| `fullAccess == .sharedDataUnavailable` | Shared-data failure reopens recovery (overrides prior FA affirmation per activation rules) |
| Resources recovery needed | Deployment failed, or resources not ready in a way the product already surfaces as actionable recovery for complete experience (same readiness authority as J3; do not invent a live Extension flag) |

When **none** of the above hold (fully activated and healthy):

1. Hide the **帮助** tab from the main `TabView`.
2. Primary re-entry is **Settings → 使用帮助 / 启用指南** (exact title may be tuned in implementation; destination is the same Help surface).

When a recovery condition later becomes true, **show the Help tab again** until the condition clears. Settings entry remains available at all times.

### 5. “重新走一遍” = re-read, not reset progress

1. Users may re-open Help and expand / re-read every activation step’s instructions after completion (**重新走一遍** as instructional replay).
2. Default replay **must not** clear checklist affirmations, observation flags, or `rime_deployed` / deployment truth.
3. **Out of scope for this Decision:** a “重置启用进度” control that clears user affirmations. If product later wants that, it requires a separate Decision (confirmation UX, what may be cleared, and test plan).

### 6. TipKit as optional packaging (main App, iOS 17+)

1. TipKit is an authorized presentation layer for the **same** activation steps and copy boundaries. It is not a second product contract.
2. Minimum platform for TipKit use is **iOS 17+**. This repository’s main-App deployment target is already well above that floor; no dual path for pre-17 TipKit is required for this task.
3. Rules (unchanged intent from `ONBOARDING_ACTIVATION.md`, now binding for implementation):
   - One tip teaches one action.
   - Invalidate when the corresponding checklist state completes (not only display-count expiry).
   - Do not put the full legal privacy policy inside a tip.
   - Activation remains main-App-owned; first-run must not depend on Keyboard Extension TipKit.
4. **Recommended implementation order:** soft Welcome + Help IA first; TipKit contextual tips as a later phase within the same Assignment, still bound by this Decision.

### 7. Extension tips: non-goal

1. No TipKit (or equivalent tip UI) inside the Keyboard Extension under this Decision.
2. No Extension deployment, no new network/account service, no claim that iOS can enable the keyboard programmatically.

## Phased product acceptance (summary)

| Phase | User-visible outcome |
|---|---|
| P1 | Soft Welcome on first open; tab label **帮助**; checklist still re-entrant |
| P2 | After healthy full activation, Help tab hidden; Settings permanent entry; recovery re-shows Help tab; re-read steps without clearing progress |
| P3 | Optional TipKit contextual tips for activation steps with checklist-bound invalidation |

Detailed Exit Criteria live on the Assignment.

## Non-goals

- Changing Full Access optionality or “basic typing without FA” truth
- General feature Tips Library (fuzzy pinyin, sync, dictionary tutorials, etc.)
- Keyboard Extension tips or Extension first-run dependency
- Resetting activation affirmations by default
- App Store submission, screenshots packaging, or public URL publication
- Closing TD-004 (matrix fidelity / Extension-visible recovery remains separate debt unless explicitly in-scoped later)

## Relationship To Prior Decisions

| Source | Relationship |
|---|---|
| `PD-RELEASE-2026-0801-03` | Remains authority for activation success, FA claims, privacy short-form, V1 checklist semantics. This Decision **amends presentation only** (soft first-run, Help tab/Settings IA, TipKit phase, re-read policy). |
| `ONBOARDING_ACTIVATION.md` | Remains journey / copy / matrix Source of Truth; must be updated to describe Help IA and soft Welcome as the authorized presentation, without rewriting activation truth. |
| Task 03 Closed state | Historical implementation remains valid; this Decision authorizes the next presentation iteration. |

## Change Policy

Material changes to first-run intensity (soft → hard block), Help tab visibility rules, re-read vs reset-progress policy, TipKit ownership, or Extension tip allowance require Product Lead amendment of this Decision and revalidation of `HELP-TIPKIT-001`.
