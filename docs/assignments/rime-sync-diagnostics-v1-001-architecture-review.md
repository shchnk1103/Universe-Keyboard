# RIME-SYNC-DIAGNOSTICS-V1-001 — Architecture Review

| Field | Value |
|---|---|
| Reviewed commit | `d07b607` |
| Final verdict | `Pass with conditions` |
| Scope | Persisted typed protocol, privacy allowlist, writer/target ownership, phase state machine and BGTask terminal linearization |

## Review history and disposition

The first independent review returned `Fail` because
`DiagnosticsJournalWriter` normalized events without copying
`rimeSyncPayload`; the first write would therefore have violated the
code/payload precondition. It also found that expiration and cancellation were
not linearized at the BGTask lifecycle seam. These findings are preserved here
because they materially changed the implementation.

Final disposition:

- **P0 closed:** writer normalization now preserves `rimeSyncPayload`, and a
  temporary-root Runtime → Ingress → Writer → Reader test proves persistence.
- **P1 closed:** normal operations propose a terminal and commit it only after
  the operation lifecycle claim. Expiration claims first, records `.expired`,
  then cancels and completes the BGTask. Late cancellation cannot replace it.
- **P2 condition:** the session rejects unrequested phases, completion without
  start and concurrent duplicate start. Because the current production path is
  a fixed standard-then-private sequence, not tracking `nextExpectedPhase` or
  every completed requested phase is non-blocking. Any new phase or dynamic
  phase order must add those constraints before shipping.

## Boundary findings

- Payloads contain only finite enums and an opaque operation UUID; no path,
  bookmark, raw error/NSError text, dictionary, candidate or input content is
  persisted.
- The producer remains in the main App. Keyboard Extension, RIME deployment and
  input hot-path ownership are unchanged.
- Optional persisted fields preserve decoding of existing v2 events. Broader
  future-version rejection policy remains protocol hardening outside this task.

This review does not prove natural iOS scheduling, signed physical-device
success, recovery of the old legacy error, Product Gate, merge or Release.
