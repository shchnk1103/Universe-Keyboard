# Shared Container And RIME Lifecycle

## Purpose

This document defines the current runtime ownership boundary between the main App, Keyboard Extension, App Group container, and RIME. It describes current source behavior, not a future plan.

The binding decisions are ADR 0001 through ADR 0004 under `docs/architecture/decisions/`. ADR 0006 records the accepted future transaction model without claiming it is implemented.

## Shared Container Layout

Both targets use App Group `group.com.DoubleShy0N.Universe-Keyboard`.

| Location | Content | Writer | Reader |
|---|---|---|---|
| `Rime/shared/` | schema, dictionary, Lua, OpenCC and compiled `build/` data | Main App deployment and schema installation paths | Main App diagnostics; Keyboard Extension session |
| `Rime/user/` | RIME user data, custom YAML and `{schema}.userdb*` learning data | Main App configuration/deployment; librime runtime may update its user data | Main App backup/diagnostics; Keyboard Extension RIME session |
| `Rime/user_dictionary_backups/{schemaID}/{timestamp}/` | local user-dictionary backup plus `manifest.json` | Main App only | Main App only |
| App Group `UserDefaults` | settings, active schema, deploy flags, diagnostics, feedback levels and bounded typo-learning metadata | Main App; Extension only for explicitly runtime-owned state such as diagnostics and typo selection learning | Both targets |
| process temporary directory | downloaded archive and extraction workspace | Main App only | Main App only |

`Packages/RimeBridge/Vendor/` is a repository-local build dependency, not App Group runtime data.

## Ownership Rules

### Main App

The main App owns operations that can scan, create, replace or delete persistent RIME files:

- download, extract, install, update and uninstall schemes;
- generate `.custom.yaml` and post-process managed schema blocks;
- copy bundled RIME/OpenCC resources and invalidate build caches;
- run `RimeDeploymentService.deploy(.fullCheck)`;
- back up, restore or reset user-dictionary files;
- update deployment status flags.

These operations must not be moved into keyboard presentation or key handling.

### Keyboard Extension

At startup the Extension calls `RimeConfigManager.runtimeDirectories()`. This resolver is read-only: both `Rime/shared` and `Rime/user` must already exist.

- When directories exist, the Extension creates `RimeEngineImpl` and a new RIME session.
- When they do not exist, it uses the fallback adapter and logs that deployment must be completed in the main App.
- During input it may process keys, select candidates, clear/recreate a session and reselect the active schema.
- It must not generate YAML, install files, clear deployment caches or run full maintenance.

The Extension may write state that is inherently runtime-owned, including librime user data, bounded diagnostic output and explicit typo-correction selection learning. It must not synchronously scan, hash, copy or persist large data from a key-event hot path.

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

`viewDidLoad` builds controller state, resolves runtime directories, creates the RIME or fallback engine, caches settings and installs observers. The first `viewDidAppear` marks the view as presented and does not abandon composition.

### Disappearance

`viewWillDisappear` stops delete repeat and popup/expanded-candidate interactions, clears candidate presentation caches, resets press visuals, resets the RIME session and abandons unfinished composition, Partial Commit, typo state and marked preedit.

### Return of an existing controller

On every `viewDidAppear` after the first, the same cleanup runs again. The keyboard deliberately starts clean; unfinished composition is not restored across visibility changes.

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

## Source Of Truth

- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`
- `Keyboard/Controllers/KeyboardViewController.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+RuntimeDirectories.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+DeploymentResources.swift`
- `Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift`
- `Universe Keyboard/Services/SchemaArchiveInstaller.swift`
- `Universe Keyboard/Services/RimeUserDictionaryBackupService.swift`
