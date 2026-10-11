# RIME-SYNC-001 — full UI regression after local-folder test repair — 2026-09-25

## Result

**Executor-recorded: Passed.** The complete `UniverseKeyboardUITests` scheme
completed with 36 tests: 29 passed, 7 skipped, 0 failed. The repaired
`testUnconfiguredLocalFolderCanOpenAndCancelSystemPicker` passed in the full
sequence (27.081 seconds). This is UI regression evidence for the current
Simulator candidate, not an independent Quality verdict or a Product Gate.

## Run identity

- Worktree: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`.
- Scheme/configuration: `UniverseKeyboardUITests` / Debug; XcodeBuildMCP
  profile `rime-sync-localfolder-e2e`.
- Simulator: iPhone 18 Pro Max, iOS 27.0, build `24A434`, UDID
  `C1B96097-D5CD-4FE3-BF01-C2C6B7DDDE20`.
- DerivedData: `/private/tmp/rime-sync-localfolder-e2e-derived`.
- Build settings included Swift 6, complete strict concurrency, warnings not
  suppressed and treated as errors, and `NE1_SKIP_KEYBOARD_BASELINE_PREACTION=1`.
- The test run began at 2026-09-25 00:17:15 and ended at 00:29:26
  Asia/Shanghai. Xcode reported 712.487 seconds of test execution.
- Result bundle:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T16-17-10-596Z_pid14565_3caf20a0.xcresult`.
- Raw xcodebuild log:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-24T16-17-10-596Z_pid14565_9fa7280b.log`.
- Independent result-bundle summary reports `result: Passed`, 36 total, 29
  passed, 7 skipped, 0 failed. The XcodeBuildMCP frontend request timed out
  at its 300-second response limit, but the already-started xcodebuild process
  continued; the log and `.xcresult` both record normal completion. The
  frontend timeout is not a test failure.

## Skip accounting

All seven skips were explicit opt-in or specialized-fixture cases, not
failures:

1. `testNE1ColdActivationAndFirstInput` — requires isolated NE1 trace runner.
2. `testNineKeyFirstInputCrashRegression` — requires reviewed T9 runtime
   fixture and readiness marker.
3. `testP3D1T02ControlledOwnerKeepsKeyboardResponsive` — requires compiled
   P3-D1 lifecycle harness.
4. `testP3D1T03VisibilityReturnClearsLifecycle` — requires compiled P3-D1
   lifecycle harness.
5. `testUniverseKeyboardIndependentKeyTargets` — requires authorized
   Simulator AX/touch harness.
6. `testFrozenLongCompositionInDisposableRemindersList` — physical-device
   S6-A preflight is opt-in.
7. `testReversibleS2LongCompositionInReminders` — requires reviewed Simulator
   fixture with deployed T9 resources.

No skipped case is counted as passing evidence.

## Repaired test and side effects

The file-picker Cancel control is exposed by iOS 27 accessibility as a generic
`Other`, not as a `Button`. The test now locates the exact `Cancel` label among
the picker's descendants instead of requiring a button role. The full suite
confirms this path passes and that cancelling leaves the local folder
unconfigured. The test did not invoke synchronization, disconnect, or delete.

The separate first-sync test also passed in this full run and created its
unique isolated Files folder `Universe-Rime-Sync-7D6841EC` in the disposable
Simulator. No existing or user data was deleted.

## Limits and non-claims

- This records one full UI-target run on one Simulator/runtime. It is not the
  full App + Keyboard CI-equivalent suite, hosted CI, Architecture review,
  Quality review, physical-device evidence, or Product acceptance.
- It does not verify provider-side deletion/propagation, live WebDAV, CloudKit,
  natural background-task delivery, cross-platform compatibility, or any
  technical-debt resolution.
- The seven specialized tests remain unverified by this run.
- The parent Assignment remains `Active`; this receipt does not authorize
  commit, push, PR, merge, TestFlight, Release, or lifecycle closure.

## Next

Use this receipt in the exact final candidate snapshot, obtain fresh
independent Quality and Architecture reviews, and preserve provider deletion
evidence and `TD-002` as explicit residuals.
