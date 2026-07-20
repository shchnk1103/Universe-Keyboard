# ADR 0021: T9 Deterministic Single-Key Choices And Cycle Selection

## Status

Accepted under Assignment `KEYBOARD-LAYOUT-9KEY-PINYIN-002` after the pinned-librime Spike passed on `2026-07-19 Asia/Shanghai`.

Development-grade evidence: [`keyboard-layout-9key-pinyin-002-spike-summary.md`](../../assignments/keyboard-layout-9key-pinyin-002-spike-summary.md). The isolated run proved `replaceInput("m")`, `replaceInput("n")`, and `replaceInput("o")` each returned exact raw input, non-empty Chinese candidates (`9 / 9 / 4`), and no committed text on librime `1.16.1`. Publication evidence still requires a clean-commit re-run.

This ADR extends ADR 0020. It does not change ADR 0018 layout/readiness/deployment ownership or ADR 0020 mixed-T9 no-raw-host-commit rules.

**Amendment A status:** Accepted for segmented disambiguation on `2026-07-19 Asia/Shanghai` after the pinned-librime hard gate passed. Evidence: [`keyboard-layout-9key-pinyin-002-segmented-spike-summary.md`](../../assignments/keyboard-layout-9key-pinyin-002-segmented-spike-summary.md).

## Context

ADR 0020 made current RIME candidate comments the sole precise-path provenance. On the pinned `t9` runtime, digit `6` exposes only comment `o` in the observed candidate window, although the key identity is `MNO`. Consequently the accepted compact path bar shows only `o` and cannot offer precise `m/n/o` selection.

ADR 0020 also defines **选拼音** as an expanded-panel trigger. Native reference behavior instead retains `m/n/o`, selects `m` on the first press, selects `n` on the second, and visibly marks the selection. A successful `replaceInput("m")` changes live RIME raw identity from `6` to `m`; rebuilding choices solely from that refined output would discard `n/o`, so cycle state must distinguish the choice origin from current refined raw.

## Decision

### 1. Two bounded choice sources

- A single unresolved raw digit `2...9` uses the canonical T9 key-identity group as its complete displayed choice set.
- Longer digit/mixed compositions continue to use compatible current RIME comment paths under ADR 0020.
- The key-identity mapping is centralized in KeyboardCore and shared by compatibility validation and single-key choice generation.
- The mapping does not generate Chinese candidates and must not expand multi-digit Cartesian combinations.

### 2. Retained refinement snapshot

KeyboardCore owns a refinement snapshot containing:

- the source composition identity that issued the displayed choices;
- ordered displayed choices;
- selected choice/index;
- a revision/token that invalidates stale UI actions.

On a successful selection, the current RIME output and marked composition update, while the single-key snapshot remains available for another selection from the same source. The snapshot is not reconstructed from UIKit or accessibility metadata.

### 3. One transactional selection path

Direct path taps and **选拼音** cycling resolve to the same Core selection transaction:

1. validate the action against the current snapshot revision and displayed choice set;
2. call `RimeEngine.replaceInput` with the chosen raw letters/path;
3. accept only a usable composition with exact requested raw identity and no `committedText`;
4. update composition/candidates/marked text and selected state;
5. on failure, restore the complete previous RIME/composition/path snapshot.

The cycle action selects index `0` when no choice is selected, otherwise advances and wraps.

An explicit path selection owns the visible marked-text spelling for that transaction. RIME remains authoritative for raw composition, candidates, and ranking, but its highlighted/first candidate comment cannot replace the exact selected path label in the host field. Rollback restores the pre-transaction marked text exactly.

### 4. Invalidation

New nine-key input, Delete, candidate/final commit, page or language change, visibility abandonment, runtime fallback, and session recreation/recovery must either build a new live snapshot or clear the previous one. Stale direct-tap/cycle actions fail closed.

### 5. UI boundary

- UIKit renders the ordered choices and selected state, and forwards direct-tap/cycle actions.
- **选拼音** no longer presents the ADR 0020 full-path panel for this Work Item.
- The fixed 34 pt reservation, plain-text presentation, candidate-bar geometry, and minimum accessible hit-target intent remain unchanged.
- Before selection, every path remains visually unselected. The active path reuses the preferred-candidate inverse-color rounded highlight rather than relying only on accessibility state.
- VoiceOver exposes each choice as a button and the active choice as selected; **选拼音** describes selecting the first/next path rather than opening a list.

### 6. Runtime and performance boundaries

- The Extension mutates only its current RIME session.
- No deployment/readiness writes, vendor upgrade, schema patch, network, or persistent hot-path work.
- Single-key generation is constant-size. Multi-key discovery remains bounded by ADR 0020 limits.

## Alternatives Considered

- **Keep comment-only provenance:** rejected because the pinned runtime demonstrably cannot supply `m/n/o` after `6`.
- **Open the existing full panel:** rejected by the new Product Decision requiring repeated-button cycling.
- **Store cycle index in UIKit:** rejected because refinement, rollback, recovery, and stale-action authorization are Core state semantics.
- **Generate every multi-digit letter combination:** rejected because it is combinatorial, can invent invalid pinyin, and duplicates RIME responsibility.
- **Upgrade librime or mutate the schema:** rejected by scope and deployment boundaries.

## Consequences

- ADR 0020's current-comment-only rule remains valid for multi-key comment paths but gains a narrow single-unresolved-digit key-identity exception.
- State must preserve a choice origin across successful raw replacement and separately track live RIME output.
- Existing expanded-panel implementation and tests become obsolete for the Product-selected button behavior.
- Tests must cover cycle wrap, direct/cycle equivalence, complete rollback, and lifecycle invalidation.

## Risks

- A keypad letter may not produce usable candidates on the pinned schema; the Spike is therefore a hard gate.
- Retaining a source snapshot too broadly could authorize stale choices after new input or recovery; explicit revision invalidation is required.
- Removing the panel reduces access to paths outside the four compact choices; this is an accepted boundary of `PD-...-002`, not an accidental UI omission.

## Follow-up Work

1. Run and archive the pinned-librime `m/n/o` Spike.
2. Accept or reject this ADR from that evidence.
3. Implement Core tests/state/actions, then UIKit behavior.
4. Update domain/release documentation and collect physical-device Product Gate evidence.

## Amendment A — Segmented Disambiguation

### State modes

KeyboardCore must distinguish two modes instead of treating every new raw input as one replaceable flat snapshot:

- **Whole composition:** no focused segment has been explicitly selected. Visible paths are a bounded merge of RIME-authorized complete paths and first-key group choices.
- **Segmented:** Core retains original digit groups, a focus index, confirmed segment values before the focus, an optional tentative value at the focus, and live RIME provenance. Pending later digit groups do not erase the focused selection.

KeyboardCore records the original digit sequence, focus index, confirmed values, current selection, ordered choices, and full replacement raw inputs. A segment choice is identified by the current Core-issued display/replacement pair; UIKit does not synthesize or interpret it.

### Transitions

1. Selecting a segment choice transactionally applies the corresponding full live raw input and records it as tentative.
2. New digit input appends a pending digit group and rebuilds live replacement forms while retaining the focused choices/selection.
3. Tapping a different focused choice changes tentative selection.
4. Tapping the already selected focused choice performs a Core-only confirm/advance transition; it does not call host commit.
5. Advancing focus performs at most one bounded probe per letter in the next physical key group. A probe is authorized only when its live candidate comments contain the corresponding apostrophe-delimited segment; exact raw retention or non-empty fallback candidates alone are insufficient. The original ambiguous raw is restored after probing.
6. Space/选定 remains candidate finalization and never substitutes for step 4.

### Acceptance evidence (Amendment A)

Pinned librime `1.16.1` proved `n4` remains uncommitted and usable. Exact probes `n'g`, `n'h`, and `n'i` all retained raw input, but only `g` and `h` produced candidate comments containing a second apostrophe-delimited segment; `i` returned fallback-only comments (`na / nian / nv / …`). The hard assertion therefore produced `authorizedSuffixes=g|h` without a static pinyin graph or Cartesian enumeration.

## Amendment B — Progressive First-Syllable Compact Paths

**Status:** Product-authorized under Active Assignment `KEYBOARD-LAYOUT-9KEY-PINYIN-002` on `2026-07-20 Asia/Shanghai` (Human Product Owner: ban multi-syllable whole paths; advance syllable-level after confirm).

### Decision

1. Whole multi-digit compact paths are **progressive first syllables** extracted from live comments (segment index 0 only) plus first-key-group letters. Multi-syllable labels with spaces (e.g. `ni xian zai`) are forbidden in the compact bar.
2. A **direct path-bar tap** both selects and, when remaining digits exist, immediately confirms/advances. **选拼音** only first/next/wraps tentative selection and never confirms a segment by itself.
3. Confirm/advance exposes the **next syllable** set at `confirmed.count`, digit-compatible with remaining source digits and live-comment authorized. Single-letter key-group probing remains the fallback when no multi-letter syllable is authorized.
4. Path-bar UI must keep single-line truncation inside the fixed 34 pt reservation; layout overlap is a defect, not an acceptable presentation of long comments.
5. No second Chinese candidate engine, no Cartesian multi-digit expansion, no Extension deployment, no raw host commit.

### Acceptance evidence (Amendment B)

Focused KeyboardCore tests cover: no multi-syllable compact labels on long digit sequences; first-syllable confirm advances to syllable-level next choices; two-key `mi / ni / m / n / o` regression; letter-group fallback after single-letter confirm (`g / h`). Physical-device Product Gate remains part of the parent Assignment.

## Related Documents

- [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-002`](../../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md)
- [`KEYBOARD-LAYOUT-9KEY-PINYIN-002`](../../assignments/keyboard-layout-9key-pinyin-002.md)
- [ADR 0020](0020-t9-precise-pinyin-path-selection.md)
- [ADR 0018](0018-keyboard-layout-nine-key-and-t9-runtime.md)
- [`KEYBOARD_LAYOUT.md`](../../KEYBOARD_LAYOUT.md)
