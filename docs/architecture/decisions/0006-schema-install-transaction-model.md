# ADR 0006: Schema Install Transaction Model

## Status

Accepted; implementation pending

## Context

The current installer copies and replaces schema files one by one in `Rime/shared`. Interruption or failure can leave a mixed installation that is neither the previous version nor the new version.

## Decision

Schema installation must evolve to an atomic directory switch or an equivalent transaction model with staging, validation, commit and rollback. Until implemented, the current file-by-file installer remains a documented High-priority technical debt and must not be described as atomic.

## Alternatives Considered

- Keep file-by-file replacement permanently: rejected because partial installations are observable by deployment/runtime.
- Rely only on redownload after failure: rejected because it does not prevent mixed state.
- Put all installation logic in the Extension: rejected by ADR 0001.

## Consequences

- Future installer work needs an explicit transaction boundary and recovery marker.
- Release validation must continue testing interrupted/incomplete installation recovery.
- No runtime behavior changes in this phase.

## Risks

- Filesystem rename/replace semantics inside the App Group must be validated.
- User data must never be included in destructive schema rollback.

## Follow-up Work

- Design staging directory, validation manifest, atomic commit and cleanup.
- Add failure-injection tests before migration.

## Related Documents

- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/TECH_DEBT.md`
