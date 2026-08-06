# ADR 0004: RIME Runtime And Session Model

## Status

Accepted

## Context

librime is bridged through Objective-C and is treated as non-thread-safe. Deployment and typing have different latency, ownership and lifecycle requirements.

## Decision

The main App uses the actor-serialized deployer for full maintenance. The Extension creates a process-local `RimeEngineImpl` session from prepared directories and performs session operations on the main actor/thread. Active-session failures may recreate the session, reselect the active schema and replay current raw input. Process death loses the session and all in-memory composition; the next process starts fresh.

## Alternatives Considered

- Share a session across processes: rejected because the session is process-local and lifecycle cannot be guaranteed.
- Process RIME keys on arbitrary background queues: rejected because librime calls require serialized thread ownership.
- Use deployment as session recovery: rejected because it violates latency and ownership boundaries.

## Consequences

- `processKey`, candidate selection and recovery stay serialized.
- In-memory input is not a durable record.
- Session recovery must not mutate persistent deployment resources.

## Risks

- Main-App and Extension processes can still access common user data concurrently.
- Long RIME calls on the main thread directly affect key latency.

## Follow-up Work

- Collect session-creation and input latency evidence in `PERFORMANCE_BASELINE.md`.
- Validate cross-process user-data access.
- Extension **main-actor session threading locus** is revised **only for the
  ADR 0025 gate-on path** by
  [`ADR 0025`](0025-responsive-rime-serial-input-pipeline.md)
  (**Accepted** `2026-08-06`; see 0025 §6 operational note and §8 gate
  contract). **Serialization remains mandatory on both paths.** Gate-off /
  Release-default production traffic continues to follow this ADR’s
  MainActor-synchronous session rule until a future Product Gate Decision
  changes defaults. ADR 0025 does **not** fully supersede this ADR.

## Related Documents

- `docs/architecture/swift6-migration.md`
- `docs/PERFORMANCE_BASELINE.md`
- `docs/TECH_DEBT.md`
