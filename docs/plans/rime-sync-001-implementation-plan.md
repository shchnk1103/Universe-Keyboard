# RIME-SYNC-001 Implementation Plan

> **Lifecycle:** Active
>
> **Current phase:** RIME 标准同步主路径 implemented; automated core validation passed; physical-device and cross-front-end evidence pending
>
> **Current Source of Truth:** [`RIME_SYNC.md`](../RIME_SYNC.md)
>
> **Related ADR:** [ADR 0012](../architecture/decisions/0012-rime-portable-sync-and-transport-boundary.md)

## Delivery Order

### Phase 0 — Contract Freeze

- Freeze package fields, file allowlist, limits, logical version rules and conflict records.
- Freeze encryption, recovery-code, credential and remote-deletion behavior.
- Update privacy, shared-container, debugging, release and debt sources before implementation.

### Phase 1 — Local Domain And Package

- Add UI-independent package models and canonical encoding.
- Add deterministic managed-setting merge, package versioning and size limits.
- Defer content hashing, staging validation, path traversal rejection and immutable file conflict preservation until the custom-file phase.
- Add golden fixtures consumable outside Swift.

### Phase 2 — Main-App Local Folder And RIME Standard Sync

- Add main-App sync coordinator and serialized operation state.
- Add security-scoped folder selection, bookmark recovery and explicit `立即同步`.
- Apply validated profiles through current settings persistence and deployment flow.
- Verify interruption and provider-unavailable recovery without claiming reliable background execution.
- Configure the user-selected folder as librime `sync_dir` and invoke `sync_user_data` only after explicit main-App confirmation.
- Keep the first standard user-data sync manual and explicitly confirmed. After its success, permit only safety-gated background maintenance using the same librime snapshot path; never copy live user databases or auto-import another device's YAML/TXT backup.

### Phase 3 — Private WebDAV Settings

- Add credential storage, capability probing, ETag/conditional-write handling and resumable idempotent object transfer for the encrypted Universe settings package only.
- Keep remote layout append-friendly and avoid relying on provider-specific locking.
- Add local test server fixtures for auth, timeout, stale ETag, partial write and corruption.

### Phase 4 — Settings UX

- Add a “数据与同步” section and `RIME 云同步` navigation row.
- Build a native `Form` detail page using existing components and global toast.
- Keep one main-App-owned observable sync model as the UI source of truth; inject transport/package services and keep retry/offline policy outside view bodies.
- Use `.task` only for view-lifecycle refresh, treat cancellation as normal, and keep long-running sync alive in the coordinator rather than tying it to one detail view.
- Present stable status, provider, content scope, E2EE/recovery and destructive management.
- Add deterministic previews for configured, syncing, offline, auth failure, wrong key, conflict and empty states without live network dependencies.
- Validate light/dark, Dynamic Type, VoiceOver, narrow devices and offline states.

### Phase 5 — Cross-Platform Compatibility

- Publish the package specification and test vectors.
- Build or adapt a small compatibility CLI for macOS/Windows/Linux.
- Define Android integration against Trime/fcitx5-compatible user directories without assuming identical platform paths.
- Verify unknown-field preservation and platform-specific file filtering.

### Phase 6 — Quality And Product Review

- Run build/unit/integration/UI/security/interruption matrices.
- Verify no network, scan, crypto or persistence enters key handling.
- Perform physical-device Full Access on/off and foreground/background opportunity checks.
- Complete Product Review and synchronize Dashboard state only after owner decisions exist.

### Follow-up Phase — Standard User-Data Evidence

- Record real-device background, cancellation, keyboard-active and notification-permission evidence for the implemented main-App-only librime `sync_user_data` path.
- Verify `*.userdb.txt` snapshot merging and per-device YAML/TXT backup with compatible macOS, Windows, Linux and Android RIME frontends; never copy live databases.
- Keep ADR 0005 and TD-002 as separate gates for local backup, restore, reset and any future broader user-data operation.

### Deferred Phase — CloudKit

- Revalidate after paid membership and container access exist.
- Implement CloudKit as a `SyncTransport`, not a second sync model.
- Verify development and production containers, account state, quota, push/fetch behavior and non-Apple access strategy before claiming cross-platform coverage.

## Validation Matrix

| Area | Minimum evidence |
|---|---|
| Package | canonical bytes, migration, unknown fields, invalid paths, size limits |
| Merge | offline concurrent settings, same-file divergence, deterministic replay |
| Security | encryption test vectors, wrong key, tamper detection, credential redaction |
| Recovery | staging failure, low storage, interrupted apply, deployment failure |
| WebDAV | auth, ETag race, timeout, partial transfer, server capability variance |
| UI | loading/success/failure, Dynamic Type, VoiceOver, light/dark, narrow device |
| Runtime | Extension offline, input hot path unchanged, main-App-only deployment |
| Platforms | representative RIME `sync_dir` snapshot merge plus per-device YAML/TXT layout on iOS/macOS/Windows/Linux/Android frontends |

## Documentation Impact

Before implementation completion, review and update:

- `docs/PRIVACY_POLICY.md`
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/PROJECT_CONTEXT.md`
- `docs/DEBUGGING.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/PERFORMANCE_BASELINE.md`
- `docs/TECH_DEBT.md`
- `docs/KNOWLEDGE_INDEX.md` and `docs/READING_MAPS.md`
- `CHANGELOG.md` only after behavior exists

This plan is not current implementation truth and must be archived or superseded after delivery.
