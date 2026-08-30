# RIME Background Sync Terminal Lifecycle — Implementation Evidence

## Run Header

| Field | Value |
|---|---|
| Assignment | `RIME-SYNC-001` |
| Trigger reviews | Architecture / Quality re-review of `0f59770` |
| Implementation commit | `a34c45cc3b1f091981cf691b4534381663057671` |
| Base | `546ffb4` |
| Evidence date | `2026-08-31 Asia/Shanghai` |
| Claim boundary | Local implementation and Executor-recorded automation; not final independent review, device Product Gate, merge or Release evidence |

## Residual Closure Design

- Replace the MainActor-only expiration state with a `Synchronization.Mutex`
  terminal-ownership gate. Expiration and operation return race atomically; only
  one can own completion.
- The expiration callback now cancels and calls `setTaskCompleted(false)` on the
  callback path without waiting for a MainActor hop or non-cooperative librime
  return. Logging and rescheduling still hop safely to MainActor.
- Add controllable production seams for operation finish and expiration. Tests
  drive immediate failure completion, late-success suppression, success-only
  notification, repeated finish suppression and concurrent ownership races.
- Re-check task cancellation after standard RIME and private-settings operations
  return. Automatic completion notification is removed from the model operation
  and published only after scheduler success obtains terminal ownership.
- Successful safety skips still complete the BGTask successfully but do not emit
  a false “同步完成” notification.

## Automated Evidence

All results are `Executor-recorded` against `a34c45c`:

1. Focused lifecycle/model matrix: `19` tests, `0` failures.
2. Full Universe Keyboard scheme, iPhone 17 Pro Max / iOS 27.0:
   `262` total, `259` passed, `3` physical-device-only skipped, `0` failed.
   Result bundle:
   `/tmp/universe-keyboard-rime-bg-lifecycle-r2-final-app/Logs/Test/Test-Universe Keyboard-2026.08.30_23-58-45-+0800.xcresult`.
3. KeyboardCore: `1068` tests, `0` failures.
4. RimeBridgeTests, iPhone 17 Pro / iOS 26.0: `68` tests, `20` existing
   fixture-gated skips, `0` failures. Result bundle:
   `/tmp/universe-keyboard-rime-bg-lifecycle-r2-rimebridge/Logs/Test/Test-RimeBridgeTests-2026.08.30_23-56-22-+0800.xcresult`.
5. Strict Swift 6 Debug and Release builds passed with warnings as errors.
6. RIME vendor structural inventory passed for all `12` artifacts.
7. `git diff --check` and strict formatting for the changed scheduler/test files
   passed. The ViewModel retains unrelated pre-existing whole-file indentation
   findings; changed hunks introduced no new formatting issue.

## Remaining Gates

- Independent Architecture and Quality must re-review `a34c45c`; findings issued
  against `0f59770` cannot be transferred automatically.
- A formal natural-background/device-notification run still requires the
  pre-frozen installed manifest and content-free receipt.
- `TD-002`, `TD-017`, cross-front-end evidence, Product Gate, push, merge,
  TestFlight and Release remain open.
