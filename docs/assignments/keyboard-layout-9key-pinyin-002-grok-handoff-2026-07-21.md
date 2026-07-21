# KEYBOARD-LAYOUT-9KEY-PINYIN-002 — Grok continuation handoff

Date: 2026-07-21  
Branch: `main`  
Worktree: dirty; all existing changes belong to the user and must be preserved  
KOS phase: Amendment H implementation / verification  
Handoff target: Grok acting as KeyboardCore Implementer first, then independent Quality reviewer  
Product Gate owner: Human Product Owner (the user)

## 1. Required reading and authority

Read in order before editing:

1. `AGENTS.md`
2. `docs/KNOWLEDGE_INDEX.md`
3. `docs/READING_MAPS.md`
4. `docs/PROJECT_CONTEXT.md`
5. `docs/ASSIGNMENT_POLICY.md`
6. `docs/assignments/keyboard-layout-9key-pinyin-002.md`
7. `docs/product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md`
8. `docs/architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md`
9. this handoff

Do not stage, commit, push, reset, discard or rewrite unrelated dirty changes unless the user separately authorizes it.

## 2. User-visible acceptance contract

Given T9 input `toutoumaiqiule`:

1. Select candidate `偷偷买`.
2. Path Bar select `qiu`:
   - marked text must be `偷偷买qiule`;
   - only the corresponding first remaining segment changes;
   - RIME candidates must stay on the `qiu` branch;
   - next Path Bar must retain full `le` when live RIME authorizes it.
3. If Path Bar selects `shu` instead:
   - marked text must be `偷偷买shule`.
4. From `偷偷买qiule`, select candidate `球`; visible composition is conceptually `偷偷买球le`.
5. First Delete:
   - undo `球` back to `qiu`;
   - marked text must return to `偷偷买qiule`;
   - no internal digit may appear.
6. Second Delete:
   - delete the first letter of the currently unresolved segment, `l`;
   - marked text must become `偷偷买qiue`;
   - internal raw should refine from `qiu'53` to `qiu'3`;
   - no internal digit may appear.

Global invariant: ASCII T9 digits are internal engine identity and must never be written to host marked text, including mixed forms such as `qiu5`.

## 3. Root causes found

### H1 — Path selection truncated the suffix

`applySelectedT9PinyinPathDisplay` and `applyConfirmedT9PinyinPrefixDisplay` rebuilt marked text from only the selected/confirmed prefix. After RIME re-ranked `qiu'53` as comment `qiu ke`, the earlier user-visible `le` was also lost or replaced by `ke`.

Implemented direction: snapshot the pre-refinement visible remainder before `replaceInput`; replace only the consumed slots and copy the unresolved trailing user-visible slots. Candidate predictions do not own that suffix.

### H2 — Nested candidate Delete could expose mixed raw

`restorePartialCommitCheckpoint` restored the prior host snapshot only when the rebuilt remainder was digit-only. Mixed preedit such as `qiu5` bypassed that condition. It also rebuilt from visible `qiule` instead of reusing the already explicit anchored raw `qiu'53`.

Implemented direction: explicit letter/apostrophe raw is authoritative for checkpoint restore; a safe prior host snapshot is restored exactly; any T9 preedit containing even one ASCII digit is sanitized/fail-closed.

### H3 — Second Delete targeted the raw tail

Generic `engine.deleteBackward()` removes the final raw slot (`3` / visible `e`). Product requires Delete at the active unresolved Path Bar focus to remove its first slot (`5` / visible `l`).

Implemented direction: for a checkpoint-free partial composition with apostrophe-anchored raw, exact-refine `qiu'53 → qiu'3`, remove the visible letter at the confirmed-prefix boundary, and preserve/rollback the complete state transactionally.

## 4. Files changed for Amendment H

- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`
  - preserves unresolved visible suffix across selected and confirmed Path Bar transitions;
  - carries the pre-RIME visible snapshot through re-ranking.
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PartialCommit.swift`
  - preserves refined raw such as `qiu'53` / `shu'53`;
  - restores safe nested checkpoint display exactly;
  - rejects all mixed digit-bearing T9 preedit from host display.
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TextEditing.swift`
  - adds active-focus Delete for anchored raw (`qiu'53 → qiu'3`, `qiule → qiue`).
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/PartialCommitControllerTests.swift`
  - extends qiu rerank regression through candidate `球` and two Deletes;
  - adds the `shu → shule` branch regression.

## 5. Evidence and exact verification state

Red evidence before implementation:

- qiu selection produced `偷偷买qiu`, failing expected `偷偷买qiule`.
- candidate undo did not restore anchored `qiu'53` and safe `qiule` display.
- second Delete returned the wrong raw/display instead of `qiu'3` / `qiue`.

Green evidence already obtained:

- After suffix/checkpoint/mixed-digit changes, focused qiu test including both Deletes passed `1/1`.
- Before the final refined-raw preservation patch, combined qiu/shu run had:
  - qiu: PASS;
  - shu: display `偷偷买shule` and confirmed `shu` passed, but state raw remained old `74853` instead of `shu'53`.

Last patch not yet executed due Codex execution-credit limit:

- `installPartialCommitPresentation` now treats any T9 raw containing ASCII letters as authoritative, so `shu'53` and `qiu'53` cannot be replaced by an older pure-digit identity.
- `git diff --check` passes after this patch.
- Compilation and tests must be rerun; do not claim final PASS from this handoff alone.

## 6. Commands Grok must run next

Run in `/Users/doubleshy0n/Dev/Universe Keyboard`:

```bash
swift test --package-path Packages/KeyboardCore --filter PartialCommitControllerTests/testT9PartialCommitSelecting
swift test --package-path Packages/KeyboardCore --filter T9PinyinPathTests
swift test --package-path Packages/KeyboardCore --filter KeyboardLayoutAndT9RuntimeTests
swift test --package-path Packages/KeyboardCore
git diff --check
git status --short
git diff --stat
```

Expected focused assertions:

- `qiu'53`, `偷偷买qiule`;
- candidate `球`, first Delete back to `qiu'53` / `偷偷买qiule`;
- second Delete to `qiu'3` / `偷偷买qiue`;
- `shu'53` / `偷偷买shule`;
- no marked text contains a digit.

If any focused test fails, inspect the first failure and fix only this Amendment H path. Do not weaken assertions, delete provenance guards, add a static pinyin engine, or expose raw digits.

## 7. Human Product Gate

After all automated tests pass, build/install the latest Debug app to the connected iPhone 13 Pro. Do not use Device Hub `Capture Keyboard`. Ask the user to test manually and report these exact checkpoints:

1. `偷偷买` → Path Bar `qiu`: is the input exactly `偷偷买qiule`?
2. Repeat with Path Bar `shu`: is it exactly `偷偷买shule`?
3. `偷偷买qiule` → candidate `球` → Delete once: is it back to `偷偷买qiule`, with no digit?
4. Delete again: is it `偷偷买qiue`, with `l` removed and no digit?
5. Are candidates after `qiu` still in the qiu branch and does Path Bar still offer full `le`?

Record device, iOS, build identity and the user's result in the independent-quality evidence. Product Gate remains Pending until the user confirms all rows.

## 8. Stop conditions

Stop and return to Product Lead if:

- real RIME cannot exact-realize anchored raw after rebuild;
- satisfying the behavior would require schema/Vendor/deployment changes;
- a fix requires a second candidate engine or static pinyin graph;
- any required Assignment field becomes `UNKNOWN`;
- unrelated dirty changes overlap the same lines and ownership cannot be resolved safely.

