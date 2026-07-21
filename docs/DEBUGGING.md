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
| no/stale suggestions after a commit | continuation eligibility/state vs candidate snapshot |
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

For a fresh RIME session, `RIME startup phases` separates setup, initialize,
session creation and schema selection. A first-key `firstProcessKey` suffix
separates librime `process_key` from bridge output collection; neither marker
contains typed or candidate content.

Always correlate a failure with its immediately preceding lifecycle/deployment event instead of reading isolated lines.

## Troubleshooting Flows

### T9 Path Bar Collapses After Long Segmented Input

Use a synthetic digit sequence and record the confirmed segment values, focused segment index, remaining source digits, published compact paths, selected path, and live RIME raw before changing UI code.

1. Verify the collapse happens in KeyboardCore path discovery, not in `T9PinyinPathBarView`: UIKit should render every Core-issued compact path and must not own selection state.
2. Compare compatible next-segment comments in the immediate candidate output, the first 16 ranked candidates, and a bounded wider `candidateWindow`. Treat 16 as a latency-oriented sample, not proof that no later syllable exists.
3. If only one exact syllable remains, probe only the current physical key group under the existing live-comment authorization rules. Non-empty candidates or exact raw retention without a matching segment comment do not authorize a branch.
4. Confirm each probe restores the prior ambiguous raw, the published next focus has no selected path regardless of item count, and failed refinement rolls back composition, candidates, marked text, focus and provenance.
5. Recheck direct tap, **选拼音**, Delete and long-input latency. Never log the user's real sentence; keep reproduction input synthetic.

### T9 Partial Commit Shows Digits or Restarts From the Wrong Key

1. Record synthetic previous raw, selected candidate, RIME result raw/preedit, comment-preferred remainder, `remainingRawInput`, `currentComposition` and `segmentSourceDigits` separately.
2. Treat digit tails containing only whitespace/apostrophe separators (for example `748 53`) as internal raw. Do not conclude they are display pinyin because the string is not strictly digit-only.
3. If RIME retains the full pre-selection raw, align the editable suffix from the normalized remaining tail or comment-preferred remaining letter count. Verify all four remaining-state fields agree before inspecting UIKit.
4. Audit every `updateInlinePreedit` fallback: missing comments or a lost session may preserve explicit letters/last safe spelling, but must never publish internal digits.

### T9 Delete Changes to Another Predicted Syllable

If `tou` becomes `tong` after Delete, compare the previous visible preedit with the shorter raw-digit candidate comment. Ordinary unconfirmed Delete should refine to the exact visible prefix (`to`), while explicit segmented selection and Partial Commit checkpoint restore follow their own earlier state-machine branches. Verify the exact replacement raw, host marked spelling, fallback rollback and final empty-session cleanup.

### Simulator Keyboard Behavior Preflight

Complete these checks in order before treating Simulator typing as feature evidence:

1. Record the currently booted Simulator model, OS and UDID; do not reuse a stale device assumption.
2. Build, install and launch the main App with normal Simulator signing. `CODE_SIGNING_ALLOWED=NO` is acceptable for compile/test evidence but not for an installation used to prove App Group or RIME runtime behavior.
3. Confirm the main App bundle resolves the expected App Group container. A missing group container invalidates all scheme-installation conclusions until the app is reinstalled correctly.
4. In the main App, confirm the intended scheme is installed, passes its basic check and is current. Install, deploy or select `rime_ice` before opening the host app when any state is false.
5. Confirm Universe Keyboard is enabled in the system keyboard list. Apply the repository Simulator keyboard baseline when needed, then verify the globe key can actually select Universe Keyboard in the host.
6. Only then type synthetic input and record candidate behavior. Never send a host message merely to prove keyboard output.

If any preflight check fails, classify it as device selection, signing/App Group, deployment/schema or system keyboard enablement before investigating continuation logic.

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

### Post-Commit Suggestions Are Missing Or Stale

1. Use synthetic Chinese text and confirm the keyboard is in Chinese letters mode with no active composition.
2. Confirm `post_commit_continuation_enabled` was refreshed into the Extension settings snapshot.
3. Check whether the committed suffix exists in the bundled V1 resource; an unknown suffix intentionally yields no suggestion.
4. Confirm the bundled resource declares the supported format/content versions and stays within the documented current size, entry, length and suggestion-count bounds. Any validation failure intentionally degrades to an empty provider.
5. Verify the final commit produced `.continuationChanged` and candidate presentation reset its snapshot.
6. Confirm no intervening newline, host deletion, English-mode switch, visibility change or setting disable cleared the state.
7. Do not log the retained context or candidate text. Inspect only eligibility flags, counts and state transitions.

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
13. Foreground private-settings maintenance requires both the automatic-sync master switch and “Universe 设置同步” child switch, and follows the selected daily or seven-day cooldown. Background standard sync also requires the master switch and “RIME 标准同步” child switch. The first successful manual sync only unlocks eligibility and resets both cooldown clocks; it must not enable the master switch. Missing child-switch values migrate to enabled without changing the master switch. Turning off the last child must also persist the master switch as disabled.
14. For notifications, inspect `rimeSync notification scheduled` or `rimeSync notification skipped master=... category=... authorization=...`. A skipped event means the App total switch, RIME category, selected notification scopes or current system authorization blocked delivery; it is independent of whether automatic sync ran. Confirm the notification subject matches the phase that actually ran: RIME standard data, Universe settings or both. When both notification scopes are selected, one complete operation should combine its start/result messages; when only one is selected, another phase's failure must not be attributed to it. Payloads must never include paths, dictionary entries, recovery codes or input content.
15. If the RIME page and global notification page appear inconsistent, confirm both receive the root `AppNotificationSettingsModel`, then check `app_notifications_enabled`, `rime_standard_sync_notifications_enabled`, `rime_standard_data_notifications_enabled` and `rime_private_settings_notifications_enabled`. Do not add a second view-local or RIME ViewModel boolean as a repair. These notification keys must never mutate `rime_standard_auto_sync_enabled` or `rime_private_auto_sync_enabled`.
16. If a foreground sync shows both Toast and notification banner/sound, verify the scheduled request contains the known category and `prefersToastWhenForeground` metadata. Toast-enabled known events should use notification-center list only; unknown future categories must retain banner/sound.
17. If operation Toasts still appear after being disabled, check `app_operation_toasts_enabled` at the root `ContentView` overlay and `presentToast` gate. Detail-page status should remain visible and must not be mistaken for a global Toast.

## Crash, Performance And Memory

The repository does not yet define production budgets. Until that work exists:

- capture the Extension crash/jetsam report and symbolicate against the exact archive;
- reproduce with the same host app and lifecycle sequence;
- inspect main-thread stacks for synchronous file, hashing, network or deployment work;
- compare `viewDidLoad`, engine initialization and `syncUI` performance logs;
- inspect candidate cell-size caches, accumulated candidates, audio players and RIME session lifetime for growth;
- use Xcode Memory Graph/Instruments evidence before claiming a retain cycle or leak.

Absence of a documented budget is not evidence that a measured delay or memory level is acceptable.

### Extension Repeatedly Crashes Before The Keyboard Appears

If selecting Universe Keyboard immediately returns to another keyboard, or the extension stops appearing after one crash:

1. Inspect the newest `Keyboard-*.ips` report before changing RIME state. A main-thread `EXC_BREAKPOINT` / `SIGTRAP` during `viewDidLoad` usually indicates a Swift lifecycle precondition failure, not an input-data failure.
2. Follow the first project frame upward. Layout-derived properties can be queried while `bootstrapKeyboard()` is still installing height constraints, before `KeyboardController` exists.
3. Any property reachable from pre-controller height or layout setup must fail closed without dereferencing the controller. The bootstrap surface is the ordinary 26-key layout until Core state has been installed.
4. After the fix, validate both activation and the first key press. A successful app build alone does not prove that the extension survives its own launch lifecycle.
5. Confirm that the reproduction produced no new `Keyboard-*.ips`; keep simulator automation separate from the physical-device Product Gate.

If typing on iPhone takes over AirPods from audio already playing on another device, first inspect the Keyboard target for app-owned `AVAudioSession` activation or `AVAudioPlayer` use. Keyboard clicks must use UIKit `UIInputViewAudioFeedback` / `UIDevice.playInputClick()`; pre-generated audio still requires an app-owned playback session and is not an acceptable route-ownership fix. Verify the final behavior on physical devices with silent mode and the system keyboard-feedback sound setting recorded separately.

Use `docs/PERFORMANCE_BASELINE.md` for the required measurement fields and scenarios. Numeric budgets may be added only after reviewed real-device evidence exists.

## Verification Commands

Use the canonical commands in `docs/RELEASE_CHECKLIST.md`. A named simulator is required only for actually running tests; discover an installed destination instead of copying a stale device name into permanent docs.

## T9 Path Bar 与逐键显示诊断

- **显示 `qiu`、候选仍是 `tian`：** 同时记录确认段、session raw、首屏 candidate comment。确认后 raw 应为 apostrophe 锚定形式（如 `qiu'53`），comment 必须继承全部确认段；不要只修 UI 文本。
- **`53` 只有 `ke` 与单字母，没有 `le`：** 区分候选页稀疏与 RIME 不授权。检查 bounded exact probe 是否命中 `qiu'le`、是否保持 usable session 和前缀 provenance，以及每次 probe 后是否恢复锚定 raw。
- **按一次 `TUV` 显示 `ta`：** 检查 `T9PreeditResolver` 是否按 raw 中的显式字母/数字槽位投影 comment。候选可预测 `ta`，marked text 只能显示一个字母 `t`；显式 Path Bar 选择应走独立显示路径。
- **选择 `qiu` 后 `le` 消失或变为 `ke`：** 选择前保存用户可见 remainder；按 `segmentSourceDigits - 已消费槽位` 只继承尾部槽位。不要从锚定后的首候选 comment 重建未选择后缀。
- **候选 Delete 后显示 `qiu5`：** 检查 checkpoint 是否复用了 `qiu'53` refined raw、是否无条件恢复安全 previousDisplayText，以及 mixed-digit preedit 是否走 fail-closed。只判断“是否纯数字”不足以阻止泄漏。
- **第二次 Delete 应去掉最后输入的 `e`：** apostrophe 锚定的 unresolved tail 按最后输入槽 exact-refine，例如 `qiu'53 → qiu'5`、`qiule → qiul`。不要删段首 `l`（那是更早的输入）。
