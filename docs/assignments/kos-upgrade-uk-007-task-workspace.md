# Assignment: KOS-UPGRADE-UK-007 — Adopt the Task Workspace continuity contract (docs-only)

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | The five-file docs-only adoption slice is authorized and prepared in an isolated worktree; the publication PR is not merged and no merged fact is recorded here |
| Material non-claims | No Kit Release; no change to the v0.9.0 pin; no F-01 or L-01 adoption; no `required` mode, migration or backfill; no runtime, CI, Profile or `ACTIVE_WORK.md` change; no fully automated cross-platform takeover. Existing active Codex tasks and worktrees are not migrated or modified by this adoption. |
| Next handoff / decision | Human Product Owner decides the merge. After merge, the existing M-02 closeout records the merged PR and commit and closes this Assignment |
| Residuals | Accepted bounded documentation deviation (Product Lead, 2026-10-18 Asia/Shanghai): while this Assignment is Active, `docs/ACTIVE_WORK.md` and the `docs/ENGINEERING_DASHBOARD.md` row are not updated, so the state mirrors are briefly out of sync. This is not claimed to satisfy M-02 item 6 or M-05. The existing M-02 closeout right after merge reconciles the mirrors and closes this Assignment; the deviation must not be left open |

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

## History

- 2026-10-18 Asia/Shanghai: Established by the Human Product Owner's decision. Prepared as a five-file docs-only slice.
- 2026-10-18 Asia/Shanghai: The Product Lead accepted the bounded mirror deviation above (no `ACTIVE_WORK.md` or Dashboard change in this slice) and kept the Assignment truthfully Active until the merge.
