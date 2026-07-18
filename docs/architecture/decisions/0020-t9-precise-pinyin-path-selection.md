# ADR 0020: T9 Precise Pinyin Path Selection

## Status

Accepted for implementation under Assignment `KEYBOARD-LAYOUT-9KEY-PINYIN-001` after real librime Spike **PASSED** (`2026-07-18 Asia/Shanghai`, local evidence `evidence/keyboard-layout-9key-pinyin-spike/20260718-201043/`). Architecture Codex review remains required before Product Gate / `Closed`.

This ADR **extends** [ADR 0018](0018-keyboard-layout-nine-key-and-t9-runtime.md). It does not replace layout/readiness/deployment decisions in ADR 0018.

### Spike facts (pinned librime 1.16.1, schema `t9`)

- `replaceInput("o")` / `replaceInput("ni")` set raw input, keep candidates, produce **no** `committedText`.
- After `64 → ni`, continuing digit yields mixed raw `ni4`; BackSpace reduces to `ni`.
- Path comments observed: after `6` at least `o` (top window may not list all of `m/n/o` — compact bar must scan windows and fail closed when sparse); after `64` at least `ni|mi`.
- No schema/vendor upgrade required beyond existing `t9_processor` removal.

## Context

Chinese nine-key V1 ships digit algebra on schema `t9` with unconditional no-raw-digit host commit (ADR 0018). Chrome exposes **选拼音** as a placeholder (`KEYBOARD-LAYOUT-9KEY-UI-001`). Product Decision `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-001` requires a precise pinyin path bar and panel so users can refine the current composition before committing Chinese candidates.

Without an explicit contract:

- Host paths might treat refined letter raw input (`ni`, `ni4`) as ordinary 26-key composition and leak raw text via Space/Return.
- UI might invent a parallel pinyin table that drifts from Rime comments.
- Extension might be tempted to patch schema or upgrade librime to force multi-tap UX.

Product requires proof on the **pinned** librime that session `replaceInput` can refine digit compositions into letter or mixed letter/digit/separator raw input without host commit, and that candidate **comments** can supply path strings.

## Decision

### 1. Composition refinement, not candidate commit

Selecting a precise pinyin path is **composition refinement**:

- Call the existing session API `RimeEngine.replaceInput(_:)` with a validated replacement raw string (for example `m` or `ni'hao`).
- Update KeyboardCore composition state and host **marked text** only when the engine returns a usable refined composition.
- Never insert path letters, digits, or separators into the host document as committed text.
- On engine rejection or empty invalid result: restore the previous `RimeOutput` / marked text (transactional update).

This is distinct from `selectCandidate` / final commit.

### 2. Mixed T9 raw input is a first-class composition form

While `usesT9InputSemantics == true`, an active T9 composition is any **non-empty** raw input whose characters are only:

- ASCII letters `a`–`z` / `A`–`Z` (normalized to lowercase for path keys);
- decimal digits `0`–`9`;
- pinyin separators space and `'` (apostrophe).

Digit-only raw input remains the common case after key taps. After path selection, raw input may be pure letters or mixed (for example `ni4`).

**Host commit policy extension of ADR 0018 §7:**

Replace “digit-only composition” as the sole T9-active predicate with **valid T9 composition** above. While a valid T9 composition is active:

| Action | Candidates | Required behavior |
|---|---|---|
| Space | yes | Commit highlighted/first **Chinese candidate text** |
| Space | no | Keep composition; **no** host commit of raw input |
| Return | yes | Commit highlighted/first candidate text |
| Return | no | Keep composition; **no** host commit of raw input; no newline |
| English / auto-English | any | Abandon composition; **no** host commit of raw input |
| Page/lifecycle abandon | any | Existing abandon; **no** implicit raw commit |

Display preedit may still prefer candidate comments, then raw input for **display only**.

### 3. Path provenance is Rime candidate comments

- Path candidates are derived by scanning `RimeEngine.candidateWindow(from:limit:)` (and/or current page candidates) and parsing each candidate’s `comment`.
- KeyboardCore owns parsing, validation, ranking, dedupe, and window pagination state.
- UIKit must not invent or re-rank paths independently of KeyboardCore.
- Accepted comment shapes: ASCII pinyin letters, spaces, and `'`. Normalize to lowercase; collapse runs of whitespace to a single `'` for `replacementRawInput`; `displayText` may show spaces for readability (for example `ni hao` display vs `ni'hao` replace).
- Reject empty comments, emoji/decorative comments, and paths incompatible with the current raw input (validation rules owned by KeyboardCore pure logic).
- Compact bar shows at most 4 deduplicated paths in first-seen Rime order. Expanded panel lazily advances the global candidate index.
- Missing/unparseable comments: fail closed to ordinary nine-key Chinese candidates only — no guessed paths, no raw commit.
- **Current-comment-only authorization:** a path is selectable only when its `replacementRawInput` was issued under the **current** comment provenance revision. Compatibility with raw digit slots is necessary but not sufficient — keys from an older comment snapshot must not remain authorized after a new RimeOutput changes candidates/comments.

### 4. No RimeEngine protocol expansion for V1

Reuse existing `replaceInput` and `candidateWindow`. Do not add a second candidate engine, offline pinyin graph, or schema-side “select pinyin” processor for this feature.

### 5. Session-only Extension boundary (unchanged ownership)

- Extension and KeyboardCore only mutate the **current RIME session**.
- Main App remains the only writer of deploy/readiness/schema artifacts (ADR 0001 / 0018).
- No librime vendor upgrade is authorized by this ADR.
- No main-App settings toggle for V1; feature is on whenever Chinese nine-key runtime is usable.

### 6. State ownership

KeyboardCore owns:

- `T9PinyinPath` (`displayText`, `replacementRawInput`)
- `T9PinyinPathState`, including two independent revision counters:
  - **`rawInputGeneration`**: bumped when tracked raw-input identity changes; stable for the same raw lifecycle.
  - **`provenanceRevision`**: bumped when live comment/window authority changes (new RimeOutput apply, usable rollback rebuild, page rebuild, or explicit hard provenance). Independent of raw identity so same-raw comment re-rank still invalidates stale issued keys and UIKit panel tokens.
- `issuedReplacementKeys` for the **current** `provenanceRevision` only (comment provenance; selection authorization)
- `T9PinyinPathWindow` (deduped paths, next global index, hasMore, carries both revisions)
- `KeyboardAction.selectT9PinyinPath`
- `KeyboardEffect.t9PinyinPathsChanged` (or equivalent effect bit)
- Clearing/rebuilding path state on delete, abandon, page switch, final candidate commit, and session recovery

**Apply vs soft refresh boundary:**

- Installing a **new** `RimeOutput` (key input, partial candidate selection remaining composition, path refine, recovery) must open a new provenance revision and rebuild issued keys from the live scan only — even when raw is unchanged.
- Soft same-snapshot refresh (UI / expanded-window re-scan of the already stored output) may keep expanded issued keys still compatible with current raw and must **not** bump `provenanceRevision`.

Keyboard Experience owns fixed-height path bar chrome, panel mutual exclusion with candidate expansion, and VoiceOver labels, under product geometry constraints (34 pt reservation). Expanded panel, lazy windows, and click stale guards bind to **`provenanceRevision`**, not only `rawInputGeneration`.

### 7. Spike gate

Product UI and mixed-input policy productization require a real Spike on pinned librime + compatible `t9` proving:

1. Digit input yields path-usable comments (record actual comments if they differ from `m/n/o` expectations).
2. `replaceInput(letterPath)` changes raw input, keeps composition/candidates, produces **no** `committedText`.
3. Multi-key refine (for example `64` → `ni`) narrows candidates; further digits may form mixed raw input.
4. Delete, paging, and empty-candidate Space/Return engine outputs do not force host raw commits (policy enforced in KeyboardCore).
5. No schema or vendor change beyond the existing `t9_processor` removal compatibility patch.

Spike failure is a **Stop Condition**: return to Architecture; do not ship UI simulation of refinement.

## Alternatives Considered

- **UI multi-tap letter buffer without Rime `replaceInput`:** rejected; diverges from session raw input used for delete/recovery.
- **Parallel offline pinyin path table:** rejected; drifts from schema/dict comments and creates a second engine.
- **Upgrade librime / reintroduce `t9_processor` for multi-tap:** rejected by Product Decision non-goals unless Spike proves current stack impossible.
- **Keep digit-only T9 commit policy after letter refine:** rejected; refined `ni`/`ni4` would fall through to 26-key Space/Return and risk raw host commit.
- **Store selected path only in UIKit:** rejected; violates KeyboardCore ownership and recovery invariants.

## Consequences

- `T9CompositionCommitPolicy` must treat mixed/letter T9 compositions as T9-active.
- Typo correction must continue to ignore active T9 compositions including mixed raw input.
- Candidate expansion and pinyin path expansion are mutually exclusive presentation modes.
- Domain docs (`KEYBOARD_LAYOUT.md`, input pipeline, UI guide, release checklist) must document path-bar height, refinement semantics, and mixed raw-input invariants after implementation.
- Architecture review remains required before Product Gate closure even if Spike passes.

## Risks

- Some candidate comments may be empty or non-pinyin; compact bar may be empty while Chinese candidates remain — fail closed is correct but UX may feel sparse until more keys are typed.
- `replaceInput` may reset highlight/page state; UI must refresh from engine output, not stale windows.
- Lazy full-path scanning could be costly if limits are unbounded; windows must stay bounded and dual-revision-guarded (`rawInputGeneration` for raw lifecycle, `provenanceRevision` for comment authority).

## Follow-up Work

- Complete Spike evidence archive under Assignment `KEYBOARD-LAYOUT-9KEY-PINYIN-001`.
- Implement KeyboardCore models/actions/invariants and unit tests.
- Implement Extension path bar and 选拼音 panel.
- Update operational docs and CHANGELOG after behavior lands.
- Codex Architecture/Quality review; physical-device Product Gate.

## Related Documents

- `docs/product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-001-authorization.md`
- `docs/assignments/keyboard-layout-9key-pinyin-001.md`
- `docs/plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md`
- `docs/KEYBOARD_LAYOUT.md`
- ADR 0018, ADR 0001, ADR 0002, ADR 0004
