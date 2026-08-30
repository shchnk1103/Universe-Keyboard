# RIME-SYNC-001 — Background Sync Lifecycle Architecture Re-review

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-30 Asia/Shanghai` |
| **Reviewer role** | Architecture & Knowledge Steward — independent subagent, read-only |
| **Object under review** | `0f597701fbd87cf390e88f367d91bf69c590927b`, base `efa009fbe1ad360b393480d617e7452272d4eb6b` |
| **Verdict** | `Pass with conditions` |

The reviewer did not implement the change, modify files, commit or push. This
review does not grant Quality, Product, merge, TestFlight or Release authority.

## Findings

| ID | Severity | Owner | Disposition | Finding |
|---|---:|---|---|---|
| `A-P2-01` | P2 | Main App data operations | `resolved at architecture/code level; Quality integration evidence pending` | The 15-minute `retryNotBefore` plus max(cadence, retry) closes repeated submission of a past eligible date on the normal Assignment path. |
| `A-P2-02` | P2 | Main App data operations + RimeBridge + Quality | `partial; retain fix` | The once-only state seam exists, but expiration first hops asynchronously to MainActor. Operation return can win before that hop, and synchronous librime maintenance is not cooperatively cancellable. |
| `A-P2-04` | P2 | Main App data operations + RimeBridge | `new fix required` | Cancellation was not re-checked after every non-cooperative phase. A model could publish completion while the BGTask lifecycle later reports expiration failure. |
| `A-P1-01` | P1 | Main App data operations + RimeBridge + Extension coordination | `unchanged; retain TD-002` | Per-instance serialization and keyboard heartbeat are not process-wide/cross-process mutual exclusion. |
| `A-P3-01` | P3 | Folder access / File Provider / RimeBridge diagnostics | `unchanged; retain TD-017` | The sandbox-extension observation remains unclassified and non-blocking. |

## Confirmed Boundaries

- No new App/Keyboard Extension ownership or privacy violation was found.
- BackgroundTasks registration remains on `DispatchQueue.main` and the sync path
  remains main-App-owned.
- Notification payloads remain fixed, content-free scope/status text.
- `A-P2-01` may close at Architecture code level; `A-P2-02`, `A-P1-01` and
  `A-P3-01` may not close on this reviewed SHA.

`SUMMARY_DECISION=Pass with conditions`
