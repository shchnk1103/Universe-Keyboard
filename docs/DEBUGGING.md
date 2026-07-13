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

### Typing Intelligence Is Empty, Duplicated Or Returns After Clear

1. Confirm `typing_intelligence_enabled` is true in the App Group and that the Extension refreshed its cached settings.
2. Verify the action reaches a final `KeyboardController` commit exit. Marked-text updates and unfinished composition must not count.
3. Check the exactly-once event tests before changing candidate or RIME code.
4. Confirm the Extension callback converts `CommittedTextEvent.text` directly to `TypingStatisticsDelta`; never add text logging to diagnose this path.
5. Confirm `typing_intelligence_reset_epoch` matches the persisted snapshot and the Extension's current cached epoch.
6. If data reappears after clear, treat it as a reset-epoch race and stop release; do not mask it in the UI.
7. If the snapshot is corrupt or a future version is unsupported, the main App shows an empty safe state. Preserve the corrupt payload only in a synthetic test, never copy real keyboard data into an issue.
8. Without writable App Group access, basic typing remains functional and statistics may be unavailable. Do not infer a reliable live Full Access flag from the main App alone.

Useful keys contain only controls or aggregates:

- `typing_intelligence_enabled`
- `typing_intelligence_reset_epoch`
- `typing_intelligence_snapshot_v1`

The snapshot must never contain committed text, candidates, raw input, host identity or per-commit timestamps.

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

### RIME Settings Sync Fails Or Repeats

1. Confirm the failure is in the main App. The Keyboard Extension never performs network, private sync or RIME standard sync work.
2. For WebDAV, verify the URL is HTTPS, credentials have read/write/create/delete permission and the service supports `GET`, `PUT`, `MKCOL`, `DELETE` and conditional requests.
3. HTTP 401/403 is an authentication or permission failure; 412 is a concurrent-write conflict and should be retried from a fresh `GET`; 507 is remote storage exhaustion.
4. For local-folder sync, first confirm diagnostics contains the non-sensitive `rimeSync folder selection` outcome. `preflight.coordinate` / `preflight.write` / `preflight.read` / `preflight.delete` identify the failed access stage; `bookmark` means the directory was accessible but its persistent authorization could not be saved. A failed selection pauses sync rather than falling back to the previous directory; reselect the folder and retry. Both paths use `NSFileCoordinator` and the file provider's coordinated URL.
5. “数据损坏或密钥不匹配” is fail-closed authenticated-decryption behavior. Verify the recovery code; never bypass authentication or replace remote data automatically.
6. Inspect `universe-rime-sync/format.json` and the existence/size of `profiles/default/settings.json`, but do not paste decrypted user settings or credentials into logs.
7. If upload succeeds but keyboard behavior is unchanged, inspect the normal RIME deployment state separately. Remote persistence and local deployment are distinct operations.
8. If two devices change the same field offline, the larger logical version and then device ID wins deterministically. Different fields should both survive.
9. “立即同步” only runs standard user-data sync after explicit confirmation with a local/file-provider folder. Confirm the keyboard is not being used, then verify `Rime/user/installation.yaml` points to the selected `sync_dir`.
10. Standard sync merges `*.userdb.txt` snapshots and backs up YAML/TXT per device. It does not copy live `*.userdb*`, auto-import another device's YAML, or sync a complete schema installation.
11. User dictionaries and custom YAML are intentionally absent from the encrypted `universe-rime-sync` package; their absence from that package is not a failure when standard RIME sync is configured.
12. For automatic standard sync, first confirm an initial manual standard sync succeeded. Then check `rimeSync automatic background task scheduled` and the result logs. `keyboardActive=true` means the App intentionally skipped the run; folder-access failure pauses sync and requires reselecting the folder. iOS can delay a background task, so a missing run at the earliest time is not by itself a product failure.

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
