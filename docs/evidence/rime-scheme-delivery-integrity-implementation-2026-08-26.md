# RIME Scheme Delivery Integrity — Implementation Evidence

## Run Header

| Field | Value |
|---|---|
| Assignment | `RIME-SCHEME-DELIVERY-INTEGRITY-001` |
| Frozen base | `bcf6c1c46ff374cfea20ec2552ca273161cb8d76` |
| Evidence refresh | `2026-08-27 Asia/Shanghai` |
| Environment | Apple Silicon macOS 27 beta; Xcode 27 beta; iOS Simulator destination `2426D713-C2F1-4850-9D17-2C5A73347FD4` |
| Claim boundary | Local implementation and beta-toolchain automated evidence only; not stable CI, physical-device, Product Gate or Release evidence |

## Implemented Evidence

- Downloaded archives are checked in distinct size and complete SHA-256 phases.
- Archive size/digest failure may advance only after the exact registered
  temporary artifact yields a positive `.removed` or `.alreadyAbsent` cleanup
  receipt; staged-content mismatch remains fail closed.
- Exhausted pinned sources report a finite aggregate of archive-size,
  archive-digest or mixed integrity failures rather than presenting the final
  attempt as the whole result.
- Typed delivery diagnostics use reviewed enums and constrained digest prefixes,
  reject generic fields and phase-invalid field combinations, and preserve the
  same source/request/result behavior when diagnostics are recorded or dropped.
- Manifest validation binds every source to a reviewed staged identity plus the
  installation-plan and deterministic post-processing revisions.
- Central RIME deployment is process-local single-flight; commit-lease waiters
  are coalesced and deferred mutation ordering is covered by tests.
- T9 prepare, deploy, smoke, readiness and layout publication hold that same
  lease. Waiting downloads can be cancelled without later installing after a
  foreign lease releases; a generation failure immediately after acquisition
  rolls its lease back before propagating cancellation.

## Automated Runs

1. `swift test --package-path Packages/KeyboardCore`
   - Result: `1065` tests, `0` failures.
2. Affected main-App matrix (`NineKeyEnableTransactionTests`,
   `SchemaArtifactSecurityTests`, `SchemaManagerTests`, `RimeSettingsStoreTests`):
   `121` tests, `0` failures. This includes real production-entry T9 lease
   waiting, foreign-lease cancellation, owned-lease deferred cancellation and
   post-acquire generation-invalidity rollback. Result bundle:
   `/tmp/universe-integrity-affected-final2/Logs/Test/Test-Universe Keyboard-2026.08.27_14-46-14-+0800.xcresult`.
3. Full App + Keyboard tests: `243` passed, `3` skipped, `0` failed. The three
   skipped TD-012 G2 cases explicitly require an authorized physical device and
   do not support model staging/load/cleanup claims. Result bundle:
   `/tmp/universe-integrity-app-full-final2/Logs/Test/Test-Universe Keyboard-2026.08.27_14-47-21-+0800.xcresult`.
4. `RimeBridgeTests`: `48` passed, `20` skipped, `0` failed. Skips require
   separately supplied isolated real-engine/Lua/T9 directories or the immutable
   S4 commit, so this run does not claim those Spike/real-engine matrices.
5. Debug and Release simulator builds both passed with strict Swift 6 settings.

`swift-format lint --strict` for the files changed in the latest remediation and
`git diff --check` both passed.

## Independent Review

- Architecture: `Pass`, P0=0/P1=0.
- Quality: `Pass with conditions`, P0=0/P1=0.
- Non-blocking P2: the process-local temporary-artifact registry does not yet
  retire successful/non-integrity registrations after ordinary cleanup. This
  can accumulate stale capabilities/URLs but does not weaken the verified
  fallback cleanup barrier.

## Open Gates

- Stable Xcode toolchain full App/RimeBridge/Debug/Release gates remain unrun.
- Exact-build Mainland cellular physical-device retry remains a Human Gate.
- Human Product Gate remains open.
- No commit, push, merge, TestFlight distribution or Release claim is made.
