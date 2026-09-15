# Product Decision: HELP-GUIDE-SHEET-001 — 引导 sheet 与设置「？」入口

**Decision ID:** `PD-HELP-GUIDE-SHEET-001`
**Lifecycle status:** `Recorded`
**Date / timezone:** `2026-09-14 Asia/Shanghai`
**Assignment:** [`HELP-GUIDE-SHEET-001`](../assignments/help-guide-sheet-001.md)
**Authorization (this slice):** [`AUTH-HELP-GUIDE-SHEET-001`](../authorizations/AUTH-HELP-GUIDE-SHEET-001.md)
**Amends:** [`PD-HELP-TIPKIT-001`](HELP-TIPKIT-001-authorization.md), [`PD-APP-SEARCH-001`](APP-SEARCH-001-authorization.md)
**Does not amend semantics of:** [`PD-RELEASE-2026-0801-03`](RELEASE-2026-0801-03-activation-authorization.md)

## Authority

- **Product Approver / Decision maker:** Human Product Owner, acting as Product Lead in the current Grok session (`2026-09-14 Asia/Shanghai`), locking F1–F3 and instructing to continue under KOS (record Decision and Assignment; no Swift).
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 📱 App & Data Operations Maintainer (main-App onboarding presentation).
- **Architecture / Quality:** Architecture review only if App Group, Full Access observation, privacy claims or activation success criteria change beyond existing ADR 0007/0008 and `PD-RELEASE-2026-0801-03`. Quality, Performance & Release Maintainer for independent evidence after an implementation slice is authorized.

This Decision authorizes **presentation packaging** for the existing activation journey. It does **not** replace activation success criteria, Full Access optionality, J2 deferral order, capability matrix or canonical copy C1–C9.

## Product Problem

`PD-HELP-TIPKIT-001` shipped a condition-dependent **帮助** tab plus a skippable Welcome sheet. Tab show/hide, 3-versus-4 tab order and Search-as-J4 carrier add hidden state. Human Product Owner wants one persistent Settings toolbar entry, one bottom sheet, and honest resume after process death — without turning first-run into a hard lock on Home.

## Bound Product Decisions (F1–F3)

Human Product Owner locked:

1. **F1 Recovery / incomplete marker + auto-present.** While recommended activation is incomplete (`nextStep != nil`) or a recovery condition holds (`sharedDataUnavailable` or actionable J3 resource recovery under existing J3 authority): the Settings toolbar **？** uses a non-color-only incomplete marker (visual may be red; VoiceOver must expose an incomplete/recovery value), **and** the next **main-App process launch** auto-presents the guide sheet. Same-process `scenePhase` returns after 「稍后再说」 must **not** auto-present again.
2. **F2 「稍后再说」.** Dismisses only the current sheet session. It does not mark any checklist step complete, does not equal activation success, and does not suppress later entry. After dismiss, the user may re-open via **？**, **or** the next process launch auto-presents per F1.
3. **F3 Single entry.** Remove the Settings list row 「使用帮助与启用指南」. The only permanent entry is the Settings navigation-bar **？**. Accessibility name remains along the lines of 「使用帮助与启用指南」.

Detailed presentation rules live in the `2026-09-14` amendment of [`PD-HELP-TIPKIT-001`](HELP-TIPKIT-001-authorization.md). J4 trial-field carrier rules live in the matching amendment of [`PD-APP-SEARCH-001`](APP-SEARCH-001-authorization.md).

## This slice vs implementation

This Decision **records** the product contract and authorizes creating Assignment `HELP-GUIDE-SHEET-001` in `Ready`. It does **not** authorize Swift/UI implementation, TipKit rebinding in code, commit, push, merge, TestFlight or Release. Implementation requires a later Human instruction and a matching Authorization whose action is implementation.

## Non-goals

- Changing J1→J2→J3→J4 order or J2 deferral semantics
- Adding layout / haptic / Lua / fuzzy / sync steps to first-run
- Hard-blocking Home with no 「稍后再说」
- Storing a step index as completion truth
- Keyboard Extension tips
- Closing TD-004
- Profile envelope onboarding / `.kos/project.json` include changes

## Related Records

- Presentation SoT (amended): [`PD-HELP-TIPKIT-001`](HELP-TIPKIT-001-authorization.md)
- Search / J4 carrier (amended): [`PD-APP-SEARCH-001`](APP-SEARCH-001-authorization.md)
- Journey / copy / matrix: [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)
- Assignment: [`HELP-GUIDE-SHEET-001`](../assignments/help-guide-sheet-001.md)
