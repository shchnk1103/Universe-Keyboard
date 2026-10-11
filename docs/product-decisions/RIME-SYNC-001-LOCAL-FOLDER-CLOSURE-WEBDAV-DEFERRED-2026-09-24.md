# Product Decision: RIME-SYNC-001 local-folder closure; WebDAV validation deferred

## Decision

**Accepted — narrow the current RIME-SYNC-001 iOS V1 closure evidence scope to
the local-folder path. Defer live WebDAV validation to a future bounded task.**

- Current closure evidence will validate the RIME standard-sync and encrypted
  Universe settings paths through one user-selected local folder.
- The WebDAV adapter and settings UI remain in the application. This decision
  does not remove code, claim WebDAV validation, or accept unknown WebDAV
  behavior as safe. Live WebDAV provider/server validation is deferred to
  [`tech_debt:TD-019`](../TECH_DEBT.md#td-019-live-webdav-provider-validation).
- CloudKit remains separately deferred; full cross-platform compatibility
  remains tracked by `TD-008`.
- Simulator validation may use a newly created, isolated folder selected
  through the Simulator's document picker. It can establish the tested
  Simulator/local-folder behavior only; it does not prove iCloud or third-party
  File Provider propagation, physical-device behavior, or WebDAV behavior.
- No remote or existing user data may be deleted as part of the Simulator run.
  The test target must be created for this run and contain no pre-existing user
  data. Any later validation that writes to or deletes from an external provider
  or server requires a separately bounded authorization.

## Rationale and boundary

The Human Product Owner stated on `2026-09-24 Asia/Shanghai` that WebDAV is a
future testing project and authorized the Executor to choose a sync folder in
Simulator and continue. This decision formalizes that direction without
converting the existing fake-transport/unit/UI checks into live WebDAV evidence.
Universe Keyboard has no Universe-owned account or hosted sync service; any
future WebDAV credential is external server configuration.

This is an evidence-scope deferral, not a feature-removal decision or a claim
that the local-folder Architecture evidence condition is already met. The
fresh Architecture review's provider metadata/deletion condition remains open
until the authorized local-folder observation is recorded and reviewed. A
Simulator-only result must retain its provider and environment limits.

## Required follow-up

- Update the Assignment and Product Contract to make local-folder the current
  closure path and reference TD-019 for future live WebDAV validation.
- Run the authorized local-folder setup/sync only in an isolated Simulator
  directory, record exact Simulator/build/result provenance, and preserve
  non-claims.
- Before claiming WebDAV validation, create a separately scoped Assignment and
  authorization for a disposable external WebDAV namespace, credentials,
  operations and deletion boundaries.

## Non-claims

This decision is not a Quality or Architecture pass, not a Product Gate or
Assignment close, and not authorization for real-provider/remote destructive
operations, commit, push, PR, merge, TestFlight or Release.
