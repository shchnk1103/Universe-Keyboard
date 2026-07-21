# Input Pipeline And Marked Text

## Purpose

This document defines the current input, marked-text and finalization invariants. It is a regression contract for changes to `KeyboardController`, RIME output handling and `UITextDocumentProxy` integration.

## Pipeline

```text
touch / gesture
  -> KeyboardViewController action
  -> KeyboardController.handle(KeyboardAction)
  -> optional RimeEngine operation
  -> KeyboardState mutation + KeyboardEffect
  -> syncUI(with:)
  -> candidate/layout refresh
```

Business state belongs in `KeyboardState`; UIKit owns presentation state such as accumulated candidate cells, expanded-panel state and press visuals.

## Composition State

The following values are related but not interchangeable:

- `currentComposition`: controller-visible raw composition used for input semantics.
- `RimeOutput.rawInput`: unformatted RIME input used for replay and restore.
- `RimeComposition.preeditText`: display text; it may contain segmentation spaces or confirmed Chinese segments.
- `insertedPreeditText` / `insertedPreeditCount`: text currently represented as marked text in the host field.
- `partialCommit`: confirmed text plus remaining raw composition for reversible partial selection.

Never reconstruct raw input from display preedit.

## T9 Precise Pinyin Path Selection (ADR 0020 + ADR 0021)

When `usesT9InputSemantics` is true:

- `KeyboardAction.selectT9PinyinPath` and `cycleT9PinyinPath` converge on the same composition-refinement transaction via `RimeEngine.replaceInput`. They update marked preedit and Chinese candidates only on a valid refine; they never finalize path letters/digits to the host.
- Failed refine is transactional: restore previous `RimeOutput`, composition, path state and marked text.
- Active T9 composition includes pure digits, pure letters and mixed letter/digit/`'` raw input. Space/Return without candidates and language switch must not host-commit that raw input.
- Host-facing T9 preedit never contains internal ASCII digits. Candidate comments are preferred; fallback preserves only already-explicit letters. Digit/separator-only composition tails are provenance, not display text.
- A single unresolved digit obtains a constant-size ordered choice set from the canonical T9 key identity; longer digit/mixed paths are parsed from compatible Rime candidate comments. Neither source produces or ranks Chinese candidates.
- After a successful single-key refinement, Core retains the issued choices/source and selected path while live RIME output moves from digit to letter. The next cycle validates against that retained snapshot; new input and lifecycle transitions rebuild or clear it.
- UIKit only displays Core state and forwards direct/cycle actions. It must not own the cycle index or reopen the predecessor path panel.
- Successful explicit refinement writes the exact selected path display to marked text after applying live RIME output. Candidate-comment preference remains the default for ordinary T9 output, but does not override explicit path intent. Failed refinement restores the exact previous marked display.
- Path state (`t9PinyinPathState`) clears on final candidate commit, abandon/visibility cleanup, and when T9 composition ends.
- Never reconstruct raw input from the path bar display text.

## Marked-Text Invariants

1. Active Chinese composition is represented with `setMarkedText`, not committed `insertText` calls per key.
2. `updateInlinePreedit` replaces the entire marked range and keeps the selection at its end.
3. Clearing unfinished preedit uses `setMarkedText("", selectedRange: 0..<0)` and clears tracked preedit state.
4. Final committed text must leave no composing underline.
5. If final text exactly equals the current marked text, `commitInlinePreedit` uses `insertText(text)` to replace the marked range. `setMarkedText` followed only by `unmarkText` is not reliable for this equal-content case.
6. If final text differs from marked display text, it replaces the marked range with `setMarkedText(finalText, ...)` and then calls `unmarkText()`.
7. If no marked range is tracked, finalization falls back to `insertText`.
8. Visibility cleanup removes marked preedit and discards unfinished composition; it does not commit it.

## Committed-Text Observation

Typing Intelligence observes final commits at the `KeyboardController` finalization boundary. The observation is downstream of the selected final text and upstream of content-free aggregation.

Invariants:

1. One successful final host commit emits exactly one `CommittedTextEvent`.
2. `updateInlinePreedit`, candidate generation and unfinished composition emit no event.
3. Both `insertText` replacement and `setMarkedText` plus `unmarkText` finalization are covered.
4. No event is emitted when no `TextInputClient` can perform the commit.
5. Emoji and other direct UIKit text route through a KeyboardCore action instead of bypassing the commit boundary.
6. Event text is ephemeral: consumers classify it synchronously and never persist or log it.
7. Observation does not change RIME, candidate, marked-text or visibility semantics.

## Action Semantics

### Post-Commit Continuation

- A successful final host commit updates a separate, process-local continuation state at the same exactly-once boundary as committed-text observation.
- The state retains at most 32 Swift `Character` values and performs only in-memory lookup after its bundled resource has been decoded once.
- Active composition always owns candidate presentation. Starting composition hides continuation items without treating them as RIME candidates.
- Selecting a continuation is a normal final direct-text commit, so it emits once and may produce the next bounded suggestion list.
- Newline, host deletion, English mode, visibility abandonment and disabling the setting clear the state. It is neither reconstructed from host context nor restored after process death.

### Candidate

- Normal RIME candidates must preserve their selection reference/global index.
- Selection is delegated to RIME when possible; returned composition or committed text determines whether the operation is partial or final.
- Final selection commits the complete visible marked range once, clears composition and resets transient correction state.
- Placeholder/composition/correction candidate kinds must not be treated as interchangeable normal RIME references.

### Delete

Priority order:

1. restore an eligible Partial Commit checkpoint;
2. handle number-suffix partial state;
3. ask the active RIME session to delete while it is composing;
4. remove from fallback `currentComposition` and refresh marked preedit;
5. only then call host `deleteBackward()`.

Delete must not remove committed host text while an active composition still owns the key.

### Space

- With active composition, Space commits the first eligible candidate, clears composition and resets the RIME session.
- Without composition, Space inserts a literal space.
- English letters mode may turn a valid double-space sequence into `. `.

### Return

- With active composition, Return commits raw input, not display-oriented segmented preedit or the first Chinese candidate.
- Example: display preedit `ni h`, raw input `nih` -> committed `nih`.
- Without composition, Return inserts `\n`.
- The RIME session is reset after composition finalization.

### Direct Text And Mode Changes

Direct symbols/text first finalize any active composition through the appropriate display/raw-input rule, then insert their own text. Input-mode and visibility transitions must not leave tracked marked text after state has been cleared.

## Partial Commit Invariants

- Partial Commit may leave confirmed Chinese plus remaining composition inside one marked range.
- A clean Delete restore uses the original raw input and may require rebuilding the RIME session; `replaceInput` alone can preserve selected segmentation.
- T9 progressive path selection (ADR 0021 Amendment B) keeps original digit groups and focus state in KeyboardCore while RIME owns live raw/candidates. Compact paths are first-syllable + first-key letters only — never multi-syllable whole labels.
- A **direct path-bar tap** selects and, when remaining digits exist, immediately confirms/advances (syllable-level next set, or letter-group fallback). **选拼音** only first/next/wraps the tentative selection and never confirms a segment by itself.
- Appending a digit after a **tentative** (选拼音) selection preserves the focused selection until a direct path tap confirms/advances.
- Advancing focus prefers live-comment syllables at the next segment index from a bounded path-discovery window; the first 16 ranked candidates are not exhaustive. While compact capacity remains, live-authorized single-letter key-group probes may supplement a non-empty exact-syllable set. Probes restore the prior ambiguous raw before publishing the new focus, and never commit host text.
- Every newly advanced focus publishes with no selected path, including a genuinely single-choice focus. Choice cardinality is display state, never user intent.
- **T9 Partial Commit display:** after selecting a shorter Chinese candidate (e.g. `你好` from `nihaoya` / digits `…92`), host marked text must show comment-preferred remaining preedit (`你好ya`), never remaining raw digits (`你好92`).
- **T9 Partial Commit remaining raw:** when librime keeps the **full** digit raw after partial select, Core peels the unresolved suffix for path/recovery (e.g. `6442692` + remaining display `ya` → remaining raw `92`) so the path bar shows `wa/ya/za` + `w/x/y/z` family choices, not leading-key `m/n/o`. Compact merge prefers first syllables then first-key letters (cap 5).
- **T9 host never shows pure raw digits:** `currentComposition` may track digit raw for recovery, but `activeCompositionDisplayText`, Partial Commit checkpoints (`previousDisplayText`), Delete restore, and fallback delete/rebuild paths must use comment-preferred preedit or the prior host marked snapshot — never push `6442692`-style digit strings into `setMarkedText`.
- **Spaced raw is still raw:** tails such as `748 53` or apostrophe-separated digit runs are normalized to internal digit identity before Partial Commit display/provenance decisions. `toutoumaiqiule → 偷偷买` must align remaining raw/path state to `74853` and expose `qiu`-authorized paths.
- **Visible-character Delete:** without a Partial Commit checkpoint or explicit segmented selection, Delete shortens the exact visible ASCII pinyin via bounded `replaceInput` and preserves that spelling against candidate completion re-ranking (`tou → to → t → empty`).
- In active T9 composition, the `选定` space key still executes normal first/highlighted-candidate finalization. It is not a segment-confirm gesture.
- Continued typing invalidates the single reversible checkpoint according to the current Partial Commit contract.
- Typo correction Partial Commit remains separately gated and must preserve original typo input for restore.

## Required Regression Coverage

- equal preedit/final text clears underline;
- segmented preedit commits raw input on Return;
- Space commits the first candidate exactly once;
- Delete stays composition-first;
- candidate final commit leaves no stale marked text;
- Partial Commit and first-Delete restore preserve raw input;
- visibility changes discard, rather than restore or commit, unfinished input;
- runtime session recovery does not duplicate committed text.
- every final commit path emits exactly once with the approved source category;
- marked-text updates and visibility abandonment emit no committed-text event;
- Emoji uses the same committed-text boundary as other direct text.
- post-commit continuation updates only after successful final commits and clears at every documented invalidation boundary.

## Source Of Truth

- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TextEditing.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+Candidates.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PartialCommit.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift`
- `Keyboard/Services/UITextDocumentProxyAdapter.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/TypingIntelligence.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/PostCommitContinuation.swift`

### T9 可见输入边界（Amendments E/F/G）

- 普通九宫格按键先进入 RIME，但 host marked text 只投影用户已输入的槽位；`8 / 86 / 868` 分别显示 `t / to / tou`，预测的额外字母留在候选层。
- Path Bar 显式选择是更高优先级的用户事实；确认 `qiu` 后显示只到 `qiu`，session raw 以 `qiu' + 剩余数字` 维持候选连续性。
- 后续完整音节必须由有界 live-RIME probe 授权；内部数字、未确认预测和不继承确认前缀的 comment 均不得进入 marked text。
