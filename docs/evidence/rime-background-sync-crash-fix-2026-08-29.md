# RIME Background Sync Crash Fix — Implementation Evidence

## Run Header

| Field | Value |
|---|---|
| Assignment | `RIME-SYNC-001` |
| Frozen base | `7f20f3aa16ff4b20f52862918da716d6a6d0b312` |
| Evidence date | `2026-08-29 Asia/Shanghai` |
| Affected release evidence | TestFlight build `15`; iPhone 13 Pro; iOS 27.0; crash UUID `329644B8-49CD-38FD-B4CA-8A8BDFB7EFDD` |
| Claim boundary | Local implementation, simulator automation and Human-attested forced-launch physical-device evidence; not natural scheduling, Product Gate, TestFlight or Release evidence |

## Root Cause And Repair

- The symbolicated crash enters
  `RimeAutomaticSyncScheduler.registerBackgroundTask()` through a system
  BackgroundTasks queue, then traps in `_swift_task_checkIsolatedSwift` and
  `_dispatch_assert_queue_fail` before synchronization begins.
- `RimeAutomaticSyncScheduler` is `MainActor`-isolated, so its synchronous
  `BGProcessingTask` launch handler is now explicitly registered on
  `DispatchQueue.main`.
- The handler immediately delegates to the existing cancellable asynchronous
  task. RIME work remains in the main App and does not move into the Keyboard
  Extension or input hot path.
- Automatic standard-sync completion continues through the existing unified
  local-notification service. Delivery remains gated by App notification master,
  RIME category, standard-data scope and current system authorization. The
  notification contains no user input, path, dictionary data or recovery data.

## Automated Evidence

1. Affected queue-policy and automatic-notification matrix:
   - `6` scheduler/model tests, `0` failures.
   - `1` notification-service delivery test, `0` failures.
2. `bash scripts/ensure_rime_vendor.sh verify`:
   - structural inventory passed for all `12` RIME frameworks.
3. `swift test --package-path Packages/KeyboardCore`:
   - `1068` tests, `0` failures.
4. `RimeBridgeTests` on `iPhone 17 Pro`, iOS 26.0:
   - `68` tests executed, `20` fixture-gated tests skipped, `0` failures.
   - Result bundle:
     `/tmp/universe-keyboard-rime-bg-sync-rimebridge/Logs/Test/Test-RimeBridgeTests-2026.08.29_00-22-32-+0800.xcresult`.
5. Full App and Keyboard tests on `iPhone 17 Pro Max`, iOS 27.0:
   - App: `244` tests, `3` device-gated tests skipped, `0` failures.
   - Keyboard: `11` tests, `0` failures.
   - Result bundle:
     `/tmp/universe-keyboard-rime-bg-sync-app-tests-ios27/Logs/Test/Test-Universe Keyboard-2026.08.29_00-25-27-+0800.xcresult`.
6. Strict Swift 6 Debug and Release simulator builds both passed with warnings
   treated as errors.
7. `swift-format lint --strict` for all changed Swift files and
   `git diff --check` passed.

The first full App test attempt used the repository's named `iPhone 17 Pro`
destination, whose only installed runtime is iOS 26.0. Under the active Xcode 27
beta toolchain, the test host repeatedly terminated between unrelated existing
tests with `pointer being freed was not allocated`. The run was interrupted and
is not counted as evidence. Re-running on the installed iOS 27.0 equivalent
destination completed without those allocator exits and produced the passing
matrix above.

## Physical-Device Forced-Launch Evidence

Human-attested Xcode device run on `2026-08-29 Asia/Shanghai`:

- A development build from `codex/rime-background-sync-crash-fix` submitted the
  standard-sync `BGProcessingTask` and was force-launched with Apple's
  device-only BackgroundTasks debugger command.
- The task crossed the build-15 failure boundary without an
  `_swift_task_checkIsolatedSwift` / `_dispatch_assert_queue_fail` crash.
- The librime console reported the `wanxiang` user database backup and
  `3 tasks ran: 3 success, 0 failure`.
- Human observed both “开始自动同步” and “自动同步完成”; the completion payload
  covered RIME standard data and Universe App settings. macOS displayed the
  phone-origin notification through iPhone notification mirroring, so this is
  notification-generation evidence, not a phone lock-screen-presentation claim.
- The scheduler then reached its post-completion resubmission breakpoint. The
  next observed `earliestBeginDate` was `2026-08-30 04:47:19 UTC`, consistent
  with the selected daily cooldown.

One console observation appeared after the successful librime receipt:
`sandbox_extension_consume failed: 22 (Invalid argument)`. No sync failure,
folder-pause state or crash accompanied it. It is therefore recorded as a
non-blocking unknown, not dismissed as harmless and not classified as the cause
of the build-15 crash. Follow-up ownership and escalation triggers are tracked in
[`TD-017`](../TECH_DEBT.md#td-017-investigate-background-sync-sandbox-extension-consume-failure).

## Open Human Gates

- Leave the App unused long enough for an iOS-selected natural launch window;
  record the exact build, device/OS, completion receipt and any crash report.
- Verify phone lock-screen / Notification Center presentation independently of
  macOS iPhone notification mirroring.
- Independent Architecture/Quality review, Human Product Gate, TestFlight upload
  and Release decisions remain open. This implementation evidence does not
  authorize merge or distribution.
