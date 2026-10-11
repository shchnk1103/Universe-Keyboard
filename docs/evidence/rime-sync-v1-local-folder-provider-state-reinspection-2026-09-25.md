# RIME-SYNC-001 — local-folder provider state reinspection — 2026-09-25

## Purpose and evidence boundary

This receipt preserves a later, read-only reinspection of the exact
test-created Simulator Files folder named by the 2026-09-25 deletion attempt.
It was captured after the first attempt and its failed XCTest; it is **not** a
contemporaneous transcript of the original deletion command and does not prove
that no intervening actor could have changed the folder. It supplements, but
does not rewrite, the original [attempt receipt](rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md).

No app was launched, no sync or delete was triggered, and no files or provider
contents were changed. The inspection did not recurse into either data folder
or read file contents.

## Target and capture

- Simulator: iPhone 18 Pro Max / iOS 27.0; UDID
  `C1B96097-D5CD-4FE3-BF01-C2C6B7DDDE20`.
- Provider: `com.apple.FileProvider.LocalStorage`.
- Test-created folder: `Universe-Rime-Sync-0757F4BD`.
- Exact provider root:
  `/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/C1B96097-D5CD-4FE3-BF01-C2C6B7DDDE20/data/Containers/Shared/AppGroup/C41B6AAE-1FF7-4544-974E-366CE72B01F1/File Provider Storage/Universe-Rime-Sync-0757F4BD`.
- Capture time: `2026-09-25 02:21:25 +08:00` (`2026-09-24T18:21:25Z`).
- Provider-root directory mtime: `2026-09-25 01:54:31 +08:00`.
- RIME standard-data directory mtime: `2026-09-25 01:54:22 +08:00`.

The read-only query was bounded to the exact root and the two immediate child
paths:

```sh
ls -1A '<exact-provider-root>'
test -e '<exact-provider-root>/universe-rime-sync'
test -d '<exact-provider-root>/universe-ios-fc975f7e-1a69-401f-8d5c-340ba976396e'
stat -f '... %HT ... %Sm' '<exact-provider-root>' '<standard-data-directory>'
```

Observed output:

```text
universe-ios-fc975f7e-1a69-401f-8d5c-340ba976396e
private_package=absent
standard_rime_directory=present
provider_root_type=Directory provider_root_mtime=2026-09-25T01:54:31+0800
standard_root_type=Directory standard_root_mtime=2026-09-25T01:54:22+0800
```

Only the private package root's absence and the standard-data directory's
presence were checked. The standard-data directory's children and all package,
settings, and user-dictionary contents were not read.

## Assessment and non-claims

This is a direct, privacy-bounded observation of the same unique Simulator
provider folder after the original attempt. The directory mtimes are consistent
with the original run's time window, but they do not prove event causality or
exclude all intervening modification. Independent Quality must decide whether
this later snapshot plus the original `.xcresult` timeline is sufficient; if
not, a new isolated capture with its state output recorded at the point of
observation is required.

The original XCTest remains **failed** in its post-delete Files UI query. This
receipt does not make it a passing end-to-end test. It proves no Files UI
refresh, physical-device behavior, cross-device propagation, cloud or
third-party provider semantics, WebDAV, CloudKit, crash/interruption recovery,
or resolution of `TD-002`. Parent Assignment remains `Active` pending fresh
review and the separate Product lifecycle decision.
