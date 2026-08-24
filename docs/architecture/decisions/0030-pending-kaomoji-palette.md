# ADR 0030: 待确认颜表情与本地候选源

## Status

Accepted — Human Product Owner, `2026-08-23 Asia/Shanghai`, after the frozen catalog/interaction Product Decision. Independent Architecture review remains a merge gate, not a precondition for starting KeyboardCore implementation.

## Decision Date

`2026-08-23 Asia/Shanghai`

## Context

V1.0 requires kaomoji content ([`RELEASE-2026-0801-08`](../../assignments/release-2026-08-01-08-kaomoji-content.md)). The nine-key and symbols-page `^_^` keys are still placeholders (`showKaomojiCandidatesPlaceholder`).

ADR 0029 already solved “local palette + host span you can replace from the candidate bar” for punctuation. Product wants the same *pending + compact bar + expand* shape, **without** the 1.0s same-key cycle.

Reusing continuation (ADR 0017) would append instead of replace. Feeding kaomoji to RIME would require composition. Teaching ADR 0029 to become a generic palette in the same change would risk the closed punctuation Product Gate.

## Decision

1. Add a **parallel** ephemeral Core state `pendingKaomoji` next to `pendingPunctuation`. Do not embed kaomoji in continuation, typo, Path, or `lastRimeOutput`.
2. Pending fields: `text`, `beforeCursor`, `afterCursor`, `ownsHostSpan`. **No** `cycleIndex` / `lastSameKeyTap` / `cycleArmed`.
3. New action `.pressKaomoji` from both Chinese nine-key letter-page `^_^` and Chinese symbols-page `^_^`.
4. New `CandidateKind.kaomojiCandidate`. Candidate tap replaces the owned span; pending remains. Compact and expand catalogs **include** the current pending title. ASCII `^_^` is always first. The pending item uses selected/preferred presentation; tapping it while it is already pending does not insert a second copy and does not cycle.
5. Candidate-bar priority: active RIME composition/preedit → else pending punctuation **or** pending kaomoji (mutually exclusive) → else continuation → else existing fallback. Starting kaomoji accepts punctuation pending (clear state, do not delete host text already accepted) and vice versa.
6. Same-key `^_^` with kaomoji pending: accept current, then insert a new default `^_^`. Never cycle through the compact list.
7. Space / Return / leave Chinese letters or symbols page / toggle English / visibility abandon: accept (clear state, do not delete). Delete while `ownsHostSpan`: remove the owned span.
8. Composition rules copy ADR 0029: commit first candidate if one exists; L1 / responsive provisional ahead **rejects** the key. Do not `finishActiveCompositionAsDisplayText`. Do not send kaomoji to RIME punctuator.
9. Host surgery reuses Core `insertText` / `deleteBackward` / `adjustTextPosition`. Extract shared span helpers from pending punctuation **only if** tests prove punctuation cycle behavior unchanged. Prefer duplication over a risky merge in V1 if extraction is unclear.
10. Catalog is a frozen first-party string table in Core (PD). No disk user catalog, network, or ranking.

## Alternatives Considered

- **Generalize ADR 0029 into one palette type now: rejected for V1.** Closed punctuation cycle is a Product Gate; a shared type with a “cycle optional” flag is a later cleanup, not the first knife.
- **UI-only insertDirectText + local lastTap: rejected.** Delete, page change, composition, and continuation would not see one Core state (same reason as 0029).
- **Reuse continuation candidates: rejected.** Continuation appends; kaomoji pending must replace.
- **Full-screen kaomoji grid replacing the keyboard: rejected.** Product froze candidate-bar reuse.

## Consequences

- Two pending kinds cannot be live together.
- ASCII `^_^` (key face / default) and fullwidth `＾_＾` are different tokens.
- Symbols-page `^_^` leaves the letters page; accepting pending on page change still applies, then the same action may start kaomoji on the symbols page.

## Risks

- Screenshot transcription of look-alike glyphs may duplicate or mis-copy a token; Product must correct the PD table before shipping.
- Extracting shared host surgery could regress punctuation; tests for ADR 0029 cycle/replace/space must stay green.
- Wide kaomoji in the 34 pt compact bar may truncate; expand panel is the overflow, not a new geometry.
- Including pending in compact uses one slot; `^_^` stays first even when another face is pending (that other face is selected wherever it sits in the list).

## Follow-up Work

- Independent Architecture review recorded [`Pass`](../../assignments/release-2026-08-01-08-architecture-review.md) `2026-08-23`. Independent Quality Q1 recorded [`Pass with conditions`](../../assignments/release-2026-08-01-08-quality-review.md) the same day. Human Product Gate [`Passed`](../../evidence/release-2026-08-01-08-product-gate-2026-08-24.md) `2026-08-24`. Assignment 08 **Closed** via PR [#80](https://github.com/shchnk1103/Universe-Keyboard/pull/80) merge `54ce3bd`. This does not freeze RC.
- Hand license/copy notes to task 05: first-party literals, not a third-party kaomoji project.
- Human may still correct near-duplicate compact/expanded glyphs in the PD table.

## Related Documents

- [`PD-RELEASE-2026-0801-08-KAOMOJI-CATALOG`](../../product-decisions/RELEASE-2026-0801-08-kaomoji-catalog.md)
- [`0029-t9-pending-punctuation-palette.md`](0029-t9-pending-punctuation-palette.md)
- [`assignments/release-2026-08-01-08-kaomoji-content.md`](../../assignments/release-2026-08-01-08-kaomoji-content.md)
