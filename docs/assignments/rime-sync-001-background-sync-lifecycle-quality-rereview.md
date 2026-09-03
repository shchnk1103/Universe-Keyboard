# RIME-SYNC-001 — Background Sync Lifecycle Quality Re-review

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-31 Asia/Shanghai` |
| **Reviewer role** | Quality, Performance & Release Maintainer — independent subagent, read-only |
| **Final object under review** | `3f94073`, implementation chain from `546ffb4` |
| **Verdict** | `Pass with conditions` |

The reviewer did not implement the change, modify files, commit or push. This
review does not grant Architecture, Product, merge, TestFlight or Release
authority.

## Final Findings

| ID | Severity | Disposition | Finding |
|---|---:|---|---|
| `Q-P2-02` | P2 | `code/unit closed; device callback open` | Production finish/expiration seams and atomic ownership tests cover exactly-once completion and late-return suppression. A real BGTask callback remains unverified. |
| `Q-P2-03` | P2 | `implementation closed` | Expiration synchronously claims the mutex, cancels and calls `setTaskCompleted(false)` without waiting for MainActor or librime. |
| `Q-P2-05` | P2 | `implementation closed` | YAML, librime, private coordinator and settings-apply boundaries all re-check cancellation; final completion notification still requires scheduler terminal ownership. |
| `Q-P2-07` | P2 | `code/unit closed` | Direct model tests deterministically reject a non-cooperative phase's late success after cancellation, preserve an uncancelled result and require an unfinished requested scope before cancellation notification. This is shared-boundary coverage, not a full injected `synchronizeAutomatically()` or real BGTask callback test. |
| `Q-P2-06` | P2 | `closed` | The normal `.failed` seam directly verifies failed BGTask completion, one reschedule and no completion notification. |
| `A-P2-01 / Quality coverage` | P2 | `policy passed; device integration open` | Cadence/retry max policy is tested; the complete App Group heartbeat-to-submit-to-callback chain is not. |
| `Q-P2-01` | P2 | `open` | No formal device run with pre-frozen installed-payload manifest and content-free receipt. |

## Independently Reverified Evidence

- Against `a34c45c`, Quality independently ran the lifecycle/model matrix:
  `19`, `0` failures.
- Against `466a5f0`, Quality first returned `Fail` because two final post-await
  checks had been removed. That verdict was not carried forward.
- Read-only delta review of `a7b2b2e` confirms those checks and the internal
  success-timestamp boundaries are restored. No implementation blocker remains.
- Read-only delta review of `3f94073` confirms the three direct model tests and
  shared production boundary. The final focused `23/0`, current-snapshot full
  suites and builds remain Executor-recorded.
- A short follow-up review closed the preflight template's receipt-schema and
  command-side-effect findings. The packet still remains `HOLD` until its
  installed-device identities are populated and readiness is independently
  reviewed.
- Final large-suite and build results are Executor-recorded, not rebranded as
  independent Quality execution.

## Remaining Evidence Boundary

The [device preflight packet](../evidence/rime-background-sync-device-run-preflight-2026-08-31.md)
is prepared but remains `HOLD`: installed payload identities are not frozen and
no human action is authorized. Natural iOS BGTask scheduling, real
callback/suspension timing, phone lock-screen and Notification Center
presentation, `TD-002`, `TD-017`, cross-front-end evidence and Product/Release
gates remain open.

`SUMMARY_DECISION=Pass with conditions`
