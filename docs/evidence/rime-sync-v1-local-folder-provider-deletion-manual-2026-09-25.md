# RIME-SYNC-001 — isolated Files-provider deletion, manual Simulator run — 2026-09-25

## Outcome

**Direct, time-adjacent local provider state observed after the successful App
deletion flow:** the isolated folder no longer contained
`universe-rime-sync/`; its standard RIME data directory remained. The App
returned to `同步方式：未设置`. This is a manual Simulator observation, not a
passing XCTest, Files UI refresh assertion, cross-device propagation result,
or Product lifecycle decision.

## Environment and provenance

- Worktree: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`.
- Checked-out HEAD: `4a51228fc8e435d538e9a5f7342ae325502e1e66`; the worktree was dirty.
- Simulator: iPhone 18 Pro Max / iOS 27.0; UDID
  `C1B96097-D5CD-4FE3-BF01-C2C6B7DDDE20`.
- Installed bundle metadata: `com.DoubleShy0N.Universe-Keyboard`, version
  `1.0`, build `1`, developer-installed Simulator app. No rebuild or reinstall
  was performed for this manual run; executable-to-current-worktree provenance
  and binary digest are therefore `UNKNOWN`.
- Provider: `com.apple.FileProvider.LocalStorage`.
- Newly created isolated Files folder: `Universe-Rime-Sync-9F47C2A1`.
- Exact provider root:
  `/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/C1B96097-D5CD-4FE3-BF01-C2C6B7DDDE20/data/Containers/Shared/AppGroup/C41B6AAE-1FF7-4544-974E-366CE72B01F1/File Provider Storage/Universe-Rime-Sync-9F47C2A1`.
- This worktree's existing broad Simulator XCTest status is unchanged: the
  earlier provider-deletion attempt remains `1 failed / 0 passed` at its later
  Files UI query. This manual action has no `.xcresult` and does not repair or
  relabel that run.

## Ordered observation

1. The App settings screen showed `Universe-Rime-Sync-9F47C2A1` as the selected
   folder and the automatic-sync master switch off. No automatic sync was
   triggered.
2. A manually confirmed sync displayed `同步正常`. The direct children of the
   exact provider root were then:

   ```text
   universe-ios-b7640898-217b-44b8-b4b1-6b4cf2128bc1
   universe-rime-sync
   ```

   Read-only `stat` confirmed both were directories. No files or contents below
   either directory were opened.
3. The App's `删除云端数据并断开` confirmation explicitly said it would remove
   only the encrypted `universe-rime-sync` package at the current sync location
   and the local sync key, while preserving the standard RIME directory and
   other-device data. The current location was the new isolated folder above.
4. The first accessibility tap left the confirmation visible and an immediate
   directory listing still showed both children. The action was not counted as
   a deletion; `取消` closed the alert and no state change was observed.
5. After reopening the alert and refreshing the UI snapshot, the explicit
   `删除并断开` action returned the App to `同步方式：未设置`. At
   `2026-09-25 04:32:34 UTC` (`12:32:34 Asia/Shanghai`), the subsequent direct
   child listing—started immediately after that UI state—contained only:

   ```text
   universe-ios-b7640898-217b-44b8-b4b1-6b4cf2128bc1
   ```

   Read-only `stat` confirmed that exact standard RIME directory remained a
   directory. The private package root was absent from the direct-child listing.
   The time of the button press itself was not independently timestamped; the
   state observation is time-bounded to the App's just-completed UI flow and
   the capture above. No operation UUID or structured app diagnostic receipt
   was available for this manual action.

## Privacy and evidence limits

- Only the exact folder's direct child names and the standard directory's type
  were inspected. No encrypted package, settings payload, recovery-code value,
  RIME file, dictionary, database, or user input was read or recorded.
- The App screen briefly displayed its Simulator recovery-code field during
  navigation. That value is intentionally not reproduced in this receipt; the
  screenshot was not saved as an evidence artifact.
- The result supports one manual production-App path against Apple's Simulator
  Files local-storage provider. It does not prove Files UI refresh, persistence
  across reboot, another device's observation, cloud/third-party provider
  semantics, live WebDAV, CloudKit, physical-device behavior, background
  scheduling, or resolution of `TD-002`.
- No XCTest pass, source/binary identity match, hosted CI, full matrix, Product
  Gate, parent lifecycle transition, commit, push, PR, merge, TestFlight, or
  Release is claimed.

## Review and lifecycle

Evidence grade: `Executor-recorded`. Fresh independent Quality reviewed the
exact 64-path evidence/source candidate and returned `Pass with conditions`,
resolving `QR-PROVIDER-DELETE-01` as `fix` for the bounded observed-state check.
Fresh independent Architecture returned `Accept with conditions` for the
single Simulator LocalStorage architecture boundary. Both receipts record
reviewer/model identity limits; neither relabels the prior failed XCTest. The
reviews do not establish a Files UI refresh assertion, a passing automated
deletion test, an independently timestamped click/operation correlation, or
installed binary/source provenance. See [Quality receipt](../reviews/rime-sync-v1-local-folder-provider-deletion-quality-manual-review-2026-09-25.md)
and [Architecture receipt](../reviews/rime-sync-v1-local-folder-provider-deletion-architecture-manual-review-2026-09-25.md).

The parent Assignment remains `Active`; Product must make any later lifecycle
decision separately. `TD-002` remains open.
