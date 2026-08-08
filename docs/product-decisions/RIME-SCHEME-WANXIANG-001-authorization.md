# Product Decision: RIME-SCHEME-WANXIANG-001 — Support 万象拼音 as a downloadable RIME scheme

**Decision ID:** `PD-RIME-SCHEME-WANXIANG-001`
**Lifecycle status:** `Active` — V1 freezes held; catalog/layout path implemented + Human-verified; formal PD/Assignment close optional after merge
**Date / timezone:** `2026-08-07 Asia/Shanghai`
**Parent domain:** RIME multi-scheme management ([`RIME_SCHEME_MANAGEMENT.md`](../RIME_SCHEME_MANAGEMENT.md)); keyboard layout ([`KEYBOARD_LAYOUT.md`](../KEYBOARD_LAYOUT.md))
**Related:** ADR 0001; catalog/install model; [`ADR 0026`](../architecture/decisions/0026-layout-bound-rime-scheme-selection.md) (**Accepted**)
**Assignment:** [`rime-scheme-wanxiang-001.md`](../assignments/rime-scheme-wanxiang-001.md)
**Replaces investment focus:** [`PD-T9-SINGLE-KEY-MIXED-CANDIDATES-001`](T9-SINGLE-KEY-MIXED-CANDIDATES-001-authorization.md) (`Closed — Won’t do`)

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Active` — path ready for formal close (2026-08-08 EOD) |
| **Phase** | Q1/Q2 frozen; base.zip + layout-bound + Human smoke; TD-009/010/011A on `main` |
| **Non-claims** | Not App Store marketing; grammar `.gram` optional not in V1 zip; not dual-spell; 万象 advanced **toggles** not fog-parity (freeze A: native triggers + usage copy only) |
| **Next** | Optional formal close; default follow-on **TD-012**; TD-011 B–D only if Product productizes 万象 controls |
| **Residuals** | TD-011 remaining B–D (optional); LMDG → TD-012; settings gates **TD-010 repaid**; toast **TD-009 repaid** |

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

### 5. Asset pin (Q1/Q2 frozen 2026-08-07, Executor under Product autonomy)

| Field | Freeze |
|---|---|
| Upstream | [amzxyz/rime-wanxiang](https://github.com/amzxyz/rime-wanxiang) |
| Release asset (V1 全拼) | **`rime-wanxiang-base.zip`** (latest GitHub release; e.g. v17.2.4 ~34 MB) — not dual-spell fuzhu packs |
| User-facing schema | **`wanxiang`** (`wanxiang.schema.yaml`); display name **万象拼音** |
| License | **CC BY 4.0** (upstream LICENSE) |
| Nine-key | Package may include `wanxiang_t9*`; **V1 picker still treats 万象 as 26-key only** until a later readiness path for 万象九键 |
| Grammar model | Optional separate `wanxiang-lts-zh-hans.gram` (RIME-LMDG) — **not** bundled in V1 install zip |

### 6. Open questions (remaining)

| # | Status | Note |
|---|---|---|
| Q1 | **Frozen** | base.zip from amzxyz/rime-wanxiang |
| Q2 | **Frozen** | schema_id `wanxiang` |
| Q3 | **Partially frozen** | ~34 MB zip accepted; jetsam residual optional device note |
| Q4 | **Deferred** | Advanced-input not claimed for 万象 V1 |
| Q5 | **Frozen** | Layout-bound picker (ADR 0026 Accepted) |
| Q6 | **Frozen (ADR 0026)** | Migration when bindings absent |

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
- 2026-08-07: Q1/Q2 freeze — `rime-wanxiang-base.zip`, schema `wanxiang`, CC BY 4.0; catalog install authorized under Product KOS autonomy.
- 2026-08-07 EOD: Human verified V1 path; roadmap agreed (close → TD-010/009 → TD-011/012); status synced for zero-context resume.
