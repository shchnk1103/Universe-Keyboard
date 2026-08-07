# Product Decision: RIME-SCHEME-WANXIANG-001 — Support 万象拼音 as a downloadable RIME scheme

**Decision ID:** `PD-RIME-SCHEME-WANXIANG-001`  
**Lifecycle status:** `Proposed — Product direction recorded; implementation not yet Ready`  
**Date / timezone:** `2026-08-07 Asia/Shanghai`  
**Parent domain:** RIME multi-scheme management ([`RIME_SCHEME_MANAGEMENT.md`](../RIME_SCHEME_MANAGEMENT.md))  
**Related:** ADR 0001 (main App deploy only); catalog/install model for `rime_ice`; T9 remains fog-song / ADR 0018  
**Assignment:** [`rime-scheme-wanxiang-001.md`](../assignments/rime-scheme-wanxiang-001.md)  
**Replaces investment focus:** [`PD-T9-SINGLE-KEY-MIXED-CANDIDATES-001`](T9-SINGLE-KEY-MIXED-CANDIDATES-001-authorization.md) (`Closed — Won’t do`)

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Proposed` |
| **Phase** | Direction: expand downloadable schemes; first new target = 万象拼音 |
| **Non-claims** | Not App Store marketing; not T9 first-key redesign; not dual-gate work |
| **Next** | Scope freeze (which upstream package / schema IDs / Lua / size); then Assignment Ready |
| **Residuals** | None until Gate |

---

## Authority

- **Product Approver:** Human Product Lead  
- **Decision source:** In-session 2026-08-07 — decline mixed-candidate goal; prefer supporting more schemes; **next: 万象拼音**

## Product problem

Users want richer choice of open-source RIME bases beyond `luna_pinyin` (built-in) and `rime_ice` (downloadable). Investing in Apple-like t9 first-key union is low leverage versus **catalog + install + switch** for popular schemes such as **万象拼音** ([amzxyz/rime-wanxiang](https://github.com/amzxyz/rime-wanxiang) and ecosystem).

Scheme management V1 already has a list-and-detail + catalog infrastructure; V1.1 text still says fog-song is the only downloadable open-source scheme — this PD authorizes **planning** the next catalog entry.

## Bound Product Direction (not full implementation Gate)

1. **Product direction:** Expand multi-scheme support using the existing main-App catalog / deploy / Extension-session-only boundary.  
2. **First new scheme target:** **万象拼音** (upstream identity and exact release asset **to be frozen** before Ready).  
3. **26-key / nine-key / English:** Keep ADR 0018 model — user-visible **base scheme** + layout-derived **effective** scheme for T9 when base is fog-song and ready; English remains non-Chinese path. **万象 is a base scheme candidate**, not a replacement for `t9` unless a later PD says otherwise.  
4. **Do not** treat 万象 as requiring T9 first-key mixed-candidate work.

### Explicit non-goals (until later PDs)

- Shipping every 万象 sub-variant (全拼/双拼/辅助码矩阵) in V1 of this work  
- Network download inside Keyboard Extension  
- Claiming 万象 grammar-model quality or “大厂级” marketing  
- Automatic migration of user dictionaries across unrelated schemas  

### Open questions before Ready (Product + Architecture)

| # | Question |
|---|---|
| Q1 | Exact upstream: full `rime-wanxiang` release vs slim fork; license and redistributable asset |
| Q2 | Primary schema ID(s) to surface as one user-facing “万象拼音” row |
| Q3 | Lua / OpenCC / grammar model binary size and Extension memory budget |
| Q4 | Advanced-input (date/calc/…) capability matrix vs fog-song |
| Q5 | Whether nine-key stays fog-song-only or ever maps 万象+layout (default: **fog-song-only T9** until PD) |

## Implementation follow-through

| Action | Authorized now? |
|---|---|
| Record direction + Assignment Pending | **Yes** |
| Spike: catalog entry, download size, install plan, selectSchema smoke | **Yes** after Executor named and Entry met |
| Production catalog + UI + deploy | **Only** when Assignment reaches Ready with Q1–Q5 frozen enough to exit UNKNOWN |
| Architecture review of deploy/Lua/size | **Required** before production install path |

## History

- 2026-08-07: Proposed after Product declined T9 single-key mixed candidates.
