# Assignment: APP-SEARCH-001 — 搜索 Tab 与 J4 试用跳转

**Policy version:** `1.0.0`  
**Task ID:** `APP-SEARCH-001`  
**Decision source / date:** [`PD-APP-SEARCH-001`](../product-decisions/APP-SEARCH-001-authorization.md), `2026-07-25 Asia/Shanghai`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` |
| **Phase** | 搜索 Tab + J4 试用跳转已交付；等待 Quality 与 Human Product Gate |
| **Non-claims** | 不宣称 Quality、真机 smoke 或 Product Gate 已过 |
| **Next** | Quality Reviewer → Human Product Lead |
| **Residuals** | 可选真机：在搜索页切到 Universe Keyboard |

---

## Authority

- **Assignment Authority:** Product Lead  
- **Product Approver:** Human Product Owner  
- **Domain Owner:** 📱 App & Data Operations Maintainer  
- **Executor:** Grok (Main App UI)  
- **Environment Executor:** Grok Simulator/build  
- **Human Dependency:** Optional device smoke (switch to Universe Keyboard in Search)  
- **Architecture Reviewer:** Not Applicable (main-App UI only)  
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer  
- **Handoff Target:** Quality → Product Lead  

## Acknowledgement

- **Executor acknowledgement:** `2026-07-25 Asia/Shanghai` on implement instruction.  
- **Lifecycle:** `Ready → Active` same day; Product Lead authorized `Active → Completed` `2026-08-14 Asia/Shanghai` after Executor delivery.

## Scope

1. PD + this Assignment; update `ONBOARDING_ACTIVATION` J4 (any content + Search field).  
2. Always-on **搜索** Tab (far right); 4 tabs OK when Help shown.  
3. Search UI: focused trial field + settings index results.  
4. J4 CTA: jump to Search + focus field; affirm remains on Help.  
5. Build evidence.

## Non-goals

- Auto-complete J4 from keystrokes  
- Extension TipKit  
- Replacing Settings IA  

## Exit Criteria

- Search always last tab  
- J4 opens Search with keyboard-capable field  
- Settings hits navigate; misses allow trial-friendly empty state  
- Copy allows any content for trial  

## Completion Record

### Implementation (`2026-07-25 Asia/Shanghai`)

- Search tab always last: 首页 | 帮助? | 设置 | **搜索**
- `SearchTab` + `SettingsSearchCatalog`; J4 CTA focuses Search field; any content allowed
- Evidence: `ActivationChecklistStateTests` **18/18 PASS** (iPhone 17 Pro Sim / iOS 26.5)
