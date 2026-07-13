# ADR 0007: Full Access And Privacy Boundary

## Status

Accepted; implementation pending. The no-upload clause is partially superseded by
[ADR 0012](0012-rime-portable-sync-and-transport-boundary.md) only for explicit,
revocable, end-to-end encrypted RIME synchronization initiated by the main App.
All other privacy and Full Access boundaries remain in force.

## Context

The Extension requests Full Access because shared App Group settings, diagnostics and managed RIME data depend on capabilities unavailable or unreliable without it. Pretending all features work when access is absent creates silent failure and weakens user trust.

## Decision

Without Full Access, the keyboard may retain basic local key insertion and any process-local behavior that actually works, but shared RIME runtime/configuration, scheme updates, cross-target settings, diagnostics, persisted feedback settings, user-dictionary management and other App Group-dependent capabilities must be treated as unavailable or degraded. The UI must provide plain-language, actionable status instead of claiming success.

The main App must not claim it can always know the Extension's live access state before the Extension runs. Prompts must be based on observed capability/failure rather than an invented authoritative main-App flag.

No typed content, surrounding host text, user dictionary, diagnostic log or correction-learning record may be uploaded or leave the device. Network access is limited to explicit main-App scheme/artifact download flows; keyboard input is not telemetry.

## Alternatives Considered

- Hide all access failures: rejected because users cannot recover.
- Hard-block every setting before the Extension runs: rejected because the main App cannot reliably know live Extension access in advance.
- Upload diagnostics/typing data for troubleshooting: rejected by the local privacy boundary.

## Consequences

- Capability-specific unavailable/degraded states and recovery copy are required.
- Basic typing must not be falsely described as proof that shared RIME features are healthy.
- Current UI does not yet implement a complete degradation matrix.

## Risks

- iOS capability behavior may differ by version and process state.
- Overly broad warnings can unnecessarily block usable local behavior.

## Follow-up Work

- Define and implement the Full Access degradation matrix.
- Verify each state on a physical device with access on/off.
- Audit logs for private input leakage.

## Related Documents

- `docs/PROJECT_CONTEXT.md`
- `docs/DEBUGGING.md`
- `docs/TECH_DEBT.md`
