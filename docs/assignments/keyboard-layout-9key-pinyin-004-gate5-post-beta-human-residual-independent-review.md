# KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 — Post-β Human Residual Independent Review

**Date:** 2026-07-23 Asia/Shanghai  
**Review roles (KOS 2.0):**  
- 🏛️ Architecture & Knowledge Steward  
- 🧪 Quality, Performance & Release Maintainer  

**Reviewed package:** post-β residual hotfixes after Human H5-A/B/C Pass  
**Handoff:** [`keyboard-layout-9key-pinyin-004-gate5-post-beta-human-residual-review-handoff.md`](keyboard-layout-9key-pinyin-004-gate5-post-beta-human-residual-review-handoff.md)  
**Evidence freeze:** remediation [`§27`](keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md)  
**Independent re-run log:** [`evidence/…/post-beta/logs/post-beta-independent-review-rerun.log`](../../evidence/keyboard-layout-9key-pinyin-004-gate5-post-beta/logs/post-beta-independent-review-rerun.log)  

### Independence statement

| Requirement | Disposition |
|---|---|
| Separate review package from Executor freeze claims | **Met** — forced hash recompute, matrix re-run, forbidden-signal scan, written answers to handoff §6–7 |
| Same-conversation lineage as Executor | **Process finding (Low)** — Product Lead requested in-session role switch. Mitigations applied; **Product Lead may commission a third-party re-review** if strict multi-agent isolation is required. Chat remains non-evidence. |

---

## 1. Scope checked

| In scope | Out of scope (not expanded) |
|---|---|
| Core ledger SoT multi-digit append/delete | Full B invent-slot |
| Ghost JKL peel / host remaining projection | Catalog / ADR rewrite |
| short / confirmed remaining resync letter rules | UIKit redesign as residual claim |
| Directed matrix + Human H5 linkage | commit/push authorization |
| Non-claims integrity | Full 004 Product Gate Pass |

**Branch surface note:** `git diff --name-only` shows broader 004 WIP (UIKit Path bar, RimeBridge passthrough, etc.). This review grades **post-β residual behavior and Core ledger/display paths named in handoff**, not a full branch clean-room of every 004 file. UIKit/RimeBridge pre-residual work is assumed prior-phase reviewed unless residual defects require them.

---

## 2. Architecture Review

### 2.1 Answers to handoff §6

| # | Question | Finding |
|---|---|---|
| 1 | Core `segmentSourceDigits` SoT for unconfirmed multi-digit? | **Yes, Accept.** Append/Delete peel/advance identity when `sourceDigits.count > 1` (or confirmed non-empty). Aligns with ADR 0023 Path provenance + β identity model. Single-digit first key remains refresh-owned — coherent. |
| 2 | `shortUnconfirmedResyncRaw` invent slots? | **No invent-slot.** Chooses **letter raw** among catalog `completeSyllable` full-cover of existing ledger length (first catalog/comment order), else pure digits. **Does not** change `sourceDigits` length/identity. Note: handoff wording said “unique only”; **code uses first full-cover**, which is acceptable for RIME letter form ranking, not slot invention. Finding **A1** below. |
| 3 | Host remaining after Path select? | **Accept.** `t9DisplayPreservingUnresolvedSuffix` rejects non-encoding illegal tails (`qingweiuil` class); re-projects via RIME letters / comment segments / progressive catalog; **must not** bare-fail to confirmed-only when remaining digits exist. |
| 4 | Partial long-tail letterization forbidden? | **Yes.** `refinedConfirmedPlusRemainingRaw` only unique **full** cover; otherwise `confirmed' + remainingDigits`. No `wo'+partial` path for long tails. |
| 5 | Full B still fail-closed / unclaimed? | **Yes.** `afterPartialCommit` unchanged-raw → `nil`; no qing-slot invent; non-claims restated in freeze. |

### 2.2 Source-of-Truth assessment

**Architecture Accept with findings** on post-β residual:

1. **Digit ledger SoT** for progressive multi-digit Delete/append correctly fixes Human ghost-`5` and short `da` Path desync without using forbidden coverage signals.  
2. **Identity pure functions** (`appendingDigit` / `deletingLastDigit` / `afterPartialCommit`) remain free of 汉字数 / `sel_*` / caret / previewLen.  
3. **`highlightedIndex` appearances** in PartialCommit/T9Path are preedit preference only — **not** slot maps.  
4. **Dual path residual:** provisional-only mixed-raw C continue remains `XCTSkip` — correctly **not** sold as fixed full C.  
5. **Finding A1 (Low):** short resync “first full-cover” vs handoff “unique only” wording mismatch — recommend documentation alignment; **not** a Reject.  
6. **Finding A2 (Info):** commentSyllableHints still rank Path labels after identity install — ADR 0023-allowed ranking, not consumption authority.

### 2.3 Architecture disposition

| Decision | Value |
|---|---|
| Post-β residual implementation | **Architecture Accept with findings** |
| Full B / invent slots | **Still No** |
| Full 004 Human Product Gate Pass | **Not authorized by this review** |
| commit / push / PR | **Not authorized by this review** |
| Eligible for Product Lead next decision | **Yes** — residual Pass language / commit auth / residual debt backlog |

---

## 3. Quality Review

### 3.1 Forced checks

| Check | Result |
|---|---|
| Hash recompute vs §27.3 | **PASS** — all 7 paths match byte-for-byte |
| Independent directed re-run | **PASS** — **68 tests, 1 skip, 0 fail** |
| Re-run log archived | `evidence/keyboard-layout-9key-pinyin-004-gate5-post-beta/logs/post-beta-independent-review-rerun.log` |
| Forbidden slot-authority scan in identity | **PASS** — no sel/caret/previewLen/汉字数 in `T9CompositionIdentity` slot map |
| `highlightedIndex` | Preedit only; **not** treated as fail |
| Host digit safety asserts | **Present** on Gate5/Human/unconfirmed paths + `T9HostPreeditSafetyTests` |
| SKIP greenwash | **PASS** — provisional-only C still `XCTSkip` with residual reason |
| Human H5 | Owner-confirmed Pass (H5-A/B/C) recorded in freeze; this review does not re-run device |

### 3.2 Quality findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| Q1 | **Info** | Same-conversation role switch weakens independence optics. | Documented; Product Lead may re-request external review |
| Q2 | **Low** | Handoff “unique full-cover” wording ≠ short resync “first full-cover” | Align docs; code OK for residual |
| Q3 | **Info** | 1 SKIP provisional-only C | Residual debt; keep visible |
| Q4 | **Info** | Full KeyboardCore suite not required for residual scope | Accept for directed freeze |

### 3.3 Quality disposition

**Quality: Pass-with-findings on post-β residual evidence.**  
**Human Product Gate full Pass: not claimed.**

---

## 4. Combined gate decision

| Gate | Status |
|---|---|
| Post-β residual hotfixes | **Architecture Accept with findings + Quality Pass-with-findings** |
| Human H5 residual matrix | **Owner Pass accepted as Product evidence** (device) |
| Full B | **Open / fail-closed** |
| Full 004 Human Product Gate | **Not closed** |
| commit/push/PR | **Product Lead only** |

### Recommended Product Lead options (not decisions)

1. **Authorize commit** of 004 Gate5 β + residual on current branch (clean commits).  
2. Publish **narrow residual Pass** language for H5 (not rewriting original frozen A/B/C history).  
3. Park residual debt: provisional-only C SKIP; full B research.  
4. Optional: third-party re-review if independence optics required.

---

## 5. Non-claims enforced

- Not 004 full Human Product Gate Pass  
- Not engine-native full B coverage  
- Not α history rewrite  
- Not commit authorization  

---

## 6. Return

→ Product Lead.  
Executor must not self-close Assignment to `Closed` solely on this review.
