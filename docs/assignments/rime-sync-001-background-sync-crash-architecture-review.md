# RIME-SYNC-001 — Background Sync Crash Architecture Review

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-29 Asia/Shanghai` |
| **Reviewer role** | Architecture & Knowledge Steward — independent of the Executor |
| **Object under review** | Commit `e3e5d7703e7111787cea06ff2c0d3454395a5abc`, base `7f20f3aa16ff4b20f52862918da716d6a6d0b312`, Draft PR [#91](https://github.com/shchnk1103/Universe-Keyboard/pull/91) |
| **Inputs** | [`RIME-SYNC-001`](rime-sync-001.md), ADR 0012/0013/0014/0019, Main App UI/RimeBridge/Coordinator playbooks, Swift 6 and shared-container lifecycle sources |

The reviewer did not implement the change and performed a read-only review. This
conclusion does not replace Quality, Human Product Gate, merge authority,
TestFlight or Release authority.

## Verdict

**Pass with conditions**

The crash repair is architecturally correct for its stated boundary:
`RimeAutomaticSyncScheduler` is `MainActor`-isolated, the synchronous
BackgroundTasks launch handler now enters through `DispatchQueue.main`, and the
actual synchronization remains in the existing cancellable asynchronous path.
The change does not move networking, RIME maintenance or deployment into the
Keyboard Extension or input hot path. No P0 was found, and no new App/Extension
ownership violation was introduced by this commit.

## Findings And Dispositions

| ID | Severity | Owner | Disposition | Finding / pointer |
|---|---:|---|---|---|
| `A-P1-01` | P1 | RimeBridge + Main App data operations | `tech_debt:TD-002` | The background handler creates a new `RimeSyncViewModel`/service instance while the foreground owns another instance. Per-instance actor serialization does not prove process-wide or cross-process exclusion. This predates the queue repair; retain the cross-process/quiesce risk in [`TD-002`](../TECH_DEBT.md#td-002-validate-rimeuser-concurrent-access). |
| `A-P2-01` | P2 | Main App data operations | `fix` | A `.keyboardActive` automatic skip does not advance `lastAutomaticAttempt`; resubmission can therefore reuse an eligible date in the past. Define a bounded retry/backoff date and test it before this residual is closed. |
| `A-P2-02` | P2 | Main App data operations + Quality | `fix` | Expiration currently cancels the operation but has no explicit once-only terminal gate around `setTaskCompleted`. Add a single-completion lifecycle seam and cancellation/expiration evidence before this residual is closed. |
| `A-P2-03` | P2 | Program/Documentation | `fix` | The reviewed SHA omitted this Active Assignment from `ACTIVE_WORK.md` and lacked a current KOS status mirror. The follow-up documentation change must synchronize Assignment, plan, Active Work and Dashboard, then re-run documentation checks. |
| `A-P3-01` | P3 | Folder access / File Provider / RimeBridge diagnostics | `tech_debt:TD-017` | The observed sandbox-extension error remains an unclassified, non-blocking signal. Continue the trigger-based investigation in [`TD-017`](../TECH_DEBT.md#td-017-investigate-background-sync-sandbox-extension-consume-failure); do not guess-modify security-scoped access. |

## Confirmed Boundaries

- Main App registration, BackgroundTasks identifier and `MainActor` entry agree.
- Standard RIME sync still uses the production RimeBridge/librime path.
- The Keyboard Extension receives no new sync, network or deployment duty.
- Notification delivery remains permission- and scope-gated and contains no
  typed content, dictionary contents, folder path or recovery material.
- Natural scheduling, phone-native notification presentation and safe
  foreground/background/Extension concurrency remain unproven.

This review permits the Draft PR to continue through residual handling. It does
not mark the change merge-ready and does not close `RIME-SYNC-001`.

`SUMMARY_DECISION=Pass with conditions`
