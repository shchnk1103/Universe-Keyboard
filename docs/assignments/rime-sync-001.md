# Assignment: RIME-SYNC-001 — Portable RIME Settings Sync

**Policy version:** `1.0.0`

**Decision source / date:** Human Product Owner authorization in the active cross-platform RIME sync objective, followed by explicit approval of RIME 标准同步主路径 / `2026-07-12 Asia/Shanghai`; manual RIME 用户词典安全恢复与设置入口调整、默认自动标准同步、冷却时间和本地通知 revalidated by the human Product Owner / `2026-07-13 Asia/Shanghai`

**Lifecycle status:** `Active`

**Repository change types:** `Contract`, `Documentation`; later `Implementation`, `Evidence`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Product Approver:** Product Lead acting under the human owner's explicit role delegation
- **Assignment Revalidation Authority:** Product Lead
- **Product Contract:** [`docs/RIME_SYNC.md`](../RIME_SYNC.md)
- **Architecture Decision:** ADR 0012 and [ADR 0013](../architecture/decisions/0013-rime-standard-sync-interoperability.md)

## Acknowledgement And Activation

- **Executor acknowledgement:** `2026-07-11 Asia/Shanghai` — contract and architecture investigation accepted.
- **Architecture acknowledgement:** ADR 0012 accepted with implementation pending.
- **Product lifecycle decision:** `Assigned -> Acknowledged -> Ready -> Active` for Contract and Architecture work only.
- **Implementation authorization:** Human Product Owner explicitly opened code implementation on `2026-07-12 Asia/Shanghai`.
- **Current phase:** Standard RIME sync main-path implementation, manual user-dictionary recovery safety hardening and automated validation active; physical-device, cross-front-end and configuration-import gates remain open.

## Assignment

- **Domain Owner:** App & Data Operations Maintainer
- **Executor:** App & Data Operations Maintainer, coordinating bounded RIME Platform and documentation work packages
- **Environment Executor:** Quality, Performance & Release Maintainer for build/simulator/network-fixture evidence; human owner for physical-device, provider-account and future CloudKit entitlement evidence
- **Human Dependency:** Human owner for explicit implementation authorization, physical-device interactions and future Apple Developer Program/container access; CloudKit is not an Entry Criterion for WebDAV/local-folder V1
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer
- **Product Approver:** Product Lead
- **Handoff Target:** Product Lead for Product Review, then Program Manager for owner-confirmed status synchronization

## Scope

1. Publish the portable sync Product Contract and ADR.
2. Define a versioned, transport-independent, encrypted sync package.
3. Add main-App-only sync orchestration and a polished native settings surface.
4. Implement WebDAV and local-folder adapters first.
5. Use librime standard `sync_dir` / `sync_user_data` for user-data snapshots and per-device YAML/TXT backup; after one confirmed initial sync, allow user-configurable, safety-gated automatic maintenance; retain encrypted managed settings as an auxiliary layer.
6. Apply managed settings through existing persistence and normal main-App deployment; require staging, validation and a recovery snapshot before any later cross-device YAML import.
7. Add deterministic offline merge and non-destructive conflict preservation.
8. Add privacy, credential, deletion, error, migration and recovery contracts.
9. Produce unit, integration, UI, interruption, security and cross-platform compatibility evidence.
10. Revalidate CloudKit only after membership, container and entitlement prerequisites exist.

## Non-goals

- No implementation code until the human owner explicitly opens implementation under `AGENTS.md`.
- No network or sync work in Keyboard Extension or KeyboardCore.
- No user dictionary, Typing Intelligence, diagnostics, logs, Typo learning or typed-content enters the encrypted Universe private package.
- No automatic RIME standard sync before the first confirmed manual sync, while the keyboard is active, or without the documented cooldown/background-task safety gate; no live database copy, cross-device YAML import or silent configuration overwrite.
- No live `*.userdb*` copying, automatic restore or silent overwrite.
- No Universe-hosted account/backend in this Assignment.
- No claim of real-time iOS background sync.
- No unrelated refactor or cleanup of the existing dirty worktree.

## Required Inputs

- `docs/RIME_SYNC.md`
- ADR 0003, 0005, 0007 and 0012
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/RIME_USER_DICTIONARY.md`
- `docs/UI_STYLE_GUIDE.md`
- `docs/PRIVACY_POLICY.md`
- `docs/TECH_DEBT.md`
- `docs/DEBUGGING.md`
- `docs/RELEASE_CHECKLIST.md`
- current Settings UI, RimeSettingsStore, deployment service and RimeBridge API surface
- official RIME user-sync contract and bundled `RimeApi.sync_user_data` header
- current Apple membership, capability and CloudKit requirements before CloudKit work

## Entry Criteria

### Contract And Architecture

- Product objective and role delegation are explicit.
- Assignment contains no `UNKNOWN` fields.
- repository and official documentation investigation is complete.

### Implementation

- Human owner explicitly authorizes code implementation.
- Privacy policy is updated for explicit encrypted synchronization.
- Sync package schema, encryption suite, credential storage and deletion semantics are accepted.
- Managed-field allowlist, package limits and deterministic conflict semantics are testable; file staging/rollback remains a prerequisite for the deferred file phase.
- Worktree scope is isolated from unrelated active changes.

### Standard RIME User-Data Sync

- The human owner explicitly approves standard RIME interoperability and the privacy boundary.
- The operation is manual, main-App-only and presents explicit confirmation that the keyboard is not in use.
- librime snapshot merge is used; live database copy, restore and overwrite remain prohibited.
- Automatic follow-up runs only after this first success, from the main App background task, with keyboard-activity, folder-access and cooldown checks plus truthful non-realtime copy.
- Physical-device, cross-process and cross-front-end evidence are recorded before Product acceptance.

### CloudKit Follow-up

- Active Apple Developer Program membership and admin permissions exist.
- iCloud container and entitlements are provisioned.
- Development and production environment verification is available on physical devices.

## Exit Criteria

- Portable package and transport contracts have executable compatibility tests.
- WebDAV and local-folder V1 pass interruption, retry, conflict, corruption and deletion tests.
- Settings UI passes light/dark, Dynamic Type, VoiceOver and narrow-device checks.
- Imported managed settings deploy only from the main App and do not replace the keyboard's last usable deployment on failure.
- Keyboard hot path and offline typing remain unchanged.
- Cross-platform fixtures round-trip on representative iOS/macOS/Windows/Linux/Android clients or approved compatibility tools.
- Documentation, privacy, debugging, release and changelog impacts are complete.
- Architecture, Quality and Product reviews issue independent conclusions.

## Stop Conditions

- Any initial standard-sync path transfers user data without explicit confirmation or clear non-encryption disclosure; any automatic path runs without the documented initial-success, inactive-keyboard, cooldown and main-App-only boundary.
- Implementation would copy/replace a live RIME user database.
- A provider forces transport-specific state into the portable domain model.
- Recovery snapshot or non-destructive conflict preservation cannot be guaranteed.
- CloudKit work begins without verified membership/container/entitlement prerequisites.
- Required physical-device, provider, security or cross-platform evidence is unavailable.
- Scope overlaps unrelated dirty-worktree changes without a clean file boundary.

## Handoff

- **Required Handoff Content:** product contract, ADR, package schema, threat model, implementation diff, test matrix, cross-platform fixtures, provider evidence, privacy/deletion proof, skipped gates and residual risks.
- **Revalidation Trigger:** any change to synced data categories, default enablement, encryption, retention/deletion, transport priority, hosted backend, Extension network boundary, user-dictionary scope, CloudKit prerequisites, owners, reviewers or acceptance platforms.
