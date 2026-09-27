# RIME-SYNC-001 — current App + Keyboard full Simulator suite — 2026-09-25

## Result

**Executor-recorded: Passed.** The current dirty worktree candidate completed
the full `Universe Keyboard` Debug scheme on Simulator. The authoritative
`.xcresult` contains 401 test cases: **391 passed, 10 skipped, 0 failed**.
`UniverseKeyboardTests` contributed 386 cases and `KeyboardTests` 15.
Skipped tests are not counted as passes.

This is the App + Keyboard broad suite only, not the complete CI-equivalent
heavy-job matrix or hosted CI.

## Run identity

- Assignment: `RIME-SYNC-001`; worktree:
  `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`.
- Source HEAD: `4a51228fc8e435d538e9a5f7342ae325502e1e66`; the worktree was dirty.
  The run used the current worktree sources, not HEAD-only source.
- Scheme/configuration: `Universe Keyboard` / Debug; XcodeBuildMCP profile
  `rime-sync-full-app-keyboard-20260925`.
- Simulator: iPhone 18 Pro, iOS 27.0, build `24A434`, UDID
  `405D994F-28CB-4F89-BB22-B64AD81C05A2`. The CI-default iPhone 17 Pro was
  not booted; this booted iOS 27.0 Simulator was used as the equivalent
  available target.
- Effective test settings: `CODE_SIGNING_ALLOWED=NO`, Swift 6,
  `SWIFT_STRICT_CONCURRENCY=complete`, warnings visible and treated as errors.
- Isolated DerivedData:
  `/private/tmp/rime-sync-full-app-keyboard-derived-20260925`.
- Xcode result summary time: 2026-09-25 00:49:09.663–00:49:53.614
  Asia/Shanghai. Xcode logged test execution completion at 00:49:53.
- `.xcresult`:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T16-48-38-236Z_pid14565_1e7290be.xcresult`.
- Raw XcodeBuildMCP/xcodebuild log:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-24T16-48-38-236Z_pid14565_9890d241.log`.
- Test products:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/test-products/test_sim_2026-09-24T16-48-38-236Z_pid14565_eb2aa385.xctestproducts`.

## Exact-run count reconciliation

XcodeBuildMCP preflight reported **402 discovered**. The `.xcresult` summary
reports **401 total**. To reconcile this run, Xcode native enumeration was
performed against the same `.xctestproducts` bundle in enumeration-only mode
(no test methods executed). It returned 401 unique enabled identifiers: 386
`UniverseKeyboardTests` and 15 `KeyboardTests`. Those identifiers match the
401 case identifiers in this run's `.xcresult` exactly after removing the
target prefix: zero missing and zero extra identifiers. The normalized,
sorted matched identifier set has SHA-256
`396a31a93c82d38c4d6013fbde71172c088e0aab7e9b0dd84653aaf94fd614cf`.

The native enumeration JSON is at
`/private/tmp/rime-sync-full-enum.QpNfak/xcode-enumeration.json`, SHA-256
`f468e61261869f772646cbfca41d232881370a8396061492cbce85044c24342a`.
The cause of the XcodeBuildMCP preflight's extra discovered count remains
unknown. On `2026-09-25`, the Human Product Owner accepted this exact-run
402/401 reporting discrepancy as a bounded MCP discovery-count residual under
the [Product Decision](../product-decisions/RIME-SYNC-001-QR-CURRENT-01-PRODUCT-RESIDUAL-2026-09-24.md).
This receipt supports reporting the exact 401 result IDs; it does not establish
future MCP count accuracy, a tool fix, or a coverage claim for skipped tests.

## Skipped cases

All ten skips have explicit environment or entitlement prerequisites:

1. One pinned official/mirror archive convergence case requires independently
   downloaded source archives.
2. One production Security Keychain CRUD case was skipped because this broad
   host is unsigned and lacks the Keychain entitlement; it requires the
   separate signed Simulator lane.
3. Five scheme-resource coexistence cases require pinned Ice/Wanxiang extract
   trees or the `default.yaml` fixture.
4. Three TD-012 LMDG model staging/load/cleanup cases are physical-device-only.

No skipped test is counted as a pass. Existing signed Keychain evidence is
historical and is not represented as a rerun in this receipt.

## Limits and non-claims

- The run is Simulator-only and uses the iPhone 18 Pro / iOS 27.0 runtime. It
  is not physical-device, hosted-CI, Release-build, Product Gate, or release
  evidence.
- The other CI heavy jobs (KeyboardCore, RimeBridgeTests, signed Keychain
  integration, Release build), classifier/lightweight checks and hosted
  workflow were not run as part of this action.
- Ten cases remain skipped. Their prerequisites and boundaries are listed
  above; no coverage is inferred from them.
- This run does not verify real File Provider deletion propagation, live
  WebDAV, CloudKit, natural BGTask delivery, cross-platform compatibility, or
  resolve `TD-002`, `TD-008`, `TD-013`, `TD-017` or `TD-019`.
- The Product acceptance applies only to this exact 2026-09-25 402/401
  reporting discrepancy. The underlying MCP cause remains unknown; no blanket
  acceptance of future counts or coverage claim is made.
- Parent Assignment remains `Active`. No commit, push, PR, merge, TestFlight,
  Release or lifecycle transition occurred.
