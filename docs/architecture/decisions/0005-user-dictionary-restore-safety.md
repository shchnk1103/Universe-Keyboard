# ADR 0005: User Dictionary Restore Safety

## Status

Accepted; recovery backup implementation complete, concurrent-writer coordination pending

## Context

The current restore path removes current `{schema}.userdb*` files before copying the latest backup. A failed or accidental restore can silently destroy newer learning data.

## Decision

Before restoring a user dictionary, the main App must create a recovery backup of the current dictionary and verify that backup succeeded. Restore must abort if current learning data exists and the safety backup cannot be created. Silent overwrite is prohibited. The user must receive progress, success or actionable failure feedback.

## Alternatives Considered

- Keep direct overwrite: rejected because it can irreversibly lose current learning.
- Ask the user to manually back up first: rejected because safety should not depend on remembering a separate action.
- Merge arbitrary userdb files: rejected because compatibility and conflict semantics are not defined.

## Consequences

- Restore becomes a multi-step operation with a recoverable pre-restore snapshot.
- More storage and failure states must be handled.
- Current code creates and verifies a recovery backup before restore or reset, then attempts rollback from that copy if replacement fails.

## Risks

- Backup may race with an active Extension/librime writer.
- Insufficient storage can block restore.

## Follow-up Work

- Define Extension/session coordination during backup and restore.
- Add interruption and concurrent-writer evidence for backup, copy and recovery.

## Related Documents

- `docs/RIME_USER_DICTIONARY.md`
- `docs/TECH_DEBT.md`
- `docs/RELEASE_CHECKLIST.md`
