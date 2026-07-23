# KEYBOARD-LAYOUT-9KEY-PINYIN-004 — Human Product Gate Entry Status

**Date:** 2026-07-23 Asia/Shanghai  

## Current stakeholder line

> **Human #2: Delete-stuck Pass; C still Fail; Path vanishes at sole qing + wrong qin candidates / Hotfix #2 landed (re-focus last syllable + letter-refined resync) / Please retest Path-delete + C on newest Debug build**

## Human matrix (append-only)

| When | A | B | C | Delete stuck | Path@sole qing | qin candidates |
|---|---|---|---|---|---|---|
| Human #1 | Pass | Pass | Fail | Fail | — | — |
| Human #2 | — | — | **Fail** (`…eocoudao…`) | **Pass** | **Fail** (bar gone) | **Fail** (手/瘦) |
| Hotfix #2 | — | — | automation + please retest | Pass kept | fix landed | fix landed |

## Please retest (newest Debug)

1. `qingweifan` → Path **qing/wei/fan** → 连删到只剩 **qing**：Path bar **必须仍显示**  
2. 再删到 **qin**：Path 正确；候选勿成手/瘦主导  
3. 再删 **qi**：勿自动选中 Path  
4. **C**：`qingweifa` → JKL → Delete → 续输正确后续  

**No agent may fill or claim the Human matrix.**
