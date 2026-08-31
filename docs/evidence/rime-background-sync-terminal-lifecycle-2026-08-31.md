# RIME Background Sync Terminal Lifecycle — Implementation Evidence

## Run Header

| Field | Value |
|---|---|
| Assignment | `RIME-SYNC-001` |
| Trigger reviews | Architecture / Quality re-review of `0f59770` |
| Final implementation commit | `3f9407387393b1a2c5fb63fba0a10f86af62bf18` |
| Implementation chain | `a34c45c` terminal ownership → `466a5f0` cancellation/test delta → `a7b2b2e` cancellation and notification closure → `3f94073` direct model cancellation coverage |
| Base | `546ffb4` |
| Evidence date | `2026-08-31 Asia/Shanghai` |
| Claim boundary | Local implementation, Executor-recorded automation and independent Architecture/Quality `Pass with conditions`; not device Product Gate, merge or Release evidence |

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
- Re-check cancellation after custom-YAML refresh before starting librime, after
  librime before recording its success time, and around private coordinator/apply
  boundaries. A cancellation notification is emitted only while a requested
  scope remains unfinished.
- Successful safety skips still complete the BGTask successfully but do not emit
  a false “同步完成” notification.
- Route each potentially non-cooperative model phase through a cancellable phase
  boundary that checks cancellation after the awaited operation returns. Direct
  model tests now prove late success is rejected and an unfinished requested
  scope is required before a cancellation notification may be emitted.

## Automated Evidence

Current-snapshot results are `Executor-recorded` against `3f94073`:

1. Final focused lifecycle/model matrix: `23` tests, `0` failures. Result bundle:
   `/tmp/universe-keyboard-rime-bg-direct-model-focused/Logs/Test/Test-Universe Keyboard-2026.08.31_07-39-33-+0800.xcresult`.
2. Full Universe Keyboard scheme, iPhone 17 Pro Max / iOS 27.0:
   App `255` tests with `3` physical-device-only skips and `0` failures;
   Keyboard `11` tests with `0` failures.
   Result bundle:
   `/tmp/universe-keyboard-rime-bg-direct-model-app/Logs/Test/Test-Universe Keyboard-2026.08.31_07-41-15-+0800.xcresult`.
3. Strict Swift 6 Debug and Release builds passed against `3f94073` with
   warnings as errors.
4. KeyboardCore: `1068` tests, `0` failures.
5. RimeBridge, iPhone 17 Pro /
   iOS 26.0: `68` tests, `20` existing
   fixture-gated skips, `0` failures. Result bundle:
   `/tmp/universe-keyboard-rime-bg-direct-model-rimebridge/Logs/Test/Test-RimeBridgeTests-2026.08.31_07-40-35-+0800.xcresult`.
6. RIME vendor structural inventory passed for all `12` artifacts.
7. `git diff --check` and strict formatting for the changed scheduler/test files
   passed. The ViewModel retains unrelated pre-existing whole-file indentation
   findings; changed hunks introduced no new formatting issue.
8. Final documentation checks against `a7b2b2e..6381520` passed changed-link
   validation for `8` Markdown files, `12` classifier/final-gate unit tests and
   KOS trigger-path checks. The pinned `kos-agent-kit@v0.5.0` advisory validator
   exited `0`; its six warnings are pre-existing records outside this change.

## Independent Reviews

- Architecture final re-review of `a7b2b2e`: `Pass with conditions`; no
  implementation-level blocker. `A-P2-01`, `A-P2-02` and `A-P2-04` are closed
  at code level. Expiration retry delivery remains a device/system condition.
- Quality final re-review of `a7b2b2e`: `Pass with conditions`; no
  implementation-level blocker. `Q-P2-02`, `Q-P2-03`, `Q-P2-05` and
  `Q-P2-06` are closed at code/unit level.
- Independent Architecture and Quality delta reviews of `3f94073` both returned
  `Pass with conditions`. Quality closed the direct model cancellation gap at
  code/unit level; Architecture retained the non-atomic local-write window as a
  non-blocking condition.

## Remaining Gates

- A formal natural-background/device-notification run still requires the
  pre-frozen installed manifest and content-free receipt. The
  [preflight packet](rime-background-sync-device-run-preflight-2026-08-31.md)
  is prepared but remains `HOLD` until installed-device identities are frozen.
- The real expiration-to-reschedule window and complete App Group
  heartbeat-to-submit-to-callback chain remain device/system conditions.
- `TD-002`, `TD-017`, cross-front-end evidence, Product Gate, push, merge,
  TestFlight and Release remain open.
