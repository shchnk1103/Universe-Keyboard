# Product Decision: APP-SEARCH-001 — 主 App 搜索 Tab 与 J4 试用

**Decision ID:** `PD-APP-SEARCH-001`  
**Lifecycle status:** `Recorded`  
**Date / timezone:** `2026-07-25 Asia/Shanghai`  
**Assignment:** [`APP-SEARCH-001`](../assignments/app-search-001.md)  
**Related:** [`PD-HELP-TIPKIT-001`](HELP-TIPKIT-001-authorization.md), [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)

## Authority

- **Product Approver:** Human Product Owner via Grok session (`2026-07-25 Asia/Shanghai`): Search tab always on far right; accept 4 tabs when Help visible; J4 allows any content; write PD/Assignment then implement.
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 📱 App & Data Operations Maintainer.

## Bound Product Decisions

1. **Always-on Search tab** at the **far right** of the main-App `TabView`.
2. Tab order examples:
   - Help visible: 首页 | 帮助 | 设置 | **搜索**
   - Help hidden: 首页 | 设置 | **搜索**
3. Search tab owns:
   - A real `TextField` (users may switch to Universe Keyboard to try input).
   - Local **settings destination search** (title + aliases → navigate into Settings destinations).
4. **J4 first input:** primary CTA switches to Search and focuses the field. Example input may guide freely; **any content** is allowed. Completion remains **user affirmation** (not automatic scheme-name matching, not live Extension proof).
5. Empty search results must not imply keyboard failure; tone allows trial typing without a settings hit.
6. Non-goals: Extension tips; auto-detect which keyboard produced text; full-text privacy policy search.

## Change Policy

Changing tab permanence, J4 success definition, or Search ownership requires Product Lead amendment.
