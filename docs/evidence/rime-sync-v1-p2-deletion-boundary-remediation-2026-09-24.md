# RIME-SYNC-001 P2 deletion-boundary remediation — 2026-09-24

## Scope

Remediation for `ARCH-RIME-SYNC-001-FINAL-P2-02` in the isolated RIME-SYNC-001
worktree. A fresh Architecture review is still required before the finding may
be considered resolved.

## Implementation

- `Universe Keyboard/Services/RimeSyncTransport.swift` now models the private
  package-root lookup as four explicit states: `missing`, `directory`,
  `notDirectory`, and `unknown`.
- The production lookup maps a confirmed no-such-file result to `missing`,
  checks `URLResourceValues.isDirectory`, and preserves `nil` as `unknown`.
  Other lookup errors continue to propagate.
- Deletion is attempted only for `directory`. Confirmed non-directory and
  unknown states throw `RimeSyncError.accessDenied`; confirmed absence remains
  an idempotent success.
- `UniverseKeyboardTests/RimeSyncTests.swift` adds regression coverage for a
  regular file at the reserved package-root path and an unknown metadata result
  that must preserve the package and sync configuration. That ViewModel test
  checks retained credentials through `MemoryRimeSyncSecretStore`, an in-memory
  test double; it does not exercise the real Keychain integration.

## Verification

- Device: iPhone 18 Pro Simulator, iOS 27.0; UDID
  `405D994F-28CB-4F89-BB22-B64AD81C05A2`.
- Scheme/configuration: `Universe Keyboard` / Debug; isolated worktree project.
- Result: **5 passed / 0 failed / 0 skipped**.
- Selected tests:
  - `UniverseKeyboardTests/RimeSyncModelTests/testLocalFolderDeletionFailurePreservesPackageConfigurationAndSecrets`
  - `UniverseKeyboardTests/RimeSyncModelTests/testUnknownPackageRootTypePreservesConfigurationAndSecrets`
  - `UniverseKeyboardTests/RimeSyncTransportTests/testLocalFolderDeletionDoesNotRemoveNonDirectoryAtPackageRoot`
  - `UniverseKeyboardTests/RimeSyncTransportTests/testLocalFolderDeletionSucceedsWhenPrivatePackageIsConfirmedMissing`
  - `UniverseKeyboardTests/RimeSyncTransportTests/testLocalFolderDeletionRemovesPrivatePackageOnly`
- The first compile attempt exposed async calls inside XCTest autoclosures; the
  test was corrected to await into local values before asserting. The successful
  rerun had no test failures. Its build log includes the Xcode warning
  `Metadata extraction skipped, no AppIntents.framework dependency found`; this
  is a skipped optional metadata extraction, not a test failure. XcodeBuildMCP
  structured test-result diagnostics contain no warning, error, or test-failure
  entries. The raw launch log also contains Simulator App Group entitlement and
  IOHID plugin-loading messages; this receipt does not diagnose their cause or
  claim the raw log is free of runtime diagnostics.
- Strict Swift formatting passed for the two changed Swift files; `git diff
  --check` passed.
- XcodeBuildMCP artifacts:
  `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-24T13-17-28-139Z_pid14565_4882b038.log`
  and
  `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T13-17-28-139Z_pid14565_c82f8a6c.xcresult`.

## Non-claims and next step

This is focused simulator evidence using a local temporary filesystem and an
injected unknown-metadata seam. It does not prove how a real document provider
reports resource metadata or propagates deletion. No full App + Keyboard suite,
hosted CI, physical-device test, Product Gate, lifecycle transition, commit,
push, PR, merge, or Release is claimed. Freeze the updated candidate and obtain
fresh independent Architecture and scoped Quality reviews before changing the
finding or parent Assignment status.
