# ADR 0003: Shared Container Ownership

## Status

Accepted

## Context

The main App and Extension share RIME data, preferences and diagnostics through one App Group. Unclear ownership can place scans, file replacement or deployment in the input hot path.

## Decision

`Rime/shared` is prepared and structurally modified by the main App and consumed by Extension sessions. `Rime/user` is prepared/configured by the main App and may be updated by librime runtime learning; backup, restore, hashing and reset remain main-App operations. User-dictionary backups and temporary install data are main-App-only. App Group preferences may be read by both targets; Extension writes must be bounded, runtime-owned and non-blocking.

## Alternatives Considered

- Treat both targets as equal filesystem writers: rejected because ordering and recovery become undefined.
- Make all shared data read-only to the Extension: rejected because librime learning/runtime state may require user-data writes.
- Duplicate data per target: rejected because deployment and active schema would diverge.

## Consequences

- Every new shared file/key needs an explicit owner and lifecycle.
- Large scans, copies and hashes are prohibited from key handling.
- `Rime/user` concurrent access remains a validation obligation.

## Risks

- librime writes can overlap with main-App backup/restore.
- App Group denial may disable shared capabilities.

## Follow-up Work

- Validate the `Rime/user` concurrent access model and define coordination if required.
- Maintain the directory ownership table.

## Related Documents

- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/TECH_DEBT.md`
