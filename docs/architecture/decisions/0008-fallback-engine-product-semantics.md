# ADR 0008: Fallback Engine Product Semantics

## Status

Accepted

## Context

When prepared RIME directories are missing, the Extension wraps the fallback candidate provider so the keyboard can remain responsive. This path does not prove that real RIME, the selected schema, Lua or OpenCC is available.

## Decision

Fallback is a safe degraded mode, not an equivalent production RIME mode and not a repair mechanism. It may preserve basic keyboard interaction and deterministic fallback candidates, but must not claim that the selected RIME scheme or compiled features are active. Diagnostics and user-facing recovery must direct the user to prepare/deploy RIME in the main App. Fallback must never trigger deployment itself.

## Alternatives Considered

- Fail closed and disable the keyboard: rejected because basic interaction can remain available.
- Present fallback as normal RIME: rejected because it hides broken deployment.
- Auto-deploy from fallback: rejected by ADR 0001.

## Consequences

- Tests must keep fallback behavior separate from real-RIME acceptance.
- Product copy must distinguish degraded availability from successful deployment.
- Release acceptance must verify both normal and missing-runtime paths.

## Risks

- Users may not recognize degraded mode if UI feedback is insufficient.
- Fallback results may differ substantially from real schemes.

## Follow-up Work

- Define the minimal user-facing degraded-state message.
- Add acceptance coverage for missing runtime directories.

## Related Documents

- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/DEBUGGING.md`
- `docs/RELEASE_CHECKLIST.md`
