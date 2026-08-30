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
| key tap lands on the wrong neighbor / gap | visual key vs `KeyTouchCellLayout` touch cell; nine-key uses column stacks (`T9NineKeyChromeHost`); Debug overlay in 诊断 |

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

## Debug Key Touch Overlay

In a **Debug** build, Settings → 诊断 →「显示按键触摸范围」draws the live hit-test snapshot. Orange solid = `touchFrame`; teal dashed = visual bounds. 26-key and nine-key must share one midline-fill snapshot. Overlay paints on the keyboard surface, not on buttons. A `TOUCHPROBE` digest (`path`, overlay state, key count, visual/touch height summary) is shown on the overlay and written to display logs; rejected geometry is content-free.

The production touch surface is a persistent sibling routing canvas built from that same snapshot. Its per-key `UIControl`s accept only the gap outside each visible key, use the same nearly invisible backing precedent as candidate cells, and forward the original button's target-action lifecycle. They exist whether the Debug overlay is on or off. Over visible key faces the canvas returns no hit, preserving the original button and gesture path. A parent `hitTest` returning an out-of-bounds descendant is not enough evidence: on a physical device, also verify that `UIControl.beginTracking` and the business `touchDown` are delivered.

Release builds have no switch and no overlay. The Extension reads the flag at settings-snapshot / visibility boundaries, never inside `hitTest`. Do not restyle the near-invisible backing views to “see” the hit area; that historically changed the surface under test.

Compact-bar commit (2026-08-14): a tap on the first candidate's upper band can hit `contentView` (`inCell`, `idx=0`, 48 pt) and still never reach `didSelect` — UICollectionView's selection tap waits for the bar's swipe-down pan to fail. `CandidateBarView` delivers an item tap that does not wait; debounce shares the commit path with `didSelect`.

Expand-button overlay: the trailing orange slab was the expand hit frame flattened to `y=0…34` and allowed to extend past the bar. The live frame is now the button's outset box clipped to the bar; a point that belongs to a candidate item is not routed to the chevron first.

See [`PD-DEBUG-KEY-HITBOX-001`](product-decisions/DEBUG-KEY-HITBOX-001-authorization.md) and [`DEBUG-KEY-HITBOX-001`](assignments/debug-key-hitbox-001.md).

## Diagnostic Logs

诊断正在从旧的 `rime_diag_log` 迁移至 App Group `Diagnostics/v1/` 的结构化 JSONL journal。v1 按 writer process 独占段并使用 generation 清空；Main App 每次刷新会冻结当前 generation，并且仅在完整 segment 总量不超过 5 MiB 的受控读取预算时按全局 newest-first 展示。旧 `UserDefaults` 文本仅在 v1 正常为空时作为只读兼容回退，绝不能把自由文本重新写入 v1。

若诊断页提示“日志已清空/分页已失效”，表示 generation 在当前分页期间推进，刷新后重新开始查询；若提示快照超过安全读取上限，表示系统拒绝返回可能乱序的部分结果。它不是键盘输入失败，也不应通过调大无界内存预算来绕过。此时即使列表为空，右上角垃圾桶也应保持可用；确认清空会推进 generation，并在成功后恢复为可读取的新快照。若页面提示“未能完整清空”，保留现状并重试，不要把空列表当作清空成功。Main App 会在启动、回到 active 和诊断页刷新时以 15 分钟 cadence 合并 retention/reclaim；该 cadence 不是超预算快照的确定恢复方式。Keyboard Extension 不执行目录扫描、reclaim 或锁等待。

键盘热路径只能向有界 typed ingress 投递内容无关 event；不得读取 App Group、格式化日期、编码 JSON、枚举目录、获取文件锁或等待持久化。Extension 消失时，未开始的尾批允许丢弃；若同一 process 恢复，v1 会尽力以 `journal.resumed` 和 `dropped_event_count` 记录该类损失。日志关闭时，这些 event 也会在后台过滤。

### Main App surface

Path: **设置 → 诊断** (`DiagnosticsSettingsView`).

| Area | Behavior |
|---|---|
| Status | Shows recording on/off and local-only storage state; it does not synchronously load the full legacy log just to display a count. |
| Master switch | `logging_enabled` — enables new writes. **Must not** insert/remove Form sections (categories stay mounted; disabled + dimmed when off). |
| Categories | Always visible; grayed/`disabled` when master is off. Keys `log_category_*` (perf, disp, engine, config, deploy, gen). Stored in plain `@State` map (not `@Observable` fan-out). |
| Debug 高保真 | 手动开启的 30 分钟绝对时窗记录内容无关的首屏溯源。“结束时通知我”默认关闭，与 **设置 → 通知与提醒** 共用同一类别；仅 Main App 安排或取消唯一的本地提醒。 |
| Review | Navigate to `DiagnosticsView` for filter/copy/clear. |
| Advanced | Collapsed by default. Nine-key **force_gc** tools live here only. |
| Status chips | Always-mounted labels; style/text only. |

**Form crash class (`SwiftUI.AsyncRenderer` / libdispatch “Block was expected to execute on queue”):**

1. Conditional `if flag { Section {…} }` remount under Toggle (historical).
2. Custom `ToggleStyle` inside `Form` correlated with residual asserts. **All main-App toggles use system `.toggleStyle(.switch)`.**
3. Avoid `.animation(_:value:)` on Form sections / opacity driven by the master flag.

**Same Form-topology rule** for notifications detail rows, RIME automatic-sync children, haptic level: always-mounted + disabled/dimming.

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

### Candidate touch routing probe (Debug high fidelity)

候选栏触摸探针只在 Debug 构建且 30 分钟高保真窗口仍有效时写入 v1。它使用同一个
`appearance` 和 `action` 对单指、短时操作做 best-effort 关联，不记录坐标、候选索引、
候选内容或宿主内容；多指或辅助功能路径不能把 `action` 当作触摸身份：

| Event / field | Meaning |
|---|---|
| `candidate.touch_routed` | 该触摸已经到达 `CandidateBarView.hitTest`；`candidate_touch_band` 仅为 `upper / middle / lower`，`candidate_cell_hit` 表示 UIKit 最终命中视图是否属于候选 cell。 |
| `candidate.gesture_terminal` | 候选列表手势结束；`candidate_pan_began` 表示 pan 是否进入 `.began`，`candidate_touch_cancelled` 只表示终态为 `.cancelled`。 |
| `candidate.selection_delivered` | 同一 `action` 已进入候选选择回调；它不证明后续 RIME/宿主提交成功。 |

对固定候选的可见文字区域依次点击上、中、下三分区，每区五次，并按 `action` 读取链路；
不要把候选栏下方的额外手势承接区算作可见“下部”。某次没有
`candidate.touch_routed`，只说明触摸未到达该观测点（或高保真窗口已关闭）；不要把“无事件”
直接解释为某个手势取消。若 routed 存在但 `candidate_cell_hit=false`，问题位于 bar 内部命中；
若 cell 命中但没有 `candidate.selection_delivered`，再结合 gesture terminal 判断 UIKit 选择前链路。
探针是观测工具，不授权扩大命中区或改变 gesture cancellation。

已确认的 2026-08-13 iPhone 13 Pro 基线中，候选 collection 为 48 pt，高度 32 pt 的
cell 居中在约 `y=8...40`；因此可见上部大多命中 collection 而非 cell，形成
`0/5 · 5/5 · 5/5`。普通紧凑候选 cell 现应覆盖完整 48 pt 容器，同时保持 32 pt
内容视觉居中。若该矩阵再次退化，先核对 collection/cell frame 与 `candidate_cell_hit`，
不要先改 RIME 或候选排序。

诊断页的一秒自动跟随刷新不应切换右上角手动刷新 spinner。根加载或日期切换在
`isRefreshing` 且当前没有可见行时必须显示「正在加载诊断日志」，不得把加载中
画成「暂无诊断日志」。筛选无匹配、有界窗口无完整记录、以及真正没有 journal
是三种不同空态。live follow 在 generation/段 watermark 未变时跳过 JSONL 根解码；
skip 比较的是触发本次解码的 identity peek，不得用加载完成后的盘面身份当作已展示。
1 秒 skip 只读目录体积水位，不得抢 exclusive snapshot fence（writer 的 shared fence 会使 exclusive 失败并逼出整页重扫）。
`beginPage` 仍在解码前冻结成员集合。不得为此抬高 5 MiB / 10,000 条预算。
诊断页离开后再进入时，若水位未变则不得重新全量解码。搜索展开时根刷新暂停，
分页由单一 owner 顺序读取；遇到首条无法完整放入 5 MiB / 10,000 条预算的记录即停止，
不得跳过该记录继续读取更老页面。关闭搜索或搜索中切换日期时，应等待在途分页返回，
拒绝迟到页后再启动新的根查询。

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

### Responsive dual-gate: Delete stuck or wipes whole composition

After dual-gate default-on, keys enqueue as deferred `processKey`. If
`replaceInput` / select capture `lastPublished` **before** draining that
backlog, the bound revision goes stale when the queue drains; the mutation is
skipped. Visible-spelling Delete may then **fail-closed wipe** the whole
composition, or appear as a **no-op** (stuck) while new keys still type. Fix:
bridge `flushPending()` before binding (`RESPONSIVE-DELETE-ANOMALY-001`). Use
synthetic burst input for repro; never log real user text.

### Responsive dual-gate: candidate tap doubles host text; bar stuck at page size

| Symptom | Boundary |
|---|---|
| Tap candidate → host shows the word twice; Space is fine | Select **double host apply**: Core `finishNormalCandidateSelection` **and** publish `applyRimeOutput(committedText)` |
| Candidate bar stops around page size (often 9 or 12); loadMore dead | ThreadAffine `candidateWindow` must not slice `lastPublished` first page only |

**Checks (synthetic only):**

1. Confirm dual-gate / responsive bridge is active (not gate-off ADR 0004).
2. Space vs tap: Space never calls `selectCandidate`; tap does.
3. Prefetch logs: `loadMoreCandidates start=12` then empty window / `hasMore=false` while dictionary still has more.
4. Fix ownership (`RESPONSIVE-CANDIDATE-ANOMALY-001`): suppress UI publish on bridge select (Core owns host apply); owner-thread live `candidateWindow` after `flushPending`.
5. Multi-segment partial then final (e.g. long 全拼: first phrase then second): if only the **last** segment doubles, suspect a late `sel-*` presentation re-apply of `committedText`. Defense: select actions use `sel-` action IDs and presentation strips host commit (Core already applied).

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

For the complete operational flow—original report acquisition, ordinary-exit vs
crash vs Jetsam classification, exact UUID/dSYM binding, Xcode/`atos`
symbolication, privacy-safe storage and the content-free receipt—follow
[`CRASH_JETSAM_SYMBOLICATION.md`](CRASH_JETSAM_SYMBOLICATION.md). Do not diagnose
an Extension termination from a screenshot or Console excerpt alone.

### Main App Crashes When A RIME Background Task Starts

An `EXC_BREAKPOINT` / `SIGTRAP` whose first project frame is
`closure #1 in RimeAutomaticSyncScheduler.registerBackgroundTask()` and whose
system frames include `_dispatch_assert_queue_fail` plus
`_swift_task_checkIsolatedSwift` is an executor mismatch at the BackgroundTasks
entry point. It occurs before folder access, librime synchronization or notification
delivery, so do not classify it as corrupt RIME data or a file-provider failure.

`RimeAutomaticSyncScheduler` is `MainActor`-isolated. Its synchronous launch
handler must therefore be registered on `DispatchQueue.main`; the handler then
creates the cancellable asynchronous operation that performs the actual sync.
Do not use unsafe isolation or move synchronization into the Keyboard Extension.

After a repair, verify the queue invariant and automatic-success notification
tests, then use Apple's device-only BackgroundTasks debugger launch and expiration
commands. A Simulator pass does not prove natural scheduling, background folder
bookmark access, lock-screen notification delivery or the absence of a new crash
on the affected OS. Preserve the exact TestFlight build, device/OS and report UUID.

If one result says the same RIME standard scope was both “updated” and
“incomplete”, inspect the cancellation boundary between standard RIME data and
private App settings. That payload means the standard completion was recorded
while failure attribution still pointed at the old phase; it is not evidence of
corrupt RIME data. The failure renderer must also remove the failed scope from
completed scopes defensively. Correlate with the background-task expiration log
before claiming expiration as a confirmed device cause.

### Extension Repeatedly Crashes Before The Keyboard Appears

If selecting Universe Keyboard immediately returns to another keyboard, or the extension stops appearing after one crash:

1. Inspect the newest `Keyboard-*.ips` report before changing RIME state. A main-thread `EXC_BREAKPOINT` / `SIGTRAP` during `viewDidLoad` usually indicates a Swift lifecycle precondition failure, not an input-data failure.
2. Follow the first project frame upward. Layout-derived properties can be queried while `bootstrapKeyboard()` is still installing height constraints, before `KeyboardController` exists.
3. Any property reachable from pre-controller height or layout setup must fail closed without dereferencing the controller. The bootstrap surface is the ordinary 26-key layout until Core state has been installed.
4. After the fix, validate both activation and the first key press. A successful app build alone does not prove that the extension survives its own launch lifecycle.
5. Confirm that the reproduction produced no new `Keyboard-*.ips`; keep simulator automation separate from the physical-device Product Gate.

If typing on iPhone takes over AirPods from audio already playing on another device, first inspect the Keyboard target for app-owned `AVAudioSession` activation or `AVAudioPlayer` use. Keyboard clicks must use UIKit `UIInputViewAudioFeedback` / `UIDevice.playInputClick()`; pre-generated audio still requires an app-owned playback session and is not an acceptable route-ownership fix. Verify the final behavior on physical devices with silent mode and the system keyboard-feedback sound setting recorded separately.

Use `docs/PERFORMANCE_BASELINE.md` for the required measurement fields and scenarios. Numeric budgets may be added only after reviewed real-device evidence exists.

### T9 continuous digit typing — DEBUG segment timing (`T9SEG`)

When investigating “long unconfirmed nine-key input feels janky without Path/candidate picks”, use **Debug** builds only. Instrumentation is `#if DEBUG` and does not change product control flow.

**What is measured** (one sample per T9 digit key; lengths only, never composition text):

| Field | Meaning |
|---|---|
| `rawLen` | Unconfirmed RIME raw length after the key |
| `rime` | `processKey` + collectOutput (bridge) |
| `pathLocal` | Local Path rebuild + focus retain |
| `preedit` | Visible preedit resolve + host marked-text update |
| `pathUI` | Path Bar `setPaths` / `reloadData` |
| `candUI` | Candidate bar snapshot fill / `reloadData` |
| `total` / `engine` / `ui` | Existing KEY END split |
| `unaccounted` | `total − (rime+pathLocal+preedit+pathUI+candUI)` |

Log prefix: `T9SEG` (and `SLOW T9SEG` when `total ≥ 50ms`). Category: `PERF`. Enable logging + PERF category in the diagnostics app if needed.

The same Debug key sample emits one content-free `T9SHADOW` line for
`T9-AUTO-ANCHOR-001` Stage 1. It does not change RIME input or candidate
behavior. Fields:

| Field | Meaning |
|---|---|
| `status` | `proposalReady` or a fail-closed reason such as `candidateSetIncomplete`, `incompletePathEvidence`, `noClosedCommonPrefix` |
| `generation` / `provenance` | Core snapshot identities; zero/stale snapshots are blocked |
| `candidates` / `compatible` / `uniquePaths` / `rejected` | Current-page structural evidence counts |
| `commonSyllables` / `closedSyllables` | Observed common prefix and the portion followed by another segment in every observed compatible Path |
| `anchorSlots` / `unresolvedSlots` | Hypothetical bounded-prefix slots and remaining active slots |
| `complete` | Whether the current snapshot is page 0, has no more pages and every candidate has compatible ASCII Path evidence |

`proposalReady` is an S1 observation label, not authorization to mutate input.
If `hasMorePages` is true, a useful observed common prefix may still be reported
while `status=candidateSetIncomplete` and `complete=false`. Do not hide that
blocker or scan more candidates synchronously from the Extension hot path.

When an explicitly gated S2 transaction has rejected and restored its pure
digit identity, Debug may also emit `T9RETRYSHADOW`. This is a Stage 3
read-only observation over the current already-returned output; it never
executes another replacement.

| Field | Meaning |
|---|---|
| `status` | `proposalReady` or `notEligible` |
| `sourceSlots` / `rejectedAt` | Current source length and first rejection length |
| `candidates` | Current returned candidate count |
| `anchorSlots` / `unresolvedSlots` | Proposed bounded prefix and remaining source lengths |

Absence of a line means the rejected/pure-digit/no-explicit-Path preconditions
were not met. A `proposalReady` line is not proof that a later transaction
would preserve candidates.

**How to collect a length curve on device**

Physical third-party-keyboard input follows the canonical Human method in
`PERFORMANCE_BASELINE.md`. Do not retry coordinate-driven XCTest, Computer Use
typing or guessed screen coordinates.

1. Install the declared diagnostic or Release-like internal Keyboard
   Extension by replacement; open a blank Reminders title field; select the
   software keyboard and switch to Chinese nine-key.
2. The Human types a fixed synthetic digit sequence at a steady natural
   cadence (e.g. 20–40 keys) without selecting Path or candidates. Prefer one
   warm session after first composition.
3. Export or filter the App diagnostics for `T9SEG`, `T9SHADOW` and, when the
   relevant experiment is active, its content-free transaction outcome.
4. Plot or table `rawLen` vs `rime`, `pathLocal`, `preedit`, `pathUI`, `candUI`, `total` (median + worst per rawLen bucket if possible).
5. Record executable hash, commit, optimization, device, OS, schema, Full
   Access and manual cadence; validate ordered event count, stable session and
   zero unexpected commits.
6. Restore ordinary gate-off Release by replacement after an internal arm.
   Do not invent budgets from one manual run.

Interpretation: if `pathUI`+`candUI` dominate as `rawLen` grows, presentation reload is the lever; if `rime` dominates, focus librime/collectOutput; if `pathLocal`/`preedit` dominate, local catalog/preedit work.

**Spike reading (P0):** device logs showed occasional `SLOW KEY` / `SLOW T9SEG` with `rime` ≈ 160–200ms while neighboring keys stay 3–10ms. On those lines, also read `SLOW RIME` / `RIME processKey returned` for:

- `processKey=(api Xms, collect Yms)` — split of librime `process_key` vs `collectOutput`/`get_context`
- If `api` dominates → engine/table work inside librime
- If `collect` dominates → context/candidate copy cost

Continuous T9 digit bursts now **idle-gate bar-mode candidate prefetch** (≈280ms after last digit; no 12→27→42 chain while still typing). Expect fewer `loadMoreCandidates` lines mid-burst; scroll-near-end still prefetches. Expanded panel prefetch is unchanged.

**Long T9 digit spikes (`api` dominates, `collect` ≈0):** primary remaining cost after hygiene. **force_gc-as-primary-fix is closed** — see case close [`evidence/t9-continuous-digit-latency-force-gc-case-close-2026-07-24.md`](evidence/t9-continuous-digit-latency-force-gc-case-close-2026-07-24.md). The 2026-07-26 simulator matrix and symbolicated multi-thread trace isolated the first-party path to `ScriptTranslation::MakeSentence → Dictionary::Lookup → Table::Query`; Lua, completion, spelling hints, the script-translator-ineffective `enable_sentence` flag and `max_homophones: 1` did not reduce the fixed-sequence spikes. A later controlled matrix retained the full composition but cumulatively anchored exact pinyin Path at natural boundaries: slow keys dropped from 15/190 to 0/190 without host commit, proving unresolved T9 ambiguity—not raw length alone—is the dominant amplifier. The real-UI follow-up also found that selecting a Path at the current composition end does not yet advance it; after entering the next syllable, the previous Path must be tapped again. Preserve this transition explicitly in any automation instead of assuming one tap per syllable. See [`evidence/t9-long-composition-process-key-latency-2026-07-26.md`](evidence/t9-long-composition-process-key-latency-2026-07-26.md) and the active [`plans/t9-long-composition-process-key-latency-plan.md`](plans/t9-long-composition-process-key-latency-plan.md). Keep simulator/Debug attribution separate from physical-device Release acceptance.

**T9 force_gc hygiene (not the main latency fix):** deploy may strip force_gc **only** from `t9.schema.yaml` (not `rime_ice` / shared `lua/force_gc.lua`). Verify with main App → 设置 → 诊断 → **高级** → **检查九键 Schema / force_gc** (source + compiled `build/t9.schema.yaml`). If source clean but compiled still lists force_gc, apply patch then **完整部署**. If **both clean** and SLOW KEY remain, do **not** reopen force_gc as primary — use the long-composition plan.

## Verification Commands

Use the canonical commands in `docs/RELEASE_CHECKLIST.md`. A named simulator is required only for actually running tests; discover an installed destination instead of copying a stale device name into permanent docs.

## T9 Path Bar 与逐键显示诊断

- **显示 `qiu`、候选仍是 `tian`：** 同时记录确认段、session raw、首屏 candidate comment。确认后 raw 应为 apostrophe 锚定形式（如 `qiu'53`），comment 必须继承全部确认段；不要只修 UI 文本。
- **`53` 只有 `ke` 与单字母，没有 `le`：** 区分候选页稀疏与 RIME 不授权。检查 bounded exact probe 是否命中 `qiu'le`、是否保持 usable session 和前缀 provenance，以及每次 probe 后是否恢复锚定 raw。
- **按一次 `TUV` 显示 `ta`：** 检查 `T9PreeditResolver` 是否按 raw 中的显式字母/数字槽位投影 comment。候选可预测 `ta`，marked text 只能显示一个字母 `t`；显式 Path Bar 选择应走独立显示路径。
- **选择 `qiu` 后 `le` 消失或变为 `ke`：** 选择前保存用户可见 remainder；按 `segmentSourceDigits - 已消费槽位` 只继承尾部槽位。不要从锚定后的首候选 comment 重建未选择后缀。
- **候选 Delete 后显示 `qiu5`：** 检查 checkpoint 是否复用了 `qiu'53` refined raw、是否无条件恢复安全 previousDisplayText，以及 mixed-digit preedit 是否走 fail-closed。只判断“是否纯数字”不足以阻止泄漏。
- **第二次 Delete 应去掉最后输入的 `e`：** apostrophe 锚定的 unresolved tail 按最后输入槽 exact-refine，例如 `qiu'53 → qiu'5`、`qiule → qiul`。不要删段首 `l`（那是更早的输入）。
