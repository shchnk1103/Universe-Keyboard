# Assignment: GIT-BRANCH-ARCHIVE-HYGIENE-001 — Group A parked-branch archive

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | Group A tag-then-delete authorized; execution from `origin/main` worktree `/private/tmp/universe-keyboard-group-a-hygiene` |
| **Non-claims** | No Group B tag/delete; no #101/#102; no Scheme Platform; no merge of the docs PR; no Product Gate / TestFlight / Release; unique Group A commits are **not** merged to `main` |
| **Next** | Execute Group A tags and deletes, write evidence, independent document reviews, push docs-only PR (merge not authorized) |
| **Residuals** | None yet |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [PD](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-001-authorization.md), Human Product Owner, `2026-09-11 Asia/Shanghai`
- **Product Approver:** Human Product Owner
- **Authorization:** [AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001.md)

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | Git-ref hygiene; no product/runtime/device claim |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment → Authorization → Accepted Product Decision bound only Group A |
| P-01 publication facts | Adopted | Docs-only feature branch and archive tags; table filled at publication handoff |
| D-01 final-documentation receipt | Not applicable | Ordinary docs-only link check after the last Markdown edit is not claimed as D-01 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current authorized slice | Authorized | `execute_group_a_parked_branch_archive`: tag+push+delete the three Group A branches; record evidence; docs-only commit/push/PR | This Assignment → [AUTH](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001.md) → [PD](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-001-authorization.md) |
| Merge of the docs PR | Not authorized | Merge / undraft-as-merge | New Human authorization |
| Group B tag or delete | Not authorized | Wanxiang P4 / kaomoji extra / release polish | New bounded Assignment and matching Authorization |
| Environment or external slice | Authorized | Current session GitHub: push annotated tags and `git push origin --delete` for the three Group A names only | Same AUTH; host GitHub |

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

Park the three closed/superseded Group A branch tips behind annotated archive
tags, then remove those branch names from local and `origin`, without merging
the leftover unique commits into `main`.

### Scope

1. Record this Assignment, Authorization, and Accepted Product Decision.
2. Revalidate open PRs and Group A SHAs against
   [`parked-branch-archive-hygiene-2026-09-11.md`](../plans/parked-branch-archive-hygiene-2026-09-11.md).
3. Create and push annotated tags:
   - `archive/codex-kos-v080-upgrade-review/20260911` → `7e090bd`
   - `archive/codex-td016-docs-only-fixture/20260911` → `bd4b6eb`
   - `archive/docs-t9-single-key-mixed-candidates-discussion/20260911` → `270f45b`
4. After each tag is on `origin` and `git rev-parse <tag>` equals the tip,
   delete the matching local and `origin` branch names.
5. Write execution evidence; independent Architecture and Quality document review.
6. Commit and push branch `docs/git-branch-archive-hygiene-001`; open a docs-only PR.

### Non-goals

- Tagging or deleting Group B (`wanxiang-p4-closure-001`, `release-2026-0801-kaomoji`, `release-2026-08-01-coordination-next`).
- Touching `codex/scheme-platform-001` / draft [#102](https://github.com/shchnk1103/Universe-Keyboard/pull/102) or `docs/adr-0034-architecture-accept-checklist` / draft [#101](https://github.com/shchnk1103/Universe-Keyboard/pull/101).
- Merging unique Group A commits onto `main`.
- Merging the documentation PR, Product Gate, TestFlight, Release, ADR Accept, Swift, SUG-08.
- Executing from the Scheme Platform checkout.

### Required Inputs

- Proposed packet [`parked-branch-archive-hygiene-2026-09-11.md`](../plans/parked-branch-archive-hygiene-2026-09-11.md) (commit `2c12cea`, cherry-picked).
- Human instruction in this session authorizing Group A only.
- Live `git fetch --prune origin` and `gh pr list --state open`.
- Closed PRs #103, #88, #46.

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Current Grok session
- **Environment Executor:** Current session — GitHub host operations limited to pushing the three archive tags, deleting the three Group A branch names on `origin`, and pushing the docs-only feature branch
- **Human Dependency:** Not Applicable — this chat is the Product authorization; force-delete of an untagged unique tip is forbidden, so no extra Human action is required
- **Architecture Reviewer:** independent runtime, lane `GIT-BRANCH-ARCHIVE-HYGIENE-001/document-architecture`, after execution evidence
- **Quality Reviewer:** independent runtime, lane `GIT-BRANCH-ARCHIVE-HYGIENE-001/document-quality`, after execution evidence
- **Handoff Target:** Human Product Owner (merge of docs PR; any Group B work)

## Gates

### Entry Criteria

- [x] Accepted Product Decision and Authorization resolve to Group A only.
- [x] No `UNKNOWN` responsibility field.
- [x] Open PRs at execution start are only #101 and #102; neither head is in the Group A allowlist.
- [x] Group A tips still match the packet: `7e090bd`, `bd4b6eb`, `270f45b`; none is an ancestor of `origin/main`.
- [x] Working copy is `/private/tmp/universe-keyboard-group-a-hygiene` on `docs/git-branch-archive-hygiene-001` from `origin/main` `6b24c37`, not `codex/scheme-platform-001`.

### Exit Criteria

- [ ] Each Group A tag exists on `origin` and points at the recorded tip.
- [ ] Each Group A branch name is absent from `git ls-remote --heads origin <name>` and deleted locally.
- [ ] Unique commits remain recoverable via `git fetch origin tag archive/…` / `git rev-parse`.
- [ ] Evidence records commands, SHAs, tag names, `ls-remote` results, and the open-PR list.
- [ ] Independent Architecture and Quality document reviews on the final docs diff.
- [ ] Docs-only feature branch pushed; PR opened. Merge is not an exit criterion.

### Stop Conditions

- An open PR whose head is a Group A name.
- A Group A tip SHA moved relative to the packet and no retag of the **current** tip was recorded.
- Attempt to delete a tip that is not tagged on `origin`.
- Working copy is `codex/scheme-platform-001`, or the grok bot still needs a Group A branch (it does not).
- Request to include Group B, #101, #102, merge, or Release in this slice.

## Handoff

- **Required Handoff Content:** tag names and SHAs; branch delete results; evidence path; both independent reviews; docs PR URL; explicit non-claims for Group B / #101 / #102 / merge.
- **Revalidation Trigger:** a Group A tip SHA change before tag push; an open PR appearing on a Group A head; a review finding that changes scope; any request to delete Group B or merge the docs PR.

## History

- `2026-09-11 Asia/Shanghai` — SUG-05 Proposed packet recorded at `2c12cea` on `docs/parked-branch-hygiene-proposed` (local only).
- `2026-09-11 Asia/Shanghai` — Human Product Owner authorized Group A execution in the current Grok session. This Assignment implements Group A only.
