# RIME-SYNC-001 P1 deletion remediation — simulator test attempt — 2026-09-24

## Scope and state

This receipt records the bounded code/test remediation attempt for
`ARCH-RIME-SYNC-001-FINAL-P1-01`. The change makes local private-package
deletion distinguish confirmed absence from an indeterminate or inaccessible
target, and adds regression coverage for failed deletion state preservation and
confirmed absence. The Assignment remains `Active`; the finding is **not**
closed, and no independent re-review has been requested against this unverified
snapshot.

## Change and static checks

- `Universe Keyboard/Services/RimeSyncTransport.swift`: injects a throwing
  package-root presence lookup; only Cocoa's explicit no-such-file result is
  treated as absence. Other lookup errors propagate before `removeItem`.
- `UniverseKeyboardTests/RimeSyncTests.swift`:
  `testLocalFolderDeletionFailurePreservesPackageConfigurationAndSecrets`,
  `testLocalFolderDeletionSucceedsWhenPrivatePackageIsConfirmedMissing`, and
  the existing `testLocalFolderDeletionRemovesPrivatePackageOnly` were selected
  for focused simulator execution.
- `xcrun swift-format lint --strict --configuration .swift-format` passed for
  both changed Swift files. `git diff --check` passed.

## Simulator attempt

- Project: isolated worktree `Universe Keyboard.xcodeproj`
- Scheme/configuration: `Universe Keyboard` / Debug
- Destination: iPhone 18 Pro, iOS 27.0 Simulator
- First attempt: XcodeBuildMCP discovered all three selected test identifiers,
  but **zero tests ran** because the test runner failed to install/launch with
  `Mach error -308 - (ipc/mig) server died`. Immediate read-only
  `xcrun simctl list devices booted` confirmation reported that the
  CoreSimulatorService connection was invalid/refused and simulator services
  were unavailable. This attempt was an environment/runtime failure, not an
  assertion failure.
- Recovery and rerun: XcodeBuildMCP subsequently listed the same iPhone 18 Pro
  as `Booted`. The identical three test identifiers then **passed 3/3, failed
  0, skipped 0** in 28.0 seconds. The recovered simulator run, not the initial
  infrastructure failure, is the execution evidence for this slice.
- XcodeBuildMCP artifacts:
  `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-24T12-52-29-631Z_pid14565_80dc6a46.log`
  and
  `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T12-52-29-632Z_pid14565_c03df5ad.xcresult`.

Passing rerun artifacts:
`~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-24T13-04-15-206Z_pid14565_e514f16a.log`
and
`~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T13-04-15-207Z_pid14565_d6392d97.xcresult`.

## Next action and non-claims

The targeted simulator regressions are now complete and pass; the next step is
to freeze the final source/test/evidence snapshot and request fresh independent
Architecture review, followed by Quality review of the changed scope. Simulator
evidence does not prove behavior against a real file provider or physical
device. No device/provider deletion, hosted CI, commit, push, PR, merge, Release,
Product Gate, or Assignment lifecycle transition is evidenced or authorized by
this receipt.
