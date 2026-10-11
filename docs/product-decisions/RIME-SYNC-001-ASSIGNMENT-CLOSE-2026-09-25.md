# Product Decision: RIME-SYNC-001 — bounded iOS V1 Assignment close

- **Decision ID:** `PD-RIME-SYNC-001-ASSIGNMENT-CLOSE-2026-09-25`
- **Lifecycle status:** `Accepted — Assignment Closed`
- **Date / timezone:** `2026-09-25 Asia/Shanghai`
- **Assignment:** [`RIME-SYNC-001`](../assignments/rime-sync-001.md)
- **Scope decision:** [`local-folder V1; WebDAV deferred`](RIME-SYNC-001-LOCAL-FOLDER-CLOSURE-WEBDAV-DEFERRED-2026-09-24.md)

## Authority and decision source

- **Decision maker:** Product Lead, acting under the Human Product Owner's
  explicit in-session instruction on `2026-09-25 Asia/Shanghai`.
- **Decision source:** “接受上述限定范围与开放技术债，按 KOS 登记父项生命周期决定吧”.
- **Accepted scope and residuals:** the preceding explicit Human Product
  Owner acceptance in this task, the bounded V1 scope decision, and the
  residual dispositions recorded below.
- This record executes the Product lifecycle decision requested in-session;
  it does not invent a Product Gate or grant external publication authority.

## Decision

**Accepted — close the RIME-SYNC-001 Assignment for the delivered iOS V1
local-folder engineering scope, with the listed limitations and open technical
debts retained.** The Assignment lifecycle is recorded through the KOS path
`Active → Completed → Reviewed → Closed`, effective `2026-09-25 Asia/Shanghai`.

This is a bounded engineering Assignment close. It is not a claim that every
provider, platform, device, background schedule or cross-process risk is
resolved.

CloudKit / iCloud is outside the accepted iOS V1 scope, rather than a residual
of the delivered local-folder path. Its prerequisites and later authorization
remain necessary; this scope exclusion is not a claim of CloudKit completion.

## Accepted evidence

- The current full App + Keyboard Simulator suite is 401 total: 391 passed,
  10 skipped, 0 failed. Native Xcode enumeration matches the 401 `.xcresult`
  IDs. Product acceptance of `QR-CURRENT-01` covers only this run's 402/401
  reporting residual; its internal cause remains unknown. The 10 skipped
  cases are not passes.
- The full UI regression receipt is 29 passed, 7 skipped, 0 failed. UI-01's
  five-case matrix and the signed Keychain + RIME transport 11/11 result are
  separate scoped evidence, not extra results in the full-suite total.
- Manual production-App deletion evidence, plus fresh independent Quality and
  Architecture reviews, closes `QR-PROVIDER-DELETE-01` as `fix` only for one
  iOS Simulator Apple Files LocalStorage state observation: the private
  `universe-rime-sync` package directory was absent after the recorded flow;
  the standard RIME directory was present. The original provider-deletion UI
  XCTest remains `1 failed / 0 passed`. No automated deletion pass, Files UI
  refresh assertion, standard-directory content/immutability, installed
  binary/source binding, or independently timed operation correlation is
  claimed.
- The synchronized final candidate manifest reviewed by the paired reviewers
  contained 68 paths and SHA-256
  `ae5f2da4efebe9de3c4da67b6db02b951dc906a8f4e73723535eb4ea265748ca`.
  Quality returned `Pass with conditions`; Architecture returned `Accept with
  conditions`. Reviewer/runtime model variants were not independently
  attestable and remain recorded as `UNKNOWN`.
- The readiness ledger's stale status narration was corrected, and the final
  synchronized state was independently re-reviewed. No additional Simulator
  run was required for the bounded provider-state claim.

## Residual dispositions retained at close

| Residual / record | Owner | Disposition | Boundary and pointer |
|---|---|---|---|
| `QR-PROVIDER-DELETE-01` | Main App / Quality / Architecture | `fix` | Closed only for the single Simulator Apple Files LocalStorage observed state; [manual evidence](../evidence/rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md), [Quality](../reviews/rime-sync-v1-local-folder-provider-deletion-quality-manual-review-2026-09-25.md), [Architecture](../reviews/rime-sync-v1-local-folder-provider-deletion-architecture-manual-review-2026-09-25.md). |
| Manual action/capture correlation, Files UI refresh and installed binary provenance | Assignment | `accept` as explicit evidence limits | The observation remains manual and time-adjacent; no operation UUID/independently timed click, Files UI refresh assertion, or installed source/binary binding. [Manual receipt](../evidence/rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md). |
| Original provider-deletion UI XCTest | Main App / Quality | `accept` as a reporting boundary; test remains failed | Preserve `1 failed / 0 passed`; no relabeling as pass. [Attempt receipt](../evidence/rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md). |
| `QR-CURRENT-01` | Quality / CI integration | `accept` for the exact documented runs only | XcodeBuildMCP cause is unknown; no future-run accuracy claim. The 10 skips remain unverified. [Product residual decision](RIME-SYNC-001-QR-CURRENT-01-PRODUCT-RESIDUAL-2026-09-24.md). |
| UI-02 narrow-device / source-binding limitations | Human owner / Quality | `accept` within the bounded V1 scope | Not a formal UI-02 pass or full accessibility-conformance claim. [Product residual decision](RIME-SYNC-001-UI02-RESIDUAL-ACCEPTANCE-2026-09-24.md). |
| `TD-002` — cross-process RIME / Keyboard Extension concurrency | Main App / RIME Platform | `tech_debt:TD-002` | **Open risk retained.** No mitigation, technical resolution or risk-free acceptance is claimed. [Debt record](../TECH_DEBT.md#td-002-validate-rimeuser-concurrent-access). |
| `TD-008` — full cross-platform compatibility | Main App data operations / RIME Platform | `tech_debt:TD-008` | Deferred beyond this iOS V1 closure; no full cross-platform compatibility claim. [Debt record](../TECH_DEBT.md#td-008-complete-portable-rime-data-compatibility). |
| `TD-013` — diagnostics/query debt and old exact error `UNKNOWN` | Diagnostics / Quality | `tech_debt:TD-013` | Remains open; the historical error stays `UNKNOWN`. [Debt record](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化). |
| `TD-017` — sandbox-extension failure attribution | Main App RIME sync / RIME Platform | `tech_debt:TD-017` | Remains open; later successes do not establish the old warning as harmless. [Debt record](../TECH_DEBT.md#td-017-investigate-background-sync-sandbox-extension-consume-failure). |
| `TD-019` — live WebDAV validation | WebDAV / Main App sync owner | `tech_debt:TD-019` | Deferred to a future bounded task; no live WebDAV server or remote deletion claim. [Debt record](../TECH_DEBT.md#td-019-live-webdav-provider-validation). |
| Run 02 `INVALID` | RIME-SYNC-001 Product / Quality | `accept` only as an invalid historical record | Preserve original `HOLD`; it is not evidence that sync behavior passed. [Run 02 receipt](../evidence/rime-background-sync-natural-device-run-2026-09-01-r2.md). |

## What this decision does not authorize or claim

- No Product Gate pass is asserted beyond this explicit bounded lifecycle
  decision.
- At the time this lifecycle decision was recorded, no commit, push, PR, merge,
  TestFlight, App Store submission or Release was authorized. The later
  publication authorization below supersedes only the commit/push/PR boundary.
- No live WebDAV, CloudKit, cross-device propagation, physical-device provider
  deletion, full portability, future automatic-sync cadence, or resolution of
  `TD-002` is claimed.
- New scope, material route changes, recurrence requiring renewed investigation,
  or any deferred provider/platform work requires its own Assignment and
  authorization as applicable.

## Subsequent publication authorization — 2026-09-25

The Human Product Owner subsequently authorized this task to complete the
release-preparation gates on `codex/rime-sync-v1-local-folder-pr` and, only if
those gates pass, commit the scoped work, push that branch and create a PR.
This supersedes the earlier no-commit/push/PR statement above for these named
actions only. It does not authorize merge, TestFlight, App Store submission or
Release; retained technical debts and evidence limitations remain unchanged.

## Lifecycle and state synchronization

The Product Lead authorizes and records the lifecycle path
`Active → Completed → Reviewed → Closed`. The owning Assignment is the
lifecycle source of truth; `ACTIVE_WORK` and Dashboard are synchronized
mirrors. This decision closes only `RIME-SYNC-001` as scoped above.
