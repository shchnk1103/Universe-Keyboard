# RIME-SYNC-001 — Background Sync Lifecycle Architecture Re-review

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-31 Asia/Shanghai` |
| **Reviewer role** | Architecture & Knowledge Steward — independent subagent, read-only |
| **Final object under review** | `3f94073`, implementation chain from `546ffb4` |
| **Verdict** | `Pass with conditions` |

The reviewer did not implement the change, modify files, commit or push. This
review does not grant Quality, Product, merge, TestFlight or Release authority.

## Final Findings

| ID | Severity | Disposition | Finding |
|---|---:|---|---|
| `A-P2-01` | P2 | `code closed; device integration open` | Keyboard-active skip records a 15-minute retry floor and scheduling uses the later of cadence and retry. The real App Group heartbeat-to-submit chain remains a device condition. |
| `A-P2-02` | P2 | `code closed` | A `Synchronization.Mutex` grants expiration or operation return one terminal owner. Only that owner can call `setTaskCompleted`; expiration cancels and fails the BGTask without waiting for MainActor or librime return. |
| `A-P2-04` | P2 | `code closed` | Cancellation is checked after YAML refresh, after librime, after the private coordinator and after settings apply. Final scope facts are recorded before the outer check; cancellation sends failure only while a requested scope remains unfinished. |
| `A-P2-06` | P2 | `non-blocking condition` | `runCancellablePhase` observes cancellation after each await but is not an atomic commit fence with the immediately following local profile/success-time write. Scheduler terminal ownership still suppresses external success; a stronger “no post-cancel local write” contract would require separate design. |
| `A-P2-05` | P2 | `device condition` | Expiration completes the current task before its asynchronous MainActor reschedule. The system may suspend before that retry request is submitted, so retry delivery is not claimed. |
| `A-P1-01` | P1 | `retain TD-002` | Instance serialization and keyboard heartbeat are not process-wide/cross-process mutual exclusion. This blocks unattended-sync Product safety acceptance, not the local lifecycle fix. |
| `A-P3-01` | P3 | `retain TD-017` | The sandbox-extension observation remains unclassified and non-blocking for this fix. |

## Review History

- `0f59770`: `Pass with conditions`; found the MainActor expiration race and
  missing post-phase cancellation closure.
- `a34c45c`: atomic terminal ownership closed the original race; final review
  found the YAML-to-librime cancellation gap and device reschedule condition.
- `466a5f0`: closed the YAML gap, but Architecture and Quality disagreed on the
  removed final post-await checks.
- `a7b2b2e`: restores conservative post-await checks while suppressing only a
  failure notification whose requested scopes are already complete. No
  implementation-level blocker remains.
- `3f94073`: routes all potentially non-cooperative phases through the same
  post-await cancellation boundary and adds deterministic direct model tests.
  The independent delta review remains `Pass with conditions`; no cross-layer
  or implementation blocker was introduced.

## Remaining Evidence Boundary

The [device preflight packet](../evidence/rime-background-sync-device-run-preflight-2026-08-31.md)
correctly remains `HOLD` and grants no device/Product authority. Natural iOS
background scheduling, real expiration/suspension timing, native phone
notifications, the still-unfrozen installed manifest/receipt, cross-process
RIME exclusion, `TD-017`, Product Gate, push, merge, TestFlight and Release are
not proven by this review.

`SUMMARY_DECISION=Pass with conditions`
