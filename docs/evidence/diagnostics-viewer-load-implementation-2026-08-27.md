# DIAGNOSTICS-VIEWER-LOAD-001 — Implementation evidence — 2026-08-27

**Assignment:** [`diagnostics-viewer-load-001.md`](../assignments/diagnostics-viewer-load-001.md)
**Authorization:** [`AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT`](../authorizations/AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT.md)
**Evidence grade:** `Executor-recorded`
**Collection date / timezone:** `2026-08-27 Asia/Shanghai`

## Changes

- `DiagnosticsLogContentView` shows a loading surface while `isRefreshing` and there are no visible rows. It no longer uses the journal-empty copy during that window.
- Filter-empty, partial-window-empty, and true-empty copy remain distinct.
- Live follow compares `DiagnosticsJournalLiveRefreshIdentity` (generation + segment count + byte watermark) and skips JSONL root decode when unchanged.
- ADR 0027 5 MiB / 10,000 条预算未改。

## Commands

```bash
swift test --package-path Packages/KeyboardCore --filter DiagnosticsJournalTests.testLiveRefreshIdentityChangesWhenBytesAreAppended
# passed

xcodebuild ... -only-testing:UniverseKeyboardTests/DiagnosticsStoreTests/testRootLoadMarksRefreshingBeforeSourceReturns
xcodebuild ... -only-testing:UniverseKeyboardTests/DiagnosticsStoreTests/testLiveRefreshSkipsRootLoadWhenIdentityIsUnchanged
xcodebuild ... -only-testing:UniverseKeyboardTests/DiagnosticsStoreTests/testLiveRefreshReloadsWhenIdentityChanges
# TEST SUCCEEDED (3/0)

KOS_AS_OF=2026-08-27T22:00:00+08:00 bash kos-agent-kit/scripts/validate-kos.sh
# PASS KOS2000
```

Full `DiagnosticsStoreTests` on Xcode 27 beta still hits known IOHIDLib/malloc host restarts on some sync tests; those failures are host crashes, not new assertion failures. The three new tests passed in isolation.

## Non-claims

Not Architecture/Quality Pass. Not Human device retest. Not PR #83 merge. Not `required`.
