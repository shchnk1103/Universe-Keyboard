# Authorization: AUTH-TYPO-CORRECTION-002-INT003-REVALIDATION-001

## Current Status

| Field | Value |
|---|---|
| Status | `active — unconsumed` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Case | `TC2-CASE-INT-003` / `TC2-CTR-INT-002` |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | Collect one bounded stale-work/cancellation evidence slice |
| Run ID | Allocate `TC2-SIM-20260919-<HHMMSS>-INT003-REVAL-<n>` immediately before capture |

## Exact Execution Identity

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` / `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- `origin/main` context: `162b09fd58ba60538a944026b1902efa405c75aa`; no same-head claim
- Tracked production/test diff SHA-256: `c9225a435b833aa1c637c21bead8f85f1465d2b6d161c30a74b5789408c523be`
- Untracked production/test file-content SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Target: iPhone 17 Pro Max / iOS 27 Simulator, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`, Messages, `+1 (888) 555-1212`

## Authorized Scope

- Exercise the existing production debounce boundary with synthetic input only and observe whether stale contextual work is cancelled or superseded when newer input arrives.
- Use manual key taps or the independently validated key-target `tap()` harness only; do not use `typeText`, pasteboard, host injection, `documentContext` or `setMarkedText`.
- Record the observed inter-key cadence, pause duration, operation/revision/session evidence and whether a stale query result was applied.
- Preserve the documented 180 ms pause contract. A slower human/manual sequence may be recorded as useful supplemental evidence but cannot pass the rapid-cadence condition.

## Required Evidence

- Fresh exact build/device/schema/provenance identity and raw-artifact hashes.
- A content-free timeline separating stimulus boundary, debounce arm/cancel, sidecar query start/finish, owner publication and UI application.
- Actual cadence measurement method and its limitations; no inferred cadence from wall-clock screenshots.
- Explicit result: passed boundary, failed boundary, or inconclusive because the target cadence/observable was not established.

## Explicit Exclusions

- No change to the 180 ms threshold, search budget, recall enablement, RIME schema, source code or tests.
- No claim about QA-001 candidate quality, paired performance, Product acceptance or parent closure.
- No physical-device substitution under this Simulator-bound receipt.

## Stop / Completion

Stop when the exact runtime identity is unavailable, the stimulus is routed to the system keyboard, the capture needs host injection, or the timing boundary cannot be observed. Completion produces an INT-003 Run Receipt only; it does not close `TC2-CASE-INT-003`.
