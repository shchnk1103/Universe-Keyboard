# RIME-SYNC-001 — Main-App Process Gate Architecture Review

| Field | Value |
|---|---|
| Date | `2026-09-01 Asia/Shanghai` |
| Reviewer | Independent Architecture reviewer subagent |
| Object | Current uncommitted process-gate delta after the failed natural device run |
| Conclusion | `Pass with conditions` |

## Conclusion

No implementation-level blocker remains. `RimeSyncProcessGate` provides one
atomic lease across manual, foreground-automatic and background-automatic App
entries. Lease identity prevents a late owner from releasing a successor, and
expiration correctly keeps the lease until a non-cooperative operation actually
returns.

The scheduling boundary is also closed: `nil` attempt plus a retry floor keeps
that floor, while `nil` attempt plus no floor returns no schedule and cannot form
an immediate skip/resubmit loop. The test-only request factory bypasses only App
Group/bookmark preparation; its production default preserves the real path.

## Conditions

- The new payload still requires a natural physical-device background round.
- This gate is main-App-process-only. App/Keyboard cross-process RIME access
  remains [`TD-002`](../TECH_DEBT.md#td-002-validate-rimeuser-concurrent-access).
- This conclusion does not authorize Product Gate, push, merge or Release.
