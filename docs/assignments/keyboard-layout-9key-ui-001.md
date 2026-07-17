# Assignment: KEYBOARD-LAYOUT-9KEY-UI-001 — Native-aligned Chinese nine-key chrome

**Policy version:** `1.0.0`

**Decision source:** Human Product Owner request to align nine-key UI with native screenshots under `photos/` / `2026-07-17 Asia/Shanghai`

**Decision date:** `2026-07-17 Asia/Shanghai`

**Lifecycle status:** `Active`

**Assignment Authority:** Product Lead

## Objective

Update **Keyboard Extension Chinese nine-key chrome only** so visual structure and key labeling move closer to the system Chinese 九宫格, using local screenshots in `photos/` as reference. Do **not** change RIME T9 digit semantics (keys still send digits 2–9 to the engine), deployment ownership, or 26-key QWERTY.

`photos/` is local reference only and must not be published to GitHub.

## Authority

- **Domain Owner:** Keyboard Experience Maintainer (primary — Extension chrome)
- **Executor:** Architecture/Implementation agent under Product authorization
- **Supporting:** RIME Platform (no scheme change expected); Input Intelligence (no typo path change expected)
- **Environment Executor:** `Not Applicable` for pure UI code; Human Dependency for optional on-device visual confirmation
- **Human Dependency:** optional physical-device screenshot after implementation
- **Architecture Reviewer:** Architecture & Knowledge Steward when layout contracts change
- **Quality Reviewer:** build + focused keyboard compile; device visual optional
- **Product Approver:** Product Lead / Human Product Owner

## Scope

1. Assignment + domain note for nine-key chrome layout.
2. Restructure Chinese nine-key rows toward native 5-column rhythm:
   - letter groups as **primary** labels (ABC/DEF/…)
   - left function column (123 / symbols entry / 中英)
   - right function column (delete / re-input / return)
   - bottom row with globe + wide space (拼音), without duplicating delete/return
3. Keep T9 input payload as digits via stable button identity (`accessibilityIdentifier`).
4. Re-input clears composition without committing raw digits (ADR 0018).
5. Ignore `photos/` in git.
6. UI_STYLE_GUIDE note: nine-key chrome exception to generic V1 freeze when matching native 九宫格 usability.

## Non-goals

- English nine-key / multi-tap letter selection / swipe letter pick
- Live layout hot-switch while keyboard remains visible
- librime upgrade, T9 schema algebra change, Extension deploy
- Changing candidate ranking or host commit rules beyond chrome layout
- Committing `photos/` or device image dumps

## Stop Conditions

- Any requirement to change effective scheme rules outside ADR 0018
- Raw-digit host commit reintroduction
- Deployment boundary violation (Extension deploy)

## Related

- ADR 0018, `docs/KEYBOARD_LAYOUT.md`, `docs/UI_STYLE_GUIDE.md`
- Closed predecessor: `KEYBOARD-LAYOUT-9KEY-001` (V1 functional nine-key)
