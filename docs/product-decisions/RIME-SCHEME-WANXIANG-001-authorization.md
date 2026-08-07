# Product Decision: RIME-SCHEME-WANXIANG-001 — Support 万象拼音 as a downloadable RIME scheme

**Decision ID:** `PD-RIME-SCHEME-WANXIANG-001`  
**Lifecycle status:** `Proposed — Product freezes recorded; implementation not Ready`  
**Date / timezone:** `2026-08-07 Asia/Shanghai`  
**Parent domain:** RIME multi-scheme management ([`RIME_SCHEME_MANAGEMENT.md`](../RIME_SCHEME_MANAGEMENT.md)); keyboard layout ([`KEYBOARD_LAYOUT.md`](../KEYBOARD_LAYOUT.md))  
**Related:** ADR 0001 (main App deploy only); catalog/install model for `rime_ice`; **ADR 0018 amend draft** [`ADR 0026`](../architecture/decisions/0026-layout-bound-rime-scheme-selection.md) (**Proposed**, not Accepted)  
**Assignment:** [`rime-scheme-wanxiang-001.md`](../assignments/rime-scheme-wanxiang-001.md)  
**Replaces investment focus:** [`PD-T9-SINGLE-KEY-MIXED-CANDIDATES-001`](T9-SINGLE-KEY-MIXED-CANDIDATES-001-authorization.md) (`Closed — Won’t do`)

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Proposed` |
| **Phase** | Product freezes in; **ADR 0026 draft** for layout×scheme; 万象 asset pin still open |
| **Non-claims** | Not App Store marketing; not dual-gate work; not mixed-candidate work; ADR 0026 not yet Accepted |
| **Next** | Architecture Accept of ADR 0026 (or revise); freeze 万象 upstream package/schema IDs; then Ready |
| **Residuals** | Q1 (exact release asset), Q2 (schema IDs), Q4 (advanced-input matrix) still open |

---

## Authority

- **Product Approver:** Human Product Lead  
- **Decision source:** In-session 2026-08-07 — decline mixed-candidate goal; prefer multi-scheme; next 万象拼音  
- **Freeze addendum:** In-session 2026-08-07 answers to open product questions (全拼优先、接受体积、布局页自选方案)

## Product problem

Users want richer choice of open-source RIME bases beyond `luna_pinyin` and `rime_ice`. Scheme catalog infrastructure exists; fog-song is still the only downloadable open-source scheme in V1.1.

Separately, **one global “当前方案” + 九键自动切 `t9`（ADR 0018）** no longer matches Product intent: users should pick **which scheme this layout uses** on the keyboard layout surface (e.g. nine-key may use fog-song `t9`, or another nine-key-capable scheme when available — not hard-locked to “only rime_ice implies t9”).

## Bound Product Direction

### 1. Multi-scheme expansion

Expand downloadable schemes via main-App catalog / deploy / Extension-session-only (ADR 0001).  
**First new scheme target:** **万象拼音**.

### 2. 万象 V1 product freezes (2026-08-07)

| Topic | Product freeze |
|---|---|
| Input style | **全拼为主** for first shippable slice; **双拼 / 辅助码变体 out of V1** (later work) |
| Package size | **Accept** packages larger than fog-song (grammar model / big dict OK in principle); Architecture still sets a **hard memory/install budget** and may require slim asset choice within that budget |
| Layout × scheme | **User-selectable scheme per keyboard layout** on the **keyboard layout settings page** — not “one global base scheme only.” When using **九宫格**, the user may **choose** the scheme used for that layout (among installed schemes that support that layout). When using **26 键**, likewise choose the 26-key scheme. **English** remains a separate input mode/path unless a later PD says otherwise. |

### 3. Layout-bound scheme selection (binding; amends ADR 0018 intent)

**Product requires:**

1. Settings **键盘布局** (or equivalent layout management UI) exposes, for each Chinese layout the product supports (at least **26 键** and **九宫格**):  
   - layout preference, and  
   - **scheme used when this layout is active** (picker over installed, layout-capable schemes).  
2. Runtime effective scheme = **layout’s selected scheme** (plus readiness/install checks), **not** solely “global base + automatic t9 rewrite.”  
3. Automatic fog-song → `t9` rewrite (current ADR 0018 table) is **no longer the sole product model**; it may remain a **default/migration** when the user has not set a per-layout scheme, until Architecture freezes migration.  
4. Schemes that **cannot** run on nine-key must be **unavailable or fail-closed** in the nine-key scheme picker (never silent wrong algebra).

**Architecture obligation:** ADR 0018 (and resolver/`RimeRuntimeSelection`) **must be amended or superseded** before production of layout-bound pickers. This PD **authorizes the product requirement**; it does **not** by itself ship the ADR text.

**Implication for 万象 + 九键:**  
Product **disagrees** with “万象 only on 26-key / nine-key forever fog-song-only.”  
Whether **万象 V1** itself exposes a nine-key-capable schema is a **capability fact** (upstream may only be 全拼 26-key). If 万象 V1 has **no** nine-key algebra, it appears only in the **26-key** picker; nine-key picker still offers fog-song `t9` (and later other nine-key schemes). Product still wants the **picker architecture**, not a hard product ban on 万象-on-nine-key forever.

### 4. Explicit non-goals (until later PDs)

- 万象 V1 双拼 / 全辅助码矩阵  
- Apple-like T9 first-key mixed candidates  
- Extension-side download  
- Cross-schema user-dictionary auto-merge  
- English layout as a third RIME Chinese scheme row (unless later PD)

### 5. Open questions (remaining)

| # | Status | Note |
|---|---|---|
| Q1 | **Open** | Exact upstream release asset (full vs slim), license, checksum |
| Q2 | **Open** | Primary schema ID(s) for user-facing “万象拼音（全拼）” |
| Q3 | **Partially frozen** | Large size **accepted in principle**; Architecture names install/jetsam budget and may force slim build |
| Q4 | **Open** | Advanced-input matrix vs fog-song |
| Q5 | **Frozen (product)** | Layout-bound scheme selection **required**; not fog-song-only T9 forever; ADR 0018 amendment required |
| Q6 | **Open (Architecture)** | Default/migration when per-layout scheme unset; readiness markers per layout×scheme |

## Implementation follow-through

| Action | Authorized now? |
|---|---|
| Record freezes + layout-bound requirement | **Yes** |
| ADR 0018 amendment draft | **Yes** (Architecture) before layout-picker production |
| Spike: 万象 catalog + full-pinyin install + selectSchema smoke | After Executor named; Q1–Q2 frozen enough |
| Layout settings UI: per-layout scheme picker | After ADR path accepted; may ship with fog-song/`t9` first, then 万象 on 26-key |
| Production catalog + deploy for 万象 | Only when Assignment Ready |

## History

- 2026-08-07: Proposed after Product declined T9 single-key mixed candidates.  
- 2026-08-07: Freeze addendum — 全拼 V1; accept large size; **layout-page scheme choice (incl. nine-key)** supersedes fog-song-only T9 product default.
