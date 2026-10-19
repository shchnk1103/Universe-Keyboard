# INPUT-RELIABILITY-DELIVERY-001 log

## CP-001 CHECKPOINT

- id: CP-001
- at: 2026-10-19T19:05:00+08:00
- lane: grok-build
- kind: CHECKPOINT
- note: Initial writer. Human Product Lead named grok-build as the initial executor. No predecessor HANDOFF exists.

## CP-002 CHECKPOINT

- id: CP-002
- at: 2026-10-19T19:30:00+08:00
- lane: grok-build
- kind: CHECKPOINT
- note: Local Batch 1 extraction committed. Writer remains grok-build. No HANDOFF and no pending P. Product source is not pushed. Checks on this Mac, destination iPhone 17 Pro, no simulator reset: swift-format lint --strict on changed Swift; KeyboardCore swift test 1208 passed; RimeBridge installer 3 passed and session recovery 2 passed after the private schema fixture gained default.yaml; KeyboardDocumentIdentityTests 4 passed; Debug build-for-testing succeeded; Release build succeeded. CHANGELOG was not updated because this is not a user-facing release. Independent Architecture and Quality are unassigned.

## CP-003 CHECKPOINT

- id: CP-003
- at: 2026-10-19T19:40:00+08:00
- lane: grok-build
- kind: CHECKPOINT
- note: C1 only. Automatic session recovery restores lastKnownRawInput when recreation fails or replaceInput neither composes nor commits. Public recoverSession and resetSession still clear it. Writer remains grok-build. No product push. Checks: swift-format lint --strict on the two changed Swift files; SynchronousSessionLossRecoveryTests 2 passed on iPhone 17 Pro, no simulator reset. CP-002 evidence still covers KeyboardCore, installer tests, identity tests, Debug build-for-testing, and Release build; those targets were not rebuilt for this engine-only fix. C2–C5 were not changed.

## CP-004 CHECKPOINT

- id: CP-004
- at: 2026-10-19T20:08:00+08:00
- lane: grok-build
- kind: CHECKPOINT
- note: PR 213 test-rimebridge failed because a restarted librime reads user/build, while the fixture only wrote shared sources. Test-only copy of default.yaml and the private schema into user/build. Production code unchanged. C1 assertions unchanged. Local SynchronousSessionLossRecoveryTests 2 passed. swift-format lint --strict passed for the test file.
