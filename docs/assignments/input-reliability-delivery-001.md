# Assignment: INPUT-RELIABILITY-DELIVERY-001 — Input Reliability Batch 1 Delivery

Policy version: 1.0.0

## Current Status

> **Superseded for current status:** see [PR #213 post-merge State Sync](#pr-213-post-merge-state-sync--2026-10-21) below and [`ACTIVE-WORK-STALE-FACTS-SYNC-001`](active-work-stale-facts-sync-001.md) (2026-10-21).
> PR [#213](https://github.com/shchnk1103/Universe-Keyboard/pull/213) is **merged** (`bb430f914deaf7b19a61183f744b5dcf2fdb8eae`). Text in this document such as "C1 local fix is ready for a directed re-review", "no product pull request exists" and "Human decides whether this carrier may be pushed" is historical narrative as of its own date, not current truth. This note does not change the Lifecycle value.

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | Active: C1 local fix is ready for a directed re-review |
| Material non-claims | Not an Architecture, Quality, or Product Gate. Not a merge, TestFlight, or Release. R345 remains evidence-insufficient. R174 stays off. The original INPUT-RELIABILITY-B-001 Assignment and worktree are not migrated. |
| Next handoff / decision | Human Product Lead decides whether this carrier may be pushed as a product PR after local validation |
| Residuals | R345 candidate identity stays out of this batch. Batch 2 and Batch 3 are not started. |

---

## Authority

- Assignment Authority / Product Approver: Human Product Owner acting as Product Lead.
- Decision Source / Date: Human Product Lead authorization in the current Grok Build session, 2026-10-19 Asia/Shanghai. Task ID `INPUT-RELIABILITY-DELIVERY-001`.

## Task Workspace

This Assignment opts in to `ops/task-workspace.md` at Kit commit `9ca6dc015bf01084150538aac65cedc25b2a33a5` (sha256 `91d3da26728c210de3b605f28f65e0377f9ee90b2f0eaf65c8e12b7f8cb5f76a`).

The initial writer lane is `grok-build`. There is no predecessor writer, so the first `CHECKPOINT` establishes `W`. No `HANDOFF` or `ACCEPT` is created for that initialization.

## Boundary

- Scope: host document identity and safe document switching; RIME session-loss recovery of the previous raw prefix; synchronous fallback installation that refuses residual responsive state; the tests that cover those three behaviors.
- Non-goals: candidate origin, paging, and native select; T9 exact retype and partial-commit failure protection; enabling R174; R349; Build 94 deploy-crash investigation; phases C and D; migrating INPUT-RELIABILITY-B-001; changing the production deploy lifecycle; editing the original Codex worktree, the main checkout, or the Claude recovery worktree.
- Required Inputs: `origin/main` `31d06e0bf8d931f001189a31168901286e9ba40f`; the read-only Codex worktree at HEAD `eedbee993f8d89cd283c1487356f27f66c5e044a` as the extraction source.
- Project baseline: isolated worktree `grok/input-reliability-delivery-001` from that `origin/main`.

## Assignment

- Domain Owner: Keyboard input runtime.
- Executor: Grok Build, lane `grok-build`.
- Environment Executor: Grok Build on this Mac, using the already booted iPhone 17 Pro simulator only when a simulator test is required.
- Human Dependency: Human Product Lead — product push, pull request, merge, and any later batch.
- Architecture Reviewer: Not yet assigned. Independent review is outside this implementation authorization.
- Quality Reviewer: Not yet assigned. Independent review is outside this implementation authorization.
- Product Approver: Human Product Owner.

## Gates and Handoff

- Entry: Human named this Task ID, the initial executor, and the Batch 1 scope; `origin/main` was reconfirmed at `31d06e0`.
- Exit: Batch 1 source and tests are committed on the carrier; the authorized local checks have a recorded result; no product pull request exists.
- Stop: a hard dependency on Batch 2 or Batch 3 design; a failing check that is not a bounded extraction error; any need to modify the original Codex worktree.
- Handoff Target: Human Product Lead.
- Required Handoff Content: carrier HEAD, extracted paths, checks run, and whether an independent review can start.
- Revalidation Trigger: `origin/main` moves under this branch; the pinned Task Workspace file changes; Human changes the batch boundary.

## History

- 2026-10-19 Asia/Shanghai: Human Product Lead authorized this new Assignment and named Grok Build as the initial executor. The original INPUT-RELIABILITY-B-001 Assignment stays unchanged.
- 2026-10-19 Asia/Shanghai: grok-build committed the Batch 1 extraction locally after the authorized checks. Product publication remains a Human decision.
- 2026-10-19 Asia/Shanghai: Human authorized a bounded C1 fix. grok-build keeps the failed-recovery raw prefix and commits that fix locally. C2–C5 stay open. Product publication remains a Human decision.
- 2026-10-19 Asia/Shanghai: Human authorized the PR 213 test-rimebridge fixture fix. The private schema is copied into user/build. Production code stays unchanged.

## PR #213 post-merge State Sync — 2026-10-21

Late M-02 sync: written after the event, not at the time of the merge.

- **Trigger:** PR [#213](https://github.com/shchnk1103/Universe-Keyboard/pull/213) `fix(keyboard): improve document identity and session recovery`; merge commit `bb430f914deaf7b19a61183f744b5dcf2fdb8eae`; head `be474bc8783e27b20d810ebc58eb2948a23ae3c3` (branch `grok/input-reliability-delivery-001`); merged `2026-10-19T12:27:34Z` by `shchnk1103` (read-only `gh pr view 213`). The PR body names task `INPUT-RELIABILITY-DELIVERY-001`.
- **Current:** Batch 1 is on `main` through PR #213. "No product pull request exists" and the push decision above are historical.
- **Residuals unchanged, none closed:** C2–C5 and the other items under "Known Limitations" in the PR #213 body; R345 not closed; R174 stays off by default. Pointers only.
- **Final Merge Gate / Authority record for the merge:** UNKNOWN (none found in the repository).
- **Lifecycle:** this file still reads `Active`. The later [Batch 2 Assignment](input-reliability-delivery-002.md) calls Delivery-001 "Closed on its own carrier", but no closure record was found in this repository: UNKNOWN. The Lifecycle value is not changed here and needs a separate Human decision.
- **Non-claims:** not Release; no Architecture/Quality Gate claim (the review lines in the PR #213 body are the PR author's own description and were not verified here); no residual weakened or closed.
