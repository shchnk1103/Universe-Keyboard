# KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 Phase 1 β-limited — Independent Architecture + Quality Review

**Date:** 2026-07-23 Asia/Shanghai  
**Review roles (KOS 2.0):**  
- 🏛️ Architecture & Knowledge Steward  
- 🧪 Quality, Performance & Release Maintainer  

**Reviewed work:** Phase 1 β-limited identity implementation（Executor: Grok 4.5）  
**Authority:** [`PD-…-GATE5-PHASE1-BETA`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md)  
**Evidence:** remediation §19  
**Independent re-run log:** `evidence/keyboard-layout-9key-pinyin-004-gate5-phase1-beta/logs/phase1-beta-independent-review-rerun.log`  

### Independence statement

角色切换复审；强制 hash 重算、定向矩阵复跑、禁止信号扫描、与 PD 范围对照。聊天不是证据。

---

## 1. Scope

| In scope | Out of scope |
|---|---|
| β-limited: C selected-segment、shortened remainder、unchanged-raw fail-closed | Full B device unchanged-raw 完整 Human 契约 |
| `T9CompositionIdentity` + Partial/T9/TextEditing/PartialCommitState | UIKit / RimeBridge 语义 / catalog / 26-key |
| 定向自动化证据 | Human Product Gate Pass |
| 是否可进入 Human **分项**复测 | commit / push / PR |

---

## 2. Architecture Review

### 2.1 PD scope compliance

| PD requirement | Finding |
|---|---|
| Shortened remainder unique-suffix align | **Met** — `afterPartialCommit` pure/mixed paths |
| Unchanged-raw fail-closed | **Met** — encode==full source → `nil`；测试钉死不猜 `dropFirst(4)` |
| C selected-segment append/delete | **Met** — identity delete + `resyncRimeCompositionFromT9Identity` |
| No 汉字数/comment/sel/caret as slot authority | **Met for slot map** — identity inputs are sourceDigits + remaining raw encoding only |
| No full B claim | **Met** — device unchanged test rewritten fail-closed |
| No catalog/UIKit/26-key | **Met** |

### 2.2 Source-of-Truth assessment

**Accept with findings:**

1. **`T9CompositionIdentity` is a correct pure core for β-limited events** (append digit, delete last digit, partial shortened remainder).  
2. **Not the sole Path identity algorithm for every partial path:** equal pure-digit unresolved tail (full-phrase A) intentionally returns `nil` so legacy remaining-raw Path refresh owns `wo…`. This is coherent and covered by A green tests.  
3. **`commentSyllableHints` after identity install** only reorder catalog ranking (ADR 0023 allowed); they do **not** authorize source slot cuts.  
4. **Mixed shortened remainder** (e.g. `wei'fan'dao'9698454`) correctly realigns Path without forbidden signals — this is engine-shortened, not device unchanged-raw.  
5. **Resync after confirmed Delete** is appropriate Core-owned composition repair against fan-fan morphology.  
6. **Residual:** provisional-only mixed-raw C continue remains out of β-limited SoT (SKIP). Accept as residual debt, not a Pass-as-full-C claim.

### 2.3 Architecture disposition

| Decision | Value |
|---|---|
| β-limited implementation | **Architecture Accept with findings** |
| Full B / invent qing on unchanged raw | **Still No** |
| Enter Human **分项** retest (A/B/C honest) | **Yes, after Quality Pass** — Product Lead 请求；B 预期可能仍 Fail |
| Human Product Gate full Pass | **Not authorized** |
| commit/push/PR | **Not authorized by this review** |

---

## 3. Quality Review

### 3.1 Evidence matrix

| Item | Result |
|---|---|
| Independent directed re-run | **145 tests, 1 skipped, 0 failures** |
| Hash §19 vs disk | **Mismatch on `T9CompositionIdentity.swift` only** — Executor wrote §19 then fixed equal-tail (`a90021bf…` → `23bc439f…`). **Other 6 files match §19.** |
| Forbidden slot-guess scan | **No** selectionStart/caret/previewLen usage in identity slot map |
| Digit host safety (T9Host + marked history asserts) | **Covered / green** |
| Fake coverage invented as engine authority | **No** |
| Full suite | Not required for β-limited scope |

### 3.2 Quality findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| Q1 | **Low** | Evidence §19 hash for `T9CompositionIdentity.swift` is stale after equal-tail fix. | **Fix inventory in §20**；不阻塞 Accept |
| Q2 | **Info** | 1 SKIP provisional-only C. | Residual; documented |
| Q3 | **Info** | Identity + legacy refresh dual path for A equal-tail. | Architecture Accept；自动化覆盖 |
| Q4 | **Info** | Full non-Gate5 suite not re-run. | Accept for β-limited |

### 3.3 Quality disposition

**Quality: Pass-with-findings on β-limited evidence; Human Gate not claimed.**

---

## 4. Combined Gate decision

| Gate | Status |
|---|---|
| Phase 1 β-limited implementation | **Architecture Accept + Quality Pass-with-findings** |
| Full B Human contract | **Still open / not delivered** |
| Human 分项 retest | **Eligible to request** (Product Lead → Human) |
| Full Human Product Gate Pass | **No** |
| commit / push / PR | **No**（需 Product Lead 另批） |

**Stakeholder line:**

> β-limited review: Architecture **Accept** + Quality **Pass-with-findings**; automation green; full B / Human Gate **not** claimed; Product Lead may request Human **A/B/C** retest (B honest).

---

## 5. Recommendations to Product Lead

1. **Request Human** iPhone 13 Pro · 备忘录 · 分项 **A / B / C**（及可选 1–8）。  
2. Expect: **A/C likely improved**; **B device unchanged-raw may still Fail** — do not reclassify as Pass without evidence.  
3. After Human results: decide residual B (new research / narrow B / live with β-limited).  
4. **Optional:** authorize commit of β-limited only after Human or explicitly as “automation checkpoint” without Human Pass claim.  

---

## 6. Explicit non-claims

- 不宣布 Human Product Gate 通过  
- 不宣布完整 B 契约交付  
- 不授权 commit/push/PR  
- 不把 SKIP 的 provisional C 算作 C 全覆盖  
