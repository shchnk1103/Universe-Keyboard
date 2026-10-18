# KOS Kit `ops/task-workspace.md` Upgrade Record (UK-007)

- Owner: Human Product Owner; executor: an independent execution session in a fresh worktree.
- From: adopted v0.9.0 advisory, commit `c98b2813240e22b2ac7fec44b2445321b03f73e0`.
- Target: one contract file, `ops/task-workspace.md`, at Kit commit `9ca6dc015bf01084150538aac65cedc25b2a33a5`.
- Decision: [`PD-KOS-UPGRADE-UK-007`](../../product-decisions/KOS-UPGRADE-UK-007-task-workspace-adoption.md). Assignment: [`KOS-UPGRADE-UK-007`](../../assignments/kos-upgrade-uk-007-task-workspace.md).

## Frozen upstream facts

| Fact | Value |
|---|---|
| Commit | `9ca6dc015bf01084150538aac65cedc25b2a33a5`, squash merge of [PR #60](https://github.com/shchnk1103/kos-agent-kit/pull/60); parent `85f81357050d62cfa4d5d5c53ec8e3ea3bd5e3fe` |
| Release status | None. `VERSION` is 0.9.0; this commit is v0.9.0 plus 53 commits and has no tag or Release |
| File | `ops/task-workspace.md`, sha256 `91d3da26728c210de3b605f28f65e0377f9ee90b2f0eaf65c8e12b7f8cb5f76a`, git blob `cdf5f1763202db8439fd85bfad081a25ebc6ca58`, 14302 B |
| Kit tree | `314df6d76ea24eabd0c32605903760d7943d4467` |
| Not in this file | The review-packet and report-handoff section (it is in an unmerged upstream PR); no section 10 |

## What the contract provides

Task ID recovery steps; a BRIEF and an append-only log per task; HANDOFF and ACCEPT as the only way the single Writer changes; write permission released when the HANDOFF commit is pushed and acquired when the ACCEPT commit is pushed; the log on the fetched branch head as the only source of ownership, with Assignment and BRIEF mirrors never granting write permission; a Human-confirmed takeover path when a normal handoff is impossible; checkpoint content and triggers; and an `independence: independent | collaborative` label for reviews.

## Applicability to Universe Keyboard

| Contract dependency | At v0.9.0 | Handling here |
|---|---|---|
| R-07 Handoff Snapshot template | present | used for BRIEF |
| A-01 authorization resolution | present, opt-in | used by new Assignments that opt in |
| Writer lease (`agent-orchestration.md`) | present, not instantiated | cited only |
| F-01 `planning-lifecycle.md` | absent | not adopted; section 4.1 is a read-only classification reference |
| L-01 `workspace-resources.md` | absent | not adopted; no Resource Ledger |
| Project Assignment and authorization records | project-local | stand in for the contract's Assignment and AUTH |

The other upstream changes between v0.9.0 and the pinned commit (other ops contracts, schemas, scripts, templates, 24 files in total) are not adopted.

## Local checks at drafting time

The upstream file digest, blob and tree were recomputed from the pinned commit. The checks to run on the publication PR are: changed-path check (exactly the five authorized files), pin and digest check, `git diff --check`, the repository Markdown link check, the existing KOS validator, and the PR CI.

## Rollback

Revert the publication PR, which removes the five document changes. Nothing else depends on it: no tasks, no Profile, no worktrees.

## Residuals

The contract is not a Kit Release. It does not provide an exclusive lock or automatic takeover. The first real task that opts in may show gaps; those are handled by a new decision, not by this record.
