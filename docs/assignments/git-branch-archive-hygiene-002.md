# Assignment: GIT-BRANCH-ARCHIVE-HYGIENE-002 — Group B parked-branch tags

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | Group B tag-only slice authorized; worktree `/private/tmp/universe-keyboard-group-b-hygiene` from `origin/main` `bb15b27` |
| **Non-claims** | No Group B delete; no #101/#102; no Scheme Platform; no merge of this docs PR; no Product Gate / TestFlight / Release; unique commits are **not** merged to `main` |
| **Next** | Push three annotated tags; evidence; independent reviews; docs-only PR (merge not authorized) |
| **Residuals** | None yet |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [PD](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-002-authorization.md), Human Product Owner, `2026-09-11 Asia/Shanghai`
- **Product Approver:** Human Product Owner
- **Authorization:** [AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-002](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-002.md)
- **Predecessor:** Closed [GIT-BRANCH-ARCHIVE-HYGIENE-001](git-branch-archive-hygiene-001.md) (Group A tag-then-delete; PR [#118](https://github.com/shchnk1103/Universe-Keyboard/pull/118) merged `bb15b27`)

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | Git-ref hygiene; no product/runtime/device claim |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment → Authorization → Accepted Product Decision bound only Group B tags |
| P-01 publication facts | Adopted | Docs-only feature branch and archive tags; table filled at publication handoff |
| D-01 final-documentation receipt | Not applicable | Ordinary docs-only link check is not claimed as D-01 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current authorized slice | Authorized | `execute_group_b_parked_branch_archive_tags`: tag+push three local tips; do not delete; Close 001 M-02; docs PR | This Assignment → [AUTH](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-002.md) → [PD](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-002-authorization.md) |
| Merge of this docs PR | Not authorized | Merge | New Human authorization |
| Group B branch delete | Not authorized | Delete local or `origin` names after tagging | New bounded Assignment and matching Authorization |
| Environment or external slice | Authorized | Current session GitHub: push the three archive tags and the docs-only branch | Same AUTH; host GitHub |

### Publication facts (P-01)

| Fact | Value |
|---|---|
| `local_candidate` | unknown until the docs commit exists |
| `published_head` | none |
| `hosted_ci_head` | unknown |
| `hosted_ci_result` | unknown |
| `coverage` | unknown |
| `pr_state` | none |
| `local_ahead_of_published` | unknown |

## Boundary

### Objective

Make the three Group B unique tips reachable on `origin` via annotated archive
tags, without deleting the branch names and without merging those commits to
`main`.

### Scope

1. Record this Assignment, Authorization, and Accepted Product Decision.
2. Close [GIT-BRANCH-ARCHIVE-HYGIENE-001](git-branch-archive-hygiene-001.md) after PR #118 merge (M-02 mirrors).
3. Revalidate Group B tips against
   [`parked-branch-archive-hygiene-2026-09-11.md`](../plans/parked-branch-archive-hygiene-2026-09-11.md).
4. Create and push annotated tags:
   - `archive/codex-wanxiang-p4-closure-001/20260911` → `e83e6358de8621e24522294542539d029c91b080`
   - `archive/codex-release-2026-0801-kaomoji/20260911` → `d3680c347181d65703327b324951b6d931d637aa`
   - `archive/codex-release-2026-08-01-coordination-next/20260911` → `3444826983bb7b4e49ef96f9eb165964880ca8b9`
5. Leave local branch names in place. Do not `git push origin --delete` them.
6. Write execution evidence; independent Architecture and Quality document review.
7. Commit and push `docs/git-branch-archive-hygiene-002`; open a docs-only PR.

### Non-goals

- Deleting Group B branches.
- Touching `codex/scheme-platform-001` / [#102](https://github.com/shchnk1103/Universe-Keyboard/pull/102) or `docs/adr-0034-architecture-accept-checklist` / [#101](https://github.com/shchnk1103/Universe-Keyboard/pull/101).
- Merging unique Group B commits onto `main`.
- Merging this documentation PR, Product Gate, TestFlight, Release, ADR Accept, Swift, SUG-08.
- Executing from the Scheme Platform checkout.

### Required Inputs

- Plan [`parked-branch-archive-hygiene-2026-09-11.md`](../plans/parked-branch-archive-hygiene-2026-09-11.md) Group B inventory.
- Closed predecessor 001 / merged #118.
- Live `git fetch --prune origin` and `gh pr list --state open`.
- Local tips `e83e635` / `d3680c3` / `3444826` (no `origin` heads at start).

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Current Grok session
- **Environment Executor:** Current session — GitHub host operations limited to pushing the three archive tags and the docs-only feature branch
- **Human Dependency:** Not Applicable — this chat is the Product authorization; branch delete is out of scope
- **Architecture Reviewer:** independent runtime, lane `GIT-BRANCH-ARCHIVE-HYGIENE-002/document-architecture`, after execution evidence
- **Quality Reviewer:** independent runtime, lane `GIT-BRANCH-ARCHIVE-HYGIENE-002/document-quality`, after execution evidence
- **Handoff Target:** Human Product Owner (merge of docs PR; any later Group B delete)

## Gates

### Entry Criteria

- [x] Accepted Product Decision and Authorization resolve to Group B tags only (no delete).
- [x] No `UNKNOWN` responsibility field.
- [x] Open PRs are only #101 and #102; neither head is a Group B name.
- [x] Group B tips match the packet and are not ancestors of `origin/main` `bb15b27`.
- [x] Working copy is `/private/tmp/universe-keyboard-group-b-hygiene` on `docs/git-branch-archive-hygiene-002`, not `codex/scheme-platform-001`.

### Exit Criteria

- [ ] Each Group B tag exists on `origin` and points at the recorded tip.
- [ ] Each Group B local branch name still exists at the same tip.
- [ ] `git ls-remote --heads origin` for those three names remains empty (they were local-only; this slice does not create remote heads).
- [ ] Evidence records commands, SHAs, tag names, and the open-PR list.
- [ ] Independent Architecture and Quality document reviews.
- [ ] Docs-only PR opened. Merge is not an exit criterion.
- [ ] Assignment 001 Closed and Active Work / Dashboard synced.

### Stop Conditions

- An open PR whose head is a Group B name.
- A Group B tip SHA moved relative to the packet and no retag of the **current** tip was recorded.
- Attempt to delete a Group B branch.
- Working copy is `codex/scheme-platform-001`.
- Request to include #101, #102, merge, Release, or Group B delete in this slice.

## Handoff

- **Required Handoff Content:** tag names and SHAs; proof branches were not deleted; evidence path; both independent reviews; docs PR URL; explicit non-claims for delete / #101 / #102 / merge.
- **Revalidation Trigger:** a Group B tip SHA change before tag push; an open PR appearing on a Group B head; a review finding that changes scope; any request to delete Group B branches or merge the docs PR.

## History

- `2026-09-11 Asia/Shanghai` — Human authorized merge of #118 and Group B work in the same instruction. This Assignment implements Group B **tags only**.
