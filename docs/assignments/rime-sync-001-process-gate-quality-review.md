# RIME-SYNC-001 — Main-App Process Gate Quality Review

| Field | Value |
|---|---|
| Date | `2026-09-01 Asia/Shanghai` |
| Reviewer | Independent Quality reviewer subagent |
| Object | Current uncommitted process-gate delta after the failed natural device run |
| Conclusion | `Pass with conditions` |

## Verified

- Two independent background `RimeSyncViewModel` instances with independent
  attempt state and one shared gate: one RIME call, maximum concurrency one,
  contender `.alreadyRunning`, no contender notifications, and owner release
  after cancellation.
- Complete owner cancellation notification sequence and process-busy BGTask
  exactly-once completion/reschedule behavior.
- Stale-lease rejection, manual/foreground duplicate suppression, and both
  missing-attempt scheduling boundaries.
- Focused `RimeAutomaticSyncPolicyTests`: `21 passed, 0 failed` on iPhone 16 Pro
  Simulator / iOS 18.0.

## Conditions

- Physical-device `BGTaskScheduler`, expiration and post-run receipts remain
  human/device gates.
- Cross-process safety remains TD-002 and is not claimed by these tests.
- This conclusion does not authorize Product Gate, push, merge or Release.
