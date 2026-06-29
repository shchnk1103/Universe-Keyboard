# ADR 0002: Visibility Change Abandons Composition

## Status

Accepted

## Context

After switching host apps, dismissing the keyboard or re-presenting an existing controller, host text state and the RIME session may no longer describe the same marked range. Restoring in-memory composition can duplicate text or revive stale input.

## Decision

Host-app switching, keyboard disappearance and Extension visibility changes abandon unfinished composition, marked text, Partial Commit state, typo state and candidate presentation caches. They do not attempt to restore or commit stale input. Runtime session recovery while the same keyboard presentation remains active is a separate path and may replay current raw input.

## Alternatives Considered

- Persist and restore composition across visibility changes: rejected because the host marked-range contract cannot be trusted.
- Commit composition automatically on disappearance: rejected because it changes user text without an explicit commit action.
- Keep UI state and only reset RIME: rejected because UI and engine state can diverge.

## Consequences

- Returning to the keyboard starts from a clean composition state.
- Uncommitted input is intentionally lost on visibility change.
- Tests must distinguish visibility cleanup from active-session recovery.

## Risks

- Users may perceive discarded unfinished input as inconvenient.
- A future lifecycle refactor could accidentally reintroduce stale restoration.

## Follow-up Work

- Preserve regression coverage for first appearance, later appearance and disappearance.
- Revisit only through a new ADR with host-state evidence.

## Related Documents

- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/architecture/input-pipeline-and-marked-text.md`
