# Assignment: KEYBOARD-LAYOUT-9KEY-UI-001 — Native-aligned Chinese nine-key chrome

**Policy version:** `1.0.0`

**Decision source:** Human Product Owner request to align nine-key UI with native screenshots under local `photos/` / `2026-07-17 Asia/Shanghai`

**Decision date:** `2026-07-17 Asia/Shanghai`

**Lifecycle status:** `Accepted / Closed`

**Assignment Authority:** Product Lead

---

## Objective

Update **Keyboard Extension Chinese nine-key chrome only** so visual structure and key labeling match the system Chinese 九宫格 closely enough for Product acceptance, without changing RIME T9 digit semantics (keys still send digits 2–9), deployment ownership, or 26-key QWERTY metrics beyond shared symbol/title type-scale constants.

`photos/` is local reference only and must not be published to GitHub (`.gitignore`).

---

## Authority

- **Domain Owner:** Keyboard Experience Maintainer (primary — Extension chrome)
- **Executor:** Architecture/Implementation agent under Product authorization
- **Supporting:** RIME Platform (no scheme change); Input Intelligence (no typo path change)
- **Environment Executor:** `Not Applicable` for pure UI code; Human Dependency for device visual acceptance
- **Human Dependency:** Human Product Owner — device screenshots and final visual standard (**satisfied** `2026-07-17`)
- **Architecture Reviewer:** Architecture & Knowledge Steward (chrome documented under `KEYBOARD_LAYOUT.md`; ADR 0018 unchanged)
- **Quality Reviewer:** Simulator build + human visual acceptance
- **Product Approver:** Product Lead / Human Product Owner

---

## Scope (delivered)

1. Assignment + domain chrome contract in `KEYBOARD_LAYOUT.md` / `UI_STYLE_GUIDE.md`.
2. Native-aligned structure:
   - letter groups as **primary** labels (`ABC`…`WXYZ`)
   - left four-column main pad (`123` / `#+=` / `中` + letter keys)
   - right column: delete SF Symbol / **颜表情 `^_^`** / **return glyph spanning bottom two rows**
   - bottom row: emoji + **选拼音** (placeholder) + wide `拼音` at **1+1+2** column widths
3. T9 digit payload via `accessibilityIdentifier` + `t9Digit` accessibility value.
4. Shared type scale: symbols **22**, letter titles **16**, function text **15**, space **14**.
5. Return never shows host text such as `send`; VoiceOver keeps `returnKeyType` semantics.
6. `photos/` gitignored.
7. CHANGELOG + Dashboard synchronization.

## Non-goals

- English nine-key / multi-tap letter selection / swipe letter pick
- Live layout hot-switch while keyboard remains visible
- librime upgrade, T9 schema algebra change, Extension deploy
- Full product 选拼音 panel or 颜表情 candidate content (placeholders only)
- Changing candidate ranking or host commit rules beyond chrome
- Committing `photos/` or device image dumps

## Stop Conditions

- Any requirement to change effective scheme rules outside ADR 0018
- Raw-digit host commit reintroduction
- Deployment boundary violation (Extension deploy)

## Exit / Closure

| Criterion | Status |
|---|---|
| Structure matches system-style 九宫格 | **Met** (device accepted) |
| Digit payload unchanged (2–9 → RIME) | **Met** |
| Type scale documented | **Met** |
| Simulator build | **Met** |
| Human visual standard accepted | **Met** `2026-07-17` |
| `photos/` not published | **Met** |

**Product Review:** Accepted by Human Product Owner after iterative device screenshots.  
**Closure:** `Accepted / Closed` on `2026-07-17 Asia/Shanghai`.

Follow-on for 选拼音 / 颜表情 product behavior requires a **new** Assignment.

## Related

- [`KEYBOARD_LAYOUT.md`](../KEYBOARD_LAYOUT.md) — chrome + runtime SoT summary
- [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) — type scale and freeze exception
- ADR 0018 — T9 runtime (unchanged)
- Predecessor: [`keyboard-layout-9key-001.md`](keyboard-layout-9key-001.md) (`Closed`)
