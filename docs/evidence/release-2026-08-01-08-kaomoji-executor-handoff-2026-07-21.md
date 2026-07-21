# RELEASE-2026-0801-08 Executor Handoff — 2026-07-21

**Task:** [`RELEASE-2026-0801-08`](../assignments/release-2026-08-01-08-kaomoji-content.md)

**Evidence class:** Executor implementation and environment observation; **not** an independent Quality conclusion or Product Gate

**Source branch:** `codex/release-2026-0801-kaomoji` (uncommitted implementation snapshot at capture time)
**Date / timezone:** `2026-07-21 Asia/Shanghai`

## Delivered Boundary

- 48 self-built, bundled and offline kaomoji: four categories of 12 entries (`常用`、`开心`、`互动`、`情绪`).
- Existing nine-key and symbol-page `^_^` controls open the same in-memory catalog.
- Selecting an entry uses the existing `insertDirectText` final-commit path; no RIME deployment, network, synchronization, persistence, recent-history, account, analytics or user content was added.

## Automated Build Evidence

1. `bash scripts/ensure_rime_vendor.sh verify` from the main checkout: passed structural inventory of 11 pinned RIME framework artifacts.
2. Copied those already verified local artifacts into the isolated worktree only for build resolution.
3. Unsigned Simulator Debug build passed:

   ```text
   xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" \
     -configuration Debug -destination 'generic/platform=iOS Simulator' \
     CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
     SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
   ```

4. Signed physical-device Debug build passed for `2913D287-F9B7-5B66-A596-849CE820D328`.

## Physical iPad Observation

- **Device:** DoubleShy 0.0 — iPad Pro (11-inch, 3rd generation), identifier `2913D287-F9B7-5B66-A596-849CE820D328`
- **OS:** iPadOS 27.0
- **Method:** Device Hub; installed and launched the signed Debug App built from this branch, then used Notes as the host text field.
- **Observed pass:** Chinese nine-key `^_^` opened the bundled catalog; selecting `^_^` inserted exactly `^_^` after existing host text; tapping `开心` replaced the grid with that category; `返回` restored the nine-key keyboard.
- **Large text observation:** Device Hub Text Size `3 -> 7` retained all category controls and visible grid content; Text Size was restored to `3` immediately afterward.
- **Not executed:** VoiceOver speech/focus traversal, dark appearance, iPhone device check, Full Access-off behavior and final Product Gate. The source sets semantic labels/hints, but source inspection is not a VoiceOver runtime pass.

## Test Result Requiring Independent Triage

The full physical-device test command completed with failure. It is not treated as a kaomoji pass or as unrelated-success evidence:

```text
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" \
  -destination 'platform=iOS,id=2913D287-F9B7-5B66-A596-849CE820D328' \
  CODE_SIGNING_ALLOWED=YES SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
```

- `121` tests executed; `5` failures.
- Reported failing names: `RimeSettingsStoreTests.testAutoBackupRunsForChangedLearningDataWhenEnabled()` and `RimeSettingsStoreTests.testSaveFuzzyPinyinSettingsSkipsDeployWhenSignatureAlreadyMatches()`.
- The failure output concerns RIME settings/deployment expectations, not the kaomoji files or interaction path. That is an observation, not a root-cause or waiver. `KeyboardTests` was skipped because tool-hosted testing is unavailable on physical-device destinations.
- Result bundle: `/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-dqqfawrpuzzfnpbyypseqvlmpaii/Logs/Test/Test-Universe Keyboard-2026.07.21_15-23-47-+0800.xcresult`

## Reviewer Handoff

Quality Reviewer must independently decide whether the five failures predate this branch, reproduce on the release baseline and block the release/task. Product Lead must separately decide any accepted risk. This Executor makes neither conclusion.
