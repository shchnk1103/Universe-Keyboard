# Product Decision: KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 — Residual-B Path-Ledger Peel

**Decision ID:** `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-004-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`  
**Lifecycle status:** `Recorded`  
**Date / timezone:** `2026-07-23 Asia/Shanghai`  
**Parent:** [`PD-…-004`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md)  
**Prior:** [`PD-…-GATE5-POST-BETA-RESIDUAL`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-post-beta-residual-disposition.md) · [`PD-…-GATE5-PHASE1-BETA`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md)  
**Assignment:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-004`](../assignments/keyboard-layout-9key-pinyin-004.md)  
**Evidence:** remediation [`§28`](../assignments/keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md)

## Authority

- **Product Approver / Decision maker:** Product Lead acting under Human Product Owner’s standing KOS 2.0 authorization for this Assignment track (in-session instruction: residual-B still fails on device — process remaining debt under KOS 2.0).  
- **Does not replace:** Human Product Owner may override; full frozen Human Product Gate for entire 004 exit criteria remains a separate act.

## Problem (bound)

Device residual-B: after Path-select `qing/wei/fan/dao` and single-character partial「请」, RIME often leaves raw **unchanged**. Prior β-limited rule was **engine-only fail-closed**, which emptied Path and broke the Human contract “consume 请, keep wei/fan/dao, focus wo”.

Phase 0.5 already proved librime `sel_*` is **not** a reliable per-candidate coverage signal. Inventing slots from 汉字数 / comment / caret / rank remains **forbidden**.

## Bound Product Decision

### 1. Path ledger is sufficient authority for **narrow** residual-B

When **all** of the following hold, Core **may** peel leading Path-confirmed syllables:

1. T9 input semantics active;  
2. Pre-selection Path has **non-empty** `confirmedSegmentValues` established by user Path select (not provisional-only);  
3. Live RIME raw still encodes the **full** pre-selection `sourceDigits` (unchanged-raw class);  
4. Committed candidate is a **single CJK** character (one extended grapheme in CJK Unified Ideographs / Ext-A);  
5. Each peeled syllable validates against its digit slice via the complete-syllable catalog (or single-letter syllable);  
6. Peel leaves a **non-empty** remaining digit source.

**Peel count for device B:** **1** (first Path-confirmed syllable, e.g. `qing`).

**Not authorized:** multi-character candidates on unchanged-raw; peel without Path confirmed; peel from 汉字数 / comment / `sel_*` / caret / rank / preedit length.

### 2. Post-peel behavior

1. Install remaining identity (`wei/fan/dao` + remaining digits).  
2. Resync RIME from Core identity so host / candidates match Path focus (`wo…`).  
3. Refresh PartialCommit remaining display without host digit leakage.

### 3. What remains fail-closed

| Case | Stance |
|---|---|
| Unchanged-raw **without** Path-confirmed syllables | Fail-closed (no invent) |
| Unchanged-raw + multi-char candidate | Fail-closed (no multi-syllable guess) |
| Engine shortened remainder | Existing `afterPartialCommit` unique-suffix path (unchanged) |
| Provisional-only mixed-raw C continue (`XCTSkip`) | Still parked residual |

### 4. Landing authorization

| Action | Authorized? |
|---|---|
| Implement residual-B Path-ledger peel in KeyboardCore | **Yes** |
| Targeted + full KeyboardCore tests | **Yes** |
| Local commit + feature branch push + open PR | **Yes** (merge remains Human Product Owner) |
| Claim full 004 Human Product Gate Pass solely from automation | **No** — needs device retest of residual-B |
| Close Assignment without Human residual-B retest | **No** |

## Explicit non-claims

- Not engine-native per-candidate coverage discovery  
- Not full 004 Product Gate Pass until Human retests residual-B  
- Not authorization to invent multi-syllable consumption on multi-char candidates  

## Human Product Owner — residual-B retest

| Step | Expect |
|---|---|
| 九键输入完整串 → Path 选 `qing/wei/fan/dao` | Path 确认四段；焦点 `wo…` |
| 选单字候选「请」 | 上屏「请」；Path 保留 `wei/fan/dao`；焦点 `wo…`；**Path 不得清空** |
| host marked | 前缀「请」+ 剩余拼音字母；**无内部数字** |
| 第一次 Delete | 按现有 Partial checkpoint 语义恢复（不得破坏 26 键） |
