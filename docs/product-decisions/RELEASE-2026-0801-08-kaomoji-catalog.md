# Product Decision: RELEASE-2026-0801-08 — 颜表情目录与插入合同

**Decision ID:** `PD-RELEASE-2026-0801-08-KAOMOJI-CATALOG`
**Lifecycle status:** `Accepted` — catalog/interaction frozen; ADR 0030 Accepted; KeyboardCore implementation authorized
**Date / timezone:** `2026-08-23 Asia/Shanghai`
**Assignment:** [`RELEASE-2026-0801-08`](../assignments/release-2026-08-01-08-kaomoji-content.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Accepted` |
| **Phase** | 目录、许可、键位与 pending 行为已冻结；ADR 0030 Accepted；生产 Swift 已授权 |
| **Non-claims** | 不是 Apple 数据文件授权；不是网络词库；不是学习/排序系统；不改 ADR 0029 标点轮换 |
| **Next** | 按 ADR 0030 实现 KeyboardCore + 两个 `^_^` 键；抄录表近形重复仍可由 Human 校正 |
| **Residuals** | 抄录自系统面板截图的字形需 Human 核对；后续可用具名开源项目替换本表 |

---

## Authority

- **Product Approver / Decision maker:** Human Product Owner / Product Lead
- **Decision Source:** Human Product Owner, `2026-08-23 Asia/Shanghai`: default pending is key-face `^_^`; compact/expand lists follow the provided system kaomoji-panel screenshot as first-cut shapes; catalog is first-party literals with no third-party project; nine-key `^_^` and symbols-page `^_^` share one action; no same-key cycle
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)

## Bound Product Decisions

1. **Default pending** is ASCII `^_^`, matching the existing chrome title.
2. **Interaction** reuses the candidate bar and expand/swipe-down panel. Tap inserts pending `^_^`. Candidate tap **replaces** the pending span. Tap `^_^` again **accepts** current pending and starts a new default `^_^`. **No** 1.0s same-key cycle.
3. **Keys:** Chinese nine-key letter-page right-column `^_^` and Chinese symbols-page `^_^` dispatch the **same** Core action. Do not add a 26-key letters-page key in this Assignment.
4. **Catalog provenance:** first-party string literals in this repository. No third-party kaomoji project, network fetch, user-generated catalog, or ranking. A later named project may replace the table under a new Product Decision. The screenshot is an **interaction and first-cut shape reference** from iOS system UI, not a licensed Apple data dump and not a claim of Apple permission.
5. **Compact bar includes the current pending.** Unlike ADR 0029 punctuation (which hides the in-host `，` so `。？！` can lead), kaomoji compact **does not exclude** the pending title. ASCII `^_^` is always first. The current pending uses the existing preferred-candidate / selected treatment (visual + VoiceOver `.selected` / 「已选中」). Tapping the already-pending item is a no-op replace (same span, pending stays). The collapse chevron is chrome, not a catalog token.
6. **Expanded panel** shows the full V1 table below, in this order, also **including** the current pending with selected state. Duplicate-looking glyphs that differ by fullwidth vs ASCII or spacing are distinct tokens.

### Compact (first cut)

Order is frozen: default `^_^` first, then the screenshot first row.

```
^_^
＾ω＾
＾＾
＾＿＾
＾_＾
＾_＾
```

The last two fullwidth faces are distinct if transcription keeps both; Human may drop a true duplicate. Compact may horizontally scroll; do not drop `^_^` to make room.

### Expanded V1 table (first cut, screenshot order, plus ASCII default)

```
^_^
＾ω＾
＾＾
＾＿＾
＾_＾
＾_＾
(＾＾)
(＾＾)
(＾-＾)
(＾_＾)
＾o＾
(o＾＾o)
(＾_＾)a
(＾_＾)v
:)
:(
:-)
=)
=(
;-)
:-|
:-(
:-D
:D
:-P
:P
囧＾-＾囧
(`∨´)
(。ì_í。)
|-|
(*＾＾*)
(*＾_＾*)
```

`^_^` is prepended so the default pending exists in the catalog. `(＾＾)` appears twice if the screenshot’s second parenthesized face is not identical; Human should correct duplicates.

7. **Displacement:** do not change punctuation cycle, continuation, typo, T9 Path, or RIME composition. Pending kaomoji and pending punctuation are mutually exclusive: starting one accepts the other (clear state, do not delete already-accepted host text).

## Explicit non-authorization

- Network catalog, persistence of user kaomoji, learning, accounts
- Redesigning candidate-bar geometry
- Presenting the `^_^` key as a finished feature in App Store copy before 08 Exit Criteria
- Changing ADR 0029 punctuation cycle behavior

## Related Documents

- [`assignments/release-2026-08-01-08-kaomoji-content.md`](../assignments/release-2026-08-01-08-kaomoji-content.md)
- [`architecture/decisions/0029-t9-pending-punctuation-palette.md`](../architecture/decisions/0029-t9-pending-punctuation-palette.md)
- [`KEYBOARD_LAYOUT.md`](../KEYBOARD_LAYOUT.md)
