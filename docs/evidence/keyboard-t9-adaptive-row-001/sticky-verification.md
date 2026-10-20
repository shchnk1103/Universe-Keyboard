# UI-2 Sticky Expansion — bounded correction

Current policy supersedes per-composition collapse in the original verification.md. Same task KEYBOARD-T9-ADAPTIVE-ROW-001, Writer codex-t9-adaptive-row, branch/worktree unchanged. Prior product5cc4a74 and checkpoint2b59617 preserved. Implementation complete, Runtime validation pending; no independent Gate or product publication.

## Minimal implementation

Only two production files changed in this correction: KeyboardViewController.swift and +T9PinyinPath.swift. Controller owns two nonpersistent UI flags: expanded-in-presentation and observed-ended-presentation. First existing coherent composition/Path/source/raw/preedit/Partial Commit/Recovery signal latches expansion. Candidates alone and no-input refresh do not. The snapshot predicate remains presentation-only; no RIME/input/authority state is altered.

Once latched, empty snapshots, candidate commit output, delete-to-empty, temporary-empty Paths, Recovery refresh, reload, ordinary appearance, document/proxy callbacks and page/layout changes never clear it. Non-T9 surfaces have no Path row and retain their ordinary256 target; returning to T9 in the same cycle immediately uses34/290, without an intermediate T9 compact state. Candidate container stays48pt, keys/spacing unchanged. Single750 constraint, idempotent update, deferred installation, clear root, Path interaction and original panel remain unchanged from the reviewed local foundation. No timers, debounce, persistence or new notifications.

## Lifecycle evidence and conservative fallback

Existing hostLifecycleRecoveryGate.noteViewWillAppear increments generation on every call, so generation alone is not proof of a new Sticky cycle. DocumentChanges rebinds/abandons input based on proxy identity; that is not proof of keyboard disappearance either. No change is made to those reliability mechanisms.

Production wiring: viewDidDisappear calls noteT9PinyinPresentationDidDisappear; it records an ended cycle only if the existing gate is hidden (its existing viewWillDisappear path ran) AND the view is detached from its window. The next viewWillAppear, after existing shared-resume handling and before existing UI installation, consumes this pending end once while the gate is appearing. It clears only the UI latch and reapplies the existing snapshot/safety signals; ongoing composition/Partial Commit/Recovery immediately keeps34pt. Repeated willAppear without a qualified completed end never resets.

This is a sufficient conservative boundary policy, NOT proof of every iOS keyboard wake event. If a real Extension keeps its view attached through disappearance, omits/compresses the callback sequence, or only produces host-active/proxy notifications, the implementation retains the latch across that ambiguous boundary. It does not guess a reset. Process recreation naturally starts with unset flags; process reuse supports a new cycle when the qualified pair is observed. Whether real host switching, dismissal/reopening, globe switching and app background/foreground deliver that pair requires Runtime Gate.

## Tests and actual outcomes

Dedicated task-owned iPhone17Pro/iOS26.5 device5DEEF120-CB85-47BB-A690-303613DD85EC; same isolated DerivedData/private tmp directories. No GUI activation attempt or shared simulator operation. New raw root: `/private/tmp/t9-adaptive-row-001-sticky`.

Commands reuse the original documented Debug xcodebuild flags: Universe Keyboard scheme, explicit device UDID, isolated DerivedData, CODE_SIGNING_ALLOWED=NO, Swift6/complete, visible warnings/as-errors. L1 filter KeyboardLayoutIntegrationTests; L2 filters KeyboardTests and KeyboardExtensionTests. All exit receipts follow process completion.

| Check | Pass / failure / skip | Artifacts in new raw root |
|---|---|---|
| Final real Controller / UIKit L1 | 5 / 0 / 0 | l1-final.log/.exit/.xcresult |
| KeyboardTests L2 | 49 / 0 / 0 | l2.log/.exit/.xcresult |
| KeyboardExtensionTests L2 | 35 / 0 / 0 | same run |
| Debug build-for-testing | Pass, exit0 | debug-build-for-testing.log/.exit/.xcresult |
| Strict Swift format/lint, all8 changed files vs main | Pass, exit0 | strict-format.log/.exit |

Initial Sticky L1 also5/0/0; final run adds no-input refresh, normal Partial Commit and actual didDisappear-hook invocation. No failed test/skip in this correction. Original earlier failed trial logs remain untouched.

Widths320/390/430: initial Path0/root256; first nonempty T9 raw Path34/root290; sequence2→empty→6→64→empty→2→empty stays290. Empty presentation snapshot after selection likewise stays34; repeated refresh preserves constraint identity, candidate/key object identities and geometry. Candidate48, first normal key45 and bottom45, relative candidate/key offsets remain fixed. Numeric/symbol/emoji/QWERTY surfaces have no additional row; returning nine-key restores sticky34. Waiting/terminal Recovery, failed Partial Commit disable/notice and normal Partial Commit safety signals retain34; clearing safety state does not collapse. Expanded candidate overlay continues to fill root and restores correct key/candidate frames. Production Path view selected Cell and selector delivery remain covered; collapsed view has no residual hit/AX.

The new lifecycle test supplies explicit existing gate transitions and calls the production didDisappear hook with a detached view; it invokes the production begin policy after the next gate appearance. It verifies reset256 on that qualified pair, no reset for duplicate appear / wrong-phase disappearance / attached view, and immediate safety expansion on a new cycle. It does not execute engine/bootstrap or claim native callback ordering. No-input function-key behavior is represented by unchanged/empty presentation inputs, not a system touch event. Candidate commit/delete tests feed resulting presentation states; they do not re-prove Core semantics or actual native candidate selection.

Final L1/L2 logs contain no new required Auto Layout conflict diagnostic (`Unable to simultaneously satisfy constraints` absent). Existing hostless needsInputModeSwitchKey and build-tool SDK/AppIntents warnings retain their documented environment boundary. Geometry assumes the caller honors requested root height; no screen-coordinate or system animation proof.

## Review / remaining Runtime Gate

Local correction is ready for read-only independent Claude review; no independent Architecture/Quality Pass. Needed native proof: which real disappearance/wake paths satisfy the qualified pair, compact start on those paths, conservative carry-over on ambiguous paths, real host height-request timing, screen coordinates/flicker, native input/delete/retype/commit, Recovery and VoiceOver/touches. UI-1 PR216 remains isolated, candidate46 integration not included. L3/full Core/App/Bridge/Release/hosted CI not run under this bounded policy correction.

Source/critical-boundary/raw-log hashes are recorded in sticky-manifest.json. Only local product/checkpoint commits permitted; remote carrier remains initial f2f20a8 with KOS docs only. No HANDOFF/ACCEPT; W remains codex-t9-adaptive-row, P=none. Stop for Human.
