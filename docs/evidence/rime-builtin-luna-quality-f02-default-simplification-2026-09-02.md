# Evidence: F-02 default-simplification fix (`b1d81fd`) — 2026-09-02

- Assignment: [`RIME-BUILTIN-LUNA-QUALITY-001`](../assignments/rime-builtin-luna-quality-001.md)
- Commit: `b1d81fd2f61522001bc1d15490563097bd581016` — `fix: write simplified Luna reset when simplification key is missing`
- Parent: `688a8fe`
- Author / date: Cowork 3P, 2026-09-02 20:01 +08:00
- Branch: `codex/f02-rime-builtin-quality-assignment`

## What changed

`git diff 688a8fe..b1d81fd` — 3 files, +103/−23:

- `Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+Preferences.swift` — adds `simplificationPreference(from:)`, centralizing the missing-`rime_simplification` → default-simplified (`true`) rule; `currentSimplification()` now delegates to it.
- `Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+CustomYaml.swift` — extracts a testable `syncCustomYamlFiles(defaults:rimeRoot:)` core; the production wrapper delegates to it and routes simplification through `simplificationPreference(from:)`, so a missing key writes `switches/@2/reset:1` for `luna_pinyin`.
- `Packages/RimeBridge/Tests/RimeBridgeTests/RimeBuiltinResourceInstallerTests.swift` — two new fixture-backed tests: missing-key → `reset:1` + receipt validation; explicit traditional (`false`) → `reset:0` + receipt validation.

## Evidence

### Committed test rerun (closes `F02-COMMITTED-TEST-RERUN-001`)

- Run: full `RimeBridgeTests` scheme, iPhone 17 Pro simulator / iOS 26.0, 2026-09-02 20:15:20.
- xcresult: `/private/tmp/uk-f02-tests-dd/Logs/Test/Test-RimeBridgeTests-2026.09.02_20-15-20-+0800.xcresult`
- Result (read back via `xcrun xcresulttool get test-results summary`): `passedTests: 75` + `skippedTests: 20` = 95 total, `failedTests: 0`, `result: "Passed"`.
- Provenance: `b1d81fd` committed at 20:01:48, before the run; worktree clean and HEAD = `b1d81fd`, no source change after the run.

### Evidence level (M-04)

- Test run itself: `Executor-recorded` (run by the Executor, not an independent reviewer).
- Replacement Quality reviewer readback (xcresult summary + git state): `reviewer-readback`, not `Quality-reverified` (no independent re-run was performed).

## Boundary

This records the committed rerun and the reviewer readback. It is not Exit, TestFlight, Release, legal or Product Gate acceptance. The `c5f3004` candidate freeze is superseded by `b1d81fd` (see the 2026-09-02 Architecture/Quality re-review addenda); re-freeze or explicit defer remains a Human Product Owner decision.
