# Assignment: GIT-BRANCH-ARCHIVE-HYGIENE-002 — Group B parked-branch tags

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | PR [#119](https://github.com/shchnk1103/Universe-Keyboard/pull/119) merged `bf0e6ec` (head `e372268`); feature branch deleted after reachability |
| **Non-claims** | No Group B delete in this Assignment; unique commits are **not** merged to `main`; not Product Gate / Release |
| **Next** | Keep disposition is [`GIT-BRANCH-ARCHIVE-HYGIENE-003`](git-branch-archive-hygiene-003.md) |
| **Residuals** | `A-GB-HYG-002-P2-01` `resolved` — [`Architecture review`](../reviews/GIT-BRANCH-ARCHIVE-HYGIENE-002-architecture-review.md) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [PD](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-002-authorization.md), Human Product Owner, `2026-09-11 Asia/Shanghai`
- **Product Approver:** Human Product Owner
- **Authorization:** [AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-002](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-002.md) (consumed) · [AUTH-…-MERGE](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-002-MERGE.md) (consumed)
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
| Current authorized slice | Not applicable | Group B tags and merge consumed; Assignment Closed | [AUTH](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-002.md) · [MERGE AUTH](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-002-MERGE.md) |
| Merge of this docs PR | Authorized | Consumed: PR [#119](https://github.com/shchnk1103/Universe-Keyboard/pull/119) merged `bf0e6ec` | Human: “批准合并 #119” |
| Group B branch delete | Not authorized | Successor [`GIT-BRANCH-ARCHIVE-HYGIENE-003`](git-branch-archive-hygiene-003.md) decided **keep** | New Assignment |
| Environment or external slice | Authorized | Current session GitHub: push the three archive tags and the docs-only branch | Same AUTH; host GitHub |

### Publication facts (P-01)

| Fact | Value |
|---|---|
| `local_candidate` | `e372268f3ce15c467e4abbf166dd6bfdda902249` |
| `published_head` | `e372268f3ce15c467e4abbf166dd6bfdda902249` |
| `hosted_ci_head` | `e372268f3ce15c467e4abbf166dd6bfdda902249` |
| `hosted_ci_result` | `green` (classify / lightweight / final-quality-gate SUCCESS; build-and-test SKIPPED) |
| `coverage` | `same-head` |
| `pr_state` | `merged` [#119](https://github.com/shchnk1103/Universe-Keyboard/pull/119) `bf0e6ec` |
| `local_ahead_of_published` | 0 |

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

- [x] Each Group B tag exists on `origin` and points at the recorded tip. See [evidence](../evidence/git-branch-archive-hygiene-002-group-b-2026-09-11.md).
- [x] Each Group B local branch name still exists at the same tip.
- [x] `git ls-remote --heads origin` for those three names remains empty.
- [x] Evidence records commands, SHAs, tag names, and the open-PR list.
- [x] Independent Architecture and Quality document reviews: [`Architecture Pass`](../reviews/GIT-BRANCH-ARCHIVE-HYGIENE-002-architecture-review.md) · [`Quality Pass`](../reviews/GIT-BRANCH-ARCHIVE-HYGIENE-002-quality-review.md).
- [x] Docs-only PR [#119](https://github.com/shchnk1103/Universe-Keyboard/pull/119) opened. Merge is not an exit criterion.
- [x] Assignment 001 Closed and Active Work / Dashboard synced.

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
- `2026-09-11 Asia/Shanghai` — Three Group B annotated tags pushed to `origin`. Local branch names kept. No origin heads created.
- `2026-09-11 Asia/Shanghai` — Architecture first Pass with conditions (`A-GB-HYG-002-P2-01` `fix`); plan Execution/Handoff aligned to 002; re-review Pass 0/0/0/0. Quality Pass 0/0/0/0.
- `2026-09-11 Asia/Shanghai` — Human authorized merge of #119. Merged `bf0e6ec`; `e372268` is an ancestor of `origin/main`; feature branch deleted. Assignment Closed. Keep/delete moved to 003.
