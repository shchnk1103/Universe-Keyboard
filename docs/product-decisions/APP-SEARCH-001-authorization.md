# Product Decision: APP-SEARCH-001 — 主 App 搜索 Tab 与 J4 试用

**Decision ID:** `PD-APP-SEARCH-001`  
**Lifecycle status:** `Recorded`  
**Date / timezone:** `2026-07-25 Asia/Shanghai`  
**Assignment:** [`APP-SEARCH-001`](../assignments/app-search-001.md)  
**Related:** [`PD-HELP-TIPKIT-001`](HELP-TIPKIT-001-authorization.md), [`PD-HELP-GUIDE-SHEET-001`](HELP-GUIDE-SHEET-001-authorization.md), [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)

## Authority

- **Product Approver:** Human Product Owner via Grok session (`2026-07-25 Asia/Shanghai`): Search tab always on far right; J4 allows any content. Tab-count assumption (4 tabs when Help visible) **superseded** `2026-09-14` by [`PD-HELP-GUIDE-SHEET-001`](HELP-GUIDE-SHEET-001-authorization.md) (no Help tab).
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 📱 App & Data Operations Maintainer.

## Bound Product Decisions

1. **Always-on Search tab** at the **far right** of the main-App `TabView`.
2. **Tab order (amended 2026-09-14):** always 首页 | 设置 | **搜索**. There is no Help / 引导 tab. Do not vary tab count by activation state.
3. Search tab owns:
   - A real `TextField` (users may switch to Universe Keyboard to try input).
   - Local **settings destination search** (title + aliases → navigate into Settings destinations).
4. **J4 first input (amended 2026-09-14):** primary path is a trial field **inside the activation sheet**. Example input may guide freely; **any content** is allowed. Completion remains **user affirmation** (not automatic scheme-name matching, not live Extension proof). Search tab remains available for settings search and optional extra trial; it is **not** the J4 primary CTA and the sheet must not depend on switching tabs to complete J4.
5. Empty search results must not imply keyboard failure; tone allows trial typing without a settings hit.
6. Non-goals: Extension tips; auto-detect which keyboard produced text; full-text privacy policy search.

## Change Policy

Changing tab permanence, J4 success definition, or Search ownership requires Product Lead amendment.

## 2026-09-14 Amendment — No Help tab; J4 in-sheet

Human Product Owner via [`PD-HELP-GUIDE-SHEET-001`](HELP-GUIDE-SHEET-001-authorization.md):

1. Drop the 4-tab “Help visible” layout.
2. Move J4’s primary trial field into the activation sheet.
3. Keep Search tab always on, far right, for settings search.

J4 **success** is still user affirmation. This amendment changes **carrier** only. Implementation waits on `HELP-GUIDE-SHEET-001` implementation Authorization.
