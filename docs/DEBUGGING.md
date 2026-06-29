# Debugging Guide

## First Principle

Classify the failure before changing code. Record the input, current page/mode, active schema, deployment state, lifecycle transition, expected result and actual result. Do not infer a root cause from UI symptoms alone.

## First Triage

| Symptom | First boundary to inspect |
|---|---|
| keyboard does not appear or has wrong height | Extension lifecycle/layout |
| key tap stalls | main-thread/UI hot path, synchronous storage or RIME call |
| raw pinyin/candidate mismatch | KeyboardCore state vs RIME output |
| empty/stale candidates | candidate snapshot/paging vs RIME session |
| works after returning to App | deployment/shared-container state |
| works until app switch | visibility cleanup or session lifecycle |
| Lua feature missing | compiled capability -> files/schema -> deployment -> smoke result |
| simplification wrong | setting/custom YAML -> deployment -> OpenCC assets/filter |
| settings differ between App and keyboard | App Group access, cached settings and notification refresh |

## Evidence To Capture

- commit and build configuration;
- device/simulator model and OS version;
- host application and input-field type;
- active schema and whether it was freshly deployed;
- exact keystrokes and lifecycle actions;
- relevant diagnostic categories and timestamps;
- whether Full Access is enabled;
- whether the issue reproduces after a clean main-App redeploy.

Do not log surrounding host text, passwords, arbitrary user content or full private sentences. Use synthetic inputs such as `nihao` when reproducing.

## Diagnostic Logs

The shared logger persists a bounded FIFO log in App Group `UserDefaults` under `rime_diag_log`; the main App diagnostics screen reads and clears it. Logging is asynchronous, but hot-path logging must remain selective.

Useful categories:

- general/lifecycle: presentation and settings refresh;
- engine: session creation, schema selection and recovery;
- config/deployment: file preparation, deploy state and OpenCC/Lua setup;
- display: layout, candidate presentation and scrolling;
- performance: initialization and key/UI durations.

Always correlate a failure with its immediately preceding lifecycle/deployment event instead of reading isolated lines.

## Troubleshooting Flows

### Keyboard Has No Real RIME Candidates

1. Confirm `Rime/shared` and `Rime/user` exist by opening the main App deployment status.
2. Confirm the desired schema is installed and active.
3. Check `rime_deployed`, `rime_needs_deploy` and deployment diagnostics.
4. Redeploy from the main App.
5. Reopen the keyboard so a fresh process/session reads prepared runtime data.
6. If directories are missing, fallback behavior is expected; do not add deployment to the Extension.
7. If directories exist but every schema fails, inspect schema validation logs and reinstall from the main App.

### Candidates Freeze Or Become Stale

1. Determine whether `currentComposition` and `RimeOutput.rawInput` still match the typed sequence.
2. Check for a visibility change or ignored printable key immediately before the failure.
3. Check session recovery logs.
4. Distinguish RIME output from UI accumulation: candidate snapshot generation/global index must reset when composition changes.
5. Verify candidate selection references are present only for normal RIME candidates.

### Composing Underline Remains Or Text Duplicates

1. Record `insertedPreeditText`, final text and whether they are equal.
2. Trace the call through `commitInlinePreedit`.
3. Equal text must take the `insertText` replacement path.
4. Different text must use `setMarkedText` then `unmarkText`.
5. Verify state is cleared exactly once and the RIME session is not replaying already committed input.
6. Run the marked-text and Return regression tests before changing UIKit code.

### Return, Space Or Delete Is Wrong

- Return with composition: commits raw input.
- Space with composition: commits first candidate.
- Delete with composition: edits composition before host text.
- First Delete after eligible Partial Commit: may restore the checkpoint.

If behavior differs, start in `KeyboardController+TextEditing.swift` and `KeyboardController+PartialCommit.swift`, not the key-button handler.

### Works Until App Switch

Visibility changes intentionally abandon unfinished composition. If old input reappears, the cleanup contract is broken. If completed text disappears, investigate host marked-range finalization before visibility cleanup. Do not implement composition restoration without a new product/architecture decision.

### Lua Feature Missing

Check in order:

1. binary compiled with Lua;
2. Lua module/components registered;
3. active schema is `rime_ice` and contains Lua references;
4. referenced scripts and required dependencies exist;
5. advanced-input settings allow the component;
6. full deployment succeeded after the latest change;
7. runtime smoke result and RIME runtime log.

### Simplified/Traditional Conversion Wrong

Current integration ownership and boundaries are defined in
[`architecture/opencc-integration.md`](architecture/opencc-integration.md). This section owns only the diagnostic flow.

1. Check `rime_simplification` in App Group settings.
2. Confirm custom YAML was regenerated.
3. Confirm full deployment succeeded.
4. Confirm `shared/opencc` configs and `.ocd2` assets exist.
5. Confirm the active schema includes the simplifier filter and correct option.

## Crash, Performance And Memory

The repository does not yet define production budgets. Until that work exists:

- capture the Extension crash/jetsam report and symbolicate against the exact archive;
- reproduce with the same host app and lifecycle sequence;
- inspect main-thread stacks for synchronous file, hashing, network or deployment work;
- compare `viewDidLoad`, engine initialization and `syncUI` performance logs;
- inspect candidate cell-size caches, accumulated candidates, audio players and RIME session lifetime for growth;
- use Xcode Memory Graph/Instruments evidence before claiming a retain cycle or leak.

Absence of a documented budget is not evidence that a measured delay or memory level is acceptable.

Use `docs/PERFORMANCE_BASELINE.md` for the required measurement fields and scenarios. Numeric budgets may be added only after reviewed real-device evidence exists.

## Verification Commands

Use the canonical commands in `docs/RELEASE_CHECKLIST.md`. A named simulator is required only for actually running tests; discover an installed destination instead of copying a stale device name into permanent docs.
