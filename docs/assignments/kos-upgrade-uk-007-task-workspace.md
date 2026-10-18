# Assignment: KOS-UPGRADE-UK-007 — Adopt the Task Workspace continuity contract (docs-only)

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Closed — effective on merge of the M-02 closeout PR that carries this edit |
| Current phase | Closed: the five-file docs-only adoption was published by PR #211 (merge commit `834c6af3e0c0772b261f5284677a399e09ca6489`); the single M-02 closeout is recorded in this Assignment |
| Material non-claims | No Kit Release; no change to the v0.9.0 pin; no F-01 or L-01 adoption; no `required` mode, migration or backfill; no runtime, CI, Profile or `ACTIVE_WORK.md` change; no fully automated cross-platform takeover. Existing active Codex tasks and worktrees are not migrated or modified by this adoption. |
| Next handoff / decision | None for this Assignment. Bringing any existing task into Task Workspace needs a separate Human authorization |
| Residuals | The accepted bounded mirror deviation is closed by this closeout: `docs/ENGINEERING_DASHBOARD.md` gains the UK-007 section; `docs/ACTIVE_WORK.md` never listed this Assignment, so no entry is added or removed. It was not claimed to satisfy M-02 item 6 / M-05 while the Assignment was Active |

---

## Authority

- Assignment Authority / Product Approver: Human Product Owner acting as Product Lead.
- Decision Source / Date: [PD-KOS-UPGRADE-UK-007](../product-decisions/KOS-UPGRADE-UK-007-task-workspace-adoption.md), 2026-10-18 Asia/Shanghai.

## Boundary

- Scope: add `docs/product-decisions/KOS-UPGRADE-UK-007-task-workspace-adoption.md`, `docs/kos/upgrade-records/KOS-UPGRADE-UK-007-task-workspace.md` and this Assignment; update `docs/kos/UPGRADE_STATUS.md` and `AGENTS.md`. Five files in total.
- Non-goals: change `.kos/project.json`, `docs/ACTIVE_WORK.md`, any existing Assignment, CI, source, tests, other contracts or the Kit; adopt F-01 or L-01; migrate any task; touch any existing worktree, branch, session or uncommitted change.
- Required Inputs: the accepted Product Decision; upstream commit `9ca6dc015bf01084150538aac65cedc25b2a33a5` and the file digest in the decision; project baseline `origin/main` at `eedbee993f8d89cd283c1487356f27f66c5e044a` or later.
- Project baseline: a new isolated worktree created from the latest `origin/main`, never the main checkout.

## Assignment

- Domain Owner / Executor: Architecture & Knowledge Steward / an independent Claude execution session in the isolated worktree.
- Environment Executor: Not Applicable — repository documentation text only; no device, application, account or release environment.
- Human Dependency: Human Product Owner — the merge decision, any later publication step, and any authorization to bring an existing task into Task Workspace.
- Architecture Reviewer: Not Applicable — Product Lead decision: docs-only adoption of one contract file; the Human reviews the diff. This is not an independent review conclusion.
- Quality Reviewer: Not Applicable — Product Lead decision: mechanical documentation checks only; no independent review conclusion is claimed.
- Product Approver: Human Product Owner.

## Gates and Handoff

- Entry: accepted Product Decision; the changed paths are exactly the five authorized files; the upstream commit and file digest match the decision; an isolated worktree from the latest `origin/main`.
- Exit: the five files merged by the Human; mechanical checks and PR CI recorded; the M-02 closeout recorded after merge.
- Stop: any need for a sixth file or any change outside the scope; a mismatch in the pin or digest; the base moving so that a change no longer applies cleanly; any impact on an existing worktree; CI or a mandatory repository rule that blocks the merge (stop and report).
- Handoff Target: Human Product Owner.
- Required Handoff Content: changed paths, pin and digest check, checks run and results, PR CI result, confirmation that existing worktrees and sessions were untouched.
- Revalidation Trigger: pinned commit or file change; scope change; first real task finding; a `required`-mode or migration request.

## M-02 closeout (trigger identity)

| Field | Value |
|---|---|
| Work Item | KOS-UPGRADE-UK-007 |
| Exact event | Merge of the lifecycle-changing tip PR that published the UK-007 adoption, and the Assignment Close recorded in this same transaction |
| Authority record | [PD-KOS-UPGRADE-UK-007](../product-decisions/KOS-UPGRADE-UK-007-task-workspace-adoption.md); the Human Product Owner's merge of PR #211 and Close decision, 2026-10-18 Asia/Shanghai |
| Merged tip PR | [#211](https://github.com/shchnk1103/Universe-Keyboard/pull/211), head `34c858e57e400f557eb357cd1739bc5a0a4a7355` |
| PR base | `eedbee993f8d89cd283c1487356f27f66c5e044a` |
| Merge pointer | `834c6af3e0c0772b261f5284677a399e09ca6489`, merged 2026-10-18T14:37:30Z (squash; single parent equals the PR base; tree equals the PR head tree) |
| Verification | After fetching remote `main`, `gh pr view` reports MERGED; the five authorized paths are the only changes; `AGENTS.md` item 8 step 5 carries the final ACCEPT wording; `.kos/project.json` and the v0.9.0 pin are unchanged |

### Completion check (Exit criteria)

- The five files were merged by the Human: met (PR #211).
- Mechanical checks and PR CI recorded: hosted classify-change, lightweight-checks, final-quality-gate and GitGuardian succeeded on the merged head; docs-only heavy jobs were skipped by the repository path classifier.
- Existing worktrees: the nine worktrees that existed before this task are unchanged in path, branch and HEAD, and the main checkout still has its own uncommitted changes. Existing active Codex tasks and worktrees are not migrated or modified by this adoption.
- Reviews: none were required for this docs-only adoption (Product Lead decision); no independent review conclusion is claimed.
- M-02 closeout: this section.

### Non-recursive closeout

This closeout PR and its administrative merge complete the single M-02 synchronization for the identity above. They do not trigger a new M-02. A later independent Product Gate, ADR Accept, Assignment Close or lifecycle-changing merge is a new trigger with its own identity.

## History

- 2026-10-18 Asia/Shanghai: Established by the Human Product Owner's decision. Prepared as a five-file docs-only slice.
- 2026-10-18 Asia/Shanghai: The Product Lead accepted the bounded mirror deviation above (no `ACTIVE_WORK.md` or Dashboard change in this slice) and kept the Assignment truthfully Active until the merge.
- 2026-10-18 Asia/Shanghai: PR #211 merged as `834c6af3e0c0772b261f5284677a399e09ca6489`. The Human Product Owner authorized the M-02 closeout; this Assignment is recorded Closed, effective on merge of the closeout PR.
