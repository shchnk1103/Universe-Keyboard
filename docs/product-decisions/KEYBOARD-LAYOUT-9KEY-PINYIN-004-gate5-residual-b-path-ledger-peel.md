# Product Decision: KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 — Residual-B Path-Ledger Cursor

**Decision ID:** `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-004-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`  
**Lifecycle status:** `Recorded`  
**Date / timezone:** `2026-07-23 Asia/Shanghai`  
**Parent:** [`PD-…-004`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md)  
**Prior:** [`PD-…-GATE5-POST-BETA-RESIDUAL`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-post-beta-residual-disposition.md) · [`PD-…-GATE5-PHASE1-BETA`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md)  
**Assignment:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-004`](../assignments/keyboard-layout-9key-pinyin-004.md)  
**Evidence:** remediation [`§28–§29`](../assignments/keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md)

## Authority

- **Product Approver:** Product Lead under Human Product Owner standing KOS 2.0 authorization for this track (session: residual-B device fail → process debt; later Product confirmed Path-ledger **cursor** model including multi-CJK).  
- **Does not replace:** full 004 Human Product Gate; Human residual-B retest required before Pass claim.  
- **Landing:** local commit / feature branch allowed; **open/merge PR only after Human device retest OK** (session constraint).

## Bound product model (SoT)

After the user Path-selects a prefix stack (e.g. `qing → wei → fan → dao`) and then confirms a RIME candidate of length **K** CJK characters:

1. **K (step count only)**  
   `K = min(CJK ideograph count of candidate, remaining user Path stack length)`.  
   CJK count does **not** equal digit length.

2. **Slots follow syllables**  
   Consume the first **K** user Path syllables; digit peel length = sum of those syllables’ letter widths on the digit ledger.

3. **Path cursor**  
   - If remaining user stack non-empty (e.g. after「请」→ `[wei,fan,dao]`): Path Bar shows options for the **first** remaining syllable slot (`wei/zei/ye…`) and **soft-selects** that syllable because the user already Path-selected it.  
   - Same for「请喂」→ focus `fan` soft-selected;「请喂饭」→ `dao` soft-selected.  
   - If stack exhausted (e.g.「请喂饭到」): Path Bar shows unselected tail (`wo…`); **no** forged soft-select.

4. **Soft-select iron rule**  
   Path Bar selected state only from: (1) 选拼音, or (2) user Path Bar tap. Soft-select after partial **restores** a prior user choice — never invents selection for unselected tails.

5. **Regret target**  
   Soft-select is for changing the **current Path focus syllable**, not rewriting already partial-committed Chinese (use Delete restore for that).

## Implementation notes

- Prefer Path-ledger cursor whenever user stack non-empty and `K > 0`, over engine shortened-remainder realign alone.  
- Resync RIME to remaining identity (`replacementRawInput`) without wiping soft-select.  
- Host remaining preedit: no internal T9 digits.  
- Without user Path stack: prior fail-closed / unique-suffix β rules unchanged.

## Explicit non-claims

- Not full 004 Human Product Gate Pass until residual-B device retest  
- Not multi-syllable invent without user Path stack  
- Not auto-select on unselected remainder  

## Human residual-B retest (required)

| Step | Expect |
|---|---|
| 整串 + Path `qing/wei/fan/dao` → 选「请」 | 上屏「请」; Path=`wei…` 且 **wei 选中**; 无数字泄漏 |
| 同上 → 选「请喂」 | Path=`fan…` 且 **fan 选中** |
| 同上 → 选「请喂饭到」 | Path=`wo…` **无选中** |
| 第一次 Delete | 按 Partial checkpoint 恢复 |
