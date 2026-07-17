# Keyboard Layout

Lifecycle status: Runtime contract accepted (ADR 0018); Chinese nine-key chrome accepted under KEYBOARD-LAYOUT-9KEY-UI-001  
Source of truth for: 26-key / Chinese nine-key layout selection, effective RIME scheme resolution, versioned T9 readiness, and **nine-key Extension chrome**  
Related ADR: [`architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md`](architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md)  
Related plan: [`plans/keyboard-layout-9key-implementation-plan.md`](plans/keyboard-layout-9key-implementation-plan.md) (Archived)  
Related Assignments:

- Runtime V1: [`assignments/keyboard-layout-9key-001.md`](assignments/keyboard-layout-9key-001.md) (`Closed`)
- Chrome UI: [`assignments/keyboard-layout-9key-ui-001.md`](assignments/keyboard-layout-9key-ui-001.md)

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

## T9 Input Semantics (V1)

- Digits go to RIME as the raw composition.
- Visible preedit prefers non-empty candidate comments, then raw digits **for display only**.
- Delete removes one raw digit through RIME.
- While T9 composition is active, Return, language switch and automatic English switch **never** commit raw digit strings to the host.
  - Space with candidates: commit highlighted/first candidate.
  - Space/Return without candidates: no raw-digit host commit; keep composition.
  - English / auto-English: no raw-digit host commit; abandon composition, show QWERTY.
- Existing letter typo-correction paths must ignore T9 digit strings.

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
| Bottom row | Emoji page entry + **选拼音** (placeholder) + wide space (`拼音`); widths follow the left pad’s 4-column rhythm (**1+1+2**); delete/return are **not** duplicated here |
| Globe | Still created for `needsInputModeSwitchKey`; system may hide it and show an external globe |

### Typography (shared with style guide)

| Kind | Size |
|---|---|
| SF Symbols (delete / return / globe / emoji) | **22** pt |
| Letter groups / character titles | **16** pt |
| Function text (中、选拼音、123、#+=、`^_^`) | **15** pt |
| Space title（拼音） | **14** pt |

Return **never** shows host action text such as `send`; VoiceOver still uses `returnKeyType` semantics.

### Placeholders (not product-complete)

- **选拼音** — chrome only; `t9SelectPinyinPlaceholder` emits key feedback only.
- **颜表情 (`^_^`)** — chrome only; reuses `showKaomojiCandidatesPlaceholder` (same family as symbols-page `^_^` entry).

Chrome is skin only: effective scheme, readiness and digit algebra remain ADR 0018.

## Deployment Boundary

Only the main App installs T9 schema artifacts, runs full deployment and writes readiness. See ADR 0001 and ADR 0018.

## V1 Non-goals

- English nine-key
- Swipe-to-letter / multi-tap letter pick on nine-key
- 朙月 nine-key scheme
- Live cross-process layout hot-switch while the keyboard is already shown
- librime binary upgrade unless a later regression invalidates the Spike
- Full product implementation of 选拼音 panel or 颜表情 candidate content (placeholders only)

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
