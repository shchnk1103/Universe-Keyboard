# RIME Background Sync Lifecycle Remediation — Implementation Evidence

## Run Header

| Field | Value |
|---|---|
| Assignment | `RIME-SYNC-001` |
| Base | `efa009fbe1ad360b393480d617e7452272d4eb6b` |
| Implementation commit | `0f597701fbd87cf390e88f367d91bf69c590927b` |
| Pull request | Draft PR [#91](https://github.com/shchnk1103/Universe-Keyboard/pull/91); this local commit is not pushed |
| Evidence date | `2026-08-30 Asia/Shanghai` |
| Claim boundary | Local implementation and Executor-recorded automation; the user screenshots are diagnostic observations, not a frozen-manifest Product/Release run |

## Diagnostic Observation

**Evidence grade: `Device-attested diagnostic`.** The human owner reported no
configuration change between an iOS-selected background opportunity and an
immediately following manual sync:

- the automatic result said RIME standard data was both “updated” and
  “incomplete”, while Universe App settings had not started;
- the following manual operation completed RIME standard data and Universe App
  settings successfully;
- this proves neither the installed commit nor the exact cancellation callback,
  because an immutable installed-payload manifest and content-free lifecycle
  receipt were not prepared before the observation.

The notification shape is nevertheless a precise code-path fingerprint: the
standard phase had inserted `.standardRimeData` into completed scopes, but
cancellation was still attributed to the standard scope before the private
settings phase became active. The most likely trigger is iOS expiration between
the two phases. This is a high-confidence diagnosis, not a retroactive formal
device proof.

## Remediation

- Move the semantic phase boundary to `.privateSettings` before observing
  cancellation after a completed standard sync. An expiration between phases
  now reports “RIME ... 已更新；Universe App 设置未完成” instead of contradicting
  itself.
- Normalize failed notification payloads defensively so one scope cannot be
  rendered as both completed and failed.
- Add a MainActor-isolated `BGProcessingTask` lifecycle gate. Expiration requests
  cancellation once; normal return and expiration converge on exactly one
  `setTaskCompleted`, and an expired task cannot report success.
- When keyboard activity blocks a due run, persist a 15-minute
  `retryNotBefore`. Scheduling uses the later of cadence and this bounded retry,
  rather than repeatedly submitting an eligible date already in the past.

The work remains in the main App. It does not move sync, persistence or logging
into the Keyboard Extension or the input hot path.

## Automated Evidence

All results below are `Executor-recorded` against implementation commit
`0f597701fbd87cf390e88f367d91bf69c590927b` unless noted otherwise.

1. `git diff --check`: passed before the implementation commit.
2. Changed-file strict format lint:
   - the new/edited scheduler and test files passed;
   - `RimeSyncViewModel.swift` and `RimeSyncModels.swift` retain unrelated
     pre-existing whole-file indentation findings. The edited hunks introduced
     no formatter finding; broad reformatting was intentionally excluded.
3. `bash scripts/ensure_rime_vendor.sh verify`: all `12` framework artifacts
   passed structural inventory.
4. `swift test --package-path Packages/KeyboardCore`: `1068` tests, `0`
   failures.
5. `RimeBridgeTests`, iPhone 17 Pro / iOS 26.0: `68` tests, `20` existing
   fixture-gated skips, `0` failures. Result bundle:
   `/tmp/universe-keyboard-rime-bg-lifecycle-rimebridge/Logs/Test/Test-RimeBridgeTests-2026.08.30_19-39-15-+0800.xcresult`.
6. Full App + Keyboard tests, iPhone 17 Pro Max / iOS 27.0:
   - App: `247` tests, `3` physical-device-only skips, `0` failures;
   - Keyboard: `11` tests, `0` failures;
   - result bundle:
     `/tmp/universe-keyboard-rime-bg-lifecycle-final-app/Logs/Test/Test-Universe Keyboard-2026.08.30_19-41-26-+0800.xcresult`.
7. Strict Swift 6 Debug and Release simulator builds both passed with warnings
   treated as errors.
8. Companion documentation validation:
   - repository lightweight checks passed, including changed Markdown links,
     `12` CI script tests, final-gate matrix and KOS trigger paths;
   - pinned KOS v0.5.0 structural validator returned `PASS`. Its six warnings
     point to pre-existing records outside this change; advisory validation is
     not Architecture, Quality or Product approval.

The App matrix uses the installed iOS 27.0 equivalent simulator because the
active Xcode 27 beta toolchain previously produced unrelated allocator exits on
the repository's iOS 26.0 App-test destination. RimeBridgeTests passed on the
CI-named iOS 26.0 destination.

## Review And Human Gates

- The earlier Architecture and Quality reviews remain valid only for
  `e3e5d77`; they do not independently approve `0f59770`.
- `0f59770` is ready for independent Architecture and Quality re-review of
  `A-P2-01`, `A-P2-02`, `Q-P2-02` and `Q-P2-03`.
- A future formal physical-device run must freeze the installed payload manifest
  and content-free receipt before the first human action, then observe an
  iOS-selected natural opportunity and the phone's own Notification Center.
- `TD-002`, `TD-017`, cross-front-end evidence, Product Gate, merge, TestFlight
  and Release remain open. This evidence authorizes none of them.
