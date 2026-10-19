# INPUT-RELIABILITY-DELIVERY-002 log

## CP-001 CHECKPOINT

- id: CP-001
- at: 2026-10-19T21:10:00+08:00
- lane: grok-build
- kind: CHECKPOINT
- note: Initial writer. Human Product Lead named grok-build as the initial executor. No predecessor HANDOFF exists. Writer authority is not inherited from INPUT-RELIABILITY-DELIVERY-001.

## CP-002 CHECKPOINT

- id: CP-002
- at: 2026-10-19T21:20:00+08:00
- lane: grok-build
- kind: CHECKPOINT
- note: Local Batch 2 extraction committed. Writer remains grok-build. No HANDOFF and no pending P. Product source is not pushed. A candidate without a native origin is not passed to native select. Local augmentation still commits its displayed text. Checks on this Mac, destination iPhone 17 Pro, no simulator reset: swift-format lint --strict on changed Swift; KeyboardCore swift test 1227 passed; Debug build-for-testing succeeded; Release build succeeded. RimeBridge, App, and Keyboard test suites were not run. CHANGELOG was not updated because this is not a user-facing release. Independent Architecture and Quality are unassigned.

## CP-003 CHECKPOINT

- id: CP-003
- at: 2026-10-19T21:40:00+08:00
- lane: grok-build
- kind: CHECKPOINT
- note: Review remediation. Writer remains grok-build. No HANDOFF and no pending P. Under an authority engine, an origin-less candidate commits only when the current page is origin-free and contains that text; otherwise it is refused and does not call selectCandidate(globalIndex:). Non-authority engines keep the previous path. isSafeCompositionFinalizationText and the provisionalPathID lookup in t9VisiblePreedit are restored to merged-main behavior. Ordered-delete isolated comparison found no regression: baseline bb430f9 four passes, candidate four passes. Checks: swift-format lint --strict; KeyboardCore swift test 1228 passed; RimeBridge SynchronousSessionLossRecoveryTests succeeded; Debug build-for-testing succeeded; Release build succeeded. Product source is not pushed. D4 and D5 remain deferred.
