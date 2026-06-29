# ADR 0001: Main App Owns RIME Deployment

## Status

Accepted

## Context

Full RIME deployment writes configuration, compiles runtime data, invalidates caches and may take long enough to block keyboard input. The Keyboard Extension has a constrained lifecycle and latency-sensitive key path.

## Decision

Only the main App may prepare persistent RIME resources and run `RimeDeploymentService.deploy(.fullCheck)`. The Extension may open prepared directories, create or recover a session and process input, but must never download, repair, invalidate caches or run maintenance/deployment.

## Alternatives Considered

- Deploy on first Extension launch: rejected because it adds blocking file and engine work to presentation.
- Allow emergency Extension deployment: rejected because it creates two writers and an unpredictable recovery path.
- Remove the main App and bundle a fixed runtime: rejected because scheme/settings updates require managed deployment.

## Consequences

- Settings that alter compiled RIME behavior take effect only after main-App deployment.
- Missing/stale runtime data must route the user back to the main App.
- Session recovery and deployment remain separate concepts.

## Risks

- Users may open the keyboard before deployment completes.
- Incorrect deployment flags may disagree with actual files.

## Follow-up Work

- Keep deployment status actionable in the main App.
- Add transaction/rollback guarantees under ADR 0006.

## Related Documents

- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/DEBUGGING.md`
- `docs/RELEASE_CHECKLIST.md`
