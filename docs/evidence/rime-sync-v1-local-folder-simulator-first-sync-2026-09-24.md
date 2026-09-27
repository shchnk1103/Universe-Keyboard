# RIME-SYNC-001 — local-folder first manual sync on Simulator — 2026-09-24

## Outcome

**Pass for one controlled iOS Simulator local-folder path.** A newly created,
uniquely named Files folder was selected in Universe Keyboard and the user-
confirmed first manual sync completed. The production ViewModel, Keychain,
RIME standard-sync service and local-folder transport were used. This is not
physical-device or third-party-provider acceptance evidence.

## Environment and provenance

- Repository/worktree: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`.
- Project/scheme: `Universe Keyboard.xcodeproj` / `UniverseKeyboardUITests`,
  Debug; isolated XcodeBuildMCP profile `rime-sync-localfolder-e2e` and
  DerivedData `/private/tmp/rime-sync-localfolder-e2e-derived`.
- Simulator: iPhone 18 Pro Max, iOS 27.0 (build `24A434`), UDID
  `C1B96097-D5CD-4FE3-BF01-C2C6B7DDDE20`.
- The signed simulator app resolved App Group
  `group.com.DoubleShy0N.Universe-Keyboard`; the Simulator reported its
  installed group container. The Files local-storage provider used
  `group.com.apple.FileProvider.LocalStorage`.
- Selected test: `RimeSyncSettingsUITests/testLocalFolderPickerCreatesIsolatedFolderAndCompletesFirstSync()`.
- Xcode result bundle:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T15-45-42-621Z_pid14565_f6e5716f.xcresult`.
  Independent `xcresulttool get test-results tests` reports one passed test on
  the simulator above; duration 232.74 seconds, no failed or skipped tests.
- The UI test uses launch argument
  `--rime-sync-ui-local-folder-integration`. The fixture uses a per-launch
  isolated UserDefaults suite and constructs the production `RimeSyncViewModel`
  with `RimeSyncSecretStore`, the production RIME service, and the production
  local-folder transport. Automatic/background execution is suppressed. The
  test opens Files, creates the unique folder, selects “RIME 标准文件夹”,
  chooses that folder in the app's system picker, taps “立即同步”, confirms
  “开始同步”, and asserts “同步正常”. It does not toggle automatic sync.

## Output verification

The test-created Files folder was `Universe-Rime-Sync-922D4B9F`. Its simulator
provider location was:

```text
.../File Provider Storage/Universe-Rime-Sync-07BCFA9A/
```

Read-only filename inspection found both expected output layers:

- RIME standard data under
  `universe-ios-0a1e5e0f-1b45-4020-bd2b-264fade42b4f/`:
  `luna_pinyin.userdb.txt`, `installation.yaml`, `rime_ice.custom.yaml`,
  `luna_pinyin.custom.yaml`, `default.custom.yaml`, and `user.yaml`.
- Universe package under `universe-rime-sync/`:
  `format.json` and `profiles/default/settings.json`.
- Public `format.json` metadata identifies format `universe-rime-sync`,
  version `1`, and `chacha20-poly1305` encryption.
- The encrypted settings payload is 4,091 bytes with SHA-256
  `0738c332e776e58d478ddb203478c5fbbe4c10da6c21bf25a9deacd942463d3e`.
  Its plaintext was not read or emitted.

An earlier run of the same UI flow used the UI fixture's fake private-settings
transport: it produced RIME standard files but no `universe-rime-sync/`
package. That run is explicitly excluded as full-sync evidence. The fixture
seam was changed and the passing result above was rerun through production
Keychain/transport. The historical blocked-before-selection receipt remains
unchanged.

## Limits and non-claims

- This proves one Simulator run through Apple's Files local-storage provider;
  it does not prove iPhone behavior, provider/cloud interoperability, or
  metadata/deletion propagation across another device.
- It does not prove live WebDAV, CloudKit, natural `BGProcessingTask` delivery,
  background timing, cross-process RIME safety, full portability, or resolution
  of `TD-002`, `TD-008`, `TD-013`, `TD-017`, `TD-019`, or the historical Run 02.
- The package was created from the clean Simulator's settings. No user input,
  real user dictionary, WebDAV account, remote object, existing folder, or
  physical device was used.
- Four folders created during UI-automation iterations remain in this
  disposable Simulator (`Universe-Rime-Sync-1C71C9FF`,
  `Universe-Rime-Sync-07BCFA9A`, `Universe-Rime-Sync-922D4B9F`, and
  `未命名文件夹`). Only the last result is the final production-path evidence;
  no pre-existing or remote data was deleted.
- No source baseline freeze, full suite, hosted CI, independent review,
  Assignment lifecycle transition, commit, push, PR, merge, TestFlight, or
  Release is claimed by this receipt.

## Next

Freeze the exact updated candidate, run the required local quality gate, obtain
fresh independent Quality and Architecture reviews bound to the final manifest,
and update Assignment/ACTIVE_WORK evidence pointers without claiming parent
closure. The reviewer must assess the still-open real-provider deletion
condition separately; this first-sync run does not test deletion.
