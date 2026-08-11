# TD-013 Diagnostics v1 P1 — execution evidence (2026-08-11)

> **Status:** Implementation evidence only. This record is not an Architecture
> review, Quality conclusion, Product Gate, Release claim, or device evidence.

## Implemented scope

1. `DiagnosticsJournalReader.beginPage` captures a current-generation `(segment
   identity, byte watermark)` manifest while discovered writer identities are
   fenced by their stable locks. Later appends are outside the watermark, rotation
   is resolved by inode, and reclaim disappearance is an explicit cursor
   invalidation. The snapshot is globally sorted by the ADR 0027 event order.
2. Core-enforced page limits are 10,000 decoded events and 5 MiB snapshot input;
   callers cannot raise them. A partial segment reports
   `snapshotExceedsReadBudget`, rather than returning an incorrectly ordered
   "latest" page.
3. Cursor states distinguish normal more/completion, generation/reclaim
   invalidation, unavailable cursor, snapshot budget rejection, and journal
   unavailability. The Main App presents controlled notices and never treats a
   failed v1 read as legacy-empty.
4. Main-App-only retention requests are coalesced to a 15-minute cadence from
   startup, active-scene restoration and Diagnostics refresh. The Keyboard
   Extension does not import or call the scheduler; UI refresh does not wait for
   reclaim.
5. Journal write failures map explicit storage exhaustion to `disk_full` and all
   other write failures to `io_failure`; no error text/domain/path is persisted.
6. Legacy producer inventory records 205 production `Logger(String)` calls. The
   directly identified RIME raw-log, Lua smoke/summary, force_gc summary and
   dynamic-resource-name paths now use aggregates only. Remaining legacy cohorts
   are not v1 inputs and remain separate debt.

## Automated / static evidence

All commands below were executed by the current Executor on `2026-08-11
Asia/Shanghai`, against `d3f415ec7da29f732fd718ae66274c8be375048d` plus the
uncommitted TD-013 diff. They are **Executor-recorded** evidence, not an
independent Quality conclusion or a Product/Release claim.

所有 XcodeBuildMCP 行使用同一等价 CI 参数：
`CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete
SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`。项目为
`Universe Keyboard.xcodeproj`，派生数据位于
`/private/tmp/universe-keyboard-td013-mcp-derived`；测试/构建收据路径已列在
各 XcodeBuildMCP 工具输出中。任何后续代码、测试、工程设置或 strict 参数变化都
使本记录失效，必须在最终提交上重验。

| Check | Grade | Result | Notes |
|---|---|---|---|
| `xcrun swift-format lint --strict --configuration .swift-format` on all changed Swift | Executor-recorded | PASS | App、Extension-reachable Core/RimeBridge sources and tests均通过；随后 `git diff --check` 也通过。 |
| `swift test --package-path Packages/KeyboardCore` | Executor-recorded | PASS | 973 tests, 0 failures；包括 global snapshot fence、append-after-begin、同小时 tie-break、seal 后 inode 解析、reclaim invalidation、current-generation partial tail 与硬事件上限。 |
| `XcodeBuildMCP test_sim` — `Universe Keyboard` Debug | Executor-recorded | PASS | iPhone 17 Pro Max（UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`，iOS Simulator 27）在 Swift 6 strict / warnings-as-errors 下报告 157 passed, 0 failed, 0 skipped，25.1 s。 |
| `XcodeBuildMCP test_sim` — `RimeBridgeTests` Debug | Executor-recorded | PASS | 同一模拟器与严格 flags：37 passed, 0 failed, 20 skipped，10.3 s。唯一 `InitGoogleLogging` STDERR 是 vendor 启动警告，未造成测试失败。 |
| `XcodeBuildMCP build_sim` — `Universe Keyboard` Debug | Executor-recorded | PASS | 同一模拟器、严格 flags，10.9 s。 |
| `XcodeBuildMCP build_sim` — `Universe Keyboard` Release | Executor-recorded | PASS | 同一模拟器、严格 flags，43.6 s。 |
| Static privacy audit | Executor-recorded | PASS for selected P0-style paths | No remaining `Logger.shared` call consumes `developerSummary`, `userFacingLines`, runtime raw lines, candidate samples or dynamic samples. |

The generic Simulator builds retain the repository's existing vendor notes about
missing x86_64 slices in several boost XCFrameworks; they are non-fatal and did
not prevent a successful build.

## Simulator runtime evidence

The prior shutdown-simulator receipt (14 passed, 6 skipped) remains historical
context only. The healthy-simulator receipts above prove compilation and
automated behavior on this simulator only; they are neither true-device evidence
nor an Architecture, Quality, Product or Release decision.

## Required next gates

1. Obtain fresh independent Architecture review against ADR 0027 and independent
   Quality review of the repaired diff and the evidence above.
2. If both reviews pass or leave only Assignment-policy-compliant residuals,
   Product Lead decides the Product Gate. No true-device or Release performance
   claim is needed for this implementation-only change unless Product opens it.
