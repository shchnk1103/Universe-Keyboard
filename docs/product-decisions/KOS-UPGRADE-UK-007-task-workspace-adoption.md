# Product Decision: KOS-UPGRADE-UK-007 — Adopt the Task Workspace continuity contract (opt-in)

## Current Status

| Field | Value |
|---|---|
| Status | Accepted |
| Decision | Adopt the single Kit contract file `ops/task-workspace.md` at the exact upstream commit below, as an opt-in contract for new Assignments |
| Decision date | 2026-10-18 Asia/Shanghai |
| Effective | On merge of the publication PR; this record is not evidence of a merge |
| Non-claims | Not a Kit Release; no change to the adopted Kit version (v0.9.0); no F-01 or L-01 adoption; no required-mode change; no migration or backfill; no fully automated cross-platform takeover; no commit, push, PR, merge, tag or Release authorization. The temporary `ACTIVE_WORK.md` / Dashboard mirror gap while the Assignment is Active is an accepted bounded deviation, not M-02 / M-05 compliance; the post-merge M-02 closeout reconciles it |

---

Human Product Owner, current session, 2026-10-18 Asia/Shanghai: “同意推进 Universe Keyboard 的 KOS Task Workspace Adoption。”

## Decision

Universe Keyboard adopts the Task Workspace task-continuity contract so that different AI Agents (Codex, Claude, Grok Build, Grok Bot or others) can continue the same task from durable records, without binding the project to any model, client or vendor.

| Upstream input | Adopted identity |
|---|---|
| Upstream repository | `shchnk1103/kos-agent-kit` |
| Kit commit (merged, not a Release) | `9ca6dc015bf01084150538aac65cedc25b2a33a5` — squash merge of [PR #60](https://github.com/shchnk1103/kos-agent-kit/pull/60), parent `85f81357050d62cfa4d5d5c53ec8e3ea3bd5e3fe` |
| Adopted file | `ops/task-workspace.md` only |
| File sha256 / git blob / size | `91d3da26728c210de3b605f28f65e0377f9ee90b2f0eaf65c8e12b7f8cb5f76a` / `cdf5f1763202db8439fd85bfad081a25ebc6ca58` / 14302 B |
| Kit tree at that commit | `314df6d76ea24eabd0c32605903760d7943d4467` |
| Current project pin (unchanged) | v0.9.0, `c98b2813240e22b2ac7fec44b2445321b03f73e0` |

The pin is v0.9.0 plus 53 upstream commits. Only the one contract file above is adopted; the other upstream changes in that range are not adopted.

## Adoption boundary

- **Opt-in.** The contract applies only to a new Assignment that states it uses `ops/task-workspace.md` at the commit above. It is not applied to existing tasks.
- **F-01 and L-01 are not adopted.** The contract cites `planning-lifecycle.md` (F-01) and `workspace-resources.md` (L-01); neither is in v0.9.0. F-01 section 4.1 may be read, at the upstream commit, as a reference for classifying a significant phase change. No Plan Decision, phase doc or Resource Ledger is required. If an Agent cannot tell whether a phase adjustment is an authorized, non-substantive implementation detail, it stops and asks the Human.
- **Local mapping.** The project's Assignment (`docs/ASSIGNMENT_POLICY.md`) is the Assignment; `docs/authorizations/` holds the authorization; the Assignment's stage plan, or a plan it links, is the Plan. The contract's `docs/tasks/<TASK-ID>/BRIEF.md` and `log.md` are created per task by the Assignment that opts in.
- **Entry point.** `AGENTS.md` item 8 gives every Agent the same Task ID recovery steps.
- **Unchanged.** The v0.9.0 pin, the M-02 and reviewer-lane clauses of UK-006, the UK-005 `kos.release-evidence` contract, KOS 2.0 core, the schema and the validator.
- **Capability limits.** Agents differ in tools. An Agent that cannot reach the repository or GitHub must ask for the material it needs, or the Human relays it. The write-permission rules are a protocol, not an operating-system or Git-server exclusive lock. This adoption does not provide fully automated cross-platform takeover.

## Protection of in-flight work

Existing active Codex tasks and worktrees are not migrated or modified by this adoption.

- No existing session is ended, restarted or taken over; no existing worktree, branch or uncommitted change is touched; no Writer is reassigned; no task is asked to migrate; no replacement or duplicate task is created.
- Bringing an existing task into Task Workspace needs a separate Human authorization. Before that, the then-current worktree and branch must be confirmed, the completed work and evidence saved, the current Writer and Git state confirmed, whether a new Assignment, plan, authorization and status record is needed decided, existing commits and uncommitted changes protected, and a safe way back to the current way of working kept.

## Review basis

No independent AI review is assigned (Product Lead decision). The change is docs-only. Mechanical checks and the Human's review of the diff are the basis; they are not an independent Architecture or Quality conclusion.

## Non-goals and separate authority

No app, extension, RIME, test, build or CI change. No change to `.kos/project.json`, `docs/ACTIVE_WORK.md`, existing Assignments, other contracts or the Kit. Publication (commit, push, PR, merge) needs its own explicit authorization. The post-merge M-02 closeout records the merged PR and commit and closes the Assignment.

Reopen this decision if the pinned file or commit changes, if the opt-in scope changes, if `required` mode or migration is requested, or if a real task shows the contract cannot be followed as written.
