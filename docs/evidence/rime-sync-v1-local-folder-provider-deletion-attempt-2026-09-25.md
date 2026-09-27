# RIME-SYNC-001 — local Files provider deletion attempt — 2026-09-25

## Outcome

**Provider deletion observed on one isolated iOS Simulator Files local-storage
folder; the enclosing UI test is not a pass.** The production App flow completed
first sync, accepted the explicit “删除并断开” confirmation, and returned to
“尚未配置”. A read-only inspection of the same Simulator's File Provider
storage after the operation found the private package absent while the RIME
standard-data folder and files remained. The test then failed in its
post-deletion Files UI navigation/assertion, so no green end-to-end `.xcresult`
is claimed.

## Run identity and isolation

- Worktree: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`.
- Simulator: iPhone 18 Pro Max, iOS 27.0, UDID
  `C1B96097-D5CD-4FE3-BF01-C2C6B7DDDE20`.
- Files provider: `com.apple.FileProvider.LocalStorage`; the target was a new,
  randomly named folder created by this attempt in that Simulator's local Files
  provider container. Its observed container folder was
  `Universe-Rime-Sync-0757F4BD`.
- The test used the production `RimeSyncViewModel`, production Keychain and
  production local-folder transport. It did not use WebDAV, CloudKit, a physical
  device, or a pre-existing user folder.
- No complete test suite passed in this attempt. The first execution ended
  `1 failed / 0 passed` after the provider delete action, at the subsequent
  Files UI navigation/assertion. Result bundle:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T17-52-12-930Z_pid14565_c881324b.xcresult`.
  The failure was in the post-delete UI query, not in the delete operation.
- A second execution ended before folder creation/synchronization because the
  Files UI remained in its sidebar/menu state and did not expose the expected
  “新建文件夹” action. It performed no sync or delete. Result bundle:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T17-56-58-614Z_pid14565_76c6326c.xcresult`.

## Observed provider state after the first execution

After the App's deletion flow returned to “尚未配置”, a host-side read-only
inspection of the Simulator's Files local-storage container found:

- `universe-rime-sync/` absent from `Universe-Rime-Sync-0757F4BD`;
- the RIME standard-data subfolder still present, including
  `luna_pinyin.userdb.txt`, `installation.yaml`, the custom YAML files and
  `user.yaml`;
- no contents of the encrypted settings package or user dictionary were read.

The inspection was scoped to the exact Simulator UDID, App Group container and
unique test-created folder. No folder, standard-data file, or other Simulator
content was manually removed. This is direct evidence of the local provider's
post-operation filesystem state, but not a fresh Files UI listing assertion.

## Evidence boundary

- Supports: one production-path deletion attempt against a test-created Files
  local-storage folder removed the `universe-rime-sync` package while preserving
  the RIME standard-data folder on that Simulator.
- Does not support: a passing end-to-end UI test, another device observing the
  deletion, cloud/third-party provider semantics, WebDAV, CloudKit, crash or
  interruption recovery, physical-device behavior, or resolution of `TD-002`.
- The failed UI-test status remains visible; do not count it as a test pass.
- Parent Assignment remains `Active`. Fresh independent Quality and Architecture
  review must determine whether this bounded provider observation satisfies the
  remaining evidence condition. Product lifecycle authorization remains a
  separate decision.

## Next

Request fresh independent Quality and Architecture review of this exact evidence
and the current bounded candidate. If either reviewer requires a Files UI
listing assertion, stabilize the Files navigation in a separate test-only
follow-up before seeking parent lifecycle disposition.
