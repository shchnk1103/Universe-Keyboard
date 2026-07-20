# Product Decision: KEYBOARD-LAYOUT-9KEY-PINYIN-002 Authorization

**Decision ID:** `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-002`  
**Lifecycle status:** Recorded  
**Date / timezone:** `2026-07-19 Asia/Shanghai`  
**Assignment:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-002`](../assignments/keyboard-layout-9key-pinyin-002.md)  
**Predecessor:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-001`](../assignments/keyboard-layout-9key-pinyin-001.md) (`Accepted / Closed`)

## Authority

- **Product Approver / Decision maker:** 🧭 Product Lead, exercising KOS 2.0 Product authority under the Human Product Owner's explicit `2026-07-19 Asia/Shanghai` instruction to continue and fix the two screenshot-confirmed behaviors.
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 🧠 Input Intelligence Maintainer.
- **Executor:** Codex, limited to the linked Assignment Scope and phase gates.
- **Architecture / Quality review:** separate Architecture & Knowledge Steward and Quality, Performance & Release review handoffs after implementation.

This record is the stable Product Decision Source. The screenshots establish the desired behavior; this document makes its reusable contract explicit.

## Product Problem

The accepted `001` implementation does not reproduce two native Chinese nine-key behaviors:

1. Pressing `MNO` sends raw digit `6`, but the precise path bar currently shows only `o` because live RIME candidate comments are sparse. Product requires the deterministic choices `m / n / o`.
2. Pressing **选拼音** currently opens a full path panel. Product requires sequential refinement: first press selects `m`, second selects `n`, then `o`, with visible selection state.

The first gap was missed by the predecessor Product Gate. The second requirement supersedes the predecessor button interaction without reopening or rewriting the Closed Assignment.

## Bound Product Decisions

### 1. Choice presentation

1. In Chinese + letters + effective nine-key runtime, the existing fixed 34 pt precise-path bar remains reserved.
2. For a single unresolved digit `2...9`, the bar shows the complete canonical key group in keypad order (`abc`, `def`, `ghi`, `jkl`, `mno`, `pqrs`, `tuv`, `wxyz`). Thus `6` must show `m / n / o` even when RIME comments expose only `o`.
3. This group mapping is **key identity**, not a second Chinese candidate engine or offline pinyin graph. Chinese candidates and ranking remain owned by the active RIME `t9` session.
4. For longer digit/mixed compositions, full-path choices continue to come from current compatible RIME candidate comments, deduplicated in RIME order, with the existing compact limit of four.
5. A user may select a displayed choice directly.

### 2. 选拼音 cycling

1. **选拼音** no longer opens the predecessor full-path panel.
2. Each press selects the next currently displayed choice. With no selection, choose index `0`; subsequent presses advance and wrap to index `0` after the final choice.
3. `6` therefore cycles `m -> n -> o -> m`.
4. The selected choice receives the existing path-bar selected appearance and an accurate VoiceOver selected state.
5. Cycling and direct taps invoke the same KeyboardCore refinement transaction.

### 3. Composition and state invariants

1. Selection calls the existing session `replaceInput` path and refines marked composition only. It never commits raw letters/digits to the host.
2. KeyboardCore must preserve the choice set and selection origin across a successful refinement (`6 -> m`) so later cycling can still select `n` and `o`.
3. A new nine-key letter-group input starts a new live choice snapshot derived from the updated composition. Delete, candidate commit, page/language change, visibility abandonment, runtime fallback, and session recovery must not retain stale choice authorization.
4. Failed or unusable `replaceInput` rolls back RIME output, composition, marked text, choices, and selection exactly.
5. UIKit renders state and forwards actions only; it does not own the cycle index or synthesize business choices.

### 4. Safety and performance

1. The single-digit canonical group must be validated against the pinned librime with real `replaceInput` evidence for every displayed letter before UI implementation proceeds.
2. No librime/vendor upgrade, schema mutation, Extension deployment, network, shared-container write, or synchronous persistent I/O is authorized.
3. Existing mixed-T9 no-raw-host-commit, provenance invalidation, rollback, and lifecycle invariants remain binding unless ADR 0021 explicitly strengthens them.
4. The input hot path remains bounded; do not probe every Cartesian letter combination.

## Non-goals

- English nine-key or phone-style multi-tap text entry
- Generating all Cartesian letter combinations for multi-digit input
- A second Chinese candidate engine or offline pinyin dictionary
- Main-App settings or feature toggle
- Changing 26-key behavior
- librime/vendor upgrade or T9 schema deployment changes
- Restoring the predecessor full-path panel through another control in this Work Item
- Publishing commits, pushing, or opening a PR without separate Human Product Owner authorization

## Gates

1. Assignment must contain no `UNKNOWN` before `Ready`.
2. ADR 0021 must record the new choice-source and retained-cycle state boundaries.
3. Real pinned-librime Spike must prove `replaceInput("m")`, `replaceInput("n")`, and `replaceInput("o")` retain usable composition/candidates and never return committed text.
4. Spike failure blocks KeyboardCore/UI product implementation and returns to Architecture/Product Lead.
5. Automated Core/UI/Simulator evidence and physical-device comparison are distinct; only Product Lead may close Product Gate.

## Change Policy

This Decision extends the `001` product contract. Do not edit the historical `001` authorization to make the new behavior appear previously accepted. Material changes to cycle order, choice source, panel availability, or multi-digit behavior require a dated amendment or superseding Product Decision.

## Acceptance Clarification — 2026-07-19 Asia/Shanghai

The Human Product Owner clarified two existing acceptance requirements; these do not expand feature scope:

1. `selectedPath` must have a plainly visible selected appearance, reusing the preferred-candidate inverse-color rounded highlight. Before the first direct/cycle selection, no path is visually selected.
2. After an explicit path selection, host marked text displays that exact selected path (`m → n → o → m`). A highlighted/first RIME candidate comment must not replace the user-selected spelling with a longer full pinyin comment.
3. Failed refinement restores the exact previously visible marked path and selected appearance.

## Amendment A — Segmented Disambiguation, 2026-07-19 Asia/Shanghai

**Status:** Authorized and implemented locally after ADR 0021 Amendment A and the pinned-librime segmented Spike passed; independent review and physical-device Product Gate remain open.

The Human Product Owner accepted the “segmented disambiguation state machine” after a native iOS 27.0 investigation. The observation record is [`keyboard-layout-9key-pinyin-002-native-segmented-observation.md`](../assignments/keyboard-layout-9key-pinyin-002-native-segmented-observation.md).

### A1. Whole-composition mode

1. With no explicit segment selection, multiple digit groups expose bounded whole-composition paths plus the first unresolved key group. For `MNO → GHI`, the required order is `mi / ni / m / n / o`, initially with no selected item.
2. Whole paths must be authorized by compatible live RIME comments. Ordering may use canonical keypad identity after validation; it must not invent a second Chinese candidate engine.
3. The compact visible limit increases from four to **five** for this native-aligned case. No unbounded catalog or Cartesian enumeration is authorized.

### A2. Segmented mode

1. Selecting a key-group choice enters segmented mode. KeyboardCore owns the original digit groups, focused segment, confirmed segment prefix, tentative selection, ordered visible choices, and provenance revision.
2. A later digit appends a pending segment but does not discard the focused segment or its tentative selection. Example: after selecting `n` for `MNO`, pressing `GHI` keeps `m / n / o` visible with `n` selected while live RIME continues on the mixed raw form.
3. Tapping an **unselected** focused choice changes the tentative selection through the normal transactional refinement path.
4. Tapping the **already selected** focused choice confirms that segment without committing host text, advances focus to the next pending digit group, and shows its RIME-authorized segment choices with no selection. For the observed example, confirming `n` advances to `g / h`.
5. **选拼音** cycles choices only for the current focus. It never confirms a segment merely because it wrapped.
6. Segment confirmation is Core state only; UIKit must not infer it from button color or accessibility state.

### A3. Marked text, candidates, and “选定”

1. RIME remains authoritative for live raw composition, Chinese candidates, and ranking. A tentative focused choice controls its exact marked spelling until later pending digits cause live RIME to display a segmented preedit (observed as `n' h`).
2. While a T9 composition is active, the space key title is **选定**.
3. Pressing space/选定 retains the existing candidate-finalization contract: commit the highlighted/first Chinese candidate when available. It does **not** confirm or advance the focused pinyin segment.
4. Clicking the already selected path is the only newly authorized segment-confirm/advance gesture in this Amendment.

### A4. Invalidation and rollback

1. Delete reverses the latest pending digit/segment transition before invalidating earlier confirmed focus state; exact behavior must be test-specified from the accepted state model.
2. Final candidate commit, language/page/visibility abandonment, fallback, and session recreation clear segmented state.
3. Any failed live refinement or failed segment-focus transition restores RIME output, marked text, candidates, segment model, visible choices, and selection exactly or fails closed by resetting the session.

### A5. Additional hard gates

1. The pinned-librime Spike must capture `64`, `n4`, and exact refinements for the next segment (`n'g`, `n'h`, `n'i` or the runtime-equivalent forms), including comments, candidates, raw identity, and absence of committed text.
2. If live RIME data cannot authorize `g / h` without a static pinyin graph, unbounded probing, or unsafe live-session mutation, stop and return to Architecture/Product Lead.
3. Material behavior outside the observed two-segment flow—especially confirmation of a whole path, Delete across confirmed segments, and three-or-more groups—must be covered by explicit tests before Product Gate rather than guessed in UIKit.

### A6. Gate outcome

The pinned `1.16.1` run passed with exact `n4 / n'g / n'h / n'i` evidence and `authorizedSuffixes=g|h`. Non-empty candidates or exact raw retention are not sufficient authorization; the live comment must contain the requested apostrophe-delimited focused segment. This closes the Amendment A implementation blocker without introducing a static pinyin graph.

## Amendment B — Progressive Syllable Compact Paths, 2026-07-20 Asia/Shanghai

**Status:** Authorized by Human Product Owner during Active Assignment work after path-bar multi-syllable overlap was observed on long T9 compositions.

### B1. Whole-composition compact content

1. Unselected multi-digit compact paths **must not** show multi-syllable whole labels (e.g. `ni xian zai`).
2. Compact content is progressive **first syllables** from live comments plus first-key-group letters, maximum five items (`mi / ni / m / n / o` for `MNO → GHI` remains required).

### B2. Confirm/advance is syllable-level

1. A **direct path-bar tap** on a choice (e.g. `ni`) is a real confirmation: when remaining digits exist, the next compact set appears immediately without a second tap.
2. The next compact set is syllable-level (`xian / xiao / zhan…`) authorized by live comments at the next segment index and compatible remaining digits.
3. When no multi-letter next syllable is authorized, single-letter key-group fallback (Amendment A `g / h` style) remains valid.
4. **选拼音** only first/next/wraps the tentative selection within the current focus; it does not confirm or advance a segment.
5. Path bar presentation stays single-line inside the fixed 34 pt reservation.

### B3. Boundaries unchanged

No second candidate engine, no Cartesian expansion, no Extension deploy, no raw host commit. Independent review and physical-device Product Gate remain required before parent Assignment close.
