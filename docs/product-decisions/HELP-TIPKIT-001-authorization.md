# Product Decision: HELP-TIPKIT-001 — 帮助入口、软首启与 TipKit 展示层

**Decision ID:** `PD-HELP-TIPKIT-001`
**Lifecycle status:** `Recorded`
**Date / timezone:** `2026-07-25 Asia/Shanghai`
**Assignment (original packaging):** [`HELP-TIPKIT-001`](../assignments/help-tipkit-001.md) (`Completed`)
**Assignment (sheet packaging):** [`HELP-GUIDE-SHEET-001`](../assignments/help-guide-sheet-001.md) (`Ready`; implementation not authorized)
**Predecessor / binding activation semantics:** [`PD-RELEASE-2026-0801-03`](RELEASE-2026-0801-03-activation-authorization.md), [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)
**Current presentation amendment:** [`PD-HELP-GUIDE-SHEET-001`](HELP-GUIDE-SHEET-001-authorization.md) (`2026-09-14 Asia/Shanghai`)

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

### 2. First-run intensity: soft (amended 2026-09-14)

The product remains **soft**: users can defer the current sheet and use Home / Settings / Search. It is **not** a hard lock.

1. On first main-App process launch, auto-present **one** multi-step bottom sheet. J0 (value + short privacy + primary CTA) is the first page of that sheet, not a separate Welcome that then switches tabs.
2. Incomplete-session sheet: disable accidental swipe-down. Provide explicit **「稍后再说」**. That action dismisses only the current process’s sheet, must not block Home, must not force a tab switch, and must not equal activation success or complete any checklist step.
3. Opening system Settings for J1/J2 must **keep** the sheet presented across backgrounding. Returning to the App shows the sheet on the **derived** `nextStep`.
4. Session persistence answers “should this process auto-present the sheet?” only. Checklist completion remains `ActivationChecklistState`. A stored step index, if any, is display memory (`focusedStep`) and **must not** override `nextStep`.
5. **Auto-present (F1):** while recommended activation is incomplete (`nextStep != nil`) **or** a recovery condition holds, the next **main-App process launch** auto-presents the sheet. Same-process foreground after 「稍后再说」 does not auto-present again.
6. After healthy full activation, do not auto-present. Re-read is user-initiated via **？**.

Historical `activation_welcome_seen` was Welcome-only. Implementation of `HELP-GUIDE-SHEET-001` may replace it with session-offer keys; it must not treat Welcome-seen or defer-this-process as activation success.

### 3. Information architecture (amended 2026-09-14)

1. **No activation tab.** Do not show **帮助** / **引导** in the main `TabView`. Tab order is always 首页 | 设置 | **搜索** (Search still far right; [`PD-APP-SEARCH-001`](APP-SEARCH-001-authorization.md)).
2. Guide content remains **activation-only**: J0–J5. It is not a general Tips Library.
3. **Single permanent entry (F3):** Settings navigation-bar **？** only. Accessibility label equivalent to 「使用帮助与启用指南」. **Remove** the Settings list row of the same name. Do not keep two entries.

### 4. Incomplete marker and recovery (replaces Help-tab visibility; F1)

`shouldShowHelpTab` is **no longer** a product contract.

While any of the following hold:

| Condition | Meaning |
|---|---|
| `ActivationChecklistState.nextStep != nil` | Recommended activation incomplete |
| `fullAccess == .sharedDataUnavailable` | Shared-data failure reopens recovery |
| Resources recovery needed | Actionable J3 recovery under existing J3 authority (do not invent a live Extension flag) |

the product must:

1. Mark **？** as incomplete/recovery. Visual may be red; **must not** be color-only (VoiceOver value such as 「启用未完成」 or 「需要恢复」).
2. Auto-present the guide sheet on the **next main-App process launch**.

When **none** of the above hold: default **？** appearance; no auto-present; user may still re-read.

「稍后再说」 (F2) does not clear the marker and does not suppress next-launch auto-present.

### 5. “重新走一遍” = re-read, not reset progress

1. Users re-open the sheet from **？** and re-read J0–J5 after completion.
2. Default replay **must not** clear checklist affirmations, observation flags, or `rime_deployed` / deployment truth.
3. Re-read sheets **may** be swipe-dismissed. Incomplete first-run / recovery sheets may not (explicit 「稍后再说」 only).
4. **Out of scope:** a “重置启用进度” control. That still needs a separate Decision.

### 6. TipKit as optional packaging (main App, iOS 17+)

1. TipKit is an authorized presentation layer for the **same** activation steps and copy boundaries. It is not a second product contract.
2. Minimum platform for TipKit use is **iOS 17+**. This repository’s main-App deployment target is already well above that floor; no dual path for pre-17 TipKit is required for this task.
3. Rules (unchanged intent from `ONBOARDING_ACTIVATION.md`, now binding for implementation):
   - One tip teaches one action.
   - Invalidate when the corresponding checklist state completes (not only display-count expiry).
   - Do not put the full legal privacy policy inside a tip.
   - Activation remains main-App-owned; first-run must not depend on Keyboard Extension TipKit.
4. **Recommended implementation order** (`HELP-GUIDE-SHEET-001`): sheet + Settings **？** + no Help tab first; TipKit surface rebind as a later phase in that Assignment, still bound by this Decision. Tips that previously targeted Help next-step bind to the sheet’s current step.

### 7. Extension tips: non-goal

1. No TipKit (or equivalent tip UI) inside the Keyboard Extension under this Decision.
2. No Extension deployment, no new network/account service, no claim that iOS can enable the keyboard programmatically.

## Phased product acceptance (summary)

Historical `HELP-TIPKIT-001` P1–P3 (Welcome + Help tab) remain the **shipped** UI until `HELP-GUIDE-SHEET-001` implementation is authorized and lands. Authorized **next** packaging:

| Phase | User-visible outcome |
|---|---|
| Record | F1–F3 and sheet IA recorded; no Swift |
| P1 (later Authorization) | Multi-step sheet (J0 first page); no Help tab; Settings **？** only |
| P2 | F1 marker + next-process auto-present; F2 「稍后再说」; recovery without a returning tab; re-read without clearing progress |
| P3 | Optional TipKit rebound to the sheet |

Detailed Exit Criteria live on [`HELP-GUIDE-SHEET-001`](../assignments/help-guide-sheet-001.md).

## Non-goals

- Changing Full Access optionality or “basic typing without FA” truth
- General feature Tips Library (fuzzy pinyin, sync, dictionary tutorials, etc.)
- Keyboard Extension tips or Extension first-run dependency
- Resetting activation affirmations by default
- App Store submission, screenshots packaging, or public URL publication
- Closing TD-004 (matrix fidelity / Extension-visible recovery remains separate debt unless explicitly in-scoped later)
- Adding non-activation first-run steps (layout, haptics, Lua/advanced input, fuzzy pinyin, sync)
- Hard-blocking Home with no 「稍后再说」

## Relationship To Prior Decisions

| Source | Relationship |
|---|---|
| `PD-RELEASE-2026-0801-03` | Remains authority for activation success, FA claims, privacy short-form, V1 checklist semantics. This Decision amends **presentation only**. |
| `PD-HELP-GUIDE-SHEET-001` | `2026-09-14` Human lock of F1–F3; current packaging amendment driver. |
| `PD-APP-SEARCH-001` | Owns Search tab permanence; J4 trial carrier amended there (in-sheet field). |
| `ONBOARDING_ACTIVATION.md` | Remains journey / copy / matrix Source of Truth; presentation sections must match this Decision without rewriting activation truth. |
| Task 03 / `HELP-TIPKIT-001` Closed | Historical Help-tab implementation remains the shipping UI until `HELP-GUIDE-SHEET-001` implementation lands. |

## Change Policy

Material changes to first-run intensity (soft ↔ hard block), sheet vs tab carrier, **？** entry, auto-present / 「稍后再说」 rules, incomplete marker, re-read vs reset-progress, TipKit ownership, or Extension tip allowance require Product Lead amendment of this Decision and a matching Assignment Authorization.

## 2026-09-14 Amendment — Guide sheet and Settings 「？」

Human Product Owner acting as Product Lead locked F1–F3 in the active Grok session and authorized recording via [`PD-HELP-GUIDE-SHEET-001`](HELP-GUIDE-SHEET-001-authorization.md):

1. Replace the conditional Help tab with a single Settings toolbar **？**.
2. Present J0–J5 in one bottom sheet; keep the sheet across system Settings round-trips.
3. Incomplete or recovery: **？** marker (red allowed, not color-only) **and** auto-present on next process launch.
4. 「稍后再说」 ends the current process sheet only; **？** and next launch remain available.
5. Remove the Settings list Help row.
6. Do not treat a stored step number as completion truth.

This amendment does not change Full Access optionality, J2 deferral order, C1–C9, or deployment ownership. Implementation is **not** authorized by the record slice.
