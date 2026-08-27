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

## A-P1-01 follow-up

Architecture `878b02a` found live skip stored a post-load `liveRefreshIdentity()` sample. Store now peeks identity before the page load and commits that peek after a successful apply. `testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad` covers an identity bump that lands after `loadLogText` returns.

```bash
swift test --package-path Packages/KeyboardCore --filter DiagnosticsJournalTests.testLiveRefreshIdentityChangesWhenBytesAreAppended
# passed

xcodebuild ... -destination 'platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' \
  -only-testing:...testRootLoadMarksRefreshingBeforeSourceReturns \
  -only-testing:...testLiveRefreshSkipsRootLoadWhenIdentityIsUnchanged \
  -only-testing:...testLiveRefreshReloadsWhenIdentityChanges \
  -only-testing:...testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad
# TEST SUCCEEDED (4/0)
```

Destination is `iPhone 17 Pro` (`8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`, iOS 26.0). Host still emits known Xcode 27 / IOHIDLib messages; they are not assertion failures. Destination `name=iPhone 17 Pro` without id fails because multiple OS versions exist.

```bash
xcodebuild ... -configuration Debug -destination 'platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' build
# BUILD SUCCEEDED

xcodebuild ... -configuration Release -destination 'platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' build
# BUILD SUCCEEDED

xcrun swift-format lint --strict --configuration .swift-format \
  "Universe Keyboard/Views/Diagnostics/DiagnosticsStore.swift" \
  UniverseKeyboardTests/DiagnosticsStoreTests.swift
# passed

KOS_AS_OF=2026-08-27T22:30:00+08:00 bash /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate-kos.sh \
  "/Users/doubleshy0n/Dev/Universe Keyboard"
# PASS KOS2000（advisory；不等于 Gate）
```

Independent Architecture re-review of `ec5e8e9`: Pass（P0=0 · P1=0）。Independent Quality: Pass with conditions（P0=0 · P1=0）。

## Human device follow-up (same day)

High-fidelity off; ~69 visible lines; Activity Monitor showed ~1 GB working set, ~95% CPU, High energy, ~4.9 MB/s disk; leaving and re-entering restarted a long load. Screenshot numbers are evidence, not a new memory contract.

Reader follow-up: `liveRefreshIdentity` / date catalog no longer take exclusive snapshot fence; `beginPage` still does. Store skips re-entry when watermark is unchanged. `resolve` is O(n) not O(n²).

```bash
swift test --package-path Packages/KeyboardCore --filter DiagnosticsJournalTests
# 25 tests passed, including testLiveRefreshIdentityAndDateCatalogDoNotTakeExclusiveFence

swift test --package-path Packages/KeyboardCore
# passed

xcodebuild ... 6 isolated DiagnosticsStoreTests
# TEST SUCCEEDED (6/0)
```

## Non-claims

Not Human device retest of the reader-load fix. Not PR #83 merge. Not `required`. Not Assignment Close. Full `DiagnosticsStoreTests` / RimeBridgeTests / Universe Keyboard scheme tests were not re-run as a CI-parity suite. Previous Architecture/Quality of `ec5e8e9` do not cover this reader-load change.
