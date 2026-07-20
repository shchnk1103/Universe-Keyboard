# Keyboard Layout

Lifecycle status: Runtime contract accepted (ADR 0018); Chinese nine-key chrome accepted under KEYBOARD-LAYOUT-9KEY-UI-001; original precise pinyin selection closed under KEYBOARD-LAYOUT-9KEY-PINYIN-001; deterministic single-key choices, segmented + progressive-syllable path bar active under KEYBOARD-LAYOUT-9KEY-PINYIN-002 (ADR 0021 Amendments A/B)
Source of truth for: 26-key / Chinese nine-key layout selection, effective RIME scheme resolution, versioned T9 readiness, nine-key Extension chrome, and **precise pinyin path bar/cycling**
Related ADR: [`architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md`](architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md), [`architecture/decisions/0020-t9-precise-pinyin-path-selection.md`](architecture/decisions/0020-t9-precise-pinyin-path-selection.md), [`architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md`](architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md)
Related plan: [`plans/keyboard-layout-9key-implementation-plan.md`](plans/keyboard-layout-9key-implementation-plan.md) (Archived); precise pinyin [`plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md`](plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md) (Active)
Related Assignments:

- Runtime V1: [`assignments/keyboard-layout-9key-001.md`](assignments/keyboard-layout-9key-001.md) (`Closed`)
- Chrome UI: [`assignments/keyboard-layout-9key-ui-001.md`](assignments/keyboard-layout-9key-ui-001.md) (`Closed`)
- Original precise pinyin selection: [`assignments/keyboard-layout-9key-pinyin-001.md`](assignments/keyboard-layout-9key-pinyin-001.md) (`Accepted / Closed`)
- Deterministic choices + cycling: [`assignments/keyboard-layout-9key-pinyin-002.md`](assignments/keyboard-layout-9key-pinyin-002.md) (`Active`) — Product Decision [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-002`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md)

## Product Model

Users choose a keyboard layout in the main App under 设置 → 输入体验:

- **26键** — standard full QWERTY. Default.
- **9键** — Chinese alphabet page uses **system-style 九宫格 chrome** (letter-group labels, side functions). English and automatic-English contexts stay on existing QWERTY.

Nine-key depends on fog-song / rime-ice T9 resources. If those resources are missing, the main App must explain the dependency, obtain GPL acceptance, download, install, deploy and verify T9 before persisting the nine-key preference.

## Runtime Rules

1. Layout preference and base scheme are separate settings.
2. Effective scheme is derived, never stored as a second user-facing scheme row for `t9`.
3. T9 readiness is a **versioned marker** (ready flag + compatibility version + resource fingerprint), written only by the main App after successful smoke verification.
4. Extension reads cached layout/readiness on appear/activate; it does not deploy or rewrite RIME resources.
5. Missing, corrupt, mismatched or unknown layout/readiness values fall back to 26-key.
6. Failed nine-key enablement keeps the previous layout and keeps the keyboard typable.

## Ordered lifecycle writes

### Enable nine-key

`install → deploy → verify → write readiness marker → write nineKey last`

### Uninstall / remove T9 resources

`write twentySixKey → invalidate readiness → delete resources`

### Switch base scheme away from rime-ice while T9 files remain intact

`write twentySixKey`; **keep** readiness if fingerprint still matches (avoid useless redeploy on return).

## Effective Selection Summary

- 26-key + rime-ice → effective `rime_ice`
- 9-key + rime-ice + **matched** readiness → effective `t9`, Chinese alphabet page uses nine-key chrome
- 9-key without matched readiness / without rime-ice / with unsupported base scheme → safe 26-key behavior

## T9 Input Semantics (V1 + ADR 0020 + ADR 0021)

- Digits go to RIME as the raw composition.
- Visible preedit prefers non-empty candidate comments, then raw input **for display only**. This includes **Partial Commit remainders**: after selecting `你好` from a longer T9 composition, marked text shows `你好` + comment remainder (e.g. `ya`), never `你好` + raw digits (`92`).
- After Partial Commit under T9, the path bar rebuilds from the **remaining** raw only (hard provenance); it must not retain choices from the pre-selection full digit sequence.
- Delete removes one raw unit through RIME (digit, letter, or mixed after path refine).
- **Active T9 composition** (ADR 0020): `usesT9InputSemantics` and non-empty raw input consisting only of letters, digits, spaces and `'`. Includes pure digits, pure letters after path selection, and mixed forms such as `ni4`.
- While a valid T9 composition is active, Return, language switch and automatic English switch **never** commit raw input to the host.
  - Space with candidates: commit highlighted/first Chinese candidate.
  - Space/Return without candidates: no raw host commit; keep composition.
  - English / auto-English: no raw host commit; abandon composition, show QWERTY.
- Existing letter typo-correction paths must ignore active T9 compositions (including mixed raw input).
- **Precise pinyin path selection** refines composition via session `replaceInput` only; it never commits path text to the host.
  - A single unresolved digit uses the canonical ordered key identity (`2 → abc` … `6 → mno` … `9 → wxyz`), so `MNO` always exposes `m / n / o` even when RIME comments contain only `o`.
  - **Amendment B progressive syllables:** With no segment selected, multi-digit compact choices are **first-syllable** labels from live comments plus first-key-group letters. `MNO → GHI` still displays `mi / ni / m / n / o` (compact maximum **5**). Multi-syllable whole comments such as `ni xian zai` **must not** appear as one compact cell.
  - **Direct path-bar tap** selects and, when remaining digits exist, **immediately confirms/advances** to the next syllable set (no second tap). **选拼音** only first/next/wraps the tentative selection within the current focus and never confirms a segment by itself.
  - After confirm, the next compact set is **syllable-level** (`xian / xiao / zhan…`) extracted from live comments at the next apostrophe-delimited index and digit-compatible with the remaining sequence. When no multi-letter syllable is authorized, fall back to single-letter key-group probes for the next digit (`g / h` style from Amendment A).
  - Next-focus authorization requires live RIME evidence: exact syllable match in comments for multi-letter steps, or letter-prefix segment authorization for single-letter fallback. Exact raw retention and non-empty candidates alone are insufficient.
  - The single-key identity mapping only issues bounded refinement choices; Chinese candidates and ranking still come exclusively from RIME.
- After a successful single-key refine, KeyboardCore retains the issued choice snapshot while updating live RIME raw/preedit. This permits `m → n → o → m` cycling without authorizing stale choices after new input, Delete, final commit, page/language/visibility changes, fallback, or recovery.
- An explicit path selection controls the host-visible marked spelling: cycling `m → n → o → m` displays exactly those values. Candidate comments may still inform path discovery/candidates, but cannot replace the selected spelling with a longer full-pinyin comment.
- Hot-path compact refresh uses page candidates first, then a **bounded** `candidateWindow` peek (`hotPathWindowLimit`, not a full catalog walk). Full-panel lazy paging uses dual-revision-guarded windows: `rawInputGeneration` tracks raw lifecycle; `provenanceRevision` tracks comment/window authority (UIKit expanded panel and click guards bind to provenance). Applying a new RimeOutput always hard-opens provenance even if raw is unchanged; soft same-snapshot re-scan may accumulate expanded issuance without bumping provenance. Device key latency for the bounded peek remains a Product Gate measurement item (no invented threshold).

### Precise path bar geometry

- Order: **path bar (34 pt, fixed reservation)** → Chinese candidate bar (34 pt) → nine-key pad.
- Path bar is reserved whenever Chinese nine-key letters chrome is active, even with empty composition (no height jump).
- Compact bar shows at most **5** single-line path labels (no multi-syllable wrap); plain text, no candidate pills; optional 1px separator above the Chinese candidate bar.
- **选拼音** selects the first compact choice for the current focus when none is selected, then advances and wraps. It never confirms a segment and never opens the predecessor expanded path panel.
- While T9 composition is active, the wide space key title changes from `拼音` to **选定**. Its action remains candidate finalization (highlighted/first Chinese candidate), not segment confirmation.
- Before the first selection there is no path highlight. The selected path uses the same inverse-color 8 pt rounded highlight language as the preferred candidate and retains an accurate VoiceOver selected state.

## Nine-key Chrome (UI)

Chinese nine-key chrome matches the **system 九宫格** visual rhythm (Assignment `KEYBOARD-LAYOUT-9KEY-UI-001`), not the classic phone-pad “large digit + tiny letters” look.

Reference screenshots used during design may live only under local `photos/` (gitignored). They are not repository evidence.

### Structure

```text
[123]  [,?!]  [ABC]  [DEF]  | [ delete.left ]
[#+=]  [GHI]  [JKL]  [MNO]  | [   ^_^      ]
[中]   [PQRS] [TUV]  [WXYZ] | ┌────────────┐
[😊]   [选拼音] [  拼音  ]  | │ return 符  │  ← spans bottom two rows
                            | └────────────┘
```

| Region | Content |
|---|---|
| Letter keys | Primary labels are letter groups (`ABC`…`WXYZ`); digit **2–9** payload is identity-only for RIME (`accessibilityIdentifier` + `accessibilityValue == t9Digit`) |
| Left main pad | Four equal columns: page/punct/letters, symbols/letters, input-mode/letters |
| Right column | Delete (SF Symbol `delete.left`), **颜表情** (`^_^`, product placeholder), **Return glyph** (`return` SF Symbol) spanning the bottom two rows |
| Bottom row | Emoji page entry + **选拼音** + wide space (`拼音`, active composition: `选定`); widths follow the left pad’s 4-column rhythm (**1+1+2**); delete/return are **not** duplicated here |
| Globe | Still created for `needsInputModeSwitchKey`; system may hide it and show an external globe |

### Typography (shared with style guide)

| Kind | Size |
|---|---|
| SF Symbols (delete / return / globe / emoji) | **22** pt |
| Letter groups / character titles | **16** pt |
| Function text (中、选拼音、123、#+=、`^_^`) | **15** pt |
| Space title（拼音） | **14** pt |

Return **never** shows host action text such as `send`; VoiceOver still uses `returnKeyType` semantics.

### Placeholders / productized controls

- **选拼音** — current behavior is governed by [`KEYBOARD-LAYOUT-9KEY-PINYIN-002`](assignments/keyboard-layout-9key-pinyin-002.md) / ADR 0021: enabled only when compact choices exist; first press selects the first choice, later presses select next/wrap. Compact paths remain directly tappable in the fixed bar.
- **颜表情 (`^_^`)** — chrome only; reuses `showKaomojiCandidatesPlaceholder` (same family as symbols-page `^_^` entry). Full product content requires a **separate** future Assignment.

Effective scheme, readiness and digit algebra remain ADR 0018; path refinement extends session semantics under ADR 0020 without Extension deploy.

## Deployment Boundary

Only the main App installs T9 schema artifacts, runs full deployment and writes readiness. See ADR 0001 and ADR 0018.

## V1 Non-goals

- English nine-key
- Swipe-to-letter / multi-tap letter pick on nine-key
- 朙月 nine-key scheme
- Live cross-process layout hot-switch while the keyboard is already shown
- librime binary upgrade unless a later regression invalidates the Spike
- Full 颜表情 candidate content (placeholders only; separate future Assignment)
- English nine-key multi-tap / swipe letter pick (still non-goals for precise pinyin work)

## Spike Gate

Product implementation of nine-key required a successful isolated T9 Spike on the pinned librime artifact with strong assertions (non-empty candidates **and** composition/preedit) and commit-bound provenance.

### Spike result (hardened, 2026-07-16)

- Status: **PASSED**
- Harness commit: `337dd30ab443ad2d2af497648910946d6beb1a35`
- Evidence archive commit: `ad5da19a487507452f4514e5225f555256ab3f04`
- Tracked evidence: `docs/evidence/keyboard-layout-9key-001/`
- Local full run: `evidence/keyboard-layout-9key-spike/20260716-195542/`
- Pinned librime: `1.16.1` (`rime-vendor-ios-1.16.1-lua.1`)
- Compatibility patch: remove `t9_processor` only
- Proven: select `t9`, input `64` → raw `64`, preedit `64`, 9 candidates (`你|密|米|迷|秘`), first comment `ni`, BackSpace → raw `6`
- Vendor verify failure fails Spike
- Runner: `scripts/run_t9_compatibility_spike.sh`
- Test: `Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9CompatibilitySpikeTests.swift`

Amendment handoff: [`evidence/keyboard-layout-9key-001-codex-handoff.md`](evidence/keyboard-layout-9key-001-codex-handoff.md).
First Codex review record (pre-amendment): [`evidence/keyboard-layout-9key-001-codex-review.md`](evidence/keyboard-layout-9key-001-codex-review.md).
