# KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 — Phase 1 β-limited Executor Handoff

**Date:** 2026-07-23 Asia/Shanghai  
**From:** Product Lead  
**To:** Executor（Grok 4.5）  
**Authority:** [`PD-…-GATE5-PHASE1-BETA`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md)  

## Product intent (read carefully)

1. **Fix what we can prove:** C identity；shortened-remainder Path rebase。  
2. **Do not fake B:** unchanged-raw **fail-closed only** — 禁止猜 `qing` 槽。  
3. **Do not claim** Human Gate Pass 或 B 契约满足。  
4. Path α 已关闭；不得把 sel/caret/preview 当 coverage。

## Deliver

- `T9CompositionIdentity`（或等价内部 reducer）  
- C 红测转绿；shortened remainder 契约；unchanged-raw fail-closed 契约  
- 定向矩阵 + evidence  
- Stop → 独立 Architecture + Quality  

## Must not

- 汉字数 / comment / preedit / 排名 / sel_* / caret / previewLen → 槽位  
- 改 catalog / 26 键 / UIKit / RimeBridge 生产语义  
- commit / push / PR  
- 代填 Human 矩阵  

## Human later

仅在独立复审通过后，由 Product Lead 请真人 iPhone 13 Pro 分项复测 A/B/C（B 诚实填）。

---

## Executor completion (`2026-07-23`)

| Item | Result |
|---|---|
| `T9CompositionIdentity` | Added |
| Shortened remainder | Green |
| Unchanged-raw fail-closed | Green |
| C selected-segment | Green |
| Directed tests | **145 pass, 1 skip, 0 fail** |
| Evidence | remediation §19 |
| Next | Independent Architecture + Quality |  
