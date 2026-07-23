# KEYBOARD-LAYOUT-9KEY-PINYIN-004 — Focused UI / Presentation Contract Evidence

**Date:** 2026-07-22 Asia/Shanghai  
**Executor:** Grok 4.5  

## Scope

Keyboard extension Path Bar is UIKit code without a dedicated `@testable` host-module for XCUITest cell geometry. Assignment required focused UI contract coverage for:

1. Same Core snapshot revision for paths + candidates  
2. Stale delayed candidate discard (Core revision)  
3. Path completeness (not truncated to 5 in Core publish)  
4. Path kind semantics for accessibility labeling  

These are covered at the **Core presentation contract** layer that UIKit is required to consume (`refreshT9PresentationFromCoreSnapshot`). Host VoiceOver / 44pt physical hit remain Human Product Gate + optional XCUITest follow-up.

## Tests added

`Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PresentationSnapshotContractTests.swift`

| Test | Contract |
|---|---|
| `testSnapshotBindsPathsCandidatesPreeditAndPagingToOneRevision` | One revision binds paths, candidates, preedit, page number, hasMorePages; no digit preedit; full path set ≥5 |
| `testStaleCompositionRevisionPathSelectionIsRejected` | Core fail-closed on stale `compositionRevision` |
| `testPathWindowOnlyReexportsCatalogSnapshotWithoutMorePages` | No `candidateWindow` side effects; no more-pages discovery |
| `testLetterPrefixAccessibilityKindSemantics` | `bu` complete / `b` prefix with shared revision stamp |

## Command + result

```bash
cd Packages/KeyboardCore
swift test --filter 'T9PresentationSnapshotContractTests|T9PinyinCatalogTests|T9PinyinCatalogControllerTests|T9HostPreeditSafetyTests|T9PinyinPathTests|KeyboardLayoutAndT9RuntimeTests|PartialCommitControllerTests'
```

**Result: 126/126 PASS, 0 failures**

(Includes 4 new presentation contract tests + prior 122.)

## UIKit code path reviewed (not XCUITest)

| Location | Contract |
|---|---|
| `KeyboardViewController+Presentation.syncUI` | T9 active → single `refreshT9PresentationFromCoreSnapshot` |
| `applyT9PresentationSnapshot` | Same snapshot → Path Bar + candidates + expanded panel |
| `resetCandidateSnapshot(from:)` | Uses snapshot paging fields (no live re-read for page/hasMore) |
| `loadMoreCandidates` | Requires matching generation + raw + Core revision |
| `T9PinyinPathBarView.point(inside:)` | Vertical hit expansion toward 44pt; cell hit remains layout-height limited until device validation |

## Residual for Human Gate / future UI tests

- Physical 44pt cell hit with 34pt bar height  
- Scroll retention across same-revision candidate paging  
- VoiceOver labels on device  
- XCUITest against real keyboard chrome (if product requires automation beyond Core contracts)
