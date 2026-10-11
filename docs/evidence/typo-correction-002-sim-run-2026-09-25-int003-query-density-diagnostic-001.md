# INT-003 query-density diagnostic capture 001

## Run header

| Field | Value |
|---|---|
| Run ID | `TC2-SIM-20260925-161830-INT003-QUERY-DENSITY-DIAGNOSTIC-001` |
| Capture purpose | Obtain a raw event timeline for query-density operation grouping; no Product or UX claim |
| Assignment / AUTH | `TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001` / `AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001` (Consumed at `2026-09-25T16:06:56+08:00`) |
| GitHub source | `shchnk1103/Universe-Keyboard` `main`, `4ef275b57d16f116b4edbae99a0e244a28d6bf25`; verified before this run |
| Xcode checkout | Isolated worktree `/private/tmp/universe-keyboard-int003-query-density-diagnosis-20260925`, branch `codex/typo-correction-002-int003-query-density-diagnostic-20260925`, HEAD `4ef275b57d16f116b4edbae99a0e244a28d6bf25` |
| Build | Scheme `Universe Keyboard`, Debug, Swift 6.0, strict concurrency complete, warnings-as-errors; `xcodebuild` exited 0 with DerivedData under this run's `/private/tmp` directory |
| Xcode version | Xcode 27.0, build `27A266a` |
| Simulator | iPhone 17 Pro Max / iOS 27.0 / UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`; host `simctl` and XcodeBuildMCP both reported Booted |
| App bundle | `com.DoubleShy0N.Universe-Keyboard`, version/build `1.0 (1)` |
| Keyboard extension bundle | `com.DoubleShy0N.Universe-Keyboard.Keyboard` |
| App executable SHA-256 | `a082030ffe68eb214251c547c3895eb9054903e27eb0e4b86efcd74437319444` |
| Keyboard executable SHA-256 | `d8b6e902f0bf91cb1dafd4741c126fb57ab70fc43211eb526a0f0266b4a28826` |
| RIME Vendor | `rime-vendor-ios-1.16.1-lua.1-octagram.1`; archive SHA-256 `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`; isolated-worktree fetch and structural verification passed |

## Environment preflight

- The default XcodeBuildMCP profile points at the protected shared checkout. It was not used. Session defaults are being set to this isolated worktree and the exact designated UDID.
- Sandboxed `xcrun simctl list devices available` failed because CoreSimulatorService and its user log path were inaccessible in the sandbox. The same read-only command in the authorized host context succeeded and listed the designated simulator as Booted under iOS 27.0. XcodeBuildMCP independently listed the same Booted UDID.
- Xcode build in the sandbox stopped at inaccessible SwiftPM/Clang user caches (exit 74). The same build command under host permissions succeeded (exit 0); no tests were run.
- Both app and extension entitlements declare `group.com.DoubleShy0N.Universe-Keyboard`.

## Capture progress

Run ID was generated before installation, diagnostic arming, app launch, or synthetic input. The app was installed and launched on the exact designated simulator. The Human enabled Universe Keyboard in Settings and completed visible keyboard taps in the app's trial field. The diagnostic categories and high-fidelity window were active during the capture; the App Group logging flag was enabled. No visual or Product claim was requested from the Human.

The Human reported this was their fastest repeatable manual cadence. The journal contains 19 highlighted key-terminal events; none of the 18 inter-key intervals is below the intended 180 ms threshold. This run therefore did **not** execute a qualifying rapid segment. It remains useful for correlating real query calls with operation ordinals and the debounce schedule.

The raw journal's SHA-256 was recorded before event-row inspection. The initial temporary copy resolved under the isolated worktree because its directory name matched the worktree path; after detecting this, it was moved to a dedicated `/private/tmp` directory outside the repository before staging or publication. The hash matched after the move. Only approved metadata was projected: event codes, timestamps, process/appearance IDs, operation ordinals, composition revisions, reason enums, and counts. Normalized composition, candidate text, host text, fingerprints, and other journal fields were neither printed nor committed.

## Results

| Observation | Result |
|---|---|
| Raw journal | `keyboard_extension-596AEB2F-5018-451A-9F89-4AB127C3A4FE-20260925T08-0.jsonl`, 571,204 bytes / 863 rows; SHA-256 `aa523a6e8330b529e0ffc03283b142f842401b2321e2b323e6ce2762d5b59f84`; retained at `/private/tmp/int003-query-density-diagnostic-2026-09-25/raw/` |
| Process / appearance | `596AEB2F-5018-451A-9F89-4AB127C3A4FE` / `0D88C406-7A57-44B3-BFF4-15DC64261FB6` |
| Query marker totals | 359 `query_begin` + 359 `query_outcome`; every operation group has matching begin/outcome counts |
| Query outcome reason | 359 `typo_recall_query_succeeded`; in this code path that means the operation was not discarded by the fence, not that candidate results were non-empty |
| Operation groups | Ordinals 1–12, all `composition_revision=2`; per-operation query counts: 31, 31, 31, 32, 31, 32, 31, 31, 26, 26, 26, 31 |
| Debounce / fence markers | 12 scheduled, 11 cancelled, 2 epoch bumps, 3 fence discards (ordinals 9–11) |
| Highlighted key timing | 19 events / 18 intervals; minimum 285.075 ms, maximum 575.942 ms, 0/18 below 180 ms |
| Schedule-to-first-query | For operations 1–12, 218.942–259.581 ms from the corresponding scheduled marker to the first query begin |

The event grouping confirms these are not duplicate log-only markers. On this source tip, every `query_begin` is emitted immediately before one `owner.correctionCandidates(...)` call, and `query_outcome` follows the driver's post-call fence classification. The driver yields one query per unique hypothesis, so a single operation can produce many query pairs. This run observed 26–32 actual candidate-query calls per operation across 12 operations. Its slower key cadence also allowed successive operations to start after the 180 ms delay.

This is a bounded explanation of query density, not an exact reconstruction of the earlier Product Capture's rapid window. The earlier raw JSONL remains unavailable for operation-level rehash/correlation, and this run missed the under-180 ms cadence. In particular, it cannot determine whether the earlier 16 query pairs arose within one or more operations during that rapid segment. No query fan-out or scheduling change is justified by this run alone.

No Swift or test changes were made; no tests were run. No product behavior, human visual attestation, Product Gate, QA-001 Gate, parent close, TestFlight, or Release claim is made by this run.
