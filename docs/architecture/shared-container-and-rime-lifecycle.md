# Shared Container And RIME Lifecycle

## Purpose

This document defines the current runtime ownership boundary between the main App, Keyboard Extension, App Group container, and RIME. It describes current source behavior, not a future plan.

The binding decisions are ADR 0001 through ADR 0004 and ADR 0013 under `docs/architecture/decisions/`. ADR 0006 records the accepted future transaction model without claiming it is implemented.

## Shared Container Layout

Both targets use App Group `group.com.DoubleShy0N.Universe-Keyboard`.

| Location | Content | Writer | Reader |
|---|---|---|---|
| `Rime/shared/` | schema, dictionary, Lua, OpenCC and compiled `build/` data | Main App deployment and schema installation paths | Main App diagnostics; Keyboard Extension session |
| `Rime/user/` | RIME user data, custom YAML and `{schema}.userdb*` learning data | Main App configuration/deployment; librime runtime may update its user data | Main App backup/diagnostics; Keyboard Extension RIME session |
| `Rime/user_dictionary_backups/{schemaID}/{timestamp}/` | local user-dictionary backup plus `manifest.json` | Main App only | Main App only |
| App Group `UserDefaults` | settings, active schema, deploy flags, diagnostics, feedback levels, bounded typo-learning metadata and versioned Typing Intelligence aggregates | Main App; Extension only for explicitly runtime-owned state such as diagnostics, typo selection learning and Typing Intelligence aggregates | Both targets |
| process temporary directory | downloaded archive and extraction workspace | Main App only | Main App only |

`Packages/RimeBridge/Vendor/` is a repository-local build dependency, not App Group runtime data.

RIME settings sync uses main-App-private state rather than the App Group:

| Location | Content | Writer / Reader |
|---|---|---|
| Main App `UserDefaults` | provider choice, WebDAV URL/user name, security-scoped folder bookmark, device ID, last merged profile and last success date | Main App only |
| Main App Keychain | WebDAV password and 256-bit content-encryption key | Main App only |
| Selected folder or WebDAV root `universe-rime-sync/` | plaintext minimal `format.json` plus encrypted `profiles/default/settings.json` | Main App sync coordinator and compatible external clients |
| User-selected local/file-provider folder | RIME standard `sync_dir`: per-device `*.userdb.txt` snapshots and YAML/TXT backup created by librime | Main App only during confirmed initial sync and safety-gated background maintenance; compatible external RIME frontends |

The Keyboard Extension does not read sync credentials or sync contents and never receives WebDAV credentials or encryption keys. It never calls `sync_user_data`; while visible it only writes a content-free activity heartbeat so the main App can conservatively defer background maintenance.

## Ownership Rules

### Main App

The main App owns operations that can scan, create, replace or delete persistent RIME files:

- download, extract, install, update and uninstall schemes;
- generate `.custom.yaml` and post-process managed schema blocks;
- copy bundled RIME/OpenCC resources and invalidate build caches;
- run `RimeDeploymentService.deploy(.fullCheck)`;
- back up, restore or reset user-dictionary files;
- encrypt, upload, download, merge and apply portable RIME settings;
- after explicit user confirmation, refresh managed `.custom.yaml` and call librime standard user-data sync while the keyboard is not in use; after the first success, the main App may repeat this via the documented background safety gate;
- update deployment status flags.

These operations must not be moved into keyboard presentation or key handling.

### Keyboard Extension

At startup the Extension calls `RimeConfigManager.runtimeDirectories()`. This resolver is read-only: both `Rime/shared` and `Rime/user` must already exist.

- When directories exist, the Extension creates `RimeEngineImpl`, opens a new RIME session and confirms the requested schema can be selected. Healthy cold startup does not synthesize input or enumerate every schema; deeper functional validation remains in explicit recovery/failure paths.
- When they do not exist, it uses the fallback adapter and logs that deployment must be completed in the main App.
- During input it may process keys, select candidates, clear/recreate a session and reselect the active schema.
- It must not generate YAML, install files, clear deployment caches or run full maintenance.

The Extension may write state that is inherently runtime-owned, including librime user data, bounded diagnostic output and explicit typo-correction selection learning. It must not synchronously scan, hash, copy or persist large data from a key-event hot path.

Typing Intelligence is a separate bounded runtime-owned writer. Final committed text is classified in memory and discarded; only content-free aggregate deltas enter an ordered utility writer. JSON/defaults reads and writes are outside key handling. The main App reads snapshots and controls enable/reset. Reset advances an epoch before deleting the payload so stale Extension batches cannot restore cleared data.

Typing Intelligence does not use `Rime/shared`, `Rime/user`, candidate storage or keyboard visibility callbacks. Sudden Extension termination may lose one bounded unflushed aggregate batch; typing correctness takes priority over statistical durability.

## Deployment Lifecycle

1. The main App prepares `Rime/shared` and `Rime/user`.
2. It installs or updates source configuration and resources.
3. It sets `rime_deployed=false`, `rime_needs_deploy=true`, then starts deployment.
4. `RimeDeploymentService` serializes `.fullCheck` deployment in an actor and calls the ObjC deployer.
5. On success the App records deployed state and, for `rime_ice`, records the runtime Lua smoke result.
6. On failure it keeps deployment pending and exposes retry/diagnostic state.
7. A subsequently created keyboard process opens the prepared directories and creates a session. It does not validate or repair the installation.

Deployment flags are status signals, not a transaction log. File installation is currently performed file-by-file; atomic whole-scheme replacement and rollback are not guaranteed by the current implementation.

ADR 0006 requires a future atomic directory switch or equivalent transaction model. That work remains High-priority technical debt.

## Keyboard Lifecycle

### First presentation

`viewDidLoad` builds controller state, resolves runtime directories and installs the in-memory fallback engine, but does not start librime. iOS can precreate a keyboard extension and suspend it without sending a view-disappearance callback; opening the RIME user dictionary in that state would leave a file lock and trigger `0xdead10cc`. The first `viewDidAppear` starts librime, creates its session and then marks the view as presented. Later visibility returns refresh the snapshot; the Extension does not rely on process-local `UserDefaults.didChangeNotification` for main-App writes.

### Disappearance

`viewWillDisappear` stops delete repeat and popup/expanded-candidate interactions, clears candidate presentation caches, resets press visuals, resets the RIME session and abandons unfinished composition, Partial Commit, typo state and marked preedit. It then synchronously finalizes the Extension-owned librime runtime before UIKit can suspend the process. This release is tied to visibility rather than `deinit`, because UIKit may retain hidden keyboard controllers and iOS terminates suspended extensions that still hold RIME database file locks.

The diagnostic writer also enters an ordered suspended state at this boundary. Pending best-effort records are discarded and no delayed App Group write remains scheduled; input correctness and suspension safety take priority over preserving the last diagnostic batch.

### Return of an existing controller

`viewWillAppear` first resumes diagnostic intake, then reinitializes librime, creates a fresh session and reselects the active schema before accepting input. On every `viewDidAppear` after the first, the same transient-state cleanup runs again. The keyboard deliberately starts clean; unfinished composition is not restored across visibility changes.

### Runtime session failure while still visible

This is different from visibility cleanup. Input recovery may rebuild the current RIME session and replay raw input when the engine ignores a printable key or loses its session. It still cannot run deployment.

### Extension process termination

All in-memory controller, composition, candidate paging and session state is lost. A new process creates a fresh controller and session from deployed App Group data. The project does not persist or restore unfinished composition across process death.

## Failure Boundaries

- Missing runtime directories: use fallback behavior; return to the main App to deploy.
- Installed files but stale/pending deployment: main App must redeploy; Extension continues with the last prepared runtime it can open.
- Session loss while visible: session-owned recovery may recreate/reselect; never full deploy.
- Corrupt or partial scheme installation: main App redownload/reinstall and redeploy path; no Extension repair.
- User-dictionary backup/restore: perform only from the main App when the keyboard is not actively relying on an in-memory session.
- Portable settings sync failure: keep the current local settings; authentication, key, corruption and conflict failures must remain actionable in the main App.
- Standard RIME sync failure: keep local runtime data and show an actionable main-App error; do not copy live databases or import another device's YAML. Automatic retries wait for a later user-selected cycle rather than retrying in a tight loop.
- Applying a merged settings profile: persist only recognized fields, preserve unknown remote fields in the sync profile, then use the normal main-App deployment path.

## Source Of Truth

- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`
- `Keyboard/Controllers/KeyboardViewController.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+RuntimeDirectories.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+DeploymentResources.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeStandardSyncService.swift`
- `Universe Keyboard/Services/SchemaArchiveInstaller.swift`
- `Universe Keyboard/Services/RimeUserDictionaryBackupService.swift`
- `Universe Keyboard/Services/RimeSyncCoordinator.swift`
- `Universe Keyboard/Services/RimeSyncTransport.swift`
- `Universe Keyboard/Models/RimeSyncViewModel.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/TypingStatisticsStore.swift`
- `Universe Keyboard/Models/TypingIntelligenceViewModel.swift`
