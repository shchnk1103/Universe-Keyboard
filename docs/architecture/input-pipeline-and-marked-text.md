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
